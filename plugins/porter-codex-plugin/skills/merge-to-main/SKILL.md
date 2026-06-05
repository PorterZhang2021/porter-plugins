---
name: merge-to-main
description: 将当前分支合并回远端默认主分支，保留分支
allowed-tools:
  - Bash
---

# Merge to Main Skill

将当前分支合并回远端默认主分支，保留分支。

## 执行

运行脚本前，先说明将要合并的目标：

```bash
CURRENT=$(git branch --show-current)
BASE=$(git remote show origin | awk '/HEAD branch/ {print $NF}')
MAIN_REPO=$(git worktree list | head -1 | awk '{print $1}')
git fetch origin "$BASE"
git -C "$MAIN_REPO" log -1 --oneline "$BASE"
```

必须向用户说明：
- 当前分支：`$CURRENT`
- 目标 base 分支：`$BASE`
- 目标 base 当前提交：`git -C "$MAIN_REPO" log -1 --oneline "$BASE"`
- 主仓库路径：`$MAIN_REPO`
- 主仓库当前分支必须是：`$BASE`
- 脚本会先同步本地 base，再必要时 rebase 当前分支，最后 fast-forward 合并

如果无法检测 `$BASE`、当前 worktree 或主仓库工作区不干净、主仓库不在 `$BASE`、目标分支异常，或本地 base 无法 fast-forward 到 `origin/$BASE`，不要继续执行。

直接运行与本 skill 同目录的脚本（将 `<skill-base-dir>` 替换为本文件所在目录）：

```bash
bash "<skill-base-dir>/merge-to-main.sh"
```

脚本会自动完成：
1. 确认当前分支不是远端默认主分支
2. 检查工作区是否干净
3. `git fetch origin <base>`
4. 本地 base 分支 `--ff-only` 同步到 `origin/<base>`
5. 检查当前分支是否落后本地 base，落后则自动 rebase 到明确的 base 提交
6. `git merge --ff-only` 保证线性历史合并

## 异常处理

脚本会在以下情况自动终止并说明原因：
- 工作区有未提交变更
- 主仓库不在目标 base 分支
- 本地 base 与远端分叉（需手动排查）
- rebase 发生冲突（自动 abort，提示手动解决）

## 下一步

```
git push origin <base>   # 推送到远端
$porter-codex-plugin:new-branch              # 开始新功能
```
