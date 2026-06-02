---
name: new-branch
description: Help the user create a new Git worktree branch for Codex following the project branch naming convention.
---

# New Branch Workflow

Help the user start a new Git branch in a Codex worktree, keeping the main checkout stable.

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

3. **创建 Codex worktree**（主目录保持在主分支）：

   先检测远端默认主分支：

   ```bash
   BASE=$(git remote show origin | awk '/HEAD branch/ {print $NF}')
   [ -z "$BASE" ] && BASE=$(git branch --show-current)
   git fetch origin "$BASE"
   git worktree add -b <type>/<name> ".codex/worktrees/<type>/<name>" "origin/$BASE"
   ```

   如果远端不可用但本地主分支存在，改用：

   ```bash
   git worktree add -b <type>/<name> ".codex/worktrees/<type>/<name>" "$BASE"
   ```

   创建后，将后续工作目录切换到：

   ```text
   .codex/worktrees/<type>/<name>
   ```

   **路径保护规则：** 在 `.codex/worktrees/<type>/<name>` 中工作时，所有写入路径必须以该 worktree 目录为基准；不要写回主仓库路径。

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
