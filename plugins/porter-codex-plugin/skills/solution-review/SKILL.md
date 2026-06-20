---
name: solution-review
description: 审查 active solution timeline slice，写入 review 文件；pass 后进入用户 commit 确认态，有问题时回到 solution-execute 回修
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
---

# Solution Review 审查

在 `$porter-codex-plugin:solution-execute` 后审查 active slice：

```text
solution -> solution-task -> solution-execute -> solution-review
```

本 skill 为 active slice 写入可追踪的 review 文件，并更新 active slice state。

## 阶段边界

- 只审查当前 active solution workflow 结果。
- 写入或更新 active slice 的 review 文件。
- 写入或更新 active slice 的 state 文件。
- 不修改 review 输出之外的实现、文档或配置文件。
- 不更新 task 文件。
- 不更新 solution 文件。
- 不执行修复。
- 不提交。
- 不合并、不 push、不 create PR。
- review 完成后停止，并提示用户下一步。

新 slice 的 review 输出：

```text
.codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md
.codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.contract.json
.codex/timeline/<timeline-name>/states/<slice-id>-<type>-<slug>.json
```

## 调用方式

```text
$porter-codex-plugin:solution-review
```

无需命令参数。

## Protected Branch Guard

review 前必须检查当前 Git 分支。

- 如果当前分支是 `main` 或 `master`，停止，不写 review 或 state，提示用户先自行切换到开发分支或使用 Codex 原生 Git 能力创建工作上下文。
- 不要求分支名符合 `<type>/<name>`。
- 不要求分支 type 等于 slice type。
- 不要求存在 `branch.<branch>.porter-base`。

## 路径解析

`solution-review` 不创建新的 slice id。

timeline name 解析顺序：

1. 如果用户在本轮对话中明确确认了 timeline name，使用该名称。
2. 如果当前分支不是 `main` / `master`，可以把分支名第一段 `/` 之后的部分作为默认 timeline name；没有 `/` 时，可以把整个分支名作为默认 timeline name。
3. 如果默认 `.codex/timeline/<timeline-name>/current.json` 不存在，扫描 `.codex/timeline/*/current.json`。
4. 只有当扫描结果中恰好一个 `current.json` 指向允许 `$porter-codex-plugin:solution-review` 的 state 时，才使用该 timeline。
5. 如果没有匹配或存在多个匹配，停止并请用户明确 timeline name。

review 前：

1. 如果 `.codex/timeline/<timeline-name>/current.json` 存在，优先使用它。
2. 读取 `current.json` 并解析 active slice 文件：
   - `solution`
   - `task`
   - `review`
   - `state`
3. 从 `states/<slice>.json` 读取 active slice state。
4. 新 slice 创建必须使用新路径，并且只能由 `$porter-codex-plugin:solution` 完成。

## 前置条件

1. 确认 `AGENTS.md` 存在。
2. 确认 `.codex/constitution.md` 存在。
3. 执行 protected branch guard。
4. 通过 `current.json` 解析 active slice。

必须存在的 active slice 文件：

- solution 文件
- task 文件
- state 文件

可选 active slice 文件：

- review 文件；仅在需要验证回修时读取

## current.json

`current.json` 是 active slice 指针，不是 workflow state。

```json
{
  "timeline": ".codex/timeline/<timeline-name>",
  "active_slice": "<slice-id>-<type>-<slug>",
  "solution": ".codex/timeline/<timeline-name>/solutions/<slice-id>-<type>-<slug>.md",
  "task": ".codex/timeline/<timeline-name>/tasks/<slice-id>-<type>-<slug>.md",
  "review": ".codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md",
  "state": ".codex/timeline/<timeline-name>/states/<slice-id>-<type>-<slug>.json"
}
```

## 状态门

review 前必须读取 active slice state。

允许状态：

- `awaiting_solution_review`
- `reviewing_solution`

如果 state 缺失或不是上述状态，停止并提示：

- 若 state 是 `awaiting_user_commit_confirm` 且用户提出新修改，调用 `$porter-codex-plugin:solution-execute` 回修。
- 若 state 是 `awaiting_user_commit_confirm` 且用户确认 commit，按本文`Commit Confirmation`执行普通 Git commit。
- 若 state 是 `committed` 或 `cancelled`，该 slice 已结束。
- 其他状态按 state 文件中的 `next_skill` 继续。

没有明确 state 时不得继续。

