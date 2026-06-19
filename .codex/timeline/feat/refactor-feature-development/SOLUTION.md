# Solution: Define Solution Entry And SOLUTION.md

## Timeline Context

- Refactor stage overview: `.codex/timeline/mvp/workflow-architecture-refactor/STAGE_OVERVIEW.md`
- Stage 1 work overview: `.codex/timeline/mvp/workflow-architecture-refactor/MVP_OVERVIEW.md`
- Work slice: 001
- Slice type: `feat`
- Branch: `feat/refactor-feature-development`
- Timeline path: `.codex/timeline/feat/refactor-feature-development/`

## Goal

新增 `solution` 入口语义与统一的 `SOLUTION.md` 结构，让不同类型的小需求都能先产出同一种方案文档。`solution-task`、`solution-execute`、`solution-review` 属于 MVP 1 的后续 slice，共同形成内容最小闭环；Git delivery 生命周期则移到后续独立 MVP。

## Problem

我们需要构建一条独立的新 workflow，而不是继续在旧 `plan-*` / `analyze-bug` 链路上做重构。

新链路需要有自己的入口、模板、过程目录和状态文件。它唯一需要协同的前置能力是 Codex 项目初始化：

- `$porter-codex-plugin:constitution` 负责生成 `.codex/constitution.md`。
- `$porter-codex-plugin:codex-md` 负责生成根目录 `AGENTS.md`，并引用 `.codex/constitution.md`。

在此前提下，`solution` 作为新链路的第一个阶段，让所有小需求统一输出 `SOLUTION.md`。

## Proposed Workflow

MVP 1 的内容最小闭环是：

```text
solution
  -> solution-task
  -> solution-execute
  -> solution-review
```

当前 slice 只定义第一段。`solution` 只负责理解问题、整理背景、形成解决方案，并写入：

```text
.codex/timeline/<branch-type>/<branch-name>/SOLUTION.md
.codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json
```

`solution` 不生成 `TASK.md`，不执行实现，不做 review，不提交，不合并。

## Solution Entry Semantics

### Invocation

建议新增 skill：

```text
$porter-codex-plugin:solution
```

初版只覆盖 branch 串行场景，不覆盖 worktree 并行场景。

唯一调用方式：

```text
$porter-codex-plugin:solution <问题或目标描述>
```

用户不会先给 type。`solution` 进入 pre-solution discussion：先和用户讨论目标、候选 type、范围边界和方案方向；可以多轮澄清，也可以切换候选 type；不写入 `SOLUTION.md` 或 `WORKFLOW_STATE.json`。

当前阶段只要求正式写入时已有非 `main` / `master` 的开发分支。现有入口可以由旧 branch 能力创建；后续独立的 `delivery-branch` MVP 会接管 branch 创建、rename 和 timeline 路径同步。

type 不作为命令参数。用户发现候选 type 不对时，用自然语言纠偏，例如"这个应该是 docs"、"这个更像 fix"。正式写入仍然不负责创建或切换分支。pre-solution discussion 可以发生在创建开发分支之前。

### Branch Rules

`solution` 应读取当前分支名并提取：

```text
<branch-type>/<branch-name>
```

例如：

```text
feat/refactor-feature-development
```

对应 timeline 目录：

```text
.codex/timeline/feat/refactor-feature-development/
```

如果当前在 `master` / `main`，应停止并提示用户先创建业务分支。

讨论到目标、type、范围和最终描述都清楚后，如果用户说"好了，帮我写方案吧"、"可以开始写方案了"、"按这个落地方案"等写入意图，`solution` 才进入正式写入检查。如果当前分支 type 或命名不匹配最终方案，不直接改分支，也不阻塞 `SOLUTION.md` 写入；必须记录 `Branch Rename Checkpoint`，后续交给 `delivery-branch` 确认并执行。

### Pre-Solution Discussion Rules

`solution` 需要先完成前置讨论或 type 选择闸门：

