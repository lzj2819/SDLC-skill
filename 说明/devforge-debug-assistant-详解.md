# DevForge Debug Assistant 深度解析

> 本文档基于 DevForge SDLC Skill Chain v1.4 的 `devforge-debug-assistant` 技能定义（`SKILL.md`）进行深度分析。
>
> **定位**：Stage 10，是一个**跨阶段响应式技能**，可在 scaffolding 之后的任何阶段触发。
> **核心目标**：提供 Bug 诊断、根因分析和代码重构建议，是 DevForge 链中的"消防队"角色。
> **关键约束**：基于实际证据诊断，不猜测；修复不得违反接口契约；重构必须保留公共接口。

---

## 一、整体流程概览（三种模式）

```
触发条件: [DEBUG] / "fix this bug" / "refactor this" / "investigate incident"
                      ↓
         ┌────────────┼────────────┐
         ↓            ↓            ↓
    ┌─────────┐ ┌──────────┐ ┌──────────────┐
    │ Mode A  │ │ Mode B   │ │ Mode C       │
    │ Bug     │ │ Refactor │ │ Production   │
    │ Diag    │ │          │ │ Issue        │
    └────┬────┘ └────┬─────┘ └──────┬───────┘
         │           │              │
    Collect      Code Health   Collect Prod
    Evidence     Scan          Evidence
         │           │              │
    Root Cause   Identify       Correlate w/
    Analysis     Improvements   Architecture
         │           │              │
    Propose Fix  Propose        Root Cause
                 Refactorings   Analysis
         │           │              │
    Generate     Generate       Generate
    DEBUG_       REFACTOR_      PRODUCTION_
    REPORT       REPORT         INCIDENT_
                                  REPORT
         │           │              │
         └────────────┼────────────┘
                      ↓
              HARD-GATE（根因确认后才能修复）
                      ↓
              Human Gate（模式专用命令）
```

---

## 二、输入来源（按模式区分）

### Mode A (Bug Diagnosis) 输入

| 输入文件 | 来源 | 用途 |
|---------|------|------|
| 失败测试输出 | test-execution / CI | 核心诊断依据：预期值 vs 实际值 |
| 源码文件 | module-design / 用户代码 | 定位问题代码行 |
| `component-spec.xml` | module-design | 检查代码签名是否与 XML 规格一致 |
| 错误堆栈 | 运行时 | 追踪异常传播路径 |
| `TEST_REPORT.md` | test-execution | 了解测试执行的整体上下文 |

### Mode B (Refactoring) 输入

| 输入文件 | 来源 | 用途 |
|---------|------|------|
| 目标模块源码 | module-design | 扫描代码坏味道 |
| `component-spec.xml` | module-design | 确认代码与规格签名一致 |
| `INTERFACE_CONTRACT.md` | architecture-design | 确认重构不破坏接口契约 |
| `DESIGN_REVIEW.md` | design-review | 识别已知设计问题 |

### Mode C (Production Issue Diagnosis) 输入

| 输入文件 | 来源 | 用途 |
|---------|------|------|
| 生产日志 | 监控系统 | 核心诊断依据 |
| 监控指标 | Prometheus/Grafana/Datadog | CPU、内存、延迟、错误率 |
| 告警通知 | PagerDuty/OpsGenie | 问题触发点 |
| 分布式追踪 | Jaeger/Zipkin/X-Ray | 跨服务调用链 |
| `STATE.md` | 全链路维护 | Module Registry、Known Pitfalls |
| `component-spec.xml` | module-design | 将日志异常映射到具体组件 |

---

## 三、上下文加载协议（Context Loading Protocol）

Debug Assistant 有**专门的上下文加载策略**，因为它通常需要在有限的上下文窗口内处理大量日志和代码：

| 策略 | 说明 | 为什么重要 |
|------|------|-----------|
| **Targeted Loading** | 只加载受影响组件的 `component-spec.xml`，不加载所有模块 | 避免加载无关模块浪费 token |
| **Repo Index 利用** | 若 `repo-index.md` 存在，用它快速定位相关文件 | 避免扫描整个目录树 |
| **Log Truncation** | 大日志只加载最后 200 行 + 开头 50 行 | 保留最新的错误信息和启动上下文 |
| **Module Registry Digest** | 使用 `STATE.md` 中 Module Registry 的 `digest` 字段快速识别模块 | 无需加载完整模块 XML |

**对比其他技能**：
- iteration-planning 需要加载 8+ 个完整文件
- debug-assistant 采用**最小必要加载**，因为日志本身就可能占用大量 token

---

## 四、Mode A：Bug Diagnosis and Fix（Bug 诊断与修复）

