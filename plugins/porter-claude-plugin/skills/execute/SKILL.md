---
name: execute
description: 基于当前分支类型，按对应节奏逐任务执行 TASK.md
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
---

# Execute

## 前置条件

1. **检查当前分支**：若在 `master` 分支上，立即终止并提示：`当前在 master 分支，请先运行 /new-branch 创建特性分支`
2. 读取当前分支名，提取类型前缀
2. 查找 `plan/<type>/<branch-name>/TASK.md`：
   - **存在** → 找到第一个未完成的任务，直接开始执行
   - **不存在，且类型为 `feat`/`fix`/`refactor`/`test`** → 终止，提示必须先运行 `/task`
   - **不存在，且类型为其他** → 查找 `plan/<type>/<branch-name>/PLAN.md`，基于 PLAN.md 直接执行，完成后更新 PLAN.md 中对应项为已完成状态

## 执行

根据分支类型，读取对应文件并按其节奏执行：

| 类型 | 文件 |
|------|------|
| feat | `reference/feat.md` |
| fix | `reference/fix.md` |
| refactor | `reference/refactor.md` |
| test | `reference/test.md` |
| docs | `reference/docs.md` |
| chore | `reference/chore.md` |
| style | `reference/style.md` |
| perf | `reference/perf.md` |
| build | `reference/build.md` |
| ci | `reference/ci.md` |

## 收尾

所有任务完成后，展示执行摘要，询问：**"所有任务已完成，是否运行 `/commit` 提交？"**
