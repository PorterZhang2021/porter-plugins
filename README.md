# AI Workflow Plugins

个人 AI 编程助手配置仓库，用来沉淀可复用的 Skills、Agents、Hooks 和协作规则。

当前仓库首先支持 Claude Code plugin，同时也把 `skills/<skill-name>/` 设计成可被 Codex 单独安装和复用的 skill 目录。

## Repository Layout

| 目录 | 内容 |
| --- | --- |
| `skills/` | 16 个工作流 Skill，单个目录可被 Claude Code 和 Codex 复用。 |
| `agents/` | 5 个 Claude Code 自定义 Agent。 |
| `hooks/` | Claude Code hooks 配置。 |
| `.claude-plugin/` | Claude Code 插件元数据。 |
| `.claude/` | 项目宪法和 Claude Code 项目配置。 |
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

也可以手动克隆本仓库后，将目录内容复制到 Claude Code 对应配置目录：

```text
skills/  -> ~/.claude/skills/
agents/  -> ~/.claude/agents/
hooks/   -> ~/.claude/hooks/
```

### 验证 Claude Code 安装

重启 Claude Code 后，在任意项目中输入 `/plan` 或 `/commit`。如果补全中出现对应 Skill，说明安装成功。

## Codex

Codex 不安装整个 Claude Code plugin，但可以安装本仓库中的单个 skill 目录。

适用目录结构：

```text
skills/<skill-name>/
  SKILL.md
```

### 使用 skill-installer 安装

前提：

```text
目标 skill 已提交并推送到 GitHub。
```

在 Codex 中使用内置 `skill-installer`，提供 GitHub repo 和 skill 路径：

```text
使用 skill-installer，从 PorterZhang2021/porter-plugins 安装 skills/web-service-tech-selection
```

等价安装源：

```text
repo: PorterZhang2021/porter-plugins
path: skills/web-service-tech-selection
```

安装结果会写入：

```text
~/.codex/skills/web-service-tech-selection/
  SKILL.md
```

安装完成后重启 Codex，使新 skill 生效。

### 本地验证安装流程

如果只是验证 `skill-installer` 是否可用，可以使用临时安装名，避免覆盖已有 skill：

```bash
python3 ~/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py \
  --repo PorterZhang2021/porter-plugins \
  --ref master \
  --path skills/plan \
  --name codex-install-test-skill
```

验证完成后删除临时 skill：

```bash
rm -rf ~/.codex/skills/codex-install-test-skill
```

### 手动安装单个 Skill

也可以直接复制单个 skill 目录：

```text
skills/web-service-tech-selection/
```

到：

```text
~/.codex/skills/web-service-tech-selection/
```

复制后重启 Codex。

## Skills

| Skill | 说明 |
| --- | --- |
| `new-branch` | 创建符合规范的 Git 功能分支。 |
| `plan` | 按分支类型结对生成规划文档 PLAN.md。 |
| `task` | 按 TDD 结构生成任务清单 TASK.md。 |
| `execute` | 按分支类型节奏逐任务执行 TASK.md。 |
| `commit` | 按 Conventional Commits 规范创建格式化提交。 |
| `merge-to-main` | 将当前分支合并回主分支。 |
| `create-pr` | 推送分支并创建 Pull Request。 |
| `analyze-bug` | 复现、定位根因并输出 Bug 分析报告。 |
| `claude-md` | 为新项目结对编写 CLAUDE.md 操作手册。 |
| `constitution` | 为新项目结对编写开发宪法。 |
| `setup-permissions` | 为当前项目配置 `.claude/settings.json` 权限规则。 |
| `explain` | 生成项目解释文档。 |
| `explain-explore` | 探索文件，收集文档所需上下文，返回结构化 findings。 |
| `explain-write` | 基于 findings 生成并写入解释文档。 |
| `learn-english` | 意图确认和英语纠错辅助，防止英文表达不精确导致执行偏差。 |
| `web-service-tech-selection` | 为 Web 后端 / HTTP API 服务结对生成或审查前置技术选型文档。 |

## Recommended Workflows

功能开发：

```text
/new-branch -> /plan -> /task -> /execute -> /commit -> /merge-to-main
```

Bug 修复：

```text
/new-branch -> /analyze-bug -> /task -> /execute -> /commit -> /merge-to-main
```

## Agents

| Agent | 说明 |
| --- | --- |
| `bug-analyzer` | 深度代码执行流分析与根因调查专家。 |
| `code-reviewer` | 代码审查专家，覆盖安全、性能与可靠性。 |
| `dev-planner` | 将需求分解为可执行开发计划。 |
| `story-generator` | 从各类输入生成带验收标准的用户故事。 |
| `ui-sketcher` | 将需求转化为 ASCII 界面设计和交互规范。 |

## Sync

`sync.sh` 可以将其他 AI 工具的配置导入本仓库。

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
./sync.sh kimi
```

使用自定义路径：

```bash
./sync.sh --path ~/.custom/kimi kimi
```

支持工具：

| 工具 | 默认来源 |
| --- | --- |
| `kimi` | `~/.kimi` |
| `codex` | `~/.codex` |
| `claude` | `~/.claude` |

### Sync Ignore

在源目录创建 `.syncignore` 文件可以排除不需要同步的内容，语法类似 `.gitignore`：

```bash
draft/
explain/TASK.md
*.tmp
```

`.syncignore` 只在同步时生效，不会同步到目标目录。
