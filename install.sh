#!/usr/bin/env bash
set -euo pipefail

CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
DRY_RUN=false
ONLY=""
SUMMARY=()

usage() {
  cat <<EOF
Usage: ./install.sh <command> [OPTIONS]

Commands:
  sync      Sync claude-plugin assets to ~/.claude

Options (for sync):
  --only commands|skills|settings   Only sync specified asset type
  --dry-run                         Preview changes without writing

Flags:
  --help                            Show this help message

Examples:
  ./install.sh sync
  ./install.sh sync --dry-run
  ./install.sh sync --only commands
EOF
}

# Dependency checks
if ! command -v rsync &>/dev/null; then
  echo "Error: rsync is required but not found. Install via: brew install rsync"
  exit 1
fi
if ! command -v python3 &>/dev/null; then
  echo "Error: python3 is required but not found. Install via: brew install python3"
  exit 1
fi

COMMAND=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    sync)      COMMAND="sync" ;;
    --dry-run) DRY_RUN=true ;;
    --only)    ONLY="$2"; shift ;;
    --help)    usage; exit 0 ;;
    *) echo "Error: unknown command '$1'"; echo ""; usage; exit 1 ;;
  esac
  shift
done

if [[ -z "$COMMAND" ]]; then
  usage
  exit 0
fi

_rsync_sync() {
  local label="$1" src="$2" dest="$3"
  local rsync_opts="-av --stats"
  $DRY_RUN && rsync_opts="$rsync_opts --dry-run"
  local output
  output=$(rsync $rsync_opts "$src" "$dest")
  local files
  files=$(echo "$output" | grep '\.md$' || true)
  local count
  count=$(echo "$output" | grep -E 'Number of (regular )?files transferred' | awk '{print $NF}' || true)
  SUMMARY+=("$label: ${count:-0} file(s) → $dest")
  if [[ -n "$files" ]]; then
    while IFS= read -r f; do
      SUMMARY+=("    - $f")
    done <<< "$files"
  fi
}

sync_commands() {
  _rsync_sync "commands" "$REPO_ROOT/commands/" "$CLAUDE_HOME/commands/"
}

sync_skills() {
  _rsync_sync "skills  " "$REPO_ROOT/skills/" "$CLAUDE_HOME/skills/"
}

merge_settings() {
  local repo_settings="$REPO_ROOT/settings/settings.json"
  local target="$CLAUDE_HOME/settings.json"

  if [[ ! -f "$target" ]]; then
    if ! $DRY_RUN; then
      cp "$repo_settings" "$target"
    fi
    SUMMARY+=("settings: copied → $target")
    return
  fi

  local merged
  merged=$(python3 -c "
import json
base = json.load(open('$target'))
patch = json.load(open('$repo_settings'))
def deep_merge(b, p):
    for k, v in p.items():
        if k in b and isinstance(b[k], dict) and isinstance(v, dict):
            deep_merge(b[k], v)
        else:
            b[k] = v
    return b
print(json.dumps(deep_merge(base, patch), indent=2, ensure_ascii=False))
")

  if $DRY_RUN; then
    SUMMARY+=("settings: merged (dry-run) → $target")
  else
    echo "$merged" > "$target"
    SUMMARY+=("settings: merged → $target")
  fi
}

main() {
  case "$ONLY" in
    commands) sync_commands ;;
    skills)   sync_skills ;;
    settings) merge_settings ;;
    "")
      sync_commands
      sync_skills
      merge_settings
      ;;
    *) echo "Unknown --only value: $ONLY"; usage; exit 1 ;;
  esac

  echo ""
  echo "==> Summary"
  for line in "${SUMMARY[@]}"; do
    echo "    $line"
  done
  echo ""
  echo "Done. Target: $CLAUDE_HOME"
  if $DRY_RUN; then echo "(dry-run mode — no files were written)"; fi
}

main
