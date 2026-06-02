---
name: explain-explore
description: 探索项目文件，收集指定类型解释文档所需的上下文，返回结构化 findings
context: fork
agent: Explore
allowed-tools:
  - ReadFile
  - Glob
  - Grep
  - Shell
---

接收参数：`type`（architecture/feature/changelog/decision/ask）、`topic`（可选）、`working_dir`

按 type 探索对应文件，收集完整上下文后，以结构化文本输出 findings。**不写任何文件，只返回探索结果。**

---

## architecture

依次执行，收集完再输出：

1. 列出项目根目录两层文件树，识别项目类型（Python/Node/Go 等）
2. 读取项目说明文件（`AGENTS.md`、`README.md`、`CLAUDE.md` 等，取第一个存在的）
3. 读取依赖声明文件（`requirements.txt`、`package.json`、`go.mod`、`Cargo.toml` 等，取存在的）
4. 自动定位入口文件：搜索 `main.py`、`index.ts`、`main.ts`、`App.vue`、`main.go`、`cmd/*/main.go` 等常见模式，读取前 50 行
5. 读取核心业务目录下各文件前 40 行（跳过 `node_modules`、`__pycache__`、`.git`、`dist`、`build` 等）
6. 识别对外暴露的功能点：搜索路由定义、API 注册、导出函数等（根据项目类型使用对应关键词）
7. 读取 `plan/` 下的 PLAN.md（如存在）

输出：目录结构、各模块职责摘要、对外功能清单、依赖栈

---

## feature

1. 从 `explain/architecture.md` 的功能清单中找到 topic 对应的模块（如存在）
2. 搜索 topic 相关的路由/接口定义
3. 沿调用链读取：接口层 → 业务层 → 数据层（每层只读与 topic 直接相关的文件）
4. 读取对应的 schema/类型定义

输出：请求入口（文件:行号）、完整调用链、数据形态变化、错误处理路径

---

## changelog

1. 运行 `git diff --name-only HEAD` 获取变更文件列表
2. 运行 `git status` 了解当前工作区状态
3. 读取 TASK.md（如存在）了解对应任务
4. 对每个变更文件读取前 60 行（了解上下文）

输出：变更文件清单（含变更类型）、每个文件的变更摘要、变更背景

---

## decision

1. 读取 `plan/` 下最新的 PLAN.md
2. 运行 `git log --oneline -10` 了解近期提交
3. 读取 TASK.md（如存在）

输出：关键决策点列表、每个决策的背景、备选方案、取舍原因

---

## ask

用户针对某个功能/概念提出具体问题，需要针对性探索代码来回答。

1. 解析用户问题中的关键词（功能名、类名、概念等）
2. 从 `explain/architecture.md` 或 `explain/feature-*.md` 中读取相关上下文（如存在）
3. 搜索问题相关的代码文件
4. 读取与问题最相关的代码片段

输出：问题涉及的核心代码、代码逻辑解释、相关设计决策
