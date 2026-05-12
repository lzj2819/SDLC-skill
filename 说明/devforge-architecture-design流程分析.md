# DevForge Architecture Design 流程深度分析

> 基于 DevForge SDLC Skill Chain v1.4 的 `devforge-architecture-design` SKILL.md 及其关联工具规范文档进行系统性分析。

---

## 一、触发条件与前置检查（Precondition Check）

### 1.1 何时触发

| 场景 | 触发方式 |
|------|----------|
| 标准流程 | 用户在 `requirement-analysis` 阶段回复 `[APPROVE]` |
| 迭代回环 | 用户在 `iteration-planning` 阶段产生破坏性变更后重新进入设计 |
| 显式调用 | 用户直接输入 "帮我设计架构" 且 `PRD.md` 已存在并已批准 |

### 1.2 前置条件校验

根据 `skill/tools/precondition-checker.md`，该技能接受的阶段为：
- `requirement_analysis_completed`（需求分析已完成）
- `iteration_planning_completed`（迭代规划已完成，进入回环）
- `evolution_completed`（演化已完成）

**不满足条件时的行为**：
- 如果阶段早于 `requirement_analysis_completed` → 停止执行，提示用户先完成 `devforge-requirement-analysis`
- 如果 `PRD.md` 不存在或未批准 → 停止执行，提示用户先完成需求分析

### 1.3 为什么设计这个检查

> **设计意图**：确保架构设计有明确的输入契约。没有 PRD 的架构设计必然会产生"虚构需求"（invented requirements），这是软件项目中最常见的设计失败模式。这个硬性检查强制要求先完成需求收敛，再进入架构展开。

---

## 二、完整工作流程（Workflow Steps）

该技能包含 **11 个核心步骤**，可归纳为 **四大阶段**：

```
阶段 I: 探索与决策（步骤 1-2）
  → 架构并行探索（Orchestrator-Worker 模式）
  → 模式选择 + 评分矩阵 + 推荐

阶段 II: 契约与状态（步骤 2-4）
  → 接口契约设计
  → 状态所有权映射
  → 测试用例设计

阶段 III: 模型与生成（步骤 5-7）
  → XML 三层架构建模
  → 数据库 DDL 生成
  → OpenAPI 规范生成

阶段 IV: 文档与沉淀（步骤 8-11）
  → 架构文档编写
  → 技术栈验证
  → 决策日志更新
  → 状态更新
  → 人工门控
```

---

### 步骤 1：架构并行探索（Parallel Exploration）

#### 1.1 读取输入

| 文件 | 用途 |
|------|------|
| `PRD.md` | 核心输入：功能需求、用户故事、NFR、跨模块交互 |
| `STATE.md` | 历史上下文：已完成步骤、已知风险、决策摘要 |
| `DECISION_LOG.md` | 需求分析阶段已记录的决策，避免重复决策 |
| `references/architecture-patterns.md` | 10 种架构模式的完整评估维度库 |

#### 1.2 动态模式选择

从 PRD 中提取**项目特征标签**（Characteristic Tags），例如：
- `frontend_heavy` → 候选：Micro-Frontends, BFF, Client-Server, Layered
- `high_read_write_ratio` → 候选：CQRS, Event-Driven, Microservice
- `event_driven` → 候选：Event-Driven, Serverless, Microservice
- `multi_tenant` → 候选：Microservice, Hexagonal, Layered
- `ai_agent` → 候选：Event-Driven, Serverless, Hexagonal, Plugin-Based

**匹配规则**：
- 根据标签匹配 Pattern Selection Matrix，选出最相关的 **4-6 种模式**
- 如果匹配标签少于 4 个，回退到默认组合：Layered, Hexagonal, Event-Driven, Microservice, Client-Server

#### 1.3 Orchestrator-Worker 评估

