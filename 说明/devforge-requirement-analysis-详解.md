# DevForge Requirement Analysis 深度解析

> 本文档基于 DevForge SDLC Skill Chain v1.4 的 `devforge-requirement-analysis` 技能定义（`SKILL.md`）进行深度分析。

---

## 一、整体流程概览（10个步骤）

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  Step 1: 方法论对齐（Methodology Alignment）                                    │
│       ↓                                                                     │
│  Step 2: 状态初始化 + 项目目录初始化（State & Directory Init）                   │
│       ↓                                                                     │
│  Step 3: 上下文收集（Context Gathering）—— 单问题单问                            │
│       ↓                                                                     │
│  Step 3a: 网络调研（Web Research）—— 条件触发                                    │
│       ↓                                                                     │
│  Step 4: 跨模块交互点识别（Cross-module Interaction Mapping）                   │
│       ↓                                                                     │
│  Step 5: PRD 生成（PRD Generation）                                             │
│       ↓                                                                     │
│  Step 6: 需求追溯矩阵生成（RTM Generation）                                      │
│       ↓                                                                     │
│  Step 7: 决策日志整理（Decision Log Consolidation）                              │
│       ↓                                                                     │
│  Step 8: 自验证（Self-validation: PRD Completeness）                            │
│       ↓                                                                     │
│  Step 9: 状态更新（State Update）                                               │
│       ↓                                                                     │
│  Step 10: 人机关卡（Human Gate）—— HARD-GATE                                   │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 二、每一步详解与调用的工具

### Step 1: 方法论对齐（Methodology Alignment）

#### 做什么？
向用户说明两个核心方法论框架：

1. **四维度推导法**：Why（为什么要做）→ What（做什么）→ How（怎么做）→ Modules（拆成哪些模块）
2. **PRD 五大质量标准**：
   - 清晰逻辑（Clear logic）
   - 闭环定义（Closed loop）
   - 可视化（Visuals）
   - 可追溯性（Traceability）
   - 优先级划分（Prioritization）

同时，主动暴露边缘场景问题：
- 恶意流量怎么处理？
- 第三方服务宕机怎么办？
- 数据一致性如何保障？

#### 调用的工具
- **无外部工具调用**，纯 AI 与用户对话交互。

#### 为什么这样设计？
- **建立共同语言**：让非技术背景的用户理解后续会产出什么、为什么需要这些信息，降低认知门槛。
- **设定期望边界**：在正式开始前就把潜在的边界问题抛出来，避免后期返工。
- **VCMF 的 "Design as Contract"**：PRD 是整个链条的第一份契约，必须先让用户理解契约精神——需求一旦锁定，后续阶段以此为基准。

---

### Step 2: 状态初始化 + 项目目录初始化

#### 做什么？
1. **读取已有状态**：尝试读取 `PROJECT_SCAFFOLD/docs/architecture/system/STATE.md`
2. **新项目初始化流程**：
   - 询问项目名称（如 `my-todo-app`）
   - 确定项目根目录（默认 `./{project-name}/`）
   - 确认路径后，创建完整的目录结构
   - 初始化 `STATE.md`，写入 **Immutable Goal（不可变目标）**
3. **已有项目处理**：如果 `STATE.md` 存在且阶段已经是 `requirement_analysis_completed` 或更晚，询问用户是覆盖还是基于现有产物继续

#### 创建的目录结构

