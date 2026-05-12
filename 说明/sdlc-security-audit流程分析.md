# SDLC Security Audit 流程深度分析

> 基于 DevForge SDLC Skill Chain v1.4 的 `skill/sdlc-security-audit/SKILL.md` **v1.1**（阶段适配重构后）及其关联工具规范文档进行系统性分析。
>
> **重要更新**：本 Skill 已从单一"代码级安全扫描"重构为**阶段适配型安全审查**，覆盖 design-review 后的架构文档审查、module-design 后的代码级扫描、以及后续迭代的增量扫描。

---

## 一、定位与核心区别

### 1.1 Skill 定位

`sdlc-security-audit` 是 DevForge SDLC Skill Chain 中专门负责**安全审查**的**独立可选 Skill**。本 Skill 是**阶段适配型**的——根据当前项目阶段自动选择审查模式：

- **阶段 I（design-review 后）**：执行**架构文档安全审查**（无代码时审查 architecture.xml、security.xml 等文档）
- **阶段 II（module-design 后）**：执行**代码级全量安全扫描**（首次有源代码时进行全面扫描）
- **阶段 III（后续迭代）**：执行**增量安全扫描**（基于 git diff 仅扫描变更文件）

它与 `devforge-design-review` 和 `devforge-threat-modeling` 共同构成安全审查的三层体系，但各自聚焦不同层级：

| 维度 | `devforge-design-review` | `devforge-threat-modeling` | `sdlc-security-audit` |
|------|------------------------|---------------------------|----------------------|
| **审查层级** | 架构 / 设计层面 | 系统威胁建模层面 | **阶段适配（文档→代码→增量）** |
| **关注焦点** | 数据流、信任边界、设计缺陷 | STRIDE 威胁分析 | **架构安全缺陷 / 代码漏洞 / CVE** |
| **输出产物** | 架构安全建议、威胁模型 | 威胁矩阵、缓解措施 | **架构审查报告 / 漏洞报告 / 修复补丁** |
| **执行时机** | 设计阶段（编码前） | 设计阶段（编码前） | **design-review 后 / module-design 后 / 每次提交** |
| **检测能力** | 逻辑漏洞、设计缺陷 | 系统级威胁 | **弱算法、接口暴露面 / 注入、密钥泄露 / CVE** |
| **修复粒度** | 模块级、接口级 | 系统级安全策略 | **XML 属性级 / 代码行级** |
| **是否必经** | 是（默认运行） | 可选 | **可选（推荐）** |

### 1.2 为什么需要阶段适配型安全审查

> **设计意图**：
> - `design-review` 在编码前发现架构层面的安全问题（如"这个接口没有鉴权"、"认证架构存在中间人攻击风险"）
> - `threat-modeling` 在设计阶段识别系统级威胁（如"这个地方存在 STRIDE 中的信息泄露风险"）
> - `sdlc-security-audit` **在不同阶段做不同的事情**：
>   - **design-review 后（无代码）**：执行**定量规则检测**——检查 `architecture.xml` 是否使用了黑名单中的弱算法、安全属性是否缺失、PRD 安全需求是否有对应 XML 节点（不做"策略是否充分"的定性判断）
>   - **module-design 后（有代码）**：扫描源代码中的具体漏洞（如 SQL 注入、硬编码密码）
>   - **后续迭代**：增量扫描变更代码
> 
> **与 `design-review` 的分工边界**：
> | 审查类型 | `design-review`（Attacker Lens） | `sdlc-security-audit` 阶段 I |
> |----------|--------------------------------|---------------------------|
> | **加密安全** | 定性推理："TLS1.2 对金融数据是否足够？" | 规则检测："`atRest` 是否在黑名单（DES/MD5/SHA1）中？" |
> | **认证授权** | 定性推理："订单服务绕过认证直接访问用户数据库是否合理？" | 规则检测："`Interface` 节点是否定义了 `Authentication` 属性？" |
> | **威胁覆盖** | 定性推理："是否遗漏了内部威胁场景？" | 需求追踪："PRD 要求的审计日志是否有 `Audit` 节点？" |
> | **输出形式** | 问题列表（Must Fix / Should Fix / Nice to Fix） | 缺陷报告（Critical/High/Medium + 安全需求覆盖度矩阵） |
> 
> 两者互补不重复：`design-review` 回答"策略对不对"，`sdlc-security-audit` 阶段 I 回答"配置有没有 + 值在不在黑名单"。
> 
> **阶段适配的核心价值**：解决了一个长期存在的矛盾——传统安全审计只能在"有代码后"运行，导致架构层面的安全缺陷（如弱算法选择）直到编码阶段才被发现，此时修复成本已很高。阶段 I 的架构文档审查让安全左移（Shift Left）到设计阶段，同时与 `design-review` 的定性审查形成互补。

---

## 二、触发条件与前置检查

### 2.1 触发条件（阶段适配）

| 阶段 | 触发场景 | 审查模式 | 扫描对象 |
|------|----------|----------|----------|
| **阶段 I** | `devforge-design-review` 完成后自动触发 | 架构文档安全审查 | `architecture.xml`, `security.xml`, `INTERFACE_CONTRACT.md` |
| **阶段 I** | 用户在 `design_review_completed` 阶段输入 `[SECURITY_AUDIT]` | 架构文档安全审查 | 同上 |
| **阶段 II** | `devforge-module-design` 完成后自动触发 | 代码级全量安全扫描 | 生成的源代码、配置文件、依赖清单 |
| **阶段 II** | `devforge-project-scaffolding` 后用户输入 `[SECURITY_AUDIT]` | 代码级全量安全扫描 | 同上 |
| **阶段 III** | 新代码提交（PR 前） | 增量安全扫描 | `git diff` 变更文件 |
| **阶段 III** | 依赖清单变更 | 增量安全扫描 | 新增/变更的依赖 |
| **阶段 III** | 敏感文件修改 | 增量安全扫描 | 变更的敏感文件 |
| **阶段 III** | 定期巡检（建议每月一次） | 增量或全量扫描 | 核心模块或遗留代码库 |

### 2.2 前置条件校验

根据 `skill/tools/precondition-checker.md`：

| 校验项 | 要求 |
|--------|------|
| **Acceptable Phases** | `design_review_completed`, `architecture_validated`, `module_design_completed`, `test_execution_completed`, `iteration_planning_completed` |
| **Minimum Phase** | `design_review_completed` |
| **Required Artifact** | `architecture.xml` |

