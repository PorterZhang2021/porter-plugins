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

## 阶段边界（强制）

- 本 skill 只执行当前 `TASK.md` 或允许的当前阶段实现任务。
- 完成任务后不得自动进入 `$porter-codex-plugin:review`、`$porter-codex-plugin:commit`、`$porter-codex-plugin:create-pr` 或 `$porter-codex-plugin:merge-to-main`。
- 即使用户在执行阶段说"顺便提交"、"全部走完"，也必须在执行完成后停止。
- 执行完成后先询问用户是否还要补充、调整或继续执行未完成任务；如果没有，再提示用户显式调用下一阶段 skill。
- 执行开始前必须检查 `plan/<type>/<branch-name>/WORKFLOW_STATE.json`；若存在且状态不是 `awaiting_execute`、`executing` 或 `execution_allowed`，必须停止并提示用户先显式调用正确的上一阶段 skill。
- 执行开始时必须把 `WORKFLOW_STATE.json` 更新为 `executing`，允许 Porter workflow hook 放行实现文件修改；执行完成后更新为 `awaiting_review_or_commit`。

## 前置条件

1. **检查当前分支**：若在 `master` 分支上，立即终止并提示：`当前在 master 分支，请先运行 $porter-codex-plugin:new-branch 创建特性分支`
2. 读取当前分支名，提取类型前缀
2. 查找 `plan/<type>/<branch-name>/TASK.md`：
   - **存在** → 找到第一个未完成的任务，直接开始执行
   - **不存在，且类型为 `feat`/`fix`/`refactor`/`test`** → 终止，提示必须先运行 `$porter-codex-plugin:task`
   - **不存在，且类型为其他** → 查找 `plan/<type>/<branch-name>/PLAN.md`，基于 PLAN.md 直接执行，完成后更新 PLAN.md 中对应项为已完成状态
3. 检查 `plan/<type>/<branch-name>/WORKFLOW_STATE.json`：
   - **不存在** → 允许继续，但说明当前分支缺少 workflow state，建议后续由 `$porter-codex-plugin:analyze-bug` / `$porter-codex-plugin:task` 自动生成
   - **状态为 `awaiting_execute` / `executing` / `execution_allowed`** → 允许执行，并在开始实现前更新为 `executing`
   - **其他状态** → 停止，提示用户显式调用状态中记录的 `next_skill`

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

所有任务完成后：

1. 更新 `plan/<type>/<branch-name>/WORKFLOW_STATE.json`：

```json
{
  "state": "awaiting_review_or_commit",
  "current_skill": "$porter-codex-plugin:execute",
  "next_skill": "$porter-codex-plugin:review",
  "alternate_next_skill": "$porter-codex-plugin:commit"
}
```

2. 展示执行摘要并停止，询问：**"执行阶段已完成。还有要补充、调整或继续执行的任务吗？如果没有，请显式调用 `$porter-codex-plugin:review` 做提交前审查，或显式调用 `$porter-codex-plugin:commit` 提交。"**