1. 用户未给出 type 时，进入 pre-solution discussion。
2. pre-solution discussion 可以发生在创建开发分支之前。
3. pre-solution discussion 是自然对话，不要求每次回复都输出完整结构。
4. 只有在初步理解形成、候选 type 变化、范围边界变化、用户要求总结/确认/写方案、或需要建议创建/切换分支时，才输出 checkpoint 小结。
5. checkpoint 小结包含当前理解、候选 type、当前边界、实际参考模板、需要确认的问题和下一步。
6. 不要每次对话都读取或套用 `reference/<type>.md`；只有当某个 type 成为主候选、需要比较候选 type、或准备写方案时才读取。
7. 讨论过程中可以切换候选 type；切换时必须说明为什么旧候选不再合适。
8. 用户可以自然语言提出 type 倾向，例如"性能相关"、"文档相关"、"修复问题"；这不是命令参数，而是候选 type 信号。
9. 当用户提出 type 倾向时，把对应 type 提升为主候选或备选，并按需读取对应 `reference/<type>.md` 校准问题。
10. 如果发现需求包含多个目标，提示拆成多个 solution；如果范围明显变大，提示可能升级为 MVP。
11. pre-solution discussion 不写 timeline 文件。
12. 用户可以自然语言纠偏候选 type，纠偏后重新整理上下文。
13. 用户要求写方案时，先回放最终 type、目标、范围、最终描述和主要验收标准。
14. 如果 branch type 或命名与最终方案不一致，记录 rename 建议和原因；不自动改分支。

### Supported Types

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

`solution` 不新增 `mvp` Git type。MVP 容器能力还不属于 Stage 1 的实现范围，后续阶段单独处理。

### Required Inputs

`solution` 应优先读取：

- `AGENTS.md`
- `.codex/constitution.md`
- `README.md`
- 如果当前工作来自更高层规划：对应的 overview 文件

不存在的背景文件不阻断，但必须在 `SOLUTION.md` 中说明哪些上下文已读取、哪些缺失。

### Required Outputs

`solution` 必须写入：

```text
.codex/timeline/<branch-type>/<branch-name>/SOLUTION.md
.codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json
```

`WORKFLOW_STATE.json` 初始建议：

```json
{
  "state": "awaiting_solution_task",
  "current_skill": "$porter-codex-plugin:solution",
  "next_skill": "$porter-codex-plugin:solution-task",
  "timeline": ".codex/timeline/<branch-type>/<branch-name>",
  "branch_rename_checkpoint": {
    "rename_needed": false,
    "current_branch": "<branch-type>/<branch-name>",
    "suggested_branch": "<type>/<suggested-branch-name>",
    "next_skill": "$porter-codex-plugin:delivery-branch"
  },
  "allowed_outputs": [
    ".codex/timeline/<branch-type>/<branch-name>/SOLUTION.md",
    ".codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json"
  ]
}
```

## SOLUTION.md Structure

统一结构不从旧 `plan-branch/reference/*.md` 或 `analyze-bug` 迁移。

映射原则：

- `SOLUTION.md` 定义新链路的通用骨架。
- 每个 type 仍然需要独立 reference 模板。
- `fix` 作为分析型 reference，内建复现、根因定位和修复方案推导流程。
- `perf` 作为度量型 reference，内建基线度量、瓶颈分析和优化验证流程。
- 所有 reference 都服务于后续 `solution-task` 的统一读取。

### Common Template

通用模板建议如下：

```markdown
# Solution: <title>

## Timeline Context

- Branch: <branch-type>/<branch-name>
- Type: <type>
- Timeline path: .codex/timeline/<branch-type>/<branch-name>/
- Parent context: <optional higher-level overview path>

## Type Decision

- Discussion confirmed type: <type>
- User correction: <type | none>
- Branch type: <branch-type>
- Selected type: <type>
- Confidence: <high | medium | low>
- Reason: <为什么这个 type 合适>
- Alternatives considered: <其他候选 type；没有则写"无">

## Branch Rename Checkpoint

- Current branch: <branch-type>/<branch-name>
- Selected type: <type>
- Suggested branch: <type>/<suggested-branch-name>
- Rename needed: <yes | no>
- Reason: <为什么需要或不需要 rename>
- Delivery action: <如果需要，写 "$porter-codex-plugin:delivery-branch rename-check"；不需要则写"无">

## Goal

<本次 solution 要解决什么问题或达成什么目标>

## Problem

<现状、痛点、为什么要做>

## Context Read

- [x] AGENTS.md
- [x] .codex/constitution.md
- [x] README.md
- [ ] <missing or not applicable>

## Scope

### In

- <本次做什么>

### Out

- <本次不做什么>

## Type-Specific Analysis

<从对应 reference/<type>.md 生成>

## Visual Model

<当 reference/<type>.md 要求或建议时，用 Mermaid 描述流程、结构、调用顺序或验证链路；不适用则写"无图，原因：...">

## Proposed Changes

- <计划新增或修改什么文件/配置/文档>

## Acceptance

- <验收标准>

## Risks

- <风险、兼容性、需要用户确认的点>

## Confirmation Needed

- <需要用户确认的范围、取舍、命名、风险或验收问题>

## Next Step

请先确认 `Confirmation Needed`。如果本 solution 无需调整，请显式调用 `$porter-codex-plugin:solution-task`。
```

