---
name: skill-recommender
description: 根据用户意图推荐合适的 Porter Codex 工作流 skill
---

# Skill Recommender

根据用户当前意图，推荐最合适的 Porter Codex 工作流 skill，并说明推荐原因。

## 使用场景

- 用户不确定应该运行 `$porter-codex-plugin:plan`、`$porter-codex-plugin:task`、`$porter-codex-plugin:execute`、`$porter-codex-plugin:review` 还是 `$porter-codex-plugin:commit`
- 用户描述了一个目标，但没有指定工作流入口
- 用户想了解 Codex 插件里有哪些可用 skill

## 推荐规则

| 用户意图 | 推荐 skill |
| --- | --- |
| 开始新功能或修复 | `$porter-codex-plugin:new-branch` |
| 梳理方案或设计 | `$porter-codex-plugin:plan` |
| 拆分任务清单 | `$porter-codex-plugin:task` |
| 执行已有任务 | `$porter-codex-plugin:execute` |
| 分析 Bug 根因 | `$porter-codex-plugin:analyze-bug` |
| 提交前审查 / 检查实现是否有问题 | `$porter-codex-plugin:review` |
| 提交当前改动 | `$porter-codex-plugin:commit` |
| 合并回主分支 | `$porter-codex-plugin:merge-to-main` |
| 创建 Pull Request | `$porter-codex-plugin:create-pr` |
| 编写 Codex 项目操作手册 | `$porter-codex-plugin:codex-md` |
| 配置 Codex 权限规则 | `$porter-codex-plugin:codex-permissions` |
| 生成解释文档 | `$porter-codex-plugin:explain` |
| 技术选型 | `$porter-codex-plugin:web-service-tech-selection` |
| 英文意图确认 | `$porter-codex-plugin:learn-english` |

## 输出格式

```text
推荐：/<skill-name>
原因：<一句话说明>
下一步：<用户可以直接执行的动作>
```

## 原则

- 只推荐，不自动执行
- 如果用户目标不清楚，先用一个问题澄清
- 如果多个 skill 都适合，最多给出 2 个选择
- 在 `.codex/worktrees/` 中工作时，提醒写入路径必须以当前 worktree 为基准