### Step A1: Collect Evidence（收集证据）

#### 做什么？
1. 读取失败测试输出（CI 日志或本地测试运行结果）
2. 读取相关源码文件
3. 读取受影响组件的 `component-spec.xml`
4. 读取错误堆栈和日志片段
5. 若从 test-execution 进入，读取 `TEST_REPORT.md`

#### 调用什么工具？
| 工具类型 | 具体操作 |
|---------|---------|
| `Read` | 读取测试输出、源码、component-spec.xml、TEST_REPORT.md |
| `Grep` | 在日志中定位关键错误信息 |
| Log Truncation | 应用 head+tail 模式截断大日志 |

#### 为什么这样设计？
- **基于证据，而非猜测**：debug-assistant 的核心设计哲学是"Reality as Baseline"——诊断必须基于实际的测试输出和日志，不能凭经验臆断
- **component-spec.xml 作为对照**：代码是否与规格一致，是 bug 的一个常见来源（规格更新了，代码没更新）

---

### Step A2: Root Cause Analysis（根因分析）

#### 做什么？
从症状追踪到根因：
- 测试断言失败 → 预期值 vs 实际值是什么？
- 异常 → 哪一行抛出？输入是什么？
- 超时 → 哪个依赖慢？有没有重试机制？

检查常见错误类别：

| 错误类别 | 典型表现 | 检查方法 |
|---------|---------|---------|
| **Logic Error** | 错误条件、差一错误 | 对比预期逻辑与实际代码路径 |
| **State Error** | 竞态条件、未初始化状态 | 检查 StateModel 中的所有权声明 |
| **Interface Mismatch** | Schema 变了但消费者未更新 | 对比代码签名与 component-spec.xml |
| **Dependency Failure** | Mock 未设置、外部服务故障 | 检查测试依赖配置和外部服务状态 |
| **XML Divergence** | 代码签名与 component-spec.xml 不一致 | 直接文本比对 |

#### 调用什么工具？
| 工具类型 | 具体操作 |
|---------|---------|
| 逻辑分析 | 从堆栈跟踪反向推导执行路径 |
| 文本比对 | 对比代码签名与 component-spec.xml |
| 模式匹配 | 识别常见错误模式（null pointer、index out of bounds 等） |

#### 为什么这样设计？
- **结构化分类**：将 bug 归入预定义类别，帮助 AI 和人类快速定位问题性质
- **XML Divergence 是 DevForge 特有的检查项**：由于 XML as Authority 原则，代码与 XML 的不一致本身就是一种 bug 来源，而不仅仅是代码层面的逻辑错误

---

### Step A3: Propose Fix（提出修复方案）

#### 做什么？
1. 提供最小化的代码变更来修复 bug
2. 包含内联注释解释根因
3. 验证修复不会破坏其他测试
4. 若修复需要接口变更，标记为 breaking 并警告用户

#### 调用什么工具？
| 工具类型 | 具体操作 |
|---------|---------|
| `Edit` | 修改源码文件 |
| 影响分析 | 检查修复是否波及其他测试用例 |
| 接口检查 | 验证修复后的签名仍符合 component-spec.xml |

#### 为什么这样设计？
- **最小化变更原则**：只改必要的代码，减少引入新 bug 的风险
- **内联注释记录根因**：让代码自解释，避免"这个为什么改了？"的疑问
- **breaking 标记**：修复 bug 不应该悄悄改变接口契约——如果需要改变接口，必须显式告知

---

### Step A4: Generate Debug Report（生成调试报告）

#### 做什么？
生成 `DEBUG_REPORT.md`，包含：
- **Symptom Summary**：症状一句话总结
- **Root Cause**：根因分析（附代码引用）
- **Proposed Fix**：修复方案（diff 格式）
- **Regression Risk Assessment**：回归风险评估
- **Verification Steps**：如何验证修复有效

#### 输出文件
`PROJECT_SCAFFOLD/docs/architecture/validation/DEBUG_REPORT.md`

---

## 五、Mode B：Refactoring Suggestion（重构建议）

### Step B1: Code Health Scan（代码健康扫描）

#### 做什么？
读取目标模块/组件的源码、component-spec.xml、INTERFACE_CONTRACT.md、DESIGN_REVIEW.md

#### 调用什么工具？
| 工具类型 | 具体操作 |
|---------|---------|
| `Read` | 读取源码和架构文档 |
| `Grep` | 扫描代码中的坏味道模式 |

---

### Step B2: Identify Improvement Opportunities（识别改进点）

#### 做什么？
检查代码坏味道（Code Smells）：

