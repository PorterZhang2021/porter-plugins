# style — Solution Task Reference

## Read From SOLUTION.md

- `Goal`
- `Scope`
- `Type-Specific Analysis`
- `Acceptance`

## Task Types

- Formatting.
- Naming consistency.
- Lint or style-only cleanup.

## Ordering

- Apply style changes before final diff review.
- Do not include behavior changes.

## Template

```markdown
## Task N: <style item>

无业务逻辑，无需测试；通过格式、lint 或 diff 审查验证。

- [ ] Update `<file_path>`
- [ ] 验收标准：style-only change matches SOLUTION.md Acceptance and introduces no behavior change
- [ ] 验证方式：<formatter, lint, or diff review>
```
