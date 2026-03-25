# Create Pull Request

将当前分支推送到远端并创建 Pull Request，适合需要 Code Review 的场景。

> 与 `/merge-to-main` 平行使用：
> - 需要 Review → `/create-pr`（push 分支 + 开 PR，由团队合并）
> - 直接合并 → `/merge-to-main`（本地合并后 push，适合个人项目）

## 前置条件

- `gh` CLI 已安装并完成认证（`gh auth status`）
- 工作区干净（无未提交变更）

## 步骤

1. **确认当前分支**
   - 获取当前分支名，记为 `<current>`
   - 检测远端默认主分支：
     ```bash
     git remote show origin | grep 'HEAD branch' | awk '{print $NF}'
     ```
   - 记为 `<base>`
   - 如果已在 `<base>` 上，终止并提示用户切换到功能分支

2. **检查工作区是否干净**
   - 运行 `git status`
   - 如有未提交的变更，提示用户先使用 `/commit` 提交，终止流程

3. **检查 `gh` CLI**
   - 运行 `gh auth status`
   - 如未安装或未认证，提示：
     ```
     请先安装并登录 gh CLI：
       brew install gh
       gh auth login
     ```
   - 终止流程

4. **推送当前分支**
   ```bash
   git push -u origin <current>
   ```

5. **生成 PR 信息**
   - 运行 `git log <base>..<current> --oneline` 获取本分支所有提交
   - 基于提交记录生成：
     - **PR 标题**：遵循 Conventional Commits 格式，概括本次变更
     - **PR 描述**：包含以下结构：
       ```markdown
       ## Summary
       <!-- 一句话说明本次 PR 解决了什么问题 -->

       ## Changes
       <!-- 基于提交记录列出具体变更 -->

       ## Testing
       <!-- 如何验证本次变更（dry-run、手动测试步骤等）-->
       ```
   - 展示生成的标题和描述，询问用户是否确认或修改

6. **创建 Pull Request**（用户确认后）
   ```bash
   gh pr create \
     --base <base> \
     --head <current> \
     --title "<title>" \
     --body "<description>"
   ```

7. **确认结果**（此步骤必须完整执行，不得省略）
   - 展示 PR URL
   - **必须**紧接着输出以下清理提示，不得因"任务完成"感而跳过：

   ---
   PR 合并后，执行以下命令清理本地分支：
   ```bash
   git checkout <base>
   git pull origin <base>
   git branch -d <current>
   ```
   ---

## 完整链路

```
/new-branch → /plan → /task → /execute → /commit → /create-pr     # 需要 Review
/new-branch → /plan → /task → /execute → /commit → /merge-to-main  # 直接合并
```
