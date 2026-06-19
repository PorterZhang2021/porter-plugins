# refactor — Solution Task Reference

## Read From SOLUTION.md

- `Goal`
- `Scope`
- `Type-Specific Analysis`
- `Acceptance`
- `Risks`

## Task Types

- Baseline verification tasks.
- Small refactor steps.
- Regression verification tasks.

## Ordering

- Confirm existing behavior before changing structure.
- Keep each refactor step small enough to verify independently.
- If tests are missing for affected behavior, add coverage before refactoring.

## No Business Logic Label

`refactor` tasks can use "无业务逻辑，无需测试；通过结构审查验证" only when the refactor is limited to Markdown/JSON structure, naming, task templates, or documentation-like configuration and does not affect executable behavior.

For code or executable configuration refactors, do not use the no-test label; require baseline behavior verification and regression verification.

## Template

```markdown
## Task N: <refactor step>

- [ ] Baseline verification: <existing test or manual check>
- [ ] **[重构]** `<file_path>`
  - <structure-only change>
- [ ] 验收标准：accepted behavior remains unchanged while the intended structure improves
- [ ] 验证方式：<existing test, manual check, diff review, or command>
```
