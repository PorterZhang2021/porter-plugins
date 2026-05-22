---
name: new-branch
description: Help the user create a new Git branch following best practices. Use when the user asks to create a new branch, start a feature branch, or switch to a new branch with a specific type and name.
---

# New Branch Workflow

Help the user start a new Git branch following conventional naming.

## Supported Branch Types

| Type | Prefix | When to use |
|------|--------|-------------|
| `feat` | `feat/` | New feature |
| `fix` | `fix/` | Bug fix |
| `refactor` | `refactor/` | Code refactoring |
| `style` | `style/` | Code style, formatting |
| `perf` | `perf/` | Performance improvements |
| `chore` | `chore/` | Maintenance, dependencies, tooling |
| `build` | `build/` | Build system changes |
| `ci` | `ci/` | CI/CD configuration changes |
| `test` | `test/` | Adding or updating tests |
| `docs` | `docs/` | Planning documents, specs, design docs |

## Workflow

1. **Parse args**: Determine `<type>` and `<name>` from the user's request.
   - If `<type>` is missing or invalid, ask the user to choose from the supported types.
   - If `<name>` is missing, ask for a short, lowercase, hyphen-separated name (e.g., `login-crash`).

2. **Check current git status**. If there are uncommitted changes, warn the user and ask whether to continue anyway.

3. **创建 worktree 并切换会话**（主目录保持在 master）：

   直接调用 `EnterWorktree` 工具，传入 `name: "<type>/<name>"`，它会一步完成：
   - 以 master HEAD 为基础创建新分支
   - 在 `.claude/worktrees/<type>/<name>` 挂载独立 worktree
   - 将当前会话工作目录切换到 worktree

   进入后执行：
   ```bash
   git branch -m <type>/<name>
   git rebase master
   ```
   确保分支名符合 `<type>/<name>` 命名规范（EnterWorktree 可能用随机名）。
   `git rebase master` 确保 worktree 包含本地 master 的最新提交（EnterWorktree 默认基于 origin/master，可能落后于本地 master）。

4. **确认成功** 并展示当前分支名，提醒使用 `/commit` 提交。

5. **下一步**（根据分支类型）：
   ```
   /plan → /task → /execute → /commit → /merge-to-main
   ```

   **fix（Bug 修复）：**
   ```
   /analyze-bug → /task → /execute → /commit → /merge-to-main
   ```
   - `fix` 分支**必须先运行 `/analyze-bug`** 进行 Bug 分析和根因定位
   - `/analyze-bug` 会输出 `ANALYSIS.md`，然后 `/task` 基于此生成修复任务
   - 修复必须遵循 TDD：先写复现测试（红）→ 再写修复（绿）→ 回归测试

   **快捷方式：**
   - 如果 `PLAN.md` 或 `ANALYSIS.md` 已存在，可直接运行 `/task` 生成任务
