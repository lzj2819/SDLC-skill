# DevForge Iteration Planning 深度解析

> 本文档基于 DevForge SDLC Skill Chain v1.4 的 `devforge-iteration-planning` 技能定义（`SKILL.md`）进行深度分析。
>
> **定位**：Stage 7，属于 DIVE 工作流的 **Evolve（演进）** 阶段。
> **核心目标**：在不推翻已有架构的前提下，将新增需求增量式地融入现有系统。
> **关键约束**：现有框架保持不变，只允许新增和定向修改；breaking changes 必须重新走验证流程。

---

## 一、整体流程概览（12个步骤）

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  Step 1: 加载完整基线（Load Full Baseline）                                   │
│       ↓                                                                     │
│  Step 2: 范围验证（Scope Validation）                                         │
│       ↓                                                                     │
│  Step 3: 影响分析（Impact Analysis）                                          │
│       ↓                                                                     │
│  Step 4: 增量 PRD 编写（Incremental PRD）                                     │
│       ↓                                                                     │
│  Step 5: 增量架构设计（Incremental Architecture Design）                       │
│       ↓                                                                     │
│  Step 6: XML 同步（XML Synchronization）                                      │
│       ↓                                                                     │
│  Step 7: 接口版本化（Interface Versioning）                                   │
│       ↓                                                                     │
│  Step 8: 迭代计划生成（Iteration Plan Generation）                             │
│       ↓                                                                     │
│  Step 9: 后迭代验证提示（Post-Iteration Validation Prompt）                    │
│       ↓                                                                     │
│  Step 10: 自验证（Self-Validation）                                           │
│       ↓                                                                     │
│  Step 11: 状态更新（State Update）                                            │
│       ↓                                                                     │
│  Step 12: 人机关卡（Human Gate）← HARD-GATE                                  │
│       ↓                                                                     │
│  [APPROVE] → 按 ITERATION_PLAN.md 逐个模块实施                                │
│       ↓                                                                     │
│  verification_gate=true → [VALIDATE] → devforge-architecture-validation      │
│       ↓                                                                     │
│  devforge-design-review → devforge-module-design / devforge-project-scaffolding│
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 二、输入来源（上游产物 + 用户新需求）

| 输入文件 | 来源阶段 | 在 Iteration Planning 中的用途 |
|---------|---------|---------------------------|
| `PRD.md` | requirement-analysis | 原始需求基线，用于判断新需求是否在原始范围内 |
| `architecture.xml` | architecture-design | 系统级架构基线，分析影响范围的起点 |
| `INTERFACE_CONTRACT.md` | architecture-design | 现有 I/O 契约基线，判断接口变更类型 |
| `DECISION_LOG.md` | architecture-design | 已有决策链，确保迭代不推翻核心设计决策 |
| `STATE.md` | 全链路维护 | 模块注册表（Module Registry）、迭代历史、不可变目标边界 |
| `module-prd.md`（各模块） | module-design | 模块级需求基线，分析模块内部影响 |
| `DESIGN_REVIEW.md` | design-review | 已知设计问题，判断是否与新增需求产生交互 |
| **用户的新需求描述** | 用户输入 | 本次迭代的核心输入，驱动整个分析流程 |

**关键洞察**：Iteration Planning 是所有技能中**读取输入文件最多**的阶段之一（8+ 个文件），因为它必须同时理解"现有系统是什么"和"新需求要什么"，才能在两者之间建立增量桥梁。

---

## 三、每一步详解与调用的工具

### Step 1: 加载完整基线（Load Full Baseline）

#### 做什么？
1. 读取系统级基线文件：`PRD.md`、`architecture.xml`、`INTERFACE_CONTRACT.md`、`DECISION_LOG.md`、`STATE.md`
2. 读取模块级基线文件：所有已设计模块的 `module-prd.md`
3. 读取验证历史：`DESIGN_REVIEW.md`（了解已知问题）
4. 收集用户的新需求描述
5. **迭代范围预分析**：对照 Module Registry，识别哪些模块会受影响
   - 若受影响模块的 status 为 `pending`（尚未完成详细设计），则**停止并提示用户先完成 module-design**

#### 调用什么工具？
| 工具类型 | 具体操作 |
|---------|---------|
| `Read` | 读取 8+ 个基线文件 |
| 逻辑分析 | 扫描 Module Registry，匹配模块状态 |
| 前置检查 | 若 phase < `module_design_completed`，拒绝执行 |

