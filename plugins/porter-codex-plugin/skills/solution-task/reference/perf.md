# perf — Solution Task Reference

## Read From SOLUTION.md

- `Type-Specific Analysis`
- `Acceptance`
- `Risks`

Required perf analysis fields:

- Performance problem
- Measurement method
- Baseline data or collection plan
- Bottleneck analysis
- Optimization plan
- Verification method

## Hard Stop

Stop and return to `$porter-codex-plugin:solution` if there is no baseline data and no baseline collection plan.

## Task Types

- Baseline measurement or collection plan tasks.
- Bottleneck confirmation tasks.
- Optimization implementation tasks.
- Post-optimization verification tasks.

## Ordering

Fixed order:

1. Baseline measurement or collection plan.
2. Bottleneck confirmation.
3. Optimization implementation.
4. Post-optimization verification.

## Conditional Execution

- The generated optimization task may describe the expected optimization path, but execution must treat it as conditional on baseline and bottleneck confirmation.
- If the baseline data contradicts the expected bottleneck or makes the optimization plan invalid, the executor must not continue with the stale optimization task.
- In that case, the next loop should update `REVIEW.md` first, then let review-remediation execution update `TASK.md` and, when the bottleneck or acceptance changed, `SOLUTION.md`.

## No Business Logic Label

`perf` tasks usually must not be marked "无业务逻辑，无需测试" because optimization needs baseline and post-change measurement evidence.

Only use "无业务逻辑，无需测试；通过结构审查验证" when the perf change only documents measurement guidance, updates non-executable benchmark notes, or changes Markdown/JSON configuration text without altering runtime behavior. In that case, validation must still inspect the stated metric, baseline plan, or observable output.

## Template

```markdown
## Task 1: Baseline Measurement

- [ ] Run or document baseline measurement
- [ ] Record environment, input size, command, and result
- [ ] 验收标准：baseline data or collection result is available before optimization
- [ ] 验证方式：recorded command, input, environment, and baseline result can be inspected

## Task 2: Bottleneck Confirmation

- [ ] Inspect bottleneck evidence
- [ ] 验收标准：optimization target is justified by baseline and bottleneck evidence
- [ ] 验证方式：bottleneck evidence is recorded and linked to the planned optimization

## Task 3: Optimization

- [ ] **[优化]** `<file_path>`
  - <optimization step>
- [ ] 前置条件：baseline and bottleneck confirmation still support this optimization
- [ ] 验收标准：optimization is implemented without changing accepted behavior
- [ ] 验证方式：behavior checks still pass after optimization

## Task 4: Performance Verification

- [ ] Re-run measurement
- [ ] Compare with baseline
- [ ] 验收标准：performance target from SOLUTION.md Acceptance improves, or the limitation is explicitly recorded
- [ ] 验证方式：post-optimization measurement is compared with baseline
```
