# AI Workflow Plugins

个人 AI 编程助手配置仓库，用来沉淀可复用的 Skills、Agents、Hooks 和协作规则。

当前仓库同时维护 Claude Code 和 Codex 两套插件入口：

- Claude Code：`porter-claude-plugin`
- Codex：`porter-codex-plugin`

## Repository Layout

| 目录 | 内容 |
| --- | --- |
| `plugins/porter-claude-plugin/` | Claude Code 插件，包含 Skills、Agents、Hooks 和插件元数据。 |
| `plugins/porter-codex-plugin/` | Codex 插件，包含 solution-first Skills、Codex hook、Git hook 脚本和插件元数据。 |
| `.claude-plugin/marketplace.json` | Claude Code marketplace 入口。 |
| `.agents/plugins/marketplace.json` | Codex repo-local marketplace 入口。 |
| `.claude/` | 当前仓库自身的 Claude Code 项目配置。 |
| `AGENTS.md` | 当前仓库自身的 Codex 协作说明。 |
| `sync.sh` | 跨 AI 工具配置同步脚本。 |

## Claude Code

### 安装插件

前置要求：

- 已安装 Claude Code。

添加 marketplace：

```bash
claude plugin marketplace add https://github.com/PorterZhang2021/porter-plugins
```

安装插件：

```bash
claude plugin install porter-claude-plugin
```

安装后重启 Claude Code，使 Skills、Agents 和 Hooks 生效。

### 手动安装

也可以手动克隆本仓库后，将 Claude 插件内容复制到 Claude Code 对应配置目录：

```text
plugins/porter-claude-plugin/skills/  -> ~/.claude/skills/
plugins/porter-claude-plugin/agents/  -> ~/.claude/agents/
plugins/porter-claude-plugin/hooks/   -> ~/.claude/hooks/
```

### 验证 Claude Code 安装

重启 Claude Code 后，在任意项目中输入 `/plan` 或 `/commit`。如果补全中出现对应 Skill，说明安装成功。

## Codex

Codex 使用独立插件入口，不再推荐逐个安装单个 skill。

### 安装插件

添加当前仓库作为 repo-local marketplace：

```bash
codex plugin marketplace add /Users/porterzhang/AiCode/porter-plugins
```

安装 Codex 插件：

```bash
codex plugin add porter-codex-plugin@porter-plugins
```

安装后开启新线程，使插件 Skills 和 Codex hook 生效。Git `commit-msg` hook 需要在目标仓库显式安装。

### 本地开发更新

修改本仓库内 Codex 插件后，使用 plugin-creator 的 cachebuster helper 刷新插件版本后再重装：

```bash
python3 /Users/porterzhang/.codex/skills/.system/plugin-creator/scripts/update_plugin_cachebuster.py plugins/porter-codex-plugin
python3 /Users/porterzhang/.codex/skills/.system/plugin-creator/scripts/read_marketplace_name.py --marketplace-path .agents/plugins/marketplace.json
codex plugin add porter-codex-plugin@porter-plugins
```

重装后开启新 Codex 线程，使更新后的 Skills 和 Codex hook 被加载。Git `commit-msg` hook 如需更新，需在目标仓库重新运行安装脚本。

如果本机已经把 `porter-plugins` 配置为远端 Git marketplace，直接安装会使用远端快照。此时需要先提交并推送插件更新，再刷新 marketplace：

```bash
codex plugin marketplace upgrade porter-plugins
codex plugin add porter-codex-plugin@porter-plugins
```

### Codex 适配说明

- Codex 插件 skill 使用 `$porter-codex-plugin:<skill>` 显式调用；`/plan`、`/review` 等是 Codex 内置 slash command，不等同于插件 skill。
- Claude 专属入口在 Codex 插件中使用 Codex 专属名称：
  - `claude-md` 对标为 `codex-md`
  - `setup-permissions` 对标为 `codex-permissions`