## Reviewing 中间态

开始收集 review 输入前，先把 active slice state 写为：

```json
{
  "state": "reviewing_solution",
  "current_skill": "$porter-codex-plugin:solution-review",
  "next_skill": "$porter-codex-plugin:solution-review",
  "timeline": ".codex/timeline/<timeline-name>",
  "active_slice": "<slice-id>-<type>-<slug>",
  "solution": ".codex/timeline/<timeline-name>/solutions/<slice-id>-<type>-<slug>.md",
  "task": ".codex/timeline/<timeline-name>/tasks/<slice-id>-<type>-<slug>.md",
  "review": ".codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md",
  "allowed_outputs": [
    ".codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md",
    ".codex/timeline/<timeline-name>/states/<slice-id>-<type>-<slug>.json"
  ]
}
```

## Review 输入

写入 review 文件前收集以下上下文：

```bash
git status --short
git diff
git ls-files --others --exclude-standard
```

读取：

- active slice solution 文件
- active slice task 文件
- active slice state 文件
- active slice review 文件，如果存在且需要用于验证回修
- `git ls-files --others --exclude-standard` 报告的范围内未跟踪文件

构建 review brief，包含：

- solution 文件中的当前目标和验收标准。
- task 文件中的已完成和未完成任务。
- `git status --short` 中的当前变更摘要。
- `git diff` 中的关键 diff 摘要或文件路径。
- 未体现在 `git diff` 中的范围内未跟踪文件内容。
- 需要重点审查的风险点。

不要读取旧 workflow 输入：

- 不读取 `plan/<type>/<branch-name>/PLAN.md`。
- 不读取 `plan/<type>/<branch-name>/ANALYSIS.md`。
- 不读取旧 `plan/` workflow state。

## Review 机制

使用两层 review。当前 Codex 负责 workflow 判断和最终结论；子代理仅在可用时执行通用工程审查。

当前 Codex 必须审查：

- 业务语义，以及结果是否满足 solution 文件。
- Solution / task 一致性。
- Solution workflow 阶段边界。
- AGENTS.md 和 constitution 规则。
- Codex plugin 路径边界。
- 最终结果和下一个 workflow state。

首次正常 review 时，如果环境支持 `code-reviewer` 子代理或等价的新上下文 review 能力，默认使用两层 review。把 review brief 和相关 diff 交给子代理，只要求其基于文件事实给出通用工程 findings。

子代理可以检查：

- JSON、Markdown 和 frontmatter 有效性。
- State 不一致。
- 缺少验证证据。
- 命名或路径不一致。
- 旧 workflow 路径残留。
- 危险命令、权限边界问题或密钥风险。
- 明显的正确性、回归、可靠性、可维护性或文档问题。

子代理不得决定：

- 业务意图。
- 配置保留或删除取舍。
- Solution workflow 阶段边界。
- 是否应扩大范围。
- 任何依赖当前长上下文用户历史的决策。

当前 Codex 必须合并结果。只保留有文件、diff 或命令输出支持的发现。需要用户判断的问题降级为`待确认问题`。

如果子代理 review 不可用，在当前 Codex 上下文完成 review，并在 review 文件的`备注`章节记录原因。这是有效降级，不是 review 失败。

回修 review：

1. 只有在确认上一次 active slice review 文件的`时间线上下文`与当前 active slice id、solution 路径、task 路径、review 路径和 state 路径一致后，才读取该 review 文件。
2. 如果已有 review 文件属于更早 slice 或不同上下文，将其视为过期文件，并按首次正常 review 覆盖。
3. 验证对应的旧发现是否已经解决。
4. 当回修 diff 较大、涉及可执行行为、用户明确要求，或通用工程风险较高时，再次使用子代理。
5. 如果跳过子代理 review，在 review 文件的`备注`章节记录原因。

## Review 检查清单

选择 result 前检查以下全部内容：

- Solution 的目标、范围和验收标准仍然成立。
- Task 条目全部完成；如有未完成项，必须有清楚的记录原因。
- 每个已完成任务都有验证证据或已记录限制。
- 当前 diff 和范围内未跟踪文件只包含本 slice 允许的文件。
- 修改实现或配置文件时，新增或修改文件仍在 Codex plugin 路径边界内。
- 除非 solution 明确要求，否则没有修改 Claude 侧配置。
- 已修改 skill 的 Markdown frontmatter 有效。
- JSON 示例或 state 文件可以解析。
- Markdown 代码围栏成对闭合。
- 状态可以进入正确的下一阶段。
- review 输出没有引入本 solution loop 之外的 state，除非明确进入终止态 `cancelled`。

