#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'USAGE'
Usage:
  install-solution-commit-msg-hook.sh [--repo PATH] [--force]

Installs the Porter Codex solution commit-msg hook into one Git repository.
USAGE
}

repo="."
force=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --repo)
      repo="${2:-}"
      shift 2
      ;;
    --force)
      force=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 2
      ;;
  esac
done

if [ -z "$repo" ]; then
  usage
  exit 2
fi

script_path="${BASH_SOURCE[0]}"
while [ -L "$script_path" ]; do
  link="$(readlink "$script_path")"
  case "$link" in
    /*) script_path="$link" ;;
    *) script_path="$(cd "$(dirname "$script_path")" && pwd)/$link" ;;
  esac
done

script_dir="$(cd "$(dirname "$script_path")" && pwd)"
source_hook="$script_dir/solution-commit-msg-hook.sh"

if [ -f "$source_hook" ]; then
  chmod +x "$source_hook"
fi

if [ ! -x "$source_hook" ]; then
  echo "Source hook not executable: $source_hook" >&2
  exit 2
fi

repo_root="$(git -C "$repo" rev-parse --show-toplevel)"
hook_path="$(git -C "$repo_root" rev-parse --git-path hooks/commit-msg)"
case "$hook_path" in
  /*) target_hook="$hook_path" ;;
  *) target_hook="$repo_root/$hook_path" ;;
esac

hook_dir="$(dirname "$target_hook")"
mkdir -p "$hook_dir"

if [ -e "$target_hook" ] || [ -L "$target_hook" ]; then
  current_target="$(readlink "$target_hook" || true)"
  if [ "$current_target" != "$source_hook" ] && [ "$force" -ne 1 ]; then
    echo "commit-msg hook already exists: $target_hook" >&2
    echo "Re-run with --force only after confirming it is safe to replace." >&2
    exit 1
  fi
fi

ln -sfn "$source_hook" "$target_hook"

echo "Installed solution commit-msg hook: $target_hook -> $source_hook"
