# DevForge Module Design 深度解析

> 本文档基于 DevForge SDLC Skill Chain v1.4 的 `devforge-module-design` 技能定义（`SKILL.md`）进行深度分析。
>
> **定位**：Stage 5，属于 DIVE 工作流的 **Design（设计）+ Implement（实现）** 混合阶段。
> **核心目标**：将系统级架构中的单个模块，从"名字和职责"深化为"完整的组件分解、接口定义、代码骨架"。
> **关键约束**：严格在 scaffolding 之后；不发明系统级 PRD 之外的需求。

---

## 一、整体流程概览（12个步骤 + 并行批量模式）

### 标准流程（单模块模式）

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  Step 1: 加载父级上下文（Load Parent Context）                                  │
│       ↓                                                                     │
│  Step 2: 锁定模块边界（Lock Module Boundaries）                                │
│       ↓                                                                     │
│  Step 3: 模块级需求分析（Module-Level Requirement Analysis）                    │
│       ↓                                                                     │
│  Step 4: 组件分解（Component Decomposition）                                   │
│       ↓                                                                     │
│  Step 5: 组件接口设计（Component Interface Design）                             │
│       ↓                                                                     │
│  Step 6: 模块级 XML 建模（Module-Level XML Modeling）                           │
│       ↓                                                                     │
│  Step 7: 模块级测试用例设计（Module-Level Test Case Design）                     │
│       ↓                                                                     │
│  Step 7a: 测试代码生成（Test Code Generation）                                 │
│       ↓                                                                     │
│  Step 8: 组件代码骨架生成（Component Code Skeleton Generation）                 │
│       ↓                                                                     │
│       ├── 8a. 微服务产物生成（条件触发）                                       │
│       │      ├── gRPC proto                                                   │
│       │      ├── resilience.yaml                                              │
│       │      └── saga-{module_id}.yaml                                        │
│       │                                                                       │
│  Step 9: 模块文档（Module Documentation）                                      │
│       ↓                                                                     │
│  Step 10: 自验证 — 模块设计一致性（Self-Validation）                             │
│       ↓                                                                     │
│  Step 11: 状态更新（State Update）                                             │
│       ↓                                                                     │
│  Step 12: 人机关卡（Human Gate）                                               │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 并行批量模式（MODULE_BATCH）

```
[MODULE_BATCH {id1},{id2},...]
    │
    ├── 1. 耦合分析（Coupling Analysis）
    │       ├── 发现循环依赖 → 回退到串行模式
    │       └── 无循环依赖 → 继续并行
    │
    ├── 2. 并行分派（Parallel Dispatch）
    │       └── 每个模块一个子代理（Agent），同时执行
    │
    ├── 3. 结果收集（Result Collection）
    │       └── 验证每个模块的输出文件存在且非空
    │
    ├── 4. 一致性检查（Consistency Check）
    │       ├── 跨模块接口兼容性
    │       ├── 共享 StateModel 冲突
    │       └── 模块间依赖完整性
    │
    ├── 5. 冲突解决（Conflict Resolution）
    │       ├── 无冲突 → 批量更新 STATE.md
    │       └── 有冲突 → 呈现冲突矩阵 → [FIX] / [DEFER] / [ROLLBACK]
    │
    └── 6. 人机关卡（批量）
```

---

## 二、输入来源（上游产物）

| 输入文件 | 来源阶段 | 在 Module Design 中的用途 |
|---------|---------|------------------------|
| `PRD.md` | requirement-analysis | 系统级需求基准，模块级需求必须可追溯 |
| `architecture.xml` | architecture-design | 提取目标模块的系统级定义（职责、接口、耦合） |
| `INTERFACE_CONTRACT.md` | architecture-design | 系统级 I/O 边界约束 |
| `DECISION_LOG.md` | 全链条维护 | 理解架构决策的 reasoning chain |
| `STATE.md` | 全链条维护 | 模块注册表（已设计模块的状态） |
| `module-architecture.xml`（模板） | architecture-design | 在 scaffolding 时生成的模块级 XML 模板 |

---

## 三、每一步详解与调用的工具

### Step 1: 加载父级上下文（Load Parent Context）