#### 为什么要这么做？
- **避免盲目迭代**：如果新增模块尚未设计就进入迭代，会导致架构不完整
- **基线完整性**：必须掌握现有系统的全貌，才能判断"新增"与"现有"的边界
- **Module Registry 作为事实来源**：它记录了每个模块的设计/脚手架状态，是判断能否安全迭代的唯一依据

---

### Step 2: 范围验证（Scope Validation）

#### 做什么？
1. 将新需求与 `STATE.md` 中的 **Immutable Goal（不可变目标）** 进行比对
2. **若新需求超出原始范围边界**：
   - 标记为 **scope escalation（范围升级）**
   - 询问用户：`[A] 扩展范围边界并继续` / `[B] 推迟到未来项目` / `[C] 作为独立子项目处理`
3. **若在范围内**：继续执行

#### 调用什么工具？
| 工具类型 | 具体操作 |
|---------|---------|
| 文本比对 | 将新需求描述与 Immutable Goal 的范围边界进行语义比对 |
| `AskUserQuestion` | 若检测到 scope escalation，向用户展示选项 |

#### 为什么要这么做？
- **防止范围蔓延（Scope Creep）**：迭代最容易犯的错误就是"顺便把这个也做了"，最终偏离原始产品目标
- **Immutable Goal 作为护栏**：它是在项目初期就定义的"不可更改的核心"，任何偏离都必须经过显式的人类决策
- **三元选项设计**：不是简单的"是/否"，而是给用户三种合理的处理路径，体现灵活性

---

### Step 3: 影响分析（Impact Analysis）

#### 做什么？
对每个新需求，分析其对现有架构的影响类型：

| 影响类型 | 含义 | 示例 |
|---------|------|------|
| `add_module` | 需要新增模块 | "增加支付功能" → 新增 PaymentService |
| `modify_module:{id}` | 现有模块需要新能力 | "用户系统增加实名认证" → UserService 新增组件 |
| `extend_interface:{id}` | 现有模块接口需要扩展 | "订单查询增加分页参数" → OrderAPI 新增参数 |
| `modify_coupling` | 跨模块交互关系变化 | "订单完成后自动触发库存扣减" → OrderService 与 InventoryService 耦合变化 |
| `modify_state` | 状态模型变化 | "新增用户偏好设置" → StateModel 新增字段 |
| `no_impact` | 无影响（罕见） | 纯 UI 文案修改 |

然后生成 **Impact Matrix（影响矩阵）**：
```
| Requirement | Affected Module | Impact Type | Severity     |
|-------------|-----------------|-------------|--------------|
| REQ-101     | PaymentService  | add_module  | additive     |
| REQ-102     | UserService     | extend_interface | additive |
| REQ-103     | OrderService    | modify_coupling | breaking  |
```

**Severity 分级**：
- `breaking`：改变现有接口（必须版本化 + 重新验证）
- `additive`：仅新增接口（兼容）
- `internal`：仅模块内部修改（对外无影响）

#### 调用什么工具？
| 工具类型 | 具体操作 |
|---------|---------|
| 架构分析 | 扫描 architecture.xml 的 Module、Coupling、StateModel 节点 |
| 依赖分析 | 追踪新需求到现有模块的依赖链路 |
| 矩阵生成 | 输出结构化的 Impact Matrix |

#### 为什么要这么做？
- **Reality as Baseline（现实为基准）**：必须识别出每一个受影响的模块，不能有任何隐藏依赖
- **Severity 分级是决策基础**：不同级别决定了后续是否需要版本化、是否需要重新验证
- **影响矩阵是迭代计划的基石**：没有它，后续的所有计划都是盲目的

---

### Step 4: 增量 PRD 编写（Incremental PRD）

#### 做什么？
1. 编写 `ITERATION_PRD.md`，**只包含新增/修改的需求**：
   - 对于 additive 需求：编写新的用户故事，附带 `relates_to: US-XXX` 链接到原始 PRD
   - 对于 modified 需求：编写 delta 描述（什么变了、什么没变）
   - 每个用户故事附带验收标准
   - 若 severity 为 `breaking`，明确写出向后兼容性要求
2. **不复制**原始 PRD 中未变更的需求

#### 调用什么工具？
| 工具类型 | 具体操作 |
|---------|---------|
| `Write` | 创建 `PROJECT_SCAFFOLD/docs/architecture/system/ITERATION_PRD.md` |
| 差分分析 | 对比新旧需求，提取 delta |

