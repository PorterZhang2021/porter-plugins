---
name: solution-execute
description: 执行 active solution timeline slice 的任务，更新 task 和 state，并在 review 回修或 commit 确认前变更时回到执行闭环
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
---

# Solution Execute 执行

执行 solution workflow 中 active slice 的任务文件：

```text
solution -> solution-task -> solution-execute -> solution-review
```

本 skill 通过 `current.json` 定位 active slice，并更新该 slice 的 task 和 state 文件。

## 阶段边界

- 执行当前允许的 solution task 工作。
- 更新 active slice 的 task 文件。
- 更新 active slice 的 state 文件。
- 仅在 review 回修模式中，当 active slice review 文件说明假设、验收标准、根因或瓶颈分析变化时，才更新 active slice 的 solution 文件。
- 如果 state 已经是 `awaiting_user_commit_confirm`，但用户提出新修改，必须回到回修执行，不得直接 commit。
- 不执行 review。
- 不提交。
- 不合并、不 push、不 create PR。
- 执行完成后停止，询问用户是否要补充、调整或继续未完成任务。
- 如果没有进一步调整，提示用户显式调用 `$porter-codex-plugin:solution-review`。

新 slice 路径：

```text
.codex/timeline/<timeline-name>/current.json
.codex/timeline/<timeline-name>/tasks/<slice-id>-<type>-<slug>.md
.codex/timeline/<timeline-name>/solutions/<slice-id>-<type>-<slug>.md
.codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md
.codex/timeline/<timeline-name>/states/<slice-id>-<type>-<slug>.json
```

## 调用方式

```text
$porter-codex-plugin:solution-execute
```

无需命令参数。

## Protected Branch Guard

执行前必须检查当前 Git 分支。

- 如果当前分支是 `main` 或 `master`，停止，不修改实现、配置、文档、task 或 state，提示用户先自行切换到开发分支或使用 Codex 原生 Git 能力创建工作上下文。
- 不要求分支名符合 `<type>/<name>`。
- 不要求分支 type 等于 slice type。
- 不要求存在 `branch.<branch>.porter-base`。

## 路径解析

`solution-execute` 不创建新的 slice id。

timeline name 解析顺序：

1. 如果用户在本轮对话中明确确认了 timeline name，使用该名称。
2. 如果当前分支不是 `main` / `master`，可以把分支名第一段 `/` 之后的部分作为默认 timeline name；没有 `/` 时，可以把整个分支名作为默认 timeline name。
3. 如果默认 `.codex/timeline/<timeline-name>/current.json` 不存在，扫描 `.codex/timeline/*/current.json`。
4. 只有当扫描结果中恰好一个 `current.json` 指向允许 `$porter-codex-plugin:solution-execute` 的 state 时，才使用该 timeline。
5. 如果没有匹配或存在多个匹配，停止并请用户明确 timeline name。

执行前：

1. 如果 `.codex/timeline/<timeline-name>/current.json` 存在，优先使用它。
2. 读取 `current.json` 并解析 active slice 文件：
   - `solution`
   - `task`
   - `review`
   - `state`
3. 读取 `current.json` 解析出的 `state` 路径，通常是 `states/<slice>.json`。
4. 新 slice 创建必须使用新路径，并且只能由 `$porter-codex-plugin:solution` 完成。

## 前置条件

1. 确认 `AGENTS.md` 存在。
2. 确认 `.codex/constitution.md` 存在。
3. 执行 protected branch guard。
4. 通过 `current.json` 解析 active slice。

必须存在的 active slice 文件：

- solution 文件
- task 文件
- state 文件

review 回修模式还需要：

- review 文件

不要读取旧 workflow 输入：

- 不读取 `plan/<type>/<branch-name>/PLAN.md`。
- 不读取 `plan/<type>/<branch-name>/ANALYSIS.md`。
- 不读取旧 `plan/` workflow state。

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

执行前必须读取解析出的 state 文件。

允许状态：

- `awaiting_solution_execute`
- `executing_solution`
- `awaiting_solution_execute_from_review`
- `executing_solution_remediation`
- `awaiting_user_commit_confirm`

如果 state 缺失或不在上述列表中，停止并提示用户显式调用 state 文件中记录的 `next_skill`，或在 `committed` / `cancelled` 终止态时创建新的 solution slice。

没有明确 state 时不得继续。

## 首次执行模式

以下状态使用此模式：

- `awaiting_solution_execute`
- `executing_solution`

在修改实现、文档、配置或 task 文件前，先写入：

