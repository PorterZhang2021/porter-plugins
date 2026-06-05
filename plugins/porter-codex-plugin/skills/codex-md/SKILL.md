---
name: codex-md
description: 帮助用户为新项目结对编写 AGENTS.md 操作手册
---

# AGENTS.md Workshop

帮助用户为新项目结对编写 Codex 使用的 `AGENTS.md` 操作手册。

## 阶段边界（强制）

- 本 skill 只生成或更新 `AGENTS.md`，不自动配置权限，不自动提交。
- 即使用户说"继续配置权限"或"顺便提交"，也必须在 `AGENTS.md` 完成后停止。
- 完成后先询问用户是否还要补充或调整 `AGENTS.md`；如果没有，再提示用户显式调用 `$porter-codex-plugin:codex-permissions` 或 `$porter-codex-plugin:commit`。

## 目标

基于固定的四节结构，逐节生成草稿，用户微调确认，最终生成项目根目录下的 `AGENTS.md`。

## 前置条件

在开始任何内容生成前，先检查 `.codex/constitution.md` 是否存在：

- **存在** -> 继续执行后续流程
- **不存在** -> 暂停，告知用户"未找到项目宪法，正在启动 `$porter-codex-plugin:constitution` 流程"，然后执行 constitution skill 的完整流程，宪法完成后再继续 AGENTS.md 的编写

## 执行方式

逐节和用户结对确认，不自动填充用户未确认的配置取舍。

收集完所有节所需信息后，一次性生成完整 `AGENTS.md` 草稿，展示全文，写入文件，最后停止，询问：**"AGENTS.md 已写入。还有要补充或调整的吗？如果没有，请显式调用 `$porter-codex-plugin:codex-permissions` 配置项目权限。"**

## AGENTS.md 模板

```markdown
## #---核心原则导入(最高优先级)-----#

明确导入项目宪法，确保 AI 在思考任何问题前，都已加载核心原则。

@.codex/constitution.md

## #---核心使命与角色设定-----#

**角色：** [用户确认的角色]
**使命：** [用户确认的项目使命]
**行为准则：**
- [具体协作规则]

## #---技术栈与环境-----#

**技术栈：** [语言/框架/工具]
**环境初始化：** [安装/启动/检查命令]
**环境变量：** [必需变量及来源]

## #---Git 与版本控制-----#

**分支规范：** [分支类型和命名规范]
**提交规范：** [提交消息规范]

## #---AI 协作指令-----#

**明确禁止：**
- [不可做事项]

**工作流程：**
1. [理解需求]
2. [影响评估]
3. [执行变更]
4. [验证确认]
5. [提交]

**审查标准：**
- [项目关注点]
```

## 收尾

- 写入 `AGENTS.md`
- 如果 `.codex/constitution.md` 是本流程新生成的，也展示其路径
- 询问：**"还有要补充或调整 AGENTS.md 的吗？如果没有，请显式调用 `$porter-codex-plugin:codex-permissions` 配置项目级 Codex 权限。"**

## 原则

- `AGENTS.md` 是 Codex 操作手册，不是原则文档
- `.codex/constitution.md` 保存最高优先级原则
- 所有路径和命名必须明文可见
- 不写入用户 home 目录配置
