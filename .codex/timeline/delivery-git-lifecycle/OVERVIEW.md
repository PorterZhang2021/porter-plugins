# Timeline Overview: Solution-Git 交付整合

## 角色

本文件是 `delivery-git-lifecycle` timeline 的阶段级 overview，不是单个 solution slice。

本阶段已经从“新增一组 delivery Git skill”收敛为“让 Codex plugin 以 solution workflow 为主线，并把 review pass 后的 commit 确认点纳入状态契约”。

## 背景判断

MVP 1 已完成内容闭环：

```text
solution -> solution-task -> solution-execute -> solution-review
```

重新评估后，本阶段不再沉淀 `delivery-branch`、`delivery-commit`、`delivery-push`、`delivery-create-pr`、`delivery-merge-to-base` 这类 Git 操作 skill。

原因：

- Codex app 已经提供分支、worktree、commit、push、PR 等 Git 能力。
- 普通 Git 命令也足以完成交付动作。
- 插件更有价值的部分是保留 solution timeline、slice state、review 回修和 commit message 可检索契约。

## 最终主线

```text
solution
  -> solution-task
  -> solution-execute
  -> solution-review
     -> pass: awaiting_user_commit_confirm
     -> needs-fix: awaiting_solution_execute_from_review
  -> user confirms commit
  -> committing
  -> committed
```

约束：

- `main` / `master` 是 protected branch guard；solution 正式写入、task、execute、review 不在主分支执行。
- 不强制分支名必须是 `<type>/<name>`。
- 不要求 `branch.<branch>.porter-base`。
- 不要求先调用任何分支创建 skill。
- `solution-task` 写入前通过窄用途 Codex hook 自动将本地分支名对齐到 `<type>/<solution-slug>`。
- commit hash 不写为 state 必填字段。
- commit type 限定为 `feat`、`fix`、`refactor`、`perf`、`test`、`docs`、`build`、`ci`、`chore`、`style`。
- commit message 必须携带 `Codex-Timeline` 和 `Codex-Slice` trailer。

## Commit Message Contract

commit subject 必须符合 Conventional Commits：

```text
<type>(<scope>): <summary>
```

commit message 必须包含 trailer：

```text
Codex-Timeline: <timeline-name>
Codex-Slice: <slice-id-type-slug>
```

示例：

```text
refactor(workflow): consolidate codex plugin around solution lifecycle

Codex-Timeline: delivery-git-lifecycle
Codex-Slice: 002-refactor-solution-git-integration
```

检索方式：

```bash
git log --grep 'Codex-Slice: 002-refactor-solution-git-integration'
```

插件随包提供 `plugins/porter-codex-plugin/scripts/install-solution-commit-msg-hook.sh`。在目标仓库显式安装后，普通 `git commit` 会通过 `commit-msg` hook 自动执行同一套检查；插件安装本身不隐式写入 `.git/hooks`。

`solution-task` 前置分支名对齐由 Codex `PreToolUse` hook 处理。该 hook 只在 active slice state 为 `awaiting_solution_task` 且即将写入 task 文件时执行本地 `git branch -m`；不因 state 文件或 `current.json` 写入触发；不会 push、不会改远端、不会处理 PR。

Solution lifecycle guard 也由 Codex `PreToolUse` hook 处理。active slice 处于 `awaiting_user_commit_confirm` 或 `committing` 时，hook 阻止继续写实现、文档、配置、task、solution 或 review 文件；必须完成 commit confirmation 或回到 `$porter-codex-plugin:solution-execute`。安装 Git `commit-msg` hook 后，未终止 active solution state 不能退化为只检查 commit subject。

## Final Cleanup 结论

删除前已创建恢复点：

```text
v1.9.0
```

`v1.9.0` 指向删除旧体系前的当前 HEAD，作为旧 branch/worktree workflow 的恢复点。

2.0.0 cleanup 删除 Codex plugin 源目录中的旧 Git/plan workflow：

- `new-branch*`
- `plan*`
- `task*`
- `execute*`
- `review*`
- `commit*`
- `merge*`
- `create-pr`
- `analyze-bug`
- 旧 Codex `workflow-guard` hooks

保留：

- `solution`
- `solution-task`
- `solution-execute`
- `solution-review`
- `skill-recommender`
- `codex-md`
- `codex-permissions`
- `constitution`
- `explain*`
- `learn-english`
- `web-service-tech-selection`

## Slice 记录

| Slice | Type | Goal | Status |
| --- | --- | --- | --- |
| 001 | feat | 原计划新增 `delivery-branch`，后续确认不需要；实现产物撤回。 | cancelled |
| 002 | refactor | 整合 002-010：solution 去强分支化、review pass commit confirmation、commit message contract、README 更新、v1.9.0 tag、旧 workflow 删除、2.0.0 版本跃迁；回修补齐 commit-msg hook、type 白名单和 solution-task branch alignment hook。 | awaiting_solution_review |

## 当前 Active Slice

- Active slice：`002-refactor-solution-git-integration`
- Solution：`.codex/timeline/delivery-git-lifecycle/solutions/002-refactor-solution-git-integration.md`
- Task：`.codex/timeline/delivery-git-lifecycle/tasks/002-refactor-solution-git-integration.md`
- Review：`.codex/timeline/delivery-git-lifecycle/reviews/002-refactor-solution-git-integration.md`
- State：`.codex/timeline/delivery-git-lifecycle/states/002-refactor-solution-git-integration.json`
- Current state：`awaiting_solution_review`
- Next action：重新执行 `$porter-codex-plugin:solution-review`，确认回修后的 hook/type 校验闭环

## 验收方向

- `solution` 不再要求 `<branch-type>/<branch-name>`。
- `solution-task` / `solution-execute` / `solution-review` 以 `current.json` 和 active state gate 为主。
- `solution-review` pass 后进入 `awaiting_user_commit_confirm`。
- review 发现问题或用户在 commit 确认前提出修改时，回到 `awaiting_solution_execute_from_review`。
- commit confirmation 使用普通 Git commit，不依赖独立 commit skill。
- 插件随包提供可显式安装的 Git `commit-msg` hook；安装后普通 `git commit` 自动校验 commit message contract。
- commit message validator 限制 type 白名单。
- `solution-task` 前置分支名对齐 hook 不 push、不改远端；目标分支冲突或 upstream 风险时停止。
- solution lifecycle guard 阻止未 review/未 commit confirmation 的普通 commit 绕过。
- commit message 可以用脚本验证 `Codex-Timeline` / `Codex-Slice` trailer。
- README 不再推荐旧 branch/worktree workflow。
- Codex plugin 版本跃迁到 `2.0.0+codex.*`。
- 插件结构、skill frontmatter、JSON 和 Markdown 基本验证通过。
