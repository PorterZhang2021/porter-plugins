# fix — Solution Execute Reference

## Read From TASK.md

- Reproduction test tasks.
- Minimal fix tasks.
- Regression verification tasks.

## Execution Order

Strict order:

1. **Reproduce** — write or run the reproduction test and confirm it fails for the known issue.
2. **Fix** — make the smallest change that addresses the root cause.
3. **Verify** — confirm the reproduction test passes and related regression checks still pass.
4. **Update `TASK.md`** — mark tasks complete only after verification evidence is available.

## Verification

- Reproduction must fail for the expected reason before the fix.
- The fix must make the reproduction pass.
- Regression verification must cover the standard recorded in `SOLUTION.md` / `TASK.md`.

## TASK.md Update

- Do not mark the fix task complete until the reproduction passes after the change.
- Record failed reproduction, different failure reasons, or regression limitations in `TASK.md`.

## Stop And Review

Stop and enter review if the issue cannot be reproduced, the failure reason differs from `SOLUTION.md`, the root cause is contradicted, or the fix would exceed the accepted scope.