#### 做什么？
读取系统级全部产物，识别目标 `module_id`（从用户输入如 `[MODULE UserService]` 提取）。

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Read` | 读取 `PRD.md`、`architecture.xml`、`INTERFACE_CONTRACT.md`、`DECISION_LOG.md`、`STATE.md` |

#### 为什么这样设计？
- **Single Thinker 模型**：module-design 不是"接手上一个技能的输出"，而是"同一个思考者从模块视角重新审视整个问题"
- **需要完整上下文**：模块级设计必须理解"这个模块在系统中扮演什么角色"，只看模块自己的定义是不够的

---

### Step 2: 锁定模块边界（Lock Module Boundaries）

#### 做什么？
从 `architecture.xml` 中提取目标模块的系统级定义：

| 提取项 | 说明 |
|--------|------|
| `Module/@id`, `Module/@owner` | 模块标识和负责团队 |
| `Module/Responsibility` | 模块职责描述 |
| `Module/Interface` | 所有输入/输出模式和错误码 |
| `Module/Coupling` | 所有依赖关系 |
| `Module/ModuleDetail/@ref` | 模块级 XML 模板路径 |

然后写入**边界约束**：模块的内部设计自由只能在系统级接口约束范围内。

#### 为什么这样设计？
- **契约不可侵犯**：系统级接口是模块对外的契约，module-design 只能在这个契约内发挥
- **防止范围蔓延**：module-design 不能发明新的系统级需求或接口
- **加载现有模板**：architecture-design 阶段已经生成了模块 XML 模板，module-design 在此基础上填充，而非从零创建

---

### Step 3: 模块级需求分析（Module-Level Requirement Analysis）

#### 做什么？
扫描系统 `PRD.md`，提取涉及该模块的所有用户故事、需求和验收标准：

| 活动 | 说明 |
|------|------|
| **系统级用户故事筛选** | 找出与该模块相关的所有系统级用户故事 |
| **模块级用户故事分解** | 每个系统级用户故事分解为 1-3 个模块级用户故事 |
| **优先级分级** | P0 / P1 / P2 |
| **验收标准定义** | 可观察和可测试的模块级验收标准 |
| **边缘场景识别** | 模块特有的边缘场景和降级策略 |

#### 为什么这样设计？
- **模块是"迷你系统"**：每个模块都需要自己的 PRD，描述它如何履行系统赋予它的职责
- **1:N 分解**：一个系统级用户故事通常涉及多个模块，每个模块只负责其中一部分
- **P0/P1/P2 延续**：系统级的优先级在模块级继续细分，指导后续代码骨架生成策略

---

### Step 4: 组件分解（Component Decomposition）

#### 做什么？
将模块分解为 3-6 个内部组件：

| 组件类型 | 职责 | 示例 |
|---------|------|------|
| `entry_point` | 控制器、处理器、API 端点 | REST API Controller、gRPC Handler |
| `domain_service` | 核心业务逻辑 | OrderService、PaymentProcessor |
| `repository` | 数据访问和持久化 | UserRepository、OrderDAO |
| `utility` | 横切辅助工具 | TokenGenerator、Validator |
| `gateway` | 外部服务客户端 | StripeGateway、EmailClient |

为每个组件定义：`id`、`type`、`responsibility`，并分配状态所有权。

#### 为什么这样设计？
- **分层架构原则**：entry_point → domain_service → repository 是典型的分层模式
- **状态所有权明确**：哪个组件是某个状态的主要写入者/读取者，必须在设计阶段确定（VCMF "State as Responsibility"）
- **3-6 个组件的范围**：太少说明分解不足，太多说明粒度太细——3-6 是经验上的最佳范围

---

### Step 5: 组件接口设计（Component Interface Design）

#### 做什么？
定义组件之间的显式接口：

| 接口属性 | 说明 |
|---------|------|
| **方法名** | 明确的动词+名词命名 |
| **输入模式（Input Schema）** | 精确的数据结构定义 |
| **输出模式（Output Schema）** | 精确的数据结构定义 |
| **错误码（Error Codes）** | 所有可能的错误场景 |

并确保接口方向不违反系统级 `Coupling` 约束。

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Write` | 生成 `module-interface-contract.md` |

#### 为什么这样设计？
- **Interface as Boundary 在组件级的体现**：组件之间的接口与模块之间的接口同等重要
- **防止循环依赖**：组件接口设计时就能发现 A→B→A 的循环，及时打破
- **为 component-spec.xml 做准备**：接口设计是 component-spec 的直接输入

---

### Step 6: 模块级 XML 建模（Module-Level XML Modeling）

#### 做什么？
填充模块级 XML 模板，生成三层 XML 架构中的第二层：

