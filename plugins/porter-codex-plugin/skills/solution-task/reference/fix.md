# fix — Solution Task Reference

## Read From SOLUTION.md

- `Problem`
- `Type-Specific Analysis`
- `Acceptance`
- `Risks`

Required fix analysis fields:

- Bug description
- Reproduction steps
- Expected vs actual behavior
- Root cause analysis
- Fix plan
- Regression standard

## Hard Stop

Stop and return to `$porter-codex-plugin:solution` if reproduction steps, root cause, or regression standard are missing.

## Task Types

- Reproduction test tasks.
- Minimal fix tasks.
- Regression verification tasks.

## Ordering

Fixed order:

1. Reproduction test.
2. Minimal fix.
3. Regression verification.

Do not generate a fix implementation task before the reproduction or regression path is defined.

## Conditional Execution

- The generated fix task list may include the planned minimal fix, but execution must treat it as conditional.
- If the reproduction test does not reproduce the issue, fails for a different reason, or contradicts the root cause analysis, the executor must not continue with the planned fix.
- In that case, the next loop should update `REVIEW.md` first, then let review-remediation execution update `TASK.md` and, when the root cause changed, `SOLUTION.md`.

## No Business Logic Label

`fix` tasks usually must not be marked "无业务逻辑，无需测试" because a fix needs reproduction and regression evidence.

Only use "无业务逻辑，无需测试；通过结构审查验证" when the fix is limited to Markdown/JSON configuration text, task template wording, documentation, or other non-executable structure, and the regression standard can be verified by structure review.

## Template

```markdown
## Task 1: Reproduction Test

- [ ] **[测试]** `<test_path>`
  - Given: <bug precondition>
  - When: <trigger>
  - Then: <expected correct behavior; currently fails>
- [ ] 验收标准：the known bug is reproducible and tied to the expected regression standard
- [ ] 验证方式：test fails for the known issue before the fix

## Task 2: Minimal Fix

- [ ] **[修复]** `<file_path>`
  - <smallest change that addresses root cause>
- [ ] 前置条件：reproduction test fails for the expected reason before this task starts
- [ ] 验收标准：root cause is addressed without widening the fix scope
- [ ] 验证方式：reproduction test passes

## Task 3: Regression Verification

- [ ] Run related regression checks
- [ ] 验收标准：regression standard from SOLUTION.md Acceptance is satisfied
- [ ] 验证方式：original bug stays fixed and adjacent behavior still works
```
