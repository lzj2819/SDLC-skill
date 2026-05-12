# DevForge Architecture Validation 深度解析

> 本文档基于 DevForge SDLC Skill Chain v1.4 的 `devforge-architecture-validation` 技能定义（`SKILL.md`）进行深度分析。
>
> **定位**：Stage 3a，属于 DIVE 工作流的 **Verify（验证）** 阶段。
> **核心目标**：回答"架构文档在技术层面是否自洽？"——如同编译器的类型检查。

---

## 一、整体流程概览（12个步骤）

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  Step 1: API 就绪性检查（API Readiness Check）                                  │
│       ↓                                                                     │
│  Step 2: 一致性检查 — XML vs 接口契约（XML vs Interface Contract）              │
│       ↓                                                                     │
│  Step 3: 一致性检查 — XML vs PRD（XML vs PRD）                                │
│       ↓                                                                     │
│  Step 4: Mock 数据注入（Mock Injection）                                       │
│       ↓                                                                     │
│  Step 5: 逐模块模拟（Module-by-Module Simulation）                             │
│       ↓                                                                     │
│  Step 6: 真实 LLM 验证（Real-LLM Validation，最小覆盖集）                       │
│       ↓                                                                     │
│  Step 7: 追踪日志打印（Trace Logging）                                         │
│       ↓                                                                     │
│  Step 8: 自愈循环（Self-Healing Loop）                                         │
│       ↓                                                                     │
│  Step 9: 健康检查脚本生成（Health-Check Script Generation）                     │
│       ↓                                                                     │
│  Step 10: 自验证 — 报告与脚本质量（Self-Validation）                            │
│       ↓                                                                     │
│  Step 11: 状态更新（State Update）                                             │
│       ↓                                                                     │
│  Step 12: 人机关卡（Human Gate）                                               │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 二、输入来源（上游产物）

`devforge-architecture-validation` 是 Triple Verification（三重验证）机制的第一环（3a），它的输入全部来自上游 `devforge-architecture-design`（Stage 2）：

| 输入文件 | 来源阶段 | 用途 |
|---------|---------|------|
| `architecture.xml` | architecture-design | 被验证的核心对象——系统级 XML 架构 |
| `INTERFACE_CONTRACT.md` | architecture-design | 接口契约，用于比对 XML 中的 `Module/Interface` |
| `PRD.md` | requirement-analysis | 需求基准，用于检查 XML 模块是否都有需求来源 |
| `ARCHITECTURE.md` | architecture-design | 提取 Mock 数据和测试用例 |
| `module-architecture.xml`（模块级，如存在） | architecture-design | 三层 XML 的引用完整性检查 |
| `STATE.md` | 全链条维护 | 读取当前 phase，确认前置条件满足 |

---

## 三、每一步详解与调用的工具

### Step 1: API 就绪性检查（API Readiness Check）

#### 做什么？
- 询问用户是否有 API Key 和 Base URL
- 如果有，配置好用于后续真实 LLM 调用
- 如果没有或用户拒绝，**明确声明**：真实 LLM 验证将被跳过，本阶段仅运行 Mock 验证 + 一致性检查

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `AskUserQuestion` | 询问用户 API Key 和 Base URL |

#### 为什么这样设计？
- **优雅降级（Graceful Degradation）**：没有 API Key 不会阻塞整个验证流程
- **透明性**：明确告知用户哪些检查被跳过了，避免产生"验证通过 = 万无一失"的错觉
- **成本意识**：真实 LLM 调用需要付费，给用户选择权

---

### Step 2: 一致性检查 — XML vs 接口契约（Consistency Check: XML vs Interface Contract）

#### 做什么？
将 `architecture.xml` 中每个 `Module/Interface` 与 `INTERFACE_CONTRACT.md` 进行逐项比对：