## REVIEW.md 结构

按以下结构写入 active slice review 文件：

```markdown
# 审查：<标题>

## 时间线上下文

- 方案：`.codex/timeline/<timeline-name>/solutions/<slice-id>-<type>-<slug>.md`
- 任务：`.codex/timeline/<timeline-name>/tasks/<slice-id>-<type>-<slug>.md`
- 审查：`.codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md`
- 状态：`.codex/timeline/<timeline-name>/states/<slice-id>-<type>-<slug>.json`
- 时间线：`.codex/timeline/<timeline-name>`
- 当前切片：`<slice-id>-<type>-<slug>`
- 类型：`<selected-type>`

## 结果

<pass | needs-fix | needs-task-update | needs-solution-update>

## 检查项

- <结构、state、命令或 review 检查>

## 发现

- <按 P0/P1/P2/P3 排序的发现；没有发现时写 "无">

## 待确认问题

- <需要用户确认的问题；没有时写 "无">

## 备注

- <非阻塞观察、子代理可用性或跳过原因>

## 下一步

<下一个明确动作>
```

`Result` 必须严格使用以下值之一：

- `pass`
- `needs-fix`
- `needs-task-update`
- `needs-solution-update`

发现必须按严重程度排序：`P0`、`P1`、`P2`、`P3`。即使没有阻塞问题，也记录非阻塞的 `P2` 和 `P3` 发现。

没有发现时写入：

```text
无
```

如果 review 发现范围、假设、验收标准、根因或瓶颈问题需要重新确认，使用 `needs-solution-update`。不要引入其它 result。

## Result 规则

以下情况使用 `pass`：

- 验收标准已经满足。
- 任务已经完成，或剩余事项已明确记录为非阻塞。
- 验证证据存在，或限制已记录。
- 没有阻塞 commit 的 `P0` 或 `P1` finding。

当实现、文档、配置或验证输出有误并需要回修时，使用 `needs-fix`。

当任务清单不完整、过期、缺少验证，或已经不能代表必要工作时，使用 `needs-task-update`。

当 solution 的假设、范围、验收标准、根因或瓶颈分析需要变化，或需要用户重新确认时，使用 `needs-solution-update`。

## 状态输出

当结果为 `pass` 时，写入 active slice state：

```json
{
  "state": "awaiting_user_commit_confirm",
  "current_skill": "$porter-codex-plugin:solution-review",
  "timeline": ".codex/timeline/<timeline-name>",
  "active_slice": "<slice-id>-<type>-<slug>",
  "solution": ".codex/timeline/<timeline-name>/solutions/<slice-id>-<type>-<slug>.md",
  "task": ".codex/timeline/<timeline-name>/tasks/<slice-id>-<type>-<slug>.md",
  "review": ".codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md",
  "review_contract": ".codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.contract.json",
  "review_contract_blob": "<git blob oid of review_contract>",
  "allowed_outputs": [
    ".codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md",
    ".codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.contract.json",
    ".codex/timeline/<timeline-name>/states/<slice-id>-<type>-<slug>.json"
  ]
}
```

`awaiting_user_commit_confirm` 不写 `next_skill`。用户可以确认 commit，也可以提出新修改并回到 `$porter-codex-plugin:solution-execute`。

review pass 必须同时写入 review contract 文件，路径固定为：

```text
.codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.contract.json
```

contract 文件是 commit confirmation 的 path/blob/mode policy source，state 只记录 `review_contract` 和 `review_contract_blob`。`review_contract_blob` 必须在 contract 文件写入完成后通过 `git hash-object --path=<contract-path> -- <contract-path>` 计算。review pass 还必须把同一个 blob 写入本地 Git anchor：

```bash
mkdir -p "$(git rev-parse --git-path porter-solution-contracts/<timeline-name>)"
printf '%s\n' "<review-contract-blob>" > "$(git rev-parse --git-path porter-solution-contracts/<timeline-name>/<slice-id-type-slug>.contract.blob)"
```

commit hook 会从 state 路径确定性推导 contract 路径，并校验 staged contract blob 同时等于 state 中记录的 `review_contract_blob` 和本地 `.git` anchor，防止 commit 前改写 state 或 contract 来扩大白名单。本地 anchor 是提交确认的安全锚点，不进入 Git commit。

