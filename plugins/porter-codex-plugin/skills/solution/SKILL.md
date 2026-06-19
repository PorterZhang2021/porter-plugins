---
name: solution
description: 默认通过 pre-solution discussion 与用户澄清需求、候选类型和边界；用户确认后基于当前开发分支生成 solution 阶段方案文档，并把新 slice 写入 timeline container
allowed-tools:
  - Bash
  - Read
  - Write
  - Glob
  - Grep
---

# Solution 方案工作坊

通过前置讨论澄清需求，并在用户确认后生成新 solution workflow 的方案文档。

```text
solution -> solution-task -> solution-execute -> solution-review
```

## 阶段边界（强制）

- 本 skill 只生成或更新 active slice 的 solution 文件。
- 本 skill 只生成或更新 active slice 的 state 文件。
- 本 skill 可以创建或更新 timeline container 根目录的 `current.json`。
- 本 skill 不生成 task 文件。
- 本 skill 不执行实现。
- 本 skill 不执行 review。
- 本 skill 不提交、不合并、不 push、不 create PR。
- 即使用户说"继续做"、"顺便拆任务"、"直接实现"，也必须在 solution 完成后停止。

新 slice 的主输出路径是：

```text
.codex/timeline/<timeline-name>/current.json
.codex/timeline/<timeline-name>/solutions/<slice-id>-<type>-<slug>.md
.codex/timeline/<timeline-name>/states/<slice-id>-<type>-<slug>.json
```

旧路径只用于当前在途 slice 收尾：

```text
.codex/timeline/<branch-type>/<branch-name>/SOLUTION.md
.codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json
```

## 调用方式

唯一入口：

```text
$porter-codex-plugin:solution <问题或目标描述>
```

用户不需要先提供 type。type 只能来自讨论结论或用户自然语言纠偏，不作为命令参数。

正式写入由用户在讨论后用自然语言触发，例如：

```text
好了，帮我写方案吧
可以开始写方案了
按这个落地方案
确认，写方案
```

正式写入前必须已有确认过的 type、目标、范围和最终描述，并且当前分支必须是非 `main` / `master` 的开发分支。

## 前置方案讨论（强制）

当用户未显式传入 type 或未确认范围时，必须进入前置讨论模式。

前置讨论模式：

- 不要求当前分支已经匹配最终 type。
- 可以发生在创建开发分支前。
- 可以读取 `AGENTS.md`、`.codex/constitution.md`、`README.md` 和必要上下文。
- 可以根据讨论临时读取一个或多个 `reference/<type>.md`，帮助重新整理问题。
- 可以在讨论中切换候选 type。
- 用户可以用自然语言纠偏，例如"这个应该是 docs"、"这个更像 fix"。
- 如果发现需求包含多个目标，提示拆成多个 solution；如果范围明显变大，提示可能升级为 MVP。
- 不写入 `.codex/timeline/`。

checkpoint 小结只在关键节点输出：

- 初步理解已经形成。
- 候选 type 发生变化。
- 范围边界发生变化。
- 用户提出 type 倾向或纠偏。
- 用户要求总结、确认或写方案。
- 需要建议创建或切换分支。

checkpoint 小结包含：

- 我的理解：当前目标、背景和限制。
- 候选类型：主候选 type、备选 type、判断理由。
- 当前边界：可能做什么、不做什么。
- 已参考模板：本轮实际读取或套用过哪些 `reference/<type>.md`；没有则省略。
- 需要确认：继续推进前需要用户确认的问题。
- 下一步：继续讨论、确认 type、建议创建分支，或在用户要求写方案且当前分支可用于记录 timeline 时写入 solution 文件。

## 正式写入确认（强制）

