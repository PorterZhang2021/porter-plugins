---
name: task-worktree
description: 基于 worktree workflow 的 PLAN.md 生成符合 TDD 结构的任务清单
allowed-tools:
  - Bash
  - Read
  - Write
  - Glob
---

# Task Workshop

## 阶段边界（强制）

- 本 skill 只生成或更新 `TASK.md`，不执行任务，不修改业务代码或配置内容。
- 即使用户在任务拆分阶段说"开始修"、"顺便改掉"、"全部处理"，也不得进入执行阶段。
- 任务清单完成后必须停止，先询问用户是否还要补充、删除或调整任务。
- 如果用户确认任务无补充，再提示用户显式调用 `$porter-codex-plugin:execute-worktree` 进入下一阶段。
- 任务清单完成后必须同步写入 `plan/<type>/<branch-name>/WORKFLOW_STATE.json`，状态为 `awaiting_execute`；该状态由 Porter workflow hook 用于阻止越阶段修改实现文件。

## 前置条件

1. 确认 `AGENTS.md` 和 `.codex/constitution.md` 存在，否则提示用户先运行 `$porter-codex-plugin:codex-md`
2. **检查当前分支**：若在 `master` 分支上，立即终止并提示：`当前在 master 分支，请先运行 $porter-codex-plugin:new-branch-worktree 创建 worktree 分支`
3. 读取当前分支名，提取类型前缀
3. **分支类型特殊处理：**

| 类型 | 依赖文件 | 不存在时提示 |
|------|----------|-------------|
| `feat` | `plan/<type>/<name>/PLAN.md` | 先运行 `$porter-codex-plugin:plan-worktree` |
| `fix` | `plan/<type>/<name>/ANALYSIS.md` | **先运行 `$porter-codex-plugin:analyze-bug`** |
| `refactor` | `plan/<type>/<name>/PLAN.md` | 先运行 `$porter-codex-plugin:plan-worktree` |
| 其他 | `plan/<type>/<name>/PLAN.md` | 先运行 `$porter-codex-plugin:plan-worktree` |

**fix 分支特殊逻辑**：
- 优先读取 `ANALYSIS.md` 获取根因分析
- 若不存在 `ANALYSIS.md`，提示先运行 `$porter-codex-plugin:analyze-bug` 完成 Bug 分析
- **不需要 PLAN.md**，基于 ANALYSIS 直接生成任务

## TDD 铁律

- 每个有业务逻辑的模块，**测试任务排在实现任务之前**
- 测试任务未完成，对应实现任务不允许开始
- 测试名称描述行为（`test_xxx_returns_yyy_when_zzz`），不描述函数名
- 无业务逻辑的模块（常量、配置）注明"无需测试"

## 执行

根据分支类型，读取对应文件并按其格式生成任务清单：

| 类型 | 输入文件 | 参考模板 |
|------|----------|----------|
| feat | `PLAN.md` | `reference/feat.md` |
| fix | **`ANALYSIS.md`** | `reference/fix.md` |
| refactor | `PLAN.md` | `reference/refactor.md` |
| test | `PLAN.md` | `reference/test.md` |
| docs | `PLAN.md` | `reference/docs.md` |
| chore | `PLAN.md` | `reference/chore.md` |
| style | `PLAN.md` | `reference/style.md` |
| perf | `PLAN.md` | `reference/perf.md` |
| build | `PLAN.md` | `reference/build.md` |
| ci | `PLAN.md` | `reference/ci.md` |

### fix 分支任务生成逻辑

基于 `ANALYSIS.md` 中的根因分析，生成以下任务结构：

**必须包含（按顺序）：**
1. **Task 1: 复现测试** — 根据 "复现步骤" 和 "问题位置" 写失败测试
2. **Task 2: Bug 修复** — 根据 "根因分析" 写最小修复
3. **Task 3: 回归测试** — 运行全量测试确认无回归

**可选：**
- Task 4: 补充边界测试（如果 ANALYSIS.md 提到影响范围）

TASK.md 文件头格式见 `templates/task_header.md`。

## 收尾

- 生成完整任务清单，展示全部内容，直接写入 `plan/<type>/<branch-name>/TASK.md`
- 同步写入 `plan/<type>/<branch-name>/WORKFLOW_STATE.json`：

```json
{
  "state": "awaiting_execute",
  "current_skill": "$porter-codex-plugin:task-worktree",
  "next_skill": "$porter-codex-plugin:execute-worktree",
  "allowed_outputs": [
    "plan/<type>/<branch-name>/TASK.md",
    "plan/<type>/<branch-name>/WORKFLOW_STATE.json"
  ]
}
```

- 停止，不执行任务
- 询问：**"任务清单已生成。还有要补充、删除或调整的吗？如果没有，请显式调用 `$porter-codex-plugin:execute-worktree` 开始实现。"**
