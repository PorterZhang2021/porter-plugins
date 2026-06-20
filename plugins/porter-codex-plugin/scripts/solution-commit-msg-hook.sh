#!/usr/bin/env bash
set -euo pipefail

message_file="${1:-}"

if [ -z "$message_file" ]; then
  echo "Usage: solution-commit-msg-hook.sh COMMIT_MSG_FILE" >&2
  exit 2
fi

resolve_script_dir() {
  local path="$1"
  while [ -L "$path" ]; do
    local link
    link="$(readlink "$path")"
    case "$link" in
      /*) path="$link" ;;
      *) path="$(cd "$(dirname "$path")" && pwd)/$link" ;;
    esac
  done
  cd "$(dirname "$path")" && pwd
}

script_dir="$(resolve_script_dir "${BASH_SOURCE[0]}")"
validator="$script_dir/validate-solution-commit-message.sh"

if [ ! -x "$validator" ]; then
  echo "Solution commit message validator not found or not executable: $validator" >&2
  exit 2
fi

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"

if [ -z "$repo_root" ] || [ ! -d "$repo_root/.codex/timeline" ]; then
  exec "$validator" --message-file "$message_file"
fi

extract_json_string() {
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

staged_json_string() {
  local key="$1"
  local staged_path="$2"
  git -C "$repo_root" show ":$staged_path" 2>/dev/null | python3 -c '
import json
import sys

key = sys.argv[1]
try:
    value = json.load(sys.stdin).get(key, "")
except Exception:
    value = ""
print(value if isinstance(value, str) else "")
' "$key"
}

staged_json_string_array() {
  local key="$1"
  local staged_path="$2"
  git -C "$repo_root" show ":$staged_path" 2>/dev/null | python3 -c '
import json
import sys

key = sys.argv[1]
try:
    value = json.load(sys.stdin).get(key, [])
except Exception:
    value = []
if isinstance(value, list):
    for item in value:
        if isinstance(item, str) and item:
            print(item)
' "$key"
}

staged_json_object_value() {
  local key="$1"
  local object_key="$2"
  local staged_path="$3"
  git -C "$repo_root" show ":$staged_path" 2>/dev/null | python3 -c '
import json
import sys

key, object_key = sys.argv[1], sys.argv[2]
try:
    value = json.load(sys.stdin).get(key, {})
except Exception:
    value = {}
if isinstance(value, dict):
    item = value.get(object_key, "")
    if isinstance(item, str):
        print(item)
' "$key" "$object_key"
}

slice_type() {
  local slice="$1"
  local type
  for type in feat fix refactor perf test docs build ci chore style; do
    case "$slice" in
      [0-9][0-9][0-9]-"$type"-*)
        printf '%s\n' "$type"
        return 0
        ;;
      "$type"-*)
        printf '%s\n' "$type"
        return 0
        ;;
    esac
  done
  return 1
}

contains_trailer() {
  local key="$1"
  local value="$2"
  local file="$3"
  grep -Fxq "$key: $value" "$file"
}

staged_blob() {
  local staged_path="$1"
  git -C "$repo_root" ls-files -s -- "$staged_path" | awk '{print $2}' | head -n 1
}

staged_mode() {
  local staged_path="$1"
  git -C "$repo_root" ls-files -s -- "$staged_path" | awk '{print $1}' | head -n 1
}

contract_json_string() {
  local key="$1"
  local contract_path="$2"
  git -C "$repo_root" show ":$contract_path" 2>/dev/null | python3 -c '
import json
import sys

key = sys.argv[1]
try:
    value = json.load(sys.stdin).get(key, "")
except Exception:
    value = ""
print(value if isinstance(value, str) else "")
' "$key"
}

contract_json_string_array() {
  local key="$1"
  local contract_path="$2"
  git -C "$repo_root" show ":$contract_path" 2>/dev/null | python3 -c '
import json
import sys

key = sys.argv[1]
try:
    value = json.load(sys.stdin).get(key, [])
except Exception:
    value = []
if isinstance(value, list):
    for item in value:
        if isinstance(item, str) and item:
            print(item)
' "$key"
}

contract_json_object_value() {
  local key="$1"
  local object_key="$2"
  local contract_path="$3"
  git -C "$repo_root" show ":$contract_path" 2>/dev/null | python3 -c '
import json
import sys

key, object_key = sys.argv[1], sys.argv[2]
try:
    value = json.load(sys.stdin).get(key, {})
except Exception:
    value = {}
if isinstance(value, dict):
    item = value.get(object_key, "")
    if isinstance(item, str):
        print(item)
' "$key" "$object_key"
}

valid_review_contract_for_state() {
  local committed_state_path="$1"
  local expected_timeline="$2"
  local expected_slice="$3"
  local contract_path state_contract_path contract_blob actual_blob anchor_blob
  local contract_timeline contract_timeline_name contract_slice contract_state

  contract_path="$(contract_path_for_state "$committed_state_path")"
  state_contract_path="$(staged_json_string review_contract "$committed_state_path")"
  contract_blob="$(staged_json_string review_contract_blob "$committed_state_path")"

  if [ -z "$state_contract_path" ] || [ -z "$contract_path" ] || [ -z "$contract_blob" ]; then
    echo "Matching committed solution state does not record review_contract and review_contract_blob." >&2
    return 1
  fi

  if [ -n "$state_contract_path" ] && [ "$state_contract_path" != "$contract_path" ]; then
    echo "Committed solution state review_contract does not match deterministic contract path: $contract_path" >&2
    return 1
  fi

  case "$contract_path" in
    .codex/timeline/*/reviews/*.contract.json) ;;
    *)
      echo "Invalid review_contract path: $contract_path" >&2
      return 1
      ;;
  esac

  actual_blob="$(staged_blob "$contract_path")"
  if [ -z "$actual_blob" ] || [ "$actual_blob" != "$contract_blob" ]; then
    echo "Review contract blob does not match committed state contract pointer: $contract_path" >&2
    return 1
  fi

  anchor_blob="$(contract_anchor_blob "$expected_timeline" "$expected_slice")"
  if [ -z "$anchor_blob" ]; then
    echo "Review contract anchor is missing for $expected_timeline / $expected_slice." >&2
    echo "Re-run solution-review so the local .git contract anchor is recorded before committing." >&2
    return 1
  fi

  if [ "$actual_blob" != "$anchor_blob" ] || [ "$contract_blob" != "$anchor_blob" ]; then
    echo "Review contract blob does not match local review-pass anchor for $expected_timeline / $expected_slice." >&2
    return 1
  fi

  contract_timeline="$(contract_json_string timeline "$contract_path")"
  contract_timeline_name="$(basename "$contract_timeline")"
  contract_slice="$(contract_json_string active_slice "$contract_path")"
  contract_state="$(contract_json_string state "$contract_path")"

  if [ "$contract_timeline_name" != "$expected_timeline" ] || \
    [ "$contract_slice" != "$expected_slice" ] || \
    [ "$contract_state" != "$committed_state_path" ]; then
    echo "Review contract identity does not match committed solution state." >&2
    return 1
  fi
}

contract_anchor_blob() {
  local timeline="$1"
  local slice="$2"
  local anchor_path
  anchor_path="$(git -C "$repo_root" rev-parse --git-path "porter-solution-contracts/$timeline/$slice.contract.blob")"
  [ -f "$anchor_path" ] || return 0
  sed -n '1p' "$anchor_path" | tr -d '[:space:]'
}

contract_path_for_state() {
  local state_path="$1"
  local prefix file slice
  case "$state_path" in
    .codex/timeline/*/states/*.json) ;;
    *) return 1 ;;
  esac
  prefix="${state_path%/states/*}"
  file="${state_path##*/}"
  slice="${file%.json}"
  printf '%s/reviews/%s.contract.json\n' "$prefix" "$slice"
}

