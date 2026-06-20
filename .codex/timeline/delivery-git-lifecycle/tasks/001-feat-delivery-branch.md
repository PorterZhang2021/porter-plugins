# 任务：新增 delivery-branch Git 分支入口

## 时间线上下文

- 方案：`.codex/timeline/delivery-git-lifecycle/solutions/001-feat-delivery-branch.md`
- 时间线：`.codex/timeline/delivery-git-lifecycle/`
- 当前切片：`001-feat-delivery-branch`
- 状态：`.codex/timeline/delivery-git-lifecycle/states/001-feat-delivery-branch.json`
- 分支：`feat/delivery-git-lifecycle`
- 类型：`feat`
- 下一阶段：`$porter-codex-plugin:solution-execute`

## 状态说明

- `[ ]` 待处理
- `[~]` 进行中
- `[x]` 已完成

## 执行规则

- 除非任务明确说明可独立执行，否则按顺序执行。
- 前置测试、复现步骤、度量或验证准备完成前，不要开始实现任务。
- 只有验证步骤通过或验证限制已记录后，才能把任务标记为完成。
- 每个任务必须包含 `验收标准` 和 `验证方式`；没有可观察证据时不得标记完成。

## Task 1：新增 delivery-branch skill 骨架

无业务逻辑，无需测试；通过结构审查验证。

- [x] 创建 `plugins/porter-codex-plugin/skills/delivery-branch/SKILL.md`。
- [x] 写入完整 frontmatter，至少包含 `name: delivery-branch` 和清晰的 `description`。
- [x] 写明阶段边界：只创建、切换或重命名普通 Git 分支。
- [x] 明确禁止在本 skill 中执行 solution、task、execute、review、commit、push、merge 或 create PR。
- [x] 验收标准：`delivery-branch` skill frontmatter 完整，路径和命名符合 kebab-case；阶段边界覆盖 SOLUTION.md 中“不 commit、不 push、不 merge、不 create PR、不写 solution/task/review”的要求。
- [x] 验证方式：用 `sed -n '1,80p' plugins/porter-codex-plugin/skills/delivery-branch/SKILL.md` 检查 frontmatter 和阶段边界；用 `rg -n "commit|push|merge|create PR|solution-task" plugins/porter-codex-plugin/skills/delivery-branch/SKILL.md` 检查禁止项和下一步提示是否明文可见。

## Task 2：定义起步模式

无业务逻辑，无需测试；通过结构审查验证。

- [x] 在 `delivery-branch` 中定义起步模式的入口语义：用户可以用自然语言描述要开始的工作。
- [x] 明确必须整理并展示候选 `type`、`name`、`base`，等待用户确认后才能创建或切换分支。
- [x] 明确 base 分支必须由用户确认，不能静默使用远端默认分支。
- [x] 复用旧 `new-branch` 中远端 base 检查、本地 fallback、`git merge --ff-only` 失败停止等安全规则。
- [x] 明确创建或切换普通分支后写入 `branch.<branch>.porter-base`。
- [x] 明确起步模式完成后停止，并提示用户显式调用 `$porter-codex-plugin:solution`。
- [x] 验收标准：起步模式满足 SOLUTION.md 中 type/name/base 确认、porter-base 记录、普通 Git 分支、完成后停止的要求。
- [x] 验证方式：审查 `delivery-branch/SKILL.md` 中起步模式章节，确认包含 `type`、`name`、`base`、`branch.<branch>.porter-base`、`$porter-codex-plugin:solution`，并确认没有 worktree 创建规则。

## Task 3：定义 rename checkpoint 模式

无业务逻辑，无需测试；通过结构审查验证。

