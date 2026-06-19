# Task: Define Solution Entry And SOLUTION.md

## Timeline Context

- Solution: `.codex/timeline/feat/refactor-feature-development/SOLUTION.md`
- Branch: `feat/refactor-feature-development`
- Type: `feat`
- Work slice: 001
- Next stage: `$porter-codex-plugin:solution-execute`

## Task 1: Create `solution` Skill Entry

无业务逻辑，无需自动化测试；通过结构审查验证。

- [x] 创建 `plugins/porter-codex-plugin/skills/solution/SKILL.md`
- [x] 添加完整 frontmatter：
  - `name: solution`
  - `description` 说明 pre-solution discussion 与正式 solution 写入
  - `allowed-tools` 覆盖读取、写入和查找所需能力
- [x] 写明阶段边界：
  - 只生成或更新当前分支对应的 `.codex/timeline/<branch-type>/<branch-name>/SOLUTION.md`
  - 只生成或更新当前分支对应的 `.codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json`
  - 不生成 `TASK.md`
  - 不执行实现
  - 不 review
  - 不 commit
  - 不 merge
- [x] 写明 invocation：
  - `$porter-codex-plugin:solution <问题或目标描述>`
  - 用户说"好了，帮我写方案吧"后，基于 discussion-confirmed type 写入
- [x] 写明 branch rules：
  - 必须在非 `main` / `master` 分支上运行
  - 当前分支必须符合 `<branch-type>/<branch-name>`
  - discussion-confirmed type 可与当前分支前缀不一致，但必须写入 `Branch Rename Checkpoint`
  - 用户未传入 type 时进入 pre-solution discussion，不写文件
  - 不自动创建、切换或重命名分支
- [x] 写明 required inputs：
  - `AGENTS.md`
  - `.codex/constitution.md`
  - `README.md`
  - 可选 parent context overview
- [x] 写明 required outputs：
  - `.codex/timeline/<branch-type>/<branch-name>/SOLUTION.md`
  - `.codex/timeline/<branch-type>/<branch-name>/WORKFLOW_STATE.json`
- [x] 写明 `WORKFLOW_STATE.json` 结构：
  - `state: awaiting_solution_task`
  - `current_skill: $porter-codex-plugin:solution`
  - `next_skill: $porter-codex-plugin:solution-task`
  - `timeline`
  - `branch_rename_checkpoint`
  - `allowed_outputs`

## Task 2: Define Common `SOLUTION.md` Skeleton

无业务逻辑，无需自动化测试；通过结构审查验证。

- [x] 在 `plugins/porter-codex-plugin/skills/solution/SKILL.md` 中定义通用 `SOLUTION.md` 骨架
- [x] 骨架必须包含：
  - `Timeline Context`
  - `Type Decision`
  - `Goal`
  - `Problem`
  - `Context Read`
  - `Scope`
  - `Type-Specific Analysis`
  - `Visual Model`
  - `Proposed Changes`
  - `Acceptance`
  - `Risks`
  - `Branch Rename Checkpoint`
  - `Next Step`
- [x] 明确 `Type-Specific Analysis` 必须由 `reference/<type>.md` 生成
- [x] 明确 `Type Decision` 必须记录 discussion-confirmed type、用户自然语言纠偏、branch type、selected type、置信度、理由和备选项
- [x] 明确 `solution` 不从旧 `plan-*` / `analyze-bug` 迁移模板
- [x] 明确 `solution` 前置协同只依赖 `.codex/constitution.md` 与根目录 `AGENTS.md`

## Task 3: Create Type Reference Templates

无业务逻辑，无需自动化测试；通过结构审查验证。

- [x] 创建 `plugins/porter-codex-plugin/skills/solution/reference/feat.md`
- [x] 创建 `plugins/porter-codex-plugin/skills/solution/reference/fix.md`
- [x] 创建 `plugins/porter-codex-plugin/skills/solution/reference/refactor.md`
- [x] 创建 `plugins/porter-codex-plugin/skills/solution/reference/perf.md`
- [x] 创建 `plugins/porter-codex-plugin/skills/solution/reference/test.md`
- [x] 创建 `plugins/porter-codex-plugin/skills/solution/reference/docs.md`
- [x] 创建 `plugins/porter-codex-plugin/skills/solution/reference/build.md`
- [x] 创建 `plugins/porter-codex-plugin/skills/solution/reference/ci.md`
- [x] 创建 `plugins/porter-codex-plugin/skills/solution/reference/chore.md`
- [x] 创建 `plugins/porter-codex-plugin/skills/solution/reference/style.md`
- [x] 每个 reference 必须说明：
  - 该 type 在 `Type-Specific Analysis` 中必须包含哪些字段
  - 该 type 在 `Visual Model` 中是否必须、建议或可选使用 Mermaid
  - 该 type 的验收标准如何表达
  - 后续 `solution-task` 应选择哪类任务模板