```
{project-root}/
├── skill/
│   └── artifacts/                    # 执行期临时工作区
│       ├── STATE.md                  # 状态文件
│       ├── PRD.md                    # 产品需求文档
│       ├── DECISION_LOG.md           # 决策日志
│       ├── RTM.md                    # 需求追溯矩阵
│       ├── ARCHITECTURE.md           # 架构设计文档
│       ├── INTERFACE_CONTRACT.md     # 接口契约
│       ├── architecture.xml          # 架构 XML（权威源）
│       ├── VALIDATION_REPORT.md      # 验证报告
│       ├── VALIDATION_DELTA.md       # 验证增量
│       ├── DESIGN_REVIEW.md          # 设计评审
│       ├── SECURITY_AUDIT_REPORT.md  # 安全审计报告
│       ├── ITERATION_PRD.md          # 迭代 PRD
│       ├── ITERATION_PLAN.md         # 迭代计划
│       └── PROJECT_SCAFFOLD/         # 最终可运行项目代码（占位）
└── docs/
    └── architecture/
        ├── system/                   # 系统级架构文档（最终权威位置）
        ├── modules/                  # 模块级架构文档
        ├── validation/               # 验证报告和测试报告
        ├── diagrams/                 # Mermaid 架构图
        └── INDEX.md                  # 统一架构文档索引
```

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Read` | 读取已有的 `STATE.md`，判断项目状态 |
| `AskUserQuestion` | 询问项目名称、确认目录路径 |
| `Bash` / `PowerShell` | 创建多层目录结构 |
| `Write` | 创建初始 `STATE.md`，写入 **Immutable Goal** 和 **Project Metadata** |

#### 为什么这样设计？
- **Immutable Goal 永不覆盖**：这是整个项目最根本的锚点。无论后续经过多少轮迭代，原始产品构想、核心成功指标、范围边界都保持不变，防止需求漂移。
- **`skill/artifacts/` 作为临时工作区**：执行过程中产生的中间产物先放在这里，最终权威文件才会写入 `docs/architecture/system/`。这种分层避免污染最终交付物。
- **`PROJECT_SCAFFOLD` 占位**：为 Step 4（project-scaffolding）阶段预留的代码目录，体现"设计先行、实现后置"的原则。
- **前置条件检查**：如果发现已有 `STATE.md` 且阶段更晚，不擅自覆盖，而是询问用户——尊重人类决策权。

---

### Step 3: 上下文收集（Context Gathering）

#### 做什么？
遵循 **Elicitation Principles（诱导原则）**，通过对话逐步收集需求信息。

#### 四大诱导原则

| 原则 | 含义 | 示例 |
|------|------|------|
| **Codebase-first** | 能读代码/已有文档回答的，绝不问用户 | 项目已有 CONTEXT.md，直接读 |
| **One question at a time** | 一次只问一个问题，并附带推荐答案 | "目标用户是 B 端还是 C 端？我推测是 B 端企业用户，对吗？" |
| **Sharpen language inline** | 用户用模糊词汇时，立即提出精确定义 | 用户说"响应要快"→"您指的是 API P99 延迟 < 200ms 吗？" |
| **Capture decisions immediately** | 有真实权衡时，立即写入 DECISION_LOG | 决定不支持离线模式 → 立刻记录 |

#### 必须覆盖的内容
- 用户画像（User Personas）
- 核心痛点（Pain Points）
- 业务价值（Business Value）
- 范围边界（Scope Boundaries）

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Read` | 读取已有 PRD、CONTEXT.md、代码库 |
| `AskUserQuestion` | 逐个问题询问用户，一次一个 |

#### 为什么这样设计？
- **"One question at a time" 是核心设计**：
  - 避免一次性抛给用户 20 个问题，导致信息过载和回答敷衍
  - 推荐答案机制（"我推测...对吗？"）大幅降低用户的回答成本，只需确认或微调
  - 支持条件分支：一个答案可能引出新的相关问题，固定问卷做不到这种动态分支
- **Sharpen inline 对抗需求漂移**：
  - 据统计，80% 的后期返工源于前期术语不统一
  - "用户"vs"客户"、"订单"vs"交易"、"快"vs"P99<200ms"——这些差异在编码阶段会导致完全不同的实现
- **立即捕获决策**：
  - 人的短期记忆不可靠，决策上下文 10 分钟后就会丢失
  - 不要在 Step 7 才批量整理，那时已经记不清当时的权衡了

