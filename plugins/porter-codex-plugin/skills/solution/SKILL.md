---
name: solution
description: 默认通过 pre-solution discussion 与用户澄清需求、候选类型和边界；用户确认后基于讨论结论和当前开发分支生成 solution 阶段方案文档，并在分支名不准确时提示 delivery-branch rename checkpoint
allowed-tools:
  - Bash
  - Read
  - Write
  - Glob
  - Grep
---

# Solution Workshop

通过前置讨论澄清需求，并在用户确认后基于当前普通 Git branch 生成新 solution workflow 的方案文档。

## 阶段边界（强制）

- 本 skill 只生成或更新当前分支对应的 `.codex/timeline/<branch-type>/<branch-name>/SOLUTION.md`。
- 本 skill 只生成或更新当前分支对应的 `.codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json`。
- 不生成 `TASK.md`。
- 不执行实现。
- 不执行 review。
- 不提交。
- 不合并。
- 即使用户说"继续做"、"顺便拆任务"、"直接实现"，也必须在 solution 完成后停止。

## 调用方式

唯一入口：

```text
$porter-codex-plugin:solution <问题或目标描述>
```

示例：

```text
$porter-codex-plugin:solution "我想补充新 workflow 的使用说明，但不确定算 docs 还是 feat"
```

上面进入 pre-solution discussion，只讨论，不写文件。

用户不需要先提供 type。type 只能来自讨论结论或用户自然语言纠偏，不作为命令参数。

正式写入由用户在讨论后用自然语言触发，例如：

```text
好了，帮我写方案吧
可以开始写方案了
按这个落地方案
确认，写方案
```

正式写入前必须已有确认过的 type、目标、范围和最终描述，并且当前分支必须是非 `main` / `master` 的开发分支。若当前分支 type 或命名与最终方案不一致，不自动改名；写入 branch rename checkpoint，后续交给 `$porter-codex-plugin:delivery-branch` 确认并执行。

## Pre-Solution Discussion（强制）

当用户未显式传入 type 时，必须进入前置讨论模式。

前置讨论模式：

- 不要求当前分支已经匹配最终 type。
- 可以发生在创建开发分支前。
- 可以读取 `AGENTS.md`、`.codex/constitution.md`、`README.md` 和必要上下文。
- 可以根据讨论临时读取一个或多个 `reference/<type>.md`，帮助重新整理问题。
- 可以在讨论中切换候选 type。
- 用户可以用自然语言纠偏，例如"这个应该是 docs"、"这个更像 fix"；纠偏后必须重新整理候选 type 和边界。
- 用户可以用自然语言提出 type 倾向，例如"这个是性能相关的"、"这个像文档"、"这可能是修复问题"；这不是命令参数，只作为候选 type 信号。
- 当用户提出 type 倾向时，把对应 type 提升为主候选或备选，并按需读取对应 `reference/<type>.md` 校准问题。
- 如果发现需求包含多个目标，提示拆成多个 solution；如果范围明显变大，提示可能升级为 MVP。
- 不写入 `.codex/timeline/`。
- 不写入 `SOLUTION.md`。
- 不写入 `WORKFLOW_STATE.json`。

前置讨论输出节奏：

- 不要每次回复都完整套用结构化输出。
- 普通澄清阶段保持自然对话，只问当前最关键的问题。
- 只有在关键节点输出 checkpoint 小结：
  - 初步理解已经形成。
  - 候选 type 发生变化。
  - 范围边界发生变化。
  - 用户提出 type 倾向或纠偏。
  - 用户要求总结、确认或写方案。
  - 需要建议创建或切换分支。
- checkpoint 小结包含：
  - 我的理解：当前目标、背景和限制。
  - 候选类型：主候选 type、备选 type、判断理由。
  - 当前边界：可能做什么、不做什么。
  - 已参考模板：本轮实际读取或套用过哪些 `reference/<type>.md`；没有则省略。
  - 需要确认：继续推进前需要用户确认的问题。
  - 下一步：继续讨论、确认 type、建议创建分支，或在用户要求写方案且当前分支可用于记录 timeline 时写入 `SOLUTION.md`。

模板读取规则：

- 不要每次对话都读取或套用 `reference/<type>.md`。
- 只有当某个 type 成为主候选、用户明确提出 type 倾向、需要比较两个候选 type、或准备写方案时，才读取对应 reference。
- 如果讨论中发现候选 type 不对，重新读取新的 `reference/<type>.md` 并整理差异。

type 倾向示例：

- 用户说"性能相关"、"慢"、"耗时"时，将 `perf` 作为主候选，并检查是否需要补充性能目标、度量方式、基线或采集计划。
- 用户说"文档相关"、"说明"、"README" 时，将 `docs` 作为主候选，并检查目标读者、文档结构和内容来源。
- 用户说"修复"、"错误"、"不符合预期"时，将 `fix` 作为主候选，并检查现象、复现路径、预期 vs 实际和回归标准。
- 用户说"补测试"、"覆盖"时，将 `test` 作为主候选，并检查覆盖缺口、测试类型和用例设计。

只有当用户明确确认 type、目标、范围和最终描述后，才能进入正式写入阶段。若用户确认后发现不对，应回到 pre-solution discussion，按新的 type 或边界重新整理。

## 正式写入确认（强制）

