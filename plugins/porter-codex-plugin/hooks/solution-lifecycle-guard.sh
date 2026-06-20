#!/usr/bin/env bash
set -euo pipefail

main() {
  local input cwd repo_root command target_paths target_path abs_target
  input="$(cat)"
  cwd="$(pwd)"

  repo_root="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || true)"
  [ -n "$repo_root" ] || exit 0

  command="$(extract_command "$input")"
  if [ -n "$command" ]; then
    guard_awaiting_commit_bash "$repo_root" "$command"
  fi

  if is_git_commit_command "$command"; then
    guard_git_commit "$repo_root"
  fi

  if is_git_add_command "$command"; then
    guard_git_add "$repo_root" "$command"
  fi

  target_paths="$(extract_target_paths "$input")"
  [ -n "$target_paths" ] || exit 0

  while IFS= read -r target_path; do
    [ -n "$target_path" ] || continue
    abs_target="$(absolute_path "$cwd" "$target_path")"
    abs_target="$(real_path "$abs_target")"
    guard_awaiting_commit_write "$repo_root" "$abs_target"
  done <<< "$target_paths"
}

extract_command() {
  python3 - "$1" <<'PY'
import json
import sys

try:
    data = json.loads(sys.argv[1])
except Exception:
    raise SystemExit

tool_input = data.get("tool_input") or data.get("input") or {}
command = ""
if isinstance(tool_input, dict):
    command = tool_input.get("command") or tool_input.get("cmd") or ""
    if not command:
        command = tool_input.get("patch") or tool_input.get("input") or ""
elif isinstance(tool_input, str):
    command = tool_input
if not command:
    command = data.get("command") or data.get("cmd") or data.get("patch") or ""

if isinstance(command, str):
    print(command)
PY
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

is_git_commit_command() {
  local command="$1"
  [ -n "$command" ] || return 1
  printf '%s\n' "$command" | grep -Eq '(^|[;&|[:space:]])git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+commit([[:space:]]|$)'
}

is_git_add_command() {
  local command="$1"
  [ -n "$command" ] || return 1
  printf '%s\n' "$command" | grep -Eq '(^|[;&|[:space:]])git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+add([[:space:]]|$)'
}

has_awaiting_commit_state() {
  local repo_root="$1"
  local current_file state_file state

  for current_file in "$repo_root"/.codex/timeline/*/current.json; do
    [ -f "$current_file" ] || continue
    state_file="$(state_file_for_current "$repo_root" "$current_file")"
    [ -n "$state_file" ] || continue
    [ -f "$state_file" ] || continue

    state="$(json_string state "$state_file")"
    case "$state" in
      awaiting_user_commit_confirm|committing)
        return 0
        ;;
    esac
  done

  return 1
}

guard_awaiting_commit_bash() {
  local repo_root="$1"
  local command="$2"

  has_awaiting_commit_state "$repo_root" || return 0

  if is_allowed_commit_confirmation_command "$command"; then
    return 0
  fi

  echo "[solution-lifecycle-guard] Bash is restricted while a solution slice is awaiting commit confirmation." >&2
  echo "[solution-lifecycle-guard] Only hook installation, explicit git add of reviewed paths, git commit, and read-only git/status commands are allowed." >&2
  echo "[solution-lifecycle-guard] Run solution-execute for new writes or composite shell commands." >&2
  exit 1
}

is_allowed_commit_confirmation_command() {
  local command="$1"
  python3 - "$command" <<'PY'
import shlex
import sys

command = sys.argv[1]
try:
    tokens = shlex.split(command)
except Exception:
    raise SystemExit(1)

if not tokens:
    raise SystemExit(1)

danger = {";", "&&", "||", "|"}
if any(token in danger for token in tokens):
    raise SystemExit(1)

if (
    tokens[0] == "plugins/porter-codex-plugin/scripts/install-solution-commit-msg-hook.sh"
    and tokens[1:] == ["--repo", "."]
):
    raise SystemExit(0)

i = 0
if tokens[i] != "git":
    raise SystemExit(1)
i += 1
if i < len(tokens) and tokens[i] == "-C":
    i += 2
if i >= len(tokens):
    raise SystemExit(1)

verb = tokens[i]
readonly = {
    "status",
    "diff",
    "show",
    "log",
    "rev-parse",
    "ls-files",
}
if verb in {"add", "commit"} or verb in readonly:
    raise SystemExit(0)
raise SystemExit(1)
PY
}

guard_git_commit() {
  local repo_root="$1"
  local current_file state_file state timeline slice blocked details
  blocked=0
  details=""

  if has_staged_committed_match "$repo_root"; then
    return 0
  fi

  for current_file in "$repo_root"/.codex/timeline/*/current.json; do
    [ -f "$current_file" ] || continue
    state_file="$(state_file_for_current "$repo_root" "$current_file")"
    [ -n "$state_file" ] || continue
    [ -f "$state_file" ] || continue

    state="$(json_string state "$state_file")"
    case "$state" in
      committed|cancelled) continue ;;
    esac

    timeline="$(json_string timeline "$current_file")"
    slice="$(json_string active_slice "$current_file")"
    [ -n "$timeline" ] || timeline="$(dirname "$current_file")"
    blocked=1
    details="${details}
- $(basename "$timeline") / ${slice:-unknown} is '${state:-missing}'"
  done

  if [ "$blocked" -eq 1 ]; then
    echo "[solution-lifecycle-guard] git commit is blocked because an active solution slice is not finalized:" >&2
    printf '%s\n' "$details" >&2
    echo "[solution-lifecycle-guard] run the recorded next solution skill, or use commit confirmation to stage a committed state before git commit." >&2
    exit 1
  fi
}

