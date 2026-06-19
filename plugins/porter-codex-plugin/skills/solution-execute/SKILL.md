---
name: solution-execute
description: Execute tasks from the active solution timeline slice, update slice state, and support review-remediation execution in the solution workflow
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
---

# Solution Execute

Execute the active slice task file for the solution workflow:

```text
solution -> solution-task -> solution-execute -> solution-review
```

This skill reads `current.json` to locate the active slice and updates that slice's task and state files.

## Phase Boundary

- Execute the current allowed solution task work.
- Update active slice task file.
- Update active slice state file.
- In review-remediation mode only, update active slice solution file when the active slice review file shows changed assumptions, acceptance, root cause, or bottleneck analysis.
- Do not execute review.
- Do not commit.
- Do not merge, push, or create PR.
- Stop after execution and ask the user whether to supplement, adjust, or continue unfinished tasks.
- If there is no further adjustment, prompt the user to explicitly call `$porter-codex-plugin:solution-review`.

New slice paths:

```text
.codex/timeline/<timeline-name>/current.json
.codex/timeline/<timeline-name>/tasks/<slice-id>-<type>-<slug>.md
.codex/timeline/<timeline-name>/solutions/<slice-id>-<type>-<slug>.md
.codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md
.codex/timeline/<timeline-name>/states/<slice-id>-<type>-<slug>.json
```

## Invocation

```text
$porter-codex-plugin:solution-execute
```

No command arguments are required.

## Path Resolution

`solution-execute` does not create a new slice id.

timeline name resolution:

1. If the user explicitly confirmed a timeline name in the current conversation, use it.
2. Otherwise use the current `<branch-name>` as the default timeline name.
3. If the default `.codex/timeline/<timeline-name>/current.json` does not exist, scan `.codex/timeline/*/current.json`.
4. Use the scanned timeline only when exactly one `current.json` points to a state that allows `$porter-codex-plugin:solution-execute`.
5. If there is no match or more than one match, stop and ask the user to name the timeline explicitly.

Before execution:

1. If `.codex/timeline/<timeline-name>/current.json` exists, use it first.
2. Read `current.json` and resolve active slice files:
   - `solution`
   - `task`
   - `review`
   - `state`
3. Read the `state` path resolved from `current.json`, normally `states/<slice>.json`.
4. If `current.json` does not exist but old `.codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json` exists, enter old-path in-flight completion mode:
   - solution file maps to `.codex/timeline/<branch-type>/<branch-name>/SOLUTION.md`
   - task file maps to `.codex/timeline/<branch-type>/<branch-name>/TASK.md`
   - review file maps to `.codex/timeline/<branch-type>/<branch-name>/REVIEW.md`
   - state file maps to `.codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json`
   - continue only when the old state allows `$porter-codex-plugin:solution-execute`
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

Review-remediation mode also requires:

- review file

Do not read old workflow inputs:

- Do not read `plan/<type>/<branch-name>/PLAN.md`.
- Do not read `plan/<type>/<branch-name>/ANALYSIS.md`.
- Do not read old `plan/` workflow state.

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

Read the resolved state file before execution.

- New path mode reads the `state` file resolved from `current.json`, normally `states/<slice>.json`.
- Old-path in-flight completion mode reads `.codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json`.

Allowed states:

- `awaiting_solution_execute`
- `executing_solution`
- `awaiting_solution_execute_from_review`
- `executing_solution_remediation`

If the state is missing or not in this list, stop and prompt the user to explicitly call the `next_skill` recorded in the state file.

Do not continue without explicit state.

## First Execution Mode

Use this mode for:

- `awaiting_solution_execute`
- `executing_solution`

Before modifying implementation, documentation, configuration, or task files, write:

```json
{
  "state": "executing_solution",
  "current_skill": "$porter-codex-plugin:solution-execute",
  "next_skill": "$porter-codex-plugin:solution-execute",
  "timeline": ".codex/timeline/<timeline-name>",
  "active_slice": "<slice-id>-<type>-<slug>",
  "solution": ".codex/timeline/<timeline-name>/solutions/<slice-id>-<type>-<slug>.md",
  "task": ".codex/timeline/<timeline-name>/tasks/<slice-id>-<type>-<slug>.md",
  "review": ".codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md",
  "allowed_outputs": [
    ".codex/timeline/<timeline-name>/tasks/<slice-id>-<type>-<slug>.md",
    ".codex/timeline/<timeline-name>/states/<slice-id>-<type>-<slug>.json",
    "<files required by unchecked task items>"
  ]
}
```

