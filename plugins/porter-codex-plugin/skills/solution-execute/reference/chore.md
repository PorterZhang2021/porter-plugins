# chore — Solution Execute Reference

## Read From TASK.md

- Metadata or configuration cleanup tasks.
- File organization tasks.
- Structural validation tasks.

## Execution Order

1. Execute the maintenance change.
2. Run the relevant command, structural check, or diff review.
3. Update `TASK.md`.

## Verification

- Non-executable housekeeping can use structure review or diff review.
- Script, generated output, installation, executable configuration, or workflow behavior changes need a command or targeted regression check.

## TASK.md Update

- Mark chore tasks `[x]` after verification evidence is recorded.
- Record any behavior-affecting surprise before stopping.

## Stop And Review

Stop and enter review if a chore becomes a feature, fix, or build change outside the accepted scope.
