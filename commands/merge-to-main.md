# Merge to Main

将当前分支合并回主分支（main/master），并清理分支。

## 步骤

1. **确认当前分支**
   - 获取当前分支名
   - 检测远端默认主分支名，记为 `<base>`（参见步骤 3）
   - 如果已在 `<base>` 上，终止并提示用户

2. **检查工作区是否干净**
   - 运行 `git status`
   - 如有未提交的变更，提示用户先使用 `/commit` 提交，终止流程

3. **同步主分支最新代码**
   - 先检测远端默认主分支名（main 或 master）：
     ```bash
     git remote show origin | grep 'HEAD branch' | awk '{print $NF}'
     ```
   - 将检测到的分支名记为 `<base>`，后续步骤统一使用
   - 先拉取远端最新代码：
     ```bash
     git fetch origin <base>
     ```
   - 运行 `git log HEAD..origin/<base> --oneline` 检查 origin/<base> 是否有当前分支未包含的提交
   - 同时更新本地主分支指针：
     ```bash
     git branch -f <base> origin/<base>
     ```
   - 如有差异，执行 rebase：
     ```bash
     git rebase <base>
     ```
   - 如有冲突，展示冲突文件，提示用户手动解决后运行 `git rebase --continue`，终止自动流程等待用户处理完毕
   - 无差异则跳过此步

4. **生成分支工作摘要**
   - 运行 `git log <base>..<current-branch> --oneline` 获取本分支所有提交
   - 基于提交记录，用自然语言总结本次分支完成了哪些工作
   - 展示摘要并询问用户是否确认合并

5. **执行合并**（用户确认后）
   ```bash
   git checkout <base>
   git merge <current-branch>
   ```

6. **删除已合并的分支**
   ```bash
   git branch -d <current-branch>
   ```

7. **确认结果**
   - 展示当前所在分支（应为 `<base>`）
   - 展示最新的 git log（最近 3 条）
   - 如需开始新功能：`/new-branch <type> <name>` → `/plan` → `/task` → `/execute` → `/commit` → `/merge-to-main`
