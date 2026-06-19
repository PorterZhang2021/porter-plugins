# Task: Define Solution Execute

## Timeline Context

- Solution: `.codex/timeline/feat/refactor-feature-development/SOLUTION.md`
- Branch: `feat/refactor-feature-development`
- Type: `feat`
- Timeline path: `.codex/timeline/feat/refactor-feature-development/`
- Work slice: 003
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

## Task 1: Create `solution-execute` Skill Entry

无业务逻辑，无需测试；通过结构审查验证。

- 验收标准：`solution-execute` skill 入口、frontmatter、阶段边界、调用方式和前置条件完整。
- 验证方式：运行 skill frontmatter 校验，并人工审查 `SKILL.md` 的入口和边界说明。

- [x] 创建 `plugins/porter-codex-plugin/skills/solution-execute/SKILL.md`
- [x] 添加完整 frontmatter：
  - `name: solution-execute`
  - `description` 说明从当前 timeline 的 `TASK.md` 执行任务，并支持 review 回修执行
  - `allowed-tools` 覆盖读取、写入、编辑、查找和执行命令所需能力
- [x] 写明唯一 invocation：
  - `$porter-codex-plugin:solution-execute`
- [x] 写明前置条件：
  - 当前不在 `main` / `master`
  - 当前分支符合 `<branch-type>/<branch-name>`
  - `AGENTS.md` 存在
  - `.codex/constitution.md` 存在
  - `.codex/timeline/<branch-type>/<branch-name>/SOLUTION.md` 存在
  - `.codex/timeline/<branch-type>/<branch-name>/TASK.md` 存在
  - `.codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json` 存在
- [x] 写明阶段边界：
  - 可以执行当前阶段任务
  - 可以更新 `TASK.md`
  - 可以更新 `WORKFLOW_STATE.json`
  - review 回修模式可按 review 结论更新 `SOLUTION.md`
  - 不执行 review
  - 不 commit
  - 不 merge / push / create PR
- [x] 写明收尾提示：
  - 执行完成后停止
  - 询问用户是否补充、调整或继续未完成任务
  - 若无调整，提示显式调用 `$porter-codex-plugin:solution-review`

## Task 2: Define Prototype Mapping From Existing `execute`

无业务逻辑，无需测试；通过结构审查验证。

- 验收标准：`solution-execute` 明确以现有 `execute` / `execute-branch` 为原型，但移除旧 `plan/` 路径、旧 fallback 和旧 review/commit 状态。
- 验证方式：审查 `SKILL.md` 的 prototype mapping 和旧路径禁止规则，并用搜索确认未保留旧 `plan/` 读取假设。

- [x] 在 `solution-execute/SKILL.md` 中写明参考原型：
  - `plugins/porter-codex-plugin/skills/execute/SKILL.md`
  - `plugins/porter-codex-plugin/skills/execute-branch/SKILL.md`
  - `plugins/porter-codex-plugin/skills/execute/reference/*.md`
- [x] 写明路径映射：
  - 旧 `plan/<type>/<branch-name>/TASK.md`
  - 新 `.codex/timeline/<branch-type>/<branch-name>/TASK.md`
  - 旧 `plan/<type>/<branch-name>/WORKFLOW_STATE.json`
  - 新 `.codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json`
- [x] 写明不提供旧 `PLAN.md` fallback；没有 `TASK.md` 必须停止并提示回到 `$porter-codex-plugin:solution-task`
- [x] 写明不读取：
  - `plan/<type>/<branch-name>/PLAN.md`
  - `plan/<type>/<branch-name>/ANALYSIS.md`
  - 旧 `plan/` workflow state
- [x] 写明旧状态与新状态映射：
  - `awaiting_execute` -> `awaiting_solution_execute`
  - `executing` -> `executing_solution`
  - `awaiting_review_or_commit` -> `awaiting_solution_review`
- [x] 写明不提供 commit alternate；必须先进入 `$porter-codex-plugin:solution-review`

## Task 3: Define Workflow State Gate

无业务逻辑，无需测试；通过 JSON 示例和结构审查验证。

- 验收标准：`solution-execute` 只能在允许状态执行，遇到不支持状态会停止并提示 `next_skill`。
- 验证方式：审查 `SKILL.md` 的 state gate 规则和 JSON 示例，使用 `python -m json.tool` 校验 JSON 示例。

- [x] 在 `solution-execute/SKILL.md` 中定义允许状态：
  - `awaiting_solution_execute`
  - `executing_solution`
  - `awaiting_solution_execute_from_review`
  - `executing_solution_remediation`
