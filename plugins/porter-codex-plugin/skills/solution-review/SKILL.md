---
name: solution-review
description: Review the current Codex timeline after solution-execute, write REVIEW.md, and update WORKFLOW_STATE.json for pass or solution remediation in the new solution workflow
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
---

# Solution Review

Review the current timeline after `$porter-codex-plugin:solution-execute` in the new solution workflow:

```text
solution -> solution-task -> solution-execute -> solution-review
```

This skill is based on the existing `$porter-codex-plugin:review` and `$porter-codex-plugin:review-branch` prototypes, but it writes a durable timeline review file and updates explicit workflow state.

## Phase Boundary

- Review only the current solution workflow result.
- Write or update `.codex/timeline/<branch-type>/<branch-name>/REVIEW.md`.
- Write or update `.codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json`.
- Do not modify implementation, documentation, or configuration files outside the review outputs.
- Do not update `TASK.md`.
- Do not update `SOLUTION.md`.
- Do not execute fixes.
- Do not commit.
- Do not merge, push, or create PR.
- Stop after review and prompt the user to call the next explicit skill.

## Invocation

```text
$porter-codex-plugin:solution-review
```

No command arguments are required.

## Prerequisites

1. Confirm `AGENTS.md` exists.
2. Confirm `.codex/constitution.md` exists.
3. Confirm the current branch is not `main` or `master`.
4. Read the current branch name and confirm it matches `<branch-type>/<branch-name>`.
5. Confirm the current timeline exists:

```text
.codex/timeline/<branch-type>/<branch-name>/
```

Required files:

- `.codex/timeline/<branch-type>/<branch-name>/SOLUTION.md`
- `.codex/timeline/<branch-type>/<branch-name>/TASK.md`
- `.codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json`

Optional file:

- `.codex/timeline/<branch-type>/<branch-name>/REVIEW.md`

## Prototype Mapping

| Existing review prototype | `solution-review` |
| --- | --- |
| `plugins/porter-codex-plugin/skills/review/SKILL.md` | Primary submit-before-commit review pattern |
| `plugins/porter-codex-plugin/skills/review-branch/SKILL.md` | Branch workflow review pattern |
| `plan/<type>/<branch-name>/PLAN.md` | `.codex/timeline/<branch-type>/<branch-name>/SOLUTION.md` |
| `plan/<type>/<branch-name>/TASK.md` | `.codex/timeline/<branch-type>/<branch-name>/TASK.md` |
| Conversation-only review output | `.codex/timeline/<branch-type>/<branch-name>/REVIEW.md` |
| Optional review before commit | Required solution workflow stage before commit |
| `commit` / `commit-branch` prompt | Explicit workflow state transition |

Do not read old workflow inputs:

- Do not read `plan/<type>/<branch-name>/PLAN.md`.
- Do not read `plan/<type>/<branch-name>/ANALYSIS.md`.
- Do not read old `plan/` workflow state.

## State Gate

Read `.codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json` before review.

Allowed state:

- `awaiting_solution_review`

If the state is missing or is not `awaiting_solution_review`, stop and prompt the user to explicitly call the `next_skill` recorded in `WORKFLOW_STATE.json`.

Do not continue without `WORKFLOW_STATE.json`; this workflow requires explicit state.

## Review Inputs

Collect this context before writing `REVIEW.md`:

```bash
git status --short
git diff
git ls-files --others --exclude-standard
```

Read:

- `.codex/timeline/<branch-type>/<branch-name>/SOLUTION.md`
- `.codex/timeline/<branch-type>/<branch-name>/TASK.md`
- `.codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json`
- Existing `.codex/timeline/<branch-type>/<branch-name>/REVIEW.md`, if present and needed to verify remediation
- In-scope untracked files reported by `git ls-files --others --exclude-standard`

Build a review brief that includes:

- Current goal and acceptance criteria from `SOLUTION.md`.
- Completed and incomplete tasks from `TASK.md`.
- Current change summary from `git status --short`.
- Key diff excerpts or file paths from `git diff`.
- In-scope untracked file contents that are not represented in `git diff`.
- Risk points that need focused review.

## Review Mechanism