---

### Step 3a: 网络调研（Web Research，条件触发）

#### 触发条件（满足任一即触发）
- 用户的产品领域属于新兴技术或垂直行业，训练数据覆盖不足
- 用户明确要求竞品分析、行业标准、合规要求

#### 搜索范围（严格受限）

| 类型 | 示例查询 |
|------|---------|
| 行业背景 | `{domain} industry standards 2025` |
| 竞品参考 | `{product type} competitors features comparison` |
| 术语标准化 | `{ambiguous term} definition standard` |
| 合规要求 | `{domain} compliance requirements GDPR/SOC2` |

**禁止搜索**：技术选型（数据库、框架、云服务）、具体代码实现

#### 结果处理
搜索结果不直接塞进 PRD，而是：
1. 提取结论性内容
2. 写入 `DECISION_LOG.md`，格式如下：

```
[YYYY-MM-DD] [RESEARCH-{id}]: Web search on "{query}"
- Source: {URL}
- Key finding: {1-sentence summary}
- Relevance to PRD: {对应 PRD 哪个章节}
```

3. PRD 中只引用结论，不堆砌原始数据

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `WebSearch` | 执行搜索查询 |
| `WebFetch` | 获取具体页面的详细内容 |
| `Write` | 将研究结果追加到 `DECISION_LOG.md` |

#### 为什么这样设计？
- **条件触发，不是每次都做**：避免不必要的网络延迟和上下文膨胀，大部分常见产品（如 Todo App、博客系统）不需要调研。
- **严格限制搜索范围**：
  - 需求阶段的任务是理解"问题域"，不是解决"方案域"
  - "用 MySQL 还是 Postgres" 是架构阶段的事，需求阶段搜索这个属于越界
- **结论进 DECISION_LOG**：
  - 确保研究结论有迹可循，避免"AI 说竞品有 X 功能"但无法验证来源
  - PRD 保持简洁，只引用精炼后的结论
- **24h 缓存规则**：短期内重复查询相同领域时复用结果，减少 API 调用和延迟。

---

### Step 4: 跨模块交互点识别（Cross-module Interaction Mapping）

#### 做什么？
基于已收集的上下文，识别所有跨模块或跨系统的交互点，在 PRD 中专门设立一节记录。

例如：
- 用户服务 ↔ 订单服务
- 支付模块 ↔ 第三方支付网关（Stripe/Alipay）
- 通知服务 ↔ 邮件/SMS 提供商
- 前端 ↔ BFF（Backend for Frontend）

#### 为什么这样设计？
- **VCMF 的 "Interface as Boundary"**：需求阶段就要识别系统边界，而不是等到架构设计时才发现"哦，原来还需要集成支付网关"。
- **提前暴露集成复杂度**：第三方 API、消息队列、外部存储等依赖必须在 PRD 中显式列出，因为它们直接影响项目排期和风险评估。
- **为 RTM 和架构设计铺垫**：这些交互点后续要映射到架构模块和组件，提前识别可以让架构设计更顺畅。

---

### Step 5: PRD 生成（PRD Generation）

#### 做什么？
生成结构化 PRD，包含 **9 个必需章节**：

| 章节 | 内容说明 | VCMF 对应 |
|------|---------|-----------|
| **Project Background** | 项目背景、目标、成功指标（Why） | Design as Contract |
| **Target User Personas** | 用户画像和使用场景 | Reality as Baseline |
| **Terminology** | 规范化术语定义（Step 3 中解决的歧义） | Design as Contract |
| **User Stories** | 用户故事 + 验收标准（Given-When-Then） | Reality as Baseline |
| **Functional Requirements** | 功能需求，P0 / P1 / P2 分级 | Prioritization |
| **Non-Functional Requirements** | 性能、安全、合规要求 | Reality as Baseline |
| **Cross-Module Interactions** | Step 4 识别的所有交互点 | Interface as Boundary |
| **Main Process Flow** | 主业务流程 | Clear logic |
| **Fallback Strategies** | 异常路径和降级策略 | Closed loop |