#### 为什么要这么做？
- **增量纯度原则**：ITERATION_PRD.md 必须是"增量文档"，不是完整 PRD 的副本，否则会导致信息冗余和同步困难
- `relates_to` 链接确保可追溯性：新增需求始终能追溯到原始需求上下文
- breaking changes 的兼容性要求必须显式文档化，否则后续实施时容易忽略

---

### Step 5: 增量架构设计（Incremental Architecture Design）

#### 做什么？
根据 Impact Matrix 中的不同影响类型，执行对应的架构更新：

**对于 `add_module`：**
- 将新增模块视为新的 bounded context
- 设计模块接口、耦合关系、状态归属
- 在 `architecture.xml` 中追加新的 `Module` 节点
- 生成模块级 XML 模板（遵循与 architecture-design 相同的规则）

**对于 `modify_module` / `extend_interface`：**
- 读取现有的 `module-architecture.xml`
- 添加新组件或扩展现有组件接口
- 更新 `module-interface-contract.md` 中的方法列表
- 更新 `component-spec.xml` 模板

**对于 `modify_coupling`：**
- 更新 `architecture.xml` 中的 `Coupling` 节点
- **检查是否引入循环依赖**

**对于 `modify_state`：**
- 更新系统级和各模块的 `StateModel`
- 若现有状态格式变更，编写状态迁移策略

#### 调用什么工具？
| 工具类型 | 具体操作 |
|---------|---------|
| `Read` | 读取受影响的 module-architecture.xml、component-spec.xml |
| `Edit` / `Write` | 修改 architecture.xml、module-architecture.xml、component-spec.xml |
| 依赖检查 | 扫描 Coupling 节点，检测循环依赖 |

#### 为什么要这么做？
- **XML as Authority（XML 为权威）**：所有代码层面的变更都必须先有 XML 层面的定义
- **三层 XML 同步**：系统层 → 模块层 → 组件层的变更必须一致传播
- **循环依赖检查**：迭代最容易引入隐藏的循环依赖，因为新增模块时开发者往往只关注局部

---

### Step 6: XML 同步（XML Synchronization）

#### 做什么？
1. 运行 `scripts/xml-sync.py --sync`（或模拟其逻辑）
2. 将变更向下传播：
   - 系统级接口变更 → 模块层 `Constraints` 节点
   - 模块层组件变更 → 组件层 `component-spec.xml` 模板
   - 新增错误码 → 所有相关的 `ErrorCodes` 和 `ErrorHandling` 节点
3. 生成 **Sync Report**，列出所有被修改的文件和具体变更

#### 调用什么工具？
| 工具类型 | 具体操作 |
|---------|---------|
| `Bash` | 执行 `python scripts/xml-sync.py --sync` |
| 或逻辑模拟 | 若脚本不可用，手动执行同步逻辑 |

#### 为什么要这么做？
- **三层 XML 一致性**：系统层、模块层、组件层的变更是手动进行的，容易遗漏同步
- **自动化传播**：人工维护三层 XML 的同步极易出错，脚本化是唯一的可靠方式
- **Sync Report 作为审计线索**：记录"什么变了、为什么变、在哪一层变的"

---

### Step 7: 接口版本化（Interface Versioning）

#### 做什么？
1. **对于 `breaking` severity 的变更：**
   - 递增受影响接口的版本号（如 `v1.0` → `v1.1` 或 `v2.0`）
   - 若适用，记录旧接口的弃用时间线
   - 在 `INTERFACE_CONTRACT.md` 中更新版本历史
2. **对于 `additive` 的变更：**
   - 在现有接口章节追加新方法/错误码
   - 标注 `[ADDED v1.1]`

#### 调用什么工具？
| 工具类型 | 具体操作 |
|---------|---------|
| `Read` | 读取 INTERFACE_CONTRACT.md 中的现有版本信息 |
| `Edit` | 更新版本号、追加版本历史、添加 [ADDED] 标注 |

#### 为什么要这么做？
- **Interface as Boundary（接口为边界）**：接口是模块之间的契约，任何变更都必须显式版本化
- **向后兼容性保障**：breaking changes 若不加版本控制，会导致下游模块在不知情的情况下失效
- `[ADDED vX.Y]` 标注让开发者一眼看出哪些是增量添加的，避免与原始接口混淆

---

### Step 8: 迭代计划生成（Iteration Plan Generation）