1. 如果用户还在描述需求，继续执行前置方案讨论，不写文件。
2. 如果用户表达"好了，帮我写方案吧"、"确认，写方案"等写入意图，先回放讨论结论。
3. 回放内容必须包含最终 type、目标、范围、最终描述、主要验收标准和是否需要拆分。
4. 如果用户尚未确认 type、目标、范围或最终描述，继续讨论，不写文件。
5. 正式写入前必须校验当前分支不是 `main` / `master`，且可解析为 `<branch-type>/<branch-name>`。
6. 如果当前分支 type 或命名与最终 type、目标描述不一致，不阻塞写入；必须写入`分支重命名检查点`，提示后续由 `$porter-codex-plugin:delivery-branch` 确认并执行 rename。

## 时间线切片路由

### 路径选择

根据当前分支 `<branch-type>/<branch-name>` 解析默认 timeline name：

```text
<timeline-name> = <branch-name>
```

例如：

```text
feat/refactor-feature-development -> .codex/timeline/refactor-feature-development/
```

长期 MVP timeline 可以使用用户确认过的 timeline name，但 `mvp` 不是 slice type。

timeline name 解析顺序：

1. 如果本轮对话中用户明确确认了 timeline name，使用该名称。
2. 否则使用当前 `<branch-name>` 作为默认 timeline name。
3. 如果需要创建新 slice，必须写入 `.codex/timeline/<timeline-name>/` 新路径。

### 新路径优先

正式写入前按顺序判断：

1. 如果 `.codex/timeline/<timeline-name>/current.json` 存在，必须优先读取它。
2. 如果 active slice 的 `states/<slice>.json` 不是 `awaiting_commit`，停止并提示用户继续该 state 中的 `next_skill`，不创建新 slice。
3. 如果需要创建新 slice，扫描 timeline container 中已有文件编号，生成下一个 slice id。
4. 如果 `current.json` 不存在，但旧 `.codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json` 存在，先读取旧 state：
   - 如果旧 state 不是 `awaiting_commit`，继续当前旧 slice 到完成。
   - 如果旧 state 是 `awaiting_commit`，不继续旧路径，创建新的 timeline slice record。
5. 新 slice 创建必须使用新路径，不再写固定旧 `SOLUTION.md` / `WORKFLOW_STATE.json`。

### 切片 id 生成

`solution` 是唯一创建新 slice id 的入口。

生成规则：

- 扫描 `solutions/`、`tasks/`、`reviews/`、`states/` 下文件名开头的三位编号。
- 取最大编号加一。
- 没有任何编号时从 `001` 开始。
- `<type>` 使用最终选定 type。
- `<slug>` 使用 kebab-case，来自用户确认后的最终目标描述。

切片记录 id：

```text
<slice-id>-<type>-<slug>
```

## current.json

`current.json` 只记录 active slice 指针，不记录完整 workflow state。

```json
{
  "timeline": ".codex/timeline/<timeline-name>",
  "active_slice": "<slice-id>-<type>-<slug>",
  "solution": ".codex/timeline/<timeline-name>/solutions/<slice-id>-<type>-<slug>.md",
  "task": ".codex/timeline/<timeline-name>/tasks/<slice-id>-<type>-<slug>.md",
  "review": ".codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md",
  "state": ".codex/timeline/<timeline-name>/states/<slice-id>-<type>-<slug>.json"
}
```

`current.json` 不得包含：

- `current_skill`
- `next_skill`
- `allowed_outputs`

## states/<slice>.json

生成 solution 文件后，同步写入 active slice state：

```json
{
  "state": "awaiting_solution_task",
  "current_skill": "$porter-codex-plugin:solution",
  "next_skill": "$porter-codex-plugin:solution-task",
  "timeline": ".codex/timeline/<timeline-name>",
  "active_slice": "<slice-id>-<type>-<slug>",
  "solution": ".codex/timeline/<timeline-name>/solutions/<slice-id>-<type>-<slug>.md",
  "task": ".codex/timeline/<timeline-name>/tasks/<slice-id>-<type>-<slug>.md",
  "review": ".codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md",
  "allowed_outputs": [
    ".codex/timeline/<timeline-name>/solutions/<slice-id>-<type>-<slug>.md",
    ".codex/timeline/<timeline-name>/states/<slice-id>-<type>-<slug>.json",
    ".codex/timeline/<timeline-name>/current.json"
  ]
}
```

