# sdlc-security-audit

**版本**: v1.1  
**类型**: 独立可选 Skill（阶段适配型）  
**定位**: 阶段适配型安全审查，覆盖架构文档安全审查（design-review 后）与代码级安全扫描（module-design 后）

---

## 1. 概述

`sdlc-security-audit` 是 DevForge SDLC Skill Chain 中专门负责**安全审查**的独立 Skill。本 Skill 是**阶段适配型**的 — 在 `design-review` 后无代码时，执行架构文档层面的安全审查（弱算法、接口暴露面、安全需求覆盖度）；在 `module-design` 后有代码时，执行代码级安全扫描（注入攻击、密钥泄露、CVE 等）。通过静态分析和模式匹配识别潜在漏洞，输出可执行的修复建议。

### 1.1 与 design-review 的区别

| 维度 | design-review | sdlc-security-audit |
|------|---------------|---------------------|
| **审查层级** | 架构 / 设计层面 | 代码 / 实现层面 |
| **关注焦点** | 数据流、信任边界、威胁建模 | 具体代码行、函数调用、配置项 |
| **输出产物** | 架构安全建议、威胁模型 | 漏洞报告、修复代码片段 |
| **执行时机** | 设计阶段（编码前） | 编码阶段、代码审查、提交前 |
| **检测能力** | 逻辑漏洞、设计缺陷 | 注入攻击、密钥泄露、不安全的 API 使用 |
| **修复粒度** | 模块级、接口级 | 函数级、代码行级 |

## Precondition Check

See `skill/tools/precondition-checker.md`. Acceptable phases: `design_review_completed`, `architecture_validated`, `module_design_completed`, `test_execution_completed`, `iteration_planning_completed`.
- If phase is earlier than `design_review_completed`, stop and instruct the user to complete `devforge-design-review` first.
- If `architecture.xml` is missing, stop and instruct the user to complete system-level architecture first.

## Language Adaptation

See `skill/tools/language-adaptation.md`.

## When to Use

`sdlc-security-audit` 是阶段适配型 Skill，根据当前项目阶段自动选择审查模式：

| 阶段 | 审查模式 | 扫描对象 | 触发方式 |
|------|----------|----------|----------|
| `design_review_completed` | **架构文档安全审查** | architecture.xml, INTERFACE_CONTRACT.md, PRD 安全需求 | 自动触发（用户可 `[SKIP]`） |
| `module_design_completed` | **代码级全量安全扫描** | 生成的源代码、配置文件、依赖清单 | 自动触发（用户可 `[SKIP]`） |
| `test_execution_completed` / `iteration_planning_completed` | **增量安全扫描** | git diff 变更文件、新增依赖 | 用户输入 `[SECURITY_AUDIT]` |

- 在 `design_review_completed` 阶段：仅审查架构文档层面的安全问题（弱算法、接口暴露面、安全需求覆盖度），**不扫描源代码**
- 在 `module_design_completed` 阶段：进行完整的代码级 8 维度安全扫描
- 在后续迭代阶段：每次 `[SECURITY_AUDIT]` 触发基于 git diff 的增量扫描

---

## 2. 触发条件

以下任一条件满足时，应触发 `sdlc-security-audit`：

### 阶段 I：架构文档安全审查（design-review 后）
1. `devforge-design-review` 完成后自动触发（无代码时）
2. 用户手动输入 `[SECURITY_AUDIT]` 且当前阶段为 `design_review_completed`

### 阶段 II：代码级全量安全扫描（module-design 完成后）
3. `devforge-module-design` 完成后自动触发（首次有源代码）
4. `devforge-project-scaffolding` 完成后用户手动触发 `[SECURITY_AUDIT]`

### 阶段 III：增量安全扫描（后续迭代）
5. **新代码提交**：开发者完成一个功能模块或修复后，准备提交 Pull Request 前。
6. **依赖变更**：`package.json`、`requirements.txt`、`pom.xml` 等依赖清单文件发生变更。
7. **敏感文件修改**：涉及认证、授权、加密、支付、用户隐私相关的代码文件被修改。
8. **定期巡检**：对核心模块或遗留代码库进行周期性安全扫描（建议每月一次）。

---

## 3. 扫描维度（阶段适配）

`sdlc-security-audit` 根据当前项目阶段自动选择审查维度。

### 阶段 I：架构文档安全审查（design-review 后，无代码时）

**审查对象**：`architecture.xml`, `INTERFACE_CONTRACT.md`, `PRD.md`, `security.xml`, `DECISION_LOG.md`

