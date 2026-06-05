#!/usr/bin/env bash
set -euo pipefail

main() {
  local input
  input=$(cat)

  local cwd tool_name target_path
  cwd=$(pwd)
  tool_name=$(json_field "$input" tool_name)
  target_path=$(extract_path "$input")

  if [ -z "$target_path" ]; then
    exit 0
  fi

  local abs_path
  abs_path=$(absolute_path "$cwd" "$target_path")
  abs_path=$(real_path "$abs_path")

  guard_worktree_path "$cwd" "$abs_path"
  guard_workflow_stage "$cwd" "$tool_name" "$abs_path"
}

json_field() {
  python3 - "$1" "$2" <<'PY'
import json
import sys

try:
    data = json.loads(sys.argv[1])
except Exception:
    print("")
    raise SystemExit

key = sys.argv[2]
value = data.get(key, "")
if not value:
    tool_input = data.get("tool_input") or data.get("input") or {}
    if isinstance(tool_input, dict):
        value = tool_input.get(key, "")
print(value if isinstance(value, str) else "")
PY
}

extract_path() {
  python3 - "$1" <<'PY'
import json
import re
import sys

try:
    data = json.loads(sys.argv[1])
except Exception:
    print("")
    raise SystemExit

tool_input = data.get("tool_input") or data.get("input") or {}
if isinstance(tool_input, dict):
    for key in ("file_path", "path", "target_path"):
        value = tool_input.get(key)
        if isinstance(value, str) and value:
            print(value)
            raise SystemExit

command = ""
if isinstance(tool_input, dict):
    command = tool_input.get("command") or tool_input.get("cmd") or ""
if not command:
    command = data.get("command") or data.get("cmd") or ""

if isinstance(command, str):
    patterns = [
        r"\*\*\* (?:Add|Update|Delete) File: ([^\n]+)",
        r"(?:>|>>)\s*([^\s]+)",
        r"\b(?:touch|rm|mv|cp)\s+(?:-[^\s]+\s+)*([^\s]+)",
    ]
    for pattern in patterns:
        match = re.search(pattern, command)
        if match:
            print(match.group(1).strip().strip('"').strip("'"))
            raise SystemExit

print("")
PY
}

absolute_path() {
  local cwd=$1
  local path=$2
  if [[ "$path" = /* ]]; then
    printf '%s\n' "$path"
  else
    printf '%s/%s\n' "$cwd" "$path"
  fi
}

guard_worktree_path() {
  local cwd=$1
  local abs_path=$2

  [[ "$cwd" == *"/.codex/worktrees/"* ]] || return 0

  local worktree_dir
  worktree_dir=$(printf '%s\n' "$cwd" | sed -E 's#^(.*/\.codex/worktrees/[^/]+/[^/]+).*#\1#')
  worktree_dir=$(real_path "$worktree_dir")

  if [[ "$abs_path" != "$worktree_dir/"* && "$abs_path" != "$worktree_dir" ]]; then
    echo "[workflow-guard] 当前在 worktree ($worktree_dir)，写入路径必须以当前 worktree 为基准：$abs_path" >&2
    exit 1
  fi
}

guard_workflow_stage() {
  local cwd=$1
  local tool_name=$2
  local abs_path=$3
  local branch state_file state

  branch=$(git -C "$cwd" branch --show-current 2>/dev/null || true)
  [ -n "$branch" ] || return 0

  state_file=$(state_file_for_branch "$cwd" "$branch")
  [ -f "$state_file" ] || return 0

  state=$(python3 - "$state_file" <<'PY'
import json
import sys

try:
    with open(sys.argv[1], "r", encoding="utf-8") as f:
        print(json.load(f).get("state", ""))
except Exception:
    print("")
PY
)

  case "$state" in
    awaiting_task)
      allow_only_plan_file "$abs_path" "$state_file" "ANALYSIS.md" "当前处于 analyze-bug 完成后的 awaiting_task 状态，请显式调用 \$porter-codex-plugin:task 后再修改实现文件。"
      ;;
    awaiting_execute)
      allow_only_plan_file "$abs_path" "$state_file" "TASK.md" "当前处于 task 完成后的 awaiting_execute 状态，请显式调用 \$porter-codex-plugin:execute 后再修改实现文件。"
      ;;
    executing|execution_allowed)
      return 0
      ;;
  esac
}

state_file_for_branch() {
  local cwd=$1
  local branch=$2
  local type name root

  type=${branch%%/*}
  name=${branch#*/}
  root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || printf '%s\n' "$cwd")
  root=$(real_path "$root")
  printf '%s/plan/%s/%s/WORKFLOW_STATE.json\n' "$root" "$type" "$name"
}

allow_only_plan_file() {
  local abs_path=$1
  local state_file=$2
  local allowed_name=$3
  local message=$4
  local plan_dir

  plan_dir=$(dirname "$state_file")
  plan_dir=$(real_path "$plan_dir")
  state_file=$(real_path "$state_file")
  if [[ "$abs_path" == "$plan_dir/$allowed_name" || "$abs_path" == "$state_file" ]]; then
    return 0
  fi

  echo "[workflow-guard] $message" >&2
  echo "[workflow-guard] blocked path: $abs_path" >&2
  exit 1
}

real_path() {
  python3 - "$1" <<'PY'
import os
import sys

print(os.path.realpath(sys.argv[1]))
PY
}

main "$@"