path_in_contract() {
  local staged_file="$1"
  local contract_path="$2"
  local reviewed_path

  while IFS= read -r reviewed_path; do
    [ -n "$reviewed_path" ] || continue
    [ "$staged_file" = "$reviewed_path" ] && return 0
  done <<< "$(contract_json_string_array reviewed_paths "$contract_path")"

  return 1
}

staged_path_matches_contract() {
  local staged_file="$1"
  local contract_path="$2"
  local expected_blob expected_mode actual_blob actual_mode

  expected_blob="$(contract_json_object_value reviewed_path_blobs "$staged_file" "$contract_path")"
  expected_mode="$(contract_json_object_value reviewed_path_modes "$staged_file" "$contract_path")"

  if [ -z "$expected_blob" ] || [ -z "$expected_mode" ]; then
    echo "Review contract does not record blob/mode for $staged_file." >&2
    return 1
  fi

  actual_blob="$(staged_blob "$staged_file")"
  actual_mode="$(staged_mode "$staged_file")"

  if [ "$expected_blob" = "__deleted__" ] || [ "$expected_mode" = "__deleted__" ]; then
    [ -z "$actual_blob" ] && [ -z "$actual_mode" ]
    return
  fi

  [ -n "$actual_blob" ] || return 1
  [ -n "$actual_mode" ] || return 1
  [ "$actual_blob" = "$expected_blob" ] && [ "$actual_mode" = "$expected_mode" ]
}

