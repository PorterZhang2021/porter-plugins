# Task: Define Solution Review

## Timeline Context

- Solution: `.codex/timeline/feat/refactor-feature-development/SOLUTION.md`
- Branch: `feat/refactor-feature-development`
- Type: `feat`
- Timeline path: `.codex/timeline/feat/refactor-feature-development/`
- Work slice: 004
- Next stage: `$porter-codex-plugin:solution-execute`

## Status Legend

- `[ ]` pending
- `[~]` in progress
- `[x]` complete

## Execution Rule

- Execute tasks in order unless a task explicitly says it can run independently.
- Do not start implementation tasks before their prerequisite tests, reproduction steps, measurements, or validation setup are ready.
- Mark each task complete only after its verification step passes or the verification limitation is recorded.
- Every task must include `验收标准` and `验证方式`; do not mark a task complete without observable evidence.

## Task 1: Create `solution-review` Skill Entry

无业务逻辑，无需测试；通过结构审查验证。

- 验收标准：`solution-review` skill 入口、frontmatter、阶段边界、调用方式和前置条件完整。
- 验证方式：运行 skill frontmatter 校验，并人工审查 `SKILL.md` 的入口和边界说明。

- [x] 创建 `plugins/porter-codex-plugin/skills/solution-review/SKILL.md`
- [x] 添加完整 frontmatter：
  - `name: solution-review`
  - `description` 说明读取当前 timeline 并产出 `REVIEW.md`
  - 如需工具权限，覆盖读取、写入、查找和 diff 检查所需能力
- [x] 写明唯一 invocation：
  - `$porter-codex-plugin:solution-review`
- [x] 写明前置条件：
  - 当前不在 `main` / `master`
  - 当前分支符合 `<branch-type>/<branch-name>`
  - `AGENTS.md` 存在
  - `.codex/constitution.md` 存在
  - `.codex/timeline/<branch-type>/<branch-name>/SOLUTION.md` 存在
  - `.codex/timeline/<branch-type>/<branch-name>/TASK.md` 存在
  - `.codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json` 存在
- [x] 写明阶段边界：
  - 只执行审查
  - 只写入或更新 `REVIEW.md`
  - 只写入或更新 `WORKFLOW_STATE.json`
  - 不修改实现文件
  - 不更新 `TASK.md`
  - 不更新 `SOLUTION.md`
  - 不执行修复
  - 不 commit / merge / push / create PR

## Task 2: Define Prototype Mapping From Existing `review`

无业务逻辑，无需测试；通过结构审查验证。

- 验收标准：`solution-review` 明确以现有 `review` / `review-branch` 为原型，但移除旧 `plan/` 输入和对话-only 输出模式。
- 验证方式：审查 `SKILL.md` 的 prototype mapping 和旧路径禁止规则，并用搜索确认未保留旧 `plan/` 读取假设。

- [x] 在 `solution-review/SKILL.md` 中写明参考原型：
  - `plugins/porter-codex-plugin/skills/review/SKILL.md`
  - `plugins/porter-codex-plugin/skills/review-branch/SKILL.md`
- [x] 写明路径映射：
  - 旧 `plan/<type>/<branch-name>/PLAN.md`
  - 新 `.codex/timeline/<branch-type>/<branch-name>/SOLUTION.md`
  - 旧 `plan/<type>/<branch-name>/TASK.md`
  - 新 `.codex/timeline/<branch-type>/<branch-name>/TASK.md`
  - 新增 `.codex/timeline/<branch-type>/<branch-name>/REVIEW.md`
- [x] 写明不读取：
  - `plan/<type>/<branch-name>/PLAN.md`
  - `plan/<type>/<branch-name>/ANALYSIS.md`
  - 旧 `plan/` workflow state
- [x] 写明与旧 review 的关键差异：
  - 旧 review 可选且主要对话输出
  - `solution-review` 是 solution 最小闭环阶段
  - `solution-review` 必须写入 `REVIEW.md`
  - `solution-review` 必须更新 `WORKFLOW_STATE.json`

## Task 3: Define State Gate And Inputs

无业务逻辑，无需测试；通过结构审查验证。

