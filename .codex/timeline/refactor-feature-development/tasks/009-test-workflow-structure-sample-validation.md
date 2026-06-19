# 任务：验证 Solution Workflow 结构与样例流程

## Timeline Context

- Solution: `.codex/timeline/refactor-feature-development/solutions/009-test-workflow-structure-sample-validation.md`
- Timeline: `.codex/timeline/refactor-feature-development/`
- Active slice: `009-test-workflow-structure-sample-validation`
- State: `.codex/timeline/refactor-feature-development/states/009-test-workflow-structure-sample-validation.json`
- Branch: `feat/refactor-feature-development`
- Type: `test`
- Work slice: `009`
- Next stage: `$porter-codex-plugin:solution-execute`

## Status Legend

- `[ ]` pending
- `[~]` in progress
- `[x]` complete

## Execution Rule

- Execute tasks in order unless a task explicitly says it can run independently.
- This slice validates and closes MVP 1; it may fix small Markdown/JSON wording or consistency issues found during validation.
- Do not change `solution*` workflow behavior: execution rules, state transitions, allowed outputs, and user interaction boundaries must stay the same unless the task explicitly records a verified inconsistency.
- Do not modify `plugins/porter-claude-plugin/`.
- Do not delete old `plan-*` / `analyze-bug` entries.
- Do not rename skill directories, commands, Git type names, state names, frontmatter keys, JSON keys, file paths, or code block contents while doing Chinese wording cleanup.
- Do not write to user home directories except the Codex plugin installation/visibility verification path recorded in Task 5.
- Before any Codex plugin installation command, record the intended touch scope: command, expected Codex config/cache location, purpose, and rollback or limitation note.
- Mark each task complete only after its verification step passes or the verification limitation is recorded.
- Every task must include `验收标准` and `验证方式`.

## Task 1: 锁定验证基线与触达边界

- [x] Confirm repository location and branch.
  - Evidence to record: `pwd`, `git status --short --branch`.
- [x] Confirm active slice routing.
  - Evidence to record: `jq . .codex/timeline/refactor-feature-development/current.json .codex/timeline/refactor-feature-development/states/009-test-workflow-structure-sample-validation.json`.
- [x] Confirm active state allows execution.
  - Expected: state is `awaiting_solution_execute`, next skill is `$porter-codex-plugin:solution-execute`.
- [x] Record protected scope before execution.
  - Must not modify `plugins/porter-claude-plugin/`.
  - Must not write to `~/.claude`, `~/.agents`, or `~/plugins`.
  - Codex plugin install verification may touch Codex local plugin config/cache only after Task 5 records the exact command and purpose.
- [x] 验收标准：执行阶段开始前，active slice、branch、worktree cleanliness and protected boundaries are explicit.
- [x] 验证方式：run `pwd`, `git status --short --branch`, and `jq` commands above; record outputs or concise result notes in this task file.

验证记录：

- `pwd` 输出 `/Users/porterzhang/AiCode/porter-plugins`。
- `git status --short --branch` 输出当前分支 `feat/refactor-feature-development`，执行前变更仅包含 009 timeline 过程记录和 `current.json`。
- `jq` 确认 `current.json` 指向 `009-test-workflow-structure-sample-validation`。
- `jq` 确认 state 已进入 `executing_solution`，`current_skill` / `next_skill` 均为 `$porter-codex-plugin:solution-execute`。
- 执行边界已记录：不修改 `plugins/porter-claude-plugin/`，不写入 `~/.claude`、`~/.agents` 或 `~/plugins`；Codex 插件安装验证只在 Task 5 记录触达范围后执行。

## Task 2: 审查 workflow 结构、frontmatter 和 reference 覆盖

- [x] Review frontmatter for current Codex solution workflow skills.
  - Target: `plugins/porter-codex-plugin/skills/solution/SKILL.md`
  - Target: `plugins/porter-codex-plugin/skills/solution-task/SKILL.md`
  - Target: `plugins/porter-codex-plugin/skills/solution-execute/SKILL.md`
  - Target: `plugins/porter-codex-plugin/skills/solution-review/SKILL.md`
  - Check: `name`, `description`, and any declared `allowed-tools` remain valid.