| 比对项 | 检查内容 |
|--------|---------|
| **输入模式（Input Schema）** | XML 中 `Module/Interface/Input/@schema` 是否与契约一致 |
| **输出模式（Output Schema）** | XML 中 `Module/Interface/Output/@schema` 是否与契约一致 |
| **错误码（Error Codes）** | XML 中 `Module/Interface/ErrorCodes` 是否完整覆盖契约定义的错误场景 |

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Read` | 读取 `architecture.xml` 和 `INTERFACE_CONTRACT.md` |

#### 为什么这样设计？
- **VCMF "Interface as Boundary"**：接口是模块之间的契约边界，任何不匹配都会导致集成失败
- **编译器类比**：这相当于编译器的"类型检查"——函数签名声明和实际定义必须一致
- **前置检查**：在投入模拟之前先排除低级错误

---

### Step 3: 一致性检查 — XML vs PRD（Consistency Check: XML vs PRD）

#### 做什么？
验证 `architecture.xml` 中的每个模块都能追溯到 `PRD.md` 中的某个需求或用户故事：

| 检查项 | 说明 |
|--------|------|
| **孤儿模块检测** | XML 中定义的模块在 PRD 中没有对应需求 → 标记为孤儿模块（orphaned module） |
| **需求覆盖度** | PRD 中的 P0/P1 功能需求是否有对应的模块实现 |

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Read` | 读取 `architecture.xml` 和 `PRD.md` |
| `Grep` | 在 PRD 中搜索模块名称或相关需求 ID |

#### 为什么这样设计？
- **VCMF "Design as Contract"**：架构必须可追溯回 PRD，不能凭空发明需求
- **防止范围蔓延**：如果架构中出现了 PRD 没要求的功能，说明架构师（AI）过度设计了
- **孤儿模块 = 技术债务**：没人知道为什么要做这个模块，后续维护成本极高

---

### Step 4: Mock 数据注入（Mock Injection）

#### 做什么？
- 读取 `ARCHITECTURE.md` 中定义的 Mock 业务数据结构
- 将这些 Mock 数据加载为模拟触发源

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Read` | 读取 `ARCHITECTURE.md` 提取 Mock 数据定义 |

#### 为什么这样设计？
- **可重复的模拟**：使用预定义的 Mock 数据而不是随机生成，确保模拟结果可复现
- **隔离性**：Mock 数据隔离了外部依赖，让验证专注于架构内部逻辑
- **与测试用例对齐**：Mock 数据在 architecture-design 阶段就与测试用例一起设计，保持一致

---

### Step 5: 逐模块模拟（Module-by-Module Simulation）

#### 做什么？
对 `architecture.xml` 中的每个 `Module`，依次执行：

| 模拟步骤 | 验证内容 |
|---------|---------|
| **接收上游输出** | 模拟模块 A 的输出作为模块 B 的输入 |
| **安全要求验证** | 检查 `Security` 节点定义的认证/加密要求是否被满足 |
| **耦合依赖验证** | 检查 `Coupling/DependsOn` 引用的模块是否存在且可达 |
| **输出模式匹配** | 验证当前模块的输出模式是否匹配下游模块的输入模式 |

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Read` | 逐模块读取 `architecture.xml` 的 `Module` 节点 |
| `Grep` | 在 XML 中查找依赖模块的定义 |

#### 为什么这样设计？
- **编译器式的逐模块检查**：如同编译器逐个编译源文件并检查类型一致性
- **数据流驱动**：模拟真实数据在模块间的流动，验证接口兼容性
- **安全内嵌**：安全不是独立步骤，而是每个模块模拟的必经检查点（VCMF "Security by Design"）
- **耦合可达性**：防止出现"模块 A 依赖模块 B，但模块 B 不存在"的死链

---

### Step 6: 真实 LLM 验证（Real-LLM Validation，最小覆盖集）

#### 做什么？
如果 API Key 可用，执行最小覆盖集的真实 LLM 调用：

