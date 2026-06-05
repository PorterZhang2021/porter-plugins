#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
GUARD="$SCRIPT_DIR/workflow-guard.sh"

pass() { printf 'ok - %s\n' "$1"; }
fail() { printf 'not ok - %s\n' "$1" >&2; exit 1; }

setup_repo() {
  local tmp=$1
  mkdir -p "$tmp/repo"
  git -C "$tmp/repo" init >/dev/null
  git -C "$tmp/repo" config user.email test@example.com
  git -C "$tmp/repo" config user.name Test
  echo init > "$tmp/repo/README.md"
  git -C "$tmp/repo" add README.md
  git -C "$tmp/repo" commit -m init >/dev/null
  git -C "$tmp/repo" branch -M master
  mkdir -p "$tmp/repo/.codex/worktrees/fix"
  git -C "$tmp/repo" worktree add -b fix/demo "$tmp/repo/.codex/worktrees/fix/demo" master >/dev/null
}

write_state() {
  local worktree=$1
  local state=$2
  mkdir -p "$worktree/plan/fix/demo"
  cat > "$worktree/plan/fix/demo/WORKFLOW_STATE.json" <<EOF
{"state":"$state","next_skill":"porter-codex-plugin:task"}
EOF
}

run_guard() {
  local cwd=$1
  local payload=$2
  (cd "$cwd" && printf '%s' "$payload" | bash "$GUARD")
}

test_awaiting_task_blocks_implementation_edit() {
  local tmp worktree payload output status
  tmp=$(mktemp -d)
  setup_repo "$tmp"
  worktree="$tmp/repo/.codex/worktrees/fix/demo"
  write_state "$worktree" awaiting_task

  payload='{"tool_name":"apply_patch","tool_input":{"file_path":"plugins/porter-codex-plugin/skills/analyze-bug/SKILL.md"}}'
  set +e
  output=$(run_guard "$worktree" "$payload" 2>&1)
  status=$?
  set -e

  [ "$status" -ne 0 ] || fail "awaiting_task should block implementation edit"
  [[ "$output" == *'$porter-codex-plugin:task'* ]] || fail "awaiting_task block should mention task skill"
  pass "awaiting_task blocks implementation edit"
}

test_awaiting_task_allows_analysis_update() {
  local tmp worktree payload
  tmp=$(mktemp -d)
  setup_repo "$tmp"
  worktree="$tmp/repo/.codex/worktrees/fix/demo"
  write_state "$worktree" awaiting_task

  payload='{"tool_name":"apply_patch","tool_input":{"file_path":"plan/fix/demo/ANALYSIS.md"}}'
  run_guard "$worktree" "$payload" >/dev/null
  pass "awaiting_task allows ANALYSIS.md update"
}

test_worktree_blocks_main_repo_write() {
  local tmp worktree payload output status
  tmp=$(mktemp -d)
  setup_repo "$tmp"
  worktree="$tmp/repo/.codex/worktrees/fix/demo"
  write_state "$worktree" executing

  payload="{\"tool_name\":\"apply_patch\",\"tool_input\":{\"file_path\":\"$tmp/repo/plugins/porter-codex-plugin/skills/task/SKILL.md\"}}"
  set +e
  output=$(run_guard "$worktree" "$payload" 2>&1)
  status=$?
  set -e

  [ "$status" -ne 0 ] || fail "worktree should block main repo write"
  [[ "$output" == *"写入路径必须以当前 worktree 为基准"* ]] || fail "worktree block should mention path rule"
  pass "worktree blocks main repo write"
}

test_awaiting_execute_blocks_implementation_edit() {
  local tmp worktree payload output status
  tmp=$(mktemp -d)
  setup_repo "$tmp"
  worktree="$tmp/repo/.codex/worktrees/fix/demo"
  write_state "$worktree" awaiting_execute

  payload='{"tool_name":"apply_patch","tool_input":{"file_path":"plugins/porter-codex-plugin/skills/execute/SKILL.md"}}'
  set +e
  output=$(run_guard "$worktree" "$payload" 2>&1)
  status=$?
  set -e

  [ "$status" -ne 0 ] || fail "awaiting_execute should block implementation edit"
  [[ "$output" == *'$porter-codex-plugin:execute'* ]] || fail "awaiting_execute block should mention execute skill"
  pass "awaiting_execute blocks implementation edit"
}

test_execution_state_allows_implementation_edit() {
  local tmp worktree payload
  tmp=$(mktemp -d)
  setup_repo "$tmp"
  worktree="$tmp/repo/.codex/worktrees/fix/demo"
  write_state "$worktree" executing

  payload='{"tool_name":"apply_patch","tool_input":{"file_path":"plugins/porter-codex-plugin/skills/execute/SKILL.md"}}'
  run_guard "$worktree" "$payload" >/dev/null
  pass "executing allows implementation edit"
}

test_awaiting_task_blocks_implementation_edit
test_awaiting_task_allows_analysis_update
test_worktree_blocks_main_repo_write
test_awaiting_execute_blocks_implementation_edit
test_execution_state_allows_implementation_edit