- [x] Review supported type reference coverage.
  - Check `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `build`, `ci`, `chore`, `style`.
  - Target directories:
    - `plugins/porter-codex-plugin/skills/solution/reference/`
    - `plugins/porter-codex-plugin/skills/solution-task/reference/`
    - `plugins/porter-codex-plugin/skills/solution-execute/reference/`
- [x] Review template and path references.
  - Target: `plugins/porter-codex-plugin/skills/solution-task/templates/task-header.md`
  - Check whether old placeholder paths could confuse new timeline slice routing.
- [x] 验收标准：frontmatter and reference coverage are complete for the supported types, or small inconsistencies are corrected in this slice and recorded.
- [x] 验证方式：use `rg --files`, targeted `sed`, and manual structure review; record checked file groups and any corrections made.

验证记录：

- 已检查 `solution`、`solution-task`、`solution-execute`、`solution-review` 四个 `SKILL.md` 的 frontmatter；`name`、`description` 和 `allowed-tools` 存在且语义有效。
- 已检查 `solution/reference/`、`solution-task/reference/`、`solution-execute/reference/`，三处均覆盖 `build`、`chore`、`ci`、`docs`、`feat`、`fix`、`perf`、`refactor`、`style`、`test`。
- 已检查 `solution-task/templates/task-header.md`；输出模板标题和字段已改为中文，仍保留路径、type、state 和 skill 命令占位符。
- 已检查 `solution-review/SKILL.md` 中的 REVIEW.md 输出模板；输出标题、章节和字段已改为中文，`pass` / `needs-fix` 等结果值保持固定枚举。

## Task 3: 审查 timeline 状态流、阶段边界和样例流程

- [x] Review `solution -> solution-task -> solution-execute -> solution-review` state transitions.
  - Check generated state names: `awaiting_solution_task`, `awaiting_solution_execute`, `awaiting_solution_review`, `awaiting_solution_execute_from_review`, `awaiting_commit`.
  - Check `current_skill`, `next_skill`, and `allowed_outputs` examples in each `solution*` skill.
- [x] Review execute/review loop semantics.
  - Confirm review records findings and state; execute performs remediation.
  - Confirm review does not directly modify implementation or task outputs.
- [x] Review existing 006-009 timeline records for pointer coherence.
  - Target: `.codex/timeline/refactor-feature-development/current.json`
  - Target: `.codex/timeline/refactor-feature-development/states/*.json`
  - Target: current 009 solution/task paths.
- [x] Review Mermaid Visual Model requirements.
  - Check `solution/reference/*.md` rules and existing solution records for a traceable visual model or clear no-diagram reason.
- [x] 验收标准：state flow, stage boundaries, sample flow, and Visual Model rules are coherent and match the current MVP 1 design.
- [x] 验证方式：use `rg` for state names, `jq` for JSON states, and manual review of relevant sections; record findings or "no findings".

验证记录：

- `rg` 确认 `awaiting_solution_task`、`awaiting_solution_execute`、`executing_solution`、`awaiting_solution_review`、`awaiting_solution_execute_from_review`、`executing_solution_remediation`、`awaiting_commit` 在对应 `solution*` skill 中有状态门或输出示例。
- `jq` 确认 `current.json` 指向 active slice `009-test-workflow-structure-sample-validation`，active state 当前为 `executing_solution`。
- 已检查 execute/review 边界：execute 更新 task/state 并在回修模式可更新 solution；review 只写 review/state，不执行修复。
- 已检查 `solution/reference/*.md` 的视觉模型规则和 006-009 solution 记录；已有 solution 记录包含 Mermaid 或明确的 Visual Model 章节。

## Task 4: 统一 solution workflow 相关 skills 的中文表述

- [x] Audit user-visible prose in solution workflow related skill docs.
  - Target: `plugins/porter-codex-plugin/skills/solution/`
  - Target: `plugins/porter-codex-plugin/skills/solution-task/`
  - Target: `plugins/porter-codex-plugin/skills/solution-execute/`
  - Target: `plugins/porter-codex-plugin/skills/solution-review/`
  - Prefer Chinese for user-facing explanations, rules, prompts, and task/reference prose.
  - Preserve necessary English identifiers: skill names, command names, Git type names, state names, frontmatter keys, JSON keys, paths, code blocks, shell commands, product/platform names, and established workflow labels.
- [x] Update avoidable mixed-language wording.
  - Examples: English task labels, generic "Stop", "Output", "Read From" style prose may be localized when not acting as a fixed identifier.
  - Keep code fences and machine-readable snippets unchanged unless they are explanatory comments.
- [x] Verify no unintended semantic changes.
  - Do not change workflow rules, state transitions, allowed outputs, or installation commands while localizing prose.
- [x] 验收标准：solution workflow 相关 skill documents present user-facing instructions primarily in Chinese, with fixed identifiers preserved.
- [x] 验证方式：run targeted `rg` searches for common English prose markers in the four solution workflow skill targets, manually review remaining English terms as necessary identifiers, and inspect diff for wording-only changes.

验证记录：

- 已将清理范围收窄到 `solution/`、`solution-task/`、`solution-execute/`、`solution-review/`，并撤回非 solution 相关 skill 的正文清理。
- 已中文化 solution workflow 相关 skill 的用户说明、任务 reference 说明、状态输出说明和停止提示。
- 已中文化新生成 `SOLUTION.md`、`TASK.md`、`REVIEW.md` 会使用的输出章节标题和字段标签，避免模板输出中英混杂。
- 保留必要固定标识：skill 名、type 名、state 名、结果枚举、路径、JSON/frontmatter key、命令和代码块。
- `rg` 检查未再命中 `Timeline Context`、`Type Decision`、`Type-Specific Analysis`、`Visual Model`、`Confirmation Needed`、`Next Step` 等模板输出英文章节名。
- `git diff --check` 通过。

## Task 5: 执行 Codex 插件安装/可见性验证

- [x] Read and record the canonical Codex plugin update/install flow before changing README or running install commands.
  - Skill source: `/Users/porterzhang/.codex/skills/.system/plugin-creator/SKILL.md`
  - Reference: `/Users/porterzhang/.codex/skills/.system/plugin-creator/references/installing-and-updating.md`
  - Relevant rule: existing local plugins should use the cachebuster helper and reinstall from the marketplace name read from `marketplace.json`.
  - Repo-local marketplace file: `.agents/plugins/marketplace.json`
  - Marketplace name command: `python3 /Users/porterzhang/.codex/skills/.system/plugin-creator/scripts/read_marketplace_name.py --marketplace-path .agents/plugins/marketplace.json`
  - Expected marketplace name: `porter-plugins`
- [x] Static plugin exposure check.
  - Validate `plugins/porter-codex-plugin/.codex-plugin/plugin.json`.
  - Validate `.agents/plugins/marketplace.json`.
  - Expected: plugin name is `porter-codex-plugin`, version is `1.9.0+codex.<timestamp>`, `skills` points to `./skills/`, marketplace points to `./plugins/porter-codex-plugin`.
- [x] Validate the plugin using the plugin-creator validator.
  - Command: `python3 /Users/porterzhang/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py plugins/porter-codex-plugin`
- [x] Update README Codex install/update section to use the same plugin-creator flow.
  - Replace stale local marketplace paths with `/Users/porterzhang/AiCode/porter-plugins`.
  - Explain repo-local marketplace install:
    - `codex plugin marketplace add /Users/porterzhang/AiCode/porter-plugins`
    - `codex plugin add porter-codex-plugin@porter-plugins`
  - Explain local development update flow:
    - `python3 /Users/porterzhang/.codex/skills/.system/plugin-creator/scripts/update_plugin_cachebuster.py plugins/porter-codex-plugin`
    - `python3 /Users/porterzhang/.codex/skills/.system/plugin-creator/scripts/read_marketplace_name.py --marketplace-path .agents/plugins/marketplace.json`
    - `codex plugin add porter-codex-plugin@porter-plugins`
    - Open a new Codex thread after reinstall so updated skills are picked up.
- [x] If plugin content changes before visibility verification, refresh the Codex cachebuster with the helper.
  - Command: `python3 /Users/porterzhang/.codex/skills/.system/plugin-creator/scripts/update_plugin_cachebuster.py plugins/porter-codex-plugin`
  - Preserve base version `1.9.0`; replace only the `+codex.<cachebuster>` suffix.
- [x] Record install touch scope before running any mutating Codex plugin command.
  - Marketplace setup command for this repo-local marketplace: `codex plugin marketplace add /Users/porterzhang/AiCode/porter-plugins`
  - Reinstall command from marketplace name: `codex plugin add porter-codex-plugin@porter-plugins`
  - Expected touch scope: Codex local plugin marketplace/config/cache under user Codex configuration or app plugin storage, if required by Codex CLI.
  - Prohibited touch scope: `~/.claude`, `~/.agents`, `~/plugins`, `plugins/porter-claude-plugin/`.
- [x] Run the least invasive available Codex plugin visibility checks first.
  - Prefer `codex plugin --help`, `codex plugin list`, or equivalent read-only commands if available.
  - If the CLI cannot verify visibility in the current environment, record the limitation and the closest available evidence.
- [x] If mutating install verification is available and appropriate, run it and record result.
  - Confirm whether `solution`, `solution-task`, `solution-execute`, and `solution-review` are visible as `$porter-codex-plugin:<skill>` entries or equivalent plugin skills.
  - If a new Codex thread is required to observe skills, record that limitation explicitly.
- [x] 验收标准：Codex plugin exposure and README instructions both use the plugin-creator update/reinstall flow; install/visibility checks record touched paths and limitations.
- [x] 验证方式：run `jq`, plugin-creator `validate_plugin.py`, `read_marketplace_name.py --marketplace-path .agents/plugins/marketplace.json`, Codex plugin read-only commands, and install/visibility commands only after recording touch scope; record outputs or concise evidence in this task file.

验证记录：

- 已读取 `/Users/porterzhang/.codex/skills/.system/plugin-creator/SKILL.md` 和 `references/installing-and-updating.md`；确认本地插件更新流程为 cachebuster helper + 从 marketplace 名重装。
- `jq` 确认 `plugin.json` 的 `name` 为 `porter-codex-plugin`，`skills` 为 `./skills/`；`.agents/plugins/marketplace.json` 的 marketplace 名为 `porter-plugins`，插件 source path 为 `./plugins/porter-codex-plugin`。
- `python3 /Users/porterzhang/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py plugins/porter-codex-plugin` 通过。
- `python3 /Users/porterzhang/.codex/skills/.system/plugin-creator/scripts/read_marketplace_name.py --marketplace-path .agents/plugins/marketplace.json` 输出 `porter-plugins`。
- 已更新 README Codex 安装/更新说明：repo-local marketplace 路径改为 `/Users/porterzhang/AiCode/porter-plugins`；本地开发更新说明使用 cachebuster helper、读取 marketplace 名、重装插件并开启新线程；补充远端 Git marketplace 需要先提交推送，再 `codex plugin marketplace upgrade porter-plugins`。
- cachebuster helper 已刷新插件版本：`1.9.0+codex.20260619221332` -> `1.9.0+codex.20260619152110`，基础版本保持 `1.9.0`。
- 已记录 mutating install touch scope：`codex plugin marketplace add /Users/porterzhang/AiCode/porter-plugins` 和 `codex plugin add porter-codex-plugin@porter-plugins` 只预期触达 Codex 本地 marketplace/config/cache；禁止触达 `~/.claude`、`~/.agents`、`~/plugins`、`plugins/porter-claude-plugin/`。
- `codex plugin --help` 可用；`codex plugin list` 显示已配置 marketplace `porter-plugins`。
- `codex plugin marketplace add /Users/porterzhang/AiCode/porter-plugins` 未成功，原因是本机已存在同名 `porter-plugins` marketplace。
- `rg` 检查 `/Users/porterzhang/.codex/config.toml` 确认现有 `porter-plugins` marketplace source 为远端 `https://github.com/PorterZhang2021/porter-plugins.git`，不是当前工作区路径。
- `codex plugin add porter-codex-plugin@porter-plugins --json` 安装成功，但安装的是远端快照中的 `1.8.0+codex.20260617104225`，不是当前工作区的 `1.9.0+codex.20260619152110`。
- `codex plugin marketplace upgrade porter-plugins --json` 返回 `upgradedRoots: []`，再次安装仍为 `1.8.0+codex.20260617104225`。
- 限制记录：当前远端 marketplace 尚未包含本轮 `1.9.0` 变更；需要在本 slice review/commit 通过后提交并推送，再执行 `codex plugin marketplace upgrade porter-plugins` 和 `codex plugin add porter-codex-plugin@porter-plugins` 才能验证远端安装到 `1.9.0`。本执行阶段不强制 remove/re-add 本机 marketplace，以免改变用户本机 marketplace 来源。

## Task 6: 审查初始化路径、README 和 MVP overview 一致性

- [x] Audit Codex initialization skills.
  - Target: `plugins/porter-codex-plugin/skills/constitution/SKILL.md`
  - Target: `plugins/porter-codex-plugin/skills/codex-md/SKILL.md`
  - Expected: `constitution` writes `.codex/constitution.md`; `codex-md` writes root `AGENTS.md`; neither writes user home configuration.
- [x] Review README Codex workflow documentation.
  - Check recommended solution workflow path.
  - Check install commands and repo-local marketplace path.
  - Check that `delivery-*` is not claimed as implemented in MVP 1.
- [x] Review MVP overview status drift.
  - Target: `.codex/timeline/mvp/workflow-architecture-refactor/MVP_OVERVIEW.md`
  - Check whether 007/008/009 statuses need small same-slice updates after validation.
- [x] Review stage result readiness.
  - Target: `.codex/timeline/mvp/workflow-architecture-refactor/STAGE_OVERVIEW.md`
  - If MVP 1 passes final validation, update result/status only if evidence is complete.
- [x] 验收标准：initialization paths, README, MVP overview, and stage result notes are consistent with current MVP 1 evidence.
- [x] 验证方式：use `rg` for `.codex/constitution.md`, `AGENTS.md`, install paths, `delivery-*`, and MVP status rows; inspect and record any same-slice doc updates.

验证记录：

- 已检查 `constitution/SKILL.md`：只生成或更新 `.codex/constitution.md`，不自动生成 `AGENTS.md`，不提交，不写用户 home 配置。
- 已检查 `codex-md/SKILL.md`：只生成或更新根目录 `AGENTS.md`，前置读取 `.codex/constitution.md`，不写用户 home 配置。
- README 已说明 solution 内容闭环写入 `.codex/timeline/<timeline-name>/`，并说明 `delivery-*` 是 review 后的独立交付线，当前 MVP 不声称完整实现。
- README Codex 安装路径已修正为 `/Users/porterzhang/AiCode/porter-plugins`，并补充远端 marketplace 先提交推送再 upgrade 的说明。
- MVP overview 已把当前工作类型更新为 `test`，007/008 标为 `review-ready`，009 标为 `active`。
- Stage overview 已把 MVP 1 验收路径从旧 `.codex/timeline/<branch-type>/<branch-name>/` 口径修正为 `.codex/timeline/<timeline-name>/` + `current.json` active slice 口径。
- Stage overview 的 MVP 1 `Result` 仍保持`待验收`，未在 review 通过前提前标记完成。

## Task 7: Final verification and scope review

- [x] Run JSON validation.
  - Command: `jq . plugins/porter-codex-plugin/.codex-plugin/plugin.json .agents/plugins/marketplace.json .codex/timeline/refactor-feature-development/current.json .codex/timeline/refactor-feature-development/states/009-test-workflow-structure-sample-validation.json`
- [x] Run whitespace validation.
  - Command: `git diff --check`
- [x] Review changed files.
  - Command: `git status --short`
  - Command: `git diff --name-status`
  - Confirm no `plugins/porter-claude-plugin/` changes.
- [x] Review wording cleanup diff.
  - Confirm changes are prose/localization or documented same-slice consistency fixes.
  - Confirm commands, paths, type names, state names, frontmatter keys, JSON keys, and code blocks were not accidentally translated.
- [x] Update this task file with verification records and completed checkboxes.
- [x] 验收标准：all validation commands pass or limitations are explicitly recorded; diff scope matches the 009 solution; no Claude-side plugin files are modified.
- [x] 验证方式：record outputs or concise result notes for `jq`, `git diff --check`, `git status --short`, `git diff --name-status`, and manual diff review.

验证记录：

- `jq . plugins/porter-codex-plugin/.codex-plugin/plugin.json .agents/plugins/marketplace.json .codex/timeline/refactor-feature-development/current.json .codex/timeline/refactor-feature-development/states/009-test-workflow-structure-sample-validation.json` 通过。
- `plugin.json` 当前版本为 `1.9.0+codex.20260619152110`；`.agents/plugins/marketplace.json` 当前 marketplace 为 `porter-plugins`，source path 为 `./plugins/porter-codex-plugin`。
- `python3 /Users/porterzhang/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py plugins/porter-codex-plugin` 通过。
- `git diff --check` 通过。
- `git status --short` 和 `git diff --name-status` 已检查；改动范围为 009 timeline 文件、README、MVP/STAGE overview、`plugin.json`、solution workflow 相关 skills。
- `git diff --name-only | rg '^plugins/porter-claude-plugin/'` 无输出，确认没有 Claude-side plugin 文件改动。
- 模板输出英文章节名检查无命中：`Timeline Context`、`Type Decision`、`Type-Specific Analysis`、`Visual Model`、`Confirmation Needed`、`Next Step` 等未残留在 solution workflow skills 中。
- 安装验证限制已记录：当前本机 `porter-plugins` marketplace 指向远端 Git snapshot，远端仍是 `1.8.0+codex.20260617104225`；本轮 `1.9.0` 需要 review/commit/push 后再通过 `codex plugin marketplace upgrade porter-plugins` 和 `codex plugin add porter-codex-plugin@porter-plugins` 验证。

## 完成标准

- [x] Workflow structure, frontmatter, reference coverage, state flow, Visual Model rules, and sample flow reviewed.
- [x] Solution workflow related skills user-facing prose localized to Chinese where appropriate.
- [x] Codex plugin install/visibility validation completed or limitation recorded with touch scope.
- [x] Initialization path, README, MVP overview, and stage result consistency reviewed.
- [x] No `plugins/porter-claude-plugin/` changes.
- [x] No unrecorded writes to user home configuration directories.
- [x] Final verification recorded in this task file.
