# 任务：定义 Timeline Slice 记录模型

## Timeline 上下文

- 方案：`.codex/timeline/feat/refactor-feature-development/SOLUTION.md`
- 分支：`feat/refactor-feature-development`
- 类型：`feat`
- 当前旧 timeline 路径：`.codex/timeline/feat/refactor-feature-development/`
- 工作切片：`005`
- 下一阶段：`$porter-codex-plugin:solution-review`

## 状态说明

- `[ ]` 待执行
- `[~]` 执行中
- `[x]` 已完成

## 执行规则

- 按任务顺序执行，除非任务明确说明可以独立执行。
- 本切片无业务逻辑，无需测试框架；通过结构审查、JSON 校验、Markdown 围栏检查和路径规则审查验证。
- 每个任务完成后，必须有对应的验收标准和验证方式。
- 不迁移历史 timeline 文件，不删除旧路径文件。
- 允许同步更新 MVP overview 中与本路径模型和下一步 slice 相关的候选项。

## Task 1: 定义 Timeline Container 结构

无业务逻辑，无需测试；通过结构审查验证。

- 验收标准：`SOLUTION.md` 明确定义 `.codex/timeline/<timeline-name>/` 作为新的 timeline container 根路径。
- 验证方式：审查 `SOLUTION.md` 的路径模型，并确认包含 `current.json`、`solutions/`、`tasks/`、`reviews/`、`states/`。

- [x] 定义 timeline container 根路径：
  - `.codex/timeline/<timeline-name>/`
- [x] 定义可选 overview 文件：
  - `<timeline-name>-overview.md`
- [x] 定义固定子目录：
  - `solutions/`
  - `tasks/`
  - `reviews/`
  - `states/`
- [x] 写明 `current.json` 位于 timeline container 根目录。

## Task 2: 定义 Slice Record 命名规则

无业务逻辑，无需测试；通过结构审查验证。

- 验收标准：slice record id 使用 `<slice-id>-<type>-<slug>`，且 type 不包含 `mvp`。
- 验证方式：审查 `SOLUTION.md` 的命名规则和 type 列表。

- [x] 定义 slice record id：
  - `<slice-id>-<type>-<slug>`
- [x] 写明 `<slice-id>` 使用三位递增编号。
- [x] 写明 `<type>` 只能使用：
  - `feat`
  - `fix`
  - `refactor`
  - `perf`
  - `test`
  - `docs`
  - `build`
  - `ci`
  - `chore`
  - `style`
- [x] 写明 `<slug>` 使用 kebab-case。
- [x] 写明 `mvp` 不是 slice type。

## Task 3: 定义 Slice 文件映射

无业务逻辑，无需测试；通过结构审查验证。

- 验收标准：同一 slice 的方案、任务、审查和状态文件都能由同一个 record id 推导。
- 验证方式：审查 `SOLUTION.md` 中四类文件路径是否完整且一致。

- [x] 定义方案文件路径：
  - `.codex/timeline/<timeline-name>/solutions/<slice-id>-<type>-<slug>.md`
- [x] 定义任务文件路径：
  - `.codex/timeline/<timeline-name>/tasks/<slice-id>-<type>-<slug>.md`
- [x] 定义审查文件路径：
  - `.codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md`
- [x] 定义状态文件路径：
  - `.codex/timeline/<timeline-name>/states/<slice-id>-<type>-<slug>.json`
- [x] 写明后续 slice 追加新文件，不覆盖旧 slice 文件。

## Task 4: 定义小 Feature 与 MVP 示例

无业务逻辑，无需测试；通过结构审查验证。

- 验收标准：小 feature 与 MVP timeline 使用同一套结构，MVP 只通过 overview 表达。
- 验证方式：审查 `SOLUTION.md` 的小 feature 示例和 MVP timeline 示例。

- [x] 写明小 feature 示例：
  - `.codex/timeline/fix-review-untracked-files/`
  - `001-fix-review-untracked-files`
