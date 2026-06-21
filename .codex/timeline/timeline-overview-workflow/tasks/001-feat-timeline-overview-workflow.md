# 任务：timeline-overview workflow

## 时间线上下文

- 方案：`.codex/timeline/timeline-overview-workflow/solutions/001-feat-timeline-overview-workflow.md`
- 时间线：`.codex/timeline/timeline-overview-workflow/`
- 当前切片：`001-feat-timeline-overview-workflow`
- 状态：`.codex/timeline/timeline-overview-workflow/states/001-feat-timeline-overview-workflow.json`
- 工作上下文：`/Users/porterzhang/AiCode/porter-plugins`
- 类型：`feat`
- 下一阶段：`$porter-codex-plugin:solution-execute`

## 状态说明

- `[ ]` 待处理
- `[~]` 进行中
- `[x]` 已完成

## 执行规则

- 除非任务明确说明可独立执行，否则按顺序执行。
- 前置测试、复现步骤、度量或验证准备完成前，不要开始实现任务。
- 只有验证步骤通过或验证限制已记录后，才能把任务标记为完成。
- 每个任务必须包含 `验收标准` 和 `验证方式`；没有可观察证据时不得标记完成。

## Task 1：新增 timeline-overview skill

无业务逻辑，无需测试；通过结构审查验证。

- [x] **[实现]** `plugins/porter-codex-plugin/skills/timeline-overview/SKILL.md`
  - 新增 Codex skill frontmatter，`name` 使用 `timeline-overview`，`description` 说明它负责 timeline 级范围判断、总览同步和收口。
  - 定义唯一入口：`$porter-codex-plugin:timeline-overview <自然语言意图>`。
  - 明确用户不需要手动选择 `assess` / `sync` / `close`；这些只是 skill 内部模式。
  - 定义自动模式：`assess`、`sync`、`close`、`gate`、`clarify`。
  - 明确输出边界：只创建或更新 `.codex/timeline/<timeline-name>/OVERVIEW.md` 和 `.codex/timeline/<timeline-name>/CHANGELOG.md`。
  - 明确不创建 solution slice id、不生成 task、不执行实现、不 review、不 commit。
  - 明确 active slice 未终止时，提示继续 state 中的 `next_skill`，不推进 close。
  - 明确 overview 层状态只是人类可读账本，不替代 `states/<slice>.json` workflow gate。
- [x] 验收标准：新增 skill 文档完整覆盖 SOLUTION.md 的功能边界、自动模式、输出路径和状态边界；不把 `timeline-overview` 写成必经 gate。
- [x] 验证方式：人工审查 `SKILL.md` frontmatter 和章节；用 `rg` 检查 `assess`、`sync`、`close`、`states/<slice>.json`、`OVERVIEW.md`、`CHANGELOG.md` 等关键约束存在。

执行记录：

- 已新增 `plugins/porter-codex-plugin/skills/timeline-overview/SKILL.md`。
- `rg` 已确认 `assess`、`sync`、`close`、`states/<slice>.json`、`OVERVIEW.md`、`CHANGELOG.md` 等关键约束存在。

## Task 2：更新 skill-recommender 推荐规则

无业务逻辑，无需测试；通过结构审查验证。

- [x] **[实现]** `plugins/porter-codex-plugin/skills/skill-recommender/SKILL.md`
  - 将 `timeline-overview` 加入适用场景：范围不确定、怀疑多个 slice、同步一串 solution 进展、timeline 收尾或总结。
  - 保持小目标默认推荐 `$porter-codex-plugin:solution`。
  - 明确 review pass 后确认 commit 仍不推荐新 skill。
  - 最多给出两个选择的原则保持不变。
- [x] 验收标准：推荐器能区分小目标、多个 slice / timeline 总览、已有 active state 下一步和 commit confirmation。
- [x] 验证方式：人工审查推荐表；用 `rg` 检查 `timeline-overview`、`多个 slice`、`范围不确定`、`收尾`、`solution` 等关键词；确认未删除既有推荐项。

执行记录：

- 已在推荐规则中加入 `timeline-overview` 的范围判断、多个 slice、进展同步和收尾场景。
- 已保留小目标进入 `$porter-codex-plugin:solution`，review pass 后确认 commit 仍使用普通 Git commit 的规则。

## Task 3：更新 README 推荐路径说明

无业务逻辑，无需测试；通过结构审查验证。

