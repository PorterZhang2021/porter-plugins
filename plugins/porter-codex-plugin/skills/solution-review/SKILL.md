---
name: solution-review
description: Review the active solution timeline slice after solution-execute, write the slice review file, and update explicit slice state for pass or remediation
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
---

# Solution Review

Review the active slice after `$porter-codex-plugin:solution-execute`:

```text
solution -> solution-task -> solution-execute -> solution-review
```

This skill writes a durable review file for the active slice and updates the active slice state.

## Phase Boundary

- Review only the current active solution workflow result.
- Write or update active slice review file.
- Write or update active slice state file.
- Do not modify implementation, documentation, or configuration files outside review outputs.
- Do not update task file.
- Do not update solution file.
- Do not execute fixes.
- Do not commit.
- Do not merge, push, or create PR.
- Stop after review and prompt the user to call the next explicit skill.

New slice review outputs:

```text
.codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md
.codex/timeline/<timeline-name>/states/<slice-id>-<type>-<slug>.json
```

## Invocation

```text
$porter-codex-plugin:solution-review
```

No command arguments are required.

## Path Resolution

`solution-review` does not create a new slice id.

timeline name resolution:

1. If the user explicitly confirmed a timeline name in the current conversation, use it.
2. Otherwise use the current `<branch-name>` as the default timeline name.
3. If the default `.codex/timeline/<timeline-name>/current.json` does not exist, scan `.codex/timeline/*/current.json`.
4. Use the scanned timeline only when exactly one `current.json` points to a state that allows `$porter-codex-plugin:solution-review`.
5. If there is no match or more than one match, stop and ask the user to name the timeline explicitly.

Before review:

1. If `.codex/timeline/<timeline-name>/current.json` exists, use it first.
2. Read `current.json` and resolve active slice files:
   - `solution`
   - `task`
   - `review`
   - `state`
3. Read active slice state from `states/<slice>.json`.
4. If `current.json` does not exist but old `.codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json` exists, enter old-path in-flight completion mode:
   - solution file maps to `.codex/timeline/<branch-type>/<branch-name>/SOLUTION.md`
   - task file maps to `.codex/timeline/<branch-type>/<branch-name>/TASK.md`
   - review file maps to `.codex/timeline/<branch-type>/<branch-name>/REVIEW.md`
   - state file maps to `.codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json`
   - continue only when the old state allows `$porter-codex-plugin:solution-review`
5. New slice creation must use the new path and belongs only to `$porter-codex-plugin:solution`.

## Prerequisites

1. Confirm `AGENTS.md` exists.
2. Confirm `.codex/constitution.md` exists.
3. Confirm the current branch is not `main` or `master`.
4. Read the current branch name and confirm it matches `<branch-type>/<branch-name>`.
5. Resolve active slice through `current.json`, or enter old-path in-flight completion when no `current.json` exists and old `WORKFLOW_STATE.json` exists.

Required active slice files:

- solution file
- task file
- state file

Optional active slice file:

- review file, if present and needed to verify remediation

## current.json

`current.json` is the active slice pointer, not workflow state.

```json
{
  "timeline": ".codex/timeline/<timeline-name>",
  "active_slice": "<slice-id>-<type>-<slug>",
  "solution": ".codex/timeline/<timeline-name>/solutions/<slice-id>-<type>-<slug>.md",
  "task": ".codex/timeline/<timeline-name>/tasks/<slice-id>-<type>-<slug>.md",
  "review": ".codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md",
  "state": ".codex/timeline/<timeline-name>/states/<slice-id>-<type>-<slug>.json"
}
```

## State Gate

Read active slice state before review.

Allowed state:

- `awaiting_solution_review`

If the state is missing or is not `awaiting_solution_review`, stop and prompt the user to explicitly call the `next_skill` recorded in the state file.

Do not continue without explicit state.

## Review Inputs

Collect this context before writing the review file:

```bash
git status --short
git diff
git ls-files --others --exclude-standard
```

