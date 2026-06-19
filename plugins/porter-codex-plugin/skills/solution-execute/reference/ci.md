# ci — Solution Execute 参考

## 读取 TASK.md

- workflow 文件变更。
- Job 顺序或触发条件变更。
- CI 验证、dry-run 或仅远端验证说明。

## 执行顺序

1. 更新 pipeline 配置。
2. 运行本地语法检查、lint、dry-run，或记录仅远端验证限制。
3. 更新 `TASK.md`.

## 验证

- 有本地检查时优先使用本地检查。
- 如果只能远端验证，记录仅远端验证限制和预期 pipeline 证据。

## TASK.md 更新

- 记录验证证据或仅远端验证限制后，才能把 CI 任务标记为 `[x]`。

## 停止并进入 review

如果 pipeline 无法验证、需要密钥或远端访问，或 trigger/job 行为与 `SOLUTION.md` 不一致，停止并进入 review。