has_staged_committed_match() {
  local repo_root="$1"
  local staged_state

  while IFS= read -r staged_state; do
    [ -n "$staged_state" ] || continue
    if git -C "$repo_root" show ":$staged_state" 2>/dev/null | grep -Eq '"state"[[:space:]]*:[[:space:]]*"committed"'; then
      return 0
    fi
  done < <(git -C "$repo_root" diff --cached --name-only -- '.codex/timeline/*/states/*.json' 2>/dev/null || true)

  return 1
}

guard_git_add() {
  local repo_root="$1"
  local command="$2"
  local current_file state_file state timeline slice add_paths path abs_path

  for current_file in "$repo_root"/.codex/timeline/*/current.json; do
    [ -f "$current_file" ] || continue
    state_file="$(state_file_for_current "$repo_root" "$current_file")"
    [ -n "$state_file" ] || continue
    [ -f "$state_file" ] || continue

    state="$(json_string state "$state_file")"
    case "$state" in
      awaiting_user_commit_confirm|committing) ;;
      *) continue ;;
    esac

    add_paths="$(extract_git_add_paths "$repo_root" "$command")"
    if [ -n "$add_paths" ]; then
      local all_allowed=1
      while IFS= read -r path; do
        [ -n "$path" ] || continue
        abs_path="$(repo_path "$repo_root" "$path")"
        abs_path="$(real_path "$abs_path")"
        if ! commit_stage_path_allowed "$repo_root" "$state_file" "$abs_path"; then
          all_allowed=0
        fi
      done <<< "$add_paths"
      [ "$all_allowed" -eq 1 ] && continue
    fi

    timeline="$(json_string timeline "$current_file")"
    slice="$(json_string active_slice "$current_file")"
    [ -n "$timeline" ] || timeline="$(dirname "$current_file")"
    echo "[solution-lifecycle-guard] git add is blocked while $(basename "$timeline") / ${slice:-unknown} is $state." >&2
    echo "[solution-lifecycle-guard] only explicit reviewed_paths plus the review contract and active state file may be staged for commit confirmation." >&2
    echo "[solution-lifecycle-guard] call solution-execute for new changes, or avoid broad/composite pathspecs." >&2
    exit 1
  done
}

extract_git_add_paths() {
  local repo_root="$1"
  local command="$2"
  python3 - "$repo_root" "$command" <<'PY'
import os
import shlex
import sys

repo_root, command = sys.argv[1], sys.argv[2]
try:
    tokens = shlex.split(command)
except Exception:
    raise SystemExit

paths = []
i = 0
while i < len(tokens):
    if tokens[i] != "git":
        i += 1
        continue

    i += 1
    git_cwd = repo_root
    if i < len(tokens) and tokens[i] == "-C":
        if i + 1 >= len(tokens):
            raise SystemExit
        git_cwd = tokens[i + 1]
        if not os.path.isabs(git_cwd):
            git_cwd = os.path.normpath(os.path.join(repo_root, git_cwd))
        i += 2

    if i >= len(tokens) or tokens[i] != "add":
        continue

    i += 1
    local_paths = []
    while i < len(tokens):
        token = tokens[i]
        if token in {";", "&&", "||", "|"}:
            break
        if token == "--":
            i += 1
            continue
        if token in {"-A", "--all", "-u", "--update", "."}:
            raise SystemExit
        if token.startswith("-"):
            i += 1
            continue
        abs_path = token if os.path.isabs(token) else os.path.normpath(os.path.join(git_cwd, token))
        try:
            rel = os.path.relpath(abs_path, repo_root)
        except Exception:
            raise SystemExit
        if rel.startswith(".." + os.sep) or rel == "..":
            raise SystemExit
        local_paths.append(rel)
        i += 1

    if not local_paths:
        raise SystemExit
    paths.extend(local_paths)

for path in paths:
    print(path)
PY
}

commit_stage_path_allowed() {
  local repo_root="$1"
  local state_file="$2"
  local abs_path="$3"
  local abs_state contract_path abs_contract reviewed_path abs_reviewed rel_reviewed

  abs_state="$(real_path "$state_file")"
  [ "$abs_path" = "$abs_state" ] && return 0

  contract_path="$(contract_path_for_state "$repo_root" "$state_file")"
  if [ -z "$contract_path" ]; then
    return 1
  fi

  abs_contract="$(real_path "$(repo_path "$repo_root" "$contract_path")")"
  [ "$abs_path" = "$abs_contract" ] && worktree_contract_matches_anchor "$repo_root" "$state_file" "$contract_path" && return 0

  while IFS= read -r reviewed_path; do
    [ -n "$reviewed_path" ] || continue
    abs_reviewed="$(repo_path "$repo_root" "$reviewed_path")"
    abs_reviewed="$(real_path "$abs_reviewed")"
    if [ "$abs_path" = "$abs_reviewed" ]; then
      rel_reviewed="$(repo_relative_path "$repo_root" "$abs_reviewed")"
      worktree_path_matches_contract "$repo_root" "$contract_path" "$rel_reviewed" && return 0
      echo "[solution-lifecycle-guard] $rel_reviewed changed after review; run solution-execute and solution-review again." >&2
      return 1
    fi
  done <<< "$(contract_json_string_array reviewed_paths "$repo_root" "$contract_path")"

  return 1
}

contract_path_for_state() {
  local repo_root="$1"
  local state_file="$2"
  local rel_state prefix file slice
  rel_state="$(repo_relative_path "$repo_root" "$state_file")"
  case "$rel_state" in
    .codex/timeline/*/states/*.json) ;;
    *) return 1 ;;
  esac
  prefix="${rel_state%/states/*}"
  file="${rel_state##*/}"
  slice="${file%.json}"
  printf '%s/reviews/%s.contract.json\n' "$prefix" "$slice"
}