## 旧路径在途收尾

旧路径只允许当前在途 slice 收尾：

```text
.codex/timeline/<branch-type>/<branch-name>/SOLUTION.md
.codex/timeline/<branch-type>/<branch-name>/TASK.md
.codex/timeline/<branch-type>/<branch-name>/REVIEW.md
.codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json
```

规则：

- 如果 `current.json` 存在，优先使用新路径。
- 如果 `current.json` 不存在但旧 `WORKFLOW_STATE.json` 存在，只有旧 state 未完成时才继续当前旧 slice 收尾。
- 如果旧 `WORKFLOW_STATE.json` 已经处于 `awaiting_commit`，不能继续旧路径，必须创建新的 timeline slice record。
- 新 slice 创建必须使用新路径。
- 不自动迁移旧文件。
- 不删除旧文件。

## 支持类型

初版沿用现有 Git type：

```text
feat
fix
refactor
test
docs
chore
style
perf
build
ci
```

`solution` 不新增 `mvp` Git type。MVP 是 timeline container + overview，不是 slice type。

## 类型推荐参考

| 类型 | 常见信号 |
| --- | --- |
| `feat` | 新能力、新入口、用户可感知行为、新 workflow 能力 |
| `fix` | 错误、异常、失败、不符合预期、回归问题 |
| `refactor` | 结构调整、职责拆分、行为不变、重构 |
| `perf` | 慢、性能、耗时、内存、benchmark、profiling |
| `test` | 补测试、覆盖缺口、测试策略、回归用例 |
| `docs` | README、说明文档、使用指南、术语、流程说明 |
| `build` | 构建脚本、产物、打包、依赖构建配置 |
| `ci` | CI workflow、pipeline、自动化检查、发布流水线 |
| `chore` | 维护、清理、元数据、配置整理、非用户行为变更 |
| `style` | 格式化、命名、lint 风格、无行为变化的代码风格 |

## 类型模板

| 类型 | 参考文件 |
| --- | --- |
| `feat` | `reference/feat.md` |
| `fix` | `reference/fix.md` |
| `refactor` | `reference/refactor.md` |
| `perf` | `reference/perf.md` |
| `test` | `reference/test.md` |
| `docs` | `reference/docs.md` |
| `build` | `reference/build.md` |
| `ci` | `reference/ci.md` |
| `chore` | `reference/chore.md` |
| `style` | `reference/style.md` |

## SOLUTION.md 骨架要求

生成的 solution 文件必须包含以下固定章节：

- 时间线上下文
- 类型决策
- 分支重命名检查点
- 目标
- 问题
- 已读上下文
- 范围
- 类型专项分析
- 视觉模型
- 拟议变更
- 验收标准
- 风险
- 待确认
- 下一步

`fix` 是分析型 reference。当选定 type 为 `fix` 时，必须完成复现与根因分析流程，并把结果写入 solution 文件。新 solution workflow 中不额外调用 `$porter-codex-plugin:analyze-bug`。

## 确认规则

每次生成 solution 文件后，必须列出`待确认`。

确认点应包含：

- type 选择是否正确。
- 范围边界是否正确。
- 输出路径和 slice 命名是否正确。
- 是否接受`分支重命名检查点`。
- 是否有需要用户选择的方案取舍。
- 风险和验收标准是否接受。
- 是否可以进入 `$porter-codex-plugin:solution-task`。

## 收尾

生成 solution 文件、`states/<slice>.json` 和 `current.json` 后停止，询问：

**"Solution 已生成。请先确认`待确认`章节。还有要补充或调整的吗？如果无需调整，请显式调用 `$porter-codex-plugin:solution-task` 生成任务清单。"**