```json
{
  "state": "executing_solution",
  "current_skill": "$porter-codex-plugin:solution-execute",
  "next_skill": "$porter-codex-plugin:solution-execute",
  "timeline": ".codex/timeline/<timeline-name>",
  "active_slice": "<slice-id>-<type>-<slug>",
  "solution": ".codex/timeline/<timeline-name>/solutions/<slice-id>-<type>-<slug>.md",
  "task": ".codex/timeline/<timeline-name>/tasks/<slice-id>-<type>-<slug>.md",
  "review": ".codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md",
  "allowed_outputs": [
    ".codex/timeline/<timeline-name>/tasks/<slice-id>-<type>-<slug>.md",
    ".codex/timeline/<timeline-name>/states/<slice-id>-<type>-<slug>.json",
    "<files required by unchecked task items>"
  ]
}
```

然后：

1. 读取 active slice 的 solution 文件。
2. 读取 active slice 的 task 文件。
3. 从 solution 文件的`类型决策`读取选定 type。
4. 加载 `solution-execute/reference/<type>.md`。
5. 如果存在第一个 `[~]` 任务，继续该任务；否则执行第一个 `[ ]` 任务。
6. 只有在任务的`验证方式`通过或已记录验证限制后，才能把任务标记为 `[x]`。
7. 每完成一个任务或子步骤后，更新 active slice 的 task 文件。

当所有任务完成后，写入：

```json
{
  "state": "awaiting_solution_review",
  "current_skill": "$porter-codex-plugin:solution-execute",
  "next_skill": "$porter-codex-plugin:solution-review",
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

## 审查回修模式

以下状态使用此模式：

- `awaiting_solution_execute_from_review`
- `executing_solution_remediation`
- `awaiting_user_commit_confirm`

`awaiting_user_commit_confirm` 只在用户提出新修改、补充验收或要求重新调整时进入本模式；如果用户只是确认 commit，不使用本 skill。

在修改实现、文档、配置、task 文件或 solution 文件前，先写入：

```json
{
  "state": "executing_solution_remediation",
  "current_skill": "$porter-codex-plugin:solution-execute",
  "next_skill": "$porter-codex-plugin:solution-execute",
  "timeline": ".codex/timeline/<timeline-name>",
  "active_slice": "<slice-id>-<type>-<slug>",
  "solution": ".codex/timeline/<timeline-name>/solutions/<slice-id>-<type>-<slug>.md",
  "task": ".codex/timeline/<timeline-name>/tasks/<slice-id>-<type>-<slug>.md",
  "review": ".codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md",
  "allowed_outputs": [
    ".codex/timeline/<timeline-name>/tasks/<slice-id>-<type>-<slug>.md",
    ".codex/timeline/<timeline-name>/solutions/<slice-id>-<type>-<slug>.md",
    ".codex/timeline/<timeline-name>/states/<slice-id>-<type>-<slug>.json",
    "<files required by active slice remediation>"
  ]
}
```

然后：

1. 读取 active slice 的 review 文件；如果 state 来自 `awaiting_user_commit_confirm` 且 review 文件不存在，停止并要求先 review。
2. 读取 active slice 的 task 文件。
3. 当 review 结论、用户新要求或验收变化影响 solution 假设、验收标准、根因或瓶颈分析时，读取 active slice 的 solution 文件。
4. 如果 review 或用户新要求报告实现缺陷，更新实现、配置或文档文件，并同步 task 文件。
5. 如果 review 报告任务缺失，更新 task 文件并执行新增或未完成任务。
6. 如果 review 报告假设、验收标准、根因或瓶颈分析变化，更新 solution 文件，然后同步 task 文件。
7. 如果回修前需要用户确认，停止并询问该决策。不要继续执行过期回修。

回修完成后，写入与首次执行相同的 `awaiting_solution_review` state。

## 类型路由

从 solution 文件的`类型决策`读取选定 type，然后加载：

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

如果选定 type 缺失或不支持，停止并提示用户回到 `$porter-codex-plugin:solution`。

`mvp` 不是 slice type。

## 执行规则

- 除非任务明确说明可独立执行，否则按 task 文件顺序执行。
- 开始新的 `[ ]` 任务前，先继续已有 `[~]` 任务。
- 没有可观察证据时，不得把任务标记为完成。
- 如果验证失败，保持任务未勾选或 `[~]`，记录限制或失败原因；除非下一步明显仍在任务范围内，否则停止等待用户确认。
- 对仅修改文档或配置的任务，结构审查、diff 审查、Markdown 围栏检查、JSON 校验或 skill frontmatter 校验可以作为证据。
- 对代码或可执行配置变更，运行任务中描述的相关测试、命令、lint、build、dry-run、benchmark 或手动验证。
- 不跳过 review；完成后始终转入 `$porter-codex-plugin:solution-review`。

## 收尾提示

执行完成后停止，并询问：

**"执行阶段已完成。还有要补充、调整或继续执行的任务吗？如果没有，请显式调用 `$porter-codex-plugin:solution-review` 做审查。"**
