---
name: solution-review
description: 在 solution-execute 后审查 active solution timeline slice，写入 slice review 文件，并根据通过或回修结论更新 state
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
---

# Solution Review 审查

在 `$porter-codex-plugin:solution-execute` 后审查 active slice：

```text
solution -> solution-task -> solution-execute -> solution-review
```

本 skill 为 active slice 写入可追踪的 review 文件，并更新 active slice state。

## 阶段边界

- 只审查当前 active solution workflow 结果。
- 写入或更新 active slice 的 review 文件。
- 写入或更新 active slice 的 state 文件。
- 不修改 review 输出之外的实现、文档或配置文件。
- 不更新 task 文件。
- 不更新 solution 文件。
- 不执行修复。
- 不提交。
- 不合并、不 push、不 create PR。
- review 完成后停止，并提示用户调用下一个明确 skill。

新 slice 的 review 输出：

```text
.codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md
.codex/timeline/<timeline-name>/states/<slice-id>-<type>-<slug>.json
```

## 调用方式

```text
$porter-codex-plugin:solution-review
```

无需命令参数。

## 路径解析

`solution-review` 不创建新的 slice id。

timeline name 解析顺序：

1. 如果用户在本轮对话中明确确认了 timeline name，使用该名称。
2. 否则使用当前 `<branch-name>` 作为默认 timeline name。
3. 如果默认 `.codex/timeline/<timeline-name>/current.json` 不存在，扫描 `.codex/timeline/*/current.json`。
4. 只有当扫描结果中恰好一个 `current.json` 指向允许 `$porter-codex-plugin:solution-review` 的 state 时，才使用该 timeline。
5. 如果没有匹配或存在多个匹配，停止并请用户明确 timeline name。

review 前：

1. 如果 `.codex/timeline/<timeline-name>/current.json` 存在，优先使用它。
2. 读取 `current.json` 并解析 active slice 文件：
   - `solution`
   - `task`
   - `review`
   - `state`
3. 从 `states/<slice>.json` 读取 active slice state。
4. 如果 `current.json` 不存在，但旧 `.codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json` 存在，进入旧路径在途收尾模式：
   - solution 文件映射到 `.codex/timeline/<branch-type>/<branch-name>/SOLUTION.md`
   - task 文件映射到 `.codex/timeline/<branch-type>/<branch-name>/TASK.md`
   - review 文件映射到 `.codex/timeline/<branch-type>/<branch-name>/REVIEW.md`
   - state 文件映射到 `.codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json`
   - 只有旧 state 允许 `$porter-codex-plugin:solution-review` 时才继续
5. 新 slice 创建必须使用新路径，并且只能由 `$porter-codex-plugin:solution` 完成。

## 前置条件

1. 确认 `AGENTS.md` 存在。
2. 确认 `.codex/constitution.md` 存在。
3. 确认当前分支不是 `main` 或 `master`。
4. 读取当前分支名，并确认符合 `<branch-type>/<branch-name>`。
5. 通过 `current.json` 解析 active slice；如果没有 `current.json` 但存在旧 `WORKFLOW_STATE.json`，进入旧路径在途收尾模式。

必须存在的 active slice 文件：

- solution 文件
- task 文件
- state 文件

可选 active slice 文件：

- review 文件；仅在需要验证回修时读取

## current.json

`current.json` 是 active slice 指针，不是 workflow state。

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

## 状态门

review 前必须读取 active slice state。

允许状态：

- `awaiting_solution_review`

如果 state 缺失或不是 `awaiting_solution_review`，停止并提示用户显式调用 state 文件中记录的 `next_skill`。

没有明确 state 时不得继续。

## Review 输入

写入 review 文件前收集以下上下文：

```bash
git status --short
git diff
git ls-files --others --exclude-standard
```

读取：

- active slice solution 文件
- active slice task 文件
- active slice state 文件
- active slice review 文件，如果存在且需要用于验证回修
- `git ls-files --others --exclude-standard` 报告的范围内未跟踪文件

构建 review brief，包含：

