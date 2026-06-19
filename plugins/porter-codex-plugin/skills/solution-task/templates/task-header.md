# Task: <title>

## Timeline Context

- Solution: `.codex/timeline/<branch-type>/<branch-name>/SOLUTION.md`
- Branch: `<branch-type>/<branch-name>`
- Type: `<selected-type>`
- Timeline path: `.codex/timeline/<branch-type>/<branch-name>/`
- Next stage: `$porter-codex-plugin:solution-execute`

## Status Legend

- `[ ]` pending
- `[~]` in progress
- `[x]` complete

## Execution Rule

- Execute tasks in order unless a task explicitly says it can run independently.
- Do not start implementation tasks before their prerequisite tests, reproduction steps, measurements, or validation setup are ready.
- Mark each task complete only after its verification step passes or the verification limitation is recorded.
- Every task must include `验收标准` and `验证方式`; do not mark a task complete without observable evidence.
