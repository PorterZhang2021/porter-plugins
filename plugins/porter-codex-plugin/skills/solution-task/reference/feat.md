# feat — Solution Task Reference

## Read From SOLUTION.md

- `Goal`
- `Scope`
- `Type-Specific Analysis`
- `Visual Model`
- `Proposed Changes`
- `Acceptance`
- `Risks`

## TDD Rule

Feature work that changes executable behavior must follow Red / Green / Refactor:

1. **Red** — write behavior tests first and confirm they fail for the missing behavior.
2. **Green** — implement the smallest change that makes the behavior tests pass.
3. **Refactor** — clean up structure after tests are green, then verify tests still pass.

Do not generate a feature implementation task before the behavior test task unless the solution is explicitly documentation/configuration-only and has no executable behavior.

## Behavior Spec Structure

Each behavior test task must describe behavior with this structure:

- Case: one sentence describing the behavior scenario.
- Given: precondition, state, input, fixture, or mock setup.
- When: user action, API call, command, or system event.
- Then: expected user-visible or system-visible outcome.
- Assert / Verify: concrete assertion, file output, state change, returned value, emitted event, or observable result.

Use domain behavior names instead of implementation function names when writing test cases.

## Task Types

- Behavior specification and failing test tasks.
- Minimal implementation tasks.
- Refactor tasks after tests are green.
- Final verification tasks.
- Structure validation tasks for Markdown/JSON-only changes.

## Ordering

- Put behavior spec and failing tests before implementation.
- Put minimal implementation after tests are red.
- Put refactor after tests are green.
- Put final verification after implementation and refactor.
- For Markdown-only skill or reference changes, write "无业务逻辑，无需测试；通过结构审查验证".

## Template

```markdown
## Task N: <feature behavior>

### Red: Behavior Test

- [ ] **[测试]** `<test_path>`
  - Case: <behavior scenario>
  - Given: <precondition, input, fixture, or mock>
  - When: <action, API call, command, or event>
  - Then: <expected behavior>
  - Assert / Verify: <specific assertion or observable output>
- [ ] 验收标准：test captures the target behavior from SOLUTION.md Acceptance
- [ ] 验证方式：test fails before implementation for the expected reason

### Green: Minimal Implementation

- [ ] **[实现]** `<file_path>`
  - <smallest change needed to pass the behavior test>
- [ ] 验收标准：target behavior from SOLUTION.md Acceptance is satisfied
- [ ] 验证方式：target behavior test passes

### Refactor

- [ ] **[重构]** `<file_path>`
  - <cleanup allowed only after tests are green>
- [ ] 验收标准：structure is improved without changing accepted behavior
- [ ] 验证方式：target and related tests still pass
```

## Documentation Or Configuration Only Template

```markdown
## Task N: <feature unit>

无业务逻辑，无需测试；通过结构审查验证。

- [ ] <create or update file>
- [ ] <define behavior, fields, or rules>
- [ ] 验收标准：<documentation/configuration result expected by SOLUTION.md Acceptance>
- [ ] 验证方式：<structure check, command, or review method>
```

## Validation

- Behavior tasks include Case / Given / When / Then / Assert or Verify.
- Implementation tasks follow failing behavior tests.
- Refactor tasks happen only after tests are green.
- Final verification records the test or observable check used.
- Every task includes `验收标准` and `验证方式`.
- Skill frontmatter validates when skill files are generated.
- Markdown fences are balanced.
- JSON examples parse when present.
- Output paths point to `.codex/timeline/<branch-type>/<branch-name>/`.
