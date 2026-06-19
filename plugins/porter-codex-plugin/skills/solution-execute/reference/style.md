# style — Solution Execute 参考

## 读取 TASK.md

- 格式化任务。
- 命名一致性任务。
- Lint 或纯风格清理任务。

## 执行顺序

1. 应用格式、命名或 lint 驱动的变更。
2. 检查 diff，确认没有意外行为变更。
3. 更新 `TASK.md`.

## 验证

- formatter、lint、结构检查或 diff 审查可用于验证纯风格工作。
- 不应引入行为变更。

## TASK.md 更新

- 风格验证和 diff 审查通过后，才能把 style 任务标记为 `[x]`。

## 停止并进入 review

如果 style 变更暴露行为变化或需要更大范围重构，停止并进入 review。
