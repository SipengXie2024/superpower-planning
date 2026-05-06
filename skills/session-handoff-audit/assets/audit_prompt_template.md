我需要你独立审计 `{{PROJECT_NAME}}` 项目的实际实现状态，不要信任任何历史会话总结、memory 文件或 progress 日志——它们可能已过期或含幻觉，仅作线索参考。所有结论必须来自当前源码。

## 上下文

- **仓库根目录**：`{{REPO_PATH}}`
- **当前分支**：`{{BRANCH_NAME}}`
- **设计规范**：`{{DESIGN_SPEC_PATH}}`
{{DESIGN_CHAPTERS_HINT}}
- **历史 memory / findings（仅作线索）**：
{{MEMORY_PATHS}}
- **审计范围**：{{AUDIT_SCOPE}}

## 审计目标

并行派遣 {{SUBAGENT_COUNT}} 个 `Explore` 子 agent（**单条 message 内全部发出，不要串行**），独立核实三个维度，最后整合一份结构化报告。

### 维度 1：实现盘点（What's actually there）

对照设计规范中每个模块/Layer/组件，用 Grep/Read/LSP 核实：
- 类型/函数/方法**是否存在**（给出 `file:line`）
- **是否被生产路径调用**（而不是仅在 test/bench/stub 中出现）—— grep 调用点，说明触发条件
- 若 spec 提到"应由 X 调用 Y"，确认 X 确实调用 Y；否则标为 **NOT-WIRED**

### 维度 2：参数/默认值核对

对 spec 列出的每个参数（常量、配置字段、环境变量默认值），grep 实际代码定义，报告：
- `MATCH`：spec 值 == 代码值
- `MISMATCH`：列出两个值
- `MISSING`：spec 提到但代码里找不到

### 维度 3：Drift 检测

不仅找"缺了什么"，还要找：
- **语义改动**：优先级、策略、时机等和 spec 不一致（例：spec 说 drop-newest，代码里是 drop-oldest）
- **多出的东西**：spec 未提及但代码里有的 env var、常量、代码路径
- **未使用的字段**：spec 设计有意义，代码里写了但没 reader

## 执行约束

- **并行派遣**：所有 Explore 子 agent 在同一条 message 里以多个工具调用发出。不要等第一个返回再派第二个。
- **证据先行**：每条结论必须带 `file_path:line_number`。无行号的断言视为猜测，reviewer 会拒绝。
- **不信任历史**：memory/findings/progress 里的断言一律要在当前代码中复核。老 finding 和现状冲突时以代码为准。
- **主动标"不确定"**：需要运行时观察才能验证的（例："这个 hook 在生产路径真被调用"），标为 **UNCERTAIN**，不要猜。
- **不做实现、不做规划**：这是只读审计。不要编辑文件、不要跑 `cargo fix`、不要建议修改方案（只列事实）。

## 任务拆分建议

把审计按模块分给各子 agent。下面是示例拆法（按项目实际结构调整）：

{{TASK_SPLIT_SUGGESTIONS}}

## 输出格式

整合为一份 markdown 报告，严格按此结构：

### 1. 实现矩阵

| 模块/组件 | Spec 要求 | 代码位置 | 生产路径接入 | 备注 |
|---|---|---|---|---|
| ... | ... | `file:line` | PASS / NOT-WIRED / PARTIAL | ... |

### 2. 参数矩阵

| 参数 | Spec 默认 | 代码默认 | 验证位置 | 状态 |
|---|---|---|---|---|
| ... | ... | ... | `file:line` | MATCH / MISMATCH / MISSING |

### 3. Drift 清单

按严重度排序（Critical / Important / Minor）。每条：
- **类型**：缺失 / 语义改动 / 额外内容 / 未使用
- **位置**：`file:line` 或 spec 章节
- **描述**：一句话说清 spec 期望 vs 代码实际
- **影响**：为什么这是问题

### 4. 测试覆盖

列出每个主要模块对应的测试文件。如果有 end-to-end 验证 binary（bench、集成测试），列出其路径和最近一次通过状态。

### 5. 剩余工作建议

基于以上证据，按"生产化路径优先级"列出下一步。每条带出处（哪条 drift 或哪个 NOT-WIRED 条目促成）。

### 6. 不确定疑点

明确列出无法仅靠读代码验证的事项，建议下一步如何确认（加日志 / 跑 e2e / 问用户）。

## 开始执行

现在开始：先 Read 设计规范的索引文件建立整体认知，然后派遣并行子 agent。预计总耗时 10-15 分钟。