```
Orchestrator（主控）
  ├── 定义评估维度（从 PRD 提取）
  │     例如：耦合度、可测试性、可扩展性、团队熟悉度、维护成本
  ├── 询问用户偏好（是否已有倾向架构）
  │     ├── 有偏好 → 评估该偏好 + 2 个替代方案
  │     └── 无偏好 → 评估动态选出的 4-6 种模式
  │
  └── Worker 1: 评估模式 A → 各维度得分、关键优势、关键风险
      Worker 2: 评估模式 B → 同上
      Worker 3: 评估模式 C → 同上
      ...

  合成阶段：
      ├── 生成评分矩阵表
      ├── 推荐架构 + 完整推理链（为什么选择，为什么拒绝其他）
      └── 输出决策建议
```

**评估维度示例**（来自 `architecture-patterns.md`）：

| 维度 | Layered | Hexagonal | Event-Driven |
|------|---------|-----------|--------------|
| 耦合度 | 中（相邻层依赖） | 高（核心零依赖） | 高（完全解耦） |
| 可测试性 | 高 | 很高 | 中（事件链调试难） |
| 可扩展性 | 低（整系统伸缩） | 中 | 很高 |
| 团队熟悉度 | 很高 | 中 | 低 |
| 维护成本 | 中 | 中（学习曲线高） | 高（事件模式复杂） |

---

### 步骤 2：接口契约设计（Interface Contract Design）

#### 2.1 基于 PRD 的跨模块交互

读取 PRD 中的 **"Cross-Module Interactions"** 部分，为每个模块间调用定义：
- **方法名**（Method Name）
- **输入模式**（Input Schema）：字段、类型、必填性
- **输出模式**（Output Schema）：字段、类型
- **错误码**（Error Codes）：HTTP 状态码 + 业务错误码
- **序列化格式**（Serialization Format）：如 HTTP/JSON, gRPC/Protobuf

#### 2.2 输出产物

生成 `PROJECT_SCAFFOLD/docs/architecture/system/INTERFACE_CONTRACT.md`

```markdown
## 接口 1: 用户认证服务

### login
- **方法**: POST /api/v1/auth/login
- **输入**: `LoginRequest`
  - email (string, required)
  - password (string, required)
- **输出**: `AuthToken`
  - token (string)
  - expires_at (datetime)
  - refresh_token (string)
- **错误码**:
  - 400: 请求参数缺失
  - 401: 凭证无效
  - 429: 登录频率超限
```

#### 2.3 为什么设计这个步骤

> **设计意图**：在编码之前固化模块边界。接口契约是模块设计的"法律"——一旦确定，后续模块设计（`devforge-module-design`）必须严格遵守。这强制实现了 **Interface as Boundary** 原则。

---

### 步骤 3：状态所有权映射（State Ownership Mapping）

#### 3.1 识别所有有状态实体

从 PRD 中识别每一个有状态的实体（如 User, Order, Session, Cart），回答四个问题：
- **存储位置**：PostgreSQL？Redis？S3？
- **写入者**：哪个模块负责写入？
- **读取者**：哪些模块会读取？
- **生命周期策略**：创建/读取/更新/删除/清理策略

#### 3.2 嵌入到 XML StateModel

```xml
<StateModel>
  <State id="user_session"
         location="Redis"
         owner="auth-service"
         consumer="order-service,payment-service"
         lifecycle="create:login,read:every_request,update:activity,delete:logout,cleanup:ttl_7d"/>
</StateModel>
```

#### 3.3 为什么设计这个步骤

> **设计意图**：分布式系统中最难调试的问题之一是"谁写了这个状态"。通过在设计阶段强制回答这个问题，可以避免后期的竞态条件、数据不一致和并发冲突。这是 **State as Responsibility** 原则的核心体现。

---

### 步骤 4：测试用例设计（Test Case Design）

#### 4.1 覆盖维度

基于 PRD 中的用户故事（User Stories）和验收标准（AC），生成三类测试：
- **Happy Path**：正常业务流程的完整验证
- **Abnormal Path**：异常输入、边界条件、错误处理
- **NFR Tests**：性能测试、安全测试、负载测试

#### 4.2 标准化 Mock 数据

定义标准化的业务 Mock 数据结构，供后续测试复用。

