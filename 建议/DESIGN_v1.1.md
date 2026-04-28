---
title: SDLC Skill Chain v1.1 Optimization Design
date: 2026-04-24
status: draft
---

# SDLC Skill Chain v1.1 优化设计方案

## 1. 架构模式扩展（Pattern Library）

### 1.1 当前状态
现有 6 种架构模式：Layered, Hexagonal, Event-Driven, Microservice, Client-Server, Plugin-Based。

### 1.2 新增模式
基于研究，新增 4 种高价值模式：

| 模式 | 适用场景 | 核心优势 | 关键风险 |
|------|---------|---------|---------|
| **CQRS** | 读写比例悬殊、高并发查询、复杂领域模型 | 读写独立扩展、查询侧可高度优化 | 最终一致性心智负担、复杂度溢出 |
| **BFF** | 多端应用（Web/Mobile/Third-party）、团队垂直分工 | 前端团队自治、按需聚合后端 | BFF 间重复代码、共享库引入耦合 |
| **Serverless/FaaS** | 事件驱动、弹性伸缩、低运维成本 | 自动扩缩容、按调用计费 | 冷启动延迟、Vendor Lock-in、调试困难 |
| **Micro-Frontends** | 大型前端应用、多团队并行交付、渐进式迁移 | 独立部署、技术栈异构、团队自治 | 包体积膨胀、运行时集成复杂度、全局样式隔离 |

### 1.3 动态模式筛选机制

**问题**：10 种模式全部并行评估会导致上下文爆炸。

**方案**：
1. 在 `sdlc-architecture-design` Step 1 中，从 PRD 提取**项目特征标签**：
   - `frontend_heavy` → 自动加入 Micro-Frontends, BFF
   - `high_read_write_ratio` → 自动加入 CQRS
   - `event_driven` → 自动加入 Event-Driven, Serverless
   - `multi_tenant` → 自动加入 Microservice, Hexagonal
   - `team_autonomy` → 自动加入 Microservice, Micro-Frontends, BFF
2. 基于标签从模式库中动态选择 **4-6 种最相关模式**进行并行评估
3. 将完整模式库存储在 `skill/references/architecture-patterns.md` 中（参考文件，按需加载）

### 1.4 实施文件
- 修改 `sdlc-architecture-design/SKILL.md`：Step 1 增加特征标签提取和动态筛选逻辑
- 新建 `skill/references/architecture-patterns.md`：10 种模式的完整评估维度、评分标准、风险清单

---

## 2. 增量迭代模型（Iteration Support）

### 2.1 设计目标
- 第一版完成**系统级框架**（足够完善、无需后续更改基础结构）
- 后续在框架基础上**增量添加模块和功能**
- 每个模块有自己的细化 PRD 和架构文档
- 新增需求时只做**增量分析**，不推翻已有架构

### 2.2 新增 Skill：`sdlc-module-design`（模块级设计）

**触发条件**：`phase: architecture_design_completed` 且用户输入 `[MODULE {module_id}]`

**输入**：
- 系统级 `PRD.md` 中该模块的责任范围
- 系统级 `architecture.xml` 中该模块的接口契约
- 系统级 `INTERFACE_CONTRACT.md` 中该模块的边界定义

**输出**（位于 `skill/artifacts/modules/{module_id}/`）：
- `module-prd.md`：模块级需求（User Stories、AC、优先级 P0/P1/P2）
- `module-architecture.xml`：模块内部组件划分、组件接口、模块内状态
- `module-interface-contract.md`：组件间接口契约
- `module-design-review.md`（可选）：模块级审查

**工作流程**：
1. 读取父级产物，锁定该模块的边界约束
2. 基于父级 PRD 中涉及该模块的 user stories，拆解为模块级 user stories
3. 设计模块内部组件（3-5 个 skill 评估的简化版，只做单模块内架构）
4. 生成分级 XML（见第 4 节）
5. 人类门控："模块 `{module_id}` 的详细设计已生成。回复 [APPROVE] 进入该模块的脚手架阶段，或提出修改意见。"