## Task 4: Define Special Fix Analysis Flow

无业务逻辑，无需自动化测试；通过结构审查验证。

- [x] 在 `plugins/porter-codex-plugin/skills/solution/reference/fix.md` 中明确 `fix` 是分析型 reference
- [x] 写明 `fix` 流程：
  - 收集现象
  - 复现问题
  - 定位根因
  - 提出修复方案
  - 定义回归标准
  - 写入 `SOLUTION.md`
- [x] 写明信息不足时必须暂停并索取：
  - 错误日志或堆栈跟踪
  - 复现步骤
  - 预期行为 vs 实际行为
  - 相关代码位置
- [x] 写明可自行复现时必须记录：
  - 复现命令
  - 关键输出
  - 复现结果
- [x] 写明复现失败时必须记录复现障碍，不得跳过根因分析假装成功
- [x] 写明新链路中不额外调用 `$porter-codex-plugin:analyze-bug`

## Task 5: Define Special Perf Measurement Flow

无业务逻辑，无需自动化测试；通过结构审查验证。

- [x] 在 `plugins/porter-codex-plugin/skills/solution/reference/perf.md` 中明确 `perf` 是度量型 reference
- [x] 写明 `perf` 流程：
  - 明确性能目标或瓶颈线索
  - 建立度量方式
  - 记录基线或采集计划
  - 分析瓶颈
  - 提出优化方案
  - 定义验证标准
- [x] 写明信息不足时必须暂停并索取：
  - 性能问题发生在哪个流程或命令
  - 当前可感知的慢点、资源消耗或失败表现
  - 数据规模、输入样本或运行环境
  - 期望目标或可接受阈值
  - 是否已有 benchmark、profiling 或日志数据
- [x] 写明可自行度量时必须记录：
  - 度量命令或观察方法
  - 环境和数据规模
  - 优化前基线数据
  - 关键瓶颈现象
- [x] 写明没有基线数据或基线采集计划时，不得直接生成优化实现任务

## Task 6: Define Confirmation Mechanism

无业务逻辑，无需自动化测试；通过结构审查验证。

- [x] 在 `plugins/porter-codex-plugin/skills/solution/SKILL.md` 的通用骨架中加入 `Confirmation Needed`
- [x] 写明每次生成 `SOLUTION.md` 后必须让用户确认 `Confirmation Needed`
- [x] 写明确认点至少覆盖：
  - 范围边界
  - 输出路径和命名
  - branch rename checkpoint 是否需要先交给 `delivery-branch`
  - 方案取舍
  - 风险和验收标准
  - 是否可以进入 `$porter-codex-plugin:solution-task`
- [x] 在每个 `solution/reference/*.md` 中补充 `Confirmation Needed 建议`
- [x] 更新收尾提示，要求用户先确认再进入 `solution-task`

## Task 7: Define Visual Model Guidance

无业务逻辑，无需自动化测试；通过结构审查验证。

- [x] 在 `plugins/porter-codex-plugin/skills/solution/SKILL.md` 的通用骨架中加入 `Visual Model`
- [x] 明确 `Visual Model` 用于表达流程、结构、调用顺序或验证链路
- [x] 明确 `feat` 默认需要 Mermaid：
  - 优先 `flowchart`
  - 多角色、服务、API、异步顺序使用 `sequenceDiagram`
  - 小功能无流程时必须写明无图原因
- [x] 明确 `fix` 通常需要 Mermaid：
  - `flowchart` 表达触发条件、错误路径、根因和修复点
  - `sequenceDiagram` 表达多组件调用或异步问题
- [x] 明确 `perf` 需要 Mermaid 表达度量链路：
  - baseline
  - bottleneck
  - optimization
  - verification
- [x] 明确 `refactor`、`build`、`ci` 建议使用 Mermaid 表达结构或流程
- [x] 明确 `test`、`docs`、`chore`、`style` 按场景可选使用 Mermaid
- [x] 在 `.codex/timeline/feat/refactor-feature-development/SOLUTION.md` 中同步 `Visual Model` 方案
- [x] 在 `.codex/timeline/mvp/workflow-architecture-refactor/MVP_OVERVIEW.md` 中同步 Slice 001 验收