#### 4.3 为什么在设计阶段做测试设计

> **设计意图**：遵循 **Reality as Baseline** 原则——如果一个设计无法被测试验证，那么它就是不可实现的。在设计阶段定义测试用例，可以反向验证架构的可测试性（testability），避免设计出"无法验证"的架构。

---

### 步骤 5：XML 架构建模（XML Architecture Modeling）

这是整个技能中最核心的步骤，生成**三层 XML 架构**的**第一层（系统层）**。

#### 5.1 读取的输入

- `references/xml-schemas.md` —— 严格的 XML Schema 定义

#### 5.2 输出产物

`PROJECT_SCAFFOLD/docs/architecture/system/architecture.xml`

#### 5.3 XML 结构要求

```xml
<SystemArchitecture type="microservice" version="1.0.0">
  <!-- 决策追踪 -->
  <DecisionTrace>
    <Decision id="arch-dec-0001" date="2026-05-12">
      <Question>为什么选用微服务而非单体架构？</Question>
      <Answer>团队规模 > 50 人，需要独立部署...</Answer>
      <Risk>分布式事务复杂性、网络延迟...</Risk>
    </Decision>
  </DecisionTrace>

  <!-- 模块定义 -->
  <Module id="user-service" owner="team-auth">
    <Responsibility>用户管理、认证、授权</Responsibility>
    <Interface>
      <Input schema="LoginRequest" protocol="HTTP/JSON"/>
      <Output schema="AuthToken" protocol="HTTP/JSON"/>
      <ErrorCodes>
        <Error code="401" description="凭证无效"/>
      </ErrorCodes>
    </Interface>
    <Coupling>
      <DependsOn module="notification-service" reason="发送登录通知"/>
    </Coupling>
    <ModuleDetail ref="modules/user-service/module-architecture.xml"/>
  </Module>

  <!-- 数据模型 -->
  <DataModel name="User" ddlType="table" tableEngine="InnoDB">
    <Fields>
      <Field name="id" type="uuid" required="true" primaryKey="true"/>
      <Field name="email" type="string" length="255" required="true" unique="true" index="true"/>
    </Fields>
    <Relationships>
      <Relationship type="one-to-one" target="Profile" foreignKey="profile_id" onDelete="SET_NULL"/>
    </Relationships>
    <CacheStrategy type="redis" ttl="3600" indexedFields="email"/>
  </DataModel>

  <!-- 状态模型 -->
  <StateModel>
    <State id="user_session" location="Redis" owner="user-service" consumer="order-service"
           lifecycle="create:login,read:every_request,update:activity,delete:logout,cleanup:ttl_7d"/>
  </StateModel>

  <!-- 安全架构 -->
  <Security>
    <Authentication type="JWT" issuer="auth-service" audience="all-services"/>
    <Authorization model="RBAC">
      <Role id="admin" permissions="*"/>
      <Role id="user" permissions="read_profile,update_profile"/>
    </Authorization>
    <Encryption inTransit="TLS1.3" atRest="AES-256"/>
    <KeyManagement>
      <Strategy type="HashiCorp-Vault" rotation="90d"/>
    </KeyManagement>
    <Audit>
      <LogEvents>authn,authz,data-access</LogEvents>
      <Retention>2555d</Retention>
    </Audit>
  </Security>
</SystemArchitecture>
```

#### 5.4 自动生成的模块级 XML 模板

对于系统 XML 中定义的每个 `Module`，自动在以下路径生成模板：

```
PROJECT_SCAFFOLD/docs/architecture/modules/{module_id}/module-architecture.xml
```

模板预填充内容：
- `ParentSystem` —— 引用回系统级 XML
- `Constraints` —— 复制系统级接口义务（Input/Output Schema）
- `Components` —— 占位符 + 示例组件结构
- `ComponentInterfaces` —— 占位符
- `ModuleStateModel` —— 根据模块职责预填状态条目骨架

#### 5.5 为什么用 XML 作为架构权威

