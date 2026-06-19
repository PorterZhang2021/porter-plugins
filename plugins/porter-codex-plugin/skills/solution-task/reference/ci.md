# ci — Solution Task Reference

## Read From SOLUTION.md

- `Goal`
- `Scope`
- `Type-Specific Analysis`
- `Acceptance`
- `Risks`

## Task Types

- Workflow file changes.
- Job ordering or trigger changes.
- CI validation or dry-run notes.

## Ordering

- Change pipeline definition before validation.
- Include a local syntax check or explain why validation must happen remotely.

## Template

```markdown
## Task N: <ci change>

无业务逻辑，无需测试；通过 workflow 结构审查或 pipeline 验证。

- [ ] Update `<workflow_path>`
- [ ] 验收标准：<workflow trigger, job, or pipeline behavior expected by SOLUTION.md Acceptance>
- [ ] 验证方式：<local check, dry-run, remote pipeline result, or documented remote-only limitation>
```
