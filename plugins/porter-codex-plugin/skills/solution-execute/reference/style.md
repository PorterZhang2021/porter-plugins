# style — Solution Execute Reference

## Read From TASK.md

- Formatting tasks.
- Naming consistency tasks.
- Lint or style-only cleanup tasks.

## Execution Order

1. Apply formatting, naming, or lint-driven changes.
2. Check diff for accidental behavior changes.
3. Update `TASK.md`.

## Verification

- Formatter, lint, structure check, or diff review can verify style-only work.
- No behavior changes should be introduced.

## TASK.md Update

- Mark style tasks `[x]` after style verification and diff review pass.

## Stop And Review

Stop and enter review if style changes reveal behavior changes or require broader refactoring.
