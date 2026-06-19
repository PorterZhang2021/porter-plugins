# chore — Solution Task Reference

## Read From SOLUTION.md

- `Goal`
- `Scope`
- `Type-Specific Analysis`
- `Proposed Changes`
- `Acceptance`
- `Risks`

## Task Types

- Metadata or configuration cleanup.
- File organization changes.
- Structural validation.

## Ordering

- Group tasks by affected area.
- Add tests only if behavior, scripts, or executable configuration changes.

## No Business Logic Label

`chore` tasks can use "无业务逻辑，无需测试；通过结构审查验证" when they only change metadata, Markdown/JSON configuration text, file organization notes, or non-executable housekeeping.

If a chore changes scripts, generated outputs, executable configuration, installation behavior, or user-visible workflow behavior, require a command, structural check, or targeted regression check instead of the no-test label.

## Template

```markdown
## Task N: <maintenance item>

- [ ] <change>
- [ ] 验收标准：<maintenance result expected by SOLUTION.md Acceptance>
- [ ] 验证方式：<diff review, structural check, or command>
```