> **设计意图（XML as Authority）**：
> 1. **机器可读**：XML Schema 可以被程序验证（`scripts/xml-sync.py`），实现 CI 自动化检查
> 2. **严格约束**：Schema 强制要求某些字段（如 `StateModel` 必须包含完整的生命周期），避免遗漏
> 3. **可追溯**：`DecisionTrace` 记录每个设计决策的 Why，防止决策失忆
> 4. **分层解耦**：系统层、模块层、组件层各自独立演进，通过引用关联

---

### 步骤 5a：安全架构建模（Security Architecture Modeling）

v1.4 新增的安全专项步骤。

#### 5a.1 弱算法检测

扫描 `architecture.xml` 中的 `Encryption` 属性，检测是否存在：
- MD5（密码学上已破解）
- SHA1（Shattered 攻击可行）
- DES（56 位密钥，暴力破解可行）
- 3DES（Sweet32 攻击）

如果检测到 → 发出 **WARNING**，要求更新为现代算法（SHA-256, AES-256, Argon2）。

#### 5a.2 生成 security.xml

`PROJECT_SCAFFOLD/docs/architecture/system/security.xml`

内容结构镜像 `architecture.xml` 中的 `Security` 节点，额外增加：
- `ComplianceRequirements` —— 从 PRD 提取合规要求（如 GDPR、SOC2）

#### 5a.3 ThreatModel 占位

`ThreatModel` 节点在此阶段可为空，由 `devforge-threat-modeling` 技能后续填充。

---

### 步骤 6：数据库 Schema 生成（DDL Generation）

#### 6.1 输入

`architecture.xml` 中的所有 `DataModel` 节点

#### 6.2 映射规则

| XML 字段类型 | SQL 类型 |
|-------------|----------|
| `string` + `length` | `VARCHAR(length)` |
| `string` (无长度) | `TEXT` |
| `int` | `INT` |
| `long` | `BIGINT` |
| `float` | `FLOAT` |
| `double` | `DOUBLE` |
| `boolean` | `BOOLEAN` / `TINYINT(1)` (MySQL) |
| `datetime` | `TIMESTAMP` / `DATETIME` |
| `uuid` | `CHAR(36)` / `UUID` (PostgreSQL) |
| `text` | `TEXT` |
| `json` | `JSON` |

#### 6.3 约束映射

| XML 属性 | SQL 约束 |
|----------|----------|
| `required="true"` / `nullable="false"` | `NOT NULL` |
| `primaryKey="true"` | `PRIMARY KEY` |
| `unique="true"` | `UNIQUE` |
| `index="true"` | `CREATE INDEX` |
| `default` | `DEFAULT {value}` |
| `autoIncrement="true"` | `AUTO_INCREMENT` / `SERIAL` |

#### 6.4 外键生成

从 `Relationships/Relationship` 生成 `ALTER TABLE` 语句：
```sql
ALTER TABLE User ADD CONSTRAINT fk_user_profile
  FOREIGN KEY (profile_id) REFERENCES Profile(id)
  ON DELETE SET_NULL ON UPDATE CASCADE;
```

#### 6.5 输出产物

- `PROJECT_SCAFFOLD/docs/architecture/system/schema.sql`
- `PROJECT_SCAFFOLD/docs/architecture/system/ERD.md`（Mermaid ER 图语法）

#### 6.6 自验证检查

- 每个 `CREATE TABLE` 以 `);` 结尾
- 每个 `ALTER TABLE` 外键语法合法
- 无 `VARCHAR()`（缺少长度参数）
- 主键字段有 `NOT NULL`

#### 6.7 为什么从 XML 自动生成 DDL

> **设计意图**：
> 1. **单一数据源**：XML 是架构的唯一权威，DDL 是派生产物，避免 XML 和数据库 schema 不同步
> 2. **多数据库兼容**：通过抽象逻辑类型（`string`, `int` 等），可生成 MySQL/PostgreSQL/SQLite 等不同方言
> 3. **可验证**：生成的 DDL 可被数据库引擎直接验证语法正确性

---

### 步骤 7：OpenAPI 规范生成

