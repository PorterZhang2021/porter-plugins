# 任务：让 Solution Workflow 使用 Timeline Slice Record 路由

## Timeline 上下文

- 方案：`.codex/timeline/refactor-feature-development/solutions/006-feat-solution-workflow-slice-record-routing.md`
- Timeline：`.codex/timeline/refactor-feature-development/`
- Active slice：`006-feat-solution-workflow-slice-record-routing`
- State：`.codex/timeline/refactor-feature-development/states/006-feat-solution-workflow-slice-record-routing.json`
- 分支：`feat/refactor-feature-development`
- 类型：`feat`
- 旧 timeline 路径：`.codex/timeline/feat/refactor-feature-development/`，仅保留历史和过渡记录
- 工作切片：`006`
- 下一阶段：`$porter-codex-plugin:solution-review`

## 状态说明

- `[ ]` 待执行
- `[~]` 执行中
- `[x]` 已完成

## 执行规则

- 按任务顺序执行，除非任务明确说明可以独立执行。
- 本切片修改的是 Markdown skill 配置，无运行时代码和测试框架；通过结构审查、frontmatter 校验、Markdown 围栏检查、JSON 示例解析和路径关键词审查验证。
- 创建当前 006 的真实 `.codex/timeline/<timeline-name>/current.json` 和 slice record 文件，作为后续 007 的 canonical active slice 基线。
- 不迁移历史已完成 slice，不删除旧 `.codex/timeline/<branch-type>/<branch-name>/` 文件。
- 不修改 Claude Code 侧配置。
- 每个任务完成后，必须有对应的验收标准和验证方式。

## Task 1: 更新 `solution` 新 slice 路由

无业务逻辑，无需测试；通过结构审查验证。

- [x] **[实现]** `plugins/porter-codex-plugin/skills/solution/SKILL.md`
  - 将 Phase Boundary 和输出路径从固定 `SOLUTION.md` / `WORKFLOW_STATE.json` 改为新 slice 的 `solutions/<slice>.md`、`states/<slice>.json` 和 `current.json`。
  - 写明 `<timeline-name>` 默认来自 branch name slug。
  - 写明 `solution` 是唯一创建新 slice id 的入口。
  - 写明 slice id 通过扫描 `solutions/`、`tasks/`、`reviews/`、`states/` 的三位编号生成。
  - 写明如果 `current.json` 存在且 active slice 未完成，应提示继续当前 `next_skill`，不创建新 slice。
  - 写明如果 `current.json` 不存在但旧 `WORKFLOW_STATE.json` 存在，只允许未完成的当前旧 slice 收尾；旧 state 已完成时必须创建新 slice record。
  - 更新 `WORKFLOW_STATE.json` 示例，包含 `timeline`、`active_slice`、`solution`、`task`、`review`、`allowed_outputs`。
- [x] 验收标准：`solution` 的新 slice 创建规则满足 SOLUTION.md Acceptance，且不再把固定旧路径作为新 slice 主模型。
- [x] 验证方式：审查 `solution/SKILL.md`，并用 `rg` 确认包含 `current.json`、`solutions/<slice`、`states/<slice`、`active_slice`、`旧 WORKFLOW_STATE.json` 收尾规则。

## Task 2: 更新 `solution-task` active slice 输入输出

无业务逻辑，无需测试；通过结构审查验证。

- [x] **[实现]** `plugins/porter-codex-plugin/skills/solution-task/SKILL.md`
  - 将 prerequisites 从固定 `SOLUTION.md` 改为优先读取 `.codex/timeline/<timeline-name>/current.json`。
  - 通过 `current.json` 解析 active slice 的 solution、task 和 state 文件。
  - 将 TASK 输出路径改为 `tasks/<slice>.md`。
  - 将 state 输出路径改为 `states/<slice>.json`。
  - 写明 `solution-task` 不创建新 slice id。
  - 保留不读取旧 `PLAN.md` / `ANALYSIS.md` 的规则。
  - 保留旧路径在途收尾规则：没有 `current.json` 但旧 `WORKFLOW_STATE.json` 存在且 state 允许当前 skill 时，允许完成当前旧 slice。
  - 写明非默认 timeline name 的解析规则。
- [x] 验收标准：`solution-task` 能从 active slice 的 solution 文件生成 active slice 的 task 文件，并更新同一 slice 的 state 文件。
- [x] 验证方式：审查 `solution-task/SKILL.md`，并用 `rg` 确认包含 `current.json`、`tasks/<slice`、`states/<slice`、`不创建新 slice` 和旧路径收尾规则。

## Task 3: 更新 `solution-execute` first execution 路由

无业务逻辑，无需测试；通过结构审查验证。

