---
name: learn-english
description: 意图确认 + 英语纠错辅助，防止英文表达不精确导致执行偏差。输出"我的理解"（中文）供用户确认后再执行任务，附带英文纠错供学习。
argument-hint: "<用英文或中文描述你想做什么>"
allowed-tools:
  - AskUserQuestion
---

# Learn English Skill

帮助用户用英文表达任务意图，通过中文确认防止执行偏差，同时附带英文纠错供学习。

## 使用方式

```
/learn-english I want add login page before the user can see dashboard
/learn-english 帮我在用户注册之后显示欢迎页面
/learn-english 帮我 delete the config file after deployment finish
```

---

## 执行流程

### Step 1：接收输入

用户的输入可能是以下三种形式之一：

| 输入形式 | 示例 | 处理方式 |
|---------|------|---------|
| 英文（可能有错） | "add login page after user register" | 解析意图 + 纠错分析 |
| 中文 | "在用户注册之后添加登录页面" | 直接提取意图 + 翻译为标准英文 |
| 中英混写 | "帮我 add a login page before the dashboard" | 拆解意图，整理为完整英文 |

**无论哪种输入形式，都先提取意图，再生成输出。不因语言形式而跳过任何步骤。**

---

### Step 2：解析意图 + 生成输出

按以下固定模板输出，不省略任何字段：

```
我的理解：[用中文完整描述任务意图，包括时序、条件、范围]

对应英文：[标准英文表达]
纠错说明：[逐条中文说明错误原因；如无错误则写"表达正确，无需修改"]
```

**语义敏感词规则（最高优先级）：**

当输入中出现以下词语时，**无论语法是否正确**，都必须在"我的理解"中用中文明确体现对应的时序或条件关系：

| 词语 | 易混淆的方向 | "我的理解"必须明确的内容 |
|------|------------|------------------------|
| after | 之后 vs 之前 | 明确"在 X 完成之后，才做 Y" |
| before | 之前 vs 之后 | 明确"在 X 发生之前，先做 Y" |
| except | 除了…之外不做 vs 只做… | 明确"排除 X，其余都…" |
| unless | 除非…否则 vs 如果… | 明确"只有当 X 不成立时，才…" |
| until | 直到…为止 vs 从…开始 | 明确"持续做 Y，直到 X 发生" |
| without | 不做 X 的情况下 | 明确"跳过 X 步骤，直接…" |

---

### Step 3：用户确认

输出完成后，使用 `AskUserQuestion` 询问用户：

**问题：** "我的理解是否正确？"

**选项：**
- **"理解正确，执行任务"** → 进入 Step 4
- **"不对，我补充一下"** → 请用户用中文或英文说明哪里理解有误，收到补充后回到 Step 2 重新解析（合并原始输入 + 用户补充）
- **"我重新描述"** → 请用户重新输入，完全替换原始输入，回到 Step 1

循环次数不限，直到用户选择"理解正确，执行任务"。

---

### Step 4：执行任务

以 Step 2 中"对应英文"的内容作为任务指令，直接执行用户的原始任务意图。

**执行阶段规则：**
- 不再重复纠错或确认步骤
- 若执行过程中遇到歧义，优先参照 Step 3 确认的"我的理解"（中文）作为权威依据
- 执行完成后正常回复，无需再提示英文学习内容

---

## 示例

### 示例 1：英文输入，含语义敏感词

**用户输入：**
```
/learn-english Please delete the backup files after the deployment is complete
```

**skill 输出：**
```
我的理解：在部署完成之后，删除备份文件。
（时序：先完成部署，再删除——请确认顺序正确）

对应英文：Please delete the backup files after the deployment is complete.
纠错说明：表达正确，无需修改。
```

**AskUserQuestion：** "我的理解是否正确？"
→ 用户选择"理解正确，执行任务"→ 执行删除备份文件操作

---

### 示例 2：纯中文输入

**用户输入：**
```
/learn-english 帮我在用户注册完成之前，显示一个引导页面
```

**skill 输出：**
```
我的理解：在用户完成注册之前（注册流程进行中），显示引导页面。
（时序：引导页面出现在注册完成前——请确认是注册过程中显示，还是注册后才显示）

对应英文：Please show a guide page before the user completes registration.
纠错说明：（中文输入，无需纠错）
```

**AskUserQuestion：** "我的理解是否正确？"
→ 用户选择"不对，我补充一下"，补充"是注册完成后才显示"
→ 回到 Step 2，重新解析 → 更新"我的理解"为"注册完成之后显示引导页面"

---

### 示例 3：中英混写输入

**用户输入：**
```
/learn-english 帮我 remove all cache files except the user session data
```

**skill 输出：**
```
我的理解：删除所有缓存文件，但保留用户 session 数据（不删除 session）。
（except 含义：排除 user session data，其余缓存全部删除——请确认）

对应英文：Please remove all cache files except the user session data.
纠错说明：表达正确，无需修改。中文部分"帮我"已合并到英文指令中。
```

**AskUserQuestion：** "我的理解是否正确？"
→ 用户选择"理解正确，执行任务"→ 执行清理缓存操作