> **与 `devforge-design-review` 的分工边界**：
> - `design-review`（Attacker Lens）负责**定性安全推理**：评估加密策略是否充分（如"TLS1.2 对金融数据不够"）、认证架构是否合理（如"订单服务绕过认证直接访问用户数据库"）、威胁场景是否完整
> - `sdlc-security-audit` 阶段 I 负责**定量规则检测**：检查 XML 中是否使用了已知的弱算法、安全属性是否缺失、PRD 安全需求是否有对应的 XML 节点。本阶段不做"策略是否充分"的判断，只做"是否配置了 + 配置值是否在黑名单中"的规则匹配

| 级别 | 维度 | 描述 | 审查点 | 规则类型 |
|------|------|------|--------|----------|
| 🔴 Critical | **弱加密算法** | `architecture.xml` / `security.xml` 中声明了黑名单中的弱加密算法 | `Encryption atRest="DES"` / `atRest="MD5"` / `inTransit="TLS1.0"` 等 | 黑名单匹配 |
| 🔴 Critical | **安全属性缺失** | 关键接口或安全节点缺少必需的 XML 属性 | `Interface` 节点未定义 `Authentication` / `Authorization` 属性；`Security` 节点完全缺失 | Schema 必填检查 |
| 🟡 High | **安全需求遗漏** | PRD 中的安全需求在架构 XML 中无对应节点 | PRD 提到"需要审计日志"但 `architecture.xml` / `security.xml` 无 `Audit` 节点 | 需求追踪矩阵 |
| 🟡 High | **信任边界属性缺失** | 跨敏感模块的 `Coupling` 未声明安全传输协议 | `Coupling/DependsOn` 涉及支付/用户数据模块但无 `protocol="HTTPS"` / `protocol="gRPC+TLS"` | 规则匹配 |
| 🟢 Medium | **security.xml 完整性** | `security.xml` 缺少建议性节点 | 缺少 `KeyManagement`, `ThreatModel` 等（`Audit` 为必须，其余为建议） | Schema 完整性检查 |

**输出产物**：`ARCHITECTURE_SECURITY_AUDIT_REPORT.md`

### 阶段 II & III：代码级安全扫描（module-design 后有代码时）

安全扫描覆盖以下 8 个维度，按严重程度分为三级：

#### 🔴 Critical（严重）

| 维度 | 描述 | 常见场景 |
|------|------|----------|
| **硬编码密钥** | API Key、数据库密码、私钥等敏感信息直接写在代码中 | 配置文件、常量定义、测试代码 |
| **SQL 注入** | 用户输入直接拼接进 SQL 语句 | 动态查询、报表导出、搜索功能 |
| **XSS（跨站脚本）** | 用户输入未经转义直接输出到页面 | 富文本展示、评论系统、搜索回显 |

#### 🟡 High（高危）

| 维度 | 描述 | 常见场景 |
|------|------|----------|
| **不安全依赖** | 使用存在已知 CVE 的第三方库 | 过期框架、未修复的 npm/pip 包 |
| **不安全文件操作** | 路径遍历、任意文件上传/下载 | 文件上传接口、导出功能、静态资源服务 |
| **敏感数据日志** | 密码、Token、身份证号等被记录到日志 | 登录接口、支付回调、调试日志 |

#### 🟢 Medium（中危）

| 维度 | 描述 | 常见场景 |
|------|------|----------|
| **弱加密算法** | 使用 MD5、SHA1、DES 等已不安全的算法 | 密码哈希、数据加密、签名验证 |
| **越权访问** | 缺少权限校验或校验逻辑绕过 | 管理接口、数据查询、资源访问 |

---

## 4. 工作流程（阶段适配）

`sdlc-security-audit` 根据当前项目阶段自动适配工作流。

---

### 阶段 I：架构文档安全审查（design-review 后，无代码）

**适用阶段**：`design_review_completed`

#### Step 1-I: 范围确定
- 读取 `architecture.xml`, `security.xml`, `INTERFACE_CONTRACT.md`, `PRD.md`
- 标记需审查的安全相关节点：`Security`, `Interface`, `Coupling`, `DataModel`

#### Step 2-I: 架构文档静态分析

**⚠️ 与 `devforge-design-review` 的分工**：本步骤只做**规则匹配和存在性检查**，不做策略合理性判断。策略合理性（如"TLS1.2 是否足够"）由 `design-review` 的 Attacker Lens 负责。

**2-I.1 弱算法扫描（黑名单规则匹配）**

检查 `architecture.xml` / `security.xml` 中 `Encryption` 属性：
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
- PRD 要求"审计日志" → `security.xml` 是否有 `Audit` 节点
- PRD 要求"数据加密" → `architecture.xml` 是否有 `Encryption` 节点
- 输出"安全需求覆盖度矩阵"——量化追踪，不是定性判断