| 坏味道 | 判定标准 | 风险级别 |
|--------|---------|---------|
| 长函数 | > 50 行 | 中 |
| 深层嵌套 | > 3 层 | 中 |
| 重复逻辑 | 相同/相似代码块出现多次 | 低 |
| 魔法数字/字符串 | 未命名的常量 | 低 |
| 紧耦合 | 直接依赖具体类而非接口 | 高 |
| 缺失错误处理 | 未覆盖的错误路径 | 高 |

同时检查架构对齐性：
- 代码是否与 `component-spec.xml` 签名一致？
- 状态管理是否与 `StateModel` 一致？
- 接口是否使用了正确的 schema？

#### 为什么这样设计？
- **量化标准**："长函数 > 50 行"、"嵌套 > 3 层"——给出可操作的阈值，避免主观判断
- **架构对齐检查**：重构不只是"让代码好看"，还要确保代码仍然遵守架构契约

---

### Step B3: Propose Refactorings（提出重构方案）

#### 做什么？
对每个问题提供：
- 位置（file:line）
- 问题描述
- 重构策略（提取方法、引入接口等）
- Before/After 代码片段
- 风险等级（low / medium / high）

---

### Step B4: Generate Refactor Report（生成重构报告）

#### 做什么？
生成 `REFACTOR_REPORT.md`，包含：
- 问题列表及严重级别（Must Fix / Should Fix / Nice to Fix）
- Before/After 代码片段
- 每项重构的风险评估
- 建议执行顺序（低风险优先）

#### 输出文件
`PROJECT_SCAFFOLD/docs/architecture/validation/REFACTOR_REPORT.md`

#### 为什么"低风险优先"？
- 重构是**高风险活动**，即使"不改变行为"的重构也可能引入 bug
- 低风险优先的策略可以在早期建立信心，同时逐步推进更复杂的变更

---

## 六、Mode C：Production Issue Diagnosis（生产问题诊断）

### Step C1: Collect Production Evidence（收集生产证据）

#### 做什么？
1. 读取生产日志（error logs、access logs、application logs）
2. 读取监控指标（CPU、内存、延迟、错误率）
3. 读取告警通知
4. 读取分布式追踪（如可用）
5. 读取 `STATE.md` 了解模块注册表和已知陷阱

**注意**：Mode C **不需要**测试输出——生产日志和指标才是主要输入

#### 调用什么工具？
| 工具类型 | 具体操作 |
|---------|---------|
| `Read` | 读取日志文件、监控数据 |
| Log Truncation | head+tail 模式处理大日志 |
| 时间序列分析 | 关联日志、指标、追踪的时间戳 |

#### 为什么这样设计？
- **生产环境 ≠ 测试环境**：生产问题往往涉及资源耗尽、级联故障、流量异常等测试环境难以复现的问题
- **多源证据关联**：单一数据源（如日志）可能误导，必须将日志、指标、追踪三者交叉验证

---

### Step C2: Correlate Symptoms with Architecture（症状与架构关联）

#### 做什么？
1. 使用 `component-spec.xml` 将日志异常映射到具体模块/组件
2. 识别错误路径中涉及的模块接口
3. 检查问题是否匹配 `STATE.md` 中的已知陷阱
4. 关联日志、指标、追踪的时间戳

#### 为什么这样设计？
- **从"什么错了"到"哪里错了"**：日志告诉你"数据库连接超时"，架构文档告诉你"这是 OrderService 的依赖"
- **已知陷阱匹配**：如果 STATE.md 中已经记录了"连接池耗尽是已知风险"，可以快速缩小排查范围

---

### Step C3: Root Cause Analysis（根因分析）

#### 做什么？
使用生产特定的错误分类：

| 错误类别 | 典型场景 |
|---------|---------|
| **Resource Exhaustion** | OOM、连接池耗尽、线程饥饿 |
| **Cascade Failure** | 下游服务超时向上游传播 |
| **Deployment-Related** | 配置不匹配、滚动更新问题、特性开关 |
| **Data Corruption** | 状态不一致、迁移错误 |
| **External Dependency Failure** | 第三方 API、云服务故障 |
| **Traffic Pattern Anomaly** | DDoS、惊群效应、突发流量 |

使用 **5 Whys 方法**从症状追踪到根因。

#### 为什么用 5 Whys？
- 生产问题往往有**深层根因**（如"连接超时"的根因可能是"连接池配置过小"，再深入可能是"压测时未考虑峰值"）
- 5 Whys 强制追问到系统/流程层面，而不是停留在表面症状

---

### Step C4: Generate Production Incident Report（生成生产事故报告）

