# 任务：更新 Codex 插件版本号

## Timeline Context

- Solution: `.codex/timeline/refactor-feature-development/solutions/008-build-codex-plugin-version-update.md`
- Timeline: `.codex/timeline/refactor-feature-development/`
- Active slice: `008-build-codex-plugin-version-update`
- State: `.codex/timeline/refactor-feature-development/states/008-build-codex-plugin-version-update.json`
- Branch: `feat/refactor-feature-development`
- Type: `build`
- Work slice: `008`
- Next stage: `$porter-codex-plugin:solution-review`

## Status Legend

- `[ ]` pending
- `[~]` in progress
- `[x]` complete

## Execution Rule

- Execute tasks in order unless a task explicitly says it can run independently.
- This slice only updates Codex plugin manifest metadata and current timeline records.
- Do not perform real plugin installation verification in this slice.
- Do not write to user machine `~/.codex`.
- Do not modify `plugins/porter-claude-plugin/`.
- Do not modify skill behavior, hooks, marketplace paths, or add runtime dependencies.
- Mark each task complete only after its verification step passes or the verification limitation is recorded.
- Every task must include `验收标准` and `验证方式`.

## Task 1: 更新 Codex 插件 manifest 版本号

无业务逻辑，无需测试；通过 manifest 结构验证和版本格式验证。

- [x] Update `plugins/porter-codex-plugin/.codex-plugin/plugin.json`
  - 将 `version` 从 `1.8.0+codex.20260617104225` 更新为新的 `1.9.0+codex.<timestamp>`。
  - 只更新 `version` 字段，不改变 `skills`、`interface`、marketplace 路径或插件能力声明。
- [x] 验收标准：`plugin.json` 的版本号已更新，格式保持 `1.9.0+codex.<timestamp>`，且 manifest 结构保持有效。
- [x] 验证方式：运行 `jq . plugins/porter-codex-plugin/.codex-plugin/plugin.json` 和 `jq -r .version plugins/porter-codex-plugin/.codex-plugin/plugin.json`，人工确认版本格式和 diff 只涉及预期字段。
- [x] 产物验证：无持久构建产物；本 slice 的可观察产物是更新后的 plugin manifest 元数据。
- [x] 记录无产物原因：版本更新只修改 manifest 元数据，不生成额外构建产物。

验证记录：

- `jq . plugins/porter-codex-plugin/.codex-plugin/plugin.json` 通过。
- `jq -r .version plugins/porter-codex-plugin/.codex-plugin/plugin.json` 输出 `1.9.0+codex.20260619221332`。
- `git diff -- plugins/porter-codex-plugin/.codex-plugin/plugin.json` 显示只修改 `version` 字段。

回修记录：

- 根据 review P1 finding 和用户纠偏，将目标版本从 `1.8.0+codex.<timestamp>` 调整为 `1.9.0+codex.<timestamp>`。

## Task 2: 范围和结构验证

无业务逻辑，无需测试；通过结构审查验证。

- [x] 运行 `git diff --check`。
- [x] 运行 `git status --short`，确认 diff 不包含 `plugins/porter-claude-plugin/`。
- [x] 确认本 slice 未执行真实安装验证，且未写入用户本机 `~/.codex`。
- [x] 确认 `.agents/plugins/marketplace.json` 未被修改，除非后续执行阶段发现必须修改并记录原因。
- [x] 验收标准：变更范围符合 solution Scope；无空白错误；不包含 Claude 侧配置或用户本机配置改动。
- [x] 验证方式：运行 `git diff --check`、`git status --short`、`git diff --name-status`，并人工审查 diff 范围。

验证记录：

- `git diff --check` 通过。
- `git status --short` 显示变更范围为当前 timeline 记录和 `plugins/porter-codex-plugin/.codex-plugin/plugin.json`。
- `git status --short | rg 'plugins/porter-claude-plugin|\\.agents/plugins/marketplace.json|\\.codex$|~/.codex'` 无命中。
- `git diff -- .agents/plugins/marketplace.json plugins/porter-claude-plugin` 无输出。
- 本 slice 未执行真实插件安装验证，未写入用户本机 `~/.codex`。

## 完成标准

- [x] Codex 插件 manifest 版本号已更新
- [x] manifest JSON 和版本格式验证已完成
- [x] 未执行安装验证，且已保留给后续验证 slice
- [x] 范围和结构验证已完成