**2-I.4 信任边界属性检查（规则匹配）**

检查 `Coupling/DependsOn` 中敏感模块间的调用：
- 涉及支付、用户数据的模块间调用是否声明 `protocol` 属性（如 `HTTPS`, `gRPC+TLS`）
- **注意**：不判断"协议选择是否合理"，只检查"是否声明了安全传输协议"

#### Step 3-I: 分级定级
- 按 Critical / High / Medium 分级
- **注意**：此阶段不生成代码修复补丁（无代码可修），仅输出架构修改建议

#### Step 4-I: 修复建议
- 提供 `architecture.xml` / `security.xml` 的修改建议（XML 片段）
- 标注所需工作量

#### Step 5-I: 报告输出
- 生成 `ARCHITECTURE_SECURITY_AUDIT_REPORT.md`
- 包含：发现的架构安全缺陷、修改建议、安全需求覆盖度矩阵

---

### 阶段 II：代码级全量安全扫描（module-design 完成后，首次有代码）

**适用阶段**：`module_design_completed`, `scaffolding_completed`

#### Step 1-II: 范围确定
- 扫描范围：**全量扫描**（首次代码级扫描）
- 识别所有源代码文件、配置文件、依赖清单
- 标记敏感文件（认证、支付、加密、隐私相关）

#### Step 2-II: 静态分析
- 使用工具扫描（如 Semgrep、CodeQL、Bandit、ESLint Security）
- 执行正则规则匹配（硬编码密钥、危险函数）
- 分析依赖树（`npm audit`、`pip-audit`、`trivy`）

#### Step 3-II: 人工复核
- 过滤误报（工具报告的假阳性）
- 确认漏洞可利用性
- 评估业务影响范围

#### Step 4-II: 分级定级
- 按 Critical / High / Medium 分级
- 标注 CVSS 评分（如适用）
- 确定修复优先级

#### Step 5-II: 修复建议
- 提供具体代码修复示例
- 标注修复所需工作量
- 建议修复时间线（Critical 24h 内，High 72h 内，Medium 7d 内）

#### Step 5a-II: 自动修复 Diff 生成
- 对每个 Critical/High 问题，生成 `git diff` 格式的修复补丁
- 输出文件：`SECURITY_FIX_{issue_id}.patch`
- 补丁格式要求：
  ```diff
  --- a/src/path/to/file.js
  +++ b/src/path/to/file.js
  @@ -10,7 +10,7 @@
  - const password = 'MyP@ssw0rd123!';
  + const password = process.env.DB_PASSWORD;
  ```
- 生成汇总文件：`SECURITY_FIX.patch`（合并所有修复）
- 用户可通过 `[APPLY]` 命令直接应用所有补丁
- 应用后自动触发重新审计

#### Step 6-II: 报告输出
- 生成 `SECURITY_AUDIT_REPORT.md`
- 在代码中插入内联安全注释
- 输出修复补丁：`SECURITY_FIX.patch`（如存在可修复问题）

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
- 过滤误报
- 确认漏洞可利用性
- 评估业务影响范围

#### Step 4-III: 分级定级
- 按 Critical / High / Medium 分级

#### Step 5-III: 修复建议 + 自动修复 Diff
- 提供代码修复示例
- 生成增量修复补丁：`SECURITY_FIX.patch`
- 用户可通过 `[APPLY]` 应用

#### Step 6-III: 报告输出
- 生成增量审计报告：`SECURITY_AUDIT_REPORT.md`
- 报告标注本次扫描为"增量扫描"及变更文件范围

---

## 5. 输出产物（阶段适配）

### 阶段 I 产物：架构安全审计报告（ARCHITECTURE_SECURITY_AUDIT_REPORT.md）

**路径**：`PROJECT_SCAFFOLD/docs/architecture/validation/ARCHITECTURE_SECURITY_AUDIT_REPORT.md`

```markdown
# Architecture Security Audit Report

**Generated**: 2026-05-12 10:00:00 UTC+8
**Phase**: architecture_document_review
**Scope**: architecture.xml, security.xml, INTERFACE_CONTRACT.md, PRD.md
**Auditor**: sdlc-security-audit Skill v1.1

---

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

## High Issues

### [H-001] 缺少审计日志节点
- **File**: `security.xml`
- **Location**: `Security` 根节点下
- **PRD Reference**: PRD.md:45 ("所有管理员操作必须记录审计日志")
- **Risk**: 架构未覆盖 PRD 安全需求，可能导致合规审计失败。
- **Fix**: 在 `security.xml` 中添加 `Audit` 节点
- **Deadline**: 修复后进入 scaffolding 阶段

## Recommendations

1. 将 `architecture.xml` 中 `Encryption/@atRest` 从 `3DES` 更新为 `AES-256`
2. 在 `security.xml` 中补充 `Audit` 节点，配置 `LogEvents` 和 `Retention`
3. 建议在 `devforge-threat-modeling` 阶段补充 `ThreatModel` 节点
```

