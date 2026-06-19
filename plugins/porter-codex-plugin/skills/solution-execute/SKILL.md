---
name: solution-execute
description: Execute tasks from the current Codex timeline TASK.md, update workflow state, and support review-remediation execution in the new solution workflow
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
---

# Solution Execute

Execute `TASK.md` for the new solution workflow:

```text
solution -> solution-task -> solution-execute -> solution-review
```

This skill is based on the existing `$porter-codex-plugin:execute` and `$porter-codex-plugin:execute-branch` prototypes, but it only reads and writes the new `.codex/timeline/<branch-type>/<branch-name>/` workflow files.

## Phase Boundary

- Execute the current allowed solution task work.
- Update `.codex/timeline/<branch-type>/<branch-name>/TASK.md`.
- Update `.codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json`.
- In review-remediation mode only, update `.codex/timeline/<branch-type>/<branch-name>/SOLUTION.md` when `REVIEW.md` shows changed assumptions, acceptance, root cause, or bottleneck analysis.
- Do not execute review.
- Do not commit.
- Do not merge, push, or create PR.
- Stop after execution and ask the user whether to supplement, adjust, or continue unfinished tasks.
- If there is no further adjustment, prompt the user to explicitly call `$porter-codex-plugin:solution-review`.

## Invocation

```text
$porter-codex-plugin:solution-execute
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

Review-remediation mode also requires:

- `.codex/timeline/<branch-type>/<branch-name>/REVIEW.md`

## Prototype Mapping

| Existing execute prototype | `solution-execute` |
| --- | --- |
| `plan/<type>/<branch-name>/TASK.md` | `.codex/timeline/<branch-type>/<branch-name>/TASK.md` |
| `plan/<type>/<branch-name>/PLAN.md` fallback | No fallback; missing `TASK.md` stops and prompts `$porter-codex-plugin:solution-task` |
| `plan/<type>/<branch-name>/WORKFLOW_STATE.json` | `.codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json` |
| `awaiting_execute` | `awaiting_solution_execute` |
| `executing` | `executing_solution` |
| `awaiting_review_or_commit` | `awaiting_solution_review` |
| `review` / `review-branch` | `solution-review` |
| `commit` / `commit-branch` alternate | No alternate; review comes before commit |
| `execute/reference/<type>.md` | `solution-execute/reference/<type>.md` |

Do not read old workflow inputs:

- Do not read `plan/<type>/<branch-name>/PLAN.md`.
- Do not read `plan/<type>/<branch-name>/ANALYSIS.md`.
- Do not read old `plan/` workflow state.

## State Gate

Read `.codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json` before execution.

Allowed states:

- `awaiting_solution_execute`
- `executing_solution`
- `awaiting_solution_execute_from_review`
- `executing_solution_remediation`

If the state is missing or not in this list, stop and prompt the user to explicitly call the `next_skill` recorded in `WORKFLOW_STATE.json`.

Do not continue without `WORKFLOW_STATE.json`; unlike the old `execute` skill, this workflow requires explicit state.

## First Execution Mode

Use this mode for:

- `awaiting_solution_execute`
- `executing_solution`

Before modifying implementation, documentation, or configuration files, write:

```json
{
  "state": "executing_solution",
  "current_skill": "$porter-codex-plugin:solution-execute",
  "next_skill": "$porter-codex-plugin:solution-execute",
  "timeline": ".codex/timeline/<branch-type>/<branch-name>",
  "allowed_outputs": [
    ".codex/timeline/<branch-type>/<branch-name>/TASK.md",
    ".codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json",
    "<files required by unchecked TASK.md items>"
  ]
}
```

Then:

1. Read `SOLUTION.md`.
2. Read `TASK.md`.
3. Read selected type from `SOLUTION.md` `Type Decision`.
4. Load `solution-execute/reference/<type>.md`.
5. Continue the first `[~]` task if one exists; otherwise execute the first `[ ]` task.
6. Mark a task `[x]` only after its `验证方式` passes or the verification limitation is recorded.
7. Update `TASK.md` after each completed task or substep.

When all tasks are complete, write:

```json
{
  "state": "awaiting_solution_review",
  "current_skill": "$porter-codex-plugin:solution-execute",
  "next_skill": "$porter-codex-plugin:solution-review",
  "timeline": ".codex/timeline/<branch-type>/<branch-name>",
  "allowed_outputs": [
    ".codex/timeline/<branch-type>/<branch-name>/REVIEW.md",
    ".codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json"
  ]
}
```

## Review-Remediation Mode

Use this mode for:

- `awaiting_solution_execute_from_review`
- `executing_solution_remediation`

Before modifying implementation, documentation, configuration, `TASK.md`, or `SOLUTION.md`, write:

```json
{
  "state": "executing_solution_remediation",
  "current_skill": "$porter-codex-plugin:solution-execute",
  "next_skill": "$porter-codex-plugin:solution-execute",
  "timeline": ".codex/timeline/<branch-type>/<branch-name>",
  "allowed_outputs": [
    ".codex/timeline/<branch-type>/<branch-name>/TASK.md",
    ".codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json",
    ".codex/timeline/<branch-type>/<branch-name>/SOLUTION.md",
    "<files required by REVIEW.md remediation>"
  ]
}
```

Then:

1. Read `REVIEW.md`.
2. Read `TASK.md`.
3. Read `SOLUTION.md` when the review conclusion affects solution assumptions, acceptance, root cause, or bottleneck analysis.
4. If review reports implementation defects, update implementation/config/docs files and `TASK.md`.
5. If review reports missing tasks, update `TASK.md` and execute the new or unfinished tasks.
6. If review reports changed assumptions, acceptance, root cause, or bottleneck analysis, update `SOLUTION.md` and then sync `TASK.md`.
7. If review reports that user confirmation is required before remediation, stop and ask for that decision. Do not continue stale remediation.

When remediation is complete, write the same `awaiting_solution_review` state used by first execution.

## Type Routing

Read selected type from `SOLUTION.md` `Type Decision`, then load:

| Type | Reference |
| --- | --- |
| `feat` | `reference/feat.md` |
| `fix` | `reference/fix.md` |
| `refactor` | `reference/refactor.md` |
| `perf` | `reference/perf.md` |
| `test` | `reference/test.md` |
| `docs` | `reference/docs.md` |
| `build` | `reference/build.md` |
| `ci` | `reference/ci.md` |
| `chore` | `reference/chore.md` |
| `style` | `reference/style.md` |

If selected type is missing or unsupported, stop and prompt the user to return to `$porter-codex-plugin:solution`.

## Execution Rules

- Follow `TASK.md` order unless a task explicitly says it can run independently.
- Continue `[~]` before starting another `[ ]` task.
- Do not mark a task complete without observable evidence.
- If verification fails, leave the task unchecked or `[~]`, record the limitation or failure, and stop for user confirmation unless the next step is obvious and still inside the task.
- For documentation or configuration-only tasks, structure review, diff review, markdown fence checks, JSON validation, or skill frontmatter validation can be enough evidence.
- For code or executable configuration changes, run the relevant tests, commands, lint, build, dry-run, benchmark, or manual verification described in the task.
- Do not skip review; completion always transitions to `$porter-codex-plugin:solution-review`.

## Completion Prompt

After execution completes, stop and ask:

**"执行阶段已完成。还有要补充、调整或继续执行的任务吗？如果没有，请显式调用 `$porter-codex-plugin:solution-review` 做审查。"**