### 2.3 新增 Skill：`sdlc-iteration-planning`（迭代规划）

**触发条件**：`phase: scaffolding_completed` 或 `phase: iteration_N_completed`，且用户提出新需求

**输入**：
- 全部历史产物（PRD, ARCHITECTURE, XML, INTERFACE_CONTRACT）
- 用户的新增需求描述

**工作流程**：
1. **影响范围分析**：读取现有 `architecture.xml`，标记新增需求影响的模块（新增 / 修改 / 无影响）
2. **增量 PRD**：只编写新增/变更的 user stories，标注与现有 PRD 的关联（`relates_to: US-001`）
3. **增量架构设计**：
   - 新增模块：走完整 `sdlc-architecture-design` 流程（但只评估该模块内架构）
   - 修改模块：更新对应 `module-architecture.xml`，保持已有模块不变
   - 接口变更：更新 `INTERFACE_CONTRACT.md`，标注版本变更（`v1.0 → v1.1`）
4. **XML 同步**：自动将系统级变更传播到对应的模块级 XML（见第 4.4 节）
5. **迭代计划生成**：输出 `ITERATION_PLAN.md`，包含：
   - 本次迭代目标
   - 涉及的模块清单
   - 每个模块需要的 skill 流程（设计/审查/脚手架）
   - 人类门控点

### 2.4 STATE.md 状态机扩展

```yaml
# phase 枚举扩展
phase:
  - requirement_analysis_completed
  - architecture_design_completed
  - architecture_validated
  - design_review_completed
  - scaffolding_completed
  - module_design_completed        # 新增：至少一个模块完成详细设计
  - iteration_planning_completed   # 新增：迭代计划已批准
  - evolution_completed            # 新增：单次演进完成

# DIVE 循环扩展
dive:
  Design: completed | in_progress
  Implement: completed | in_progress
  Verify: completed | in_progress
  Evolve: completed | in_progress | pending
  NextAction: iterate | refactor | module | none  # 新增：Evolve 后的分支选择

# 新增字段
module_registry:  # 已完成的模块列表
  - id: UserService
    status: scaffolded
    path: modules/UserService/
  - id: OrderService
    status: design_completed
    path: modules/OrderService/

iteration_history:  # 迭代历史
  - iteration: 1
    date: 2026-04-24
    scope: "Initial scaffolding"
  - iteration: 2
    date: 2026-05-01
    scope: "Add payment module"
```

---

## 3. 工程基础设施（DevOps & Tooling）

### 3.1 版本控制深度集成

**目标**：让架构产物成为代码仓库的一级公民，而非 session 临时文件。

**实施方案**：
1. **产物输出路径变更**：
   - 系统级产物 → `docs/architecture/system/`
   - 模块级产物 → `docs/architecture/modules/{module_id}/`
   - 决策日志 → `docs/architecture/DECISION_LOG.md`
   - 所有产物纳入 Git 版本控制

2. **Git 友好配置**：
   - 生成 `.gitattributes`：标记 `*.xml` 为 `diff=text`，确保合并时可读
   - 生成 `docs/architecture/.gitignore`：排除临时验证报告，保留核心产物

3. **同步规则**（`docs/architecture/sync-rules.md`）：
   ```markdown
   | 代码变更类型 | 必须同步的文档 |
   |-------------|---------------|
   | 新增/删除模块目录 | `architecture.xml` + `module-registry` |
   | 修改函数签名 | `INTERFACE_CONTRACT.md` + 对应 `module-interface-contract.md` |
   | 变更状态存储位置 | `architecture.xml` 中 `<StateModel>` |
   | 新增错误码 | `INTERFACE_CONTRACT.md` + XML `<Interface>` |
   ```

4. **Commit Message 规范**：
   - 在 `sdlc-project-scaffolding` 中生成 `docs/architecture/commit-convention.md`
   - 要求架构变更的 commit 引用 Decision ID（如 `arch-dec-0042: migrate auth to BFF pattern`）

### 3.2 自动化验证能力

**目标**：将 `sdlc-architecture-validation` 从一次性 session 活动升级为持续运行的 CI 检查。

