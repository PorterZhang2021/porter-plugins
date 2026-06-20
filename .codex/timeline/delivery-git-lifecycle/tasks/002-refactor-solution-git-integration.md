# 任务：整合 solution 与 Git commit 生命周期

## 时间线上下文

- 方案：`.codex/timeline/delivery-git-lifecycle/solutions/002-refactor-solution-git-integration.md`
- 时间线：`.codex/timeline/delivery-git-lifecycle/`
- 当前切片：`002-refactor-solution-git-integration`
- 状态：`.codex/timeline/delivery-git-lifecycle/states/002-refactor-solution-git-integration.json`
- 工作上下文：`feat/delivery-git-lifecycle`
- 类型：`refactor`
- 下一阶段：`$porter-codex-plugin:solution-execute`

## 状态说明

- `[ ]` 待处理
- `[~]` 进行中
- `[x]` 已完成

## 执行规则

- 除非任务明确说明可独立执行，否则按顺序执行。
- 只有验证步骤通过或验证限制已记录后，才能把任务标记为完成。
- 每个任务必须包含`验收标准`和`验证方式`。

## Task 1：收尾 001 设计回退

无业务逻辑，无需测试；通过 timeline state 审查验证。

- [x] 写入 `reviews/001-feat-delivery-branch.md`，说明 001 取消原因。
- [x] 将 `states/001-feat-delivery-branch.json` 更新为 `cancelled`。
- [x] 验收标准：001 不再阻塞后续 slice。
- [x] 验证方式：`jq . .codex/timeline/delivery-git-lifecycle/states/001-feat-delivery-branch.json` 可解析。

## Task 2：solution workflow 去强分支化

无业务逻辑，无需测试；通过 skill 文档结构审查验证。

- [x] 更新 `solution/SKILL.md`，正式写入只保留 protected branch guard，不要求 `<branch-type>/<branch-name>`。
- [x] 更新 `solution-task/SKILL.md`，优先使用 `current.json` 和 active state gate。
- [x] 更新 `solution-execute/SKILL.md`，允许 `awaiting_user_commit_confirm` 在用户提出新修改时回到回修执行。
- [x] 更新 `solution-review/SKILL.md`，review 前置不再要求分支格式。
- [x] 更新 `solution-task/templates/task-header.md`，把固定分支字段改为工作上下文。
- [x] 验收标准：源码不再出现旧入口名或 `awaiting_commit`。
- [x] 验证方式：`rg -n "new-branch|plan-branch|task-branch|execute-branch|review-branch|commit-branch|awaiting_commit" README.md plugins/porter-codex-plugin` 无结果。

## Task 3：review pass 与 commit confirmation

无业务逻辑，无需测试；通过 state 示例和文档审查验证。

- [x] `solution-review` pass 后写入 `awaiting_user_commit_confirm`。
- [x] 有问题时写入 `awaiting_solution_execute_from_review`。
- [x] 写明用户确认 commit 后使用普通 Git commit，而不是新 plugin skill。
- [x] 写明 `committed` 终止态不包含 `next_skill`。
- [x] 验收标准：`solution-review/SKILL.md` 包含 `awaiting_user_commit_confirm`、`committing`、`committed` 和 trailer contract。
- [x] 验证方式：`rg -n "awaiting_user_commit_confirm|committing|committed|Codex-Timeline|Codex-Slice" plugins/porter-codex-plugin/skills/solution-review/SKILL.md`。

## Task 4：commit message contract 验证

无业务逻辑，无需测试框架；通过脚本样例验证。

- [x] 新增 `plugins/porter-codex-plugin/scripts/validate-solution-commit-message.sh`。
- [x] 校验 Conventional Commit subject。
- [x] 校验 `Codex-Timeline` trailer。
- [x] 校验 `Codex-Slice` trailer。
- [x] 验收标准：正确样例通过，缺少 trailer 的样例失败。
- [x] 验证方式：用临时 commit message 文件运行脚本正反例。

