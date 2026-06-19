# Stage Overview: Workflow Architecture Refactor

## Purpose

本文件是整个 workflow architecture refactor 的阶段总览，层级高于具体 MVP。

它只回答：

- 这个长期改造拆成哪些 MVP。
- 每个 MVP 的目标是什么。
- 每个 MVP 的验收内容是什么。
- 每个 MVP 当前验收结果如何。
- 当前应该读取哪个 MVP overview。

具体某个 MVP 要做哪些 `feat`、`docs`、`build`、`chore`、`test` 工作，不在这里展开，而是在对应的 `MVP_OVERVIEW.md` 中描述。

## Operating Rule

后续任何阶段工作开始前，先读取本文件，再读取当前 MVP 对应的 MVP overview。

当前入口：

```text
STAGE_OVERVIEW.md -> current MVP_OVERVIEW.md -> selected slice workflow
```

其中 `solution` 负责内容决策，`delivery-*` 负责 Git 生命周期。二者可以协同读取 `.codex/timeline/`，但不做强制绑定。

## Scope

本轮先聚焦 branch 串行 workflow，不考虑 worktree 并行模式。

默认只修改 Codex 插件侧：

- `plugins/porter-codex-plugin/`
- `README.md` 中 Codex workflow 说明

不修改 Claude Code 插件，不操作用户本机 `~/.codex`、`~/.claude`、`~/.agents` 配置。

## MVP Roadmap

| MVP | Name | Goal | Acceptance | Result | Status |
| --- | --- | --- | --- | --- | --- |
| 1 | Solution 最小闭环 | 新增独立的 solution 内容闭环，不从旧 `plan` / `analyze-bug` 迁移，也不绑定 Git delivery 生命周期。 | 小 feature、小 fix、小 perf/test/docs/build 等需求能走 `solution -> solution-task -> solution-execute -> solution-review`；产物写入 `.codex/timeline/<timeline-name>/`，并由 `current.json` 指向 active slice；fix 的复现、根因、修复方案被纳入 active slice 的 solution 文件；perf 的基线、瓶颈和验证链路被纳入 active slice 的 solution 文件；review 可记录通过、需修复、需补任务或需更新方案；solution 生成后能提示后续 `delivery-branch` rename checkpoint，但不直接改名。 | 待验收 | in-progress |
| 2 | Delivery Git 生命周期 | 新增独立的 Git 生命周期线：`delivery-branch`、`delivery-commit`、`delivery-merge-to-base`、`delivery-push`、`delivery-create-pr`。 | `delivery-branch` 能先用粗描述创建开发分支；`solution` 落地后可触发 rename checkpoint；重命名前区分未 push、已 push、已有 upstream 或 PR 的影响；commit/merge/push/PR 可以读取 timeline 生成摘要，但不强制依赖 solution。 | 待验收 | pending |
| 3 | MVP 容器 | 建立串行 MVP 的总览、阶段、backlog、slice 和 changelog 结构。 | MVP 有明确的 overview；每个 slice 能回指到 stage acceptance；每轮完成后能更新 result 和 changelog；可以继续拆下一轮 slice。 | 待验收 | pending |
| 4 | Solution 升级 MVP | 支持普通小需求在 review 后升级为 MVP。 | 已完成的普通 solution 能归档为 MVP slice 1；review 发现的新阶段或验收缺口能写入 overview；后续能从新 overview 继续拆 slice。 | 待验收 | pending |

## Current MVP

- MVP: 1
- Name: Solution 最小闭环
- MVP overview: `.codex/timeline/mvp/workflow-architecture-refactor/MVP_OVERVIEW.md`
- Reason: 先把 `solution -> solution-task -> solution-execute -> solution-review` 这条内容最小闭环稳定下来；Git 生命周期拆到下一轮 `delivery-*` MVP，旧 `plan/analyze-bug` 暂时只作为并存旧体系，不作为新 solution 的模板来源。

## MVP Result Log

### MVP 1

- Status: in-progress
- Result: 待填写

### MVP 2

- Status: pending
- Result: 待填写

### MVP 3

- Status: pending
- Result: 待填写

### MVP 4

- Status: pending
- Result: 待填写

## Deferred

- worktree 并行 MVP。
- 自动批量创建 branch/worktree。
- 删除旧 `plan-*` / `analyze-bug` 入口。
- 自动迁移历史规划文件。
