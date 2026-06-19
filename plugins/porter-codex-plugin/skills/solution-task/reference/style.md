# style — Solution Task 参考

## 读取 SOLUTION.md

- `目标`
- `范围`
- `类型专项分析`
- `验收标准`

## 任务类型

- 格式化。
- 命名一致性。
- Lint 或纯风格清理。

## 顺序

- 先应用风格变更，再做最终 diff 审查。
- 不包含行为变更。

## 模板

```markdown
## Task N：<风格项>

无业务逻辑，无需测试；通过格式、lint 或 diff 审查验证。

- [ ] 更新 `<file_path>`
- [ ] 验收标准：纯风格变更符合 SOLUTION.md 验收标准，且不引入行为变化
- [ ] 验证方式：<formatter、lint 或 diff 审查>
```