#### 做什么？
编写 `ITERATION_PLAN.md`，包含：
1. **Iteration Goal**：一句话概括本次迭代目标
2. **Scope Summary**：明确包含什么、明确排除什么
3. **Affected Module Checklist**：受影响模块清单 + 所需的技能流
   ```
   | Module | Impact Type | Required Skills | Status |
   |--------|-------------|-----------------|--------|
   | UserService | extend_interface | design-review + scaffolding | pending |
   | PaymentService | add_module | requirement-analysis + architecture-design + ... | pending |
   ```
4. **Execution Order**：模块间的依赖执行顺序
5. **Human Gate Points**：计划中的人工审批点
6. **Risk Summary**：breaking changes、向后兼容性担忧
7. **Rollback Criteria**：何时应该中止迭代
8. **verification_gate**：
   ```yaml
   verification_gate:
     required: true  # 若存在 breaking 或 modify_coupling
     skills_to_rerun: [architecture-validation, design-review]
     trigger_condition: "any breaking change or coupling modification"
   ```

#### 调用什么工具？
| 工具类型 | 具体操作 |
|---------|---------|
| `Write` | 创建 `ITERATION_PLAN.md` |
| 依赖排序 | 根据模块间的耦合关系计算拓扑排序 |

#### 为什么要这么做？
- **Execution Order 防止依赖错乱**：若 PaymentService 依赖 UserService 的新接口，必须先完成 UserService
- **verification_gate 是安全网**：breaking changes 必须重新走验证流程，不能偷偷绕过
- **Rollback Criteria 是风险管理**：明确什么情况下应该放弃迭代，防止沉没成本陷阱

---

### Step 9: 后迭代验证提示（Post-Iteration Validation Prompt）

#### 做什么？
1. 检查 `ITERATION_PLAN.md` 中的 `verification_gate.required`
2. 若为 `true`，在迭代脚手架完成后提示用户：
   > "迭代实施涉及架构变更。回复 `[VALIDATE]` 重新运行架构验证，回复 `[SKIP]` 跳过（不推荐）。"
3. 若用户回复 `[VALIDATE]`，触发 `devforge-architecture-validation`

#### 调用什么工具？
| 工具类型 | 具体操作 |
|---------|---------|
| 条件判断 | 读取 verification_gate 配置 |
| 提示输出 | 向用户展示验证选项 |

#### 为什么要这么做？
- **闭环验证**：迭代不是"设计完就完事了"，breaking changes 实施后必须验证仍然满足原始架构约束
- **可选但强烈推荐**：给用户选择权，但明确标记 SKIP 为"不推荐"

---

### Step 10: 自验证（Self-Validation: Iteration Plan Consistency）

#### 做什么？
执行 6 项自动化检查：

| 检查项 | 检查内容 | 失败处理 |
|--------|---------|---------|
| **Impact Matrix 完整性** | 每个 ITERATION_PRD.md 中的需求都必须在 Impact Matrix 中有对应行 | 补充缺失行 |
| **无循环依赖** | 扫描更新后的 architecture.xml Coupling 节点 | 打破循环 |
| **版本化正确性** | 每个 breaking 变更必须有版本号递增；additive 必须有 `[ADDED vX.Y]` | 修复版本标注 |
| **增量 PRD 纯度** | ITERATION_PRD.md 必须只包含新/改需求，不能复制未变更需求 | 删除冗余 |
| **Sync Report 完整性** | Sync Report 必须列出所有被修改的文件 | 补充遗漏 |
| **向后兼容性文档** | 每个 breaking 变更必须有兼容性/迁移策略 | 补充文档 |

#### 调用什么工具？
| 工具类型 | 具体操作 |
|---------|---------|
| 自动化扫描 | 遍历 XML、Markdown 文件执行规则检查 |
| `Read` | 读取 ITERATION_PRD.md、ITERATION_PLAN.md、architecture.xml 等 |

#### 为什么要这么做？
- **自我纠错**：在提交给用户审批前，AI 先自查一遍，减少低级错误
- **6 项检查覆盖迭代核心风险**：遗漏影响、循环依赖、版本混乱、文档冗余、同步缺失、兼容性遗漏

---

### Step 11: 状态更新（State Update）

#### 做什么？
更新 `STATE.md` 的多个章节：

1. **Completed Steps**：追加迭代规划完成记录
   ```
   [YYYY-MM-DD HH:MM] devforge-iteration-planning: Analyzed [N] new requirements. Impact: [X] modules affected. Iteration scope: [summary]
   ```
2. **Current State**：
   - `phase: iteration_planning_completed`
   - `NextAction: iterate`