**不满足条件时的行为**：
- 如果阶段早于 `design_review_completed` → 停止执行，提示用户先完成 `devforge-design-review`
- 如果 `architecture.xml` 不存在 → 停止执行，提示用户先完成系统级架构设计

### 2.3 阶段与审查模式的映射

```
design-review 完成后 (design_review_completed)
    → 阶段 I：架构文档安全审查（无代码，审查 XML/PRD 安全覆盖度）
    → 可 [SKIP] 进入 scaffolding

module-design 完成后 (module_design_completed)
    → 阶段 II：代码级全量安全扫描（首次有源代码）
    → 可 [SKIP] 进入 test-execution

后续迭代 (test_execution_completed / iteration_planning_completed)
    → 阶段 III：增量安全扫描（git diff 变更文件）
    → 用户手动输入 [SECURITY_AUDIT] 触发
```

### 2.4 为什么 design-review 后先做架构文档审查

> **设计意图**：
> 1. **安全左移（Shift Left）**：在编码前发现架构层面的安全缺陷（如选用了 `3DES` 加密、缺少审计日志节点），避免缺陷被编码固化后修复成本倍增
> 2. **无代码时的价值**：即使没有源代码，architecture.xml 和 security.xml 中仍然可能存在严重的安全设计缺陷（如弱算法、接口缺少认证定义）
> 3. **形成安全基线**：阶段 I 的审查结果（安全需求覆盖度矩阵）成为后续代码扫描的基准——如果 PRD 要求的"审计日志"在架构中未覆盖，后续代码即使写得再安全也无法满足合规要求

---

## 三、扫描维度（阶段适配）

`sdlc-security-audit` 根据当前项目阶段自动选择审查维度。

---

### 阶段 I：架构文档安全审查（design-review 后，无代码时）

**审查对象**：`architecture.xml`, `INTERFACE_CONTRACT.md`, `PRD.md`, `security.xml`, `DECISION_LOG.md`

**⚠️ 与 `devforge-design-review` 的分工边界**：
- `design-review`（Attacker Lens）负责**定性安全推理**：评估加密策略是否充分、认证架构是否合理、威胁场景是否完整
- `sdlc-security-audit` 阶段 I 负责**定量规则检测**：检查 XML 中是否使用了已知的弱算法、安全属性是否缺失、PRD 安全需求是否有对应的 XML 节点
- **本阶段不做"策略是否充分"的判断，只做"是否配置了 + 配置值是否在黑名单中"的规则匹配**

#### 🔴 Critical（严重）— 阻塞进入 scaffolding

| 维度 | 描述 | 审查点 | 典型规则 ID | 与 design-review 的区别 |
|------|------|--------|------------|----------------------|
| **弱加密算法** | `architecture.xml` / `security.xml` 中声明了**黑名单**中的弱加密算法 | `Encryption atRest="DES"` / `atRest="MD5"` / `inTransit="TLS1.0"` | `security.arch.weak-encryption` | design-review 判断"策略是否充分"；本步骤只做"是否在黑名单中"的规则匹配 |
| **安全属性缺失** | 关键接口或安全节点**缺少必需的 XML 属性** | `Interface` 节点未定义 `Authentication` / `Authorization` 属性；`Security` 节点完全缺失 | `security.arch.missing-auth` | design-review 判断"认证架构是否合理"；本步骤只做"属性是否存在"的 Schema 检查 |

#### 🟡 High（高危）— 修复后进入 scaffolding

| 维度 | 描述 | 审查点 | 典型规则 ID | 与 design-review 的区别 |
|------|------|--------|------------|----------------------|
| **安全需求遗漏** | PRD 中的安全需求在架构 XML 中**无对应节点** | PRD 提到"需要审计日志"但 `architecture.xml` / `security.xml` 无 `Audit` 节点 | `security.arch.missing-requirement` | design-review 判断"安全策略是否完整"；本步骤只做"PRD 需求 ↔ XML 节点"的追踪矩阵 |
| **信任边界属性缺失** | 跨敏感模块的 `Coupling` **未声明安全传输协议** | `Coupling/DependsOn` 涉及支付/用户数据模块但无 `protocol="HTTPS"` | `security.arch.missing-trust-boundary` | design-review 判断"信任边界设计是否合理"；本步骤只做"是否声明了 protocol 属性" |

#### 🟢 Medium（中危）— 建议修复

| 维度 | 描述 | 审查点 | 典型规则 ID |
|------|------|--------|------------|
| **security.xml 完整性** | `security.xml` 缺少建议性节点 | 缺少 `KeyManagement`, `ThreatModel` 等（`Audit` 为必须，其余为建议） | `security.arch.incomplete-security-xml` |

**阶段 I 输出产物**：`ARCHITECTURE_SECURITY_AUDIT_REPORT.md`

---

### 阶段 II & III：代码级安全扫描（module-design 后有代码时）

安全扫描覆盖以下 **8 个维度**，按严重程度分为三级：

#### 🔴 Critical（严重）— 阻塞发布

| 维度 | 描述 | 常见场景 | 典型规则 ID |
|------|------|----------|------------|
| **硬编码密钥** | API Key、数据库密码、私钥等敏感信息直接写在代码中 | 配置文件、常量定义、测试代码 | `security.secrets.hardcoded-password` |
| **SQL 注入** | 用户输入直接拼接进 SQL 语句 | 动态查询、报表导出、搜索功能 | `security.sql.injection` |
| **XSS（跨站脚本）** | 用户输入未经转义直接输出到页面 | 富文本展示、评论系统、搜索回显 | `security.xss.unescaped-output` |

#### 🟡 High（高危）— 当前迭代修复

| 维度 | 描述 | 常见场景 | 典型规则 ID |
|------|------|----------|------------|
| **不安全依赖** | 使用存在已知 CVE 的第三方库 | 过期框架、未修复的 npm/pip 包 | `security.dependencies.known-cve` |
| **不安全文件操作** | 路径遍历、任意文件上传/下载 | 文件上传接口、导出功能、静态资源服务 | `security.files.path-traversal` |
| **敏感数据日志** | 密码、Token、身份证号等被记录到日志 | 登录接口、支付回调、调试日志 | `security.logging.sensitive-data` |

#### 🟢 Medium（中危）— 排入下个迭代