- [x] 写明首次执行从 `awaiting_solution_execute` 开始
- [x] 写明首次执行开始前必须写入 `executing_solution`
- [x] 写明回修执行从 `awaiting_solution_execute_from_review` 开始
- [x] 写明回修执行开始前必须写入 `executing_solution_remediation`
- [x] 写明如果状态不在允许列表，必须停止并提示 `WORKFLOW_STATE.json` 中记录的 `next_skill`
- [x] 写明缺失 `WORKFLOW_STATE.json` 时必须停止，不沿用旧 execute 的宽松继续行为

## Task 4: Define First Execution Mode

无业务逻辑，无需测试；通过结构审查验证。

- 验收标准：首次执行模式能从 `SOLUTION.md` / `TASK.md` 读取 selected type 和任务清单，按 checkbox 顺序执行并更新状态到 review。
- 验证方式：审查 `SKILL.md` 的 First execution mode、读写边界和状态输出。

- [x] 写明首次执行读取：
  - `.codex/timeline/<branch-type>/<branch-name>/SOLUTION.md`
  - `.codex/timeline/<branch-type>/<branch-name>/TASK.md`
  - `.codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json`
- [x] 写明从 `SOLUTION.md` 的 `Type Decision` 读取 `Selected type`
- [x] 写明根据 selected type 读取 `solution-execute/reference/<type>.md`
- [x] 写明按 `TASK.md` checkbox 顺序执行：
  - 优先继续 `[~]` 任务
  - 否则执行第一个 `[ ]` 任务
  - 只在验证方式通过或限制已记录后标记 `[x]`
- [x] 写明每完成一个 task 或子步骤必须更新 `TASK.md`
- [x] 写明全部任务完成后写入 `WORKFLOW_STATE.json`：
  - `state: awaiting_solution_review`
  - `current_skill: $porter-codex-plugin:solution-execute`
  - `next_skill: $porter-codex-plugin:solution-review`

## Task 5: Define Review Remediation Mode

无业务逻辑，无需测试；通过结构审查验证。

- 验收标准：review 回修模式能读取 `REVIEW.md`，按 review 结论执行修复、补任务或更新方案，并回到 review 状态。
- 验证方式：审查 `SKILL.md` 的 review remediation mode、`SOLUTION.md` 更新边界和 `needs-mvp-upgrade` 停止规则。

- [x] 写明 review 回修模式读取：
  - `.codex/timeline/<branch-type>/<branch-name>/REVIEW.md`
  - `.codex/timeline/<branch-type>/<branch-name>/TASK.md`
  - 必要时读取 `.codex/timeline/<branch-type>/<branch-name>/SOLUTION.md`
- [x] 写明只有状态为 `awaiting_solution_execute_from_review` 或 `executing_solution_remediation` 时才进入回修模式
- [x] 写明 review 结论为实现缺陷时，可以修改实现文件并更新 `TASK.md`
- [x] 写明 review 结论为任务缺口时，可以更新 `TASK.md` 并执行新增或未完成任务
- [x] 写明 review 结论为方案假设、验收标准、根因或瓶颈变化时，可以同步更新 `SOLUTION.md`
- [x] 写明 review 结论为 `needs-mvp-upgrade` 时必须停止，提示回到 MVP discussion，不继续假定修复
- [x] 写明回修完成后写入 `WORKFLOW_STATE.json`：
  - `state: awaiting_solution_review`
  - `current_skill: $porter-codex-plugin:solution-execute`
  - `next_skill: $porter-codex-plugin:solution-review`

## Task 6: Create Type Execution References

无业务逻辑，无需测试；通过结构审查验证。

- 验收标准：所有支持 type 都有 `solution-execute/reference/*.md`，且执行节奏来自旧 execute 原型但不保留旧 `plan/` 假设。
- 验证方式：检查 reference 文件齐全，并用搜索确认 reference 不包含旧 `plan/<type>/<branch-name>` 路径假设。

- [x] 创建 `plugins/porter-codex-plugin/skills/solution-execute/reference/feat.md`
- [x] 创建 `plugins/porter-codex-plugin/skills/solution-execute/reference/fix.md`
- [x] 创建 `plugins/porter-codex-plugin/skills/solution-execute/reference/refactor.md`
- [x] 创建 `plugins/porter-codex-plugin/skills/solution-execute/reference/perf.md`
- [x] 创建 `plugins/porter-codex-plugin/skills/solution-execute/reference/test.md`
- [x] 创建 `plugins/porter-codex-plugin/skills/solution-execute/reference/docs.md`
- [x] 创建 `plugins/porter-codex-plugin/skills/solution-execute/reference/build.md`
- [x] 创建 `plugins/porter-codex-plugin/skills/solution-execute/reference/ci.md`
- [x] 创建 `plugins/porter-codex-plugin/skills/solution-execute/reference/chore.md`
- [x] 创建 `plugins/porter-codex-plugin/skills/solution-execute/reference/style.md`
- [x] 每个 reference 必须说明：
  - 从 `TASK.md` 读取什么
  - 执行顺序
  - 验证要求
  - 如何更新 `TASK.md`
  - 什么时候需要停止并进入 review