| 验证项 | 说明 |
|--------|------|
| **格式/模式合规性** | LLM 输出是否符合预期的 XML schema？ |
| **Mock 数据结构解析** | LLM 能否正确解析并返回 Mock 数据结构？ |

**明确不做的**（由 design-review 负责）：
- 安全判断（Security judgment）
- 错误翻译（Error translation）
- 工具选择验证（Tool selection）

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `WebFetch` / API 调用 | 向 LLM API 发送请求并接收响应 |

#### 为什么这样设计？
- **最小覆盖集**：不做全面测试，只验证"架构中假设 LLM 能做到的事，LLM 真的能做到"
- **成本与价值平衡**：全面 LLM 测试成本高、耗时长，最小覆盖集在成本和覆盖度之间取得平衡
- **职责分离**：semantic-sensitive 的验证（安全、错误处理）交给 `devforge-design-review`（3b），避免重复
- **降级策略**：无 API Key 时自动降级为 Mock + 一致性检查，不阻塞流程

---

### Step 7: 追踪日志打印（Trace Logging）

#### 做什么？
将模拟过程打印为结构化追踪日志，格式如下：

```
[API Response] -> [Case ID] -> Inject Mock -> [Module A] Receive -> [Auth: Valid] -> Simulate Logic -> [Data Contract: PASS] -> Route to [Module B] ... -> Final Result
```

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Write` | 将追踪日志写入验证报告 |

#### 为什么这样设计？
- **可审计性**：完整的模拟轨迹让开发者和审阅者可以复盘每一步发生了什么
- **故障定位**：当某个模块验证失败时，追踪日志精确指出失败点在哪一步
- **透明度**：明确标注 `[SIMULATED]` vs `[REAL]`，防止混淆模拟结果和真实 API 结果（VCMF "Reality as Baseline"）

---

### Step 8: 自愈循环（Self-Healing Loop）

#### 做什么？
对发现的每个问题进行分类和处理：

| 分类 | 定义 | 处理方式 |
|------|------|---------|
| **阻塞性（Blocking）** | 会导致系统失败的严重问题 | 必须修复，不能继续 |
| **非阻塞性（Non-blocking）** | 警告/观察性问题 | 可以跳过，但需记录 |

**分支逻辑**：

```
if (存在阻塞性失败):
    记录失败到报告
    告知用户: "架构校验未通过，存在阻塞性问题。请回复 [RETRY] 退回架构设计阶段修改 XML，或提出修改意见。"
    → 禁止进入 scaffolding

elif (仅存在非阻塞性警告):
    告知用户: "架构校验发现 {N} 个非阻塞性警告。回复 [FORCE_APPROVE] 跳过警告继续到设计审查阶段，或回复 [RETRY] 修改。"

else (全部通过):
    写入 VALIDATION_REPORT.md
    生成 VALIDATION_DELTA.md（与上一轮验证结果对比）
```

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Read` | 读取上一轮验证报告（用于生成 Delta） |
| `Write` | 写入 `VALIDATION_REPORT.md` 和 `VALIDATION_DELTA.md` |

#### VALIDATION_DELTA.md 的生成逻辑
- 读取前一轮 `VALIDATION_REPORT.md`（如果存在）
- 对比当前结果与上一轮结果
- **只记录**：新引入的问题 或 已解决的问题
- **首次验证**：报告声明"Initial validation — all issues are new"

#### 为什么这样设计？
- **增量视角**：VALIDATION_DELTA 让团队一眼看出"这次验证相比上次有什么变化"
- **渐进式验证**：迭代开发中，不需要每次都看完整报告，只需关注变化
- **阻塞 vs 非阻塞的区分**：
  - 阻塞 = 编译错误，不修复无法运行
  - 非阻塞 = 编译警告，可以运行但可能有问题
- **[FORCE_APPROVE] 的权限控制**：仅在所有失败都是 warning 级别时才可用，防止误用

---

### Step 9: 健康检查脚本生成（Health-Check Script Generation）

