# Claude Plugins

个人 Claude Code 插件配置仓库，包含自定义 Skills、Agents 及插件配置。

## 项目结构

| 目录 | 内容 |
|------|------|
| `skills/` | 15 个工作流 Skill（部分含同目录自动化脚本） |
| `agents/` | 5 个自定义 Agent |
| `hooks/` | 插件 Hooks 配置（hooks.json） |
| `.claude-plugin/` | 插件元数据（plugin.json、marketplace.json） |
| `.claude/` | 项目宪法（constitution.md） |

## 前置要求

- [Claude Code](https://claude.ai/code) 已安装

## 安装

**第一步：添加市场源**

```bash
claude plugin marketplace add https://github.com/PorterZhang2021/porter-plugins
```

**第二步：安装插件**

```bash
claude plugin install porter-claude-plugin
```

或手动克隆后将 `skills/` 和 `agents/` 目录内容复制到对应的 `~/.claude/` 路径。

## Skills

| Skill | 说明 |
|-------|------|
| `new-branch` | 创建符合规范的 Git 功能分支 |
| `plan` | 按分支类型结对生成规划文档 PLAN.md |
| `task` | 按 TDD 结构生成任务清单 TASK.md |
| `execute` | 按分支类型节奏逐任务执行 TASK.md |
| `commit` | 按 Conventional Commits 规范创建格式化提交 |
| `merge-to-main` | 将当前分支合并回主分支（main/master） |
| `create-pr` | 推送分支并创建 Pull Request |
| `analyze-bug` | Bug 分析，复现、定位根因、输出分析报告 |
| `claude-md` | 为新项目结对编写 CLAUDE.md 操作手册 |
| `constitution` | 为新项目结对编写开发宪法 |
| `setup-permissions` | 为当前项目配置 .claude/settings.json 权限规则 |
| `explain` | 生成项目解释文档，保存到 explain/ 目录 |
| `explain-explore` | 探索文件，收集文档所需上下文，返回结构化 findings |
| `explain-write` | 基于 findings 生成并写入解释文档 |
| `learn-english` | 意图确认 + 英语纠错辅助，防止英文表达不精确导致执行偏差 |

### 推荐工作流

```
/new-branch → /plan → /task → /execute → /commit → /merge-to-main
```

Bug 修复：

```
/new-branch → /analyze-bug → /task → /execute → /commit → /merge-to-main
```

## Agents

| Agent | 说明 |
|-------|------|
| `bug-analyzer` | 深度代码执行流分析与根因调查专家 |
| `code-reviewer` | 代码审查专家，覆盖安全、性能与可靠性 |
| `dev-planner` | 将需求分解为可执行开发计划 |
| `story-generator` | 从各类输入生成带验收标准的用户故事 |
| `ui-sketcher` | 将需求转化为 ASCII 界面设计和交互规范 |

## 跨平台配置同步（实验性）

使用 `sync.sh` 可以将其他 AI 工具的配置导入本仓库：

```bash
./sync.sh
```

### 支持工具

- `kimi` — Kimi CLI 配置（`~/.kimi`）
- `codex` — Codex CLI 配置（`~/.codex`）
- `claude` — Claude Code 配置（`~/.claude`）

### 常用参数

```bash
./sync.sh --list                    # 列出支持的 AI 工具
./sync.sh --dry-run                 # 预览同步（不实际执行）
./sync.sh kimi                      # 直接指定工具
./sync.sh --path ~/.custom/kimi kimi  # 使用自定义路径
```

### 过滤配置

在源目录创建 `.syncignore` 文件（类似 `.gitignore` 语法）：

```bash
# 排除整个目录
draft/

# 排除特定文件
explain/TASK.md

# 排除模式
*.tmp
```

**注意**：`.syncignore` 文件仅在仓库内生效，不会同步到目标目录。

## 验证安装

重启 Claude Code 后，在任意项目中输入 `/plan` 或 `/commit`，若 Skill 补全出现则安装成功。