guard_staged_paths_reviewed() {
  local committed_state_path="$1"
  local contract_path staged_file blocked details

  contract_path="$(contract_path_for_state "$committed_state_path")"

  if [ -z "$(contract_json_string_array reviewed_paths "$contract_path")" ]; then
    echo "Matching review contract does not record reviewed_paths." >&2
    echo "Re-run solution-review so commit confirmation can stage only reviewed files." >&2
    return 1
  fi

  blocked=0
  details=""
  while IFS= read -r staged_file; do
    [ -n "$staged_file" ] || continue

    if [ "$staged_file" = "$committed_state_path" ]; then
      continue
    fi
    if [ "$staged_file" = "$contract_path" ]; then
      continue
    fi

    if ! path_in_contract "$staged_file" "$contract_path"; then
      blocked=1
      details="${details}
- $staged_file"
      continue
    fi

    if ! staged_path_matches_contract "$staged_file" "$contract_path"; then
      blocked=1
      details="${details}
- $staged_file changed after review"
    fi
  done < <(git -C "$repo_root" diff --cached --name-only 2>/dev/null || true)

  if [ "$blocked" -eq 1 ]; then
    echo "Commit includes files that were not recorded in the review contract, or changed after review:" >&2
    printf '%s\n' "$details" >&2
    echo "Run solution-execute and solution-review again for new changes, or stage only reviewed paths plus the review contract and active state file." >&2
    return 1
  fi
}

active_count=0
active_timeline=""
active_slice=""
active_type=""
blocked_count=0
blocked_details=""
committed_match_count=0
committed_timeline=""
committed_slice=""
committed_type=""
committed_state_path=""
committed_state_staged=0
staged_committed_state=0
has_committed_match=0

while IFS= read -r staged_file; do
  [ -n "$staged_file" ] || continue
  case "$staged_file" in
    .codex/timeline/*/states/*.json)
      if git -C "$repo_root" show ":$staged_file" 2>/dev/null | grep -Eq '"state"[[:space:]]*:[[:space:]]*"committed"'; then
        staged_committed_state=1
      fi
      ;;
  esac
done < <(git -C "$repo_root" diff --cached --name-only -- '.codex/timeline/*/states/*.json' 2>/dev/null || true)

for current_file in "$repo_root"/.codex/timeline/*/current.json; do
  [ -f "$current_file" ] || continue

  state_path="$(extract_json_string state "$current_file")"
  if [ -z "$state_path" ]; then
    blocked_count=$((blocked_count + 1))
    blocked_details="${blocked_details}