```xml
<ModuleArchitecture id="UserService" version="1.0.0">
  <ParentSystem ref="../../architecture.xml"/>
  <Constraints>
    <InterfaceConstraint>
      <Input schema="LoginRequest" must="true"/>
      <Output schema="AuthToken" must="true"/>
    </InterfaceConstraint>
  </Constraints>
  <Components>
    <Component id="AuthController" type="entry_point">
      <ComponentDetail ref="components/AuthController/component-spec.xml"/>
    </Component>
    <!-- ... -->
  </Components>
  <ComponentInterfaces>
    <!-- 组件间接口定义 -->
  </ComponentInterfaces>
  <ModuleStateModel>
    <!-- 模块级状态定义 -->
  </ModuleStateModel>
</ModuleArchitecture>
```

同时为每个组件生成第三层 XML：`component-spec.xml`

```xml
<ComponentSpec id="AuthController" version="1.0.0">
  <ParentModule ref="../module-architecture.xml"/>
  <Metadata>
    <Language>Python</Language>
    <Framework>FastAPI</Framework>
    <FilePath>src/modules/UserService/controllers/auth_controller.py</FilePath>
  </Metadata>
  <Functions>
    <!-- 函数签名、逻辑、错误处理 -->
  </Functions>
  <Dependencies>
    <!-- 依赖注入定义 -->
  </Dependencies>
</ComponentSpec>
```

#### 微服务特殊处理
当 `architecture.xml/@type="microservice"` 时，在 `component-spec.xml` 中增加 `Resilience` 节点：

```xml
<Resilience>
  <CircuitBreaker threshold="50%" window="10s" timeout="30s"/>
  <RateLimiter maxRequests="1000" window="1m"/>
  <Retry maxAttempts="3" backoff="exponential" initialDelay="100ms"/>
</Resilience>
```

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Read` | 读取 `xml-schemas.md`（模块级 schema 定义） |
| `Write` | 生成/填充 `module-architecture.xml` 和 `component-spec.xml` |

#### 为什么这样设计？
- **三层 XML 的完整性**：system → module → component，module-design 负责填充后两层
- **Constraints 继承**：模块级 `InterfaceConstraint` 必须从系统级 `Module/Interface` 复制，确保内部设计不违反对外契约
- **component-spec.xml 是代码生成的权威源**：后续代码骨架完全基于 component-spec 生成，实现 "XML as Authority"
- **微服务韧性模式**：断路器、限流、重试是微服务的标配，在 component-spec 中预定义确保一致实现

---

### Step 7: 模块级测试用例设计（Module-Level Test Case Design）

#### 做什么？
基于模块级用户故事和验收标准，设计测试用例：

| 测试类型 | 覆盖内容 |
|---------|---------|
| **Happy Path** | 正常流程的组件测试 |
| **Abnormal Path** | 无效输入、依赖故障、状态冲突 |
| **State Lifecycle** | create、read、update、delete、cleanup |

同时定义组件级测试的 Mock 数据结构。

#### 为什么这样设计？
- **测试驱动设计**：在设计阶段就定义测试用例，确保设计是可测试的
- **三层测试覆盖**：Happy + Abnormal + State Lifecycle 覆盖了功能、异常和数据三个维度
- **为 7a 测试代码生成做准备**：测试用例设计是测试代码的直接输入

---

### Step 7a: 测试代码生成（Test Code Generation）

#### 做什么？
读取 scaffolding 生成的 `tests/` 目录结构，为每个组件生成测试文件：

```python
# tests/mock/UserService/auth_controller_test.py

# Test: TC-UserService-AuthController-001
# Source: module-prd.md::Test Case Catalog::TC-001
# Component: component-spec.xml::AuthController

def test_login_happy_path():
    ...
```

如果 `tests/end_to_end/` 缺少模块相关的端到端测试，生成基础版本。

#### 为什么这样设计？
- **测试文件头注释的可追溯性**：每个测试函数都标明它对应 module-prd 中的哪个测试用例、component-spec 中的哪个组件
- **与 scaffolding 的衔接**：scaffolding 生成了测试框架，module-design 填充具体测试用例
- **Mock 测试优先**：`tests/mock/` 是日常开发的主力测试，不依赖外部服务

---

### Step 8: 组件代码骨架生成（Component Code Skeleton Generation）

#### 核心策略：P0/P1/P2 分级骨架

| 优先级 | 代码骨架策略 | 说明 |
|--------|-------------|------|
| **P0** | 完整的接口桩 + 最小可工作实现（非空函数体，返回合理默认值） | MVP 核心功能，必须能运行 |
| **P1** | 接口桩 + `raise NotImplementedError("P1: implement per module-prd")` | 重要但非核心，占位提示 |
| **P2** | 文件头注释 + 空函数/类定义 | 已识别但延期实现 |

#### 覆盖策略
- **覆盖 scaffolding 的 `__init__.py`**：scaffolding 只生成了 header comment，module-design 覆盖为完整骨架
- **手动修改保护**：如果检测到 `<!-- MANUAL -->` 或 `# MANUAL:` 标记，保留用户修改并追加新内容

