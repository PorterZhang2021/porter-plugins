# ci — Solution Execute Reference

## Read From TASK.md

- Workflow file changes.
- Job ordering or trigger changes.
- CI validation, dry-run, or remote-only verification notes.

## Execution Order

1. Update pipeline configuration.
2. Run local syntax checks, lint, dry-run, or document remote-only validation.
3. Update `TASK.md`.

## Verification

- Use local checks when available.
- If validation can only happen remotely, record the remote-only limitation and expected pipeline evidence.

## TASK.md Update

- Mark CI tasks `[x]` after validation evidence or remote-only limitation is recorded.

## Stop And Review

Stop and enter review if the pipeline cannot be validated, secrets or remote access are required, or trigger/job behavior differs from `SOLUTION.md`.
