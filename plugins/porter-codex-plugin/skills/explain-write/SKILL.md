---
name: explain-write
description: 基于 explain-explore 返回的 findings，读取对应模板，生成并写入解释文档
context: fork
agent: general-purpose
allowed-tools:
  - ReadFile
  - WriteFile
  - Shell
---

接收参数：`type`、`topic`、`working_dir`、`findings`（来自 explain-explore 的输出）、`force`（可选，设为 `true` 时自动覆盖已存在文件）

## 步骤

### 1. 确定输出路径和模板路径

| type | 输出文件 | 模板 |
|------|---------|------|
| architecture | `{working_dir}/explain/architecture.md` | `templates/architecture.md` |
| feature | `{working_dir}/explain/feature-{topic}.md` | `templates/feature.md` |
| changelog | `{working_dir}/explain/changelog-{topic}.md` | `templates/changelog.md` |
| decision | `{working_dir}/explain/decision-{topic}.md` | `templates/decision.md` |
| ask | `{working_dir}/explain/ask-{topic}.md` | `templates/ask.md` |

### 2. 写入前检查

如果输出文件已存在：

- **`force=true`**：自动覆盖，无需确认
- **`force` 未设置或为 false**：读取前 5 行展示给用户，询问：
  ```
  explain/{filename} 已存在。

  覆盖？[y/N]
  ```
  选 N 则终止。

### 3. 读取模板

读取对应 `{skill_dir}/templates/<type>.md`，以其结构为骨架。skill_dir 是本 skill 所在目录（`~/.kimi/skills/explain-write`）。

### 4. 生成内容

将 findings 填入模板结构，遵循通用要求：

- 用中文撰写
- 只解释非显而易见的部分，跳过读代码就能看懂的内容
- 面向两类读者：自己（帮助回忆）+ 他人（帮助理解）
- 控制长度，能快速阅读

### 5. 写入

创建 `explain/` 目录（如不存在），写入文件，完成后输出：

```
✓ 已保存至 explain/{filename}
```