- [x] **[实现]** `plugins/porter-codex-plugin/skills/solution-execute/SKILL.md`
  - 将 State Gate 从固定 `WORKFLOW_STATE.json` 改为优先读取 active slice 的 `states/<slice>.json`。
  - 通过 `current.json` 解析 task、solution、review 和 state 文件。
  - 将首次执行的 allowed outputs 改为 active slice 的 task / state 文件和任务需要的实现文件。
  - 完成后写回 `states/<slice>.json` 的 `awaiting_solution_review` 状态。
  - 写明 `solution-execute` 不创建新 slice id。
  - 写明非默认 timeline name 的解析规则。
- [x] 验收标准：首次执行模式使用 active slice 的 task / state 文件，不再依赖固定旧 `TASK.md` / `WORKFLOW_STATE.json` 作为新 slice 主模型。
- [x] 验证方式：审查 `solution-execute/SKILL.md` 的 First Execution Mode 和 State Gate，并用 `rg` 确认新路径字段完整。

## Task 4: 更新 `solution-execute` review 回修路由

无业务逻辑，无需测试；通过结构审查验证。

- [x] **[实现]** `plugins/porter-codex-plugin/skills/solution-execute/SKILL.md`
  - 将 review-remediation mode 改为读取 active slice 的 review / task / solution / state 文件。
  - 将回修 allowed outputs 改为 active slice 的 task / solution / state 文件和 review 回修需要的实现文件。
  - 完成回修后写回同一 active slice 的 `awaiting_solution_review` 状态。
  - 保留 review 需要用户确认时停止并询问的规则。
  - 移除固定 `REVIEW.md` 表述，改为 active slice review file / `reviews/<slice>.md`。
- [x] 验收标准：review 回修不会写固定旧 `SOLUTION.md` / `TASK.md` / `WORKFLOW_STATE.json` 作为新 slice 主模型。
- [x] 验证方式：审查 `solution-execute/SKILL.md` 的 Review-Remediation Mode，并确认 active slice 文件路径和状态流一致。

## Task 5: 更新 `solution-review` active slice review 输出

无业务逻辑，无需测试；通过结构审查验证。

- [x] **[实现]** `plugins/porter-codex-plugin/skills/solution-review/SKILL.md`
  - 将 review 输入改为 active slice 的 solution、task、state 和当前 diff。
  - 将 review 输出改为 `reviews/<slice>.md`。
  - 将 pass 和 remediation 的状态输出改为 `states/<slice>.json`。
  - 将 stale review 判断改为比较 active slice id、solution path、task path、review path 和 state path。
  - 保留首次普通 review 默认使用 fresh-context `code-reviewer` 子代理的机制。
  - 保留 review 不直接修复、不修改 task / solution / implementation 的阶段边界。
  - 写明非默认 timeline name 的解析规则。
- [x] 验收标准：`solution-review` 的输入输出路径全部来自 active slice，且子代理 review 机制没有被移除。
- [x] 验证方式：审查 `solution-review/SKILL.md`，并用 `rg` 确认包含 `reviews/<slice`、`states/<slice`、`code-reviewer`、`current.json` 和 pass/remediation state 示例。

## Task 6: 对齐四个 skill 的旧路径在途收尾规则

无业务逻辑，无需测试；通过结构审查验证。

- [x] **[实现]** `plugins/porter-codex-plugin/skills/solution/SKILL.md`
- [x] **[实现]** `plugins/porter-codex-plugin/skills/solution-task/SKILL.md`
- [x] **[实现]** `plugins/porter-codex-plugin/skills/solution-execute/SKILL.md`
- [x] **[实现]** `plugins/porter-codex-plugin/skills/solution-review/SKILL.md`
  - 四个 skill 都必须写明：如果 `current.json` 存在，优先使用新路径。
  - 四个 skill 都必须写明：如果 `current.json` 不存在但旧 `WORKFLOW_STATE.json` 存在，只有旧 state 未完成且允许当前 skill 时才继续当前旧 slice 收尾。
  - 四个 skill 都必须写明：新 slice 创建必须使用新路径。
  - 避免把旧路径描述成长期可用的表述。
- [x] 验收标准：旧路径只被描述为当前在途 slice 收尾机制，不作为新 slice 创建路径。
- [x] 验证方式：用 `rg` 检查四个 skill 中的 `current.json`、`旧 WORKFLOW_STATE.json`、`在途`、`新 slice 创建必须使用新路径`，并确认没有把旧路径描述成长期可用。

## Task 7: 对齐 state JSON 示例和字段职责

无业务逻辑，无需测试；通过 JSON 解析和结构审查验证。

- [x] **[实现]** `plugins/porter-codex-plugin/skills/solution/SKILL.md`
- [x] **[实现]** `plugins/porter-codex-plugin/skills/solution-task/SKILL.md`
- [x] **[实现]** `plugins/porter-codex-plugin/skills/solution-execute/SKILL.md`
- [x] **[实现]** `plugins/porter-codex-plugin/skills/solution-review/SKILL.md`
  - `current.json` 示例只包含 active slice 指针字段，可以包含 `state` 文件路径，但不承载完整 workflow state。
  - `states/<slice>.json` 示例包含：
    - `state`
    - `current_skill`
    - `next_skill`
    - `timeline`
    - `active_slice`
    - `solution`
    - `task`
    - `review`
    - `allowed_outputs`
  - `allowed_outputs` 必须指向 active slice 文件或任务需要的实现文件。