#### 7.1 输入

- `INTERFACE_CONTRACT.md`
- `architecture.xml`

#### 7.2 转换规则

```yaml
openapi: 3.0.0
info:
  title: {project_name}
  version: {from STATE.md}
paths:
  /{module}/{endpoint}/{method}:
    post:
      requestBody:
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/LoginRequest'
      responses:
        200:
          description: Success
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/AuthToken'
        401:
          description: 凭证无效
components:
  schemas:
    LoginRequest:
      type: object
      properties:
        email: { type: string }
        password: { type: string }
```

#### 7.3 自验证检查

- 所有 `$ref` 以 `#/components/schemas/` 开头
- 所有路径至少有一个响应定义
- `components/schemas` 中的名称与 `architecture.xml` 的 `DataModel` 名称一致
- YAML 缩进一致（2 空格）

#### 7.4 输出产物

`PROJECT_SCAFFOLD/docs/architecture/system/openapi.yaml`

#### 7.5 为什么同时生成 DDL 和 OpenAPI

> **设计意图**：
> - DDL 是**内部实现契约**——后端开发者、DBA 使用
> - OpenAPI 是**外部通信契约**——前端、客户端、第三方集成方使用
> - 两者同源（都来自 XML），确保内部数据模型和外部 API 的一致性

---

### 步骤 8：架构文档编写（ARCHITECTURE.md）

#### 8.1 内容结构

- **选定架构及理由**：引用评分矩阵，说明选择原因
- **接口契约摘要**：概述所有跨模块接口
- **测试用例目录**：列出已设计的测试用例
- **Mock 数据定义**：标准化测试数据
- **技术栈推荐**：含验证规则（见步骤 8a）

#### 8.2 输出产物

`PROJECT_SCAFFOLD/docs/architecture/system/ARCHITECTURE.md`

---

### 步骤 8a：技术栈验证规则（Technology Stack Validation）

v1.2 引入的关键安全步骤，在推荐任何第三方工具/库/框架之前必须执行：

#### 8a.1 主动搜索（Primary）

使用 `WebSearch` / `WebFetch` 搜索：
- `"{tool_name} deprecated"`
- `"{tool_name} CVE"`
- `"{tool_name} maintenance status"`

检查 GitHub/官网：
- 最后提交/发布日期（12 个月内有更新 = 活跃维护）
- 是否有弃用通知或归档状态
- 开放的安全公告

#### 8a.2 知识验证（Fallback）

如果搜索工具不可用，基于训练知识交叉验证，并附加免责声明。

#### 8a.3 黑名单强制执行（Always）

**绝不推荐**（除非用户明确批准）：
- VM2（严重沙箱逃逸 CVE，项目已归档）
- 过去 12 个月内有已知 RCE 漏洞的库
- 弱密码算法：MD5, SHA1, DES, 3DES

如果 `architecture.xml` 中包含 `Encryption atRest="DES"` → 标记为 **CRITICAL**，要求更新后才继续。

#### 8a.4 冲突处理

如果搜索到的工具在黑名单中或已弃用：
- 显式标记风险
- 提供活跃维护的替代方案
- 在 `DECISION_LOG.md` 中记录风险

#### 8a.5 为什么设计这个验证

> **设计意图**：防止因为推荐了已弃用/有安全漏洞的依赖而导致项目在上线前就被迫重构。这是**供应链安全**的第一道防线。历史上 VM2、Log4j 等事件都证明了在架构阶段验证依赖安全性的重要性。

---

### 步骤 9：决策日志更新（Decision Log Update）

#### 9.1 追加内容

向 `PROJECT_SCAFFOLD/docs/architecture/system/DECISION_LOG.md` 追加：
- 日期和决策 ID（如 `arch-dec-0001`）
- 评估维度和评分矩阵
- **完整推理链**：为什么选择该架构、为什么拒绝每个替代方案
- 被拒绝的替代方案及具体原因

#### 9.2 遵循的规则

