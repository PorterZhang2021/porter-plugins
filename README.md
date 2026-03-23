# Claude Plugins

个人 Claude Code 插件配置仓库，包含自定义 Commands、Skills、Agents 及 MCP 服务配置。

## 项目简介

| 目录 | 内容 |
|------|------|
| `commands/` | 7 个自定义斜杠命令（commit、new-branch、plan 等） |
| `skills/` | 5 个工作流 Skill（plan、task、execute、explain-explore、explain-write） |
| `agents/` | 5 个专用 Agent（bug-analyzer、code-reviewer、dev-planner 等） |
| `mcp/` | MCP 服务配置模板 |
| `settings/` | 全局 Claude Code 设置 |

## 前置要求

- [Claude Code](https://claude.ai/code) 已安装
- Node.js >= 18（MCP 服务需要）

## 安装 Commands

```bash
cp -r commands/* ~/.claude/commands/
```

## 安装 Skills

```bash
cp -r skills/* ~/.claude/skills/
```

## 安装 Agents

```bash
cp -r agents/* ~/.claude/agents/
```

## 配置 MCP 服务

1. 复制模板：
   ```bash
   cp mcp/mcp-config.template.json mcp/mcp-config.json
   ```

2. 编辑 `~/.claude.json`，将以下内容合并进 `mcpServers` 字段，并将 `<YOUR_Z_AI_API_KEY>` 替换为真实 Key：
   ```json
   {
     "mcpServers": {
       "zai-mcp-server": { ... },
       "web-search-prime": { ... },
       "web-reader": { ... },
       "zread": { ... }
     }
   }
   ```
   完整配置见 `mcp/mcp-config.template.json`。

## 全局 Settings（可选）

如需同步 claude-hud 等插件配置，将 `settings/settings.json` 内容合并到 `~/.claude/settings.json`。

> 注意：直接覆盖会丢失你本地已有的配置，建议手动合并。

## 验证安装

重启 Claude Code 后，在任意项目中输入 `/commit` 或 `/new-branch`，若命令补全出现则安装成功。
