# 任务清单

## 状态说明

- `[ ]` 待开始
- `[~]` 进行中
- `[x]` 已完成

---

## Task 1：脚本骨架

无业务逻辑，无需测试。

- [x] 创建 `install.sh`，添加执行权限
- [x] 定义核心变量：`CLAUDE_HOME`、`REPO_ROOT`、`DRY_RUN`、`ONLY`、`SUMMARY`
- [x] 实现依赖检查：`rsync` 与 `python3` 不存在时报错退出
- [x] 实现参数解析循环（`--dry-run`、`--only`、`--help`）
- [x] 实现 `--help` 帮助信息输出

## Task 2：commands 同步

无业务逻辑，无需测试。

- [x] 抽取 `_rsync_sync()` 公共函数，供 commands/skills 复用
- [x] 使用 `rsync -av --stats` 静默同步，捕获输出解析文件数与文件列表
- [x] `--dry-run` 时加 `--dry-run` 标志，只打印不写入
- [x] 将结果写入 `SUMMARY` 数组（含文件列表）

## Task 3：skills 同步

无业务逻辑，无需测试。

- [x] 复用 `_rsync_sync()` 同步 `skills/` → `$CLAUDE_HOME/skills/`
- [x] `--dry-run` 时加 `--dry-run` 标志
- [x] 将结果写入 `SUMMARY` 数组（含文件列表）

## Task 4：settings 合并

有业务逻辑（深度合并），手动验收。

- [x] 实现 `merge_settings()` 函数
- [x] 用 `python3 -c` 内联实现深度合并：仓库 key 覆盖本地同名 key，本地独有 key 保留
- [x] `--dry-run` 时只打印合并结果，不写入文件
- [x] `$CLAUDE_HOME/settings.json` 不存在时直接复制

## Task 5：`--only` 过滤

无业务逻辑，无需测试。

- [x] 根据 `ONLY` 变量值只调用对应函数（commands / skills / settings）
- [x] `ONLY` 为空时调用全部三个函数

## Task 6：变更摘要输出

无业务逻辑，无需测试。

- [x] 各步骤静默执行，不打印中间过程
- [x] 同步完成后统一打印 `SUMMARY` 数组：每类资产显示文件数 + 具体文件列表
- [x] dry-run 模式额外标注 `(dry-run mode — no files were written)`