根据 `skill/tools/artifact-manager.md`，`DECISION_LOG.md` 使用 **Append-only** 模式：
- 新决策追加到末尾
- 废弃决策标记为 `superseded by [新决策ID]` 而非删除
- 保留完整的历史决策链

#### 9.3 为什么保留完整决策链

> **设计意图**：架构决策是项目最重要的隐性资产。"我们当时为什么选这个"是后续迭代中最常被问到的问题。完整的推理链让未来的开发者（甚至 6 个月后的自己）理解约束条件和权衡取舍。

---

### 步骤 10：状态更新（State Update）

#### 10.1 更新 STATE.md

根据 `skill/tools/state-updater.md` 执行：

| 字段 | 更新内容 |
|------|----------|
| **Completed Steps** | 追加：`[YYYY-MM-DD HH:MM] devforge-architecture-design: 评估了 N 种模式。选择了 [pattern]。关键推理：[摘要]` |
| **Known Pitfalls** | 追加评估过程中识别的风险 |
| **DIVE Design** | `completed` |
| **DIVE Implement** | `pending` |
| **Phase** | `architecture_design_completed` |

#### 10.2 为什么 STATE.md 是中央状态文件

> **设计意图**：所有 Skill 共享同一个状态文件，实现跨会话的连续性。即使会话中断，下一次启动时只需读取 `STATE.md` 即可恢复到正确的阶段。这是 **File-based State** 架构的核心。

---

### 步骤 11：人工门控（Human Gate）

#### 11.1 呈现内容

- 架构摘要（一句话概括：选择了什么架构、核心模块、关键技术决策）
- XML 大纲（模块列表、数据模型列表、接口数量）
- 生成的文件清单

#### 11.2 固定提示语

```
架构设计、接口契约和 XML 模型已生成。请确认当前阶段输出。
```

#### 11.3 可用命令列表

| 命令 | 行为 |
|------|------|
| `[APPROVE]` | 批准并继续，进入架构验证阶段（`devforge-architecture-validation`） |
| `[PAUSE]` | 暂停当前阶段，保留上下文 |
| `[ROLLBACK {step_id}]` | 回滚到指定步骤重新执行 |
| `[EDIT {file_path}]` | 手动编辑文件后让 AI 继续 |
| `[INJECT {context}]` | 补充额外上下文约束 |
| `[SKIP]` | 跳过当前可选步骤 |
| `[EXPLAIN {TraceID}]` | 展开解释某个决策/错误的推理链 |
| `[DESIGN_REVIEW]` | 触发设计审查（`devforge-design-review`） |
| `[SECURITY_AUDIT]` | 触发安全审计（`devforge-security-audit`） |

#### 11.4 自然语言处理

如果用户输入自然语言（如"这里需要修改"），**不视为无效命令**，而是：
1. 分析修改请求
2. 应用变更
3. 重新呈现门控 + 更新后的输出

#### 11.5 HARD-GATE

```xml
<HARD-GATE>
Do NOT proceed to architecture-validation or scaffolding until the user replies [APPROVE] or explicitly asks to continue.
</HARD-GATE>
```

#### 11.6 为什么必须有硬门控

> **设计意图**：
> 1. **防止幻觉自动推进**：LLM 可能在用户未确认的情况下自动"批准"并继续，这会导致错误设计被后续阶段固化
> 2. **强制人类审核**：架构设计是影响最大的决策点之一，修改成本随时间指数增长。在设计阶段修正错误的成本是 1x，在编码阶段修正就是 10x，在上线后修正就是 100x
> 3. **满足合规要求**：很多企业的技术方案评审（TR）要求架构文档必须经人工签字确认

---

## 三、调用工具汇总

| 工具/技能 | 用途 | 调用时机 |
|-----------|------|----------|
| `Read` | 读取 `PRD.md`, `STATE.md`, `DECISION_LOG.md` | 步骤 1 |
| `Read` | 读取 `references/architecture-patterns.md` | 步骤 1 |
| `Read` | 读取 `references/xml-schemas.md` | 步骤 5 |
| `WebSearch` / `WebFetch` | 搜索工具/库的 CVE、弃用状态 | 步骤 8a |
| `Write` | 写入所有输出文件 | 步骤 2-9 |
| `xml-sync.py`（脚本） | 验证 XML 引用完整性、Schema 合规性 | 隐含在自验证中 |
| `architecture-ci.sh`（脚本） | 架构一致性 CI 检查 | 隐含在自验证中 |