#### 关键约束
- **PRD 只描述"用户感知和接受什么"**
- **不指定实现选择**：不出现数据库选型（MySQL/MongoDB）、框架选择（React/Vue）、缓存策略（Redis/Memcached）、部署拓扑（Docker/K8s）——那些属于 `architecture-design` 阶段

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Write` | 将 PRD 写入 `PROJECT_SCAFFOLD/docs/architecture/system/PRD.md` |

#### 为什么这样设计？
- **关注点分离（Separation of Concerns）**：
  - 需求回答"做什么"（What）
  - 架构回答"怎么做"（How）
  - 混在一起会导致需求文档变成技术方案，失去与业务方的沟通价值
- **P0/P1/P2 分级**：
  - P0 = 必须有的 MVP 功能
  - P1 = 重要但可延期
  - P2 = 锦上添花
  - 这种分级让团队在资源紧张时知道该砍什么
- **验收标准必须可观察和可测试**：
  - 对应 VCMF "Reality as Baseline"
  - "系统应该快" → 不可测试
  - "API P99 延迟 < 200ms" → 可测试

---

### Step 6: RTM（需求追溯矩阵）生成

#### 做什么？
生成 `RTM.md`，建立从"需求"到"实现"再到"测试"的完整追溯链。

#### 结构

| Requirement ID | User Story | Acceptance Criteria | Architecture Module | Component | Test Case ID | Status |
|----------------|-----------|---------------------|---------------------|-----------|--------------|--------|
| REQ-001 | 作为用户，我可以登录 | 输入正确密码后跳转到首页 | AuthModule | LoginService | TC-001 | pending |

#### 规则
- 每个 **P0/P1** 需求必须至少映射到一个 Module 和 Component
- 所有条目初始状态为 `pending`
- 后续技能逐步填充：
  - `architecture-design` → 填充 **Architecture Module** 列
  - `module-design` → 填充 **Component** 列
  - `project-scaffolding` → 填充 **Test Case ID** 列
  - `architecture-validation` → 更新 **Status** 为 `verified`

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Write` | 将 RTM 写入 `PROJECT_SCAFFOLD/docs/architecture/system/RTM.md` |

#### 为什么这样设计？
- **可追溯性（Traceability）是 PRD 五大质量标准之一**：
  - 当产品经理说"这个需求变了"时，开发团队能快速定位受影响的所有模块、组件和测试用例
- **矩阵式追踪**：
  - 正向追踪：需求 → 哪些模块实现了它 → 哪些测试验证了它
  - 反向追踪：测试失败 → 对应哪个组件 → 满足哪个需求
- **P0/P1 强制映射**：
  - 确保核心需求不会被遗漏在架构设计之外
  - P2 可以不映射，因为 P2 可能会延迟或取消

---

### Step 7: 决策日志整理（Decision Log Consolidation）

#### 做什么？
整理 `DECISION_LOG.md`，**只保留**满足以下**任一条件**的决策：

1. **难以逆转（Hard to reverse）**：改变决策需要大量返工（如重画 P0 范围、更换目标用户群体）
2. **缺少上下文会让人困惑（Surprising without context）**：未来读者会问"为什么这样设计？"
3. **有真实权衡（Backed by a real trade-off）**：存在真正的替代方案，拒绝理由很重要

**删除**不满足任何条件的条目——那些属于 PRD 正文或聊天记录，不需要进决策日志。

#### 条目格式
```markdown
## [YYYY-MM-DD] DEC-{id}: {决策标题}

**决策**：{做了什么选择}

**理由**：{为什么这样选}

**拒绝的替代方案**：
- {方案 A}：{为什么放弃}
- {方案 B}：{为什么放弃}
```