- 验收标准：`solution-review` 只能从 `awaiting_solution_review` 进入，并能收集审查所需上下文。
- 验证方式：审查 `SKILL.md` 的 state gate、输入清单和不支持状态处理规则。

- [x] 在 `solution-review/SKILL.md` 中定义只允许状态：
  - `awaiting_solution_review`
- [x] 写明如果状态不是 `awaiting_solution_review`，必须停止并提示 `WORKFLOW_STATE.json` 中记录的 `next_skill`
- [x] 写明审查输入：
  - `.codex/timeline/<branch-type>/<branch-name>/SOLUTION.md`
  - `.codex/timeline/<branch-type>/<branch-name>/TASK.md`
  - `.codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json`
  - `git status --short`
  - 当前 diff
  - 必要时读取已有 `.codex/timeline/<branch-type>/<branch-name>/REVIEW.md`
- [x] 写明 review brief 必须包含：
  - 本次目标和验收标准
  - 已完成任务
  - 当前改动摘要
  - 关键 diff
  - 需要重点审查的风险点

## Task 4: Define Two-Layer Review Mechanism

无业务逻辑，无需测试；通过结构审查验证。

- 验收标准：`solution-review` 继承旧 review 的双层审查机制，并区分首次 review 与回修 review。
- 验证方式：审查 `SKILL.md` 的 Review Mechanism 规则和 `REVIEW.md` notes 记录要求。

- [x] 写明当前 Codex 负责：
  - 整理 review brief
  - 裁决业务语义
  - 裁决 solution workflow 阶段边界
  - 检查 `SOLUTION.md` / `TASK.md` 一致性
  - 检查 AGENTS.md / constitution 规则
  - 决定最终状态流
- [x] 写明首次正常 review 默认使用双层审查
- [x] 写明如果环境支持 `code-reviewer` 子代理或等价新上下文审查能力，则委托子代理审查 review brief 和 diff
- [x] 写明子代理只做通用工程审查，不裁决业务意图、配置取舍或 workflow 阶段边界
- [x] 写明当前 Codex 合并子代理 findings，并保留有文件事实或 diff 支撑的问题
- [x] 写明环境不支持子代理时降级为当前 Codex 审查，并在 `REVIEW.md` Notes 记录原因
- [x] 写明回修 review 先复查上一轮 `REVIEW.md` findings 是否解决
- [x] 写明回修 diff 较大、涉及可执行行为、用户显式要求或风险较高时，再次使用子代理
- [x] 写明回修 review 跳过子代理时，必须在 `REVIEW.md` Notes 记录原因

## Task 5: Define `REVIEW.md` Structure

无业务逻辑，无需测试；通过结构审查验证。

- 验收标准：`REVIEW.md` 结构能稳定记录上下文、结论、检查项、findings、open questions、notes 和 next step。
- 验证方式：审查 `SKILL.md` 的 `REVIEW.md` skeleton，并确认包含必要字段。

- [x] 在 `solution-review/SKILL.md` 中定义 `REVIEW.md` 结构：
  - `# Review: <title>`
  - `Timeline Context`
  - `Result`
  - `Checks`
  - `Findings`
  - `Open Questions`
  - `Notes`
  - `Next Step`
- [x] 写明 `Result` 只能是：
  - `pass`
  - `needs-fix`
  - `needs-task-update`
  - `needs-solution-update`
- [x] 写明 findings 必须按 P0 / P1 / P2 / P3 排序
- [x] 写明没有阻断问题时必须明确写“无阻断问题”
- [x] 写明范围重新确认问题归入 `needs-solution-update`，不得新增额外状态

## Task 6: Define Review Conclusions And State Outputs

无业务逻辑，无需测试；通过 JSON 校验验证。

- 验收标准：每个 review 结论都有明确 next state，且 JSON 示例可解析。
- 验证方式：抽取或复制 `SKILL.md` 中 JSON 示例，用 `python -m json.tool` 校验。

- [x] 写明 `pass` 结论：
  - `state: awaiting_commit`
  - `current_skill: $porter-codex-plugin:solution-review`
  - `next_skill: $porter-codex-plugin:commit`
