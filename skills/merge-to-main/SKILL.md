---
name: merge-to-main
description: 将当前分支合并回主分支（main/master），保留分支
allowed-tools:
  - Shell
  - AskUserQuestion
---

# Merge to Main Skill

将当前分支合并回主分支（main/master），保留分支。

## 步骤

1. **确认当前分支**
   - 获取当前分支名
   - 检测远端默认主分支名，记为 `<base>`（参见步骤 3）
   - 如果已在 `<base>` 上，终止并提示用户

2. **检查工作区是否干净**
   - 运行 `git status`
   - 如有未提交的变更，提示用户先使用 `/commit` 提交，终止流程

3. **拉取远端并确保当前分支包含最新内容**
   - 先检测远端默认主分支名（main 或 master）：
     ```bash
     git remote show origin | grep 'HEAD branch' | awk '{print $NF}'
     ```
   - 拉取远端最新状态（不更新本地指针）：
     ```bash
     git fetch origin <base>
     ```
   - 检查 `origin/<base>` 是否有当前分支不包含的提交：
     ```bash
     git log HEAD..origin/<base> --oneline
     ```
   - 判断结果：
     - **无输出**（当前分支已包含远端所有提交）→ 正常，继续执行
     - **有输出**（远端领先）→ 将当前分支 rebase 到远端最新：
       ```bash
       git rebase origin/<base>
       ```
       - rebase 成功 → 继续执行
       - rebase 有冲突 → 执行 `git rebase --abort`，终止并提示用户：`rebase 发生冲突，请手动解决后重新运行 /merge-to-main`

4. **生成分支工作摘要**
   - 运行 `git log <base>..<current-branch> --oneline` 获取本分支所有提交
   - 基于提交记录，用自然语言总结本次分支完成了哪些工作
   - **直接执行合并，无需询问用户确认**（仅在发生冲突或异常时中止并告知用户）

5. **执行合并**

   获取主仓库根目录（worktree 场景下不等于当前 pwd）：
   ```bash
   MAIN_REPO=$(git worktree list | head -1 | awk '{print $1}')
   ```

   在主仓库上以 fast-forward only 方式执行 merge，保证线性历史：
   ```bash
   git -C $MAIN_REPO merge --ff-only <current-branch>
   ```

   - merge 成功 → 继续步骤 6
   - `--ff-only` 失败（master 已分叉）→ 终止，提示用户：
     `<base> 与当前分支已分叉，无法 fast-forward。请先在当前分支执行 git rebase <base>，再重新运行 /merge-to-main`
   - 其他错误 → 终止并展示错误信息

6. **确认结果**
   - 展示主仓库最新的 git log（最近 3 条）：
     ```bash
     git -C $MAIN_REPO log --oneline -3
     ```
   - 如需开始新功能，根据场景选择收尾方式：
     ```
     /new-branch → /plan → /task → /execute → /commit → /merge-to-main  # 直接合并（个人项目）
     /new-branch → /plan → /task → /execute → /commit → /create-pr       # 开 PR（需要 Review）
     ```