Read:

- active slice solution file
- active slice task file
- active slice state file
- active slice review file, if present and needed to verify remediation
- in-scope untracked files reported by `git ls-files --others --exclude-standard`

Build a review brief that includes:

- Current goal and acceptance criteria from the solution file.
- Completed and incomplete tasks from the task file.
- Current change summary from `git status --short`.
- Key diff excerpts or file paths from `git diff`.
- In-scope untracked file contents that are not represented in `git diff`.
- Risk points that need focused review.

Do not read old workflow inputs:

- Do not read `plan/<type>/<branch-name>/PLAN.md`.
- Do not read `plan/<type>/<branch-name>/ANALYSIS.md`.
- Do not read old `plan/` workflow state.

## Review Mechanism

Use two-layer review. The current Codex owns workflow judgment and final result; a subagent only performs general engineering review when available.

Current Codex must review:

- Business semantics and whether the result satisfies the solution file.
- Solution / task consistency.
- Solution workflow phase boundaries.
- AGENTS.md and constitution rules.
- Codex plugin path boundaries.
- Final result and next workflow state.

For the first normal review, use two-layer review by default when the environment supports a `code-reviewer` subagent or equivalent fresh-context review capability. Give the subagent the review brief and relevant diff. Ask only for general engineering findings with file facts.

The subagent may check:

- JSON, Markdown, and frontmatter validity.
- State inconsistencies.
- Missing validation evidence.
- Naming or path inconsistencies.
- Old workflow path remnants.
- Dangerous commands, permission boundary issues, or secret risks.
- Obvious correctness, regression, reliability, maintainability, or documentation issues.

The subagent must not decide:

- Business intent.
- Configuration retention or deletion choices.
- Solution workflow phase boundaries.
- Whether scope should be expanded.
- Any decision that depends on current long-context user history.

Current Codex must merge the results. Keep only findings supported by files, diff, or command output. Downgrade questions that need user judgment to `Open Questions`.

If subagent review is unavailable, complete the review in the current Codex context and record the reason in the review file Notes. This is a valid fallback, not a review failure.

For remediation review:

1. Read the previous active slice review file only after confirming its Timeline Context matches the active slice id, solution path, task path, review path, and state path.
2. If an existing review file belongs to an older slice or different context, treat it as stale and overwrite it as a first normal review.
3. Verify whether matching prior findings were resolved.
4. Use a subagent again when the remediation diff is large, involves executable behavior, the user explicitly asks for it, or the general engineering risk is high.
5. If skipping subagent review, record the reason in the review file Notes.

## Review Checklist

Check all of these before choosing a result:

- Solution goal, scope, and acceptance still hold.
- Task items are all complete, or any incomplete item has a clear recorded reason.
- Each completed task has validation evidence or a recorded limitation.
- Current diff and in-scope untracked files only contain files allowed by this slice.
- New or modified files stay under the Codex plugin path boundary when implementation/config files are changed.
- No old `plan-*`, `execute-*`, `review-*`, or Claude-side configuration was changed unless explicitly required by the solution.
- Markdown frontmatter is valid for modified skills.
- JSON examples or state files are parseable.
- Markdown code fences are balanced.
- Workflow state can transition to the correct next stage.
- Review output does not introduce states outside this solution loop.

## REVIEW.md Structure

Write the active slice review file using this structure:

```markdown
# Review: <title>

## Timeline Context

- Solution: `.codex/timeline/<timeline-name>/solutions/<slice-id>-<type>-<slug>.md`
- Task: `.codex/timeline/<timeline-name>/tasks/<slice-id>-<type>-<slug>.md`
- Review: `.codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md`
- State: `.codex/timeline/<timeline-name>/states/<slice-id>-<type>-<slug>.json`
- Timeline: `.codex/timeline/<timeline-name>`
- Active slice: `<slice-id>-<type>-<slug>`
- Type: `<selected-type>`

## Result

<pass | needs-fix | needs-task-update | needs-solution-update>

## Checks

- <structure, state, command, or review check>

## Findings

- <P0/P1/P2/P3 ordered findings; write "无" only when there are no findings>

## Open Questions

- <questions requiring user confirmation; write "无" when none>

## Notes

- <non-blocking observations, subagent availability, or skip reasons>

## Next Step

<next explicit skill>
```

