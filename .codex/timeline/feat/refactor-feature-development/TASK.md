# Task: Define Solution Task

## Timeline Context

- Solution: `.codex/timeline/feat/refactor-feature-development/SOLUTION.md`
- Branch: `feat/refactor-feature-development`
- Type: `feat`
- Work slice: 002
- Next stage: `$porter-codex-plugin:solution-execute`

## Task 1: Create `solution-task` Skill Entry

无业务逻辑，无需自动化测试；通过结构审查验证。

- 验收标准：`solution-task` skill 入口、frontmatter、阶段边界、调用方式和前置条件完整。
- 验证方式：运行 skill frontmatter 校验，并人工审查 `SKILL.md` 的边界说明。

- [x] 创建 `plugins/porter-codex-plugin/skills/solution-task/SKILL.md`
- [x] 添加完整 frontmatter：
  - `name: solution-task`
  - `description` 说明从 `SOLUTION.md` 生成 `TASK.md`
  - `allowed-tools` 覆盖读取、写入和查找所需能力
- [x] 写明阶段边界：
  - 只生成或更新 `.codex/timeline/<branch-type>/<branch-name>/TASK.md`
  - 只生成或更新 `.codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json`
  - 不修改 `SOLUTION.md`
  - 不执行任务
  - 不 review
  - 不 commit
  - 不 merge / push / create PR
- [x] 写明 invocation：
  - `$porter-codex-plugin:solution-task`
- [x] 写明前置条件：
  - 当前不在 `main` / `master`
  - 当前分支符合 `<branch-type>/<branch-name>`
  - `AGENTS.md` 存在
  - `.codex/constitution.md` 存在
  - `.codex/timeline/<branch-type>/<branch-name>/SOLUTION.md` 存在
- [x] 写明不读取旧输入：
  - 不读取 `plan/<type>/<branch-name>/PLAN.md`
  - 不读取 `plan/<type>/<branch-name>/ANALYSIS.md`
  - 不读取旧 `plan/` workflow state
- [x] 写明收尾提示：
  - 生成 `TASK.md` 后停止
  - 询问用户是否补充、删除或调整任务
  - 若无调整，提示显式调用 `$porter-codex-plugin:solution-execute`

## Task 2: Define `SOLUTION.md` Readiness Checks

无业务逻辑，无需自动化测试；通过结构审查验证。

- 验收标准：`solution-task` 在生成任务前能确认 `SOLUTION.md` 已具备 type、目标、范围、验收和确认状态。
- 验证方式：审查 `SKILL.md` 中 readiness check 和 hard stop 规则。

- [x] 在 `solution-task/SKILL.md` 中定义读取 `SOLUTION.md` 后的必要检查
- [x] 检查 `SOLUTION.md` 必须包含：
  - `Type Decision`
  - `Goal`
  - `Scope`
  - `Type-Specific Analysis`
  - `Acceptance`
  - `Confirmation` 或已解决的 `Confirmation Needed`
- [x] 如果 `Confirmation Needed` 未解决，必须停止并提示回到 `$porter-codex-plugin:solution`
- [x] 如果 selected type 缺失或无法识别，必须停止并提示修正 `SOLUTION.md`
- [x] 如果 `Acceptance` 缺失，必须停止并提示补充验收标准
- [x] 如果 `Branch Rename Checkpoint` 仍需要处理，必须提示先处理 rename checkpoint

## Task 3: Define Common `TASK.md` Skeleton

无业务逻辑，无需自动化测试；通过结构审查验证。

- 验收标准：通用任务骨架能稳定表达 timeline context、状态、执行顺序、验收标准和验证方式。
- 验证方式：审查 `templates/task-header.md` 和 `SKILL.md` 的 `TASK.md Structure` 规则。

- [x] 新增 `plugins/porter-codex-plugin/skills/solution-task/templates/task-header.md`
- [x] `task-header.md` 包含：
  - 标题 `# Task: <title>`
  - `Timeline Context`
  - 状态说明 `[ ]`、`[~]`、`[x]`
  - `Execution Rule`
