# sdlc-security-audit

**版本**: v1.0  
**类型**: 独立可选 Skill  
**定位**: 代码级安全扫描，作为 `design-review` 的补充

---

## 1. 概述

`sdlc-security-audit` 是 DevForge SDLC Skill Chain 中专门负责**代码级安全扫描**的独立 Skill。与 `design-review` 的架构层面安全审查不同，本 Skill 聚焦于源代码中的具体安全缺陷，通过静态分析和模式匹配识别潜在漏洞，输出可执行的修复建议。

### 1.1 与 design-review 的区别

| 维度 | design-review | sdlc-security-audit |
|------|---------------|---------------------|
| **审查层级** | 架构 / 设计层面 | 代码 / 实现层面 |
| **关注焦点** | 数据流、信任边界、威胁建模 | 具体代码行、函数调用、配置项 |
| **输出产物** | 架构安全建议、威胁模型 | 漏洞报告、修复代码片段 |
| **执行时机** | 设计阶段（编码前） | 编码阶段、代码审查、提交前 |
| **检测能力** | 逻辑漏洞、设计缺陷 | 注入攻击、密钥泄露、不安全的 API 使用 |
| **修复粒度** | 模块级、接口级 | 函数级、代码行级 |

---

## 2. 触发条件

以下任一条件满足时，应触发 `sdlc-security-audit`：

1. **新代码提交**：开发者完成一个功能模块或修复后，准备提交 Pull Request 前。
2. **依赖变更**：`package.json`、`requirements.txt`、`pom.xml` 等依赖清单文件发生变更。
3. **敏感文件修改**：涉及认证、授权、加密、支付、用户隐私相关的代码文件被修改。
4. **定期巡检**：对核心模块或遗留代码库进行周期性安全扫描（建议每月一次）。

---

## 3. 扫描维度

安全扫描覆盖以下 8 个维度，按严重程度分为三级：

### 🔴 Critical（严重）

| 维度 | 描述 | 常见场景 |
|------|------|----------|
| **硬编码密钥** | API Key、数据库密码、私钥等敏感信息直接写在代码中 | 配置文件、常量定义、测试代码 |
| **SQL 注入** | 用户输入直接拼接进 SQL 语句 | 动态查询、报表导出、搜索功能 |
| **XSS（跨站脚本）** | 用户输入未经转义直接输出到页面 | 富文本展示、评论系统、搜索回显 |

### 🟡 High（高危）

| 维度 | 描述 | 常见场景 |
|------|------|----------|
| **不安全依赖** | 使用存在已知 CVE 的第三方库 | 过期框架、未修复的 npm/pip 包 |
| **不安全文件操作** | 路径遍历、任意文件上传/下载 | 文件上传接口、导出功能、静态资源服务 |
| **敏感数据日志** | 密码、Token、身份证号等被记录到日志 | 登录接口、支付回调、调试日志 |

### 🟢 Medium（中危）

| 维度 | 描述 | 常见场景 |
|------|------|----------|
| **弱加密算法** | 使用 MD5、SHA1、DES 等已不安全的算法 | 密码哈希、数据加密、签名验证 |
| **越权访问** | 缺少权限校验或校验逻辑绕过 | 管理接口、数据查询、资源访问 |

---

## 4. 工作流程

安全扫描遵循以下 6 步流程：

### Step 1: 范围确定
- 识别变更文件列表（`git diff --name-only`）
- 标记敏感文件（认证、支付、加密、隐私相关）
- 确定扫描范围：增量扫描或全量扫描

### Step 2: 静态分析
- 使用工具扫描（如 Semgrep、CodeQL、Bandit、ESLint Security）
- 执行正则规则匹配（硬编码密钥、危险函数）
- 分析依赖树（`npm audit`、`pip-audit`、`trivy`）

### Step 3: 人工复核
- 过滤误报（工具报告的假阳性）
- 确认漏洞可利用性
- 评估业务影响范围

### Step 4: 分级定级
- 按 Critical / High / Medium 分级
- 标注 CVSS 评分（如适用）
- 确定修复优先级

### Step 5: 修复建议
- 提供具体代码修复示例
- 标注修复所需工作量
- 建议修复时间线（Critical 24h 内，High 72h 内，Medium 7d 内）

### Step 6: 报告输出
- 生成 `SECURITY_AUDIT_REPORT.md`
- 在代码中插入内联安全注释
- 归档至项目安全知识库

---

## 5. 输出产物

### 5.1 安全审计报告（SECURITY_AUDIT_REPORT.md）

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

### 6.1 触发扫描

```bash
# 增量扫描（基于 git diff）
devforge security-audit --diff HEAD~1

# 全量扫描
devforge security-audit --all

# 指定目录扫描
devforge security-audit --path src/auth/

# 生成报告
devforge security-audit --report SECURITY_AUDIT_REPORT.md
```

### 6.2 集成到 CI/CD

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
          path: SECURITY_AUDIT_REPORT.md
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

---

## 8. 版本历史

| 版本 | 日期 | 变更说明 |
|------|------|----------|
| v1.0 | 2026-04-29 | 初始版本，覆盖 8 个核心扫描维度 |

---

*本 Skill 由 DevForge SDLC Skill Chain 提供，遵循安全最佳实践与最小权限原则。*
