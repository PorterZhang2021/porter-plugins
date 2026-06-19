# test — Solution Task Reference

## Read From SOLUTION.md

- `Goal`
- `Scope`
- `Type-Specific Analysis`
- `Acceptance`

## Task Types

- Test file creation or update.
- Test case design.
- Test execution and verification.

## Ordering

- Generate only test-related tasks unless test infrastructure must be created.
- Do not generate product implementation tasks for a `test` solution.

## No Business Logic Label

`test` tasks usually must not be marked "无业务逻辑，无需测试" because the purpose of the task is to create or verify test evidence.

Only use "无业务逻辑，无需测试；通过结构审查验证" when the task updates test documentation, test naming guidance, metadata, or non-executable test planning notes without adding or changing runnable tests.

## Template

```markdown
## Task N: <test area>

- [ ] Create or update `<test_path>`
  - Case: <behavior>
  - Given: <precondition>
  - When: <action>
  - Then: <assertion>
  - Assert / Verify: <specific assertion or observable result>
- [ ] 验收标准：test coverage matches the behavior or regression expected by SOLUTION.md Acceptance
- [ ] 验证方式：run the relevant test command
```