- [x] **[实现]** `README.md`
  - 在 Codex skills 表中加入 `timeline-overview`。
  - 在 Recommended Workflows 中说明默认仍使用 solution 内容闭环。
  - 增加 timeline overview 可选路径：当目标范围不确定、连续多个 solution 需要整理、或需要收口总结时使用。
  - 说明 `OVERVIEW.md` / `CHANGELOG.md` 是 timeline 级人类可读账本。
  - 说明 overview 状态不替代 `states/<slice>.json` 的 workflow gate。
  - 避免把 `stage-overview` 或 `MVP_OVERVIEW.md` 写成新主路径。
- [x] 验收标准：README 能解释 `timeline-overview` 与 solution workflow 的关系；不暗示 `mvp` 是 slice type；不声称 overview 是强制步骤。
- [x] 验证方式：人工审查 README diff；用 `rg` 检查 `timeline-overview`、`OVERVIEW.md`、`CHANGELOG.md`、`states/<slice>.json`、`mvp` 等关键词上下文。

执行记录：

- 已在 Skills 表加入 `timeline-overview`。
- 已在 Recommended Workflows 增加可选 timeline overview 路径，并说明默认小目标仍进入 `$porter-codex-plugin:solution`。
- `rg` 检查中 README 未出现 `mvp` / `MVP` / `stage-overview` / `MVP_OVERVIEW` 新主路径表述。

## Task 4：最终结构审查和变更范围验证

无业务逻辑，无需测试；通过结构审查验证。

- [x] **[验证]** Frontmatter 和 Markdown 结构
  - 检查新增 skill frontmatter 字段完整。
  - 检查 Markdown 代码围栏成对闭合。
  - 检查文档路径均为 Codex 插件侧或当前 timeline。
- [x] **[验证]** JSON 和 state 指针
  - 校验 `.codex/timeline/timeline-overview-workflow/current.json`。
  - 校验 `.codex/timeline/timeline-overview-workflow/states/001-feat-timeline-overview-workflow.json`。
  - 确认 state 进入 `awaiting_solution_review` 前，task 完成情况和 allowed outputs 一致。
- [x] **[验证]** 禁止项
  - 检查未新增 `mvp` slice type。
  - 检查未修改 `plugins/porter-claude-plugin/`。
  - 检查未操作用户 home 配置。
  - 检查未把 `timeline-overview` 插入 solution 核心状态机。
- [x] 验收标准：所有结构检查通过，变更范围符合 SOLUTION.md；未出现 Claude 侧或用户 home 配置变更。
- [x] 验证方式：运行 `jq` 校验 JSON；用 `rg` 和 `git diff --name-status` 审查关键词和文件范围；记录验证命令结果或限制。

执行记录：

- `jq . .codex/timeline/timeline-overview-workflow/current.json .codex/timeline/timeline-overview-workflow/states/001-feat-timeline-overview-workflow.json plugins/porter-codex-plugin/.codex-plugin/plugin.json` 通过。
- Markdown 代码围栏计数：`timeline-overview/SKILL.md:24`、`skill-recommender/SKILL.md:6`、`README.md:38`、solution 文件 `14`，均为偶数；task 文件无代码围栏。
- `git diff --name-status -- plugins/porter-claude-plugin` 无输出。
- `rg` 检查未发现 `mvp-overview`、`stage-overview` 或 `MVP_OVERVIEW` 被写入本次触达文件；`mvp` 仅出现在 `timeline-overview` skill 的禁止新增 `mvp` type 说明中。
- `git status --short` 显示变更范围为 `README.md`、`plugins/porter-codex-plugin/skills/skill-recommender/SKILL.md`、新增 `plugins/porter-codex-plugin/skills/timeline-overview/` 和当前 timeline 过程记录。

## Task 5：回修 solution 与 timeline-overview 的入口闭环

无业务逻辑，无需测试；通过结构审查验证。

- [x] **[回修]** `plugins/porter-codex-plugin/skills/solution/SKILL.md`
  - 明确 pre-solution discussion 发现目标明显超过单个 slice 时，推荐 `$porter-codex-plugin:timeline-overview`。
  - 明确尚未正式写入 solution 文件时，应停止写入半成品 solution，先进入 timeline overview discussion。
  - 保持 `solution` 不创建 overview、不拆完整 timeline、不改变 state 机。
- [x] **[回修]** `plugins/porter-codex-plugin/skills/timeline-overview/SKILL.md`
  - 明确 timeline overview 也有前置讨论、checkpoint 小结、写入前回放和用户确认。
  - 明确它讨论的是 timeline 级总目标、slice 列表、候选 type、顺序和完成标准。
  - 明确写入 `OVERVIEW.md` 后推荐回到 `$porter-codex-plugin:solution` 做第一个 slice。