| 维度 | 描述 | 常见场景 | 典型规则 ID |
|------|------|----------|------------|
| **弱加密算法** | 使用 MD5、SHA1、DES 等已不安全的算法 | 密码哈希、数据加密、签名验证 | `security.crypto.weak-hash` |
| **越权访问** | 缺少权限校验或校验逻辑绕过 | 管理接口、数据查询、资源访问 | `security.auth.missing-authorization` |

### 修复时间线要求

| 级别 | 修复时限 | 发布策略 |
|------|----------|----------|
| Critical | 24 小时内 | **阻塞发布**，必须修复后才能上线 |
| High | 72 小时内 | 纳入当前迭代，阻塞下个版本发布 |
| Medium | 7 天内 | 排入下个迭代，不阻塞当前版本 |

---

## 四、完整工作流程（阶段适配）

`sdlc-security-audit` 根据当前项目阶段自动适配工作流。

```
阶段 I（design-review 后，无代码）：
    Step 1-I: 范围确定 → 读取 architecture.xml, security.xml, PRD 安全需求
    Step 2-I: 架构文档静态分析 → 弱算法扫描、接口暴露面、安全需求覆盖度
    Step 3-I: 分级定级 → Critical/High/Medium
    Step 4-I: 修复建议 → XML 修改建议（无代码补丁）
    Step 5-I: 报告输出 → ARCHITECTURE_SECURITY_AUDIT_REPORT.md

阶段 II（module-design 后，首次有代码）：
    Step 1-II: 范围确定 → 全量扫描所有源代码、配置、依赖
    Step 2-II: 静态分析 → 工具扫描 + 正则匹配 + 依赖分析
    Step 3-II: 人工复核 → 过滤误报、确认可利用性
    Step 4-II: 分级定级 → Critical/High/Medium + CVSS
    Step 5-II: 修复建议 → 具体代码修复示例
    Step 5a-II: 自动修复 Diff 生成 → git diff 补丁
    Step 6-II: 报告输出 → SECURITY_AUDIT_REPORT.md + SECURITY_FIX.patch

阶段 III（后续迭代，增量）：
    Step 1-III: 范围确定 → git diff 变更文件
    Step 2-III: 增量静态分析 → 仅扫描变更文件
    Step 3-III: 人工复核
    Step 4-III: 分级定级
    Step 5-III: 修复建议 + 自动修复 Diff
    Step 6-III: 报告输出 → SECURITY_AUDIT_REPORT.md（标注增量扫描）
```

---

### 阶段 I：架构文档安全审查（design-review 后，无代码）

**适用阶段**：`design_review_completed`

#### Step 1-I: 范围确定

- 读取 `architecture.xml`, `security.xml`, `INTERFACE_CONTRACT.md`, `PRD.md`
- 标记需审查的安全相关节点：`Security`, `Interface`, `Coupling`, `DataModel`

**为什么范围确定在阶段 I 不同**：

> 阶段 I 不需要 `git diff`，因为审查对象是架构文档而非源代码。审查范围由 `architecture.xml` 中的 `Security` 节点、`Module/Interface` 定义、`Coupling` 关系决定。

---

#### Step 2-I: 架构文档静态分析

**⚠️ 与 `devforge-design-review` 的分工**：本步骤只做**规则匹配和存在性检查**，不做策略合理性判断。策略合理性（如"TLS1.2 是否足够"）由 `design-review` 的 Attacker Lens 负责。

**2-I.1 弱算法扫描（黑名单规则匹配）**

扫描 `architecture.xml` / `security.xml` 中 `Encryption` 属性：
- **黑名单**：`MD5`, `SHA1`, `DES`, `3DES`, `TLS1.0`, `TLS1.1`
- 如检测到 → 标记 **Critical**，要求更新为 `AES-256` / `SHA-256` / `TLS1.3`
- **注意**：不判断"当前算法是否满足业务需求"，只做"是否在黑名单中"的规则匹配
- 与 `devforge-architecture-design` 中的弱算法检测形成互补——设计阶段检测一次，审计阶段再验证一次

**2-I.2 安全属性存在性检查（Schema 必填检查）**

检查 `Module/Interface` 是否定义了安全属性：
- 涉及用户数据/支付的接口是否有 `Authentication` / `Authorization` 属性
- `SystemArchitecture/Security` 节点是否存在
- **注意**：不判断"认证机制是否足够强"，只检查"是否配置了"

**2-I.3 安全需求覆盖度（需求追踪矩阵）**

对比 PRD 安全需求与 `security.xml` / `architecture.xml` 实现：

| PRD 安全需求 | architecture.xml 检查点 | 状态 |
|-------------|------------------------|------|
| "用户密码加密存储" | `Encryption atRest` 是否存在且非弱算法 | **必须覆盖** |
| "传输加密" | `Encryption inTransit` 是否为 `TLS1.3` | **必须覆盖** |
| "API 鉴权" | `Authorization` 节点是否定义 | **必须覆盖** |
| "审计日志" | `Audit` 节点是否存在 | **必须覆盖** |
| "密钥管理" | `KeyManagement` 节点是否存在 | **建议覆盖** |
| "威胁建模" | `ThreatModel` 节点是否存在 | **可选（由 threat-modeling 填充）** |

- 输出"安全需求覆盖度矩阵"——量化追踪，不是定性判断

**2-I.4 信任边界属性检查（规则匹配）**

检查 `Coupling/DependsOn` 中敏感模块间的调用：
- 涉及支付、用户数据的模块间调用是否声明 `protocol` 属性（如 `HTTPS`, `gRPC+TLS`）
- **注意**：不判断"协议选择是否合理"，只检查"是否声明了安全传输协议"

---

#### Step 3-I: 分级定级

按 Critical / High / Medium 分级。

**注意**：此阶段不生成代码修复补丁（无代码可修），仅输出架构修改建议（XML 片段）。

---

#### Step 4-I: 修复建议

提供 `architecture.xml` / `security.xml` 的修改建议：

```xml
<!-- 修复前 -->
<Encryption atRest="3DES" inTransit="TLS1.2"/>

<!-- 修复后 -->
<Encryption atRest="AES-256" inTransit="TLS1.3"/>
```

---

#### Step 5-I: 报告输出

生成 `ARCHITECTURE_SECURITY_AUDIT_REPORT.md`：