## Type-Specific Required Fields

`solution` 应保留类似旧 `plan-branch/reference/*.md` 的模板组织方式：

```text
plugins/porter-codex-plugin/skills/solution/reference/
  feat.md
  fix.md
  refactor.md
  perf.md
  test.md
  docs.md
  build.md
  ci.md
  chore.md
  style.md
```

每个 `reference/<type>.md` 负责说明：

- 该 type 在 `SOLUTION.md` 的 `Type-Specific Analysis` 中必须包含哪些字段。
- 该 type 在 `SOLUTION.md` 的 `Visual Model` 中是否必须、建议或可选使用 Mermaid。
- 该 type 的验收标准应该如何表达。
- 后续 `solution-task` 应该选择哪类任务模板。

### Pre-Solution Type Signals

pre-solution discussion 讨论候选 type 时参考以下信号：

| Type | 常见信号 |
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

本节定义新 solution 体系自己的 reference 模板。旧 `plan-*` / `analyze-bug` 可以作为人工理解历史背景，但不作为新模板的依赖来源。

### feat

必须包含：

- 功能目标：一句话描述这个功能解决什么问题。
- 用户价值：谁会使用，完成后获得什么能力。
- 功能边界：做什么 / 不做什么。
- 方案设计：核心设计、模块关系、关键流程。
- 目录结构：新增或修改的文件清单。
- 接口或配置：API、命令、配置项或对外入口；没有则写"无"。
- 数据流：核心流程的数据流向；无数据流则写"无"。
- 实现顺序：基于依赖关系排列模块顺序。
- Visual Model：默认需要 Mermaid，优先用 `flowchart` 表达功能流程、状态流转或数据流；涉及角色、服务、API 或异步顺序时用 `sequenceDiagram`。

### fix

`fix` 是 `solution` 中的特殊分析型 reference，不是普通规划型 reference。

其他 type 通常是：

```text
理解目标 -> 设计方案 -> 验收标准 -> SOLUTION.md
```

`fix` 必须是：

```text
收集现象 -> 复现问题 -> 定位根因 -> 提出修复方案 -> 回归标准 -> SOLUTION.md
```

也就是说，`solution/reference/fix.md` 内部自带复现与根因分析流程。用户不需要在新链路中单独调用 `analyze-bug`。

必须包含：

- Bug 描述：现象、触发条件、影响范围。
- 复现步骤：最小复现路径、输入数据或操作序列。
- 预期 vs 实际：明确正确行为与当前错误行为。
- 根因分析：触发条件、问题位置、原因详解。
- 修复方案：拟修改的文件和逻辑，说明为什么能解决问题。
- 回归测试：至少包含一个能复现 Bug 的测试用例。
- 影响范围：本次修复可能影响哪些功能。
- Visual Model：通常需要 Mermaid，优先用 `flowchart` 表达触发条件、错误路径、根因和修复点；多组件调用或异步问题可用 `sequenceDiagram`。

`fix` 不再单独输出 `ANALYSIS.md`，而是把旧 bug analysis 的核心内容纳入 `SOLUTION.md`。

如果复现信息不足，`solution type=fix` 应暂停并向用户索取：

- 错误日志或堆栈跟踪。
- 复现步骤。
- 预期行为 vs 实际行为。
- 相关代码位置，如果用户已知。

如果可以自行复现，则记录复现命令、关键输出和复现结果。若复现失败，也必须在 `SOLUTION.md` 中记录复现障碍，不要跳过根因分析假装成功。