worktree_contract_matches_anchor() {
  local repo_root="$1"
  local state_file="$2"
  local contract_path="$3"
  local timeline slice expected actual

  timeline="$(basename "$(json_string timeline "$state_file")")"
  slice="$(json_string active_slice "$state_file")"
  expected="$(contract_anchor_blob "$repo_root" "$timeline" "$slice")"
  [ -n "$expected" ] || return 1
  [ -f "$repo_root/$contract_path" ] || return 1
  actual="$(git -C "$repo_root" hash-object --path="$contract_path" -- "$repo_root/$contract_path" 2>/dev/null || true)"
  [ -n "$actual" ] || return 1
  [ "$actual" = "$expected" ]
}

contract_anchor_blob() {
  local repo_root="$1"
  local timeline="$2"
  local slice="$3"
  local anchor_path
  anchor_path="$(git -C "$repo_root" rev-parse --git-path "porter-solution-contracts/$timeline/$slice.contract.blob")"
  [ -f "$anchor_path" ] || return 0
  sed -n '1p' "$anchor_path" | tr -d '[:space:]'
}

worktree_path_matches_contract() {
  local repo_root="$1"
  local contract_path="$2"
  local rel_path="$3"
  local expected_blob expected_mode actual_blob actual_mode

  expected_blob="$(contract_json_object_value reviewed_path_blobs "$repo_root" "$contract_path" "$rel_path")"
  expected_mode="$(contract_json_object_value reviewed_path_modes "$repo_root" "$contract_path" "$rel_path")"
  [ -n "$expected_blob" ] || return 1
  [ -n "$expected_mode" ] || return 1

  if [ "$expected_blob" = "__deleted__" ] || [ "$expected_mode" = "__deleted__" ]; then
    [ ! -e "$repo_root/$rel_path" ]
    return
  fi

  [ -f "$repo_root/$rel_path" ] || return 1
  actual_blob="$(git -C "$repo_root" hash-object --path="$rel_path" -- "$repo_root/$rel_path" 2>/dev/null || true)"
  actual_mode="$(worktree_mode "$repo_root/$rel_path")"
  [ -n "$actual_blob" ] || return 1
  [ -n "$actual_mode" ] || return 1
  [ "$actual_blob" = "$expected_blob" ] && [ "$actual_mode" = "$expected_mode" ]
}