#### 严格排序规则
> Step 8（代码骨架生成）**绝对不能**修改 Step 6（component-spec.xml）中定义的签名。
>
> 如果发现签名需要调整：
> 1. **不要**直接修改代码骨架
> 2. 先更新 `component-spec.xml`
> 3. 从更新后的 `component-spec.xml` 重新生成代码骨架
> 4. 确保 `component-spec.xml` 始终是权威源

#### 代码文件头注释
```python
# Module: {module_id}
# Component: {component_id}
# Priority: {P0/P1/P2}
# Source: component-spec.xml::{component_id}
# Status: {placeholder/minimal-implemented}
```

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Read` | 读取 `component-spec.xml` |
| `Write` | 生成代码骨架文件（覆盖 scaffolding 的 `__init__.py` 或创建新文件） |

#### 为什么这样设计？
- **P0/P1/P2 骨架策略是核心创新**：
  - P0 有最小实现 → 项目能跑起来（MVP 可用）
  - P1 有明确占位 → 开发者知道哪里需要补全
  - P2 只有空壳 → 不浪费精力在延期功能上
- **XML 权威源的强制执行**：代码骨架必须匹配 component-spec，不能反过来——这确保了"设计驱动实现"而非"实现驱动设计"
- **手动修改保护**：尊重人类开发者的修改，不覆盖人类的手动工作

---

### Step 8a: 微服务产物生成（Microservice Artifact Generation）

#### 触发条件
仅当 `architecture.xml/@type="microservice"` 时触发。

#### 生成的产物

| 产物 | 路径 | 说明 |
|------|------|------|
| **gRPC proto** | `grpc/{module_id}.proto` | 从 component-spec.xml 接口定义生成的 proto 文件 |
| **resilience.yaml** | `config/resilience.yaml` | 断路器、限流、重试配置 |
| **saga-{module_id}.yaml** | `config/saga-{module_id}.yaml` | Saga 状态机配置（如参与分布式事务） |

#### gRPC proto 生成示例
```protobuf
// grpc/UserService.proto
service UserService {
  rpc Login (LoginRequest) returns (AuthToken);
  // 错误码映射: 401 = Invalid credentials
}
```

#### resilience.yaml 示例
```yaml
resilience:
  circuit_breaker:
    failure_rate_threshold: 50
    slow_call_rate_threshold: 80
    wait_duration_in_open_state: 30s
  rate_limiter:
    limit_for_period: 1000
    limit_refresh_period: 1m
  retry:
    max_attempts: 3
    wait_duration: 100ms
    exponential_backoff_multiplier: 2