3. **Iteration History**：追加新迭代条目（日期、范围、受影响模块）
4. **Module Registry**：
   - 新增模块 status = `pending`
   - 更新受影响模块的 status（若发生 breaking 变更，可能从 `verified` 降级为 `implemented`）
5. **Known Pitfalls**：追加迭代特定风险

同时更新 `RTM.md`：
- 追加新需求，status = `pending`
- 对于 breaking 接口变更，将现有需求的 status 从 `verified` 降级为 `implemented`

#### 调用什么工具？
| 工具类型 | 具体操作 |
|---------|---------|
| `Read` | 读取 STATE.md、RTM.md |
| `Edit` | 追加/更新多个章节 |

#### 为什么要这么做？
- **State as Responsibility（状态为责任）**：每次迭代都会改变系统的"状态"，必须准确记录
- **RTM 降级机制**：breaking 变更意味着原有需求的验证假设失效了，必须重新验证
- **NextAction: iterate**：明确告诉系统"我们正处于迭代循环中"

---

### Step 12: 人机关卡（Human Gate）← HARD-GATE

#### 做什么？
1. 向用户展示迭代摘要：
   - 新需求数量
   - Impact Matrix（受影响模块、严重级别）
   - 执行顺序和预计技能流
2. 固定话术：
   > "迭代计划已生成。本次迭代涉及 [N] 个模块，其中 [X] 个新增、[Y] 个修改。**如果本次迭代包含 breaking changes，实施后将自动触发重新验证。**"
3. 列出可用命令：
   - `[APPROVE]` — 按迭代计划逐个模块实施
   - `[MODIFY]` — 调整迭代范围
   - `[REJECT]` — 放弃本次迭代
   - `[PAUSE]` / `[ROLLBACK]` / `[EDIT]` / `[INJECT]` / `[EXPLAIN]`
4. **HARD-GATE**：在迭代计划获批前，不得继续实施迭代项

#### 调用什么工具？
| 工具类型 | 具体操作 |
|---------|---------|
| 文本输出 | 向用户展示迭代摘要和命令列表 |
| 等待输入 | 阻塞直到用户输入有效命令 |

#### 为什么要这么做？
- **HARD-GATE 是安全底线**：迭代涉及对已有系统的修改，未经人类审批就实施风险极高
- **固定话术确保信息透明**：用户必须清楚知道"有多少模块受影响、有没有 breaking changes"
- **breaking changes 自动触发验证**：在审批阶段就告知用户，避免实施后的惊讶

---

## 四、输出产物清单

| 产物文件 | 路径 | 说明 |
|---------|------|------|
| `ITERATION_PRD.md` | `docs/architecture/system/ITERATION_PRD.md` | 增量需求文档，只包含新增/修改的需求 |
| `ITERATION_PLAN.md` | `docs/architecture/system/ITERATION_PLAN.md` | 迭代执行计划，含模块清单、执行顺序、verification_gate |
| 更新后的 `architecture.xml` | `docs/architecture/system/architecture.xml` | 追加新 Module 节点、更新 Coupling/StateModel |
| 更新后的 `INTERFACE_CONTRACT.md` | `docs/architecture/system/INTERFACE_CONTRACT.md` | 版本化接口变更、版本历史 |
| 更新后的模块级 XML | `docs/architecture/modules/{id}/module-architecture.xml` | 受影响模块的架构更新 |
| 更新后的组件级 XML | `docs/architecture/modules/{id}/component-spec.xml` | 受影响组件的规格更新 |
| XML Sync Report | （内嵌于流程或单独文件） | 记录所有三层 XML 的同步变更 |
| 更新后的 `STATE.md` | `docs/architecture/system/STATE.md` | 阶段、模块注册表、迭代历史更新 |
| 更新后的 `RTM.md` | `docs/architecture/system/RTM.md` | 追加新需求、降级受影响需求 |

---

## 五、设计哲学：流程为什么这样设计？

### 1. 增量式演进，而非推倒重来

**核心原则**：`the existing framework stays; only additions and targeted modifications are allowed`

- 为什么？因为大部分软件开发不是从零开始，而是在已有系统上叠加新功能。若每次新需求都重新设计架构，会导致无休止的重构和交付延迟。
- 如何保障？通过 Immutable Goal 和 Scope Validation 两道防线，确保迭代不会偏离原始产品目标。

### 2. 影响分析是迭代的心脏

**Impact Matrix** 是连接"需求"与"架构"的桥梁。

