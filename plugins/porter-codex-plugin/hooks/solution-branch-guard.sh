#!/usr/bin/env bash
set -euo pipefail

main() {
  local input cwd repo_root branch target_paths target_path abs_target
  input="$(cat)"
  cwd="$(pwd)"

  repo_root="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || true)"
  [ -n "$repo_root" ] || exit 0

  branch="$(git -C "$repo_root" branch --show-current 2>/dev/null || true)"
  [ -n "$branch" ] || exit 0
  case "$branch" in
    main|master) exit 0 ;;
  esac

  target_paths="$(extract_target_paths "$input")"
  [ -n "$target_paths" ] || exit 0

  while IFS= read -r target_path; do
    [ -n "$target_path" ] || continue
    abs_target="$(absolute_path "$cwd" "$target_path")"
    abs_target="$(real_path "$abs_target")"
    maybe_rename_for_solution_task "$repo_root" "$branch" "$abs_target"
  done <<< "$target_paths"
}

extract_target_paths() {
  python3 - "$1" <<'PY'
import json
import re
import sys

try:
    data = json.loads(sys.argv[1])
except Exception:
    raise SystemExit

targets = []

def add(value):
    if isinstance(value, str) and value:
        targets.append(value.strip().strip('"').strip("'"))

tool_input = data.get("tool_input") or data.get("input") or {}
if isinstance(tool_input, dict):
    for key in ("file_path", "filePath", "path", "target_path"):
        add(tool_input.get(key))

command = ""
if isinstance(tool_input, dict):
    command = tool_input.get("command") or tool_input.get("cmd") or ""
    if not command:
        command = tool_input.get("patch") or tool_input.get("input") or ""
elif isinstance(tool_input, str):
    command = tool_input
if not command:
    command = data.get("command") or data.get("cmd") or ""
if not command:
    command = data.get("patch") or ""

if isinstance(command, str):
    patterns = [
        r"\*\*\* (?:Add|Update|Delete) File: ([^\n]+)",
        r"(?:>|>>)\s*([^\s]+)",
        r"\b(?:touch|rm|mv|cp)\s+(?:-[^\s]+\s+)*([^\s]+)",
    ]
    for pattern in patterns:
        for match in re.finditer(pattern, command):
            add(match.group(1))

seen = set()
for target in targets:
    if target and target not in seen:
        seen.add(target)
        print(target)
PY
}

maybe_rename_for_solution_task() {
  local repo_root="$1"
  local branch="$2"
  local abs_target="$3"
  local current_file

  for current_file in "$repo_root"/.codex/timeline/*/current.json; do
    [ -f "$current_file" ] || continue
    maybe_rename_for_current "$repo_root" "$branch" "$abs_target" "$current_file"
  done
}

maybe_rename_for_current() {
  local repo_root="$1"
  local branch="$2"
  local abs_target="$3"
  local current_file="$4"
  local active_slice task state_path state_file state desired_branch
  local abs_task

  active_slice="$(json_string active_slice "$current_file")"
  task="$(json_string task "$current_file")"
  state_path="$(json_string state "$current_file")"

  [ -n "$active_slice" ] || return 0
  [ -n "$task" ] || return 0
  [ -n "$state_path" ] || return 0

  state_file="$(repo_path "$repo_root" "$state_path")"
  [ -f "$state_file" ] || return 0

  state="$(json_string state "$state_file")"
  [ "$state" = "awaiting_solution_task" ] || return 0

  abs_task="$(real_path "$(repo_path "$repo_root" "$task")")"
  [ "$abs_target" = "$abs_task" ] || return 0

  desired_branch="$(branch_from_slice "$active_slice")"
  [ -n "$desired_branch" ] || return 0
  [ "$branch" != "$desired_branch" ] || return 0

  guard_clean_rename "$repo_root" "$branch" "$desired_branch"
  git -C "$repo_root" branch -m "$desired_branch"
  echo "[solution-branch-guard] renamed local branch: $branch -> $desired_branch" >&2
  exit 0
}

branch_from_slice() {
  local slice="$1"
  python3 - "$slice" <<'PY'
import re
import sys

slice_id = sys.argv[1]
match = re.match(r"^\d{3}-([a-z]+)-(.+)$", slice_id)
if not match:
    raise SystemExit
kind, slug = match.groups()
allowed = {"feat", "fix", "refactor", "perf", "test", "docs", "build", "ci", "chore", "style"}
if kind not in allowed:
    raise SystemExit
slug = re.sub(r"[^a-z0-9._-]+", "-", slug.lower()).strip("-.")
if not slug:
    raise SystemExit
print(f"{kind}/{slug}")
PY
}

guard_clean_rename() {
  local repo_root="$1"
  local branch="$2"
  local desired_branch="$3"

  if git -C "$repo_root" show-ref --verify --quiet "refs/heads/$desired_branch"; then
    echo "[solution-branch-guard] cannot rename '$branch' to '$desired_branch': target branch already exists" >&2
    exit 1
  fi

  case "$desired_branch" in
    main|master|*/..|../*|*..*|*" "*|*~*|*^*|*:*|*\?*|*\**|*\[*|*\\*)
      echo "[solution-branch-guard] invalid desired branch name: $desired_branch" >&2
      exit 1
      ;;
  esac

  if git -C "$repo_root" config --get "branch.$branch.remote" >/dev/null 2>&1 || \
    git -C "$repo_root" config --get "branch.$branch.merge" >/dev/null 2>&1; then
    echo "[solution-branch-guard] current branch '$branch' has upstream config; rename manually after checking remote/PR impact" >&2
    exit 1
  fi
}

json_string() {
  local key="$1"
  local file="$2"
  python3 - "$key" "$file" <<'PY'
import json
import sys

key, file_name = sys.argv[1], sys.argv[2]
try:
    with open(file_name, "r", encoding="utf-8") as f:
        value = json.load(f).get(key, "")
except Exception:
    value = ""
print(value if isinstance(value, str) else "")
PY
}

repo_path() {
  local repo_root="$1"
  local path="$2"
  case "$path" in
    /*) printf '%s\n' "$path" ;;
    *) printf '%s/%s\n' "$repo_root" "$path" ;;
  esac
}

absolute_path() {
  local cwd="$1"
  local path="$2"
  case "$path" in
    /*) printf '%s\n' "$path" ;;
    *) printf '%s/%s\n' "$cwd" "$path" ;;
  esac
}

real_path() {
  python3 - "$1" <<'PY'
import os
import sys

print(os.path.realpath(sys.argv[1]))
PY
}

main "$@"