```

#### 为什么这样设计？
- **微服务基础设施标准化**：断路器、限流、重试是微服务的"御三家"，在 component-spec 中预定义确保每个服务都有统一的韧性策略
- **Saga 模式支持**：分布式事务是微服务的经典难题，预生成 Saga 配置降低实现复杂度
- **proto 从 spec 自动生成**：确保 gRPC 接口与 component-spec 完全一致，避免手动编写 proto 时的不一致

---

### Step 9: 模块文档（Module Documentation）

#### 做什么？
生成 `module-prd.md`，包含：

| 章节 | 内容 |
|------|------|
| 模块背景和范围 | 在系统上下文中的定位 |
| 模块级用户故事 | 带验收标准 |
| 功能需求 | P0/P1/P2 分级 |
| 非功能需求 | 性能、安全（模块相关部分） |
| 组件职责映射 | 哪个组件负责什么 |
| 测试用例目录 | 测试 ID 和描述 |
| Mock 数据定义 | 模块级测试数据 |

#### 为什么这样设计？
- **模块是"迷你系统"，需要自己的 PRD**：虽然范围比系统级 PRD 小，但结构完整
- **组件职责映射**：让开发者和审阅者快速理解"这个模块内部是怎么分工的"
- **测试用例目录**：作为测试代码的索引，方便查找

---

### Step 10: 自验证 — 模块设计一致性（Self-Validation）

#### 做什么？
执行 8 项自动检查：

| 检查 ID | 检查项 | 说明 |
|---------|--------|------|
| MD-SCHEMA | **Schema Compliance** | `module-architecture.xml` 包含所有必需节点：`ParentSystem`、`Constraints`、`Components`、`ComponentInterfaces`、`ModuleStateModel` |
| MD-SYS-HONOR | **System Interface Honor** | `Constraints/InterfaceConstraint` 匹配系统级 `Module/Interface`，标记任何缺失或偏离的 schema |
| MD-SPEC-COVER | **Component Spec Coverage** | 每个 `module-architecture.xml/Components` 中的组件都有对应的 `component-spec.xml` |
| MD-PRD-TRACE | **PRD Traceability** | 每个模块级用户故事引用至少一个系统级 PRD 需求或用户故事 ID |
| MD-STATE-LIFE | **State Lifecycle Completeness** | 每个 `ModuleStateModel/State` 都有 `location`、`owner`（组件 ID）、`consumer`（组件 IDs）、`lifecycle` |
| MD-NO-VAGUE | **Interface Explicitness** | `module-interface-contract.md` 中没有"returns data"或"handles errors"等模糊表述 |
| MD-CROSS-MOD | **Cross-Module Interface Compatibility** | 当前模块的系统级输出接口模式匹配所有下游模块的系统级输入接口模式 |
| MD-SKELETON | **Code Skeleton Compliance** | 代码签名匹配 `component-spec.xml`；所有错误处理条目有对应代码；文件路径匹配 `Metadata/FilePath` |

**如果任何检查失败，修复模块产物后再继续。**

#### 为什么这样设计？
- **最严格的自验证**：module-design 的自验证是 DevForge 链条中最全面的，因为它跨越了设计→实现边界
- **Cross-Module Interface Compatibility 是关键**：模块不是孤岛，它的输出是其他模块的输入——这个检查防止"各自设计、集成时才发现不匹配"
- **8 项检查覆盖 VCMF 全部五原则**：每个原则都有对应的检查项

---

### Step 11: 状态更新（State Update）

#### 做什么？
更新 `STATE.md`：

1. **Completed Steps 追加**：
   ```
   [YYYY-MM-DD HH:MM] devforge-module-design: 
   Designed module [module_id]. Components: [list]. Key decisions: [summary]
   ```
2. **Module Registry 更新**：
   ```yaml
   - id: UserService
     status: design_completed
     path: PROJECT_SCAFFOLD/docs/architecture/modules/UserService/
     digest: "Auth domain: JWT + RBAC, 3 components, 8 interfaces"
   ```
3. **Known Pitfalls 追加**：模块特有的风险
4. **INDEX.md 更新**：添加模块行，链接到生成的产物

#### 为什么这样设计？
- **Module Registry 的 digest 字段**：50 字以内的微摘要，供后续会话快速恢复上下文
- **状态判断**：如果所有模块都 design_completed，则设置 `phase: module_design_completed`
- **INDEX.md 实时更新**：保持文档索引的完整性

---

### Step 12: 人机关卡（Human Gate）

#### 做什么？
1. 展示模块设计摘要（组件列表、接口数量、测试用例数量）
2. 告知："模块 `{module_id}` 的详细设计已生成，包含模块级 PRD、组件分解、接口契约、XML 模型和精确代码骨架。"
3. 列出可用命令

#### 可用命令

| 命令 | 作用 |
|------|------|
| `[APPROVE]` | 批准并继续（进入该模块的测试执行阶段） |
| `[NEXT MODULE]` | 设计下一个模块 |
| `[PAUSE]` | 暂停当前阶段，保留上下文 |
| `[ROLLBACK {step_id}]` | 回滚到指定步骤重新执行 |
| `[EDIT {file_path}]` | 手动编辑文件后让 AI 继续 |
| `[INJECT {context}]` | 补充额外上下文约束 |
| `[SKIP]` | 跳过当前可选步骤 |
| `[EXPLAIN {TraceID}]` | 展开解释某个决策/错误的推理链 |

#### 关键约束：HARD-GATE
```markdown
<HARD-GATE>
Do NOT mark the module design as complete or allow transition to test-execution 
until the user replies [APPROVE] or explicitly asks to continue.
</HARD-GATE>
```

---

## 四、并行批量模式（Parallel Batch Mode）详解

### 触发方式
用户输入 `[MODULE_BATCH {id1},{id2},...]`

### 核心流程

#### 1. 耦合分析（Coupling Analysis）
- 读取 `architecture.xml`，分析模块间的 `Coupling` 关系
- **如果发现循环依赖**：回退到串行模式，警告用户

#### 2. 并行分派（Parallel Dispatch）
- 为每个模块构造独立的子代理（subagent）prompt，包含：
  - 该模块的系统级定义
  - 完整的父级上下文（PRD、契约、决策、状态）
  - 完整的 12 步 workflow（限定在该模块范围内）
  - 边界约束：遵守系统级接口，不发明范围外的新需求
- 使用原生 `Agent` 工具**并行分派**所有子代理（一次消息中发送多个 Agent 调用）
- 子代理**没有人机关卡**，直接运行到完成

#### 3. 结果收集（Result Collection）
- 读取所有生成的 `module-architecture.xml`
- 读取所有生成的 `module-interface-contract.md`
- 读取所有生成的 `component-spec.xml`
- 验证文件存在且非空

#### 4. 一致性检查（Consistency Check）

| 检查项 | 说明 |
|--------|------|
| **跨模块接口兼容性** | 模块 A 的系统级输出模式是否匹配模块 B 的系统级输入模式 |
| **共享 StateModel 冲突** | 相同 `id` 的状态在不同模块中定义是否一致 |
| **模块间依赖完整性** | 每个 `DependsOn` 目标是否有对应的模块设计完成 |

#### 5. 冲突解决（Conflict Resolution）

**无冲突**：批量更新 `STATE.md`，进入人机关卡。

**有冲突**：呈现冲突矩阵，进入协调模式：

```
| Conflict ID | Type | Module A | Module B | Description | Severity |
|-------------|------|----------|----------|-------------|----------|
| C-001 | interface_mismatch | OrderService | InventoryService | Output schema ≠ Input schema | blocking |
```

用户选择：
- `[FIX {conflict_id}]` → 进入修复子模式
- `[DEFER {conflict_id}]` → 标记为已知问题，继续
- `[ROLLBACK]` → 回退到串行模式，重新设计受影响模块

**修复子模式**：
1. 读取两个模块的产物
2. 生成修复方案（如更新接口模式、重命名状态条目）
3. 写入 `DESIGN_REVIEW_FIX_{conflict_id}.md`
4. 用户选择 `[APPLY]` / `[EDIT]` / `[IGNORE]`
5. 所有阻塞性冲突解决后，重新运行一致性检查

#### 6. 人机关卡（批量）
- 展示："已并行完成 {N} 个模块的详细设计"
- 列出每个模块的组件数和状态
- 如解决了冲突，注明："已解决 {M} 处跨模块冲突"

### 为什么设计并行批量模式？

- **效率提升**：设计 10 个模块串行需要 10 轮交互，并行只需 1 轮
- **子代理无人机关卡**：并行分派的子代理直接运行到完成，不在中间停顿——因为冲突检测和解决在收集阶段统一处理
- **冲突检测后置**：先让每个模块独立设计，再检查模块间的一致性——这是"先分后合"的策略
- **优雅降级**：如果平台不支持并行 Agent 或发现循环依赖，自动回退到串行模式

---

## 五、核心输出产物清单

| 产物 | 路径 | 作用 | 下游消费者 |
|------|------|------|-----------|
| **module-prd.md** | `docs/architecture/modules/{id}/module-prd.md` | 模块级 PRD | test-execution（测试用例来源） |
| **module-architecture.xml** | `docs/architecture/modules/{id}/module-architecture.xml` | 模块级 XML（三层架构第二层） | architecture-validation（迭代时验证） |
| **module-interface-contract.md** | `docs/architecture/modules/{id}/module-interface-contract.md` | 组件间接口契约 | module-design（自身参考）、debug-assistant |
| **component-spec.xml** | `docs/architecture/modules/{id}/components/{cid}/component-spec.xml` | 组件规格（三层架构第三层） | **代码生成的权威源**；test-execution（测试断言基准） |
| **测试代码** | `tests/mock/{id}/{cid}_test.*` | 组件级测试文件 | test-execution |
| **代码骨架** | `src/modules/{id}/...` | 精确代码骨架（P0/P1/P2 分级） | 开发者（填充业务逻辑） |
| **gRPC proto**（微服务） | `grpc/{id}.proto` | gRPC 接口定义 | protobuf 编译器 |
| **resilience.yaml**（微服务） | `config/resilience.yaml` | 韧性策略配置 | 微服务框架（如 Resilience4j） |
| **saga-{id}.yaml**（微服务） | `config/saga-{id}.yaml` | Saga 状态机配置 | Saga 编排器 |

---

## 六、流程设计哲学深度解析

### 1. 为什么 module-design 必须在 scaffolding 之后？

这是 v1.3 引入的**严格前置条件**：

| 阶段 | 生成内容 | 为什么必须有序 |
|------|---------|--------------|
| **scaffolding** | 目录结构、CI/CD、测试框架、`.env.template` | 基础设施是业务代码的容器 |
| **module-design** | 组件分解、代码骨架、测试用例 | 业务代码需要运行在基础设施之上 |

**反面场景**：如果 module-design 在 scaffolding 之前：
- module-design 生成了 `src/modules/UserService/controllers/auth_controller.py`
- scaffolding 随后生成目录结构，可能覆盖或冲突
- 或者 scaffolding 不知道 module-design 生成了哪些文件，INDEX.md 不完整

### 2. 为什么 component-spec.xml 是代码生成的权威源？

**严格排序规则**的核心设计：

```
component-spec.xml ──→ 代码骨架
      ↑                    ↓
   修改签名            绝不反向修改
      │                    │
      └── 需要调整签名？ ───┘
            → 先改 component-spec.xml
            → 再从 spec 重新生成代码