#### 做什么？
生成 `PRODUCTION_INCIDENT_REPORT.md`，包含：
- **Incident Summary**：什么、何时、影响范围
- **Symptom Timeline**：按时间顺序排列的事件日志
- **Root Cause**：附证据引用
- **Affected Components and Modules**：受影响的组件和模块
- **Immediate Mitigation**：紧急缓解措施（如有）
- **Long-term Fix Proposal**：长期修复方案
- **Prevention Recommendations**：预防建议

#### 输出文件
`PROJECT_SCAFFOLD/docs/architecture/validation/PRODUCTION_INCIDENT_REPORT.md`

#### 为什么包含"Immediate Mitigation"和"Long-term Fix"？
- 生产事故有**时间压力**：先止血（mitigation），再根治（fix）
- 事故报告是**组织学习工具**：记录完整时间线和根因，供事后复盘

---

## 七、HARD-GATE（硬性关卡）

Debug Assistant 的 HARD-GATE 是 DevForge 链中**最严格**的之一：

> **Do NOT apply refactoring changes or close a debug session until the user explicitly approves the fix strategy.**

具体要求：
- **Mode A**：根因分析必须被确认后，才能生成修复方案
- **Mode B**：重构计划必须被批准后，才能应用变更
- **Mode C**：事故时间线和根因必须被确认后，才能提出修复

### 为什么如此严格？
1. **Debug Assistant 是唯一直接修改代码的技能**：其他技能（module-design、scaffolding）生成代码骨架，但 debug-assistant 直接修改已有代码——风险更高
2. **修复可能比 bug 更糟糕**：一个未经确认的修复可能引入新的 bug，甚至破坏已有功能
3. **生产事故需要审慎**：Mode C 涉及生产环境，错误的修复可能导致二次事故

---

## 八、人机关卡（Human Gate）

根据当前模式展示不同的摘要和命令：

### 模式专用命令

| 命令 | 适用模式 | 含义 |
|------|---------|------|
| `[APPROVE FIX]` | A / C | 应用修复方案 |
| `[APPROVE REFACTOR]` | B | 应用重构方案 |
| `[SPECIFIC {issue_id}]` | 全模式 | 只处理特定问题 |
| `[PAUSE]` | 全模式 | 暂停，保留上下文 |
| `[ROLLBACK {step_id}]` | 全模式 | 回滚到指定步骤 |
| `[EDIT {file_path}]` | 全模式 | 手动编辑后让 AI 继续 |
| `[INJECT {context}]` | 全模式 | 补充额外上下文 |
| `[EXPLAIN {TraceID}]` | 全模式 | 展开解释决策/错误推理链 |

### 与其他技能的区别
- iteration-planning 的命令是 `[APPROVE]`、`[MODIFY]`、`[REJECT]`
- debug-assistant 的命令更具体：`[APPROVE FIX]` 和 `[APPROVE REFACTOR]`，因为修复和重构的风险级别不同

---

## 九、输出产物清单

| 产物文件 | 路径 | 适用模式 | 说明 |
|---------|------|---------|------|
| `DEBUG_REPORT.md` | `docs/architecture/validation/DEBUG_REPORT.md` | A | Bug 诊断报告 |
| `REFACTOR_REPORT.md` | `docs/architecture/validation/REFACTOR_REPORT.md` | B | 重构建议报告 |
| `PRODUCTION_INCIDENT_REPORT.md` | `docs/architecture/validation/PRODUCTION_INCIDENT_REPORT.md` | C | 生产事故分析报告 |

---

## 十、设计哲学：流程为什么这样设计？

### 1. 三模式设计：覆盖软件生命周期的三类问题

| 模式 | 触发场景 | 核心差异 |
|------|---------|---------|
| Mode A | 测试失败 | 以测试输出为核心证据 |
| Mode B | 代码质量改进 | 以代码坏味道为核心输入 |
| Mode C | 生产事故 | 以日志/指标/追踪为核心证据 |

**为什么不做成一个通用模式？**
- 三类问题的**证据来源完全不同**：测试输出 vs 源码质量 vs 生产监控
- 三类问题的**时间压力不同**：Mode A 可以慢慢分析，Mode C 需要快速响应
- 三类问题的**输出受众不同**：DEBUG_REPORT 给开发者，INCIDENT_REPORT 给运维和经理

### 2. 基于证据的诊断，而非猜测

**Reality as Baseline** 在 debug-assistant 中被推到极端：
- Mode A：必须基于实际测试输出
- Mode C：必须基于实际日志和指标
- 禁止"我觉得可能是..."的推测性诊断

**为什么？**
- 调试是最容易被认知偏差影响的环节——开发者往往根据经验先入为主地假设根因
- 强制基于证据的诊断，可以过滤掉大量的错误假设