- [x] 写明小 feature 后续变大时可新增 slice。
- [x] 写明 MVP timeline 示例：
  - `.codex/timeline/workflow-architecture-refactor/`
  - `workflow-architecture-refactor-overview.md`
- [x] 写明 MVP 内部继续拆 `feat`、`fix`、`perf`、`docs` 等 slice。
- [x] 写明不使用 `mvp` 作为 slice type。

## Task 5: 定义 `current.json` 职责

无业务逻辑，无需测试；通过 JSON 示例和结构审查验证。

- 验收标准：`current.json` 只作为 active slice 指针，不承载完整 workflow state。
- 验证方式：审查 `current.json` JSON 示例，并用 JSON 解析校验示例。

- [x] 定义 `current.json` 字段：
  - `timeline`
  - `active_slice`
  - `solution`
  - `task`
  - `review`
  - `state`
- [x] 写明 `solution` 创建或选择 active slice 时写入 `current.json`。
- [x] 写明 `solution-task`、`solution-execute`、`solution-review` 优先从 `current.json` 解析 active slice 文件。
- [x] 写明 `current.json` 不记录完整 workflow state。
- [x] 写明本 slice 不实现切换 active slice 的命令。

## Task 6: 定义 `states/*.json` 职责

无业务逻辑，无需测试；通过 JSON 示例和结构审查验证。

- 验收标准：`states/*.json` 承接新 slice 的 workflow state，并明确允许输出范围。
- 验证方式：审查 `states/*.json` JSON 示例，并用 JSON 解析校验示例。

- [x] 定义 state 文件路径：
  - `.codex/timeline/<timeline-name>/states/<slice-id>-<type>-<slug>.json`
- [x] 定义必要字段：
  - `state`
  - `current_skill`
  - `next_skill`
  - `timeline`
  - `active_slice`
  - `solution`
  - `task`
  - `review`
  - `allowed_outputs`
- [x] 写明 `timeline` 字段含义变为 timeline container 路径。
- [x] 写明 `states/*.json` 替代新 slice 中固定的 `WORKFLOW_STATE.json`。

## Task 7: 定义阶段写入边界

无业务逻辑，无需测试；通过结构审查验证。

- 验收标准：`solution`、`solution-task`、`solution-execute`、`solution-review` 的可写文件边界清晰，且 review 不直接修复。
- 验证方式：审查 `SOLUTION.md` 的阶段写入边界。

- [x] 定义 `solution` 只能写：
  - `solutions/<slice>.md`
  - `states/<slice>.json`
  - `current.json`
- [x] 定义 `solution-task` 只能写：
  - `tasks/<slice>.md`
  - `states/<slice>.json`
  - `current.json`
- [x] 定义 `solution-execute` 首次执行可写：
  - `tasks/<slice>.md`
  - `states/<slice>.json`
  - task 需要的实现文件
- [x] 定义 `solution-execute` 回修执行可写：
  - `solutions/<slice>.md`
  - `tasks/<slice>.md`
  - `states/<slice>.json`
  - review 回修需要的实现文件
- [x] 定义 `solution-review` 只能写：
  - `reviews/<slice>.md`
  - `states/<slice>.json`

## Task 8: 定义旧路径在途收尾规则

无业务逻辑，无需测试；通过结构审查验证。

- 验收标准：旧 `.codex/timeline/<branch-type>/<branch-name>/` 路径只允许当前在途 slice 收尾，不作为新 slice 创建路径。
- 验证方式：审查 `SOLUTION.md` 的旧路径收尾规则和范围边界。

- [x] 写明如果 `current.json` 存在，必须优先使用新路径。
- [x] 写明如果 `current.json` 不存在但旧 `WORKFLOW_STATE.json` 存在，可以继续当前旧 slice 直到完成。
- [x] 写明新 slice 创建必须使用新路径。
- [x] 写明旧路径收尾完成后，后续新 slice 不再写入固定 `SOLUTION.md` / `TASK.md` / `REVIEW.md` / `WORKFLOW_STATE.json`。
- [x] 写明本 slice 不自动迁移旧文件。
- [x] 写明本 slice 不删除旧文件。
- [x] 写明历史迁移需要后续单独拆迁移 slice。

