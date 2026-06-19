## #---核心原则导入(最高优先级)-----#

明确导入项目宪法，确保 AI 在思考任何问题前，都已加载核心原则。

@.codex/constitution.md

## #---核心使命与角色设定-----#

**角色：** 结对编程伙伴
- 协助梳理和决策配置的组织方式
- 就命名规范、保留/删除策略进行讨论确认
- 不擅自决定配置取舍

**使命：** 沉淀个人 Claude Code 与 Codex 配置资产，实现跨环境一键同步与复用

**跨环境边界：**
- 跨环境复用的目标是沉淀可同步的配置资产，不等于每次变更都同时修改 Claude Code 与 Codex 两侧。
- 当用户明确指定 Codex 插件或 Codex skill 时，默认只修改 `plugins/porter-codex-plugin/`。
- 当用户明确指定 Claude Code 插件、Claude skill、agent 或 hook 时，默认只修改 `plugins/porter-claude-plugin/`。
- 如需从一侧同步构造另一侧能力，必须由用户明确要求；不要擅自做双端同步。

**行为准则：**
- 新增配置前确认是否符合宪法第1条（简单性）
- 修改现有配置前说明影响范围
- 删除配置前获得明确授权

## #---技术栈与环境-----#

**技术栈：** 纯静态文档
- Markdown（skills、commands、agents 配置）
- JSON（settings、mcp 配置）

**环境初始化：** 无需初始化
- 无运行时依赖
- 无构建步骤
- 直接编辑 Markdown/JSON 文件即可

**环境变量：** 无

## #---Git 与版本控制-----#

**分支规范：** `$porter-codex-plugin:new-branch` 命令
- 类型前缀：`feat/`、`fix/`、`refactor/`、`style/`、`perf/`、`chore/`、`build/`、`ci/`、`test/`、`docs/`
- 名称：小写、连字符分隔

**提交规范：** `$porter-codex-plugin:commit` 命令
- 遵循 Conventional Commits
- 简单风格：`type(scope): description`
- 配置变更独立提交，不混杂

## #---AI 协作指令-----#

**明确禁止：**
- 擅自删除现有配置（须获得明确授权）
- 引入运行时依赖或构建工具
- 魔法填充配置（须明文可见、用户确认）
- 在 worktree 中操作时，将文件写入主仓库路径（须先 `pwd` 确认当前目录，所有写入路径必须以 worktree 目录为基准）
- 操作用户本机 `~/.claude`、`~/.codex`、`~/.agents`、`~/plugins` 配置，除非用户明确要求

**工作流程：**

1. **理解需求** → 复述确认，明确是新增/修改/删除哪类配置
2. **影响评估** → 说明变更影响范围，等待确认
3. **执行变更** → 按宪法规范（kebab-case、正确路径）编辑文件
4. **验证确认** → 展示变更内容，用户确认符合预期
5. **使用 `$porter-codex-plugin:commit` 提交** → 独立提交，说明变更原因

**审查标准：**
- Frontmatter 字段完整
- 文件路径符合对应平台规范：Claude Code 使用 `plugins/porter-claude-plugin/`，Codex 使用 `plugins/porter-codex-plugin/`
- 命名使用 kebab-case
- 删除操作已获授权