- Codex 2.0.0 起，Codex 插件主开发流收敛为 solution workflow；分支创建、worktree、push、PR 和 merge 交给 Codex app 原生 Git 能力、UI 或普通 Git 命令。
- Codex solution workflow 使用 `.codex/timeline/<timeline-name>/current.json` 和同一 active slice 的过程文件记录阶段状态；自然语言“继续”“修一下”不等同于显式调用下一阶段 skill。
- `main` / `master` 只作为 protected branch guard：solution 正式写入、task、execute、review 不在主分支执行；不强制分支名必须是 `<type>/<name>`。

## Hooks

Claude Code 插件和 Codex 插件各自维护独立 hooks。

### Claude Code Hooks

Claude Code hooks 位于 `plugins/porter-claude-plugin/hooks/`，用于保护 `.claude/worktrees/` 中的写入路径，避免在 worktree 中误写到 worktree 外部。

### Codex Hooks

Codex 2.0.0 不再打包旧 branch/worktree workflow guard。Solution workflow 的阶段边界由 `.codex/timeline/<timeline-name>/current.json` 和 `states/<slice>.json` 显式记录，并由对应 solution skill 读取 state gate。

Codex 插件保留两个窄用途 `PreToolUse` hook：

- `solution-task` branch alignment：当 active slice 处于 `awaiting_solution_task`，且 `$porter-codex-plugin:solution-task` 即将写入该 slice 的 task 文件时，hook 会把本地当前分支重命名为 `<type>/<solution-slug>`。为避免和 `solution` 阶段重复，hook 不因 state 文件或 `current.json` 写入触发。如果目标分支已存在，或当前分支已有 upstream 配置，hook 会停止并要求人工确认；不会 push、不会改远端、不会处理 PR。
- solution lifecycle guard：当 active slice 已 review pass 并处于 `awaiting_user_commit_confirm` 或 `committing` 时，hook 会阻止继续写实现、文档、配置、task、solution 或 review 文件；commit confirmation 只能用单条非复合 Bash 命令安装本仓库 `commit-msg` hook、显式 stage active state 文件、review contract 文件和 contract 中记录的 `reviewed_paths`，并要求内容 blob 与 file mode 匹配 contract，不会放行 `git add .`、`git add -A`、`git add --all` 或复合写入/stage 命令。hook 也会在 Codex 中阻止未终止 active solution 直接执行 `git commit`，但当前 staged committed slice 已匹配时不会被其它 stale current 卡住。

Codex 插件随包提供 Git `commit-msg` hook。该 hook 不会在插件安装时偷偷写入项目 `.git/hooks`；需要在目标仓库中显式安装：

```bash
plugins/porter-codex-plugin/scripts/install-solution-commit-msg-hook.sh --repo .
```

安装后，普通 `git commit` 会触发检查：

- commit subject 必须是 Conventional Commit，且 type 只能是 `feat`、`fix`、`refactor`、`perf`、`test`、`docs`、`build`、`ci`、`chore`、`style`。
- 如果仓库存在未终止 active solution state，必须先按 state 中记录的下一步完成 review/回修/commit confirmation；不能只靠合法 subject 绕过 lifecycle。
- 如果仓库 staged 了 `committed` solution state，message 必须包含对应的 `Codex-Timeline` 和 `Codex-Slice` trailer，且 staged 文件只能是该 state 文件、固定路径 review contract 文件或 contract 中记录的 `reviewed_paths`，staged blob 与 file mode 都必须匹配 review contract。state 记录的 `review_contract_blob` 和本地 `.git/porter-solution-contracts/<timeline>/<slice>.contract.blob` anchor 还必须匹配 staged contract blob，防止 commit 前改写白名单。

也可以手动校验 review pass 后的 commit message：

```bash
plugins/porter-codex-plugin/scripts/validate-solution-commit-message.sh \
  --message-file .git/COMMIT_EDITMSG \
  --timeline <timeline-name> \
  --slice <slice-id-type-slug> \
  --type <type>
```

## Skills