worktree_mode() {
  local path="$1"
  if [ -L "$path" ]; then
    printf '120000\n'
  elif [ -x "$path" ]; then
    printf '100755\n'
  else
    printf '100644\n'
  fi
}

guard_awaiting_commit_write() {
  local repo_root="$1"
  local abs_target="$2"
  local current_file state_file state abs_state timeline slice

  for current_file in "$repo_root"/.codex/timeline/*/current.json; do
    [ -f "$current_file" ] || continue
    state_file="$(state_file_for_current "$repo_root" "$current_file")"
    [ -n "$state_file" ] || continue
    [ -f "$state_file" ] || continue

    state="$(json_string state "$state_file")"
    case "$state" in
      awaiting_user_commit_confirm|committing) ;;
      *) continue ;;
    esac

    abs_state="$(real_path "$state_file")"
    [ "$abs_target" = "$abs_state" ] && continue

    timeline="$(json_string timeline "$current_file")"
    slice="$(json_string active_slice "$current_file")"
    [ -n "$timeline" ] || timeline="$(dirname "$current_file")"
    echo "[solution-lifecycle-guard] write blocked after review pass for $(basename "$timeline") / ${slice:-unknown}: $abs_target" >&2
    echo "[solution-lifecycle-guard] only the active state file may change before commit confirmation finishes; use solution-execute for new changes." >&2
    exit 1
  done
}

state_file_for_current() {
  local repo_root="$1"
  local current_file="$2"
  local state_path
  state_path="$(json_string state "$current_file")"
  [ -n "$state_path" ] || return 0
  repo_path "$repo_root" "$state_path"
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

contract_json_string_array() {
  local key="$1"
  local repo_root="$2"
  local contract_path="$3"
  python3 - "$key" "$repo_root/$contract_path" <<'PY'
import json
import sys

key, file_name = sys.argv[1], sys.argv[2]
try:
    with open(file_name, "r", encoding="utf-8") as f:
        value = json.load(f).get(key, [])
except Exception:
    value = []

if isinstance(value, list):
    for item in value:
        if isinstance(item, str) and item:
            print(item)
PY
}

contract_json_object_value() {
  local key="$1"
  local repo_root="$2"
  local contract_path="$3"
  local object_key="$4"
  python3 - "$key" "$repo_root/$contract_path" "$object_key" <<'PY'
import json
import sys

key, file_name, object_key = sys.argv[1], sys.argv[2], sys.argv[3]
try:
    with open(file_name, "r", encoding="utf-8") as f:
        value = json.load(f).get(key, {})
except Exception:
    value = {}

if isinstance(value, dict):
    item = value.get(object_key, "")
    if isinstance(item, str):
        print(item)
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

repo_relative_path() {
  local repo_root="$1"
  local path="$2"
  python3 - "$repo_root" "$path" <<'PY'
import os
import sys

repo_root, path = sys.argv[1], sys.argv[2]
try:
    print(os.path.relpath(path, repo_root))
except Exception:
    print(path)
PY
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