## Task 8: Define Pre-Solution Discussion Guidance

无业务逻辑，无需自动化测试；通过结构审查验证。

- [x] 在 `plugins/porter-codex-plugin/skills/solution/SKILL.md` 中定义 type 解析规则
- [x] 明确默认使用方式是不先传 type，而是直接进入 pre-solution discussion
- [x] 定义默认入口进入 pre-solution discussion
- [x] 明确 pre-solution discussion 可以发生在创建开发分支之前
- [x] 明确 pre-solution discussion 不写入 `.codex/timeline/`
- [x] 移除 `$porter-codex-plugin:solution <type> <问题或目标描述>` 命令入口
- [x] 明确 type 只能来自讨论结论或用户自然语言纠偏
- [x] 支持用户默认先讨论目标、候选 type、范围边界和方案方向
- [x] 明确普通澄清阶段保持自然对话，不每次回复都完整套模板
- [x] 明确只在关键节点输出 checkpoint 小结：
  - 初步理解形成
  - 候选 type 变化
  - 范围边界变化
  - 用户要求总结、确认或写方案
  - 需要建议创建或切换分支
- [x] 支持讨论过程中按需读取 `reference/<type>.md` 对比候选模板
- [x] 明确不在每次对话中重复读取或套用 `reference/<type>.md`
- [x] 支持讨论过程中切换候选 type，并说明切换原因
- [x] 支持用户发现候选 type 不对时主动纠偏，并回到 discussion 重新整理
- [x] 支持用户说"好了，帮我写方案吧"后触发正式写入检查
- [x] 支持用户说"可以开始写方案了"、"按这个落地方案"后触发正式写入检查
- [x] 支持用户说"性能相关"、"文档相关"、"修复问题"等自然语言 type 倾向
- [x] 用户提出 type 倾向时，按需读取对应 `reference/<type>.md` 并引导 type-specific 确认问题
- [x] 支持发现多目标时建议拆成多个 solution
- [x] 支持发现范围变大时提示可能升级为 MVP
- [x] 讨论阶段只输出讨论结论和下一步，不写入 `SOLUTION.md`
- [x] discussion-confirmed type 与 branch 前缀或命名冲突时写入 `Branch Rename Checkpoint`，不自动改分支
- [x] pre-solution discussion checkpoint 必须展示：
  - 我的理解
  - 候选类型
  - 当前边界
  - 已参考模板，如本轮实际读取或套用过
  - 需要确认
  - 下一步
- [x] 在 `SOLUTION.md` 通用骨架中加入 `Type Decision`
- [x] 在 `.codex/timeline/feat/refactor-feature-development/SOLUTION.md` 中同步 pre-solution discussion 规则

## Task 9: Validate Structure

无业务逻辑，无需自动化测试；通过结构审查验证。

- [x] 确认 `plugins/porter-codex-plugin/skills/solution/SKILL.md` frontmatter 完整
- [x] 确认 `plugins/porter-codex-plugin/skills/solution/reference/*.md` 文件齐全
- [x] 确认 `plugins/porter-codex-plugin/skills/solution/reference/*.md` 都包含 `Visual Model`
- [x] 确认所有新增路径使用 kebab-case
- [x] 确认所有初始输出路径指向当前分支对应的 `.codex/timeline/<branch-type>/<branch-name>/`
- [x] 确认讨论阶段不会直接写入 timeline 文件
- [x] 确认没有把 `.claude/constitution.md` 写成 Codex 前置依赖
- [x] 确认本 slice 未修改旧 `plan-*` / `analyze-bug` skill
- [x] 确认本 slice 未处理 worktree 并行模式

## Completion Criteria

- [x] `solution` skill 入口定义完成
- [x] 通用 `SOLUTION.md` 骨架定义完成
- [x] 所有 type reference 模板定义完成
- [x] Pre-solution discussion / Type Decision 机制定义完成
- [x] `fix` 分析型 reference 定义完成
- [x] `perf` 度量型 reference 定义完成
- [x] `Confirmation Needed` 确认机制定义完成
- [x] `Visual Model` / Mermaid 规则定义完成
- [x] `Branch Rename Checkpoint` 定义完成
- [x] 结构审查完成