---

### 阶段 II & III 产物：代码安全审计报告（SECURITY_AUDIT_REPORT.md）

```markdown
# Security Audit Report

**Generated**: 2026-04-29 14:30:00 UTC+8  
**Scope**: `src/auth/`, `src/payment/`, `config/`, `package.json`  
**Auditor**: sdlc-security-audit Skill v1.0  
**Commit**: `a1b2c3d`

---

## Summary

| Severity | Count | Status |
|----------|-------|--------|
| Critical | 2 | 待修复 |
| High     | 3 | 待修复 |
| Medium   | 1 | 待修复 |

---

## Critical Issues

### [C-001] 硬编码数据库密码

- **File**: `config/database.js`
- **Line**: 12
- **Risk**: 数据库密码明文存储在代码仓库中，一旦泄露将导致生产数据库完全暴露。
- **Fix**:
  ```javascript
  // Before
  const password = 'MyP@ssw0rd123!';

  // After
  const password = process.env.DB_PASSWORD;
  ```
- **Rule**: `security.secrets.hardcoded-password`
- **Deadline**: 立即修复，24 小时内

### [C-002] SQL 注入漏洞

- **File**: `src/user/search.js`
- **Line**: 45
- **Risk**: 用户输入直接拼接到 SQL 查询中，攻击者可提取或篡改数据库全部数据。
- **Fix**:
  ```javascript
  // Before
  const query = `SELECT * FROM users WHERE name = '${req.body.name}'`;

  // After
  const query = 'SELECT * FROM users WHERE name = ?';
  db.query(query, [req.body.name]);
  ```
- **Rule**: `security.sql.injection`
- **Deadline**: 立即修复，24 小时内

---

## High Issues

### [H-001] 存在已知 CVE 的依赖包

- **File**: `package.json`
- **Line**: 23
- **Risk**: `lodash@4.17.15` 存在 CVE-2020-8203（原型污染），可能导致权限绕过。
- **Fix**:
  ```json
  // Before
  "lodash": "^4.17.15"

  // After
  "lodash": "^4.17.21"
  ```
- **Rule**: `security.dependencies.known-cve`
- **Deadline**: 72 小时内

### [H-002] 路径遍历漏洞

- **File**: `src/file/download.js`
- **Line**: 18
- **Risk**: 文件名未做校验，攻击者可通过 `../` 访问服务器任意文件。
- **Fix**:
  ```javascript
  // Before
  const filePath = `./uploads/${req.query.filename}`;

  // After
  const path = require('path');
  const filePath = path.resolve('./uploads', req.query.filename);
  if (!filePath.startsWith(path.resolve('./uploads'))) {
    return res.status(403).send('Access denied');
  }
  ```
- **Rule**: `security.files.path-traversal`
- **Deadline**: 72 小时内

### [H-003] 敏感信息写入日志

- **File**: `src/auth/login.js`
- **Line**: 34
- **Risk**: 用户密码被记录到日志文件，日志泄露将导致凭证暴露。
- **Fix**:
  ```javascript
  // Before
  logger.info(`User login attempt: ${JSON.stringify(req.body)}`);

  // After
  const { password, ...safeBody } = req.body;
  logger.info(`User login attempt: ${JSON.stringify(safeBody)}`);
  ```
- **Rule**: `security.logging.sensitive-data`
- **Deadline**: 72 小时内

---

## Medium Issues

### [M-001] 使用弱哈希算法 MD5

- **File**: `src/utils/hash.js`
- **Line**: 8
- **Risk**: MD5 已被证明存在碰撞攻击，不适用于密码存储场景。
- **Fix**:
  ```javascript
  // Before
  const crypto = require('crypto');
  const hash = crypto.createHash('md5').update(password).digest('hex');

  // After
  const bcrypt = require('bcrypt');
  const hash = await bcrypt.hash(password, 12);
  ```
- **Rule**: `security.crypto.weak-hash`
- **Deadline**: 7 天内

---

## Fix Priority

1. **Critical**: 24 小时内必须修复，阻塞发布
2. **High**: 72 小时内修复，纳入当前迭代
3. **Medium**: 7 天内修复，排入下个迭代

---

## Appendix

- 扫描工具: Semgrep v1.0, npm audit, custom rules
- 规则集: security-audit-rules-v1.0
- 误报说明: 无
```