#### 做什么？
生成可执行的 `health-check.sh` 脚本，检查以下内容：

| 检查项 | 说明 |
|--------|------|
| **XML 格式良好性** | `xmllint` 或等效工具验证 XML 是否 well-formed |
| **耦合目标存在性** | 所有 `Coupling/DependsOn/@module` 引用的模块名在 XML 中真实存在 |
| **StateModel 属性完整性** | 所有 `StateModel/State` 节点都有必需的 `location`, `owner`, `lifecycle` 属性 |

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Write` | 生成 `health-check.sh` |
| `Bash` | 运行 `bash -n health-check.sh` 验证脚本语法 |

#### 为什么这样设计？
- **可重复执行**：脚本可以集成到 CI/CD 中，每次提交自动运行
- **开发者自助**：不需要 AI 介入，开发者自己就能运行脚本检查架构一致性
- **三层验证的自动化**：脚本检查的是"机器能验证的"，AI 模拟检查的是"机器无法自动验证的"
- **Unix Shell 可运行**：选择 shell 脚本是因为通用性强，几乎任何 CI 环境都支持

---

### Step 10: 自验证 — 报告与脚本质量（Self-Validation）

#### 做什么？
执行 5 项自动检查：

| 检查 ID | 检查项 | 通过标准 |
|---------|--------|---------|
| VAL-REPORT-COMPLETE | **报告完整性** | `VALIDATION_REPORT.md` 对每个 `Module` 都有 PASS/FAIL 判定 |
| VAL-TRACE-FORMAT | **追踪日志格式** | 每条追踪线都遵循 `[API Response] -> [Case ID] -> ... -> Final Result` 格式 |
| VAL-SCRIPT-SYNTAX | **脚本语法有效性** | `bash -n health-check.sh` 必须通过 |
| VAL-SIM-TRANSPARENCY | **模拟透明度** | 报告中所有模拟输出都明确标注 `[SIMULATED]`，防止被误读为真实 API 结果 |
| VAL-DELTA-ACCURACY | **Delta 报告准确性** | `VALIDATION_DELTA.md` 只包含与上一轮验证结果不同的 issue |

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Read` | 读取报告和脚本进行质量检查 |
| `Bash` | 运行 `bash -n` 验证脚本语法 |
| `Grep` | 在报告中搜索 `[SIMULATED]` 标记 |

#### 为什么这样设计？
- **验证验证者的质量**：如果连验证报告本身都有问题，那验证结果不可信
- **防止模拟幻觉**：特别要求检查 `[SIMULATED]` 标记，防止 AI 误将模拟结果呈现为真实测试结果
- **引用 validation-engine.md**：与所有其他技能使用同一套检查框架，保持标准一致

---

### Step 11: 状态更新（State Update）

#### 做什么？
更新 `STATE.md`：

1. **Completed Steps 追加**：
   ```
   [YYYY-MM-DD HH:MM] devforge-architecture-validation: 
   Validated N modules. X PASS, Y FAIL (Z blocking). 
   Real-LLM validation: {run/skipped}. Health-check script generated.
   ```