| Skill | Claude Code | Codex | 说明 |
| --- | --- | --- | --- |
| `solution` | 否 | 是 | 进入 pre-solution discussion，确认 type、timeline、目标和范围后写入 active slice 的 solution 与 state。 |
| `solution-task` | 否 | 是 | 从 active slice 的 solution 文件生成 task 文件，并推进到执行阶段。 |
| `solution-execute` | 否 | 是 | 执行 active slice 的 task，更新 task 和 state，完成后进入 review；review 后有新修改时回到回修执行。 |
| `solution-review` | 否 | 是 | 审查 active slice 的实现和过程记录；pass 后进入用户 commit 确认态，有问题则回到 execute。 |
| `timeline-overview` | 否 | 是 | 判断目标是否需要多个 solution slice，并维护 timeline 级 `OVERVIEW.md` / `CHANGELOG.md`。 |
| `skill-recommender` | 否 | 是 | 根据用户意图推荐当前 Codex 插件中的合适 skill。 |
| `claude-md` | 是 | 否 | 为 Claude Code 项目生成 CLAUDE.md。 |
| `codex-md` | 否 | 是 | 为 Codex 项目生成 AGENTS.md。 |
| `constitution` | 是 | 是 | 为新项目结对编写开发宪法。 |
| `setup-permissions` | 是 | 否 | 为 Claude Code 项目配置 `.claude/settings.json`。 |
| `codex-permissions` | 否 | 是 | 为 Codex 项目配置 `.codex/config.toml` 或 AGENTS.md 权限规则。 |
| `explain` | 是 | 是 | 生成项目解释文档。 |
| `explain-explore` | 是 | 是 | 探索文件，收集文档所需上下文，返回结构化 findings。 |
| `explain-write` | 是 | 是 | 基于 findings 生成并写入解释文档。 |
| `learn-english` | 是 | 是 | 意图确认和英语纠错辅助，防止英文表达不精确导致执行偏差。 |
| `web-service-tech-selection` | 是 | 是 | 为 Web 后端 / HTTP API 服务结对生成或审查前置技术选型文档。 |

## Recommended Workflows

Solution 内容闭环（Codex 默认开发流）：

```text
$porter-codex-plugin:solution
  -> $porter-codex-plugin:solution-task
  -> $porter-codex-plugin:solution-execute
  -> $porter-codex-plugin:solution-review
     -> pass: awaiting_user_commit_confirm
     -> needs-fix: $porter-codex-plugin:solution-execute
  -> user confirms commit
  -> committed
```

这条线用于小 feature、小 fix、小 perf/test/docs/build 等需求，先完成方案、任务、执行和审查。过程记录写入 `.codex/timeline/<timeline-name>/`：

```text
.codex/timeline/<timeline-name>/
  current.json
  solutions/<slice-id>-<type>-<slug>.md
  tasks/<slice-id>-<type>-<slug>.md
  reviews/<slice-id>-<type>-<slug>.md
  reviews/<slice-id>-<type>-<slug>.contract.json
  states/<slice-id>-<type>-<slug>.json
```

Review pass 后不再调用独立 commit skill，而是进入 `awaiting_user_commit_confirm`。用户确认后，由 Codex 使用普通 Git commit，并在 message 中写入：

```text
<type>(<scope>): <summary>

Codex-Timeline: <timeline-name>
Codex-Slice: <slice-id-type-slug>
```

commit type 必须属于 solution workflow 支持的类型：`feat`、`fix`、`refactor`、`perf`、`test`、`docs`、`build`、`ci`、`chore`、`style`。

如果已在当前仓库运行 `plugins/porter-codex-plugin/scripts/install-solution-commit-msg-hook.sh --repo .`，普通 `git commit` 会自动执行同一套检查。

Review pass 会写入独立 review contract 文件，记录本次 review 已覆盖、允许进入本次 commit 的非 state 文件，以及每个路径的 blob 与 file mode；已审查的删除使用 `__deleted__` 标记。state 只记录 `review_contract` 和 `review_contract_blob`，并把同一个 contract blob 写入本地 `.git/porter-solution-contracts/<timeline>/<slice>.contract.blob` anchor。用户确认 commit 后，只显式 stage contract 文件、contract 中的路径和 active state 文件；如果要加入新文件、同路径新内容、mode 变化或新改动，先回到 `$porter-codex-plugin:solution-execute` 回修再 review。

