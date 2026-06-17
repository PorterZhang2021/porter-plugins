---
name: review-worktree
description: worktree workflow 提交前审查
---

# Review

在 `$porter-codex-plugin:execute-worktree` 之后、`$porter-codex-plugin:commit-worktree` 之前，对当前 worktree 中本次实现或修复的全部未提交改动进行审查。

`$porter-codex-plugin:review-worktree` 是可选环节，不自动修改文件，不自动提交，也不强制阻断 `$porter-codex-plugin:commit-worktree`。

## 阶段边界（强制）

- 本 skill 只做提交前审查，只输出 findings、open questions 和 summary。
- 不得自动修改文件，不得自动调用 `$porter-codex-plugin:execute-worktree` 修复，也不得自动调用 `$porter-codex-plugin:commit-worktree` 提交。
- 即使用户说"顺便修掉"或"没问题就提交"，也必须先完成审查并停止。
- 审查完成后先询问用户是否要补充审查范围或处理 findings；如果没有，再提示用户显式调用下一阶段 skill。

## 前置条件

1. **检查当前分支**：若在 `master` 分支上，立即终止并提示：`当前在 master 分支，请先运行 $porter-codex-plugin:new-branch-worktree 创建 worktree 分支`
2. 读取当前分支名，记为 `<current>`
3. 检测 base 分支：
   ```bash
   BASE=$(git config --get "branch.$CURRENT.porter-base")
   if [ -z "$BASE" ]; then
     BASE=$(git remote show origin 2>/dev/null | awk '/HEAD branch/ {print $NF}')
     [ -z "$BASE" ] && BASE=master
   fi
   ```
4. 读取工作区状态：
   ```bash
   git status --short
   ```
5. 若没有未提交改动，提示：`当前没有未提交改动。还有要补充审查的吗？如果没有，请显式调用 $porter-codex-plugin:commit-worktree 或 $porter-codex-plugin:merge-worktree-to-base`

## Review 输入

审查前收集以下上下文：

```bash
git status --short
git diff "$BASE"...HEAD
git diff
```

同时读取当前分支对应的规划文件，存在几个读几个，不存在不阻断：

```text
plan/<type>/<branch-name>/PLAN.md
plan/<type>/<branch-name>/TASK.md
plan/<type>/<branch-name>/ANALYSIS.md
```

基于这些输入整理 review brief：

- 本次目标和验收标准
- 已完成任务
- 当前改动摘要
- 关键 diff
- 需要重点审查的风险点

## 审查机制

采用“双层审查”：当前长上下文负责业务和最终裁决，子代理只负责通用工程审查。

1. 当前 Codex 先基于 review brief 审查业务语义、PLAN / TASK / ANALYSIS 一致性、AGENTS.md / constitution 规则、workflow 阶段边界和最终输出优先级。
2. 如果用户已显式调用 `$porter-codex-plugin:review-worktree`，且当前环境支持 `multi_agent_v1.spawn_agent` 的 `code-reviewer` 子代理或等价的新上下文大模型，使用 `agent_type="code-reviewer"` 委托子代理审查 review brief 和 diff。
3. 子代理只做“通用工程审查”，例如：空指针、未定义值、边界条件、SQL / shell / JSON / Markdown frontmatter / 配置是否明显不可运行、并发竞态、状态不一致、错误处理遗漏、测试缺口、diff 遗漏、命名不一致、历史引用未清干净、secret 泄露、危险命令和权限边界破坏。
4. 子代理不应单独裁决业务意图、配置取舍、删除策略、workflow 阶段边界，或任何需要当前长上下文和用户历史要求才能判断的产品决策。
5. 子代理只返回 findings，不直接修改文件；返回内容必须包含事实依据和文件位置。
6. 当前 Codex 负责结果合并：保留有 diff 或文件事实支撑的问题；把依赖业务背景但证据不足的问题降级为 Open Questions 或丢弃；最终 findings 仍由当前 Codex 按 P0-P3 排序输出。
7. 如果当前环境不支持子代理或新上下文审查，则降级为当前 Codex 按同一审查清单完成审查。

降级不是失败。不同 Codex 环境能力不同，但 `$porter-codex-plugin:review-worktree` 的入口、目标和输出格式必须保持一致。

## 审查重点

- correctness：实现是否满足 PLAN / TASK / ANALYSIS 的目标
- regression：是否引入明显回归或遗漏相关文件
- reliability：错误处理、边界条件和状态一致性
- security：权限、敏感信息、命令执行和配置风险
- maintainability：命名、结构、重复、复杂度和可读性
- documentation：README、skill 描述、工作流链路是否同步
- repository rules：是否符合 AGENTS.md、constitution 和路径规范

## 输出格式

审查结果必须 findings 优先，按严重程度排序：

```text
Findings

- [P1] <标题>
  事实：<基于文件或 diff 的事实>
  推断：<为什么这是问题>
  建议：<如何修复>
  位置：<文件路径:行号>

Open Questions

- <需要用户确认的问题，没有则写“无”>

Summary

- <一句话总结是否建议先修复再 $porter-codex-plugin:commit-worktree>
```

严重程度：

- `P0`：必须立即修复，可能导致严重错误或数据/安全风险
- `P1`：应在提交前修复，可能导致功能错误或明显回归
- `P2`：建议修复，可维护性、边界条件或文档同步问题
- `P3`：可选优化

如果没有发现问题，明确输出：

```text
Findings

未发现阻断 $porter-codex-plugin:commit-worktree 的问题。
```

## 收尾

- 如果存在 `P0` 或 `P1`，询问：**"发现提交前应处理的问题，是否进入修复？"**
- 如果没有 `P0` 或 `P1`，提示：**"Review 完成。还有要补充审查或处理的问题吗？如果没有，请显式调用 `$porter-codex-plugin:commit-worktree` 提交。"**
