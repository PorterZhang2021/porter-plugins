---
name: skill-recommender
description: 根据用户意图推荐合适的 Porter 工作流 skill
---

# Skill Recommender

根据用户当前意图，推荐最合适的 Porter 工作流 skill，并说明推荐原因。

## 使用场景

- 用户不确定应该运行 `/plan`、`/task`、`/execute` 还是 `/commit`
- 用户描述了一个目标，但没有指定工作流入口
- 用户想了解当前仓库里有哪些可用 skill

## 推荐规则

| 用户意图 | 推荐 skill |
| --- | --- |
| 开始新功能或修复 | `/new-branch` |
| 梳理方案或设计 | `/plan` |
| 拆分任务清单 | `/task` |
| 执行已有任务 | `/execute` |
| 分析 Bug 根因 | `/analyze-bug` |
| 提交当前改动 | `/commit` |
| 合并回主分支 | `/merge-to-main` |
| 创建 Pull Request | `/create-pr` |
| 编写项目操作手册 | `/claude-md` |
| 配置 Claude Code 权限 | `/setup-permissions` |
| 生成解释文档 | `/explain` |
| 技术选型 | `/web-service-tech-selection` |
| 英文意图确认 | `/learn-english` |

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
