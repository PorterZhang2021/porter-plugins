#!/usr/bin/env bash
set -euo pipefail

# ── helpers ──────────────────────────────────────────────────────────────────
info()  { echo "[merge-to-main] $*"; }
error() { echo "[merge-to-main] ERROR: $*" >&2; exit 1; }

# ── 1. 确认当前分支 ───────────────────────────────────────────────────────────
CURRENT=$(git branch --show-current)
[ -z "$CURRENT" ] && error "当前处于 detached HEAD 状态，无法合并"

BASE=$(git remote show origin | grep 'HEAD branch' | awk '{print $NF}')
[ -z "$BASE" ] && error "无法检测远端默认主分支名"

[ "$CURRENT" = "$BASE" ] && error "当前已在 $BASE 分支，无需合并"

info "当前分支：$CURRENT  →  目标：$BASE"

# ── 2. 检查工作区是否干净 ──────────────────────────────────────────────────────
if ! git diff --quiet || ! git diff --cached --quiet; then
  error "工作区有未提交的变更，请先运行 /commit"
fi

# ── 3. 获取主仓库路径（兼容 worktree）────────────────────────────────────────
MAIN_REPO=$(git worktree list | head -1 | awk '{print $1}')

# ── 4. 拉取远端并同步本地 master ──────────────────────────────────────────────
info "拉取 origin/$BASE ..."
git fetch origin "$BASE"

info "同步本地 $BASE 到 origin/$BASE ..."
if ! git -C "$MAIN_REPO" merge --ff-only "origin/$BASE" 2>/dev/null; then
  error "本地 $BASE 与 origin/$BASE 已分叉，请先手动排查后再合并"
fi

# ── 5. 检查 feature 分支是否落后本地 master ───────────────────────────────────
BEHIND=$(git log "HEAD..$BASE" --oneline)
if [ -n "$BEHIND" ]; then
  info "$BASE 有当前分支未包含的提交，开始 rebase ..."
  if ! git rebase "$BASE"; then
    git rebase --abort
    error "rebase 发生冲突，已中止。请手动解决冲突后重新运行 /merge-to-main"
  fi
  info "rebase 完成"
fi

# ── 6. fast-forward 合并进 master ─────────────────────────────────────────────
info "合并 $CURRENT → $BASE ..."
git -C "$MAIN_REPO" merge --ff-only "$CURRENT"

# ── 7. 展示结果 ───────────────────────────────────────────────────────────────
echo ""
echo "✓ 合并成功，线性历史如下："
git -C "$MAIN_REPO" log --oneline -4
echo ""
echo "下一步："
echo "  推送到远端 → git push origin $BASE"
echo "  开始新功能 → /new-branch"
