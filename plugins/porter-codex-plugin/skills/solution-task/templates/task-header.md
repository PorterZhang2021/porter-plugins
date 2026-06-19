# 任务：<标题>

## 时间线上下文

- 方案：`.codex/timeline/<timeline-name>/solutions/<slice-id>-<type>-<slug>.md`
- 时间线：`.codex/timeline/<timeline-name>/`
- 当前切片：`<slice-id>-<type>-<slug>`
- 状态：`.codex/timeline/<timeline-name>/states/<slice-id>-<type>-<slug>.json`
- 分支：`<branch-type>/<branch-name>`
- 类型：`<selected-type>`
- 下一阶段：`$porter-codex-plugin:solution-execute`

## 状态说明

- `[ ]` 待处理
- `[~]` 进行中
- `[x]` 已完成

## 执行规则

- 除非任务明确说明可独立执行，否则按顺序执行。
- 前置测试、复现步骤、度量或验证准备完成前，不要开始实现任务。
- 只有验证步骤通过或验证限制已记录后，才能把任务标记为完成。
- 每个任务必须包含 `验收标准` 和 `验证方式`；没有可观察证据时不得标记完成。