1. 如果用户还在描述需求，继续执行 Pre-Solution Discussion，不写文件。
2. 如果用户表达"好了，帮我写方案吧"、"确认，写方案"等写入意图，先回放讨论结论。
3. 回放内容必须包含最终 type、目标、范围、最终描述、主要验收标准和是否需要拆分。
4. 如果用户尚未确认 type、目标、范围或最终描述，继续讨论，不写文件。
5. 正式写入前必须校验当前分支不是 `main` / `master`，且可解析为 `<branch-type>/<branch-name>`。
6. 正式写入前必须根据讨论内容和项目上下文再次判断最终 type 是否语义合理。
7. 如果明显更像另一个 type，停止，不写文件，回到 pre-solution discussion，让用户确认是否切换 type 或拆分 solution。
8. 如果当前分支 type 或命名与最终 type、目标描述不一致，不阻塞 `SOLUTION.md` 写入；必须写入 `Branch Rename Checkpoint`，提示后续由 `$porter-codex-plugin:delivery-branch` 确认并执行 rename。

## 类型推荐参考

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

如果描述同时命中多个 type，优先选择最能决定后续验证方式的 type，并把其他候选写进讨论结论。

如果讨论过程中 type 发生变化，应重新套用新的 `reference/<type>.md` 整理上下文，并明确说明前一次候选为什么被替换。

## 前置条件（写文件前）

1. 必须已有可执行 type：用户在 pre-solution discussion 中已确认最终 type。
2. 确认当前不在 `main` / `master` 分支。
3. 读取当前分支名，必须符合 `<branch-type>/<branch-name>`。
4. 如果 discussion-confirmed type 与当前分支前缀不一致，不停止写入；记录冲突原因、建议分支名和 rename 风险，不自动改分支、不自动改 type。
5. 优先读取项目上下文：
   - `AGENTS.md`
   - `.codex/constitution.md`
   - `README.md`
   - 可选 parent context overview
6. 若 `.codex/constitution.md` 或 `AGENTS.md` 缺失，提示用户先运行 `$porter-codex-plugin:constitution` 或 `$porter-codex-plugin:codex-md`。

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

`solution` 不新增 `mvp` Git type。MVP 容器能力不属于本阶段。

## 输出路径

根据当前分支 `<branch-type>/<branch-name>` 写入初始 timeline：

```text
.codex/timeline/<branch-type>/<branch-name>/SOLUTION.md
.codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json
```

如果最终 selected type 或建议命名不同，`SOLUTION.md` 必须记录建议的目标路径。后续由 `delivery-branch` 在用户确认后同步分支名和 timeline 路径。

## 执行规则

1. 先执行类型解析。
2. 如果没有已确认的讨论结论，进入 pre-solution discussion 后停止，不写文件。
3. 如果当前分支不是可记录 timeline 的开发分支，输出冲突说明后停止，不写文件。
4. 如果最终 type 与语义判断明显冲突，回到 pre-solution discussion 后停止，不写文件。
5. 根据已确认 `<type>` 读取 `reference/<type>.md`。
6. 按通用骨架生成 `SOLUTION.md`。
7. 用 `reference/<type>.md` 填充 `Type-Specific Analysis`。
8. 必须在 `SOLUTION.md` 中写入 `Type Decision`。
9. 必须在 `SOLUTION.md` 中写入 `Branch Rename Checkpoint`。
10. 必须在 `SOLUTION.md` 中写入 `Confirmation Needed`。
11. 写入 `WORKFLOW_STATE.json`，状态为 `awaiting_solution_task`。
12. 停止，要求用户先确认 `Confirmation Needed`；如果存在 rename 建议，提示先由 `$porter-codex-plugin:delivery-branch` 处理 rename checkpoint；如果无调整且无需 rename，再提示显式调用 `$porter-codex-plugin:solution-task`。

## 通用 SOLUTION.md 骨架

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

- [ ] AGENTS.md
- [ ] .codex/constitution.md
- [ ] README.md
- [ ] <optional parent context>

## Scope

### In

- <本次做什么>

### Out

- <本次不做什么>

## Type-Specific Analysis

<从 reference/<type>.md 生成>

## Visual Model

<当 reference/<type>.md 要求或建议时，用 Mermaid 描述流程、结构、调用顺序或验证链路；不适用则写"无">

## Proposed Changes

- <计划新增或修改什么文件/配置/文档>

## Acceptance

- <验收标准>

## Risks

- <风险、兼容性、需要用户确认的点>

## Confirmation Needed

- <需要用户确认的范围、取舍、命名、风险或验收问题>

## Next Step

请先确认 `Confirmation Needed`。如果存在 Branch Rename Checkpoint，请先显式调用 `$porter-codex-plugin:delivery-branch`；如果无需调整且无需 rename，请显式调用 `$porter-codex-plugin:solution-task`。
```

## WORKFLOW_STATE.json

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

## 类型模板

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

## fix 特殊规则

`fix` 是分析型 reference。当 discussion-confirmed type 为 `fix` 时，必须完成复现与根因分析流程，并把结果写入 `SOLUTION.md`。

如果信息不足，暂停并向用户索取错误日志、复现步骤、预期行为 vs 实际行为、相关代码位置。

新 solution workflow 中不额外调用 `$porter-codex-plugin:analyze-bug`。

## 确认规则

每次生成 `SOLUTION.md` 后，必须列出 `Confirmation Needed`。

确认点应包含：

- type 选择是否正确。
- 范围边界是否正确。
- 输出路径和命名是否正确。
- 是否接受 branch rename checkpoint，是否需要先交给 `$porter-codex-plugin:delivery-branch` 处理。
- 是否有需要用户选择的方案取舍。
- 风险和验收标准是否接受。
- 是否可以进入 `$porter-codex-plugin:solution-task`。

## 收尾

生成 `SOLUTION.md` 和 `WORKFLOW_STATE.json` 后停止，询问：

**"SOLUTION.md 已生成。请先确认 Confirmation Needed。还有要补充或调整的吗？如果 Branch Rename Checkpoint 需要处理，请先调用 `$porter-codex-plugin:delivery-branch`；如果无需调整且无需 rename，请显式调用 `$porter-codex-plugin:solution-task` 生成任务清单。"**