Commit 成功后，slice state 进入 `committed`，且不再写 `next_skill`。后续可通过以下命令检索对应提交：

```bash
git log --grep 'Codex-Slice: <slice-id-type-slug>'
```

Codex 原生 Git 能力继续负责分支、worktree、push、PR 和 merge；这些动作不再由 Porter Codex 插件维护单独 skill 链。

Solution workflow state：

| 文件 | 作用 |
| --- | --- |
| `.codex/timeline/<timeline-name>/current.json` | 只保存 active slice 指针。 |
| `.codex/timeline/<timeline-name>/states/<slice-id>-<type>-<slug>.json` | 保存完整 workflow state、当前 skill、下一 skill 或 commit confirmation 信息。 |

Timeline overview（可选范围整理）：

```text
$porter-codex-plugin:timeline-overview
  -> 判断目标是否适合单个 solution slice
  -> 多 slice 时维护 .codex/timeline/<timeline-name>/OVERVIEW.md
  -> 收口时维护 .codex/timeline/<timeline-name>/CHANGELOG.md
```

这条线只在目标范围不确定、连续多个 solution slice 需要整理，或一条 timeline 需要收口总结时使用。默认小目标仍直接进入 `$porter-codex-plugin:solution`。

如果 `$porter-codex-plugin:solution` 的前置讨论发现目标明显不适合单个 slice，应先停止写入 solution 文件，转而调用 `$porter-codex-plugin:timeline-overview` 讨论并确认多个 slice；`timeline-overview` 写入 `OVERVIEW.md` 后，再回到 `$porter-codex-plugin:solution` 创建第一个清晰 slice。

`OVERVIEW.md` / `CHANGELOG.md` 是 timeline 级人类可读账本；其中的 `candidate`、`active`、`committed`、`deferred`、`cancelled` 只用于总览，不替代 `.codex/timeline/<timeline-name>/states/<slice-id>-<type>-<slug>.json` 的 workflow gate。active slice 未结束时，应继续 state 中记录的 `next_skill`。

Codex 项目初始化：

```text
$porter-codex-plugin:constitution -> $porter-codex-plugin:codex-md -> $porter-codex-plugin:codex-permissions
```

## Agents

Claude Code 插件包含以下自定义 Agent：

| Agent | 说明 |
| --- | --- |
| `bug-analyzer` | 深度代码执行流分析与根因调查专家。 |
| `code-reviewer` | 代码审查专家，覆盖安全、性能与可靠性。 |
| `dev-planner` | 将需求分解为可执行开发计划。 |
| `story-generator` | 从各类输入生成带验收标准的用户故事。 |
| `ui-sketcher` | 将需求转化为 ASCII 界面设计和交互规范。 |

Codex 插件不打包 Claude Code Agents；Codex `solution-task` 前置分支对齐 hook 位于 `plugins/porter-codex-plugin/hooks/`，solution commit hook 脚本位于 `plugins/porter-codex-plugin/scripts/`。

## Sync

`sync.sh` 可以将其他 AI 工具的配置导入本仓库对应插件目录。

查看支持的工具：

```bash
./sync.sh --list
```

预览同步：

```bash
./sync.sh --dry-run
```

直接指定工具：

```bash
./sync.sh codex
./sync.sh claude
```

支持工具：

| 工具 | 默认来源 | 默认目标 |
| --- | --- | --- |
| `kimi` | `~/.kimi` | 当前仓库根目录的同名目录 |
| `codex` | `~/.codex` | `plugins/porter-codex-plugin/` |
| `claude` | `~/.claude` | `plugins/porter-claude-plugin/` |

### Sync Ignore

在源目录创建 `.syncignore` 文件可以排除不需要同步的内容，语法类似 `.gitignore`：

```bash
draft/
explain/TASK.md
*.tmp
```

`.syncignore` 只在同步时生效，不会同步到目标目录。