2. **设置 DIVE 状态**：`Verify: completed`（注意：Design 仍是 completed，Implement 仍是 pending）
3. **更新 Artifact Index**：添加 `VALIDATION_REPORT.md`、`VALIDATION_DELTA.md`、`health-check.sh`
4. **Known Pitfalls 追加**：发现的任何架构风险

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Read` | 读取当前 STATE.md |
| `Write` / `Edit` | 更新 STATE.md 各节内容 |

#### 为什么这样设计？
- **DIVE 状态映射**：Validation 属于 Verify 阶段，完成后设置 `Verify: completed`
- **但 Verify 没结束**：因为 design-review（3b）和 security-audit（3c）也是 Verify 阶段的一部分
- **Artifact Index 实时更新**：让后续技能（如 design-review）知道验证产物在哪里

---

### Step 12: 人机关卡（Human Gate）

#### 做什么？
1. 展示验证摘要（通过/失败数，阻塞 vs 非阻塞分类）
2. 告知："架构验证报告和健康检查脚本已生成。请确认当前阶段输出。"
3. 列出可用命令并等待用户回复

#### 可用命令

| 命令 | 作用 | 可用条件 |
|------|------|---------|
| `[APPROVE]` | 批准并继续（进入 design-review 阶段，推荐） |  always |
| `[SKIP_REVIEW]` | 跳过设计审查，直接进入 project-scaffolding 阶段 | always |
| `[FORCE_APPROVE]` | 跳过非阻塞性警告 | 仅当所有失败都是 warning 级别 |
| `[PAUSE]` | 暂停当前阶段，保留上下文 | always |
| `[ROLLBACK {step_id}]` | 回滚到指定步骤重新执行 | always |
| `[EDIT {file_path}]` | 手动编辑文件后让 AI 继续 | always |
| `[INJECT {context}]` | 补充额外上下文约束 | always |
| `[EXPLAIN {TraceID}]` | 展开解释某个决策/错误的推理链 | always |

#### 关键约束：HARD-GATE
```markdown
<HARD-GATE>
Do NOT proceed to project-scaffolding if validation failed. 
If validation passed, do NOT proceed until the user replies [APPROVE], [SKIP_REVIEW], or [FORCE_APPROVE].
</HARD-GATE>
```

#### 为什么这样设计？
- **双重 HARD-GATE**：
  - 验证失败 → 禁止继续（必须 `[RETRY]` 回 architecture-design 修改）
  - 验证通过 → 仍需要人类确认（不能自动跳到 scaffolding）
- **`[SKIP_REVIEW]` 的存在**：
  - 允许用户跳过 design-review（3b）直接进入 scaffolding
  - 但只在关卡中提供，不会在流程中自动跳过
  - 这是给用户的选择权，不是默认行为
- **`[FORCE_APPROVE]` 的条件限制**：
  - 防止用户在存在阻塞性问题时强行继续
  - 系统必须确保所有阻塞性问题都已解决或已被明确处理

---

## 四、核心输出产物清单

| 产物 | 路径 | 作用 | 下游消费者 |
|------|------|------|-----------|
| **VALIDATION_REPORT.md** | `docs/architecture/validation/VALIDATION_REPORT.md` | 完整验证报告，含逐模块 PASS/FAIL 和模拟追踪 | design-review（3b）参考；iteration-planning（7）对比 |
| **VALIDATION_DELTA.md** | `docs/architecture/validation/VALIDATION_DELTA_{YYYYMMDD}.md` | 与上一轮验证的差异报告（新增/已解决问题） | iteration-planning（7）判断是否需重新验证 |
| **health-check.sh** | `docs/architecture/validation/health-check.sh` | 可执行的架构一致性检查脚本 | CI/CD 集成；开发者日常自查 |

---

## 五、流程设计哲学深度解析

### 1. 为什么是"编译器类型检查"的类比？

DevForge 将 architecture-validation（3a）比作**编译器的类型检查**：

| 编译器类型检查 | 架构验证 |
|---------------|---------|
| 检查函数签名是否匹配声明 | 检查 XML Interface 是否匹配 INTERFACE_CONTRACT.md |
| 检查变量类型是否兼容 | 检查模块输出模式是否匹配下游输入模式 |
| 检查引用的函数是否存在 | 检查 Coupling/DependsOn 的模块是否存在 |
| 检查语法是否正确 | 检查 XML well-formedness 和 schema compliance |

**关键洞察**：编译器不会问你"这个算法是否最优"（那是代码审查的事），它只问"这个代码在技术层面是否自洽"。同理，architecture-validation 不问"这个架构设计是否合理"（那是 design-review 的事），它只问"这个架构文档在技术层面是否自洽"。

### 2. 为什么要有 Mock + 真实 LLM 的双重验证？

| 验证类型 | 覆盖范围 | 成本 | 必要性 |
|---------|---------|------|--------|
| **Mock 验证** | 结构一致性、接口兼容性、数据流连通性 | 低（本地计算） | 必须 |
| **真实 LLM 验证** | LLM 实际输出是否符合预期 schema | 高（API 调用费） | 可选但推荐 |

**原因**：
- 架构中可能假设"LLM 会返回 JSON 格式的 X"，但真实的 LLM 可能返回 markdown 包裹的 JSON、或字段名不一致
- Mock 验证不了这种"语义层面的假设是否成立"
- 但全面真实 LLM 测试成本太高，所以采用**最小覆盖集**

### 3. 为什么 VALIDATION_DELTA 只记录"变化"？

**场景**：项目进行到第 5 轮迭代，每次验证都产生一份报告。

**没有 Delta**：
- 开发者需要人工对比 5 份报告，找出"这次多了什么问题"
- 耗时且容易遗漏

**有 Delta**：
- 开发者只看最新 Delta，一目了然："新增 2 个问题，已解决 3 个问题"
- 特别适合 CI/CD 集成：每次 PR 自动生成 Delta，Reviewer 只看变化

### 4. 为什么区分 Blocking vs Non-blocking？

这对应软件开发中**编译错误 vs 编译警告**的经典区分：

| 类型 | 类比 | 处理策略 |
|------|------|---------|
| **Blocking** | 编译错误（Error） | 必须修复，否则系统无法运行 |
| **Non-blocking** | 编译警告（Warning） | 可以暂时接受，但需记录并计划在后续修复 |

**设计意图**：
- 不是所有问题都值得阻塞整个流程
- 但在关键节点（进入 scaffolding 前），必须确保没有阻塞性问题
- `[FORCE_APPROVE]` 的设计体现了"工程实用性"——在警告可控时允许继续

### 5. 为什么 health-check.sh 是可执行脚本而不是文档？

| 形式 | 优势 | 劣势 |
|------|------|------|
| **文档** | 人类可读 | 无法自动化，容易过时 |
| **可执行脚本** | 可集成 CI，每次提交自动验证，永不"文档与代码不同步" | 需要维护脚本本身 |

**设计意图**：
- DevForge 强调 **"可执行架构"（Executable Architecture）**
- 架构文档不是静态 PDF，而是可以被机器验证的活文档
- 脚本生成后由 AI 验证语法（`bash -n`），确保脚本本身是可运行的

---

## 六、与 Triple Verification（三重验证）的关系

`devforge-architecture-validation` 是 Triple Verification 的第一环（3a）：

| 维度 | 3a. architecture-validation（本文档） | 3b. design-review | 3c. security-audit |
|------|--------------------------------------|-------------------|-------------------|
| **目的** | 验证"设计在技术层面是否正确指定" | 验证"设计是否有缺陷/遗漏" | 验证"设计是否有安全漏洞" |
| **视角** | 技术一致性（工程师视角） | 对抗性审查（批评者视角） | 安全扫描（审计者视角） |
| **输入** | `architecture.xml`, `INTERFACE_CONTRACT.md` | `PRD.md`, `architecture.xml`, `DECISION_LOG` | `architecture.xml`, 代码, 依赖 |
| **检查项** | XML Schema 合规、接口一致性、PRD 可追溯性 | 安全、可运维性、可扩展性 | 漏洞、密钥泄露、合规性 |
| **输出** | `VALIDATION_REPORT.md`（PASS/FAIL） | `DESIGN_REVIEW.md`（问题清单，无 PASS/FAIL） | `SECURITY_AUDIT_REPORT.md`（风险等级） |
| **结果** | 失败必须修复才能继续 | 问题可接受、延期或修复 | 严重问题必须修复才能部署 |
| **类比** | **编译器类型检查** | **代码审查** | **安全渗透测试** |

**核心原则**：三者互补，不可互相替代。
- Validation 通过 ≠ 设计没有缺陷（可能 design-review 会发现问题）
- Design-review 没问题 ≠ 设计安全（可能 security-audit 会发现漏洞）
- 三个都通过了，才能有信心进入实现阶段

---

## 七、VCMF 五原则在 Architecture Validation 中的体现

| VCMF 原则 | 在 Architecture Validation 中的体现 |
|-----------|--------------------------------------|
| **Design as Contract** | Step 3 验证 XML 模块可追溯回 PRD 需求；禁止孤儿模块；VALIDATION_REPORT 对每个模块给出 PASS/FAIL 判定 |
| **Interface as Boundary** | Step 2 验证 XML `Coupling` 与 `INTERFACE_CONTRACT.md` 完全匹配；Step 5 验证输出模式匹配下游输入模式 |
| **Reality as Baseline** | Step 6 真实 LLM 验证确保架构中的语义假设成立；Step 7 追踪日志明确标注 `[SIMULATED]` vs `[REAL]`；Step 10 自验证防止模拟结果被误读 |
| **State as Responsibility** | Step 5 验证 `StateModel` 生命周期定义的内部一致性；health-check.sh 检查 `State` 节点是否包含必需的 `location`, `owner`, `lifecycle` 属性 |
| **XML as Authority** | 验证的核心对象是 `architecture.xml`；检查 XML well-formedness、schema compliance、cross-reference integrity；health-check.sh 验证所有 `ref` 属性指向的文件真实存在 |

---

## 八、与其他技能的协作边界

### 与 `devforge-architecture-design`（上游）的关系

```
architecture-design 输出 ──→ architecture-validation 输入
    architecture.xml              →  被验证的核心对象
    INTERFACE_CONTRACT.md         →  一致性检查基准
    PRD.md（传递）                 →  可追溯性检查基准
    ARCHITECTURE.md               →  Mock 数据来源