- [x] `feat` reference 保留 Red / Green / Refactor：
  - 先让行为测试失败
  - 再最小实现
  - 再重构并复验
- [x] `fix` reference 保留复现 -> 修复 -> 回归验证
- [x] `perf` reference 保留基线 -> 瓶颈确认 -> 优化 -> 优化后度量验证
- [x] `docs` / `chore` / `style` 支持结构审查和 diff review 作为验证方式

## Task 7: Define Output State Examples

无业务逻辑，无需测试；通过 JSON 校验验证。

- 验收标准：`solution-execute` 的输出 state 示例可解析，且 allowed outputs 覆盖执行和回修模式需要写入的文件。
- 验证方式：复制或抽取 `SKILL.md` 中 JSON 示例，用 `python -m json.tool` 校验。

- [x] 在 `solution-execute/SKILL.md` 中定义首次执行开始状态示例：
  - `state: executing_solution`
  - `current_skill: $porter-codex-plugin:solution-execute`
- [x] 在 `solution-execute/SKILL.md` 中定义回修执行开始状态示例：
  - `state: executing_solution_remediation`
  - `current_skill: $porter-codex-plugin:solution-execute`
- [x] 在 `solution-execute/SKILL.md` 中定义执行完成状态示例：
  - `state: awaiting_solution_review`
  - `current_skill: $porter-codex-plugin:solution-execute`
  - `next_skill: $porter-codex-plugin:solution-review`
- [x] 首次执行 allowed outputs 必须包含：
  - `.codex/timeline/<branch-type>/<branch-name>/TASK.md`
  - `.codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json`
  - 本轮任务允许修改的实现、文档或配置文件
- [x] 回修执行 allowed outputs 必须包含：
  - `.codex/timeline/<branch-type>/<branch-name>/TASK.md`
  - `.codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json`
  - 必要时包含 `.codex/timeline/<branch-type>/<branch-name>/SOLUTION.md`
  - 本轮 review 允许修改的实现、文档或配置文件

## Task 8: Validate Structure

无业务逻辑，无需测试；通过结构审查验证。

- 验收标准：新增 skill 结构、reference 文件、路径、Markdown 围栏和状态 JSON 全部通过轻量验证。
- 验证方式：运行 `quick_validate.py`、JSON 校验、Markdown 围栏检查和路径搜索。

- [x] 运行 `skill-creator/scripts/quick_validate.py plugins/porter-codex-plugin/skills/solution-execute`
- [x] 确认 `plugins/porter-codex-plugin/skills/solution-execute/SKILL.md` frontmatter 完整
- [x] 确认 `plugins/porter-codex-plugin/skills/solution-execute/reference/*.md` 文件齐全
- [x] 确认所有新增路径使用 kebab-case
- [x] 确认所有 timeline 输出路径指向 `.codex/timeline/<branch-type>/<branch-name>/`
- [x] 确认没有引入 MVP 容器目录结构
- [x] 确认没有修改旧 `execute` / `execute-branch` / `execute-worktree`
- [x] 确认没有实现 `solution-review`
- [x] 确认没有实现 `delivery-*`
- [x] 确认 Markdown 代码围栏平衡
- [x] 确认 JSON 示例能通过 `python -m json.tool`
- [x] 确认没有旧 `plan/<type>/<branch-name>/PLAN.md` / `ANALYSIS.md` / workflow state 读取假设

## Completion Criteria

- [x] `solution-execute` skill 入口定义完成
- [x] 旧 `execute` 原型映射定义完成
- [x] 首次执行模式定义完成
- [x] review 回修执行模式定义完成
- [x] workflow state gate 定义完成
- [x] `TASK.md` checkbox 更新规则定义完成
- [x] `SOLUTION.md` 回修更新边界定义完成
- [x] 所有 type execution reference 定义完成
- [x] `feat` Red / Green / Refactor 执行节奏定义完成
- [x] `fix` 复现 / 修复 / 回归执行节奏定义完成
- [x] `perf` 基线 / 优化 / 度量验证执行节奏定义完成
- [x] `WORKFLOW_STATE.json` 输出规则定义完成
- [x] 结构审查完成