- solution 文件中的当前目标和验收标准。
- task 文件中的已完成和未完成任务。
- `git status --short` 中的当前变更摘要。
- `git diff` 中的关键 diff 摘要或文件路径。
- 未体现在 `git diff` 中的范围内未跟踪文件内容。
- 需要重点审查的风险点。

不要读取旧 workflow 输入：

- 不读取 `plan/<type>/<branch-name>/PLAN.md`。
- 不读取 `plan/<type>/<branch-name>/ANALYSIS.md`。
- 不读取旧 `plan/` workflow state。

## Review 机制

使用两层 review。当前 Codex 负责 workflow 判断和最终结论；子代理仅在可用时执行通用工程审查。

当前 Codex 必须审查：

- 业务语义，以及结果是否满足 solution 文件。
- Solution / task 一致性。
- Solution workflow 阶段边界。
- AGENTS.md 和 constitution 规则。
- Codex plugin 路径边界。
- 最终结果和下一个 workflow state。

首次正常 review 时，如果环境支持 `code-reviewer` 子代理或等价的新上下文 review 能力，默认使用两层 review。把 review brief 和相关 diff 交给子代理，只要求其基于文件事实给出通用工程 findings。

子代理可以检查：

- JSON、Markdown 和 frontmatter 有效性。
- State 不一致。
- 缺少验证证据。
- 命名或路径不一致。
- 旧 workflow 路径残留。
- 危险命令、权限边界问题或密钥风险。
- 明显的正确性、回归、可靠性、可维护性或文档问题。

子代理不得决定：

- 业务意图。
- 配置保留或删除取舍。
- Solution workflow 阶段边界。
- 是否应扩大范围。
- 任何依赖当前长上下文用户历史的决策。

当前 Codex 必须合并结果。只保留有文件、diff 或命令输出支持的发现。需要用户判断的问题降级为`待确认问题`。

如果子代理 review 不可用，在当前 Codex 上下文完成 review，并在 review 文件的`备注`章节记录原因。这是有效降级，不是 review 失败。

回修 review：

1. 只有在确认上一次 active slice review 文件的`时间线上下文`与当前 active slice id、solution 路径、task 路径、review 路径和 state 路径一致后，才读取该 review 文件。
2. 如果已有 review 文件属于更早 slice 或不同上下文，将其视为过期文件，并按首次正常 review 覆盖。
3. 验证对应的旧发现是否已经解决。
4. 当回修 diff 较大、涉及可执行行为、用户明确要求，或通用工程风险较高时，再次使用子代理。
5. 如果跳过子代理 review，在 review 文件的`备注`章节记录原因。

## Review 检查清单

选择 result 前检查以下全部内容：

- Solution 的目标、范围和验收标准仍然成立。
- Task 条目全部完成；如有未完成项，必须有清楚的记录原因。
- 每个已完成任务都有验证证据或已记录限制。
- 当前 diff 和范围内未跟踪文件只包含本 slice 允许的文件。
- 修改实现或配置文件时，新增或修改文件仍在 Codex plugin 路径边界内。
- 除非 solution 明确要求，否则没有修改旧 `plan-*`、`execute-*`、`review-*` 或 Claude 侧配置。
- 已修改 skill 的 Markdown frontmatter 有效。
- JSON 示例或 state 文件可以解析。
- Markdown 代码围栏成对闭合。
- 状态可以进入正确的下一阶段。
- review 输出没有引入本 solution loop 之外的 state。

## REVIEW.md 结构

按以下结构写入 active slice review 文件：

```markdown
# 审查：<标题>

## 时间线上下文

- 方案：`.codex/timeline/<timeline-name>/solutions/<slice-id>-<type>-<slug>.md`
- 任务：`.codex/timeline/<timeline-name>/tasks/<slice-id>-<type>-<slug>.md`
- 审查：`.codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md`
- 状态：`.codex/timeline/<timeline-name>/states/<slice-id>-<type>-<slug>.json`
- 时间线：`.codex/timeline/<timeline-name>`
- 当前切片：`<slice-id>-<type>-<slug>`
- 类型：`<selected-type>`

## 结果

<pass | needs-fix | needs-task-update | needs-solution-update>

## 检查项

- <结构、state、命令或 review 检查>

## 发现

- <按 P0/P1/P2/P3 排序的发现；没有发现时写 "无">

## 待确认问题

- <需要用户确认的问题；没有时写 "无">

## 备注

- <非阻塞观察、子代理可用性或跳过原因>

## 下一步

<下一个明确 skill>
```