## Task 5：README / recommender / manifest 更新

无业务逻辑，无需测试；通过结构审查验证。

- [x] README 改为 solution-first 2.0.0 说明。
- [x] `skill-recommender` 不再推荐旧 branch/worktree workflow。
- [x] `plugin.json` 版本跃迁到 `2.0.0+codex.*`。
- [x] 验收标准：README 和 recommender 不出现旧 workflow skill 名。
- [x] 验证方式：`rg` 残留扫描无结果。

## Task 6：final cleanup

删除操作已获得用户明确授权。

- [x] 创建 `v1.9.0` tag。
- [x] 删除旧 Codex branch/worktree workflow skill 源文件。
- [x] 删除旧 Codex `workflow-guard` hooks。
- [x] 清理空目录。
- [x] 验收标准：Codex plugin skill 目录只保留 solution 主线与配置/解释类 skill。
- [x] 验证方式：`find plugins/porter-codex-plugin/skills -maxdepth 2 -type f -name SKILL.md | sort`。

## Task 7：最终验证

无业务逻辑，无需测试框架；通过结构审查和脚本验证。

- [x] `jq` 校验 plugin manifest 和 timeline state。
- [x] quick_validate 校验保留的 skill。
- [x] plugin validator 校验 Codex plugin。
- [x] `git diff --check` 通过。
- [x] commit message validator 正反例通过。
- [x] 验收标准：本 slice 的全部结构验证通过。
- [x] 验证方式：记录实际命令结果到 review。

## Task 8：回修 commit-msg hook 与 type 白名单

用户在 commit 确认前发现 contract 没有自动接入普通 `git commit`，且 validator 没有限制提交 type 白名单；按 review 回修模式补齐。

- [x] 新增 `plugins/porter-codex-plugin/scripts/solution-commit-msg-hook.sh`。
- [x] 新增 `plugins/porter-codex-plugin/scripts/install-solution-commit-msg-hook.sh`，显式安装到目标仓库 `.git/hooks/commit-msg`。
- [x] 更新 `validate-solution-commit-message.sh`，默认限制 type 为 `feat/fix/refactor/perf/test/docs/build/ci/chore/style`。
- [x] 更新 README、`solution-review` 和 `skill-recommender`，说明 hook 安装和自动检查边界。
- [x] bump Codex plugin build metadata。
- [x] 验收标准：安装 hook 后普通 `git commit` 会触发 validator；未安装时仍可手动校验；非法 type 会失败，`feat`、`docs`、`build` 等合法 type 会通过。
- [x] 验证方式：用临时 Git repo 安装 hook，分别运行合法 message、非法 type、缺 trailer 三组 `commit-msg` hook 样例；再运行 validator 的合法 type 和非法 type 样例。

## Task 9：回修 solution-task 前置分支名对齐 hook

用户指出 `solution-task` 执行前应由 hook 将当前分支名和 solution name 对齐；按 review 回修模式补齐。

- [x] 新增 `plugins/porter-codex-plugin/hooks/hooks.json`，恢复窄用途 Codex `PreToolUse` hook。
- [x] 新增 `plugins/porter-codex-plugin/hooks/solution-branch-guard.sh`，只在 active slice 为 `awaiting_solution_task` 且即将写入 task 文件时执行本地 branch rename。
- [x] 更新 `solution` / `solution-task` / README，说明分支名对齐发生在 `solution-task` 写入前，不在 solution 阶段执行。
- [x] bump Codex plugin build metadata。
- [x] 验收标准：普通 solution-task 写入前，当前本地分支会从粗分支名改为 `<type>/<solution-slug>`；目标分支已存在或当前分支有 upstream 时停止。
- [x] 验证方式：用临时 Git repo 构造 active slice，模拟 PreToolUse 输入，验证 task 写入前 rename 成功、state/current 写入不触发、多文件 patch 中 task 路径在后也能触发、目标分支冲突失败、upstream 配置失败样例。

## Task 10：回修 solution lifecycle 提交闭环漏洞