### refactor

必须包含：

- 重构目标：当前问题是什么，重构后期望达到什么状态。
- 影响范围：涉及的模块、文件、接口。
- 重构策略：分步拆解，每步保持测试绿色。
- 回归测试策略：现有测试是否覆盖，需要补充什么。
- 不变约束：重构前后对外行为必须一致的部分。
- Visual Model：建议用 `flowchart` 表达重构前后的模块关系；对象模型或类型关系可用 `classDiagram`。

### perf

`perf` 是 `solution` 中的特殊度量型 reference，不是普通规划型 reference。

普通 type 可以从目标直接进入方案设计；`perf` 必须先建立可验证的性能路径：

```text
性能目标或瓶颈线索 -> 建立度量方式 -> 记录基线或采集计划 -> 分析瓶颈 -> 优化方案 -> 验证标准 -> SOLUTION.md
```

必须包含：

- 性能问题：当前瓶颈在哪，如何度量，是否有基准数据。
- 优化方案：拟采取的优化手段。
- 验证方式：如何量化改善效果，例如 benchmark 或 profiling。
- 回归风险：可能影响的功能。
- Visual Model：需要 Mermaid 表达度量链路，优先用 `flowchart` 表达 baseline -> bottleneck -> optimization -> verification；请求链路或多服务耗时可补 `sequenceDiagram`。

如果信息不足，`solution type=perf` 应暂停并向用户索取：

- 性能问题发生在哪个流程或命令。
- 当前可感知的慢点、资源消耗或失败表现。
- 数据规模、输入样本或运行环境。
- 期望目标或可接受阈值。
- 是否已有 benchmark、profiling 或日志数据。

如果可以自行度量，则记录度量命令、环境、数据规模、优化前基线和关键瓶颈现象。若不能运行度量，必须写明基线采集计划，不得直接跳到优化实现。

### test

必须包含：

- 测试目标：补充哪个模块或场景的测试，当前覆盖缺口在哪。
- 测试类型：单元测试 / 集成测试 / 端到端测试。
- 用例设计：正常路径、边界条件、异常路径。
- Mock 策略：哪些外部依赖需要 Mock，如何 Mock。
- Visual Model：可选；流程测试用 `flowchart`，多组件交互测试用 `sequenceDiagram`。

### docs

必须包含：

- 文档目标：面向谁，解决什么信息缺口。
- 文档结构：章节大纲。
- 内容来源：参考哪些现有代码、文档、设计。
- Visual Model：可选；流程说明用 `flowchart`，信息结构说明可用 `flowchart` 或 `mindmap`。

### build

必须包含：

- 变更内容：修改哪个构建工具或配置。
- 变更原因：解决什么构建问题或优化目标。
- 验证方式：如何确认构建正常。
- Visual Model：建议用 `flowchart` 表达构建输入、步骤和产物。

### ci

必须包含：

- 变更内容：修改哪个 pipeline / workflow / 部署脚本。
- 变更原因：解决什么 CI 问题或新增什么自动化能力。
- 验证方式：如何在不破坏现有流水线的前提下验证。
- Visual Model：建议用 `flowchart` 表达触发、job 顺序、失败分支和发布边界；多系统部署可补 `sequenceDiagram`。

### chore

必须包含：

- 变更内容：具体要做什么，例如升级依赖、调整配置、清理代码。
- 风险评估：可能影响哪些功能。
- 回滚方案：出问题如何恢复。
- Visual Model：可选；影响 workflow、目录迁移或多文件关系时建议用 `flowchart`。

### style

必须包含：

- 目标：整理哪些风格问题，例如格式化、命名、lint 规则。
- 工具：使用哪些格式化工具及配置。
- 影响范围：涉及哪些文件或目录。
- Visual Model：可选；涉及格式化管线或 lint 流程时建议用 `flowchart`。

## Task Template Relationship

`SOLUTION.md` 不直接复制 `task-branch/reference/*.md` 的任务格式，但它必须保留足够信息，让后续 `solution-task` 可以选择对应任务模板：