```markdown
# Architecture Security Audit Report

**Phase**: architecture_document_review
**Scope**: architecture.xml, security.xml, INTERFACE_CONTRACT.md, PRD.md

## Summary

| Severity | Count | Category |
|----------|-------|----------|
| Critical | 1 | weak_encryption_algorithm |
| High     | 1 | missing_security_requirement |
| Medium   | 1 | incomplete_security_xml |

## Architecture Security Coverage Matrix

| PRD Security Requirement | architecture.xml Coverage | Status |
|--------------------------|---------------------------|--------|
| 用户密码加密存储 | `Encryption atRest="AES-256"` | Covered |
| 审计日志 | `Audit` 节点缺失 | **Missing** |
| 传输加密 | `Encryption inTransit="TLS1.3"` | Covered |
| API 鉴权 | `Authorization model="RBAC"` | Covered |

## Critical Issues

### [C-001] 使用弱加密算法 3DES
- **File**: `architecture.xml`
- **Location**: `/SystemArchitecture/Security/Encryption/@atRest`
- **Current**: `atRest="3DES"`
- **Risk**: 3DES 存在 Sweet32 攻击，不符合现代安全标准。
- **Fix**: 更新为 `atRest="AES-256"`
- **Deadline**: 立即修复，阻塞进入 scaffolding 阶段

## Recommendations
1. 将 `architecture.xml` 中 `Encryption/@atRest` 从 `3DES` 更新为 `AES-256`
2. 在 `security.xml` 中补充 `Audit` 节点
3. 建议在 `devforge-threat-modeling` 阶段补充 `ThreatModel` 节点
```

---

### 阶段 II：代码级全量安全扫描（module-design 后，首次有代码）

**适用阶段**：`module_design_completed`, `scaffolding_completed`

#### Step 1-II: 范围确定

- 扫描范围：**全量扫描**（首次代码级扫描）
- 识别所有源代码文件、配置文件、依赖清单
- 标记敏感文件（认证、支付、加密、隐私相关）

---

#### Step 2-II: 静态分析

##### 2-II.1 三层扫描机制

```
┌─────────────────────────────────────────────┐
│  Layer 1: 工具扫描（结构性漏洞）              │
│  - Semgrep: 跨语言模式匹配                   │
│  - CodeQL: 深层数据流分析                    │
│  - Bandit: Python 专用安全扫描               │
│  - ESLint Security: JS/TS 安全规则           │
├─────────────────────────────────────────────┤
│  Layer 2: 正则规则匹配（模式识别）            │
│  - 硬编码密钥正则：API_KEY\s*=\s*['"]\w+     │
│  - SQL 拼接模式：`...${userInput}...`        │
│  - 危险函数调用：eval(), innerHTML()          │
├─────────────────────────────────────────────┤
│  Layer 3: 依赖树分析（供应链安全）            │
│  - npm audit: Node.js 依赖 CVE              │
│  - pip-audit: Python 依赖 CVE               │
│  - trivy: 容器镜像 + 依赖 CVE               │
└─────────────────────────────────────────────┘
```

##### 2-II.2 技术栈适配

| 技术栈 | 扫描工具 | 规则文件 |
|--------|----------|----------|
| JavaScript/Node.js | Semgrep, ESLint Security | `rules/js-security.yaml` |
| Python | Bandit, Semgrep | `rules/py-security.yaml` |
| Java | CodeQL, SpotBugs | `rules/java-security.yaml` |
| Go | gosec, Semgrep | `rules/go-security.yaml` |
| 通用（密钥扫描） | GitLeaks, truffleHog | `rules/common-secrets.yaml` |

##### 2-II.3 为什么使用多层扫描

> **设计意图**：
> - **工具扫描**发现结构性漏洞（如不安全的函数调用模式），覆盖广但可能有误报
> - **正则匹配**发现简单的模式问题（如硬编码密码），快速且确定性强
> - **依赖分析**发现供应链安全问题（已知 CVE），这是现代安全中最常见的攻击向量
> 三层结合可最大化漏洞发现率，同时通过交叉验证减少误报

---

#### Step 3-II: 人工复核

##### 3-II.1 过滤误报

工具报告的问题中，部分可能是**假阳性**（False Positives）：
- 测试代码中的硬编码数据（非生产密码）
- 内部工具的非安全敏感配置
- 框架生成的样板代码中的"疑似"问题

##### 3-II.2 确认可利用性

对于每个报告的问题，评估：
- 攻击者是否可以实际利用该漏洞？
- 利用需要什么前置条件？
- 利用后的影响范围有多大？

##### 3-II.3 评估业务影响

结合项目上下文评估漏洞的业务影响：
- 支付模块的 SQL 注入 → Critical（涉及资金）
- 内部管理后台的 XSS → High（影响有限）
- 日志中的测试数据 → Medium（非生产环境）

##### 3-II.4 为什么需要人工复核

> **设计意图**：静态分析工具不可避免地产生误报。如果直接输出所有工具结果，用户会被大量无效告警淹没，导致"告警疲劳"，最终忽视真正的问题。人工复核（由 AI 模拟专家判断）过滤掉明显误报，只保留有实际风险的漏洞。

---

#### Step 4-II: 分级定级

##### 4-II.1 分级标准

| 级别 | 定义 | 示例 |
|------|------|------|
| **Critical** | 可导致系统完全沦陷、数据全部泄露、资金损失的漏洞 | 生产数据库密码硬编码、支付接口 SQL 注入 |
| **High** | 可导致部分数据泄露、权限提升、服务中断的漏洞 | 已知 CVE 依赖、路径遍历、敏感日志 |
| **Medium** | 增加攻击面但单独利用影响有限的漏洞 | MD5 哈希、缺少部分权限校验 |

##### 4-II.2 CVSS 评分（可选）

对于符合 CVSS 标准的漏洞，标注 CVSS v3.1 评分：
- Critical: 9.0 - 10.0
- High: 7.0 - 8.9
- Medium: 4.0 - 6.9

---

#### Step 5-II: 修复建议

##### 5-II.1 修复内容要求

对每个漏洞提供：
- **修复前代码**（Before）：标注问题所在行
- **修复后代码**（After）：可直接使用的安全代码
- **修复原理**：简要说明为什么这样修复
- **工作量评估**：简单（1 行修改）/ 中等（需引入库）/ 复杂（需重构）
- **截止时间**：Critical 24h / High 72h / Medium 7d

##### 5-II.2 修复示例