### 3. Context Loading Protocol：在有限上下文内处理无限日志

**为什么需要专门的上下文策略？**
- 生产日志可能达到 GB 级别，不可能全部加载到上下文中
- head+tail（前 50 + 后 200 行）的策略保留了：启动信息（前 50）+ 最新错误（后 200）
- Targeted Loading 避免加载无关模块的 XML

### 4. HARD-GATE 的双重确认机制

**为什么根因确认必须在修复之前？**
- 匆忙修复（"先试试这个"）往往会掩盖真正的根因
- 双重确认机制强制进行充分的根因分析，再进入修复阶段
- 这在 Mode C（生产事故）中尤为重要——错误的修复可能导致服务再次中断

### 5. VCMF 五项原则全部标记为 "New"

Debug Assistant 是 DevForge 链中**唯一一个**所有 VCMF 原则都标记为 "New" 的技能：

| 原则 | 为什么对 Debug 是全新的 |
|------|----------------------|
| **Design as Contract** | Bug 修复不能违反 INTERFACE_CONTRACT——修复本身也必须遵守契约 |
| **Interface as Boundary** | 重构必须保留公共接口——这是重构的底线 |
| **Reality as Baseline** | 诊断基于实际输出——不是设计文档，而是运行时证据 |
| **State as Responsibility** | Bug 涉及状态时，必须尊重 StateModel 的所有权声明 |
| **XML as Authority** | 若 bug 的根源是 XML 规格本身错了，必须更新 XML |

**这说明了什么？**
- Debug Assistant 不是简单地"应用"已有原则，而是在调试这个特殊场景下**重新定义**了这些原则的含义
- 其他技能是"生成"和"设计"，debug-assistant 是"修复"和"维护"——工作性质完全不同

---

## 十一、VCMF 五项原则在本阶段的体现

| VCMF 原则 | 在本阶段的具体体现 |
|-----------|------------------|
| **Design as Contract** | Bug 修复不得违反 `INTERFACE_CONTRACT.md` 或 `component-spec.xml`；修复方案必须经过审批 |
| **Interface as Boundary** | 重构必须保留所有公共接口，除非用户显式批准接口变更 |
| **Reality as Baseline** | 诊断基于实际测试输出、日志、监控指标，禁止猜测；XML Divergence 是一种独立的 bug 类别 |
| **State as Responsibility** | 涉及状态的 bug 修复必须尊重 `StateModel` 中的所有权声明 |
| **XML as Authority** | 若发现 bug 的根源是 `component-spec.xml` 本身错误，必须更新 XML 规格而非仅修改代码 |

---

## 十二、与其他技能的协作边界

```
上游触发：
  devforge-test-execution ──→ [DEBUG]（测试失败时触发 Mode A）
  用户直接输入 ──→ "fix this bug" / "refactor this" / "investigate incident"

可能的上游状态：
  scaffolding_completed, module_design_completed,
  iteration_planning_completed, test_execution_completed

下游影响：
  ┌─→ 修改后的源码文件（Mode A/B 应用修复后）
  ├─→ 更新后的 component-spec.xml（若 XML 本身有 bug）
  ├─→ STATE.md Known Pitfalls（追加新发现的风险）
  ├─→ STATE.md Error Log（记录错误和修复）
  └─→ devforge-test-execution（修复后重新运行测试）
```

**关键协作规则**：
1. debug-assistant **不生成新功能**，只修复已有代码的问题
2. debug-assistant 可以**更新 XML 规格**（如果 bug 根因在 XML），这是极少数可以反向修改架构文档的技能
3. debug-assistant 是**响应式技能**，不是流程中的必经阶段——项目在任何时候都可能触发它
4. 修复后的代码必须**重新走 test-execution** 验证

---

## 十三、常见陷阱与注意事项

1. **不要违反 INTERFACE_CONTRACT.md 提出修复** — 接口变更必须经用户显式批准
2. **不要在没有保留公共接口的情况下重构** — 重构的底线是行为保持
3. **不要基于猜测诊断** — 必须引用实际的测试输出、日志或监控指标
4. **不要在 Mode C 中忽略生产上下文** — 必须将日志与架构和已知陷阱关联
5. **不要跳过 HARD-GATE** — 根因确认前不得生成修复
6. **注意 XML Divergence** — 代码与 component-spec.xml 不一致本身就是一种 bug，可能是双向的（代码错了，或 XML 错了）
7. **大日志处理** — 始终使用 head+tail 截断，避免耗尽上下文窗口
8. **Targeted Loading** — 不要加载无关模块的 XML，浪费 token