**实施方案**：
1. **升级验证脚本**：
   - 将 `health-check.sh` 升级为 `scripts/architecture-ci.sh`
   - 新增检查项：
     - XML 引用完整性（所有 `ref="..."` 指向的文件存在）
     - 接口签名一致性（代码中的函数签名 vs XML 中的 `<Signature>`）
     - 模块覆盖率（`architecture.xml` 中的每个 `<Module>` 都有对应的代码目录）

2. **增量验证报告**：
   - 新增 `VALIDATION_DELTA.md`（增量验证报告）
   - 只报告与上次验证相比的新增问题
   - 存储在 `docs/architecture/validation/` 下，按日期版本化

3. **CI/CD 集成**：
   - 在 `sdlc-project-scaffolding` 生成的 CI 配置中，增加 architecture-check job：
     ```yaml
     architecture-check:
       steps:
         - run: ./scripts/architecture-ci.sh
         - run: ./scripts/xml-sync.py --verify-only
     ```

### 3.3 领域特化 Skill 子链（Domain Extensions）

**目标**：让通用 SDLC skill 链能够挂载领域专用知识。

**实施方案**：
1. **目录结构**：
   ```
   skill/
   ├── sdlc-requirement-analysis/
   ├── sdlc-architecture-design/
   ├── ...（核心链）
   └── extensions/
       ├── ai-agent-design/
       │   ├── SKILL.md
       │   └── references/
       │       ├── tool-use-patterns.md
       │       └── memory-management.md
       ├── data-pipeline-design/
       │   ├── SKILL.md
       │   └── references/
       │       ├── schema-evolution.md
       │       └── idempotency-patterns.md
       └── mobile-app-design/
           ├── SKILL.md
           └── references/
               ├── offline-first.md
               └── push-notification.md
   ```

2. **动态加载机制**：
   - 在 `sdlc-requirement-analysis` 阶段，从 PRD 提取领域标签（`domain: ai-agent`）
   - 在 `sdlc-architecture-design` 阶段，如果存在匹配的领域扩展，自动加载其参考文件
   - 扩展 skill 不替代通用 skill，而是**覆盖（overlay）**特定步骤的评估维度
   - 例如：AI Agent 扩展会在架构评估时增加 "Tool Selection Latency"、"Memory Context Window" 等维度

3. **扩展接口规范**：
   - 每个扩展必须提供 `dimensions.md`：新增评估维度及其权重
   - 每个扩展必须提供 `anti-patterns.md`：该领域常见架构反模式

### 3.4 信息压缩与摘要机制

**目标**：解决跨 session 恢复时的上下文爆炸问题。

**实施方案**：
1. **STATE.md 新增 `Compressed Context` 字段**：
   ```markdown
   ## Compressed Context
   **Project**: AI Legal Assistant v1.0
   **Pattern**: Microservices + BFF
   **Key Decisions**: [arch-dec-0001] Use Hexagonal for core domain; [arch-dec-0002] BFF for mobile/web
   **Known Pitfalls**: Auth service is SPOF; Redis session TTL not defined
   **Module Registry**: UserService(scaffolded), CaseService(design), PaymentService(pending)
   ```

2. **新增内部工具：`context-compression`**（非用户-facing skill，由其他 skill 调用）：
   - 在每个 skill 执行完毕后，自动提取 200 字决策摘要
   - 摘要格式：`[DecisionID]: [What] → [Why] → [Risk]`
   - 存储在 `STATE.md` 的 `DecisionDigest` 列表中

3. **Session 恢复优化**：
   - 新 session 启动时，优先读取 `STATE.md` 的 `Immutable Goal` + `Compressed Context`
   - 只有当用户询问细节时，才按需读取完整产物文件
   - 在 `STATE.md` 中维护 `Artifact Index`，标注每个产物的最后修改时间和摘要

---

## 4. XML 分层架构（Hierarchical Architecture Description）

### 4.1 核心设计原则

用户核心诉求：**所有代码开发围绕 XML 描述的功能进行**。

这意味着 XML 不是"文档"，而是**架构的权威描述（Single Source of Truth）**。