**SQL 注入修复**：
```javascript
// Before（漏洞代码）
const query = `SELECT * FROM users WHERE name = '${req.body.name}'`;

// After（安全代码）
const query = 'SELECT * FROM users WHERE name = ?';
db.query(query, [req.body.name]);
```

---

#### Step 5a-II: 自动修复 Diff 生成（Auto-Fix Patch）

这是 `sdlc-security-audit` 的关键特性——**不仅报告问题，还生成可直接应用的修复补丁**。

##### 5a-II.1 补丁生成规则

- **仅对 Critical 和 High 级别问题生成补丁**
- **格式**：标准 `git diff` 格式
- **命名**：`SECURITY_FIX_{issue_id}.patch`
- **汇总**：所有补丁合并为 `SECURITY_FIX.patch`

##### 5a-II.2 补丁格式示例

```diff
--- a/src/auth/login.js
+++ b/src/auth/login.js
@@ -10,7 +10,7 @@
- const password = 'MyP@ssw0rd123!';
+ const password = process.env.DB_PASSWORD;

--- a/src/user/search.js
+++ b/src/user/search.js
@@ -42,7 +42,7 @@
- const query = `SELECT * FROM users WHERE name = '${req.body.name}'`;
+ const query = 'SELECT * FROM users WHERE name = ?';
+ db.query(query, [req.body.name]);
```

##### 5a-II.3 用户交互

用户可通过以下命令操作补丁：
- `[APPLY]` — 直接应用 `SECURITY_FIX.patch` 中的所有修复
- `[APPLY {issue_id}]` — 仅应用指定问题的修复
- `[EDIT {file_path}]` — 手动编辑后应用

##### 5a-II.4 应用后自动重新审计

应用补丁后，自动触发重新扫描，验证：
- 原漏洞是否已消除
- 修复代码是否引入了新的问题
- 补丁是否破坏了原有功能

##### 5a-II.5 为什么设计自动修复

> **设计意图**：
> 1. **降低修复成本**：开发者不需要手动查找和修改每处漏洞，一键应用即可
> 2. **确保修复质量**：AI 生成的修复遵循安全最佳实践，避免开发者自行修复时引入新问题
> 3. **快速闭环**：报告→修复→验证的周期从小时级缩短到分钟级
> 4. **可审计**：git diff 格式的补丁天然可追溯，可纳入代码审查流程

---

#### Step 6-II: 报告输出

生成 `SECURITY_AUDIT_REPORT.md` + 内联安全注释 + `SECURITY_FIX.patch`。

---

### 阶段 III：增量安全扫描（后续迭代）

**适用阶段**：`test_execution_completed`, `iteration_planning_completed`，或任意代码变更时

#### Step 1-III: 范围确定

- 识别变更文件列表（`git diff --name-only`）
- 标记敏感文件（认证、支付、加密、隐私相关）
- 确定扫描范围：**增量扫描**（仅变更文件）

#### Step 2-III: 增量静态分析

- 仅扫描变更文件和相关依赖
- 使用与阶段 II 相同的工具链，但限制扫描范围
- 分析新增/变更的依赖（`npm audit`、`pip-audit`）

#### Step 3-III: 人工复核

过滤误报、确认可利用性、评估业务影响。

#### Step 4-III: 分级定级

按 Critical / High / Medium 分级。

#### Step 5-III: 修复建议 + 自动修复 Diff

提供代码修复示例，生成增量修复补丁：`SECURITY_FIX.patch`。

#### Step 6-III: 报告输出

生成增量审计报告：`SECURITY_AUDIT_REPORT.md`，报告标注本次扫描为"增量扫描"及变更文件范围。

---

## 五、调用工具汇总

| 工具/技能 | 用途 | 调用时机 |
|-----------|------|----------|
| `Read` | 读取 `architecture.xml`, `STATE.md` | Step 1（前置检查） |
| `Bash` | `git diff --name-only` 获取变更文件 | Step 1 |
| `Grep` | 正则匹配硬编码密钥、危险函数模式 | Step 2 |
| `WebSearch` / `WebFetch` | 查询依赖包的 CVE 信息 | Step 2 |
| `Bash` | `npm audit`, `pip-audit`, `trivy` 等依赖扫描 | Step 2 |
| `Read` | 读取源码文件进行代码级分析 | Step 2-3 |
| `Write` | 写入 `SECURITY_AUDIT_REPORT.md` | Step 6 |
| `Write` | 写入 `SECURITY_FIX_{id}.patch` / `SECURITY_FIX.patch` | Step 5a |
| `Bash` | `git apply SECURITY_FIX.patch`（用户触发 `[APPLY]`） | 用户命令 |
| `Bash` | 重新运行静态分析验证修复 | 补丁应用后 |

---

## 六、生成产物清单（阶段适配）

### 阶段 I 产物

| 产物文件 | 路径 | 用途 | 更新模式 |
|----------|------|------|----------|
| `ARCHITECTURE_SECURITY_AUDIT_REPORT.md` | `docs/architecture/validation/` | 架构安全审计报告（含安全需求覆盖度矩阵） | 新生成 |

### 阶段 II & III 产物

| 产物文件 | 路径 | 用途 | 更新模式 |
|----------|------|------|----------|
| `SECURITY_AUDIT_REPORT.md` | `docs/architecture/validation/` | 代码安全审计主报告 | 新生成 |
| `SECURITY_FIX_{issue_id}.patch` | `docs/architecture/validation/` | 单个问题的修复补丁 | 新生成 |
| `SECURITY_FIX.patch` | `docs/architecture/validation/` | 所有修复的合并补丁 | 新生成 |
| 内联代码注释 | 源代码文件中 | 临时标记漏洞位置 | 修复后移除 |
| `STATE.md` Known Pitfalls | `docs/architecture/system/` | 追加发现的安全风险 | Append-only |
| `ErrorLog` | `STATE.md` 内 | 记录安全漏洞（遵循 error-tracing 格式） | Append-only |
| `STATE.md` Security Posture | `docs/architecture/system/` | 架构安全审查后更新安全态势 | Selective update |

---

## 七、与 Triple Verification 的关系

DevForge v1.3 引入的 **Triple Verification Mechanism** 包含三个互补的验证维度：

```
设计阶段完成后：
    → architecture-validation (3a) — 技术一致性检查
    → design-review (3b) — 对抗性审查
    → sdlc-security-audit (3c) — 安全审查（阶段适配）
```