contract 文件结构：

```json
{
  "timeline": ".codex/timeline/<timeline-name>",
  "active_slice": "<slice-id>-<type>-<slug>",
  "state": ".codex/timeline/<timeline-name>/states/<slice-id>-<type>-<slug>.json",
  "review": ".codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md",
  "reviewed_paths": [
    ".codex/timeline/<timeline-name>/solutions/<slice-id>-<type>-<slug>.md",
    ".codex/timeline/<timeline-name>/tasks/<slice-id>-<type>-<slug>.md",
    ".codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md",
    "<reviewed implementation/config/documentation path>"
  ],
  "reviewed_path_blobs": {
    ".codex/timeline/<timeline-name>/solutions/<slice-id>-<type>-<slug>.md": "<git blob oid>",
    ".codex/timeline/<timeline-name>/tasks/<slice-id>-<type>-<slug>.md": "<git blob oid>",
    ".codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md": "<git blob oid>",
    "<reviewed implementation/config/documentation path>": "<git blob oid or __deleted__>"
  },
  "reviewed_path_modes": {
    ".codex/timeline/<timeline-name>/solutions/<slice-id>-<type>-<slug>.md": "<git file mode>",
    ".codex/timeline/<timeline-name>/tasks/<slice-id>-<type>-<slug>.md": "<git file mode>",
    ".codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md": "<git file mode>",
    "<reviewed implementation/config/documentation path>": "<git file mode or __deleted__>"
  }
}
```

`reviewed_paths` 必须列出本次 review 已覆盖、允许进入本次 commit 的非 state、非 contract 文件路径，使用 repo-relative path。active state 文件和 review contract 文件不需要放入 `reviewed_paths`，commit confirmation 可单独 stage 它们。不得把未审查文件、宽泛目录或 `.` 写入 `reviewed_paths`。

`reviewed_path_blobs` 必须记录每个 `reviewed_paths` 路径在 review pass 时的 Git blob oid；如果 review 确认该路径应被删除，值写为 `__deleted__`。`reviewed_path_modes` 必须记录每个 `reviewed_paths` 路径在 review pass 时的 Git file mode，例如 `100644`、`100755` 或删除标记 `__deleted__`。对已跟踪或未跟踪但存在于工作区的文件，可以使用：

```bash
git hash-object --path=<repo-relative-path> -- <repo-relative-path>
git ls-files -s -- <repo-relative-path>
```

安装的 `commit-msg` hook 会用最终 staged blob oid、mode 或删除状态对比 review contract，防止 review pass 后同路径内容或 executable bit 被改写后提交。

当结果为 `needs-fix`、`needs-task-update` 或 `needs-solution-update` 时，写入 active slice state：

```json
{
  "state": "awaiting_solution_execute_from_review",
  "current_skill": "$porter-codex-plugin:solution-review",
  "next_skill": "$porter-codex-plugin:solution-execute",
  "timeline": ".codex/timeline/<timeline-name>",
  "active_slice": "<slice-id>-<type>-<slug>",
  "solution": ".codex/timeline/<timeline-name>/solutions/<slice-id>-<type>-<slug>.md",
  "task": ".codex/timeline/<timeline-name>/tasks/<slice-id>-<type>-<slug>.md",
  "review": ".codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md",
  "allowed_outputs": [
    ".codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md",
    ".codex/timeline/<timeline-name>/states/<slice-id>-<type>-<slug>.json"
  ]
}
```

review 阶段不得写入 task 文件或 solution 文件。回修属于 `$porter-codex-plugin:solution-execute`。

## Commit Confirmation

这里不是新的 plugin skill。它是 review pass 后的普通对话动作：

1. 仅当 active slice state 是 `awaiting_user_commit_confirm`，且用户明确确认要 commit 时执行。
2. 重新读取 `current.json`、active state、solution、task、review 和 `git status --short`。
3. 生成 commit message，subject 必须符合：

```text
<type>(<scope>): <summary>
```

4. commit message 必须包含 trailers：

```text
Codex-Timeline: <timeline-name>
Codex-Slice: <slice-id-type-slug>
```