### 4.2 三层 XML 体系

```
system-architecture.xml          ← 系统级（已有，扩展）
├── modules/
│   ├── UserService/
│   │   └── module-architecture.xml   ← 模块级（新增）
│   │       └── components/
│   │           ├── AuthController/
│   │           │   └── component-spec.xml  ← 组件级（新增）
│   │           └── UserRepository/
│   │               └── component-spec.xml
│   └── OrderService/
│       └── module-architecture.xml
└── shared/
    └── common-types.xml         ← 共享类型定义
```

### 4.3 XML Schema 定义

#### 4.3.1 System Level（`architecture.xml` 扩展）

```xml
<?xml version="1.0" encoding="UTF-8"?>
<SystemArchitecture type="microservice" version="1.0.0">
  <DecisionTrace>
    <Decision id="arch-dec-0001" date="2026-04-24">
      <Question>Which pattern for service boundary?</Question>
      <Answer>Microservice with BFF for mobile</Answer>
      <Risk>Network latency between services</Risk>
    </Decision>
  </DecisionTrace>

  <Module id="UserService" owner="team-auth">
    <Responsibility>User registration, authentication, session management</Responsibility>
    <Interface>
      <Input schema="LoginRequest" protocol="HTTP/JSON"/>
      <Output schema="AuthToken" protocol="HTTP/JSON"/>
      <ErrorCodes>
        <Error code="401" description="Invalid credentials"/>
        <Error code="429" description="Rate limit exceeded"/>
      </ErrorCodes>
    </Interface>
    <Coupling>
      <DependsOn module="Redis" reason="session storage"/>
      <DependsOn module="PostgreSQL" reason="user data"/>
    </Coupling>
    <!-- 新增：引用模块级 XML -->
    <ModuleDetail ref="modules/UserService/module-architecture.xml"/>
  </Module>

  <DataModel>
    <Entity id="User" module="UserService">
      <Fields>
        <Field name="id" type="UUID" nullable="false"/>
        <Field name="email" type="string" nullable="false" encrypted="true"/>
      </Fields>
      <CacheStrategy type="Redis" ttl="3600"/>
    </Entity>
  </DataModel>

  <StateModel>
    <State id="session" location="Redis" owner="UserService" consumer="BFF-Mobile, BFF-Web"
           lifecycle="create:on_login, read:on_request, update:on_refresh, delete:on_logout_or_timeout, cleanup:TTL_24h"/>
  </StateModel>

  <Security>
    <Authentication type="JWT" issuer="UserService" audience="all"/>
    <Encryption inTransit="TLS1.3" atRest="AES-256"/>
  </Security>
</SystemArchitecture>
```

#### 4.3.2 Module Level（新增：`module-architecture.xml`）

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ModuleArchitecture id="UserService" version="1.0.0">
  <ParentSystem ref="../../architecture.xml"/>

  <Constraints>
    <!-- 继承自系统级的约束，不可违反 -->
    <InterfaceConstraint>
      <Input schema="LoginRequest" must="true"/>
      <Output schema="AuthToken" must="true"/>
    </InterfaceConstraint>
  </Constraints>

  <Components>
    <Component id="AuthController">
      <Responsibility>Handle HTTP authentication requests</Responsibility>
      <Type>entry_point</Type>
      <Input schema="LoginRequest"/>
      <Output schema="AuthToken"/>
      <!-- 引用组件级 XML -->
      <ComponentDetail ref="components/AuthController/component-spec.xml"/>
    </Component>

    <Component id="AuthService">
      <Responsibility>Core authentication logic</Responsibility>
      <Type>domain_service</Type>
      <Dependencies>
        <Dependency component="UserRepository"/>
        <Dependency component="TokenGenerator"/>
      </Dependencies>
    </Component>

    <Component id="UserRepository">
      <Responsibility>Data access for User entity</Responsibility>
      <Type>repository</Type>
    </Component>

    <Component id="TokenGenerator">
      <Responsibility>JWT token generation and validation</Responsibility>
      <Type>utility</Type>
    </Component>
  </Components>

  <ComponentInterfaces>
    <Interface from="AuthController" to="AuthService">
      <Method name="authenticate" input="Credentials" output="UserPrincipal"/>
    </Interface>
    <Interface from="AuthService" to="UserRepository">
      <Method name="findByEmail" input="string" output="User"/>
    </Interface>
  </ComponentInterfaces>

  <ModuleStateModel>
    <State id="session_cache" location="Redis" owner="TokenGenerator" consumer="AuthController"
           lifecycle="create:on_login, read:on_request, delete:on_logout"/>
  </ModuleStateModel>
