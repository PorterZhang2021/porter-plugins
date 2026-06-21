---
name: timeline-overview
description: 判断目标是否需要多个 solution slice，并维护 timeline 级 OVERVIEW.md / CHANGELOG.md；用于范围不确定、连续 slice 同步和 timeline 收口
allowed-tools:
  - Bash
  - Read
  - Write
  - Glob
  - Grep
---

# Timeline Overview 时间线总览

维护 solution workflow 之上的 timeline 级范围账本。

`timeline-overview` 不是新的执行链路，也不是新的 slice type。它只在用户不确定范围、需要整理多个 solution slice，或准备总结收口时使用。

默认开发流仍然是：

```text
solution -> solution-task -> solution-execute -> solution-review
```

## 阶段边界

- 本 skill 可以创建或更新 `.codex/timeline/<timeline-name>/OVERVIEW.md`。
- 本 skill 可以创建或更新 `.codex/timeline/<timeline-name>/CHANGELOG.md`。
- 本 skill 可以读取同一 timeline 下的 `current.json`、`states/*.json`、`solutions/*.md`、`tasks/*.md` 和 `reviews/*.md`。
- 本 skill 不创建 solution slice id。
- 本 skill 不生成 solution 文件。
- 本 skill 不生成 task 文件。
- 本 skill 不执行实现。
- 本 skill 不执行 review。
- 本 skill 不提交、不合并、不 push、不 create PR。
- 本 skill 不修改 `states/<slice>.json` 的 solution workflow 状态。
- 本 skill 不把 `OVERVIEW.md` 中的状态作为 workflow gate。

overview 层状态只是人类可读账本；真正的执行门禁仍以 active slice 的 `states/<slice>.json` 为准。

## 调用方式

唯一入口：

```text
$porter-codex-plugin:timeline-overview <自然语言意图>
```

用户不需要传入模式参数。`assess`、`sync`、`close`、`gate`、`clarify` 只是本 skill 的内部判断模式。

示例：

```text
$porter-codex-plugin:timeline-overview 看看这个需求是不是要拆
$porter-codex-plugin:timeline-overview 同步一下当前 timeline 的进展
$porter-codex-plugin:timeline-overview 这一串 slice 收个尾
```

## 语言约定

默认输出使用中文，避免无必要的中英文混排。

保留英文的内容：

- skill 名，例如 `$porter-codex-plugin:solution`。
- 文件名、路径、JSON key、state 名和 commit trailer。
- timeline name、slice id、分支名、命令和代码块内容。
- slice type，例如 `feat`、`fix`、`docs`、`build`、`test`。
- 内部模式名，例如 `assess`、`sync`、`close`、`gate`、`clarify`。
- overview 表格中的状态值：`candidate`、`active`、`committed`、`deferred`、`cancelled`。

除上述稳定标识外，解释说明、判断理由、checkpoint 小结、`OVERVIEW.md` / `CHANGELOG.md` 的标题、正文、表头和验收描述默认用中文。`timeline`、`slice`、`workflow` 等核心术语可以保留英文，但句子表达应以中文为主。

## 前置总览讨论

当用户还在描述目标、范围或多个 slice 的关系时，进入前置总览讨论模式，不写文件。

前置总览讨论模式用于确认：

- timeline name。
- timeline 总目标。
- 为什么当前目标不适合单个 solution slice。
- 候选 slice 列表。
- 每个候选 slice 的 type、目标和验收。
- slice 顺序和依赖关系。
- 哪些内容暂不做或延后。
- 整体完成标准。

如果用户是从 `$porter-codex-plugin:solution` handoff 过来的，先读取或复述 solution discussion 中已经形成的范围判断；不要要求用户重新描述全部上下文。

checkpoint 小结只在关键节点输出：

- 初步判断已经形成。
- 判断从单 slice 变为多 slice，或从多 slice 变为单 slice。
- timeline name 发生变化。
- slice 列表、顺序、候选 type 或完成标准发生变化。
- 用户要求总结、确认或写 overview / changelog。

checkpoint 小结包含：

- 我的理解：当前 timeline 目标和为什么需要或不需要多个 slice。
- 候选 slice：每个 slice 的候选 type、目标和验收。
- Timeline：当前建议或已确认的 timeline name。
- 当前边界：做什么、不做什么、延后什么。
- 需要确认：写入前仍需用户确认的问题。
- 下一步：继续讨论，写 `OVERVIEW.md` / `CHANGELOG.md`，或回到 `$porter-codex-plugin:solution`。

正式写入前必须回放最终结论并等待用户确认。没有确认 timeline name、总目标、slice 列表、边界和完成标准时，不写 `OVERVIEW.md`。

写入 `OVERVIEW.md` 后停止，并提示用户选择第一个明确 slice，显式调用 `$porter-codex-plugin:solution` 进入单 slice 闭环。

## Protected Branch Guard

正式写入 `OVERVIEW.md` 或 `CHANGELOG.md` 前必须检查当前 Git 分支。

- 如果当前分支是 `main` 或 `master`，停止，不写 `.codex/timeline/`，提示用户先切换到开发分支或使用 Codex 原生 Git 能力创建工作上下文。
- 如果当前不在 Git repo、分支处于 detached 状态，或分支名无法读取，但用户已经明确确认 timeline name，可以继续写入。
- 不要求分支名符合 `<type>/<name>`。
- 不重命名分支。
- 不创建分支。