- $(dirname "$current_file"): missing state pointer"
    continue
  fi

  case "$state_path" in
    /*) state_file="$state_path" ;;
    *) state_file="$repo_root/$state_path" ;;
  esac
  case "$state_path" in
    /*) staged_state_path="${state_path#"$repo_root"/}" ;;
    *) staged_state_path="$state_path" ;;
  esac

  if [ ! -f "$state_file" ]; then
    blocked_count=$((blocked_count + 1))
    blocked_details="${blocked_details}
- $(dirname "$current_file"): missing state file $state_path"
    continue
  fi

  state="$(extract_json_string state "$state_file")"
  timeline_path="$(extract_json_string timeline "$current_file")"
  slice="$(extract_json_string active_slice "$current_file")"

  [ -n "$timeline_path" ] || timeline_path="$(dirname "$current_file")"
  if [ -z "$slice" ]; then
    blocked_count=$((blocked_count + 1))
    blocked_details="${blocked_details}
- $(dirname "$current_file"): missing active_slice"
    continue
  fi

  timeline_name="$(basename "$timeline_path")"
  type="$(slice_type "$slice" || true)"
  if [ -z "$type" ]; then
    echo "Cannot infer allowed commit type from active slice: $slice" >&2
    exit 1
  fi

  case "$state" in
    committed)
      if contains_trailer "Codex-Timeline" "$timeline_name" "$message_file" && \
        contains_trailer "Codex-Slice" "$slice" "$message_file"; then
        committed_match_count=$((committed_match_count + 1))
        committed_timeline="$timeline_name"
        committed_slice="$slice"
        committed_type="$type"
        committed_state_path="$staged_state_path"
        if [ "$(staged_json_string state "$staged_state_path")" = "committed" ]; then
          committed_state_staged=1
        fi
        has_committed_match=1
      fi
      ;;
    cancelled)
      ;;
    awaiting_user_commit_confirm|committing)
      active_count=$((active_count + 1))
      active_timeline="$timeline_name"
      active_slice="$slice"
      active_type="$type"
      ;;
    *)
      if [ "$has_committed_match" -ne 1 ]; then
        blocked_count=$((blocked_count + 1))
        blocked_details="${blocked_details}
- $timeline_name / $slice is '$state'"
      fi
      ;;
  esac
done

if [ "$committed_match_count" -eq 0 ] && [ "$blocked_count" -gt 0 ]; then
  echo "Active solution lifecycle is not ready to commit." >&2
  echo "Run the next recorded solution skill before committing:" >&2
  printf '%s\n' "$blocked_details" >&2
  exit 1
fi

if [ "$committed_match_count" -eq 0 ] && [ "$active_count" -gt 1 ]; then
  echo "Multiple active solution commit states found; cannot choose commit message contract." >&2
  echo "Resolve stale .codex/timeline/*/current.json state before committing." >&2
  exit 1
fi

if [ "$committed_match_count" -eq 0 ] && [ "$active_count" -eq 1 ]; then
  echo "Active solution slice is '$active_timeline / $active_slice' and is not finalized for commit." >&2
  echo "Use the solution-review commit confirmation path so the state is written as 'committed' before git commit." >&2
  echo "Current pre-commit state still requires user confirmation or final state update." >&2
  exit 1
fi

if [ "$committed_match_count" -gt 1 ]; then
  echo "Commit message matches multiple committed solution slices; cannot choose contract." >&2
  exit 1
fi

if [ "$committed_match_count" -eq 1 ]; then
  if [ "$committed_state_staged" -ne 1 ]; then
    echo "Matching committed solution slice found, but its state file is not staged as 'committed'." >&2
    echo "Stage the active state file so the terminal lifecycle state enters this commit." >&2
    exit 1
  fi
  valid_review_contract_for_state "$committed_state_path" "$committed_timeline" "$committed_slice"
  guard_staged_paths_reviewed "$committed_state_path"
  exec "$validator" \
    --message-file "$message_file" \
    --timeline "$committed_timeline" \
    --slice "$committed_slice" \
    --type "$committed_type"
fi

if [ "$staged_committed_state" -eq 1 ]; then
  echo "A solution state is staged as 'committed', but the commit message does not match its Codex-Timeline/Codex-Slice contract." >&2
  exit 1
fi

if grep -Eq '^Codex-(Timeline|Slice): ' "$message_file"; then
  echo "Codex solution trailers are present, but no matching committed solution slice was found." >&2
  exit 1
fi

exec "$validator" --message-file "$message_file"