### 7.1 Triple Verification 对比

| 维度 | 3a 架构验证 | 3b 设计审查 | 3c 安全审计 |
|------|------------|------------|------------|
| **目的** | "设计是否正确指定" | "设计是否有遗漏/错误" | "设计/代码是否有安全缺陷" |
| **视角** | 工程师视角 | 批评者视角 | **安全审计者视角** |
| **输入** | architecture.xml, INTERFACE_CONTRACT.md | PRD, architecture.xml, DECISION_LOG | **阶段 I: architecture.xml, PRD<br>阶段 II/III: 源代码, 依赖清单** |
| **检查项** | XML Schema 合规、接口一致性、PRD 可追溯性 | 安全性、可操作性、可扩展性 | **阶段 I: 弱算法、接口暴露面、安全需求覆盖度<br>阶段 II/III: 漏洞、密钥泄露、CVE** |
| **输出** | VALIDATION_REPORT.md (PASS/FAIL) | DESIGN_REVIEW.md (问题列表) | **阶段 I: ARCHITECTURE_SECURITY_AUDIT_REPORT.md<br>阶段 II/III: SECURITY_AUDIT_REPORT.md** |
| **结果** | 失败必须修复后才能继续 | 问题可接受/延期/修复 | **Critical 必须修复后才能继续/发布** |
| **修复粒度** | 文档级 | 模块级 | **阶段 I: XML 属性级<br>阶段 II/III: 代码行级** |
| **类比** | 编译器类型检查 | 代码审查 | **阶段 I: 安全设计审查<br>阶段 II/III: 安全渗透测试** |

### 7.2 3b（design-review）与 3c（安全审计）的边界

| 维度 | 3b design-review（Attacker Lens） | 3c sdlc-security-audit 阶段 I |
|------|----------------------------------|-------------------------------|
| **审查性质** | 定性推理（对抗性、主观判断） | 定量检测（规则匹配、客观事实） |
| **加密审查** | "TLS1.2 对金融数据是否足够？" | "`atRest` 是否在黑名单（DES/MD5/SHA1）中？" |
| **认证审查** | "订单服务绕过认证访问用户数据库是否合理？" | "`Interface` 节点是否有 `Authentication` 属性？" |
| **威胁审查** | "是否遗漏了内部威胁场景？" | "PRD 要求的审计日志是否有 `Audit` 节点？" |
| **输出** | 问题列表（Must Fix / Should Fix / Nice to Fix） | 缺陷报告（Critical/High/Medium + 覆盖度矩阵） |
| **可自动化** | 低（需要推理） | 高（规则引擎可直接检测） |

**为什么两者都需要**：
- `design-review` 可能发现"TLS1.2 不够"，但**不会**发现"`architecture.xml` 里不小心写成了 `DES`"
- `sdlc-security-audit` 阶段 I 可能发现"`atRest="DES"`，但**不会**判断"这个加密策略在10万 QPS 下是否合理"

### 7.3 为什么安全审计是阶段适配的

传统 Triple Verification 的一个矛盾是：3c（安全审计）被放在 design-review 之后，但此时还没有源代码，无法执行"代码级安全扫描"。

**v1.1 的解决方案**：
- **design-review 后**：3c 执行"架构文档安全审查"——审查 architecture.xml 中的安全设计缺陷（此时有文档可审）
- **module-design 后**：3c 执行"代码级安全扫描"——此时有源代码可扫
- **后续迭代**：3c 执行"增量安全扫描"——持续保障安全

**三者互补，不可替代**：
- 架构验证确保"设计文档是自洽的"
- 设计审查确保"设计决策是正确的"
- **安全审计确保"设计配置是正确的（阶段 I）且实现代码是安全的（阶段 II/III）"**

---

## 八、状态更新规则（阶段适配）

根据 `skill/tools/state-updater.md`：

**`sdlc-security-audit` 不转换阶段（phase transition）**，因为它是一个可选的补充步骤。但不同阶段的更新内容不同。

### 阶段 I 更新（架构文档审查后）

1. **不转换 phase**：`sdlc-security-audit` 不改变当前阶段
2. **更新 `Security Posture`**（`STATE.md` 中 v1.4 新增的 16 个章节之一）：
   - 发现的架构安全缺陷数量（Critical/High/Medium）
   - 安全需求覆盖度（PRD 安全需求 ↔ architecture.xml 实现映射）
   - 阻塞项（Critical 问题必须修复后才能进入 scaffolding）
3. **追加到 `Known Pitfalls`**：记录所有发现的架构安全风险
4. **更新 `ErrorLog`**：遵循 `skill/tools/error-tracing.md` 格式记录架构安全缺陷
   - `TraceID`：`{DecisionID}-{ErrorCode}-{Timestamp}`
   - `ErrorCode`：`SEC-ARCH-{Category}-{Number}`（如 `SEC-ARCH-WEAK-ENCRYPT-001`）
   - `状态`：`OPEN`（未修复）/ `CLOSED`（已修复）

### 阶段 II & III 更新（代码扫描后）

1. **不转换 phase**
2. **追加到 `Known Pitfalls`**：记录代码级安全风险
3. **更新 `ErrorLog`**：记录代码漏洞
   - `ErrorCode`：`SEC-{Category}-{Number}`（如 `SEC-SECRETS-001`）
   - `状态`：`OPEN`（未修复）/ `CLOSED`（已修复）
4. **追加到 `InterventionLog`**：如果用户应用了 `[APPLY]` 补丁

### Security Posture 章节示例（阶段 I 更新后）

```markdown
## Security Posture

**Last Updated**: 2026-05-12 10:00:00

### Architecture Security Review

| Check Item | Status | Issue Count |
|------------|--------|-------------|
| Weak Encryption Algorithm | Critical | 1 (3DES detected) |
| Interface Auth Coverage | Pass | 0 |
| Security Requirement Coverage | High | 1 (Audit missing) |
| Trust Boundary Definition | Pass | 0 |
| security.xml Completeness | Medium | 1 (ThreatModel empty) |

### Blocking Issues (Must Fix Before Scaffolding)
- [ ] SEC-ARCH-WEAK-ENCRYPT-001: `architecture.xml` uses `atRest="3DES"` → change to `AES-256`
```

---

## 九、人工门控