- [x] **[回修]** `README.md`
  - 补充 `solution` 发现范围过大时可以先切到 `timeline-overview`。
- [x] 验收标准：`solution -> timeline-overview -> solution` 的闭环在 skill 文档和 README 中明确；不会误导用户以为 `timeline-overview` 会直接执行所有 type。
- [x] 验证方式：用 `rg` 检查 `$porter-codex-plugin:timeline-overview`、`停止写入`、`回到 $porter-codex-plugin:solution`、`前置讨论`、`候选 type` 等关键词；人工审查相关 diff。

执行记录：

- `solution` 已明确在 pre-solution discussion 发现目标明显超过单个 slice 时，停止写入 solution 文件并建议调用 `$porter-codex-plugin:timeline-overview`。
- `timeline-overview` 已补充前置总览讨论、checkpoint 小结、写入前回放确认，以及写入 `OVERVIEW.md` 后回到 `$porter-codex-plugin:solution` 的规则。
- `README.md` 已说明 `solution -> timeline-overview -> solution` 的闭环路径。
- `rg -F` 已确认 `$porter-codex-plugin:timeline-overview`、`停止写入 solution 文件`、`写入 \`OVERVIEW.md\` 后停止`、`$porter-codex-plugin:solution`、`候选 type` 等关键约束存在。

## Task 6：回修 Codex 插件版本号

无业务逻辑，无需测试；通过 manifest 结构审查验证。

- [x] **[回修]** `plugins/porter-codex-plugin/.codex-plugin/plugin.json`
  - 将 Codex 插件 manifest `version` 更新为 `2.1.0`。
- [x] 验收标准：`plugins/porter-codex-plugin/.codex-plugin/plugin.json` 中的 `version` 为 `2.1.0`，manifest 仍可被插件校验脚本接受。
- [x] 验证方式：运行 `jq` 校验 JSON；运行 plugin manifest validator；记录验证结果。

执行记录：

- 已将 manifest `version` 更新为 `2.1.0`。
- `jq . plugins/porter-codex-plugin/.codex-plugin/plugin.json .codex/timeline/timeline-overview-workflow/states/001-feat-timeline-overview-workflow.json` 通过。
- `jq -r '.version' plugins/porter-codex-plugin/.codex-plugin/plugin.json` 输出 `2.1.0`。
- 直接运行 `python3 /Users/porterzhang/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py plugins/porter-codex-plugin` 时，本机 Python 缺少 `yaml` 模块，脚本在 import 阶段失败，尚未读取插件文件。
- 使用临时 `PYTHONPATH` 提供 `yaml.safe_load` frontmatter 解析后，`validate_plugin.py plugins/porter-codex-plugin` 通过，输出 `Plugin validation passed`。

## Task 7：回修 timeline-overview 输出语言约定

无业务逻辑，无需测试；通过结构审查和关键词审查验证。

- [x] **[回修]** `plugins/porter-codex-plugin/skills/timeline-overview/SKILL.md`
  - 增加语言约定：默认输出中文，保留 skill 名、路径、state、type、timeline name、slice id、命令等稳定标识为英文。
  - 将 `OVERVIEW.md` 模板标题、章节和表头调整为中文为主。
  - 将 `CHANGELOG.md` 模板标题、章节和表头调整为中文为主。
  - 保持 `candidate`、`active`、`committed`、`deferred`、`cancelled` 等 overview 状态值不变。
- [x] 验收标准：后续调用 `timeline-overview` 时，说明文字和生成模板默认中文；不会因为英文模板标题导致输出大面积中英文混排。
- [x] 验证方式：用 `rg` 检查 `语言约定`、`默认输出使用中文`、`Timeline 总览`、`目标`、`Slice 候选列表`、`Timeline 变更记录`、`后续事项` 等关键词；检查 Markdown 围栏成对闭合。

执行记录：

- 已增加 `timeline-overview` 语言约定。
- 已将 `OVERVIEW.md` / `CHANGELOG.md` 模板标题、章节和表头调整为中文为主。
- `rg` 已确认 `语言约定`、`默认输出使用中文`、`Timeline 总览`、`目标`、`Slice 候选列表`、`Timeline 变更记录`、`后续事项` 以及 overview 状态值存在。
- Markdown 代码围栏计数：`timeline-overview/SKILL.md:24`、solution 文件 `14`、task 文件 `0`，均为偶数。
- `jq` 校验 current/state/plugin manifest 通过；插件版本仍为 `2.1.0`。
- `git diff --check` 无输出；`git diff --name-status -- plugins/porter-claude-plugin` 无输出。
