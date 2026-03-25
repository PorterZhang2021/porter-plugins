# PLAN: feat/install-sync-skill

## 1. 功能目标

将 `claude-plugin` 仓库中的配置资产（commands、skills、settings）一键同步到本地 `~/.claude/` 目录，解决手动复制繁琐、跨机器重新配置成本高的问题。

## 2. 技术选型

- **Shell 脚本**（`install.sh`）：直接执行，无构建步骤
- `rsync`：同步 commands/skills 目录（外部依赖，脚本启动时检测）
- `python3 -c`：内联 JSON 深度合并（外部依赖，脚本启动时检测；仅使用标准库 `json`）

## 3. 目录结构

**新增文件：**
```
install.sh          # 安装脚本（仓库根目录）
```

**仓库 → `~/.claude` 映射：**

| 仓库路径 | 目标路径 | 策略 |
|----------|----------|------|
| `commands/` | `~/.claude/commands/` | rsync（已有则覆盖，不删用户自有文件）|
| `skills/` | `~/.claude/skills/` | rsync（已有则覆盖，不删用户自有文件）|
| `settings/settings.json` | `~/.claude/settings.json` | 深度合并，不覆盖用户自有 key |

## 4. 脚本接口

```bash
./install.sh                  # 全量同步
./install.sh --only commands  # 只同步 commands
./install.sh --only skills    # 只同步 skills
./install.sh --only settings  # 只同步 settings
./install.sh --dry-run        # 预览模式，不实际写入
```

## 5. 数据流

```
install.sh 执行
    │
    ├─ 解析参数（--only / --dry-run）
    ├─ 检测 CLAUDE_HOME（默认 ~/.claude）
    │
    ├─ 同步 commands/
    │   └─ rsync repo/commands/ → $CLAUDE_HOME/commands/
    │
    ├─ 同步 skills/
    │   └─ rsync repo/skills/ → $CLAUDE_HOME/skills/
    │
    └─ 合并 settings/settings.json
        ├─ 读取 $CLAUDE_HOME/settings.json（已有）
        ├─ 读取 repo/settings/settings.json（仓库）
        └─ 深度合并写回（python3 内联）
```

## 6. 核心参数

```bash
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"  # 可通过环境变量覆盖目标路径
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"   # 脚本所在仓库根目录
DRY_RUN=false
ONLY=""
SUMMARY=()                                   # 收集各步骤摘要，最终统一输出
```

## 7. 功能边界

**做：**
- 同步 `commands/`、`skills/` 到 `~/.claude`
- 合并 `settings/settings.json`（深度合并，保留用户自有 key）
- `--dry-run` 预览模式
- `--only` 指定同步类型
- 同步前打印变更摘要

**不做：**
- 同步 `.claude/constitution.md`（项目专属，不污染全局）
- 删除用户在 `~/.claude` 中自有的 commands/skills
- 处理 `mcp/` 配置（MCP 安装复杂，文档另行说明）
- 备份/回滚机制

## 8. 实现顺序

1. 脚本骨架 — 参数解析、`CLAUDE_HOME` 检测、依赖检查（rsync/python3）、帮助信息
2. commands/skills 同步 — 抽取 `_rsync_sync()` 公共函数，rsync + dry-run + 文件列表捕获
3. settings 合并 — python3 内联 JSON 深度合并
4. `--only` 过滤 — 控制只执行某一步
5. 变更摘要输出 — 静默执行，最终统一打印各步骤同步的文件列表与数量