#### 为什么这样设计？
- **防止"决策考古"**：6 个月后，团队里没人记得当初为什么不用方案 B。DECISION_LOG 就是时间胶囊。
- **过滤噪音**：
  - 不是所有对话都值得记录
  - "午餐吃什么"级别的决策不需要进日志
  - 只保留有**结构性影响**的决策
- **VCMF 的 "State as Responsibility"**：
  - 明确谁拥有每个业务状态
  - 决策责任也要明确——这个决策是谁做的、基于什么信息、放弃了什么

---

### Step 8: 自验证（Self-validation: PRD Completeness）

#### 做什么？
执行 **4 项自动检查**：

| 检查 ID | 检查项 | 目的 |
|---------|--------|------|
| PRD-SEC-COMPLETE | **Section completeness** | PRD 是否包含全部 9 个必需章节 |
| PRD-AC-OBSERVABLE | **Acceptance criteria observability** | 扫描并标记"快"、"用户友好"、"无缝"等不可量化形容词 |
| PRD-RTM-COVERAGE | **Traceability coverage** | 每个 P0/P1 需求在 RTM 中都有对应行 |
| PRD-CROSS-MODULE | **Cross-module interaction consistency** | 每个交互点至少被一个用户故事或功能需求引用 |

**如果任何检查失败**，修复 PRD 或 RTM 后再继续。

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Read` | 读取 PRD.md 和 RTM.md 进行内容检查 |
| `Edit` / `Write` | 修复发现的问题 |

#### 为什么这样设计？
- **不依赖人类检查的自觉性**：AI 自动执行检查，确保质量底线，不会因为"觉得差不多"就放行。
- **在流程中内嵌质量关卡**：而不是等到最后才发现缺东西，那时修复成本呈指数增长。
- **引用 validation-engine.md 公共检查库**：保持跨技能检查标准一致，所有技能使用同一套检查框架。
- **Acceptance criteria observability 是最关键的检查**：
  - 一个包含"系统应该响应很快"的验收标准等于没有验收标准
  - 必须在流程中就强制量化

---

### Step 9: 状态更新（State Update）

#### 做什么？
更新 `STATE.md`（16 节完整状态文件）：

1. **写入 Immutable Goal**（如尚未写入）：原始产品构想 + 成功指标 + 范围边界
2. **Completed Steps 追加**：
   ```
   [YYYY-MM-DD HH:MM] devforge-requirement-analysis: Locked P0/P1/P2 scope. Key decisions: [...]
   ```
3. **设置 DIVE 状态**：
   - `Design: in_progress`
   - `Implement: pending`
   - `Verify: pending`
   - `Evolve: pending`
4. **更新 Artifact Index**：记录 PRD、RTM、DECISION_LOG 的路径和摘要
5. **记录 Project Metadata**：`project_root`, `project_name`, `created_at`

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Read` | 读取当前 STATE.md |
| `Write` / `Edit` | 更新 STATE.md 各节内容 |

#### 为什么这样设计？
- **STATE.md 是跨会话唯一的真相源（Single Source of Truth）**：
  - 用户可以随时中断会话
  - 新会话只需读取 STATE.md 就能完整恢复上下文
- **Append-only 的 Completed Steps**：
  - 历史不可篡改，防止状态回滚时丢失信息
  - 审计追踪：谁（哪个技能）在什么时候做了什么
- **DIVE 状态机**：
  - 明确当前处于 Design-Implement-Verify-Evolve 的哪个阶段
  - 让后续技能知道该做什么、不该做什么

---

### Step 10: 人机关卡（Human Gate）

#### 做什么？
1. 展示 PRD 摘要（3-5 个 bullet 点）
2. 告知："本次 PRD 基于 {N} 条外部研究结论，详细引用见 DECISION_LOG.md"
3. 列出所有可用命令
4. **等待用户回复 `[APPROVE]` 或明确继续指令**

#### 可用命令

