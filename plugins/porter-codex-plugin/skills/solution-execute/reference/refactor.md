# refactor — Solution Execute Reference

## Read From TASK.md

- Baseline verification tasks.
- Small refactor steps.
- Regression verification tasks.

## Execution Order

1. Confirm baseline behavior before changing structure.
2. Execute one small refactor step.
3. Run or record the verification required by the task.
4. Update `TASK.md`.

If behavior coverage is missing and the refactor affects executable behavior, add or request coverage before continuing.

## Verification

- Existing tests, manual checks, command output, or diff review must show accepted behavior is unchanged.
- Markdown/JSON-only refactors may use structure review.

## TASK.md Update

- Mark a refactor step `[x]` only when its behavior-preservation verification passes or the limitation is recorded.
- Keep unfinished refactor work `[~]` if follow-up is still inside the same task.

## Stop And Review

Stop and enter review if behavior changes, verification is unavailable for risky executable changes, or the refactor reveals a scope change.