5. `type` 默认与 slice type 一致；如需不同 type，必须先让用户确认。
6. `type` 必须属于 solution workflow 支持的 commit type：`feat`、`fix`、`refactor`、`perf`、`test`、`docs`、`build`、`ci`、`chore`、`style`。
7. 如果当前仓库需要普通 `git commit` 自动触发检查，先显式运行 `plugins/porter-codex-plugin/scripts/install-solution-commit-msg-hook.sh --repo .`。该安装器写入目标仓库 `.git/hooks/commit-msg`，插件安装本身不自动改 Git hooks。
8. 可以用 `plugins/porter-codex-plugin/scripts/validate-solution-commit-message.sh` 校验 message 文件；安装 hook 后，`git commit` 会自动执行同一套检查。
9. 如果 Codex `PreToolUse` hook 已加载，active slice 在 `awaiting_user_commit_confirm` 或 `committing` 时不得再写实现、文档、配置、task、solution 或 review 文件；commit confirmation 只能用单条、非复合 Bash 命令运行第 7 步的安装器、显式 stage active state 文件、review contract 文件和 contract 中记录的 `reviewed_paths`。不要使用 `git add .`、`git add -A`、`git add --all`、`git -C` 路径混淆或包含 `&&` / `;` / 管道的复合命令；新变化必须回到 `$porter-codex-plugin:solution-execute` 回修。
10. 安装的 Git `commit-msg` hook 必须拒绝没有匹配 committed solution trailer 的未终止 active solution 提交；普通 `git commit` 只有在 active state 已写为 `committed`、commit message trailer 匹配、staged review contract blob 匹配 state 记录、staged 文件均属于 review contract 或 active state/contract 文件，且 staged blob 与 mode 匹配 review contract 时才通过。仓库中其它 stale `current.json` 不应阻塞当前已匹配 committed slice 的提交；它们应由后续独立清理处理。
11. 为避免 post-commit 后再次弄脏工作区，确认提交后按以下顺序执行：
   - 确认 review contract 文件已存在，且 state 中记录了 `review_contract` 和 `review_contract_blob`。
   - 先把 state 写为 `committing`，保留 `review_contract` 和 `review_contract_blob`，记录待提交 subject 和 trailer。
   - 显式 staging review contract 文件、contract 中需要进入提交的 reviewed paths 和 active state 文件，并完成 message validation。
   - 在运行 `git commit` 前，把 state 改写为 `committed`、保留 `review_contract` / `review_contract_blob` 且移除 `next_skill`，让最终 state 随同本次 commit 一起进入提交；如果已安装 `commit-msg` hook，普通 `git commit` 会再次校验 subject、type、trailers、staged path contract、blob contract 和 mode contract。
   - 如果 `git commit` 失败，立即把 state 恢复为 `awaiting_user_commit_confirm` 或保留 `committing` 并记录失败原因，停止等待用户判断。
12. commit 成功后，用 `git log -1 --format=%B` 验证 subject 和 trailers；如果不满足 contract，不默认 amend 已 push 历史，先提示风险并等待用户决定。

`committed` state 示例：

```json
{
  "state": "committed",
  "current_skill": "git commit",
  "timeline": ".codex/timeline/<timeline-name>",
  "active_slice": "<slice-id>-<type>-<slug>",
  "solution": ".codex/timeline/<timeline-name>/solutions/<slice-id>-<type>-<slug>.md",
  "task": ".codex/timeline/<timeline-name>/tasks/<slice-id>-<type>-<slug>.md",
  "review": ".codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.md",
  "review_contract": ".codex/timeline/<timeline-name>/reviews/<slice-id>-<type>-<slug>.contract.json",
  "review_contract_blob": "<git blob oid of review_contract>",
  "commit": {
    "subject": "<type>(<scope>): <summary>",
    "trailers": {
      "Codex-Timeline": "<timeline-name>",
      "Codex-Slice": "<slice-id-type-slug>"
    }
  },
  "allowed_outputs": []
}
```

`committed` 是终止态，`next_skill` 应为空或不存在。

## 收尾提示

如果结果为 `pass`，停止并提示：

**"Review 已完成，结果为 pass。当前 slice 进入 `awaiting_user_commit_confirm`。如果确认提交，我会按 commit message contract 使用普通 Git commit；如果还要改，请调用 `$porter-codex-plugin:solution-execute` 回修。"**

如果结果为 `needs-fix`、`needs-task-update` 或 `needs-solution-update`，停止并提示：

**"Review 已完成，发现需要回修的内容。请确认后显式调用 `$porter-codex-plugin:solution-execute` 进入回修。"**