| 命令 | 作用 |
|------|------|
| `[APPROVE]` | 批准并继续（进入 `architecture-design` 阶段） |
| `[PAUSE]` | 暂停当前阶段，保留上下文 |
| `[ROLLBACK {step_id}]` | 回滚到指定步骤重新执行（如 `[ROLLBACK step3]`） |
| `[EDIT {file_path}]` | 手动编辑文件后让 AI 继续（如 `[EDIT PRD.md]`） |
| `[INJECT {context}]` | 补充额外上下文约束（如 `[INJECT 增加移动端支持]`） |
| `[EXPLAIN {TraceID}]` | 展开解释某个决策/错误的推理链 |

#### 关键约束：HARD-GATE
```markdown
<HARD-GATE>
Do NOT proceed to architecture-design, write any code, or scaffold any project 
until the user replies [APPROVE] or explicitly asks to continue.
</HARD-GATE>
```

#### 为什么这样设计？
- **硬关卡（HARD-GATE）防止自动越界**：
  - AI 不能在没有人类确认的情况下自动进入下一阶段
  - 防止"AI 觉得自己做好了就继续"的幻觉行为
- **命令标准化**：
  - 所有 DevForge 技能使用同一套命令语法
  - 用户学会一次，全链条通用
- **`[INJECT]` 支持中途补充需求**：
  - 不需要回滚到 Step 3
  - 直接在关卡处注入新约束，AI 应用修改后重新呈现
- **`[EXPLAIN]` 支持可解释性**：
  - 用户可以追问任何决策的推理链
  - 对应 XAI（可解释 AI）原则，不让 AI 成为黑盒
- **自然语言反馈也被接受**：
  - 用户不用记命令，直接说"这里需要修改"
  - AI 分析反馈、应用修改、重新呈现关卡

---

## 三、核心输出产物清单

| 产物 | 路径 | 作用 | 下游消费者 |
|------|------|------|-----------|
| **PRD.md** | `PROJECT_SCAFFOLD/docs/architecture/system/PRD.md` | 产品需求文档，整个链条的输入基准 | `architecture-design`, `design-review`, `module-design` |
| **RTM.md** | `PROJECT_SCAFFOLD/docs/architecture/system/RTM.md` | 需求追溯矩阵，需求↔架构↔测试的映射 | `architecture-design`（填 Module）、`module-design`（填 Component）、`test-execution`（填 Test Case） |
| **DECISION_LOG.md** | `PROJECT_SCAFFOLD/docs/architecture/system/DECISION_LOG.md` | 关键决策记录，防止知识流失 | 所有后续技能（防止重复争论） |
| **STATE.md** | `PROJECT_SCAFFOLD/docs/architecture/system/STATE.md` | 跨会话状态，16 节完整项目状态 | 所有技能（会话恢复） |

---

## 四、流程设计哲学深度解析

### 1. 为什么采用"单问题单问"模式？

| 对比维度 | 批量问卷 | 单问题单问 |
|---------|---------|-----------|
| 认知负荷 | 高（20 个问题同时抛出） | 低（一次只关注一个） |
| 回答质量 | 低（用户敷衍） | 高（推荐答案降低门槛） |
| 条件分支 | 不支持（固定问卷） | 支持（动态调整下一题） |
| 上下文保持 | 差（用户忘了前面答了什么） | 好（AI 记住整个对话链） |

**核心洞察**：用户不是产品经理，面对一份 50 题的问卷会选择放弃或胡乱填写。通过推荐答案（"我推测...对吗？"），用户只需确认或微调，回答成本从"创作"降为"选择"。

### 2. 为什么 PRD 不能包含技术选型？

这是**关注点分离（Separation of Concerns）**的经典应用：

| 阶段 | 问题域 | 典型内容 |
|------|--------|---------|
| **Requirement Analysis** | What（做什么） | 用户故事、功能需求、验收标准 |
| **Architecture Design** | How（怎么做） | 数据库选型、框架选择、部署拓扑 |
| **Module Design** | Who（谁来做） | 组件职责、接口签名、文件路径 |