Then:

1. Read active slice solution file.
2. Read active slice task file.
3. Read selected type from solution file Type Decision.
4. Load `solution-execute/reference/<type>.md`.
5. Continue the first `[~]` task if one exists; otherwise execute the first `[ ]` task.
6. Mark a task `[x]` only after its `验证方式` passes or the verification limitation is recorded.
7. Update the active slice task file after each completed task or substep.

When all tasks are complete, write:

```json
{
  "state": "awaiting_solution_review",
  "current_skill": "$porter-codex-plugin:solution-execute",
  "next_skill": "$porter-codex-plugin:solution-review",
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

## Review-Remediation Mode

Use this mode for:

- `awaiting_solution_execute_from_review`
- `executing_solution_remediation`

Before modifying implementation, documentation, configuration, task file, or solution file, write:

```json
{
  "state": "executing_solution_remediation",
  "current_skill": "$porter-codex-plugin:solution-execute",
  "next_skill": "$porter-codex-plugin:solution-execute",
  "timeline": ".codex/timeline/<timeline-name>",
  "active_slice": "<slice-id>-<type>-<slug>",
  "solution": ".codex/timeline/<timeline-name>/solutions/<slice-id>-<type>-<slug>.md",
  "task": ".codex/timeline/<timeline-name>/tasks/<slice-id>-<type>-<slug>.md",
  "review": ".codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md",
  "allowed_outputs": [
    ".codex/timeline/<timeline-name>/tasks/<slice-id>-<type>-<slug>.md",
    ".codex/timeline/<timeline-name>/solutions/<slice-id>-<type>-<slug>.md",
    ".codex/timeline/<timeline-name>/states/<slice-id>-<type>-<slug>.json",
    "<files required by active slice review remediation>"
  ]
}
```

Then:

1. Read active slice review file.
2. Read active slice task file.
3. Read active slice solution file when the review conclusion affects solution assumptions, acceptance, root cause, or bottleneck analysis.
4. If review reports implementation defects, update implementation/config/docs files and task file.
5. If review reports missing tasks, update task file and execute the new or unfinished tasks.
6. If review reports changed assumptions, acceptance, root cause, or bottleneck analysis, update solution file and then sync task file.
7. If review reports that user confirmation is required before remediation, stop and ask for that decision. Do not continue stale remediation.

When remediation is complete, write the same `awaiting_solution_review` state used by first execution.

## Type Routing

Read selected type from solution file Type Decision, then load:

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

`mvp` is not a slice type.

## Execution Rules

- Follow task file order unless a task explicitly says it can run independently.
- Continue `[~]` before starting another `[ ]` task.
- Do not mark a task complete without observable evidence.
- If verification fails, leave the task unchecked or `[~]`, record the limitation or failure, and stop for user confirmation unless the next step is obvious and still inside the task.
- For documentation or configuration-only tasks, structure review, diff review, markdown fence checks, JSON validation, or skill frontmatter validation can be enough evidence.
- For code or executable configuration changes, run the relevant tests, commands, lint, build, dry-run, benchmark, or manual verification described in the task.
- Do not skip review; completion always transitions to `$porter-codex-plugin:solution-review`.

## 旧路径在途收尾

规则：

- 如果 `current.json` 存在，优先使用新路径。
- 如果 `current.json` 不存在但旧 `WORKFLOW_STATE.json` 存在，只有旧 state 允许进入 `$porter-codex-plugin:solution-execute` 时才继续旧路径收尾。
- 新 slice 创建必须使用新路径。
- 不自动迁移旧文件。
- 不删除旧文件。

## Completion Prompt

After execution completes, stop and ask:

**"执行阶段已完成。还有要补充、调整或继续执行的任务吗？如果没有，请显式调用 `$porter-codex-plugin:solution-review` 做审查。"**
