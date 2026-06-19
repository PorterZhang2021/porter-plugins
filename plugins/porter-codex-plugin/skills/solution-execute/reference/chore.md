# chore — Solution Execute 参考

## 读取 TASK.md

- 元数据或配置清理任务。
- 文件组织任务。
- 结构验证任务。

## 执行顺序

1. 执行维护变更。
2. 运行相关命令、结构检查或 diff 审查。
3. 更新 `TASK.md`.

## 验证

- 非可执行维护项可以使用结构审查或 diff 审查验证。
- 脚本、生成输出、安装、可执行配置或 workflow 行为变更需要命令或定向回归检查。

## TASK.md 更新

- 记录验证证据后，才能把 chore 任务标记为 `[x]`。
- 停止前记录任何影响行为的意外情况。

## 停止并进入 review

如果 chore 变成超出已接受范围的 feature、fix 或 build 变更，停止并进入 review。