`Result` 必须严格使用以下值之一：

- `pass`
- `needs-fix`
- `needs-task-update`
- `needs-solution-update`

发现必须按严重程度排序：`P0`、`P1`、`P2`、`P3`。即使没有阻塞问题，也记录非阻塞的 `P2` 和 `P3` 发现。

没有发现时写入：

```text
无
```

如果 review 发现范围、假设、验收标准、根因或瓶颈问题需要重新确认，使用 `needs-solution-update`。不要引入其它 state。

## Result 规则

以下情况使用 `pass`：

- 验收标准已经满足。
- 任务已经完成，或剩余事项已明确记录为非阻塞。
- 验证证据存在，或限制已记录。
- 没有阻塞 commit 的 `P0` 或 `P1` finding。

当实现、文档、配置或验证输出有误并需要回修时，使用 `needs-fix`。

当任务清单不完整、过期、缺少验证，或已经不能代表必要工作时，使用 `needs-task-update`。

当 solution 的假设、范围、验收标准、根因或瓶颈分析需要变化，或需要用户重新确认时，使用 `needs-solution-update`。

## 状态输出

当结果为 `pass` 时，写入 active slice state：

```json
{
  "state": "awaiting_commit",
  "current_skill": "$porter-codex-plugin:solution-review",
  "next_skill": "$porter-codex-plugin:commit",
  "timeline": ".codex/timeline/<timeline-name>",
  "active_slice": "<slice-id>-<type>-<slug>",
  "solution": ".codex/timeline/<timeline-name>/solutions/<slice-id>-<type>-<slug>.md",
  "task": ".codex/timeline/<timeline-name>/tasks/<slice-id>-<type>-<slug>.md",
  "review": ".codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md",
  "allowed_outputs": [
    ".codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md",
    ".codex/timeline/<timeline-name>/states/<slice-id>-<type>-<slug>.json"
  ]
}
```

当结果为 `needs-fix`、`needs-task-update` 或 `needs-solution-update` 时，写入 active slice state：

```json
{
  "state": "awaiting_solution_execute_from_review",
  "current_skill": "$porter-codex-plugin:solution-review",
  "next_skill": "$porter-codex-plugin:solution-execute",
  "timeline": ".codex/timeline/<timeline-name>",
  "active_slice": "<slice-id>-<type>-<slug>",
  "solution": ".codex/timeline/<timeline-name>/solutions/<slice-id>-<type>-<slug>.md",
  "task": ".codex/timeline/<timeline-name>/tasks/<slice-id>-<type>-<slug>.md",
  "review": ".codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md",
  "allowed_outputs": [
    ".codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md",
    ".codex/timeline/<timeline-name>/states/<slice-id>-<type>-<slug>.json"
  ]
}
```

review 阶段不得写入 task 文件或 solution 文件。回修属于 `$porter-codex-plugin:solution-execute`。

## 旧路径在途收尾

规则：

- 如果 `current.json` 存在，优先使用新路径。
- 如果 `current.json` 不存在但旧 `WORKFLOW_STATE.json` 存在，只有旧 state 允许进入 `$porter-codex-plugin:solution-review` 时才继续旧路径收尾。
- 新 slice 创建必须使用新路径。
- 不自动迁移旧文件。
- 不删除旧文件。

## 收尾提示

如果结果为 `pass`，停止并提示：

**"Review 已完成，结果为 pass。还有要补充审查的吗？如果没有，请显式调用 `$porter-codex-plugin:commit` 提交。"**

如果结果为 `needs-fix`、`needs-task-update` 或 `needs-solution-update`，停止并提示：

**"Review 已完成，发现需要回修的内容。请确认后显式调用 `$porter-codex-plugin:solution-execute` 进入回修。"**