Use two-layer review. The current Codex owns workflow judgment and final result; a subagent only performs general engineering review when available.

Current Codex must review:

- Business semantics and whether the result satisfies `SOLUTION.md`.
- `SOLUTION.md` / `TASK.md` consistency.
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

If subagent review is unavailable, complete the review in the current Codex context and record the reason in `REVIEW.md` Notes. This is a valid fallback, not a review failure.

For remediation review:

1. Read the previous `REVIEW.md` only after confirming its Timeline Context matches the active branch, work slice, solution path, and task path.
2. If an existing `REVIEW.md` belongs to an older slice or different context, treat it as stale and overwrite it as a first normal review.
3. Verify whether matching prior findings were resolved.
4. Use a subagent again when the remediation diff is large, involves executable behavior, the user explicitly asks for it, or the general engineering risk is high.
5. If skipping subagent review, record the reason in `REVIEW.md` Notes.

## Review Checklist

Check all of these before choosing a result:

- `SOLUTION.md` goal, scope, and acceptance still hold.
- `TASK.md` tasks are all complete, or any incomplete item has a clear recorded reason.
- Each completed task has validation evidence or a recorded limitation.
- Current diff and in-scope untracked files only contain files allowed by this slice.
- New or modified files stay under the Codex plugin path boundary when implementation/config files are changed.
- No old `plan-*`, `execute-*`, `review-*`, or Claude-side configuration was changed unless explicitly required by `SOLUTION.md`.
- Markdown frontmatter is valid for modified skills.
- JSON examples or state files are parseable.
- Markdown code fences are balanced.
- Workflow state can transition to the correct next stage.
- Review output does not introduce states outside this solution loop.

## REVIEW.md Structure

Write `.codex/timeline/<branch-type>/<branch-name>/REVIEW.md` using this structure:

```markdown
# Review: <title>

## Timeline Context

- Solution: `.codex/timeline/<branch-type>/<branch-name>/SOLUTION.md`
- Task: `.codex/timeline/<branch-type>/<branch-name>/TASK.md`
- Branch: `<branch-type>/<branch-name>`
- Type: `<selected-type>`
- Work slice: `<slice>`

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
- TASK is complete or any remaining item is explicitly non-blocking.
- Validation evidence is present or limitations are recorded.
- No `P0` or `P1` finding blocks commit.

Use `needs-fix` when implementation, documentation, configuration, or validation output is wrong and requires remediation.

Use `needs-task-update` when the task list is incomplete, stale, missing validation, or no longer represents the required work.

Use `needs-solution-update` when the solution assumptions, scope, acceptance, root cause, or bottleneck analysis needs to change or needs user reconfirmation.

## State Outputs

For `pass`, write:

```json
{
  "state": "awaiting_commit",
  "current_skill": "$porter-codex-plugin:solution-review",
  "next_skill": "$porter-codex-plugin:commit",
  "timeline": ".codex/timeline/<branch-type>/<branch-name>",
  "allowed_outputs": [
    ".codex/timeline/<branch-type>/<branch-name>/REVIEW.md",
    ".codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json"
  ]
}
```

For `needs-fix`, `needs-task-update`, or `needs-solution-update`, write:

```json
{
  "state": "awaiting_solution_execute_from_review",
  "current_skill": "$porter-codex-plugin:solution-review",
  "next_skill": "$porter-codex-plugin:solution-execute",
  "timeline": ".codex/timeline/<branch-type>/<branch-name>",
  "allowed_outputs": [
    ".codex/timeline/<branch-type>/<branch-name>/REVIEW.md",
    ".codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json"
  ]
}
```

Do not write `TASK.md` or `SOLUTION.md` during review. Remediation belongs to `$porter-codex-plugin:solution-execute`.

## Completion Prompt

If the result is `pass`, stop and say:

**"Review 已完成，结果为 pass。还有要补充审查的吗？如果没有，请显式调用 `$porter-codex-plugin:commit` 提交。"**

If the result is `needs-fix`, `needs-task-update`, or `needs-solution-update`, stop and say:

**"Review 已完成，发现需要回修的内容。请确认后显式调用 `$porter-codex-plugin:solution-execute` 进入回修。"**