`sdlc-security-audit` 的门控与其他 DevForge Skill 不同——它不是"批准进入下一阶段"，而是"确认漏洞处理方案"。

### 9.1 呈现内容

- 漏洞摘要统计（Critical/High/Medium 数量和状态）
- 修复补丁概览（可自动修复的问题数量）
- 建议的修复时间线

### 9.2 可用命令

| 命令 | 行为 |
|------|------|
| `[APPROVE]` | 确认已知风险，继续开发流程 |
| `[APPLY]` | 应用 `SECURITY_FIX.patch` 中的所有修复 |
| `[APPLY {issue_id}]` | 仅应用指定问题的修复 |
| `[PAUSE]` | 暂停，人工审查漏洞后决定 |
| `[EXPLAIN {issue_id}]` | 展开解释某个漏洞的详细信息 |
| `[EDIT {file_path}]` | 手动编辑文件后让 AI 继续 |
| `[SKIP]` | 跳过本次安全审计（不推荐） |
| `[INJECT {context}]` | 补充额外上下文（如"这是测试代码"） |

### 9.3 自然语言反馈处理

如果用户输入自然语言（如"第 3 个漏洞不是问题，那个是测试用的"）：
- 分析用户意图
- 标记对应漏洞为 `IGNORED`（在报告中注明原因）
- 更新 ErrorLog 状态
- 重新呈现门控

---

## 十、CI/CD 集成（阶段适配）

`sdlc-security-audit` 设计为可无缝集成到 CI/CD 流程中，不同阶段的 CI 配置不同。

### 阶段 I：架构文档安全审查（设计阶段）

```yaml
# .github/workflows/architecture-security-audit.yml
name: Architecture Security Audit
on:
  pull_request:
    paths:
      - 'docs/architecture/system/architecture.xml'
      - 'docs/architecture/system/security.xml'
      - 'docs/architecture/system/INTERFACE_CONTRACT.md'
jobs:
  architecture-security-audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Architecture Security Audit
        run: devforge security-audit --phase architecture
      - name: Fail on Critical Architecture Issues
        run: |
          if grep -q "Critical" ARCHITECTURE_SECURITY_AUDIT_REPORT.md; then
            echo "Critical architecture security issues found. Blocking merge."
            exit 1
          fi
      - name: Upload Report
        uses: actions/upload-artifact@v4
        with:
          name: architecture-security-report
          path: PROJECT_SCAFFOLD/docs/architecture/validation/ARCHITECTURE_SECURITY_AUDIT_REPORT.md
```

### 阶段 II & III：代码安全扫描（编码/迭代阶段）

```yaml
# .github/workflows/security-audit.yml
name: Security Audit
on: [pull_request]
jobs:
  security-audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run SDLC Security Audit
        run: devforge security-audit --diff origin/main
      - name: Upload Report
        uses: actions/upload-artifact@v4
        with:
          name: security-report
          path: PROJECT_SCAFFOLD/docs/architecture/validation/SECURITY_AUDIT_REPORT.md
      - name: Fail on Critical Issues
        run: |
          if grep -q "Critical" SECURITY_AUDIT_REPORT.md; then
            echo "Critical security issues found. Blocking merge."
            exit 1
          fi
```

### 集成要点

| 阶段 | CI 触发条件 | 扫描范围 | 阻塞策略 |
|------|------------|----------|----------|
| **阶段 I** | `architecture.xml` / `security.xml` 变更时 | 架构文档 | Critical 架构安全问题阻塞进入 scaffolding |
| **阶段 II** | `module-design` 完成后 | 全量代码 | Critical 漏洞阻塞进入 test-execution |
| **阶段 III** | 每次 PR | 增量扫描（git diff） | Critical 漏洞阻塞合并 |

- **增量扫描**：仅扫描 PR 中的变更文件，速度秒级
- **阻塞策略**：发现 Critical 漏洞时自动阻塞合并
- **报告归档**：审计报告作为构建产物归档，供安全团队审查
- **安全需求覆盖度追踪**：阶段 I 的 `Security Posture` 章节可作为持续追踪安全基线的依据

---

## 十一、流程设计原理（Why Designed This Way）

### 11.1 为什么采用 8 维度 3 级别设计

| 设计决策 | 原因 |
|----------|------|
| **8 个扫描维度** | 覆盖 OWASP Top 10 的核心风险 + 供应链安全（依赖 CVE），同时避免维度过多导致扫描效率下降 |
| **3 个严重级别** | 对应行业标准的 Severity 分级，与 CVSS 评分体系兼容，便于安全团队理解 |
| **Critical 阻塞发布** | 硬编码密钥、SQL 注入、XSS 都是可导致系统完全沦陷的漏洞，必须零容忍 |
| **修复时间线** | Critical 24h / High 72h / Medium 7d 是业界普遍接受的安全修复 SLA |

### 11.2 为什么设计自动修复补丁

传统安全审计流程：
```
审计报告 → 开发者阅读 → 理解漏洞 → 编写修复 → 测试 → 提交
    ↑_________________________________________________↓
                        （循环数次）
```

DevForge 安全审计流程：
```
审计报告 + 自动补丁 → 用户审查补丁 → [APPLY] → 自动验证
```

> **设计意图**：安全修复最大的瓶颈不是"不知道有问题"，而是"修复太慢"。自动补丁将修复时间从小时级缩短到分钟级，同时确保修复质量（遵循安全最佳实践）。

### 11.3 为什么是可选而非必经

| 对比 | 必经（如 design-review） | 可选（如 security-audit） |
|------|------------------------|--------------------------|
| **适用场景** | 所有项目 | 有安全要求的项目 |
| **执行成本** | 必须承担 | 按需执行 |
| **阻塞性** | 阻塞流程 | 仅阻塞发布（Critical 时） |

> **设计意图**：并非所有项目都有严格的安全要求（如内部工具、原型系统）。将安全审计设计为可选步骤，允许用户根据项目特性决定投入。但强烈建议所有生产环境项目启用。

### 11.4 为什么设计三阶段适配模式（v1.1 核心变更）

**传统模式的矛盾**：
```
设计阶段（编码前）:
    design-review —— 发现架构安全问题（如"接口缺少鉴权"）
    threat-modeling —— 发现系统威胁（如"存在信息泄露风险"）
    security-audit —— ??? 无代码可扫，只能空转或跳过

编码阶段（编码后）:
    security-audit —— 发现实现漏洞（如"这行代码有 SQL 注入"）
    但架构层面的安全缺陷（如选用了 3DES）已固化到代码中，修复成本倍增
```