用户指出当前 solution 闭环仍可被普通 commit 或 review pass 后继续写入绕过；按回修模式补齐 lifecycle guard。

- [x] 更新 `plugins/porter-codex-plugin/scripts/solution-commit-msg-hook.sh`，仓库存在未终止 active solution state 时拒绝普通 `git commit`，不再退化为只检查 subject。
- [x] 要求 staged `committed` solution state 的 commit message 必须匹配 `Codex-Timeline` / `Codex-Slice` trailer。
- [x] 新增 `plugins/porter-codex-plugin/hooks/solution-lifecycle-guard.sh`，在 `awaiting_user_commit_confirm` 阶段阻止继续写实现、文档、配置、task、solution 或 review 文件。
- [x] 更新 `hooks.json`，同一 `PreToolUse` hook 顺序执行 lifecycle guard 和 branch alignment guard。
- [x] 更新 README 和 `solution-review`，说明 commit confirmation 与 hook 的硬边界。
- [x] bump Codex plugin build metadata。
- [x] 验收标准：未 review、awaiting commit confirm、缺 trailer、伪造 Codex trailer、committed state 未 staged 都不能通过；committed state staged + 正确 trailer 可以通过；review pass 后和 committing 中写非 state 文件会被 Codex hook 阻止，只允许写入并 stage active state 文件完成 commit confirmation。
- [x] 验证方式：用临时 Git repo 模拟 commit-msg hook 和 Codex PreToolUse 输入，覆盖单行 JSON state 解析、未 review commit 失败、awaiting_user_commit_confirm commit 失败、committing commit 失败、committed trailer 通过、committed state 未 staged 失败、缺 trailer 失败、bogus trailer 失败、review pass 后写入失败、committing 写入失败、写 state 通过、stage state 通过、stage 非 state 失败等样例。

## Task 11：回修 commit confirmation staging 自锁

Review 发现 lifecycle guard 在 `awaiting_user_commit_confirm` / `committing` 阶段只允许 stage active state，导致确认提交时无法 stage 已 review 的变更；按回修模式补齐 `reviewed_paths` 白名单。

- [x] 更新 `solution-lifecycle-guard.sh`，允许显式 stage active state 文件和 active state 中记录的 `reviewed_paths`。
- [x] 更新 `solution-commit-msg-hook.sh`，普通 Git commit 时拒绝不在 `reviewed_paths` 或 active state 文件内的 staged path。
- [x] 更新 `solution-review` 与 README，要求 review pass state 写入 repo-relative `reviewed_paths`，并禁止用 `git add .` 等宽泛 pathspec 完成 commit confirmation。
- [x] 更新 solution 与 plugin build metadata。
- [x] 验收标准：review pass 后已审查文件和 active state 可被显式 staged；未审查文件、`git add .`、缺失 `reviewed_paths` 或包含未审查 staged 文件的 commit 都会失败。
- [x] 验证方式：用临时 Git repo 模拟 Codex PreToolUse 和真实 `commit-msg` hook，覆盖 reviewed path 放行、state 放行、未审查 path 拒绝、宽泛 pathspec 拒绝、缺 `reviewed_paths` 拒绝、未审查 staged 文件拒绝。

## Task 12：回修 reviewed path 内容漂移与 stale current 阻塞

Review 发现 `reviewed_paths` 只能证明文件名已审查，不能证明内容未变；同时其它 stale `current.json` 会阻塞当前已匹配 committed slice 的提交。