## Task 9: 更新可视化模型

无业务逻辑，无需测试；通过结构审查验证。

- 验收标准：可视化模型表达用户进入、路径选择、slice 创建、阶段读写和 review 回修流程。
- 验证方式：审查 Mermaid 图和图后说明，确认不是单纯目录图。

- [x] Mermaid 图包含 `current.json` 判断。
- [x] Mermaid 图包含旧 `WORKFLOW_STATE.json` 在途收尾分支。
- [x] Mermaid 图包含创建新 slice id。
- [x] Mermaid 图包含 `solution`、`solution-task`、`solution-execute`、`solution-review` 的读写流。
- [x] Mermaid 图包含 review `pass` 和回修分支。
- [x] 图后说明解释 `current.json`、`states/<slice>.json` 和追加记录逻辑。

## Task 10: 验证结构

无业务逻辑，无需测试；通过结构审查验证。

- 验收标准：`SOLUTION.md`、`TASK.md` 和 `WORKFLOW_STATE.json` 结构有效，且本 slice 没有执行迁移或实现改造。
- 验证方式：运行 JSON 校验、Markdown 围栏检查、路径关键词搜索和 diff 审查。

- [x] 校验 `.codex/timeline/feat/refactor-feature-development/WORKFLOW_STATE.json` 可解析。
- [x] 校验 `SOLUTION.md` / `TASK.md` Markdown 代码围栏平衡。
- [x] 校验 `SOLUTION.md` 中包含：
  - `.codex/timeline/<timeline-name>/`
  - `current.json`
  - `solutions/`
  - `tasks/`
  - `reviews/`
  - `states/`
  - `<slice-id>-<type>-<slug>`
- [x] 校验 `SOLUTION.md` 中明确 `mvp` 不是 slice type。
- [x] 校验 diff 只包含本 slice 允许的 timeline 文档和 state 更新。
- [x] 校验 diff 不包含插件 skill 实现改动。
- [x] 确认没有创建新 timeline 目录。
- [x] 确认没有修改 `plugins/porter-codex-plugin/skills/*`。

## Task 11: 同步 MVP Overview 候选顺序

无业务逻辑，无需测试；通过结构审查验证。

- 验收标准：`MVP_OVERVIEW.md` 中 005 与当前路径模型一致，006 成为实际修正四个 solution skill 路由的下一步，原初始化类审计任务顺延。
- 验证方式：审查 `MVP_OVERVIEW.md` 的过程文件模型、Work Overview 和 Slice Candidates。

- [x] 将 MVP 过程文件模型改为 `.codex/timeline/<timeline-name>/`、`current.json`、`solutions/`、`tasks/`、`reviews/`、`states/`。
- [x] 将 005 对齐为 timeline container 与 slice record 文件模型。
- [x] 将 006 对齐为让 `solution`、`solution-task`、`solution-execute`、`solution-review` 使用 `current.json` / `states/*.json` 路由。
- [x] 将原 `constitution` / `codex-md` 审计顺延到后续 slice。
- [x] 移除 MVP overview 中把 `needs-mvp-upgrade` 作为本闭环 review 结论的表述。
- [x] 确认 `mvp` 不作为 slice type。

## 完成标准

- [x] Timeline container 结构定义完成
- [x] Slice record 命名规则定义完成
- [x] Slice 文件映射定义完成
- [x] 小 feature 与 MVP 示例定义完成
- [x] `current.json` 职责定义完成
- [x] `states/*.json` 职责定义完成
- [x] 阶段写入边界定义完成
- [x] 旧路径在途收尾规则定义完成
- [x] 可视化模型更新完成
- [x] 结构验证完成
- [x] MVP overview 候选顺序同步完成