- [x] 写明 `needs-fix` 结论：
  - `state: awaiting_solution_execute_from_review`
  - `current_skill: $porter-codex-plugin:solution-review`
  - `next_skill: $porter-codex-plugin:solution-execute`
- [x] 写明 `needs-task-update` 结论：
  - `state: awaiting_solution_execute_from_review`
  - `current_skill: $porter-codex-plugin:solution-review`
  - `next_skill: $porter-codex-plugin:solution-execute`
- [x] 写明 `needs-solution-update` 结论：
  - `state: awaiting_solution_execute_from_review`
  - `current_skill: $porter-codex-plugin:solution-review`
  - `next_skill: $porter-codex-plugin:solution-execute`
- [x] 所有输出 state 的 `allowed_outputs` 只包含：
  - `.codex/timeline/<branch-type>/<branch-name>/REVIEW.md`
  - `.codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json`
- [x] 写明 `solution-review` 不直接写 `TASK.md` / `SOLUTION.md`

## Task 7: Define Review Checklist

无业务逻辑，无需测试；通过结构审查验证。

- 验收标准：review 清单覆盖 solution 目标、task 完成状态、验证证据、diff 范围、路径边界、frontmatter、JSON、Markdown 围栏和 workflow state。
- 验证方式：审查 `SKILL.md` 的 checklist 字段。

- [x] 检查 `SOLUTION.md` 的目标、范围和验收是否仍然成立
- [x] 检查 `TASK.md` 是否全部完成，或未完成项是否合理记录
- [x] 检查 `TASK.md` 中每个完成任务是否有验证证据或限制说明
- [x] 检查当前 diff 是否只包含本 slice 允许范围
- [x] 检查新增或修改文件是否符合 Codex 插件路径边界
- [x] 检查是否误改旧 `plan-*`、`execute-*`、`review-*` 或 Claude 侧配置
- [x] 检查 Markdown frontmatter 是否有效
- [x] 检查 JSON 示例或状态文件是否可解析
- [x] 检查 Markdown 代码围栏是否平衡
- [x] 检查当前 workflow state 是否能正确进入下一阶段

## Task 8: Validate Structure

无业务逻辑，无需测试；通过结构审查验证。

- 验收标准：新增 skill、路径、Markdown 围栏、JSON 示例和状态规则全部通过轻量验证。
- 验证方式：运行 `quick_validate.py`、JSON 校验、Markdown 围栏检查和路径搜索。

- [x] 运行 `python /Users/porterzhang/.codex/skills/.system/skill-creator/scripts/quick_validate.py plugins/porter-codex-plugin/skills/solution-review`
- [x] 确认 `plugins/porter-codex-plugin/skills/solution-review/SKILL.md` frontmatter 完整
- [x] 确认新增路径使用 kebab-case
- [x] 确认所有 timeline 输出路径指向 `.codex/timeline/<branch-type>/<branch-name>/`
- [x] 确认没有修改旧 `review` / `review-branch`
- [x] 确认没有实现 `delivery-*`
- [x] 确认没有新增额外状态流
- [x] 确认没有读取旧 `plan/<type>/<branch-name>/PLAN.md` / `ANALYSIS.md` / workflow state 假设
- [x] 确认 Markdown 代码围栏平衡
- [x] 确认 JSON 示例能通过 `python -m json.tool`
- [x] 回修 `REVIEW.md` 中记录的 untracked 文件读取、旧 `REVIEW.md` context guard、非阻断 findings 记录规则

## Completion Criteria

- [x] `solution-review` skill 入口定义完成
- [x] 旧 `review` 原型映射定义完成
- [x] state gate 和 review 输入定义完成
- [x] 双层审查机制定义完成
- [x] 首次 review 与回修 review 规则定义完成
- [x] `REVIEW.md` 结构定义完成
- [x] review 结论定义完成
- [x] `pass` 状态输出定义完成
- [x] `needs-fix` / `needs-task-update` / `needs-solution-update` 回修状态输出定义完成
- [x] review checklist 定义完成
- [x] 结构审查完成