```

### 与 `devforge-design-review`（并行 3b）的关系

```
architecture-validation 通过后 ──→ 可选择进入 design-review
    VALIDATION_REPORT.md          →  design-review 的参考输入之一
                                    （design-review 会读所有历史产物）
```

### 与 `devforge-project-scaffolding`（下游）的关系

```
architecture-validation [APPROVE] ──→ 可进入 project-scaffolding
                                    （如果用户选择 [SKIP_REVIEW]）
    或 design-review [APPROVE]    ──→ 再进入 project-scaffolding
                                    （默认流程）
```

### 与 `devforge-iteration-planning`（循环回）的关系

```
iteration-planning（迭代后）──→ 可能触发重新验证
    如果迭代引入 breaking changes → STATE.md NextAction = iterate
                                 → 提示用户运行 [VALIDATE]
                                 → 生成新的 VALIDATION_DELTA 对比
```

---

## 九、总结

`devforge-architecture-validation` 是 DevForge 链条中承上启下的**技术守门员**。它的核心价值在于：

1. **技术自洽性保证**：在投入昂贵的实现工作前，确保架构文档自身没有矛盾
2. **机器可验证**：通过 health-check.sh 将架构检查自动化、常态化
3. **增量视角**：VALIDATION_DELTA 让团队只关注"变化"，而非重复阅读完整报告
4. **优雅降级**：没有 API Key 也能运行核心检查，不因外部依赖阻塞流程
5. **严格但务实**：区分 Blocking 和 Non-blocking，在质量和进度之间取得平衡

它是 Triple Verification 的**第一道防线**——如同编译器的类型检查，在代码运行之前捕获类型错误；architecture-validation 在系统构建之前捕获架构不一致。

---

> 生成日期：2026-05-12
> 基于：DevForge SDLC Skill Chain v1.4
> 关联文档：devforge-requirement-analysis-详解.md（Stage 1）、devforge-architecture-design/SKILL.md（Stage 2）
