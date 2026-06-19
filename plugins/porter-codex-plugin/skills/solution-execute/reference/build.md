# build — Solution Execute Reference

## Read From TASK.md

- Build configuration tasks.
- Script or package metadata tasks.
- Build command verification tasks.
- Artifact verification tasks.

## Execution Order

1. Modify build configuration or metadata.
2. Run the build or structural validation command.
3. Verify expected artifacts or record why no persistent artifact exists.
4. Update `TASK.md`.

## Verification

- Build command or structural validation must be recorded when available.
- Artifact verification checks path, file list, metadata, manifest, size, generated output, or downstream load behavior.
- Avoid mistaking stale artifacts for new output.

## TASK.md Update

- Mark build tasks `[x]` only after build and artifact verification pass, or after no-artifact reasoning and observable output are recorded.

## Stop And Review

Stop and enter review if the build cannot be verified, artifact expectations are unclear, or configuration changes affect scope beyond `SOLUTION.md`.