`Result` must be exactly one of:

- `pass`
- `needs-fix`
- `needs-task-update`
- `needs-solution-update`

Findings must be ordered by severity: `P0`, `P1`, `P2`, then `P3`. Record non-blocking `P2` and `P3` findings even when there are no blocking issues.

If no findings are found, write:

```text
无
```

If review finds scope, assumption, acceptance, root-cause, or bottleneck issues that need reconfirmation, use `needs-solution-update`. Do not introduce another state.

## Result Rules

Use `pass` when:

- Acceptance is satisfied.
- Tasks are complete or any remaining item is explicitly non-blocking.
- Validation evidence is present or limitations are recorded.
- No `P0` or `P1` finding blocks commit.

Use `needs-fix` when implementation, documentation, configuration, or validation output is wrong and requires remediation.

Use `needs-task-update` when the task list is incomplete, stale, missing validation, or no longer represents the required work.

Use `needs-solution-update` when the solution assumptions, scope, acceptance, root cause, or bottleneck analysis needs to change or needs user reconfirmation.

## State Outputs

For `pass`, write active slice state:

```json
{
  "state": "awaiting_commit",
  "current_skill": "$porter-codex-plugin:solution-review",
  "next_skill": "$porter-codex-plugin:commit",
  "timeline": ".codex/timeline/<timeline-name>",
  "active_slice": "<slice-id>-<type>-<slug>",
  "solution": ".codex/timeline/<timeline-name>/solutions/<slice-id>-<type>-<slug>.md",
  "task": ".codex/timeline/<timeline-name>/tasks/<slice-id>-<type>-<slug>.md",
  "review": ".codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md",
  "allowed_outputs": [
    ".codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md",
    ".codex/timeline/<timeline-name>/states/<slice-id>-<type>-<slug>.json"
  ]
}
```

For `needs-fix`, `needs-task-update`, or `needs-solution-update`, write active slice state:

```json
{
  "state": "awaiting_solution_execute_from_review",
  "current_skill": "$porter-codex-plugin:solution-review",
  "next_skill": "$porter-codex-plugin:solution-execute",
  "timeline": ".codex/timeline/<timeline-name>",
  "active_slice": "<slice-id>-<type>-<slug>",
  "solution": ".codex/timeline/<timeline-name>/solutions/<slice-id>-<type>-<slug>.md",
  "task": ".codex/timeline/<timeline-name>/tasks/<slice-id>-<type>-<slug>.md",
  "review": ".codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md",
  "allowed_outputs": [
    ".codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md",
    ".codex/timeline/<timeline-name>/states/<slice-id>-<type>-<slug>.json"
  ]
}
```

Do not write task file or solution file during review. Remediation belongs to `$porter-codex-plugin:solution-execute`.

## 旧路径在途收尾

规则：

- 如果 `current.json` 存在，优先使用新路径。
- 如果 `current.json` 不存在但旧 `WORKFLOW_STATE.json` 存在，只有旧 state 允许进入 `$porter-codex-plugin:solution-review` 时才继续旧路径收尾。
- 新 slice 创建必须使用新路径。
- 不自动迁移旧文件。
- 不删除旧文件。

## Completion Prompt

If the result is `pass`, stop and say:

**"Review 已完成，结果为 pass。还有要补充审查的吗？如果没有，请显式调用 `$porter-codex-plugin:commit` 提交。"**

If the result is `needs-fix`, `needs-task-update`, or `needs-solution-update`, stop and say:

**"Review 已完成，发现需要回修的内容。请确认后显式调用 `$porter-codex-plugin:solution-execute` 进入回修。"**
