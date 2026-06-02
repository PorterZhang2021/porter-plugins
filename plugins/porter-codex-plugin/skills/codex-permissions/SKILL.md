---
name: codex-permissions
description: 为当前项目结对配置 Codex 项目级权限与协作规则说明
---

# Codex Permissions

为当前项目结对配置 Codex 项目级权限与协作规则说明。

## 目标

根据当前项目风险，帮助用户明确 Codex 的文件写入、命令执行、网络访问、Git 操作和 worktree 约束。优先写入项目级 `.codex/config.toml`；如果当前 Codex 环境不支持某项配置，则把规则写入 `AGENTS.md` 的 AI 协作指令部分。

## 前置检查

读取以下文件是否存在：

- `.codex/config.toml`
- `AGENTS.md`
- `.codex/constitution.md`

如果 `.codex/config.toml` 已存在，先展示当前内容，询问用户是追加、覆盖还是只更新 `AGENTS.md` 说明。

## 配置流程

逐类收集用户意图，不等待每类确认，全部收集完后统一生成配置草稿。

### Step 1：文件写入范围

确认 Codex 是否只能写入项目目录，以及在 `.codex/worktrees/<type>/<name>` 中工作时是否禁止写回主仓库路径。

默认建议：

```text
写入范围限制到当前项目或当前 worktree。
进入 `.codex/worktrees/` 后，所有写入路径必须以当前 worktree 为基准。
```

### Step 2：命令执行审批

按以下分类确认策略：

| 类别 | 建议 |
| --- | --- |
| 只读命令 | 允许，如 `pwd`、`ls`、`rg`、`git status` |
| 构建/测试 | 按项目需要允许，如 `npm test`、`pytest`、`go test` |
| Git 写操作 | 创建分支、add、commit 可确认后执行 |
| 远端操作 | `push`、PR 创建需要明确确认 |
| 危险操作 | `rm -rf`、`git reset --hard`、`sudo` 默认禁止或每次询问 |

### Step 3：网络访问

确认是否允许联网下载依赖、查询文档、访问 GitHub 或调用外部服务。默认建议：

```text
网络访问默认需用户确认；官方文档查询和必要依赖安装按任务单次批准。
```

### Step 4：Git 与提交

确认是否采用项目默认规范：

```text
分支：<type>/<name>
提交：Conventional Commits，格式为 type(scope): description
配置变更独立提交，不混杂
```

### Step 5：生成配置

优先生成 `.codex/config.toml` 草稿；无法确认 Codex 配置键时，不魔法填充，改为生成 `AGENTS.md` 中的明文协作规则。

## 收尾

- 汇总展示完整配置或协作规则
- 等待用户最终确认
- 写入 `.codex/config.toml` 或更新 `AGENTS.md`
- 询问：**"Codex 权限规则已写入，是否运行 `/commit` 提交？"**

## 原则

- 不写入全局 `~/.codex` 配置
- 不自动推断未确认的权限
- 不为危险命令建立永久放行
- Codex worktree 写入路径必须显式受限