- [x] 验收标准：四个 skill 的 state 示例字段一致，且 `current.json` 和 `states/<slice>.json` 职责不混淆。
- [x] 验证方式：提取四个 skill 中的 JSON 代码块并用 JSON 解析；审查 `current.json` 示例没有 `current_skill` / `next_skill` / `allowed_outputs`。

## Task 8: 结构验证和范围审查

无业务逻辑，无需测试；通过结构审查验证。

- [x] 校验四个修改后的 skill frontmatter 仍包含 `name`、`description`、`allowed-tools`。
- [x] 校验四个修改后的 skill Markdown 代码围栏平衡。
- [x] 校验四个修改后的 skill 中 JSON 示例可解析。
- [x] 校验 `mvp` 没有作为 slice type 加入支持类型列表。
- [x] 校验 diff 只包含本切片允许的四个 solution skill、旧路径过渡记录和新路径 006 slice record 文件。
- [x] 校验没有修改 `plugins/porter-claude-plugin/`。
- [x] 校验只创建当前 006 所需的真实 `.codex/timeline/<timeline-name>/current.json` 和新 slice record 文件，没有创建额外记录。
- [x] 验收标准：结构有效、范围符合 SOLUTION.md Scope、没有越界修改。
- [x] 验证方式：运行 `git diff --check`、Markdown 围栏检查、JSON 解析、`git diff --name-status` 和相关 `rg` 路径检查。

## Task 9: 将当前 006 迁入新路径记录

无业务逻辑，无需测试；通过结构审查验证。

- [x] **[实现]** `.codex/timeline/refactor-feature-development/current.json`
  - 指向当前 active slice `006-feat-solution-workflow-slice-record-routing`。
- [x] **[实现]** `.codex/timeline/refactor-feature-development/solutions/006-feat-solution-workflow-slice-record-routing.md`
- [x] **[实现]** `.codex/timeline/refactor-feature-development/tasks/006-feat-solution-workflow-slice-record-routing.md`
- [x] **[实现]** `.codex/timeline/refactor-feature-development/reviews/006-feat-solution-workflow-slice-record-routing.md`
- [x] **[实现]** `.codex/timeline/refactor-feature-development/states/006-feat-solution-workflow-slice-record-routing.json`
  - 将 006 的过程记录写入新 timeline container。
  - 保留旧 `.codex/timeline/feat/refactor-feature-development/` 文件，不删除。
- [x] 验收标准：006 已作为新路径 active slice record 存在，后续 007 可以从 `current.json` 判断当前 slice 状态后创建新 slice。
- [x] 验证方式：校验 `current.json` 和 `states/006-feat-solution-workflow-slice-record-routing.json` 可解析，并确认路径字段指向存在的 006 文件。

## Task 10: 处理复审发现的路由文档不一致

无业务逻辑，无需测试；通过结构审查验证。

- [x] **[实现]** `plugins/porter-codex-plugin/skills/solution/SKILL.md`
  - 将 completed state 判断从 `awaiting_commit 或其他已完成状态` 收敛为明确的 `awaiting_commit`。
- [x] **[实现]** `plugins/porter-codex-plugin/skills/solution-execute/SKILL.md`
  - 将 State Gate 改为读取已解析的 state 文件；新路径读取 `states/<slice>.json`，旧路径收尾读取旧 `WORKFLOW_STATE.json`。
- [x] **[实现]** `.codex/timeline/refactor-feature-development/solutions/006-feat-solution-workflow-slice-record-routing.md`
  - 修正“本切片不新增真实 timeline slice record 文件”的旧表述。
- [x] 验收标准：复审中记录的 P2/P3 路由文档不一致已消除，且不扩大到 Claude 侧配置或运行时依赖。
- [x] 验证方式：用 `rg` 检查旧表述不再存在；重新运行 JSON 解析、Markdown 围栏检查、frontmatter 检查和 `git diff --check`。

## 完成标准

- [x] `solution` 新 slice 路由更新完成
- [x] `solution-task` active slice 输入输出更新完成
- [x] `solution-execute` first execution 路由更新完成
- [x] `solution-execute` review 回修路由更新完成
- [x] `solution-review` active slice review 输出更新完成
- [x] 四个 skill 的旧路径在途收尾规则对齐完成
- [x] state JSON 示例和字段职责对齐完成
- [x] 结构验证和范围审查完成
- [x] 当前 006 新路径 slice record 创建完成
- [x] 复审发现的路由文档不一致回修完成
