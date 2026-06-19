# test — Solution Execute Reference

## Read From TASK.md

- Test file creation or update tasks.
- Test case design tasks.
- Test execution and verification tasks.

## Execution Order

1. Create or update the requested tests.
2. Run the relevant test command or record why it cannot be run.
3. Update `TASK.md`.

Do not generate product implementation work for a `test` solution unless the task explicitly says test infrastructure is missing.

## Verification

- New tests should fail or pass according to the task's expected evidence.
- Existing behavior coverage must match the acceptance criteria.
- If execution is impossible, record the limitation and the closest structural check.

## TASK.md Update

- Mark test tasks `[x]` only after the test command or recorded limitation is present.
- Keep missing infrastructure or unclear behavior unchecked and stop for review or user confirmation.

## Stop And Review

Stop and enter review if tests require product changes outside scope, expected behavior is unclear, or the test result contradicts `SOLUTION.md`.
