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

1. 读取当前分支名，提取类型前缀
2. 若无法识别类型，询问用户
3. 读取项目已有协作规则和背景文档，作为规划约束

优先读取这些文件，存在几个读几个，不存在不阻断：

```text
AGENTS.md
AGENTS.md
.codex/constitution.md
README.md
```

如果项目没有任何协作规则文档，继续和用户结对确认规划内容，不自动生成缺失的规则文件。

## 执行

根据分支类型，读取对应文件并按其流程执行：

| 类型 | 文件 | 特殊处理 |
|------|------|---------|
| feat | `reference/feat.md` | - |
| fix | `reference/fix.md` | **优先完成 bug 分析** |
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
2. 如果运行环境支持 bug 分析 agent 或子任务委托，可以使用它进行深度分析
3. 如果运行环境不支持 agent，则在当前对话中完成复现信息整理和根因分析
4. 将分析结果整合到 PLAN.md 的根因分析和修复方案中

## 收尾规则

**强制顺序：必须先写入 PLAN.md，再执行后续操作。**

**禁止：** 未生成 PLAN.md 文件就直接执行变更或提交。

**必须进入任务拆分（业务逻辑类）：** `feat` / `fix` / `refactor` / `test`

**可选进入任务拆分（其他类型）：** `docs` / `chore` / `style` / `perf` / `build` / `ci`

**通用：** 写入 PLAN.md 后停止，不自动执行下一步，只提示用户继续。

提示方式：

```text
Codex：可以继续运行 /task 或使用 task skill。
```

完整链路：

```text
plan -> task -> execute -> review? -> commit -> merge-to-main
```