- [x] 在 `delivery-branch` 中定义 rename checkpoint 模式的触发条件：用户显式要求处理分支重命名检查点，或被其他 workflow 提示后显式调用。
- [x] 明确读取 `.codex/timeline/<timeline-name>/current.json` 和 active solution 文件。
- [x] 明确从 active solution 的`分支重命名检查点`读取当前分支、建议分支、是否需要重命名和理由。
- [x] 明确需要检查当前分支、工作区、upstream、远端同名分支和可能的 PR 状态。
- [x] 明确展示影响范围并等待用户确认后，才允许执行本地分支 rename。
- [x] 明确不会删除远端旧分支、不会 force push、不会修改 PR。
- [x] 明确 rename 后需要校验或迁移 `branch.<new-branch>.porter-base`。
- [x] 明确完成后停止，并提示回到原 workflow，例如 `$porter-codex-plugin:solution-task`。
- [x] 验收标准：rename checkpoint 模式满足 SOLUTION.md 中读取 active solution、展示风险、确认后本地 rename、禁止远端破坏性操作的要求。
- [x] 验证方式：审查 `delivery-branch/SKILL.md` 中 rename checkpoint 章节，确认包含 `current.json`、`分支重命名检查点`、`upstream`、`remote`、`PR`、`force push`、`porter-base` 和 `$porter-codex-plugin:solution-task`。

## Task 4：更新 README 推荐路径

无业务逻辑，无需测试；通过结构审查验证。

- [x] 在 README 的 Codex plugin / workflow 说明中加入 `$porter-codex-plugin:delivery-branch`。
- [x] 说明 `delivery-branch -> solution` 是新 delivery workflow 的推荐起步路径。
- [x] 说明当前 slice 只新增 `delivery-branch`；`delivery-commit`、`delivery-push`、`delivery-create-pr`、`delivery-merge-to-base` 仍是后续 slice。
- [x] 说明旧 `new-branch` 保留，不在本 slice 删除或替换。
- [x] 验收标准：README 能解释 `delivery-branch -> solution` 的推荐起步路径，并避免让用户误以为完整 delivery workflow 已全部实现。
- [x] 验证方式：用 `rg -n "delivery-branch|delivery-commit|new-branch|solution" README.md` 检查 README 中新旧入口关系和当前实现范围。

## Task 5：检查插件 manifest/cachebuster

无业务逻辑，无需测试；通过结构审查验证。

- [x] 检查 `plugins/porter-codex-plugin/.codex-plugin/plugin.json` 是否需要为新增 skill 刷新 cachebuster 或相关元数据。
- [x] 如项目约定需要刷新 cachebuster，更新对应字段；如不需要，记录原因在执行总结中。
- [x] 保持 JSON 可解析，不引入隐式配置。
- [x] 验收标准：Codex 插件 manifest 与新增 `delivery-branch` skill 的暴露方式一致；如更新 JSON，必须语法有效。
- [x] 验证方式：执行 `jq . plugins/porter-codex-plugin/.codex-plugin/plugin.json >/dev/null`；如修改 manifest，用 `git diff -- plugins/porter-codex-plugin/.codex-plugin/plugin.json` 审查变更范围。

## Task 6：最终结构验证

无业务逻辑，无需测试；通过结构审查验证。

- [x] 检查新增 skill 文件路径、frontmatter、标题和阶段边界。
- [x] 检查 README 只描述本 slice 已实现的 `delivery-branch`，没有提前承诺后续 delivery skill 已可用。
- [x] 检查未修改 `plugins/porter-claude-plugin/`。
- [x] 检查未删除旧 `new-branch`。
- [x] 检查没有新增运行时依赖、构建工具或测试框架。
- [x] 检查 timeline JSON 仍可解析。
- [x] 运行 `git diff --check`。
- [x] 验收标准：SOLUTION.md 的验收标准均有对应产物或检查记录；变更范围只覆盖 Codex 插件、README、manifest/cachebuster 和当前 timeline 记录。
- [x] 验证方式：执行 `jq . .codex/timeline/delivery-git-lifecycle/current.json .codex/timeline/delivery-git-lifecycle/states/001-feat-delivery-branch.json >/dev/null`、`git diff --check`、`git status --short`，并审查 `git diff --stat`。