- [x] 在 `solution-task/SKILL.md` 中定义通用 `TASK.md` 生成骨架
- [x] 骨架必须支持：
  - 无业务逻辑任务
  - 测试先行任务
  - 度量先行任务
  - 文档/配置结构审查任务
- [x] 明确任务必须使用 checkbox
- [x] 明确每个任务必须有 `验收标准` 和 `验证方式`
- [x] 明确 `验收标准` 必须对应 `SOLUTION.md` 的 `Acceptance` 或说明支撑性任务性质
- [x] 明确 `验证方式` 必须写出可观察证据

## Task 4: Create Type Reference Templates

无业务逻辑，无需自动化测试；通过结构审查验证。

- 验收标准：所有支持的 type 都有独立 reference，且每个 reference 都能生成带验收标准和验证方式的任务。
- 验证方式：检查 `solution-task/reference/*.md` 文件齐全，并用搜索确认每个模板包含 `验收标准` 与 `验证方式`。

- [x] 创建 `plugins/porter-codex-plugin/skills/solution-task/reference/feat.md`
- [x] 创建 `plugins/porter-codex-plugin/skills/solution-task/reference/fix.md`
- [x] 创建 `plugins/porter-codex-plugin/skills/solution-task/reference/refactor.md`
- [x] 创建 `plugins/porter-codex-plugin/skills/solution-task/reference/perf.md`
- [x] 创建 `plugins/porter-codex-plugin/skills/solution-task/reference/test.md`
- [x] 创建 `plugins/porter-codex-plugin/skills/solution-task/reference/docs.md`
- [x] 创建 `plugins/porter-codex-plugin/skills/solution-task/reference/build.md`
- [x] 创建 `plugins/porter-codex-plugin/skills/solution-task/reference/ci.md`
- [x] 创建 `plugins/porter-codex-plugin/skills/solution-task/reference/chore.md`
- [x] 创建 `plugins/porter-codex-plugin/skills/solution-task/reference/style.md`
- [x] 每个 reference 必须说明：
  - 从 `SOLUTION.md` 读取哪些字段
  - 生成哪些任务类型
  - 任务顺序要求
  - 验证方式
  - 什么时候可以标记"无业务逻辑，无需测试"
- [x] 每个 reference 模板中的任务必须包含 `验收标准` 和 `验证方式`
- [x] reference 可以参考旧 `task/reference/*.md`，但不得保留旧 `PLAN.md` / `ANALYSIS.md` / `plan/` 路径假设
- [x] `feat` reference 必须要求可执行行为变化遵循 TDD Red / Green / Refactor
- [x] `feat` 行为测试必须包含 Case / Given / When / Then / Assert 或 Verify
- [x] `build` reference 必须要求构建验证和产物验证；如果没有持久产物，必须记录原因并验证可观察输出

## Task 5: Define Special Fix Task Flow

无业务逻辑，无需自动化测试；通过结构审查验证。

- 验收标准：`fix` 任务必须复现先行、最小修复、回归验证，并在复现或根因不成立时停止旧修复路径。
- 验证方式：审查 `reference/fix.md` 的 hard stop、ordering、conditional execution 和模板字段。

- [x] 在 `solution-task/reference/fix.md` 中明确 `fix` 任务必须从复现测试开始
- [x] 写明固定顺序：
  - Task 1: 复现测试
  - Task 2: 最小修复
  - Task 3: 回归验证
- [x] 写明如果 `SOLUTION.md` 缺少复现步骤或根因分析，必须停止并回到 solution 阶段补充
- [x] 写明复现失败或无法复现时，不能生成假定修复任务
- [x] 写明如果执行复现时推翻根因或复现不成立，不能继续假定修复；应进入 review 后由回修执行更新 `TASK.md` / `SOLUTION.md`

## Task 6: Define Special Perf Task Flow

无业务逻辑，无需自动化测试；通过结构审查验证。