- 为什么必须先做影响分析再做设计？因为如果没有先识别"哪些模块会受影响"，设计就会变成无的放矢。
- Severity 三级分型的意义：`breaking` / `additive` / `internal` 不是技术细节，而是**决策分类器**——它直接决定了后续是否需要版本化、是否需要重新验证。

### 3. 三层 XML 同步是权威的保障

**XML as Authority** 在迭代阶段面临最大挑战：变更需要在三层之间传播。

- 为什么需要 xml-sync.py？因为人类（包括 AI）手动维护三层 XML 的一致性几乎必然出错。
- Sync Report 不仅是技术产物，更是**审计线索**——当迭代出现问题时，可以追溯"变更从哪一层发起、传播到了哪一层"。

### 4. verification_gate 是闭环设计

**迭代不是线性的，是循环的**。

- 为什么 breaking changes 必须重新验证？因为"增量"不等于"安全"，一个看似小的接口变更可能破坏整个系统的验证假设。
- verification_gate 的设计体现了 DIVE 循环的本质：Evolve 之后必须回到 Verify。

### 5. 接口版本化是契约精神的体现

**Interface as Boundary** 在迭代阶段最容易被破坏。

- 为什么 additive 也要标注 `[ADDED vX.Y]`？因为即使兼容，开发者也需要知道"这是新加的"。
- 版本化不是技术官僚，而是**团队沟通工具**——它让下游模块的开发者清楚地知道"我依赖的接口发生了什么变化"。

### 6. Module Registry 状态管理是迭代安全的前提

- 为什么 pending 模块会阻断迭代？因为如果一个新增模块尚未完成设计，它的接口、状态、耦合都是未知的，基于未知做迭代计划等于在沙滩上建房子。
- RTM 降级机制（verified → implemented）体现了**验证状态是脆弱的**——任何 breaking 变更都会让已验证的需求回到"待验证"状态。

---

## 六、VCMF 五项原则在本阶段的体现

| VCMF 原则 | 在本阶段的具体体现 |
|-----------|------------------|
| **Design as Contract** | 新需求必须与原始 PRD 范围建立 `relates_to` 链接；超出范围的必须显式升级 |
| **Interface as Boundary** | 所有接口变更必须版本化；breaking changes 必须记录弃用时间线 |
| **Reality as Baseline** | Impact Matrix 强制识别每一个受影响模块，禁止隐藏依赖；循环依赖检查 |
| **State as Responsibility** | 新增/修改的状态条目必须声明与现有状态的关系（独立、派生、替换）；RTM 状态降级 |
| **XML as Authority** | 增量架构变更必须通过 xml-sync.py 在三层层级间同步传播；Sync Report 作为审计线索 |

---

## 七、与其他技能的协作边界

```
上游输入：
  devforge-requirement-analysis ──→ PRD.md（原始基线）
  devforge-architecture-design ──→ architecture.xml, INTERFACE_CONTRACT.md, DECISION_LOG.md
  devforge-module-design ──→ module-prd.md, module-architecture.xml, component-spec.xml
  devforge-test-execution ──→ STATE.md（含测试状态，间接参考）

下游输出：
  ┌─→ devforge-architecture-validation（若 verification_gate=true）
  ├─→ devforge-design-review（若 verification_gate=true）
  ├─→ devforge-project-scaffolding（若 add_module）
  ├─→ devforge-module-design（若 modify_module / extend_interface）
  └─→ devforge-test-execution（迭代实施后的验证）
```

**关键协作规则**：
1. iteration-planning 不直接生成代码，只生成增量设计文档（ITERATION_PRD.md、ITERATION_PLAN.md）
2. iteration-planning 可以触发重新验证（通过 verification_gate），但不直接执行验证
3. 若迭代范围包含新增模块，迭代计划中的执行顺序必须确保新增模块先走 architecture-design 流程
4. iteration-planning 是**唯一一个**在 STATE.md 中设置 `NextAction: iterate` 的技能，标志着项目进入"演进循环"状态

---

## 八、常见陷阱与注意事项

1. **不要修改 DECISION_LOG.md 中的现有决策** — 只能追加，不能改写历史
2. **不要改变核心架构模式** — 例如不能把微服务改成单体，这类变更需要重新走 architecture-design
3. **不要跳过影响分析** — 每个新需求都必须有 traced impact
4. **不要忽略 breaking changes** — 它们必须显式版本化并触发重新验证
5. **ITERATION_PRD.md 必须保持纯度** — 不能复制原始 PRD 的未变更需求，否则会导致需求管理的混乱
6. **循环依赖检查不可省略** — 新增模块或修改耦合时最容易引入循环依赖