</ModuleArchitecture>
```

#### 4.3.3 Component Level（新增：`component-spec.xml`）

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ComponentSpec id="AuthController" version="1.0.0">
  <ParentModule ref="../module-architecture.xml"/>

  <Metadata>
    <Language>Python</Language>
    <Framework>FastAPI</Framework>
    <FilePath>src/user_service/controllers/auth_controller.py</FilePath>
  </Metadata>

  <Functions>
    <Function id="login" async="true" traceTo="US-001">
      <Signature><![CDATA[
async def login(
    request: LoginRequest,
    auth_service: AuthService = Depends(get_auth_service)
) -> AuthToken
      ]]></Signature>
      <Logic>
        <Step order="1" description="Validate request schema using Pydantic"/>
        <Step order="2" description="Call auth_service.authenticate(request.credentials)"/>
        <Step order="3" description="If valid, call token_generator.create_token(user)"/>
        <Step order="4" description="Return AuthToken with JWT"/>
      </Logic>
      <ErrorHandling>
        <Error code="401" condition="auth_service returns None" response="{\"error\": \"Invalid credentials\"}"/>
        <Error code="429" condition="rate_limiter.exceeded(client_ip)" response="{\"error\": \"Too many requests\"}"/>
        <Error code="500" condition="unexpected exception" response="{\"error\": \"Internal server error\"}" log="true"/>
      </ErrorHandling>
      <Tests>
        <Test id="TC-001" type="happy_path" description="Valid credentials return token"/>
        <Test id="TC-002" type="abnormal" description="Invalid credentials return 401"/>
        <Test id="TC-003" type="abnormal" description="Rate limit exceeded returns 429"/>
      </Tests>
    </Function>
  </Functions>

  <Dependencies>
    <Dependency id="AuthService" injection="constructor"/>
    <Dependency id="TokenGenerator" injection="constructor"/>
    <Dependency id="RateLimiter" injection="singleton"/>
  </Dependencies>

  <!-- 代码生成模板（可选） -->
  <CodeTemplate>
    <Header><![CDATA[
# Architecture Decision: arch-dec-0001
# Component: AuthController
# PRD Requirement: US-001
# Known Risk: Rate limiting must be configured per environment
    ]]></Header>
  </CodeTemplate>
</ComponentSpec>
```

### 4.4 XML 同步与变更传播机制

**依赖方向**：Component → Module → System（子级引用父级）

**变更传播规则**：

| 变更层级 | 变更内容 | 传播要求 |
|---------|---------|---------|
| System | 模块接口变更 | 强制更新对应 Module Level XML 的 Constraints |
| System | 模块职责变更 | 检查 Module Level Components 是否覆盖新职责 |
| Module | 组件接口变更 | 检查 System Level Interface 是否需要更新版本 |
| Module | 新增组件 | 生成新的 Component Level XML 模板 |
| Component | 函数签名变更 | 反向检查 Module Level Interface 兼容性 |
| Component | 新增错误码 | 反向检查 System Level ErrorCodes 完整性 |

**自动化同步脚本**（`scripts/xml-sync.py`）：

```python
# 伪代码
class XMLSync:
    def verify(self):
        """验证模式：只检查不修改"""
        # 1. 检查所有 ref 指向的文件存在
        # 2. 检查 System Interface 与 Module Constraints 一致
        # 3. 检查 Component Signature 与 Module Interface 兼容
        # 4. 生成验证报告

    def sync(self):
        """同步模式：自动传播变更"""
        # 1. 检测 System Level 变更
        # 2. 将变更传播到受影响的 Module Level
        # 3. 将 Module Level 变更传播到 Component Level
        # 4. 生成变更日志
```