---

## 四、生成产物清单

| 产物文件 | 路径 | 用途 | 更新模式 |
|----------|------|------|----------|
| `ARCHITECTURE.md` | `docs/architecture/system/` | 架构文档（选择理由、接口摘要、测试目录、Mock 数据、技术栈） | 新生成 |
| `INTERFACE_CONTRACT.md` | `docs/architecture/system/` | 跨模块接口契约 | Merge-update |
| `architecture.xml` | `docs/architecture/system/` | 系统级 XML 架构（权威源） | Merge-update |
| `module-architecture.xml` | `docs/architecture/modules/{id}/` | 模块级 XML 模板（每个模块一个） | Merge-update |
| `schema.sql` | `docs/architecture/system/` | 数据库 DDL | 新生成 |
| `ERD.md` | `docs/architecture/system/` | Mermaid ER 图 | 新生成 |
| `openapi.yaml` | `docs/architecture/system/` | OpenAPI 3.0 规范 | 新生成 |
| `security.xml` | `docs/architecture/system/` | 安全架构详细定义 | Merge-update |
| `DECISION_LOG.md` | `docs/architecture/system/` | 架构决策记录 | Append-only |
| `STATE.md` | `docs/architecture/system/` | 中央状态文件 | Selective update |

---

## 五、流程设计原理（Why Designed This Way）

### 5.1 设计哲学：Workflow-Aggregate Decomposition

整个 DevForge 链的设计不是"角色接力赛"（role relay race），而是**"同一个思考者从不同维度展开同一个复杂问题"**。每个 Skill 都是同一个思考者，只是聚焦在不同的维度上：
- `requirement-analysis` → "我要做什么？"
- `architecture-design` → "我要怎么组织它？"
- `module-design` → "每个部分长什么样？"
- `test-execution` → "它工作正常吗？"

这意味着 `architecture-design` 不会只读上一阶段的输出，而是读取**全部历史产物**（PRD + STATE + DECISION_LOG），保持对完整意图的理解。

### 5.2 VCMF 五原则的贯彻

| VCMF 原则 | 在 architecture-design 中的体现 |
|-----------|-------------------------------|
| **Design as Contract** | 架构必须可追溯回 PRD 需求，不允许虚构需求；所有决策记录在 `DecisionTrace` |
| **Interface as Boundary** | 每个跨模块调用都有显式的 Input/Output/ErrorCode 定义在 `INTERFACE_CONTRACT.md` |
| **Reality as Baseline** | 测试用例覆盖 happy path + abnormal path + NFR；技术栈推荐前有主动搜索验证 |
| **State as Responsibility** | `StateModel` 强制回答：存储位置、写入者、读取者、生命周期 |
| **XML as Authority** | `architecture.xml` 是架构的唯一权威源，DDL/OpenAPI 均由其派生 |

### 5.3 为什么使用 Orchestrator-Worker 模式做架构探索

| 对比维度 | 单一线性评估 | Orchestrator-Worker 并行评估 |
|----------|-------------|------------------------------|
| 偏见风险 | 高（一旦开始倾向于某个模式，后续评估会寻找确认证据） | 低（每个 Worker 独立评估一个模式，无交叉影响） |
| 覆盖广度 | 低（通常只评估 2-3 个模式） | 高（同时评估 4-6 个模式） |
| 推理链完整性 | 弱（为什么没选某个模式可能没有明确记录） | 强（每个被拒绝的模式都有明确原因） |
| 用户信任度 | 低（用户不知道是否漏掉了更好的方案） | 高（用户看到完整的评分矩阵和对比） |

### 5.4 为什么有三层 XML 架构