## 自动模式判断

按上下文自动选择模式，不要求用户手动选择。

| 上下文 | 模式 | 行为 |
| --- | --- | --- |
| 没有 overview，用户提出新目标且范围不确定 | `assess` | 判断单 slice / 多 slice；单 slice 推荐 `$porter-codex-plugin:solution`；多 slice 回放拆分建议，确认后写 `OVERVIEW.md`。 |
| 已有 overview，用户询问进展、下一步或做完一个 slice | `sync` | 读取 timeline records，同步 `OVERVIEW.md` 中的 slice 状态并推荐下一步。 |
| 已有 overview，但 active slice state 不是终止态 | `gate` | 不推进 overview 收口，不改 workflow state，提示继续 state 中记录的 `next_skill`。 |
| 用户说收尾、总结、差不多了、写 changelog | `close` | 检查是否还有 active / candidate slice，确认后写 `CHANGELOG.md` 或 result 总结。 |
| 无法确定 timeline name，或多个 timeline 都可能匹配 | `clarify` | 停止并请用户确认 timeline name。 |

终止态只按 solution workflow state 判断：

```text
committed
cancelled
```

## Timeline Name 解析

timeline name 解析顺序：

1. 如果本轮对话中用户明确确认了 timeline name，使用该名称。
2. 如果 `.codex/timeline/*/current.json` 中恰好有一个 active state 与用户意图相关，使用该 timeline。
3. 如果当前分支不是 `main` / `master`，可以把分支名第一段 `/` 之后的部分作为默认 timeline name；没有 `/` 时，可以把整个分支名作为默认 timeline name。
4. 如果仍无法确定 timeline name，进入 `clarify`，请用户明确 timeline name。

timeline name 必须使用 kebab-case，写入 `.codex/timeline/<timeline-name>/`。

## 写入确认

任何写入前都必须回放并等待用户确认。

### 写入 `OVERVIEW.md` 前必须回放

- timeline name
- 总目标
- 为什么需要多个 slice
- 拟定 slice 列表
- 每个 slice 的 type、目标和验收
- 哪些内容暂不做或延后
- 是否把当前 active / 已完成 solution 关联为某个 slice

### 写入 `CHANGELOG.md` 前必须回放

- timeline name
- 已完成 slice
- 已取消或延后的 slice
- 整体结果
- 遗留问题
- 是否确认收口和总结措辞

用户没有明确确认时，不写入。

## OVERVIEW.md 结构

`OVERVIEW.md` 是 timeline 级范围账本，建议包含：

```markdown
# Timeline 总览：<timeline-name>

## 目标

<这个 timeline 的总目标>

## 为什么需要多个 Slice

<为什么不是一个 solution slice>

## 边界

### 范围内

- <范围内事项>

### 范围外

- <范围外事项>

## Slice 候选列表

| Slice | Type | 目标 | 验收标准 | 状态 | 关联 Slice |
| --- | --- | --- | --- | --- | --- |
| 001 | feat | <目标> | <验收标准> | candidate | |

## 当前状态

- 当前 active slice：`<slice-id-type-slug>` 或 `none`
- 下一步：`<next skill or decision>`

## 完成标准

- <什么时候这个 timeline 算完成>
```

`Status` 只允许使用人类可读状态：

```text
candidate
active
committed
deferred
cancelled
```

这些状态不替代 `states/<slice>.json`。

## CHANGELOG.md 结构

`CHANGELOG.md` 是 timeline 收口总结，建议包含：

```markdown
# Timeline 变更记录：<timeline-name>

## 结果

<整体结果>

## 已完成 Slice

| Slice | Type | 摘要 | 证据 |
| --- | --- | --- | --- |
| 001 | feat | <摘要> | <review / commit / state> |

## 延后或取消

- <未做或取消的内容和原因>

## 后续事项

- <后续候选事项>
```

## 与 Solution Workflow 的关系

默认推荐路径：

```text
小目标清楚 -> solution
范围不确定 -> timeline-overview
多个 solution 需要整理 -> timeline-overview
需要收口总结 -> timeline-overview
```

`timeline-overview` 只负责看全局。单个 slice 的方案、任务、执行和审查仍由：

```text
$porter-codex-plugin:solution
$porter-codex-plugin:solution-task
$porter-codex-plugin:solution-execute
$porter-codex-plugin:solution-review
```

负责。

如果 active slice 未终止，`timeline-overview` 不继续写 close 总结，而是提示：

```text
当前 active slice 尚未结束。请先继续 <next_skill>。
```

## 不使用 MVP Type

本 skill 不新增 `mvp` type。

MVP、overview 或 timeline 都是容器概念；slice type 仍然只使用：

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

## 输出收尾

如果建议直接使用 solution，输出：

```text
推荐：$porter-codex-plugin:solution
原因：这个目标可以作为单个 slice 处理。
下一步：确认 type、timeline、目标和范围后进入 solution。
```

如果需要写 overview 或 changelog，先回放确认；写入后停止，并提示用户下一步调用 `$porter-codex-plugin:solution`、当前 active state 的 `next_skill`，或确认是否继续收口。
