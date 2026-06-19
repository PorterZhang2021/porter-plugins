# feat — Solution Execute Reference

## Read From TASK.md

- Behavior test tasks.
- Minimal implementation tasks.
- Refactor tasks.
- Final verification tasks.
- Structure validation tasks for Markdown/JSON-only features.

## Execution Order

For executable behavior changes, keep the existing execute prototype rhythm:

1. **Red** — write or run the behavior test and confirm it fails for the missing behavior.
2. **Green** — make the smallest implementation change that passes the behavior test.
3. **Refactor** — clean up only after tests are green, then verify tests still pass.
4. **Update `TASK.md`** — mark the task complete only after verification evidence is available.

For documentation or configuration-only features, execute the file changes and validate structure instead of forcing behavior tests.

## Verification

- Behavior tests must include Case / Given / When / Then / Assert or Verify when the task asks for them.
- Red verification records the expected failing test.
- Green verification records the passing test or observable output.
- Refactor verification records that target and related tests still pass.
- Markdown/JSON-only verification can use structure review, `quick_validate.py`, markdown fence checks, JSON validation, or diff review.

## TASK.md Update

- Continue `[~]` tasks first.
- Mark each completed task `[x]` after its `验证方式` passes or the limitation is recorded.
- Leave failed or blocked tasks unchecked and record why execution stopped.

## Stop And Review

Stop and enter review if behavior cannot be tested, verification contradicts the accepted behavior, or the feature scope no longer matches `SOLUTION.md`.