- `feat`：有业务逻辑的模块需要测试先行；无业务逻辑的模块注明无需测试。
- `fix`：第一个任务必须是复现 Bug 的失败测试。
- `refactor`：每步重构必须保持测试绿色。
- `perf`：先度量，再优化，再验证。
- `test`：只生成测试任务，不生成实现任务。
- `docs`：生成写作任务，无需测试。
- `build` / `ci` / `style`：通常无业务逻辑，通过构建、pipeline、lint 或 diff 验证。
- `chore`：视复杂度决定是否需要测试。

## Scope

### In

- 新增独立 `solution` 入口的阶段语义。
- 默认入口不要求用户先给 type；type 由 discussion 产生，用户可用自然语言纠偏。
- 用户可用自然语言提出 type 倾向，例如"性能相关"；`solution` 按需读取对应 reference 并引导补充该 type 需要确认的信息。
- 支持未传 type 时进入 pre-solution discussion，允许多轮讨论、切换候选 type、重新套用 type 模板，并在确认后再写文件。
- 定义 pre-solution discussion 的 checkpoint 输出节奏，避免每次对话都模板化。
- 定义 `SOLUTION.md` 的统一结构。
- 定义 `solution/reference/*.md`，让每个 type 都有独立模板。
- 定义 `Visual Model` 段落，让不同 type 能按需要输出 Mermaid 流程图、时序图、类图或信息结构图。
- 定义 `solution` 阶段的输出文件和状态。
- 定义 `Branch Rename Checkpoint`，让 solution 落地后能把分支命名修正交给后续 `delivery-branch`。
- 明确 `solution` 的前置协同只依赖 `.codex/constitution.md` 与根目录 `AGENTS.md`。

### Out

- 不实现 `solution-task`。
- 不实现 `solution-execute`。
- 不实现 `solution-review`。
- 不实现 `delivery-branch`、`delivery-commit`、`delivery-merge-to-base`、`delivery-push`、`delivery-create-pr`。
- 不删除旧 `plan-*` / `analyze-bug`。
- 不处理 worktree 并行模式。
- 不处理 MVP 容器阶段。

## Proposed Changes

后续 task 阶段可围绕以下文件拆分：

- 新增 `plugins/porter-codex-plugin/skills/solution/SKILL.md`
- 新增 `plugins/porter-codex-plugin/skills/solution/reference/*.md`
- 默认入口必须进入 pre-solution discussion；讨论阶段不写 `.codex/timeline/`。
- pre-solution discussion 普通澄清阶段保持自然对话，只在关键节点输出 checkpoint 小结。
- `reference/<type>.md` 按需读取，不在每次对话中重复套用。
- 用户提出 type 倾向时，`solution` 可以读取对应 `reference/<type>.md` 并引导 type-specific 确认问题。
- 用户表达"可以开始写方案了"、"按这个落地方案"等写入意图时，先进入正式写入前 checkpoint。
- 正式写入时，`solution` 必须先完成 `Type Decision`，记录 discussion-confirmed type、用户自然语言纠偏、branch type、最终 selected type、置信度、理由和备选项。
- 正式写入时，如果当前分支 type 或命名与最终方案不一致，写入 `Branch Rename Checkpoint`，提示后续由 `delivery-branch` 确认并执行。
- `solution/reference/fix.md` 必须内建复现与根因分析流程。
- `solution/reference/*.md` 必须定义 `Visual Model` 写法，`feat` 默认需要 Mermaid，`fix` / `perf` / `refactor` / `build` / `ci` 需要或建议使用，`test` / `docs` / `chore` / `style` 按场景可选。
- 后续更新 `README.md`，说明新 solution 链路。
- 后续通过独立 chore slice 审计 `constitution` / `codex-md` 是否仍与 `.codex/constitution.md` 和 `.codex/timeline/` 约定一致；如发现错误再拆 fix。

## Acceptance