```

**原因**：
- **防止"实现驱动设计"**：如果允许代码骨架直接修改签名，开发者会逐渐忘记 component-spec 的存在
- **XML as Authority**：component-spec 是权威源，代码是它的派生产物
- **CI 一致性检查的基础**：architecture-ci.sh 检查代码签名是否与 component-spec 一致——如果代码可以独立修改，这个检查就失效了

### 3. 为什么 P0/P1/P2 骨架策略如此设计？

| 优先级 | 骨架内容 | 目的 |
|--------|---------|------|
| **P0** | 完整接口 + 最小可工作实现 | MVP 必须能运行，不能只是空壳 |
| **P1** | 完整接口 + `NotImplementedError` | 接口已定义，实现可延期；明确的占位提示 |
| **P2** | 空函数/类定义 | 已识别需求，但当前迭代不实现；不浪费精力 |

**场景示例**：
- P0 `AuthController.login()` → 返回 mock token（能跑通登录流程）
- P1 `AuthController.refresh_token()` → `raise NotImplementedError("P1: implement per module-prd")`
- P2 `AuthController.oauth_login()` → `def oauth_login(): pass`

这种策略让项目在任何时刻都是**可运行的**（P0 能工作），同时清晰地标记了**待实现项**（P1/P2）。

### 4. 为什么 Cross-Module Interface Compatibility 检查在 module-design 中？

**问题场景**：
- Module A（OrderService）定义输出：`OrderCreatedEvent { orderId, totalAmount }`
- Module B（InventoryService）期望输入：`OrderCreatedEvent { orderId, items[] }`
- 各自设计时都没问题，但集成时发现不匹配

**module-design 中的检查**：
- 设计 OrderService 时，检查它的输出是否匹配所有下游模块（Coupling/DependsOn）的输入
- 设计 InventoryService 时，检查它的输入是否匹配所有上游模块的输出
- **在编码之前捕获接口不匹配**

### 5. 为什么并行批量模式需要冲突解决机制？

**并行的代价**：多个模块同时设计，各自独立决策，可能产生不一致。

**冲突类型**：

| 冲突类型 | 示例 | 解决策略 |
|---------|------|---------|
| **接口不匹配** | A 输出 `{id}`，B 期望 `{userId}` | 统一字段名 |
| **状态定义冲突** | A 和 B 都定义了 `Session` 状态，但属性不同 | 统一状态定义或拆分命名 |
| **依赖不完整** | A 依赖 B，但 B 尚未设计 | 标记为阻塞，等待 B 设计完成 |

**协调模式的价值**：
- 先并行（效率），后协调（一致性）
- 冲突矩阵让人类决策者一目了然
- `[FIX]` / `[DEFER]` / `[ROLLBACK]` 三种选择适应不同场景

---

## 七、与 DIVE 工作流的关系

```
Design                          Implement                    Verify
   │                               │                           │
   ├── requirement-analysis        │                           │
   ├── architecture-design         │                           │
   │                               │                           │
   │     [APPROVE]                 │                           │
   │                               │                           │
   ├── architecture-validation     │                           │
   ├── design-review               │                           │
   │                               │                           │
   │     [APPROVE]                 ↓                           │
   │                          scaffolding                      │
   │                          (基础设施)                       │
   │                               │                           │
   │     [APPROVE]                 ↓                           │
   │                          ┌──────────┐                     │
   │                          │ module-  │ ← 你在这里           │
   │                          │ design   │   (业务逻辑设计+骨架) │
   │                          │ (模块级)  │                     │
   │                          └──────────┘                     │
   │                               │                           │
   │     [APPROVE]                 ↓                           ↓
   │                          test-execution ←───────────────┘
   │                                                       │
   │                                                  [APPROVE/DEBUG]
   │                                                       │
   └───────────────────────────────────────────────────────┘
                             iteration-planning (Evolve)
