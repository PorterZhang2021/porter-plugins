---
name: skill-recommender
description: 根据用户意图推荐合适的 Porter Codex workflow skill；适用于用户不确定该调用 solution、solution-task、solution-execute、solution-review 或配置/解释类 skill 的场景
---

# Skill Recommender

根据用户当前意图，推荐最合适的 Porter Codex workflow skill，并说明推荐原因。

## 使用场景

- 用户描述了一个目标，但没有指定工作流入口。
- 用户不确定当前 solution timeline 应该进入哪个阶段。
- 用户想了解 Codex 插件里有哪些可用 skill。
- 用户需要 Codex 项目配置、解释文档、技术选型或英文意图确认辅助。

## 推荐规则

| 用户意图 | 推荐 skill |
| --- | --- |
| 开始一个 feature/fix/refactor/test/docs/build 等开发目标 | `$porter-codex-plugin:solution` |
| 已有 solution，想拆任务 | `$porter-codex-plugin:solution-task` |
| 已有 task，想执行或回修 | `$porter-codex-plugin:solution-execute` |
| 已执行完成，想审查并进入 commit 确认 | `$porter-codex-plugin:solution-review` |
| review pass 后确认提交 | 不推荐新 skill；按 active state 使用普通 Git commit，并写入 `Codex-Timeline` / `Codex-Slice` trailer |
| 编写 Codex 项目操作手册 | `$porter-codex-plugin:codex-md` |
| 配置 Codex 权限规则 | `$porter-codex-plugin:codex-permissions` |
| 生成解释文档 | `$porter-codex-plugin:explain` |
| 探索解释文档上下文 | `$porter-codex-plugin:explain-explore` |
| 基于 findings 写解释文档 | `$porter-codex-plugin:explain-write` |
| 技术选型 | `$porter-codex-plugin:web-service-tech-selection` |
| 英文意图确认 | `$porter-codex-plugin:learn-english` |
| 编写项目宪法 | `$porter-codex-plugin:constitution` |

## 输出格式

```text
推荐：$porter-codex-plugin:<skill-name>
原因：<一句话说明>
下一步：<用户可以直接执行的动作>
```

如果 review pass 后用户确认 commit，输出：

```text
推荐：普通 Git commit
原因：当前 solution workflow 已进入 awaiting_user_commit_confirm，不需要新的 plugin skill。
下一步：确保当前仓库已安装 solution commit-msg hook，或手动运行 validator；再按 commit message contract 生成提交信息。
```

## 原则

- 只推荐，不自动执行。
- 如果用户目标不清楚，先用一个问题澄清。
- 如果多个 skill 都适合，最多给出 2 个选择。
- 如果当前分支是 `main` 或 `master`，提醒先切换工作上下文；不要推荐旧 branch/worktree workflow。
