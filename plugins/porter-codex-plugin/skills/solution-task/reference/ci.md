# ci — Solution Task 参考

## 读取 SOLUTION.md

- `目标`
- `范围`
- `类型专项分析`
- `验收标准`
- `风险`

## 任务类型

- workflow 文件变更。
- Job 顺序或触发条件变更。
- CI 验证或 dry-run 说明。

## 顺序

- 验证前先修改 pipeline 定义。
- 包含本地语法检查；如果只能远端验证，说明原因。

## 模板

```markdown
## Task N：<CI 变更>

无业务逻辑，无需测试；通过 workflow 结构审查或 pipeline 验证。

- [ ] 更新 `<workflow_path>`
- [ ] 验收标准：<SOLUTION.md 验收标准中预期的 workflow 触发条件、job 或 pipeline 行为>
- [ ] 验证方式：<本地检查、dry-run、远端 pipeline 结果或已记录的仅远端验证限制>
```