```

Module-design 是 **Design 阶段的最后一环**，同时也是 **Implement 阶段的起点**——它完成了设计的细化，并生成了可编译的代码骨架。

---

## 八、VCMF 五原则在 Module Design 中的体现

| VCMF 原则 | 在 Module Design 中的体现 |
|-----------|--------------------------|
| **Design as Contract** | 模块级用户故事必须引用系统级 PRD；代码骨架必须追溯到 `component-spec.xml`；Step 10 的 PRD Traceability 检查强制执行 |
| **Interface as Boundary** | `module-interface-contract.md` 定义所有组件间接口；Cross-Module Interface Compatibility 检查确保模块间接口匹配；`Constraints/InterfaceConstraint` 继承系统级接口 |
| **Reality as Baseline** | 模块级测试用例覆盖 happy path、abnormal path 和 state lifecycle；P0 组件有最小可工作实现（能运行）；验收标准可观察和可测试 |
| **State as Responsibility** | `ModuleStateModel` 明确每个状态的 location、owner（组件 ID）、consumer（组件 IDs）、lifecycle；组件分解时分配状态所有权 |
| **XML as Authority** | `component-spec.xml` 是代码生成的唯一权威源；严格排序规则禁止代码骨架反向修改签名；CI 检查代码与 component-spec 的一致性；三层 XML（system → module → component）的完整性 |

---

## 九、与其他技能的协作边界

### 与 `devforge-project-scaffolding`（上游）的关系

```
scaffolding (4) ──→ module-design (5)
    目录结构已就绪         填充组件、接口、代码骨架
    __init__.py (header)   覆盖为完整骨架
    tests/ 框架已就绪       生成具体测试用例
    CI/CD 已配置           运行自验证时使用