- 验收标准：`perf` 任务必须基线先行、确认瓶颈、再优化、再量化验证，并在瓶颈判断变化时停止旧优化路径。
- 验证方式：审查 `reference/perf.md` 的 hard stop、ordering、conditional execution 和模板字段。

- [x] 在 `solution-task/reference/perf.md` 中明确 `perf` 任务必须先度量
- [x] 写明固定顺序：
  - Task 1: 基线度量或基线采集计划
  - Task 2: 瓶颈确认
  - Task 3: 优化实现
  - Task 4: 优化后验证
- [x] 写明如果没有基线数据或采集计划，不得生成优化实现任务
- [x] 写明验证任务必须有量化指标或可执行检查方法
- [x] 写明如果执行基线或瓶颈确认时推翻优化方向，不能继续过期优化；应进入 review 后由回修执行更新 `TASK.md` / `SOLUTION.md`

## Task 7: Define Workflow State Output

无业务逻辑，无需自动化测试；通过 JSON 校验验证。

- 验收标准：生成任务后 workflow state 指向 `awaiting_solution_execute`，且 allowed outputs 只允许 `TASK.md` 与 `WORKFLOW_STATE.json`。
- 验证方式：使用 `python -m json.tool` 校验当前 `WORKFLOW_STATE.json`，并审查 `SKILL.md` JSON 示例。

- [x] 在 `solution-task/SKILL.md` 中定义写入 `WORKFLOW_STATE.json`
- [x] 状态必须为 `awaiting_solution_execute`
- [x] `current_skill` 必须为 `$porter-codex-plugin:solution-task`
- [x] `next_skill` 必须为 `$porter-codex-plugin:solution-execute`
- [x] `timeline` 指向 `.codex/timeline/<branch-type>/<branch-name>`
- [x] `allowed_outputs` 只包含：
  - `.codex/timeline/<branch-type>/<branch-name>/TASK.md`
  - `.codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json`
- [x] JSON 示例必须能通过 `python -m json.tool`

## Task 8: Validate Structure

无业务逻辑，无需自动化测试；通过结构审查验证。

- 验收标准：新增 skill 结构、reference 文件、路径、Markdown 围栏和状态 JSON 全部通过轻量验证。
- 验证方式：运行 `quick_validate.py`、JSON 校验、Markdown 围栏检查和 reference 字段搜索。

- [x] 运行 `skill-creator/scripts/quick_validate.py plugins/porter-codex-plugin/skills/solution-task`
- [x] 确认 `plugins/porter-codex-plugin/skills/solution-task/SKILL.md` frontmatter 完整
- [x] 确认 `plugins/porter-codex-plugin/skills/solution-task/reference/*.md` 文件齐全
- [x] 确认所有新增路径使用 kebab-case
- [x] 确认所有输出路径指向 `.codex/timeline/<branch-type>/<branch-name>/`
- [x] 确认没有引入 MVP 容器目录结构
- [x] 确认没有修改旧 `task` / `task-branch` / `task-worktree`
- [x] 确认没有实现 `solution-execute`
- [x] 确认没有实现 `delivery-*`
- [x] 确认 Markdown 代码围栏平衡
- [x] 确认 `feat` reference 不是泛泛"测试在前"，而是 Red / Green / Refactor 任务结构
- [x] 确认 `build` reference 不只验证构建命令成功，还验证产物
- [x] 确认 `fix` / `perf` reference 包含 review 回修前的条件执行边界
- [x] 确认所有 type reference 模板都包含 `验收标准` 和 `验证方式`

## Completion Criteria

- [x] `solution-task` skill 入口定义完成
- [x] `TASK.md` 通用骨架定义完成
- [x] 所有 type reference 模板定义完成
- [x] `feat` TDD Red / Green / Refactor 规则定义完成
- [x] `fix` 任务流定义完成
- [x] `perf` 任务流定义完成
- [x] `build` 产物验证规则定义完成
- [x] `fix` / `perf` 条件执行边界定义完成
- [x] 所有 type task 验收标准与验证方式定义完成
- [x] `WORKFLOW_STATE.json` 输出规则定义完成
- [x] 结构审查完成
