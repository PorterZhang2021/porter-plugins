---
name: plan
description: 基于当前分支类型，结对生成对应的规划文档
allowed-tools:
  - Bash
  - Read
  - Write
  - Glob
---

# Plan Workshop

## 前置条件

1. 确认 `CLAUDE.md` 和 `.claude/constitution.md` 存在，否则暂停提示用户先运行 `/claude-md`
2. 读取当前分支名，提取类型前缀
3. 若无法识别类型，询问用户

## 执行

根据分支类型，读取对应文件并按其流程执行：

| 类型 | 文件 | 特殊处理 |
|------|------|---------|
| feat | `reference/feat.md` | - |
| fix | `reference/fix.md` | **使用 bug-analyzer agent 分析问题** |
| refactor | `reference/refactor.md` | - |
| test | `reference/test.md` | - |
| docs | `reference/docs.md` | - |
| chore | `reference/chore.md` | - |
| style | `reference/style.md` | - |
| perf | `reference/perf.md` | - |
| build | `reference/build.md` | - |
| ci | `reference/ci.md` | - |

### Bug 修复特殊流程（fix 类型）

对于 `fix` 类型分支，在生成 PLAN.md 前：
1. 询问用户是否有错误信息、堆栈跟踪或日志
2. 如果有，使用 **`delegate_subtask(agent_type='bug-analyzer')`** 进行深度分析
3. 将分析结果整合到 PLAN.md 的根因分析和修复方案中

## 收尾规则

**强制顺序：必须先写入 PLAN.md，再执行后续操作。**

PLAN.md 写完后，询问用户：

```
PLAN.md 已生成，路径：plan/<type>/<branch-name>/PLAN.md

是否需要生成 TASK.md？

  y — 运行 /task 生成任务清单（改动较多时推荐）
  n — 直接运行 /execute（改动简单时可跳过）
```

**禁止：** 未生成 PLAN.md 文件就直接执行变更或提交。

**必须运行 `/task`（业务逻辑类）：** `feat` / `fix` / `refactor` / `test`

**可选运行 `/task`（其他类型）：** `docs` / `chore` / `style` / `perf` / `build` / `ci`

**通用：** 写入 PLAN.md 后提示使用 `/commit` 提交，完整链路：`/plan` → `(/task)` → `/execute` → `/commit` → `/merge-to-main`