**集成到 Skill 流程**：
- `sdlc-architecture-design` 生成 System Level XML 后，自动为每个 Module 生成 Module Level XML 模板
- `sdlc-module-design` 填充 Module Level XML，并为每个 Component 生成 Component Level XML 模板
- `sdlc-project-scaffolding` 读取 Component Level XML，生成与 `<Signature>` 和 `<ErrorHandling>` 匹配的代码骨架
- `sdlc-iteration-planning` 在增量需求分析后，调用 `xml-sync.py --sync` 自动传播变更

### 4.5 代码开发围绕 XML 的规范

**正向（XML → Code）**：
- 代码骨架必须从 Component Level XML 的 `<Functions>` 生成
- 函数签名必须与 `<Signature>` 完全一致（包括参数名、类型、顺序）
- 错误码处理必须覆盖 `<ErrorHandling>` 中定义的所有情况
- 文件路径必须与 `<Metadata>/<FilePath>` 一致

**反向（Code → XML）**：
- 如果开发者需要修改代码签名，必须先修改 XML
- CI 中的 `architecture-ci.sh` 会检查代码与 XML 的一致性
- 不一致时阻断构建，提示开发者更新 XML

---

## 5. 实施路线图

### Phase 1：基础设施（高优先级，无依赖）
1. 新建 `skill/references/architecture-patterns.md`（10 种模式完整规格）
2. 修改 `sdlc-architecture-design/SKILL.md`（增加动态模式筛选）
3. 修改 `sdlc-project-scaffolding/SKILL.md`（产物输出到 `docs/architecture/`）
4. 生成 `scripts/architecture-ci.sh` 和 `scripts/xml-sync.py`

### Phase 2：XML 分层（高优先级，依赖 Phase 1）
1. 定义 `module-architecture.xml` 和 `component-spec.xml` 的 Schema
2. 修改 `sdlc-architecture-design`：生成 System Level XML 时自动创建 Module Level 模板
3. 修改 `sdlc-project-scaffolding`：从 Component Level XML 生成代码骨架
4. 在 CI 中集成 XML 一致性检查

### Phase 3：增量迭代（中优先级，依赖 Phase 2）
1. 新建 `sdlc-module-design/SKILL.md`
2. 新建 `sdlc-iteration-planning/SKILL.md`
3. 扩展 `STATE.md` 模板（`module_registry`, `iteration_history`, `NextAction`）
4. 修改现有 skill 的 precondition check，支持迭代状态

### Phase 4：领域扩展与优化（低优先级，依赖 Phase 3）
1. 创建 `skill/extensions/` 目录结构
2. 实现 `ai-agent-design` 扩展（示例）
3. 实现信息压缩机制（`context-compression` 内部工具）
4. 实现自动化验证的增量报告（`VALIDATION_DELTA.md`）

---

## 6. 关键设计决策

| ID | 决策 | 备选方案 | 选择理由 |
|----|------|---------|---------|
| D001 | XML 分层三级（System/Module/Component） | 只有两级（System/Module） | 组件级是实现"代码围绕 XML 开发"的最小粒度，缺少它则无法驱动代码生成 |
| D002 | 动态模式筛选（4-6种）而非固定评估10种 | 始终评估全部10种 | 防止上下文爆炸，保持评估质量；参考文件保留全部模式供查阅 |
| D003 | 增量迭代时"只加不改"已有框架 | 允许修改已有架构 | 符合用户"搭好框架后只加东西"的核心诉求；通过 version 字段管理接口演进 |
| D004 | Module Level XML 由系统级自动创建模板 | 由 module-design skill 从头创建 | 确保 System → Module 的约束一致性，减少人工同步错误 |
| D005 | 领域扩展使用 overlay 机制 | 完全独立的 skill 链 | 保持核心链的通用性，同时允许领域知识注入特定步骤 |

---

*本设计方案基于 SDLC Skill Chain v1.0.1 的现有结构，通过扩展而非推翻的方式实现演进。*