**阶段适配模式的解决**：
```
设计阶段（编码前）:
    design-review —— 架构安全问题
    threat-modeling —— 系统威胁
    sdlc-security-audit 阶段 I —— 架构文档安全审查（弱算法、接口暴露面、安全需求覆盖度）

编码阶段（编码后）:
    sdlc-security-audit 阶段 II —— 代码级全量扫描（注入、密钥泄露、CVE）

后续迭代:
    sdlc-security-audit 阶段 III —— 增量扫描（仅变更文件）
```

> **设计意图**：
> - **安全左移（Shift Left）**：在编码前发现架构层面的安全缺陷（如选用了 `3DES` 加密），避免缺陷被编码固化后修复成本倍增
> - **无代码时的价值**：即使没有源代码，architecture.xml 和 security.xml 中仍然可能存在严重的安全设计缺陷
> - **形成安全基线**：阶段 I 的审查结果（安全需求覆盖度矩阵）成为后续代码扫描的基准——如果 PRD 要求的"审计日志"在架构中未覆盖，后续代码即使写得再安全也无法满足合规要求
> - **持续保障**：阶段 III 的增量扫描确保每次代码提交都经过安全审查，防止"破窗效应"

### 11.5 为什么用 git diff 格式的补丁

- **标准化**：git diff 是开发者最熟悉的代码变更格式
- **可追溯**：补丁天然包含文件路径、行号、变更前后对比
- **可审查**：补丁可被纳入代码审查流程（Code Review）
- **可回滚**：如果补丁应用后发现问题，可用 `git checkout` 回滚
- **CI 友好**：可直接用于自动化修复流程

---

## 十二、常见误区与 Red Flags

### 与 `design-review` 的边界误区

| 误区 | 正确做法 |
|------|----------|
| **混淆两者职责**：用 `sdlc-security-audit` 阶段 I 做"加密策略是否充分"的判断 | 策略充分性由 `design-review` 的 Attacker Lens 负责；`security-audit` 阶段 I 只做"是否使用了黑名单算法"的规则检测 |
| **混淆两者职责**：用 `design-review` 做"`architecture.xml` 是否使用了 DES"的检查 | 具体算法黑名单检测由 `sdlc-security-audit` 阶段 I 负责；`design-review` 不做这种低层规则匹配 |
| **重复审查**：`design-review` 已发现加密问题，`security-audit` 阶段 I 又报告一次 | `design-review` 报告"策略问题"（如"TLS1.2 不够"），`security-audit` 报告"配置问题"（如"写成了 DES"），两者不重复 |

### 通用误区

| 误区 | 正确做法 |
|------|----------|
| 认为 design-review 已经足够，跳过 security-audit | 两者互补，design-review 无法自动发现 XML 中的弱算法配置 |
| 认为 security-audit 阶段 I 可以替代 design-review | 阶段 I 只做规则检测，不做对抗性推理，无法替代 design-review |
| 忽略 Medium 级别问题 | Medium 问题累计会增加攻击面，应按计划修复 |
| 将测试代码中的硬编码数据标记为 Critical | 人工复核时应识别上下文，测试代码可降级 |
| 应用补丁后不重新审计 | `[APPLY]` 后必须自动触发重新扫描 |
| 将安全审计仅作为上线前检查 | 应在每次代码提交、依赖变更时运行（阶段 III） |
| 忽略依赖安全问题 | `npm audit` / `pip-audit` 发现的 CVE 往往比代码漏洞更危险 |

---

## 十三、总结

`sdlc-security-audit` 是 DevForge SDLC Skill Chain 安全体系的**动态防线**——根据项目阶段自动调整审查深度和范围，覆盖从设计到迭代的全生命周期。

### 阶段适配的价值

| 阶段 | 解决的问题 | 核心价值 |
|------|-----------|----------|
| **阶段 I**（design-review 后） | 编码前发现架构安全缺陷 | **安全左移**：避免弱算法、安全需求遗漏被固化到代码中 |
| **阶段 II**（module-design 后） | 首次全面代码安全扫描 | **基线建立**：建立完整的代码安全基线，生成初始修复补丁 |
| **阶段 III**（后续迭代） | 每次变更的安全保障 | **持续保障**：增量扫描防止"破窗效应"，确保每次提交都安全 |

### 核心价值

1. **阶段适配**：根据项目阶段自动选择审查模式（架构文档审查 / 代码扫描 / 增量扫描），避免"无代码时空转"的尴尬
2. **安全左移**：阶段 I 在编码前发现架构层面的安全缺陷（如弱算法选择），修复成本最低
3. **自动修复**：不仅报告问题，还生成可直接应用的 git diff 修复补丁
4. **快速闭环**：扫描→修复→验证的完整流程可在分钟级完成
5. **CI/CD 原生**：增量扫描策略使其可无缝集成到提交前钩子和 PR 流程
6. **分级处理**：Critical/High/Medium 三级处理策略，确保关键漏洞优先修复

### 适用场景

| 场景 | 推荐阶段 |
|------|----------|
| 所有生产系统 | 阶段 I + II + III 全部启用 |
| 内部工具 / 原型 | 阶段 I（架构审查）即可 |
| 遗留代码库 | 阶段 II（全量扫描）建立基线，然后阶段 III（增量）持续保障 |
| 合规认证项目（SOC2、GDPR、等保） | 三阶段全部启用，阶段 I 的安全需求覆盖度矩阵是审计关键证据 |

### v1.1 关键改进

- **解决了 design-review 后无代码无法扫描的矛盾**：通过架构文档审查填充了这个空白期
- **引入了安全需求覆盖度矩阵**：让 PRD 安全需求 ↔ architecture.xml 实现的追踪变得可量化
- **更新了 Security Posture 章节**：与 v1.4 的 STATE.md 16 章节规范对齐
- **明确了与 `design-review` 的边界**：
  - `design-review`（Attacker Lens）→ 定性安全推理（"策略对不对"）
  - `security-audit` 阶段 I → 定量规则检测（"配置有没有 + 值在不在黑名单"）
  - 避免了两者的功能重叠和职责混淆

---

*分析基于 DevForge SDLC Skill Chain v1.4（2026-05-11）及 sdlc-security-audit v1.1（2026-05-12）*