- `solution` 的职责边界清楚：只产出 `SOLUTION.md` 和 `WORKFLOW_STATE.json`。
- 默认使用方式是用户不传 type，先完成 pre-solution discussion。
- 用户用自然语言纠偏 type 时，`solution` 重新整理候选 type、边界和上下文。
- 用户用自然语言提出 type 倾向时，`solution` 将其作为候选 type 信号，而不是命令参数。
- 用户未传入 type 时，`solution` 进入 pre-solution discussion，可以多轮澄清、切换候选 type、重新参考不同 type 模板，不直接写文件。
- pre-solution discussion 不会每次回复都强制输出完整模板；只在关键节点输出 checkpoint。
- `SOLUTION.md` 结构能覆盖 `feat`、`fix`、`refactor`、`perf`、`test`、`docs`、`build`、`ci`、`chore`、`style`。
- `SOLUTION.md` 必须包含 `Type Decision`，记录 type 选择依据。
- `solution/reference/*.md` 为每个 type 提供独立模板。
- `SOLUTION.md` 必须包含 `Confirmation Needed`，让用户在进入 task 前确认范围、取舍、风险和验收。
- `SOLUTION.md` 必须包含 `Visual Model`，并按 reference 决定是否输出 Mermaid 或明确无图原因。
- `fix` 的复现、根因、修复方案能被纳入 `SOLUTION.md`。
- 新链路中 `fix` 的方式是 discussion 确认最终 type 为 `fix` 后，把复现和根因分析写入 `SOLUTION.md`，不再额外调用 `analyze-bug`；如果当前分支不是 `fix/<branch-name>`，写入 rename checkpoint。
- 新链路初始使用 `.codex/timeline/<branch-type>/<branch-name>/`，不使用旧 `plan/<type>/<branch-name>/`；如后续 rename，交给 `delivery-branch` 同步到最终 timeline 路径。
- 旧 `plan-*` / `analyze-bug` 不参与本 slice；不删除，也不作为新链路依赖。
- 下一步能根据情况进入 `delivery-branch` rename checkpoint 或 `solution-task`。

## Risks

- 如果 `solution` 一次覆盖所有 type，文档可能偏长；可以用统一结构 + type-specific section 平衡。
- `WORKFLOW_STATE.json` 的 state 命名需要后续和 hook guard 对齐，当前先作为方案建议。
- 新 solution 体系依赖 `.codex` 路径约定稳定；需要通过后续 chore/test slice 校验初始化类 skill 没有遗留 `.claude/constitution.md` 引用。
- `fix` 的分析流程比普通规划流程更重；如果实现时只按字段模板生成，会丢失复现与根因定位的核心价值。
- `perf` 的度量流程比普通规划流程更重；如果没有基线数据或采集计划就直接优化，会无法证明优化有效。
- Mermaid 图如果被当成装饰，会增加维护成本；必须服务于确认流程、结构、调用顺序或验证链路。
- 如果缺少 `Confirmation Needed`，solution 阶段会失去结对确认点，容易过早进入 task。
- 如果未传 type 时直接写文件，会违背显式确认原则；必须先进入 pre-solution discussion，等目标、type、边界和最终描述确认后再写。
- 如果把 type 作为命令参数，会让用户过早承担分类成本；正常路径必须先讨论，再由 Codex 提出候选 type 供用户确认或纠偏。
- 如果 solution 直接自动改分支名，会把内容决策和 Git 生命周期绑死；本 slice 只生成 checkpoint，实际 rename 留给 delivery 线。

## Open Questions

- `solution` 是否需要同时支持普通 branch 和未来更高层容器中的 work slice，还是通过 `Parent context` 字段自然复用。
- `delivery-branch` MVP 是否应把 branch rename 和 timeline 目录迁移作为同一个确认动作处理。
- `solution` frontmatter 的 description 是否应该明确写“新 solution workflow 入口”以区分旧 `plan`。
- `constitution` / `codex-md` 的路径审计如果发现不一致，应该作为本 MVP 的 fix slice 处理，还是归入初始化 workflow 的独立 MVP。
- discussion-confirmed type 为 `fix` 时，是否需要保留可委托子代理/子任务的分析步骤，还是先在当前对话中完成复现与根因定位。
- discussion-confirmed type 为 `perf` 时，是否需要支持自动运行 benchmark/profiling，还是先只要求记录可执行的基线采集计划。
- `Confirmation Needed` 是否需要根据不同 reference 固定最少确认项，还是允许按场景动态生成。
- `Visual Model` 是否需要在后续 `solution-task` 中成为生成任务前的强校验项。
- pre-solution discussion 是否需要未来单独落临时讨论记录，还是继续保持只在对话中完成。

## Next Step

如果本 solution 方向确认无误，下一步进入 `solution-task`，把本文件拆成可执行任务清单。
