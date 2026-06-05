# AI Workflow Plugins

个人 AI 编程助手配置仓库，用来沉淀可复用的 Skills、Agents、Hooks 和协作规则。

当前仓库同时维护 Claude Code 和 Codex 两套插件入口：

- Claude Code：`porter-claude-plugin`
- Codex：`porter-codex-plugin`

## Repository Layout

| 目录 | 内容 |
| --- | --- |
| `plugins/porter-claude-plugin/` | Claude Code 插件，包含 Skills、Agents、Hooks 和插件元数据。 |
| `plugins/porter-codex-plugin/` | Codex 插件，包含全量工作流 Skills、Hooks 和插件元数据。 |
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
codex plugin marketplace add /Users/poterzhang/AIProjects/claude-plugins
```

安装 Codex 插件：

```bash
codex plugin add porter-codex-plugin@porter-plugins
```

安装后开启新线程，使插件 Skills 和 Hooks 生效。

### Codex 适配说明

- Codex 插件包含所有现有工作流 Skills 和 Codex workflow Hooks。
- Codex 插件 skill 使用 `$porter-codex-plugin:<skill>` 显式调用；`/plan`、`/review` 等是 Codex 内置 slash command，不等同于插件 skill。
- Claude 专属入口在 Codex 插件中使用 Codex 专属名称：
  - `claude-md` 对标为 `codex-md`
  - `setup-permissions` 对标为 `codex-permissions`
- Codex 版 `new-branch` 使用 `.codex/worktrees/<type>/<name>` worktree 模型。
- Codex 版执行类 skill 使用 Codex 原生命令、审批和对话能力替代 Claude 专属工具。
- Codex workflow Hooks 使用 `WORKFLOW_STATE.json` 保护阶段边界；自然语言“继续”“修一下”不等同于显式调用下一阶段 skill。

## Hooks

Claude Code 插件和 Codex 插件各自维护独立 hooks。

### Claude Code Hooks

Claude Code hooks 位于 `plugins/porter-claude-plugin/hooks/`，用于保护 `.claude/worktrees/` 中的写入路径，避免在 worktree 中误写到 worktree 外部。

### Codex Hooks

Codex hooks 位于 `plugins/porter-codex-plugin/hooks/`。当前 `hooks.json` 定义了两个 `PreToolUse` 规则：

| Matcher | 作用 |
| --- | --- |
| `apply_patch|Edit|Write` | 写入类工具执行前检查 workflow 阶段和 worktree 写入路径。 |
| `Bash` | Bash 命令执行前检查可能的写入路径和 workflow 阶段。 |

两个规则都调用 `plugins/porter-codex-plugin/hooks/workflow-guard.sh`。Guard 的核心约束：

- 在 `.codex/worktrees/<type>/<name>` 中工作时，写入路径必须留在当前 worktree 内。
- workflow 阶段保护依赖 `plan/<type>/<branch-name>/WORKFLOW_STATE.json`。
- `awaiting_task` 阶段阻止修改实现文件，只允许更新 `ANALYSIS.md` 或 `WORKFLOW_STATE.json`。
- `awaiting_execute` 阶段阻止修改实现文件，只允许更新 `TASK.md` 或 `WORKFLOW_STATE.json`。
- `executing` / `execution_allowed` 阶段允许实现文件修改。

`plugins/porter-codex-plugin/hooks/workflow-guard.test.sh` 是 guard 行为的轻量验证脚本。

## Skills

| Skill | Claude Code | Codex | 说明 |
| --- | --- | --- | --- |
| `new-branch` | 是 | 是 | 创建符合规范的 Git 功能分支；Codex 版使用 `.codex/worktrees/`。 |
| `plan` | 是 | 是 | 按分支类型结对生成规划文档 PLAN.md。 |
| `task` | 是 | 是 | 按 TDD 结构生成任务清单 TASK.md。 |
| `execute` | 是 | 是 | 按分支类型节奏逐任务执行 TASK.md。 |
| `review` | 否 | 是 | 可选的 Codex 提交前审查，优先使用独立审查上下文检查本次实现或修复。 |
| `commit` | 是 | 是 | 按 Conventional Commits 规范创建格式化提交。 |
| `merge-to-main` | 是 | 是 | 将当前分支合并回主分支。 |
| `create-pr` | 是 | 是 | 推送分支并创建 Pull Request。 |
| `analyze-bug` | 是 | 是 | 复现、定位根因并输出 Bug 分析报告。 |
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

功能开发：

```text
$porter-codex-plugin:new-branch -> $porter-codex-plugin:plan -> $porter-codex-plugin:task -> $porter-codex-plugin:execute -> $porter-codex-plugin:review? -> $porter-codex-plugin:commit -> $porter-codex-plugin:merge-to-main
```

Bug 修复：

```text
$porter-codex-plugin:new-branch -> $porter-codex-plugin:analyze-bug -> $porter-codex-plugin:task -> $porter-codex-plugin:execute -> $porter-codex-plugin:review? -> $porter-codex-plugin:commit -> $porter-codex-plugin:merge-to-main
```

Codex workflow state：

| Skill | State 更新 |
| --- | --- |
| `$porter-codex-plugin:analyze-bug` | 分析完成后写入 `awaiting_task`。 |
| `$porter-codex-plugin:task` | 任务清单完成后写入 `awaiting_execute`。 |
| `$porter-codex-plugin:execute` | 执行开始时写入 `executing`，执行完成后写入 `awaiting_review_or_commit`。 |

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

Codex 插件不打包 Claude Code Agents；Codex workflow hooks 位于 `plugins/porter-codex-plugin/hooks/`。

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
