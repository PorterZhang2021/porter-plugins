---
name: solution-task
description: 从 active slice 的 solution 文件生成 task 文件，并更新对应 slice state；优先使用 current.json 和 active state gate，不要求分支命名格式
allowed-tools:
  - Bash
  - Read
  - Write
  - Glob
  - Grep
---

# Solution Task 任务工作坊

从已确认的 solution 文件生成 task 文件，作为 solution workflow 的第二段：

```text
solution -> solution-task -> solution-execute -> solution-review
```

## 阶段边界（强制）

- 本 skill 只生成或更新 active slice 的 task 文件。
- 本 skill 只生成或更新 active slice 的 state 文件。
- 本 skill 可以保持 `current.json` 指向同一个 active slice。
- 不修改 solution 文件。
- 不执行任务。
- 不执行 review。
- 不提交、不合并、不 push、不 create PR。
- 即使用户说"顺便实现"、"直接执行"、"继续做"，也必须在任务清单生成后停止。

新 slice 的主输出路径是：

```text
.codex/timeline/<timeline-name>/tasks/<slice-id>-<type>-<slug>.md
.codex/timeline/<timeline-name>/states/<slice-id>-<type>-<slug>.json
.codex/timeline/<timeline-name>/current.json
```

## 调用方式

唯一入口：

```text
$porter-codex-plugin:solution-task
```

## Protected Branch Guard

执行前必须检查当前 Git 分支。

- 如果当前分支是 `main` 或 `master`，停止，不写 task 或 state，提示用户先自行切换到开发分支或使用 Codex 原生 Git 能力创建工作上下文。
- 不要求分支名符合 `<type>/<name>`。
- 不要求分支 type 等于 slice type。
- 不要求存在 `branch.<branch>.porter-base`。

## Solution Branch Alignment Hook

`solution-task` 写入 task 文件前，会触发 Codex `PreToolUse` hook：

- hook 脚本：`plugins/porter-codex-plugin/hooks/solution-branch-guard.sh`。
- 触发条件：active slice state 是 `awaiting_solution_task`，且即将写入该 active slice 的 task 文件。
- 为避免和 `solution` 阶段重复，hook 不因 state 文件或 `current.json` 写入触发。
- 目标分支名：从 active slice id 推导为 `<type>/<solution-slug>`，例如 `002-refactor-solution-git-integration` 对应 `refactor/solution-git-integration`。
- 如果当前分支已经等于目标分支名，hook 不做任何事。
- 如果当前分支是 `main` / `master`、detached、目标分支已存在，或当前分支已有 upstream 配置，hook 停止并提示人工处理。
- hook 只执行本地 `git branch -m`，不 push、不改远端、不处理 PR、不写 solution/task/state 文件。

本 skill 执行前仍必须做 protected branch guard；hook 是分支命名对齐，不是分支创建、push、PR 或 merge workflow。

## 路径解析

`solution-task` 不创建新 slice id，只消费 active slice。

timeline name 解析顺序：

1. 如果本轮对话中用户明确确认了 timeline name，使用该名称。
2. 如果当前分支不是 `main` / `master`，可以把分支名第一段 `/` 之后的部分作为默认 timeline name；没有 `/` 时，可以把整个分支名作为默认 timeline name。
3. 如果默认 `.codex/timeline/<timeline-name>/current.json` 不存在，可以扫描 `.codex/timeline/*/current.json`。
4. 只有当恰好一个 `current.json` 指向的 state 允许进入 `$porter-codex-plugin:solution-task` 时，才使用该 timeline。
5. 如果没有匹配或存在多个匹配，停止并请用户明确 timeline name。

执行前按顺序判断：

1. 如果 `.codex/timeline/<timeline-name>/current.json` 存在，必须优先读取它。
2. 从 `current.json` 读取：
   - `timeline`
   - `active_slice`
   - `solution`
   - `task`
   - `review`
   - `state`
3. 读取 `state` 指向的 `states/<slice>.json`，确认当前 state 允许进入 `$porter-codex-plugin:solution-task`。
4. 新 slice 创建必须使用新路径，并且只能由 `$porter-codex-plugin:solution` 创建。

## 前置条件

1. 确认 `AGENTS.md` 存在。
2. 确认 `.codex/constitution.md` 存在。
3. 执行 protected branch guard。
4. 确认 Codex hook 已能在写入 task 文件前执行分支命名对齐；如果 hook 报告目标分支已存在或 upstream 风险，停止并让用户人工确认。
5. 通过 `current.json` 解析 active slice。
6. 读取 active slice 的 solution 文件。
7. 读取 active slice 的 state 文件。

不要读取旧 workflow 输入：

