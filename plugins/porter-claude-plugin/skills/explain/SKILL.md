---
name: explain
description: 生成项目解释文档，保存到 explain/ 目录
context: fork
agent: general-purpose
allowed-tools:
  - Agent
---

生成项目解释文档，保存到 `explain/` 目录。

## 参数

| 参数 | 说明 | 可选值 |
|------|------|--------|
| `type` | 解释文档类型 | `architecture` / `feature` / `changelog` / `decision` / `ask` |
| `topic` | 具体主题（feature/decision/ask 时需要） | 任意字符串 |
| `force` | 强制覆盖已存在的文件 | `true` / `false`（默认） |

## 用法

```
# 显示帮助信息（默认）
/explain

# 探索整个项目，生成架构总览（含功能清单）
/explain type=architecture

# 显示功能清单，供选择后深入探索
/explain type=feature

# 深入讲解某个具体功能的实现
/explain type=feature topic=upload

# 这次改了什么（变更记录）
/explain type=changelog

# 设计决策与取舍
/explain type=decision topic=缓存策略

```

## 执行步骤

根据参数路由到不同的处理逻辑：

---

### 无参数

显示本帮助文档，列出所有可用命令和参数说明。

---

### `type=architecture`

依次调用两个 skill：

1. 调用 `explain-explore` skill，传入：
   ```
   type: architecture
   working_dir: {当前工作目录绝对路径}
   ```
2. 将返回的 findings 传入 `explain-write` skill：
   ```
   type: architecture
   working_dir: {当前工作目录绝对路径}
   findings: {explain-explore 的输出}
   force: {force 参数值，如未设置则为 false}
   ```

---

### `type=feature`（无 topic）

需要先确认 `explain/architecture.md` 是否存在：

**如果文件存在**：提取 `## 功能清单` 章节内容，直接展示给用户，并提示：
```
以上是当前功能清单。运行 `/explain feature {topic}` 深入了解某个功能。
如需重新生成，运行 `/explain` 更新 architecture.md。
```

**如果文件不存在**：提示用户先运行 `/explain` 生成架构总览，再使用此命令。

---

### `type=feature`（有 topic）/ `type=changelog` / `type=decision` / `type=ask`

依次调用两个 skill：

1. 调用 `explain-explore` skill，传入：
   ```
   type: {type}
   topic: {topic}
   working_dir: {当前工作目录绝对路径}
   ```
2. 将返回的 findings 传入 `explain-write` skill：
   ```
   type: {type}
   topic: {topic}
   working_dir: {当前工作目录绝对路径}
   findings: {explain-explore 的输出}
   force: {force 参数值，如未设置则为 false}
   ```