- [x] 更新 `solution-commit-msg-hook.sh`，要求 staged 文件的 blob oid 匹配 `reviewed_path_blobs`，删除路径使用 `__deleted__`。
- [x] 更新 `solution-commit-msg-hook.sh`，当 commit message 已匹配一个 staged `committed` solution state 时，不再因其它无关 stale `current.json` 阻塞当前提交。
- [x] 更新 `solution-lifecycle-guard.sh`，Codex `git add` 前校验 worktree blob 与 `reviewed_path_blobs` 一致，避免同路径内容漂移被 staged。
- [x] 更新 `solution-review` 与 README，说明 `reviewed_path_blobs`、删除标记和 stale current 边界。
- [x] 更新 solution 与 plugin build metadata。
- [x] 验收标准：review 后同路径内容变化会被 Codex hook 或 commit-msg hook 拒绝；已审查删除可提交；无关 stale current 不阻止当前已匹配 committed slice 提交。
- [x] 验证方式：用临时 Git repo 模拟真实 `commit-msg` hook 和 Codex PreToolUse，覆盖 stale current 放行当前 committed slice、same-path blob mismatch 拒绝、删除标记通过、PreToolUse stage 前 blob mismatch 拒绝。

## Task 13：回修 review contract 不可变性与 PreToolUse 解析边界

Review 补全矩阵发现 commit confirmation 的 policy source 仍可被 mutable state 扩权，file mode 未纳入校验，Codex lifecycle guard 对 Bash / `git add` / stale current 的边界仍不完整；按回修模式一次性补齐。

- [x] 新增 review contract 约定：review pass 写入固定路径 `reviews/<slice>.contract.json`，state 只记录 `review_contract` 与 `review_contract_blob`，并把 contract blob 写入本地 `.git/porter-solution-contracts/<timeline>/<slice>.contract.blob` anchor。
- [x] 更新 `solution-commit-msg-hook.sh`，从 state 路径确定性推导 contract 路径，校验 staged contract blob 匹配 state 记录，且 staged 文件必须匹配 contract 中的 path、blob 与 mode。
- [x] 更新 `solution-lifecycle-guard.sh`，从同一 contract 校验 `git add`，拒绝复合 Bash、解释器/管道写入、宽泛 pathspec、多段 `git add` 漏检和 `git -C` 路径基准混淆。
- [x] 更新 `solution-review` 与 README，说明 review contract、`reviewed_path_modes`、mode-only 漂移、contract staging 和 commit confirmation 的窄 Bash 边界。
- [x] 验收标准：committed state 不能通过改写 `reviewed_paths` 扩大白名单；mode-only 变化会被拒绝；stale current 不阻塞当前 staged committed slice；复合 Bash 写入/stage、多段 `git add`、`git -C` 路径混淆都会被 PreToolUse 拒绝或正确校验。
- [x] 验证方式：用临时 Git repo 跑完整 commit-msg 与 PreToolUse 矩阵，覆盖正向提交、删除、非法 type、未终止 state、未审查文件、blob mismatch、mode-only mismatch、mutable state 扩权、stale current、直接写入、宽泛 add、复合 Bash、解释器/tee 写入、多段 add、`git -C` add 和 branch alignment。

## Task 14：回修 commit-msg hook 安装自举

真实 commit 前安装本仓库 `commit-msg` hook 时发现 `solution-commit-msg-hook.sh` 尚未具备 executable bit，安装器先检查 `-x` 会导致安装失败；按回修模式补齐。

- [x] 更新 `install-solution-commit-msg-hook.sh`，在检查 source hook 可执行前先对已有 source hook 执行 `chmod +x`。
- [x] 将会被 Git 直接执行的 hook 和相关脚本纳入 executable file mode。
- [x] 更新 `solution-lifecycle-guard.sh`，允许 commit confirmation 阶段运行单条本仓库 hook 安装命令。
- [x] 更新 README 和 `solution-review`，同步安装命令在 commit confirmation 白名单内。
- [x] bump Codex plugin build metadata。
- [x] 验收标准：新 checkout 中运行 `plugins/porter-codex-plugin/scripts/install-solution-commit-msg-hook.sh --repo .` 可以安装 `.git/hooks/commit-msg`；安装后普通 `git commit` 触发本 hook。
- [x] 验证方式：安装本仓库 hook，检查 `.git/hooks/commit-msg` 指向插件脚本；最终普通 `git commit` 通过 hook 完成。