```
System Layer (architecture.xml)
    → 定义模块边界、系统级接口、数据模型、状态、安全策略
    → 产出物：系统架构大图

Module Layer (module-architecture.xml)
    → 继承系统级约束，定义模块内组件分解、组件接口
    → 产出物：模块内部设计

Component Layer (component-spec.xml)
    → 继承模块级约束，定义函数签名、业务逻辑、错误处理、测试用例
    → 产出物：可直接生成代码的精确规格
```

**分层的好处**：
1. **关注点分离**：系统架构师看系统层，模块负责人看模块层，开发者看组件层
2. **独立演进**：系统层修改（如新增模块）不影响已有的模块层和组件层
3. **权限隔离**：不同角色可以编辑不同层，减少冲突
4. **引用完整性**：上层通过 `@ref` 引用下层，通过 `scripts/xml-sync.py` 自动验证引用是否正确

### 5.5 为什么 Triple Verification（三重验证）在架构之后

```
architecture-design
    → [APPROVE]
    → architecture-validation (3a) —— "设计是否正确指定"
    → design-review (3b) —— "设计是否有遗漏/错误"
    → security-audit (3c) —— "设计是否有安全漏洞"
```

| 维度 | 3a 架构验证 | 3b 设计审查 | 3c 安全审计 |
|------|------------|------------|------------|
| 视角 | 工程师视角 | 批评者视角 | 审计者视角 |
| 类比 | 编译器类型检查 | 代码审查 | 安全渗透测试 |
| 输出 | PASS/FAIL | 问题列表（无 PASS/FAIL） | 风险等级 |
| 失败处理 | 必须修复 | 可接受/延期/修复 | 严重问题必须修复 |

**为什么三个都要做**：
- 架构验证确保"设计文档是自洽的"
- 设计审查确保"设计决策是正确的"
- 安全审计确保"设计是安全的"
- 三者互补，不可互相替代

### 5.6 为什么技术栈验证必须在设计阶段

架构设计阶段确定的技术栈会在后续所有阶段被使用（脚手架生成配置文件、模块设计生成代码骨架、运维生成部署拓扑）。如果在设计阶段推荐了有安全漏洞或已弃用的工具：
- 后续所有生成产物都会受其影响
- 修正成本随着阶段推进指数增长
- 可能导致项目在接近完成时被迫重构

因此，技术栈验证被设计为**阻塞性检查**（blocking check）——发现问题必须解决或显式确认后才能继续。

---

## 六、常见误区与 Red Flags

根据 SKILL.md 中的 Red Flags 部分：

| 误区 | 正确做法 |
|------|----------|
| 虚构 PRD 中没有的需求 | 所有设计必须可追溯回 PRD |
| 跳过 XML Schema 约束 | 必须包含 `StateModel`、`DecisionTrace` 等必需节点 |
| 写模糊的接口契约（如"返回数据"） | 每个接口必须有明确的 Input/Output Schema 和 Error Codes |
| 自动推进跳过人工门控 | 必须等待 `[APPROVE]` 才能进入下一阶段 |
| 推荐已知有漏洞的工具 | 必须执行 WebSearch 验证，遵守黑名单 |
| 忽略安全架构建模 | v1.4 强制要求生成 `security.xml` 并做弱算法检测 |

---

## 七、总结

`devforge-architecture-design` 是整个 DevForge 链中**承上启下最关键的节点**：

- **承上**：将 PRD 中的模糊需求转化为精确的架构决策
- **启下**：生成 `architecture.xml` 作为后续所有阶段（脚手架、模块设计、测试、运维）的权威输入
- **质量保证**：通过并行探索避免架构偏见，通过三重验证确保设计正确，通过技术栈验证保障供应链安全
- **可追溯性**：每个决策都有完整的 `DecisionTrace`，每个接口都有显式契约，每个状态都有明确的责任人

这个流程的设计目标不是"快速生成一个架构图"，而是"生成一个**可被验证、可被审查、可被演化**的架构体系"。

---

*分析基于 DevForge SDLC Skill Chain v1.4（2026-05-11）*