- 不读取 `plan/<type>/<branch-name>/PLAN.md`。
- 不读取 `plan/<type>/<branch-name>/ANALYSIS.md`。
- 不读取旧 `plan/` workflow state。

## current.json

`current.json` 是 active slice 指针，不承载完整 workflow state。

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

读取 active slice 的 state 文件。

允许状态：

- `awaiting_solution_task`

如果 state 缺失或不是 `awaiting_solution_task`，停止并提示用户显式调用 state 中记录的 `next_skill`。

## SOLUTION.md 就绪检查

读取 active slice 的 solution 文件后必须检查：

- 存在`时间线上下文`。
- 存在`类型决策`。
- 存在`工作上下文`。
- 存在`目标`。
- 存在`范围`。
- 存在`类型专项分析`。
- 存在`验收标准`。
- 存在`待确认`，或待确认事项已在对话中明确解决。

如果任一检查失败，停止，不写 task 文件，提示用户回到 `$porter-codex-plugin:solution` 补充或确认。

## 类型识别

优先从 solution 文件的`类型决策`读取选定 type。

支持类型：

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

`mvp` 不是 slice type。

如果选定 type 缺失、无法识别，或与 solution 内容明显冲突，停止并提示先修正 solution 文件。

## 参考文件路由

根据选定 type 读取对应 reference：

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

reference 可以参考旧 `task/reference/*.md` 的任务节奏，但不得保留旧 `PLAN.md` / `ANALYSIS.md` / `plan/` 路径假设。

## TASK.md 结构

生成 task 文件时，先使用 `templates/task-header.md` 的结构，再按 type reference 生成任务。

任务规则：

- 所有任务必须使用 checkbox。
- 每个任务必须有 `验收标准` 和 `验证方式`。
- `验收标准` 必须能对应 solution 文件的`验收标准`章节，或明确说明这是结构审查、产物审查、基线采集等支撑性任务。
- `验证方式` 必须写出可观察证据，例如测试命令、失败/通过条件、产物路径、度量结果、结构审查项、diff review 或远端 pipeline 结果。
- 如果无法为任务写出验收标准或验证方式，停止并提示回到 `$porter-codex-plugin:solution` 补充验收。
- 有业务逻辑的实现任务必须先写测试任务。
- `feat` 中有可执行行为变化时，必须使用 Red / Green / Refactor。
- 无业务逻辑的 Markdown/JSON 配置任务可以写"无业务逻辑，无需测试；通过结构审查验证"。

## 类型专属规则

### feat

有可执行行为变化时必须遵循 TDD：

1. Red: 先写行为测试，并确认测试因为目标行为缺失而失败。
2. Green: 写最小实现让行为测试通过。
3. Refactor: 在测试绿色后做结构清理，并再次验证测试通过。

如果 feature 仅修改 Markdown/JSON 配置且无可执行行为，可以标注"无业务逻辑，无需测试；通过结构审查验证"。

### fix

`fix` 任务必须从复现测试开始。

固定顺序：

1. 任务 1：复现测试。
2. 任务 2：最小修复。
3. 任务 3：回归验证。

如果 solution 文件缺少复现步骤、根因分析或回归标准，停止并提示回到 solution 阶段补充。

### perf

`perf` 任务必须先度量，再优化，再验证。

固定顺序：

1. 任务 1：基线度量或基线采集计划。
2. 任务 2：瓶颈确认。
3. 任务 3：优化实现。
4. 任务 4：优化后验证。

如果没有基线数据或基线采集计划，不得生成优化实现任务。

## 状态输出

生成 task 文件后，同步写入 active slice state：

```json
{
  "state": "awaiting_solution_execute",
  "current_skill": "$porter-codex-plugin:solution-task",
  "next_skill": "$porter-codex-plugin:solution-execute",
  "timeline": ".codex/timeline/<timeline-name>",
  "active_slice": "<slice-id>-<type>-<slug>",
  "solution": ".codex/timeline/<timeline-name>/solutions/<slice-id>-<type>-<slug>.md",
  "task": ".codex/timeline/<timeline-name>/tasks/<slice-id>-<type>-<slug>.md",
  "review": ".codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md",
  "allowed_outputs": [
    ".codex/timeline/<timeline-name>/tasks/<slice-id>-<type>-<slug>.md",
    ".codex/timeline/<timeline-name>/states/<slice-id>-<type>-<slug>.json",
    ".codex/timeline/<timeline-name>/current.json"
  ]
}
```

## 收尾

生成 task 文件和 `states/<slice>.json` 后停止，询问：

**"TASK 已生成。还有要补充、删除或调整的吗？如果没有，请显式调用 `$porter-codex-plugin:solution-execute` 开始执行。"**