如果在需求阶段就讨论"用 MySQL 还是 Postgres"：
- 业务方（PRD 的主要读者）不关心也不理解
- 技术选择会被过早锁定，而此时的需求理解还不完整
- PRD 变成了技术方案，失去了与业务沟通的价值

### 3. 为什么需要 RTM？

RTM（Requirement Traceability Matrix）解决了软件工程中最头痛的问题之一：**变更影响分析**。

**场景**：产品经理说"登录流程要加上双因素认证"

**没有 RTM**：
- 开发团队："不知道会影响哪些模块，可能全都要改"
- 测试团队："不知道要补哪些测试"
- 结果：要么过度修改，要么遗漏影响

**有 RTM**：
- 一查：REQ-001（登录）→ AuthModule → LoginService, TokenService
- 测试：TC-001（登录成功）、TC-002（登录失败）
- 结果：精确知道改哪里、测哪里

此外，RTM 在**合规审计**（医疗、金融、航空）中是强制要求。

### 4. 为什么决策要"立即记录"？

**认知科学视角**：
- 人的工作记忆只能保持 4±1 个信息块，持续约 30 秒
- 一个技术权衡（如"单体 vs 微服务"）涉及 5-10 个因素
- 10 分钟后，决策者和 AI 都会忘记 50% 的推理细节

**工程管理视角**：
- 新成员加入时，通过 DECISION_LOG 可以快速理解"为什么系统长这样"
- 防止"重新发明轮子"：同样的技术选型不需要每轮迭代都重新辩论
- 审计追踪：当系统出问题时，可以追溯到当初的决策依据

### 5. 为什么是"人机关卡"而不是自动流转？

**AI 的局限性**：
- LLM 会产生"幻觉"——可能误解了用户的意图但自信满满地继续
- LLM 没有"业务直觉"——不知道某个需求对公司的战略意义
- LLM 不能承担责任——出问题时问责的是人类

**关卡设计的价值**：
- **防止幻觉产物**：强制停顿让用户有机会发现 AI 的误解
- **尊重人类决策权**：AI 辅助但不替代人类判断
- **支持迭代修正**：用户可以在关卡处 `[EDIT]` 或 `[INJECT]`，不需要从头开始
- **责任边界清晰**：人类在 `[APPROVE]` 时刻承担了继续的责任

---

## 五、VCMF 五原则在 Requirement Analysis 中的体现

| VCMF 原则 | 在 Requirement Analysis 中的体现 |
|-----------|--------------------------------|
| **Design as Contract** | PRD 就是第一份契约；Immutable Goal 永不覆盖；P0/P1/P2 分级锁定范围 |
| **Interface as Boundary** | Step 4 识别所有跨模块交互点；PRD 专设 Cross-Module Interactions 章节 |
| **Reality as Baseline** | 验收标准必须可观察和可测试；禁止"快"、"用户友好"等模糊形容词 |
| **State as Responsibility** | 用户故事中明确每个业务状态的拥有者；DECISION_LOG 记录决策责任 |
| **XML as Authority** | PRD 引用 XML schema 位置（`architecture.xml` 将在架构阶段生成） |

---

## 六、总结

`devforge-requirement-analysis` 是整个 DevForge 链条的**起点和基石**。它的设计体现了以下核心理念：

1. **慢就是快**：在需求阶段多花 30 分钟澄清术语和边界，可以避免架构阶段 3 天的返工
2. **人类是最终决策者**：所有产出物都经过人机关卡确认，AI 不擅自越界
3. **可追溯是一切的基础**：从 PRD → RTM → Architecture → Module → Test，每一步都有迹可循
4. **上下文是连续的**：通过 STATE.md 和 DECISION_LOG，实现跨会话、跨人员的知识接力

---

> 生成日期：2026-05-12
> 基于：DevForge SDLC Skill Chain v1.4
