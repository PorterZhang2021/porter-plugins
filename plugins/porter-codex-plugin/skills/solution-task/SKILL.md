---
name: solution-task
description: 从当前 Codex timeline 的 SOLUTION.md 生成新 solution workflow 的 TASK.md；用于用户确认 solution 后拆分任务，并进入 solution-execute 前的任务确认阶段
allowed-tools:
  - Bash
  - Read
  - Write
  - Glob
  - Grep
---

# Solution Task Workshop

从已确认的 `SOLUTION.md` 生成 `TASK.md`，作为新 solution workflow 的第二段：

```text
solution -> solution-task -> solution-execute -> solution-review
```

## 阶段边界（强制）

- 本 skill 只生成或更新当前分支对应的 `.codex/timeline/<branch-type>/<branch-name>/TASK.md`。
- 本 skill 只生成或更新当前分支对应的 `.codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json`。
- 不修改 `SOLUTION.md`。
- 不执行任务。
- 不执行 review。
- 不提交。
- 不合并、不 push、不 create PR。
- 即使用户说"顺便实现"、"直接执行"、"继续做"，也必须在任务清单生成后停止。

## 调用方式

唯一入口：

```text
$porter-codex-plugin:solution-task
```

## 前置条件

1. 确认 `AGENTS.md` 存在。
2. 确认 `.codex/constitution.md` 存在。
3. 确认当前不在 `main` / `master` 分支。
4. 读取当前分支名，必须符合 `<branch-type>/<branch-name>`。
5. 读取当前 timeline：

```text
.codex/timeline/<branch-type>/<branch-name>/SOLUTION.md
```

不读取旧 workflow 输入：

- 不读取 `plan/<type>/<branch-name>/PLAN.md`。
- 不读取 `plan/<type>/<branch-name>/ANALYSIS.md`。
- 不读取旧 `plan/` workflow state。

本阶段不引入 MVP 容器目录结构；多 slice 文件结构留到后续 MVP 容器阶段设计。

## SOLUTION.md Readiness Check

读取 `SOLUTION.md` 后必须检查：

- 存在 `Type Decision`。
- 存在 `Goal`。
- 存在 `Scope`。
- 存在 `Type-Specific Analysis`。
- 存在 `Acceptance`。
- 存在 `Confirmation`，或 `Confirmation Needed` 已在对话中明确解决。
- `Branch Rename Checkpoint` 不是待处理状态。

如果任一检查失败，停止，不写 `TASK.md`，提示用户回到 `$porter-codex-plugin:solution` 补充或确认。

## Type Detection

优先从 `SOLUTION.md` 的 `Type Decision` 读取 `Selected type`。

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

如果 selected type 缺失、无法识别，或与 `SOLUTION.md` 内容明显冲突，停止并提示先修正 `SOLUTION.md`。

## Reference Routing

根据 selected type 读取对应 reference：

| Type | Reference |
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

每个 reference 都说明：

- 从 `SOLUTION.md` 读取哪些字段。
- 生成哪些任务类型。
- 任务顺序要求。
- 验证方式。
- 什么时候可以标记"无业务逻辑，无需测试"。

reference 可以参考旧 `task/reference/*.md` 的任务节奏，但不得保留旧 `PLAN.md` / `ANALYSIS.md` / `plan/` 路径假设。

## TASK.md Structure

生成 `TASK.md` 时，先使用 `templates/task-header.md` 的结构，再按 type reference 生成任务。

任务规则：

- 所有任务必须使用 checkbox。
- 每个任务必须有 `验收标准` 和 `验证方式`。
- `验收标准` 必须能对应 `SOLUTION.md` 的 `Acceptance`，或明确说明这是结构审查、产物审查、基线采集等支撑性任务。
- `验证方式` 必须写出可观察证据，例如测试命令、失败/通过条件、产物路径、度量结果、结构审查项、diff review 或远端 pipeline 结果。
- 如果无法为任务写出验收标准或验证方式，停止并提示回到 `$porter-codex-plugin:solution` 补充验收。
- 有业务逻辑的实现任务必须先写测试任务。
- `feat` 中有可执行行为变化时，必须使用 Red / Green / Refactor；行为测试必须包含 Case / Given / When / Then / Assert 或 Verify。
- 无业务逻辑的 Markdown/JSON 配置任务可以写"无业务逻辑，无需测试；通过结构审查验证"。
- `build` 任务必须包含构建验证和产物验证；如果没有持久产物，必须记录原因并验证可观察输出。
- 不要生成实现内容，只生成任务清单。

## Type-Specific Rules

### feat

`feat` 任务在包含可执行行为变化时必须遵循 TDD：

1. Red: 先写行为测试，并确认测试因为目标行为缺失而失败。
2. Green: 写最小实现让行为测试通过。
3. Refactor: 在测试绿色后做结构清理，并再次验证测试通过。

行为测试必须包含：

- Case: 一句话说明行为场景。
- Given: 前置条件、状态、输入、fixture 或 mock。
- When: 用户操作、API 调用、命令或系统事件。
- Then: 预期行为。
- Assert / Verify: 具体断言、文件输出、状态变化、返回值、事件或可观察结果。

如果 feature 仅修改 Markdown/JSON 配置且无可执行行为，可以标注"无业务逻辑，无需测试；通过结构审查验证"。

即使是文档或配置型 feature，也必须为每个任务写明验收标准和验证方式。

### fix

`fix` 任务必须从复现测试开始。

固定顺序：

1. Task 1: 复现测试。
2. Task 2: 最小修复。
3. Task 3: 回归验证。

如果 `SOLUTION.md` 缺少复现步骤、根因分析或回归标准，停止并提示回到 solution 阶段补充。

如果执行复现时无法复现、失败原因不同，或复现结果推翻了根因分析，后续执行不应继续假定修复；应先进入 review 记录问题，再由 review 回修执行更新 `TASK.md`，必要时更新 `SOLUTION.md`。

### perf

`perf` 任务必须先度量，再优化，再验证。

固定顺序：

1. Task 1: 基线度量或基线采集计划。
2. Task 2: 瓶颈确认。
3. Task 3: 优化实现。
4. Task 4: 优化后验证。

如果没有基线数据或基线采集计划，不得生成优化实现任务。

如果执行基线或瓶颈确认时推翻了原优化方向，后续执行不应继续过期优化任务；应先进入 review 记录问题，再由 review 回修执行更新 `TASK.md`，必要时更新 `SOLUTION.md`。

## WORKFLOW_STATE.json

生成 `TASK.md` 后，同步写入：

```json
{
  "state": "awaiting_solution_execute",
  "current_skill": "$porter-codex-plugin:solution-task",
  "next_skill": "$porter-codex-plugin:solution-execute",
  "timeline": ".codex/timeline/<branch-type>/<branch-name>",
  "allowed_outputs": [
    ".codex/timeline/<branch-type>/<branch-name>/TASK.md",
    ".codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json"
  ]
}
```

## 收尾

生成 `TASK.md` 和 `WORKFLOW_STATE.json` 后停止，询问：

**"TASK.md 已生成。还有要补充、删除或调整的吗？如果没有，请显式调用 `$porter-codex-plugin:solution-execute` 开始执行。"**
