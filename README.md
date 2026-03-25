# Claude Plugins

个人 Claude Code 插件配置仓库，包含自定义 Commands、Skills 及全局 Settings。

## 项目结构

| 目录 | 内容 |
|------|------|
| `commands/` | 自定义斜杠命令（commit、new-branch、plan 等） |
| `skills/` | 工作流 Skill（plan、task、execute、explain-explore、explain-write） |
| `settings/` | 全局 Claude Code 设置 |
| `mcp/` | MCP 服务安装说明 |

## 前置要求

- [Claude Code](https://claude.ai/code) 已安装
- `rsync`（macOS 自带）
- `python3`（macOS 自带）

## 一键安装

```bash
./install.sh
```

首次安装或后续同步均可使用，幂等执行。

### 可选参数

```bash
./install.sh --dry-run              # 预览变更，不实际写入
./install.sh --only commands        # 只同步 commands
./install.sh --only skills          # 只同步 skills
./install.sh --only settings        # 只合并 settings
```

### 同步策略

| 资产 | 策略 |
|------|------|
| `commands/` | 覆盖已有同名文件，保留用户自有文件，不删除 |
| `skills/` | 覆盖已有同名文件，保留用户自有文件，不删除 |
| `settings/settings.json` | 深度合并，仓库 key 写入本地，本地独有 key 保留 |

### 示例输出

```
==> Summary
    commands: 7 file(s) → ~/.claude/commands/
        - commit.md
        - new-branch.md
        - ...
    skills  : 41 file(s) → ~/.claude/skills/
        - plan/SKILL.md
        - task/SKILL.md
        - ...
    settings: merged → ~/.claude/settings.json

Done. Target: /Users/yourname/.claude
```

## 配置 MCP 服务

MCP 服务需手动配置，详见 `mcp/INSTALL.md`。

## 验证安装

重启 Claude Code 后，在任意项目中输入 `/commit` 或 `/new-branch`，若命令补全出现则安装成功。
