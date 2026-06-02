---
name: merge-to-main
description: 将当前分支合并回主分支（main/master），保留分支
allowed-tools:
  - Bash
---

# Merge to Main Skill

将当前分支合并回主分支（main/master），保留分支。

## 执行

直接运行与本 skill 同目录的脚本（将 `<skill-base-dir>` 替换为本文件所在目录）：

```bash
bash "<skill-base-dir>/merge-to-main.sh"
```

脚本会自动完成：
1. 确认当前分支不是 master
2. 检查工作区是否干净
3. `git fetch origin <base>`
4. 本地 master `--ff-only` 同步到 `origin/<base>`
5. 检查 feature 分支是否落后本地 master，落后则自动 `git rebase <base>`
6. `git merge --ff-only` 保证线性历史合并

## 异常处理

脚本会在以下情况自动终止并说明原因：
- 工作区有未提交变更
- 本地 master 与远端分叉（需手动排查）
- rebase 发生冲突（自动 abort，提示手动解决）

## 下一步

```
git push origin <base>   # 推送到远端
/new-branch              # 开始新功能
```
