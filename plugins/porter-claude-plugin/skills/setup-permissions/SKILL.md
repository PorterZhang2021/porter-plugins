---
name: setup-permissions
description: 为当前项目结对配置 .claude/settings.json 权限规则
---

# Setup Permissions

为当前项目结对配置 `.claude/settings.json` 权限规则。

## 目标

逐类引导用户确认 `defaultMode` / `allow` / `ask` / `deny`，最终生成项目级 `.claude/settings.json`。

## 前置检查

读取 `.claude/settings.json` 是否已存在：
- **存在** → 展示当前内容，询问是覆盖还是追加
- **不存在** → 直接进入配置流程

## 配置流程

逐类收集用户意图，不等待每类确认，全部收集完后统一生成配置。

### Step 1：默认模式

询问用户选择 `defaultMode`：

| 选项 | 效果 | 推荐场景 |
|------|------|---------|
| `acceptEdits` | 文件读写自动通过，Bash 命令仍需审批 | **日常开发（推荐）** |
| `plan` | 所有操作先规划再执行，plan 模式优先级高于 allow 列表 | 需要严格审查每步操作时 |
| `default` | 每次操作都弹审批 | 不确定项目时使用 |
| `dontAsk` | allow 列表内命令全部自动执行 | 完全信任环境时使用 |

> **注意：** `plan` 模式会覆盖 `allow` 列表——即使命令在 allow 中，plan 模式下仍需批准计划。日常开发建议用 `acceptEdits`。

### Step 2：allow 列表

按以下分类依次询问（不等确认，连续询问完毕后统一生成配置）：

1. **文件操作** — `Read` / `Edit` / `Write` / `Glob` / `Grep`，询问是否限制到项目目录
2. **Git 操作** — 日常命令放行，危险操作（push/reset --hard/branch -D）建议放入 ask
3. **语言与包管理** — 根据项目技术栈询问（Python/Node/Go 等），包管理询问是否限制虚拟环境
4. **测试与服务** — pytest / uvicorn / 其他测试工具
5. **基础命令** — ls / cat / echo 全局放行；mkdir / cp / mv / touch 询问是否限制项目目录

### Step 3：ask 列表

询问哪些操作需要每次弹窗确认：
- 文件写入（如果 Step 2 中未放入 allow）
- 危险 git 操作
- 包删除
- 文件删除（rm）

### Step 4：deny 列表

询问哪些操作永久禁止，建议默认：
- `Bash(rm -rf:*)` — 递归强制删除
- `Bash(sudo:*)` — 提权操作
- 其他用户认为绝对不可执行的命令

## 收尾

- 汇总展示完整配置，等待用户最终确认
- 写入 `.claude/settings.json`
- 询问：**"权限配置已写入，是否运行 `/commit` 提交？"**
