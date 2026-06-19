# 任务：更新 Codex Solution Workflow 推荐路径说明

## Timeline 上下文

- 方案：`.codex/timeline/refactor-feature-development/solutions/007-docs-solution-workflow-path-guide.md`
- Timeline：`.codex/timeline/refactor-feature-development/`
- Active slice：`007-docs-solution-workflow-path-guide`
- State：`.codex/timeline/refactor-feature-development/states/007-docs-solution-workflow-path-guide.json`
- 分支：`feat/refactor-feature-development`
- 类型：`docs`
- 工作切片：`007`
- 下一阶段：`$porter-codex-plugin:solution-review`

## 状态说明

- `[ ]` 待执行
- `[~]` 执行中
- `[x]` 已完成

## 执行规则

- 按任务顺序执行，除非任务明确说明可以独立执行。
- 本切片只更新文档和当前 timeline 过程记录，无业务逻辑，无需测试；通过结构审查验证。
- 保留旧 branch/worktree workflow 说明，但需要明确它和新的 solution 内容闭环不是同一层能力。
- 不修改 `plugins/porter-codex-plugin/skills/solution*` 四个 skill 的行为。
- 不修改 `plugins/porter-claude-plugin/`。
- 不引入运行时依赖、脚本或构建工具。
- 不声称当前 MVP 已实现完整 `delivery-*` Git 生命周期。
- 每个任务完成后，必须有对应的验收标准和验证方式。

## Task 1: 更新 README 的 solution 内容闭环推荐入口

无业务逻辑，无需测试；通过结构审查验证。

- [x] **[实现]** `README.md`
  - 在 Codex 推荐 workflow 区域增加 solution 内容闭环：
    - `$porter-codex-plugin:solution`
    - `$porter-codex-plugin:solution-task`
    - `$porter-codex-plugin:solution-execute`
    - `$porter-codex-plugin:solution-review`
  - 说明该闭环用于小 feature、小 fix、小 perf/test/docs/build 等需求的方案、任务、执行和审查。
  - 如需要，补充 Skills 表中四个 solution skill 的用途说明。
- [x] 验收标准：`README.md` 明确推荐新的 Codex solution 内容闭环，且用户能从 README 直接看到四个入口的顺序。
- [x] 验证方式：用 `rg` 检查 `README.md` 包含四个 `$porter-codex-plugin:solution*` 入口和等价顺序说明。

## Task 2: 更新 README 的 timeline state 路径和 Git 交付边界说明

无业务逻辑，无需测试；通过结构审查验证。

- [x] **[实现]** `README.md`
  - 说明 solution workflow 的过程记录路径为 `.codex/timeline/<timeline-name>/current.json`。
  - 说明同一 active slice 的过程文件位于：
    - `solutions/<slice-id>-<type>-<slug>.md`
    - `tasks/<slice-id>-<type>-<slug>.md`
    - `reviews/<slice-id>-<type>-<slug>.md`
    - `states/<slice-id>-<type>-<slug>.json`
  - 保留旧 branch/worktree workflow 说明，但避免把旧 `plan/<type>/<branch-name>/WORKFLOW_STATE.json` 描述成 solution workflow 的主模型。
  - 明确 Git commit / delivery 是 review 通过后的交付线，和 solution 内容闭环协同但不强绑定。
  - 明确当前 MVP 不声称已经实现完整 `delivery-*` Git 生命周期。
- [x] 验收标准：`README.md` 能区分 solution 内容闭环、timeline slice record 过程记录和 Git 交付线；不会让读者误以为 `delivery-*` 已在当前 MVP 完成。
- [x] 验证方式：用 `rg` 检查 `current.json`、`solutions/`、`tasks/`、`reviews/`、`states/`、`delivery`、`commit` 等关键术语，并人工审查相关段落语义。

## Task 3: 同步 MVP overview 的 007 候选顺序

无业务逻辑，无需测试；通过结构审查验证。

- [x] **[实现]** `.codex/timeline/mvp/workflow-architecture-refactor/MVP_OVERVIEW.md`
  - 将原 007 初始化路径审计并入最终结构验证候选，不再作为单独 007 slice。
  - 将当前 docs slice 记录为新的 007。
  - 顺延或整理后续 build/test 候选编号，避免与已完成或当前 slice 冲突。
  - 保持 `mvp` 只是 timeline container / overview 概念，不作为 slice type。
- [x] 验收标准：MVP overview 中当前 007 对应“更新 Codex workflow 推荐路径说明”，初始化路径审计已并入最终验证，后续候选顺序清晰。
- [x] 验证方式：用 `rg` 检查 `MVP_OVERVIEW.md` 中 `007`、`初始化路径审计`、`更新 Codex workflow 推荐路径说明`、`mvp` 等关键词，并人工确认表格编号没有冲突。

## Task 4: 文档结构和范围验证

无业务逻辑，无需测试；通过结构审查验证。

- [x] 校验 `README.md` 和 `.codex/timeline/mvp/workflow-architecture-refactor/MVP_OVERVIEW.md` 的 Markdown 代码围栏平衡。
- [x] 校验文档不把 `mvp` 写成 slice type。
- [x] 校验文档不声称当前 MVP 已实现完整 `delivery-*` Git 生命周期。
- [x] 校验 diff 不包含 `plugins/porter-claude-plugin/`。
- [x] 校验 diff 不修改四个 `plugins/porter-codex-plugin/skills/solution*` skill 行为。
- [x] 运行 `git diff --check`。
- [x] 验收标准：结构有效、范围符合 SOLUTION.md Scope、没有越界修改。
- [x] 验证方式：运行 Markdown 围栏检查、`rg` 关键词检查、`git diff --name-status` 和 `git diff --check`。

验证记录：

- Markdown 围栏计数：`README.md:32`、`MVP_OVERVIEW.md:6`，均为偶数。
- `rg` 未发现表格 type 位置把 `mvp` 写成 slice type。
- `delivery-*` 相关命中均为“不声称已经实现完整 `delivery-*` Git 生命周期”等边界说明。
- `git diff --name-status`、`git status --short` 和 `git ls-files --others --exclude-standard` 确认变更范围未包含 `plugins/porter-claude-plugin/` 或四个 `plugins/porter-codex-plugin/skills/solution*` skill 目录；新增未跟踪文件均为当前 007 timeline slice 过程记录。
- `git diff --check` 通过。

回修记录：

- 根据 review P2 finding，将 Timeline 上下文的下一阶段从 `$porter-codex-plugin:solution-execute` 修正为 `$porter-codex-plugin:solution-review`。
- 根据 review P2 finding，补充记录 `git status --short` 和 `git ls-files --others --exclude-standard` 对未跟踪文件的范围验证。

## 完成标准

- [x] `README.md` 的 solution 内容闭环推荐入口已更新
- [x] `README.md` 的 timeline state 路径和 Git 交付边界说明已更新
- [x] MVP overview 的 007 候选顺序已同步
- [x] 文档结构和范围验证已完成