### 5.2 内联代码注释格式

在扫描过程中，可在代码中插入临时安全注释（需在修复后移除）：

```javascript
// [SECURITY-AUDIT] Critical: 硬编码密钥
// Rule: security.secrets.hardcoded-password
// Fix: 使用 process.env.DB_PASSWORD 替代
// Deadline: 2026-04-30
const password = 'MyP@ssw0rd123!';

// [SECURITY-AUDIT] High: 路径遍历风险
// Rule: security.files.path-traversal
// Fix: 校验文件路径是否在允许目录内
// Deadline: 2026-05-02
const filePath = `./uploads/${req.query.filename}`;
```

---

## 6. 使用示例

### 6.1 阶段 I：架构文档安全审查（design-review 后）

```bash
# 自动触发（design-review 完成后）
# 扫描对象：architecture.xml, security.xml, INTERFACE_CONTRACT.md
# 输出：ARCHITECTURE_SECURITY_AUDIT_REPORT.md

# 手动触发架构文档审查
devforge security-audit --phase architecture --report PROJECT_SCAFFOLD/docs/architecture/validation/ARCHITECTURE_SECURITY_AUDIT_REPORT.md
```

### 6.2 阶段 II：代码级全量扫描（module-design 完成后）

```bash
# 全量扫描（首次有代码时）
devforge security-audit --all

# 指定目录扫描
devforge security-audit --path src/auth/

# 生成报告
devforge security-audit --report PROJECT_SCAFFOLD/docs/architecture/validation/SECURITY_AUDIT_REPORT.md
```

### 6.3 阶段 III：增量扫描（后续迭代）

```bash
# 增量扫描（基于 git diff）
devforge security-audit --diff HEAD~1

# 生成报告
devforge security-audit --report PROJECT_SCAFFOLD/docs/architecture/validation/SECURITY_AUDIT_REPORT.md
```

### 6.4 集成到 CI/CD

#### 阶段 I：架构文档审查（设计阶段）

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

#### 阶段 II & III：代码安全扫描（编码/迭代阶段）

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

---

## 7. 规则扩展

项目可根据技术栈自定义扫描规则：

| 技术栈 | 规则文件 | 工具 |
|--------|----------|------|
| JavaScript/Node.js | `rules/js-security.yaml` | Semgrep, ESLint |
| Python | `rules/py-security.yaml` | Bandit, Semgrep |
| Java | `rules/java-security.yaml` | CodeQL, SpotBugs |
| Go | `rules/go-security.yaml` | gosec, Semgrep |
| 通用 | `rules/common-secrets.yaml` | GitLeaks, truffleHog |

## State Update

See `skill/tools/state-updater.md`. This skill does not transition phase; it appends findings to `Known Pitfalls` and updates `Security Posture`.

### 阶段 I 更新（架构文档审查后）

- **不转换 phase**：`sdlc-security-audit` 不改变当前阶段
- **更新 `Security Posture`**：在 `STATE.md` 的 Security Posture 章节记录：
  - 发现的架构安全缺陷数量（Critical/High/Medium）
  - 安全需求覆盖度（PRD 安全需求 ↔ architecture.xml 实现映射）
  - 阻塞项（Critical 问题必须修复后才能进入 scaffolding）
- **追加到 `Known Pitfalls`**：记录所有发现的风险
- **更新 `ErrorLog`**：遵循 `skill/tools/error-tracing.md` 格式记录架构安全缺陷

### 阶段 II & III 更新（代码扫描后）

- **不转换 phase**
- **追加到 `Known Pitfalls`**：记录代码级安全风险
- **更新 `ErrorLog`**：记录代码漏洞（状态：OPEN → CLOSED 随修复更新）
- **追加到 `InterventionLog`**：如果用户应用了 `[APPLY]` 补丁

---

## 8. 版本历史

| 版本 | 日期 | 变更说明 |
|------|------|----------|
| v1.1 | 2026-05-12 | **阶段适配重构**：将单一扫描流程重构为三阶段适配模式 — 阶段 I（design-review 后架构文档安全审查）、阶段 II（module-design 后代码级全量扫描）、阶段 III（后续迭代增量扫描）。解决 design-review 后无代码无法扫描的矛盾。 |
| v1.0 | 2026-04-29 | 初始版本，覆盖 8 个核心扫描维度 |

---

*本 Skill 由 DevForge SDLC Skill Chain 提供，遵循安全最佳实践与最小权限原则。*
