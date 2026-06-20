#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'USAGE'
Usage:
  validate-solution-commit-message.sh --message-file FILE [--timeline NAME --slice SLICE] [--type TYPE]

Allowed commit types:
  feat fix refactor perf test docs build ci chore style
USAGE
}

allowed_types="feat fix refactor perf test docs build ci chore style"
message_file=""
timeline=""
slice=""
expected_type=""

has_allowed_type() {
  case " $allowed_types " in
    *" $1 "*) return 0 ;;
    *) return 1 ;;
  esac
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --message-file)
      message_file="${2:-}"
      shift 2
      ;;
    --timeline)
      timeline="${2:-}"
      shift 2
      ;;
    --slice)
      slice="${2:-}"
      shift 2
      ;;
    --type)
      expected_type="${2:-}"
      shift 2
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

if [ -z "$message_file" ]; then
  usage
  exit 2
fi

if [ ! -f "$message_file" ]; then
  echo "Commit message file not found: $message_file" >&2
  exit 2
fi

if { [ -n "$timeline" ] && [ -z "$slice" ]; } || { [ -z "$timeline" ] && [ -n "$slice" ]; }; then
  echo "--timeline and --slice must be provided together." >&2
  usage
  exit 2
fi

if [ -n "$expected_type" ] && ! has_allowed_type "$expected_type"; then
  echo "Unsupported expected type '$expected_type'. Allowed types: $allowed_types" >&2
  exit 2
fi

subject="$(sed -n '/[^[:space:]]/{p;q;}' "$message_file")"

if [ -z "$subject" ]; then
  echo "Commit message subject is empty." >&2
  exit 1
fi

if ! printf '%s
' "$subject" | grep -Eq '^[a-z]+(\([a-z0-9._-]+\))?: .+'; then
  echo "Invalid Conventional Commit subject: $subject" >&2
  exit 1
fi

actual_type="${subject%%(*}"
if [ "$actual_type" = "$subject" ]; then
  actual_type="${subject%%:*}"
fi

if ! has_allowed_type "$actual_type"; then
  echo "Unsupported commit type '$actual_type'. Allowed types: $allowed_types" >&2
  exit 1
fi

if [ -n "$expected_type" ] && [ "$actual_type" != "$expected_type" ]; then
  echo "Commit type '$actual_type' does not match expected type '$expected_type'." >&2
  exit 1
fi

if [ -z "$timeline" ]; then
  echo "Commit message subject OK: $actual_type"
  exit 0
fi

if ! grep -Fxq "Codex-Timeline: $timeline" "$message_file"; then
  echo "Missing trailer: Codex-Timeline: $timeline" >&2
  exit 1
fi

if ! grep -Fxq "Codex-Slice: $slice" "$message_file"; then
  echo "Missing trailer: Codex-Slice: $slice" >&2
  exit 1
fi

echo "Commit message contract OK: $timeline / $slice"
