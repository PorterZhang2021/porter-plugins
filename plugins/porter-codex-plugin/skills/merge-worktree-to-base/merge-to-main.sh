#!/usr/bin/env bash
set -euo pipefail

# ── helpers ──────────────────────────────────────────────────────────────────
info()  { echo "[merge-worktree-to-base] $*"; }
error() { echo "[merge-worktree-to-base] ERROR: $*" >&2; exit 1; }

# ── 1. 确认当前分支 ───────────────────────────────────────────────────────────
CURRENT=$(git branch --show-current)
[ -z "$CURRENT" ] && error "当前处于 detached HEAD 状态，无法合并"

BASE=$(git config --get "branch.$CURRENT.porter-base" || true)
[ -z "$BASE" ] && error "当前分支没有记录 porter-base，请先使用 \$porter-codex-plugin:new-branch-worktree 创建分支，或手动设置：git config branch.$CURRENT.porter-base <base>"

[ "$CURRENT" = "$BASE" ] && error "当前已在 $BASE 分支，无需合并"

# ── 2. 检查工作区是否干净 ──────────────────────────────────────────────────────
if ! git diff --quiet || ! git diff --cached --quiet; then
  error "工作区有未提交的变更，请先运行 \$porter-codex-plugin:commit"
fi

# ── 3. 获取主仓库路径（兼容 worktree）────────────────────────────────────────
MAIN_REPO=$(git worktree list | head -1 | awk '{print $1}')
[ -z "$MAIN_REPO" ] && error "无法检测主仓库路径"

MAIN_CURRENT=$(git -C "$MAIN_REPO" branch --show-current)
[ "$MAIN_CURRENT" = "$BASE" ] || error "主仓库当前在 $MAIN_CURRENT 分支，不是目标 base 分支 $BASE"

if ! git -C "$MAIN_REPO" diff --quiet || ! git -C "$MAIN_REPO" diff --cached --quiet; then
  error "主仓库工作区有未提交的变更，请先处理后再合并"
fi

if ! git -C "$MAIN_REPO" show-ref --verify --quiet "refs/heads/$BASE"; then
  error "主仓库中不存在本地 base 分支：$BASE"
fi

# ── 4. 拉取远端并同步本地 base ───────────────────────────────────────────────
if git ls-remote --exit-code --heads origin "$BASE" >/dev/null 2>&1; then
  info "拉取 origin/$BASE ..."
  git fetch origin "$BASE"

  info "同步本地 $BASE 到 origin/$BASE ..."
  if ! git -C "$MAIN_REPO" merge --ff-only "origin/$BASE" 2>/dev/null; then
    error "本地 $BASE 与 origin/$BASE 已分叉，请先手动排查后再合并"
  fi
else
  info "远端 origin/$BASE 不存在，使用本地 $BASE 作为 fallback"
fi

BASE_REF="refs/heads/$BASE"
BASE_COMMIT=$(git -C "$MAIN_REPO" rev-parse "$BASE_REF")
BASE_SUMMARY=$(git -C "$MAIN_REPO" log -1 --oneline "$BASE_COMMIT")

info "合并计划："
info "  当前分支：$CURRENT"
info "  目标分支：$BASE"
info "  目标提交：$BASE_SUMMARY"
info "  主仓库：$MAIN_REPO"
info "  主仓库当前分支：$MAIN_CURRENT"

# ── 5. 检查当前分支是否落后本地 base ──────────────────────────────────────────
BEHIND=$(git log "HEAD..$BASE_COMMIT" --oneline)
if [ -n "$BEHIND" ]; then
  info "$BASE 有当前分支未包含的提交，开始 rebase 到 $BASE_COMMIT ..."
  if ! git rebase "$BASE_COMMIT"; then
    git rebase --abort
    error "rebase 发生冲突，已中止。请手动解决冲突后重新运行 \$porter-codex-plugin:merge-worktree-to-base"
  fi
  info "rebase 完成"
fi

# ── 6. fast-forward 合并进 base ───────────────────────────────────────────────
info "合并 $CURRENT → $BASE ..."
git -C "$MAIN_REPO" merge --ff-only "$CURRENT"

# ── 7. 展示结果 ───────────────────────────────────────────────────────────────
echo ""
echo "✓ 合并成功，线性历史如下："
git -C "$MAIN_REPO" log --oneline -4
echo ""
echo "下一步："
echo "  推送到远端 → git push origin $BASE"
echo "  开始新功能 → \$porter-codex-plugin:new-branch-worktree"