```

**严格前置条件**：`scaffolding_completed` 是 module-design 的必需前置条件。

### 与 `devforge-test-execution`（下游）的关系

```
module-design (5) ──→ test-execution (6)
    module-prd.md         → 测试用例来源
    component-spec.xml    → 测试断言基准（验证代码行为是否符合 spec）
    代码骨架              → 被测试的对象
    tests/mock/...        → 具体测试文件
```

### 与 `devforge-architecture-design`（上游源头）的关系

```
architecture-design (2) ──→ module-design (5)
    architecture.xml      → 系统级模块定义（边界约束）
    module-architecture.xml 模板 → 被填充为完整模块设计
```

### 与 `devforge-iteration-planning`（循环回）的关系

```
iteration-planning (7) ──→ 新增/修改模块 ──→ 重新运行 module-design
    增量 PRD                  基于已有设计继续
```

---

## 十、总结

`devforge-module-design` 是 DevForge 链条中**最关键的实现阶段**。它的核心价值在于：

1. **"迷你系统"方法论**：将每个模块视为独立的子系统，执行完整的需求→设计→实现流程
2. **三层 XML 的填充者**：完成 system → module → component 三层架构中后两层的权威定义
3. **P0/P1/P2 骨架策略**：让项目在任何时刻都是可运行的，同时清晰标记待实现项
4. **XML 权威源的严格 enforce**：代码骨架必须匹配 component-spec，不能反向修改
5. **跨模块一致性检查**：在编码之前捕获模块间接口不匹配
6. **并行批量模式**：通过子代理并行加速多模块设计，通过冲突解决保证一致性

它是 DIVE 工作流中 **Design 的收官之作** 和 **Implement 的开篇之笔**——设计在此细化到可编译的代码，实现由此开始。

---

> 生成日期：2026-05-12
> 基于：DevForge SDLC Skill Chain v1.4
> 关联文档：devforge-project-scaffolding-详解.md（Stage 4）、devforge-test-execution/SKILL.md（Stage 6）
