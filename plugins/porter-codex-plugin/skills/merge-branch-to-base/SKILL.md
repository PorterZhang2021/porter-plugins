---
name: merge-branch-to-base
description: 将普通 Git 分支合并回创建分支时记录的 base 分支，保留分支
allowed-tools:
  - Bash
---

# Merge Branch to Base Skill

将当前普通 Git 分支合并回 `$porter-codex-plugin:new-branch` 创建分支时记录的 base 分支，保留分支。

本 skill 只适用于 branch workflow。worktree workflow 请使用 `$porter-codex-plugin:merge-worktree-to-base`。

## 执行前说明

运行合并命令前，先说明将要合并的目标：

```bash
CURRENT=$(git branch --show-current)
BASE=$(git config --get "branch.$CURRENT.porter-base")

if git ls-remote --exit-code --heads origin "$BASE" >/dev/null 2>&1; then
  git fetch origin "$BASE"
else
  echo "远端 origin/$BASE 不存在，将使用本地 $BASE 作为 fallback"
fi

git log -1 --oneline "$BASE"
```

必须向用户说明：

- 当前分支：`$CURRENT`
- 记录的目标 base 分支：`$BASE`
- 目标 base 当前提交：`git log -1 --oneline "$BASE"`
- 当前工作区必须干净
- 脚本会先同步本地 base，再必要时 rebase 当前分支，最后切换到 base 并 fast-forward 合并

如果无法读取 `branch.$CURRENT.porter-base`、当前分支就是 `$BASE`、工作区不干净、目标分支异常，或本地 base 无法 fast-forward 到 `origin/$BASE`，不要继续执行。若远端 `origin/$BASE` 不存在但本地 `$BASE` 存在，可使用本地 base fallback，并明确说明。

## 推荐命令

```bash
set -euo pipefail

CURRENT=$(git branch --show-current)
BASE=$(git config --get "branch.$CURRENT.porter-base")

[ -n "$CURRENT" ] || { echo "当前处于 detached HEAD 状态，无法合并"; exit 1; }
[ -n "$BASE" ] || { echo "当前分支没有记录 porter-base"; exit 1; }
[ "$CURRENT" != "$BASE" ] || { echo "当前已在 $BASE 分支，无需合并"; exit 1; }

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "工作区有未提交的变更，请先运行 \$porter-codex-plugin:commit-branch"
  exit 1
fi

if git ls-remote --exit-code --heads origin "$BASE" >/dev/null 2>&1; then
  git fetch origin "$BASE"
  git switch "$BASE"
  if ! git merge --ff-only "origin/$BASE"; then
    echo "本地 $BASE 与 origin/$BASE 已分叉，请先手动排查后再合并"
    exit 1
  fi
  git switch "$CURRENT"
else
  git show-ref --verify --quiet "refs/heads/$BASE" || { echo "base 分支不存在：$BASE"; exit 1; }
  echo "远端 origin/$BASE 不存在，使用本地 $BASE 作为 fallback"
fi

BASE_COMMIT=$(git rev-parse "$BASE")

if [ -n "$(git log "HEAD..$BASE_COMMIT" --oneline)" ]; then
  if ! git rebase "$BASE_COMMIT"; then
    git rebase --abort
    echo "rebase 发生冲突，已中止。请手动解决冲突后重新运行 \$porter-codex-plugin:merge-branch-to-base"
    exit 1
  fi
fi

git switch "$BASE"
git merge --ff-only "$CURRENT"
```

## 异常处理

必须在以下情况终止并说明原因：

- 工作区有未提交变更
- 当前分支没有记录 `porter-base`
- 当前已在目标 base 分支
- 本地 base 与远端分叉，无法 fast-forward
- rebase 发生冲突
- `git merge --ff-only` 无法线性合并

## 下一步

```text
git push origin <base>                         # 推送到远端
$porter-codex-plugin:new-branch                # 开始新的普通分支工作
$porter-codex-plugin:new-branch-worktree       # 开始新的 worktree 并行工作
```
