# DevForge Threat Modeling 流程深度分析

> 基于 DevForge SDLC Skill Chain v1.4 的 `devforge-threat-modeling/SKILL.md` 及其关联工具规范文档进行系统性分析。
>
> **定位**：结构化威胁建模 Skill，使用 STRIDE 方法论对已批准架构进行系统级安全分析，输出威胁矩阵、缓解措施和安全测试用例。

---

## 一、定位与核心区别

### 1.1 Skill 定位

`devforge-threat-modeling` 是 DevForge SDLC Skill Chain v1.4 引入的专门负责**系统级威胁建模**的独立 Skill。它使用微软 STRIDE 方法论，在已批准的架构上识别系统级威胁，输出可执行的缓解措施和对应的安全测试用例。

它填补了 `devforge-design-review`（对抗性审查）和 `sdlc-security-audit`（代码级安全扫描）之间的空白：

| 维度 | `devforge-design-review` | `devforge-threat-modeling` | `sdlc-security-audit` |
|------|------------------------|---------------------------|----------------------|
| **审查层级** | 架构 / 设计层面 | **系统威胁建模层面** | 代码 / 配置层面 |
| **方法论** | Attacker Lens（对抗性检查） | **STRIDE（结构化威胁分析）** | 规则匹配 + 静态扫描 |
| **关注焦点** | 设计缺陷、可扩展性、可操作性 | **系统级威胁场景、攻击路径** | 具体漏洞、密钥泄露、CVE |
| **输出产物** | 问题列表（Must Fix/Should Fix） | **威胁矩阵 + 缓解措施 + 安全测试用例** | 漏洞报告 / 修复补丁 |
| **执行时机** | design-review 阶段 | **design-review 后，编码前** | design-review 后 / module-design 后 |
| **检测能力** | 定性推理（"策略是否充分"） | **结构化威胁识别（6 个维度）** | 定量规则检测 |
| **是否必经** | 是（默认运行） | **可选（高安全项目推荐）** | 可选（推荐） |
| **DIVE 阶段** | Verify | **Verify** | Verify |

### 1.2 为什么需要独立的威胁建模 Skill

> **设计意图**：
> 1. **填补验证空白**：design-review 的 Attacker Lens 是通用的对抗性检查，而 threat-modeling 使用标准化的 STRIDE 方法论，确保威胁覆盖的系统性和完整性
> 2. **产出物差异**：design-review 输出"问题列表"，threat-modeling 输出"威胁矩阵 + 缓解措施 + 安全测试用例"——后者更结构化、可追踪、可验证
> 3. **与 security-audit 的分工**：
>    - threat-modeling 在**编码前**识别系统级威胁（如"缺少审计日志导致无法追溯"）
>    - security-audit 在**编码后**扫描具体漏洞（如"SQL 注入"）
>    - 两者互补：威胁建模回答"系统面临什么威胁"，安全审计回答"代码中有什么漏洞"
> 4. **合规需求**：许多安全合规框架（如 SOC 2、ISO 27001）要求正式的威胁建模过程

### 1.3 与 design-review Attacker Lens 的区别

| 维度 | design-review（Attacker Lens） | threat-modeling（STRIDE） |
|------|-------------------------------|--------------------------|
| **方法论** | 自由式对抗性审查 | **标准化的 6 维度检查表** |
| **输出形式** | 问题列表（主观判断） | **威胁矩阵（结构化评分）** |
| **缓解措施** | 建议性 | **具体的技术/流程/补偿控制** |
| **测试用例** | 无 | **每个缓解措施对应一个安全测试用例** |
| **可追溯性** | 弱 | **每个威胁映射到 Module/Interface** |
| **XML 更新** | 无 | **更新 `architecture.xml/Security/ThreatModel` 节点** |

> **关键区别**：design-review 的 Attacker Lens 是"资深架构师凭经验找问题"，threat-modeling 是"按照标准方法论系统化地识别威胁"。两者都发现安全问题，但 threat-modeling 的输出更结构化、更可验证、更适合合规审计。

---

## 二、触发条件与前置检查

### 2.1 触发条件

| 触发方式 | 场景 | 说明 |
|----------|------|------|
| **用户输入 `[THREAT_MODEL]`** | design-review 完成后，用户需要正式威胁建模 | 最常见的触发方式 |
| **高安全项目自动触发** | design-review 完成后，项目带有 `high-security` 标签 | 自动加载，用户可 `[SKIP]` |
| **架构更新后重新触发** | `architecture.xml` 发生安全相关变更后 | 重新评估威胁场景 |

### 2.2 前置条件校验

根据 `skill/tools/precondition-checker.md`：

| 校验项 | 要求 |
|--------|------|
| **Acceptable Phases** | `design_review_completed`, `architecture_validated`, `module_design_completed` |
| **Minimum Phase** | `design_review_completed` |
| **Required Artifact** | `architecture.xml` |

**不满足条件时的行为**：
- 如果阶段早于 `design_review_completed` → 停止执行，提示用户先完成 `devforge-design-review`
- 如果 `architecture.xml` 不存在 → 停止执行，提示用户先完成 `devforge-architecture-design`

### 2.3 为什么要求 design-review_completed

> **设计意图**：
> - threat-modeling 需要在 architecture.xml 已经过 design-review 的对抗性审查之后运行
> - design-review 可能已经发现了一些安全问题，threat-modeling 在此基础上进行更系统化的分析
> - 如果 design-review 发现了严重的架构安全缺陷，应先修复后再进行威胁建模（否则威胁模型基于有缺陷的架构）
> - 这确保了 threat-modeling 分析的是"已审查过的"架构，而非原始设计

---

## 三、输出产物

`devforge-threat-modeling` 生成三类产物：

| 产物 | 路径 | 内容 | 用途 |
|------|------|------|------|
| **威胁建模报告** | `docs/architecture/validation/THREAT_MODEL_REPORT.md` | 威胁矩阵、风险评级、缓解措施、安全测试用例 | 安全团队审查、合规审计证据 |
| **更新 architecture.xml** | `docs/architecture/system/architecture.xml` | 填充 `Security/ThreatModel` 节点 | 架构权威文档的安全增强 |
| **更新 security.xml** | `docs/architecture/system/security.xml` | 添加 `Mitigations` 章节 | 安全策略文档的缓解措施 |

### 3.1 产物详细内容

#### THREAT_MODEL_REPORT.md 结构

```markdown
# Threat Model Report

## Executive Summary
- 总威胁数、Critical/High/Medium/Low 分布
- 关键发现摘要

## Threat Matrix

| Threat ID | STRIDE | Module | Interface | Likelihood | Impact | Risk | Mitigation |
|-----------|--------|--------|-----------|------------|--------|------|------------|
| T-001 | Spoofing | UserService | /login | Likely | High | Critical | 实施 MFA |
| T-002 | Tampering | OrderService | /create | Possible | High | High | 请求签名验证 |
| ... | ... | ... | ... | ... | ... | ... | ... |

## Mitigations

### Critical Threats
#### T-001: Spoofing against UserService
- **威胁描述**：攻击者可伪造用户身份...
- **技术控制**：实施多因素认证（MFA）
- **流程控制**：异常登录告警
- **补偿控制**：IP 白名单（如 MFA 不可行）

## Security Test Cases

### TC-SEC-001: MFA Enforcement
- **对应威胁**：T-001
- **验证方法**：尝试使用单因素认证登录，应被拒绝
- **通过标准**：返回 403，提示需要第二因素

## Appendix
- STRIDE 覆盖率检查
- 未覆盖的模块/接口说明
```

### 3.2 为什么更新 architecture.xml

> **设计意图**：威胁建模的发现应反馈到架构权威文档中。`architecture.xml/Security/ThreatModel` 节点的填充实现了：
> 1. **架构与安全的统一**：安全威胁成为架构文档的一部分，而非独立的外部文档
> 2. **可追溯性**：后续安全审计可以直接从 XML 中读取威胁信息
> 3. **增量更新**：架构变更后，威胁模型可以基于 XML 中的 ThreatModel 节点进行增量更新

---

## 四、完整工作流程

`devforge-threat-modeling` 的工作流程分为 8 个步骤：

```
Step 1: 加载架构上下文
    → 读取 architecture.xml, PRD.md, INTERFACE_CONTRACT.md, security.xml
    → 提取所有 Module ID、Interface 定义、信任边界
    → 识别外部依赖和第三方集成

Step 2: 按模块进行 STRIDE 分析
    → 对每个 Module，评估 6 个 STRIDE 维度
    → Spoofing / Tampering / Repudiation / Information Disclosure / DoS / Elevation

Step 3: 风险评级
    → Likelihood × Impact 矩阵
    → 输出 Critical / High / Medium / Low

Step 4: 缓解措施生成
    → 对每个 Critical/High 威胁生成具体缓解措施
    → 技术控制 / 流程控制 / 补偿控制

Step 5: 安全测试用例生成
    → 将每个缓解措施转换为可测试的安全需求
    → 输出 TC-SEC-{NNN} 格式的测试用例

Step 6: 产物输出
    → 写入 THREAT_MODEL_REPORT.md
    → 更新 architecture.xml/Security/ThreatModel
    → 更新 security.xml/Mitigations

Step 7: 自验证
    → 验证每个威胁引用有效的 Module ID
    → 验证每个缓解措施可实施
    → 验证 STRIDE 覆盖率（每个维度至少一个威胁）

Step 8: 人工门控
    → 呈现威胁摘要，等待用户确认
```

---

### Step 1: 加载架构上下文

**输入文件**：
- `architecture.xml`（必需）— 模块定义、接口、数据模型、状态模型、安全策略
- `PRD.md`（必需）— 业务需求，帮助理解哪些功能是高价值攻击目标
- `INTERFACE_CONTRACT.md`（必需）— 接口契约，定义信任边界
- `security.xml`（可选）— 现有安全策略，避免重复分析

**提取的信息**：

| 信息类型 | XML 来源 | 用途 |
|----------|----------|------|
| 模块列表 | `SystemArchitecture/Module/@id` | STRIDE 分析的遍历对象 |
| 接口定义 | `Module/Interface/Input` + `Output` | 识别攻击面 |
| 认证机制 | `Security/Authentication/@type` | Spoofing 分析 |
| 授权策略 | `Security/Authorization/@model` | Elevation 分析 |
| 审计配置 | `Security/Audit` | Repudiation 分析 |
| 加密策略 | `Security/Encryption` | Information Disclosure 分析 |
| 状态模型 | `StateModel/State` | 数据流威胁分析 |
| 耦合关系 | `Module/Coupling/DependsOn` | 信任边界识别 |
| PII 字段 | `DataModel/Fields/Field/@isPII="true"` | Information Disclosure 优先级 |

**信任边界识别**：
> 信任边界是威胁建模的核心概念——它是系统中"信任级别发生变化"的边界。在 architecture.xml 中，信任边界可以从以下信息推断：
> - `Module/Interface` — 模块的公共接口是信任边界（外部不可信输入进入系统）
> - `Module/Coupling/DependsOn` — 跨模块调用是信任边界（模块 A 信任模块 B 吗？）
> - 外部系统（从 `DependsOn` 推断的外部依赖）— 系统与外部世界的边界是最关键的信任边界

---

### Step 2: 按模块进行 STRIDE 分析

STRIDE 是微软开发的威胁分类框架，涵盖 6 种威胁类型：

| 维度 | 英文 | 核心问题 | 典型攻击场景 | 关键接口 |
|------|------|----------|-------------|----------|
| **S**poofing | 假冒 | 攻击者能否冒充此模块/用户？ | 伪造 JWT、会话劫持、API 密钥盗窃 | Authentication 接口 |
| **T**ampering | 篡改 | 流向/流出此模块的数据能否被修改？ | 中间人攻击、请求参数篡改、响应篡改 | 所有 Input/Output 接口 |
| **R**epudiation | 抵赖 | 此模块的操作能否被否认？ | 删除审计日志、伪造操作记录 | Audit logging 接口 |
| **I**nformation Disclosure | 信息泄露 | 敏感数据是否会被暴露？ | SQL 注入提取数据、日志泄露密码、错误信息暴露堆栈 | 处理 PII/密钥的接口 |
| **D**enial of Service | 拒绝服务 | 此模块能否被搞到不可用？ | DDoS、资源耗尽攻击、慢速攻击 | Public-facing 接口 |
| **E**levation of Privilege | 权限提升 | 权限能否被提升？ | 垂直越权（普通用户→管理员）、水平越权（用户A→用户B） | Admin/Authorization 接口 |

**分析流程**：

```
对每个 Module in architecture.xml:
    对 6 个 STRIDE 维度:
        检查该模块的接口是否面临此类威胁
        检查该模块的数据流是否面临此类威胁
        检查该模块的依赖关系是否引入此类威胁
        如果存在威胁 → 记录威胁详情
```

**示例分析**：

假设 `UserService` 模块有以下接口：
- `POST /login` — 用户登录
- `POST /register` — 用户注册
- `GET /profile` — 获取用户资料

STRIDE 分析结果：

| 维度 | 威胁描述 | 接口 |
|------|----------|------|
| Spoofing | 攻击者可能伪造 JWT 令牌冒充其他用户 | `/profile` |
| Tampering | 注册请求中的邮箱可能被中间人篡改 | `/register` |
| Repudiation | 登录操作无审计日志，攻击者登录后无法追溯 | `/login` |
| Info Disclosure | 错误响应可能暴露数据库结构 | `/login` (错误时) |
| DoS | 登录接口无速率限制，可被暴力破解 | `/login` |
| Elevation | 注册接口可能允许创建管理员账户 | `/register` |

---

### Step 3: 风险评级

**评级矩阵**：Likelihood × Impact

| | Impact: High | Impact: Medium | Impact: Low |
|---|---|---|---|
| **Likelihood: Likely** | **Critical** | High | Medium |
| **Likelihood: Possible** | High | Medium | Low |
| **Likelihood: Unlikely** | Medium | Low | Low |

**Likelihood（可能性）评估因素**：
- 攻击复杂度（是否需要特殊条件？）
- 攻击者能力要求（是否需要高级技术？）
- 发现难度（漏洞是否容易被发现？）

**Impact（影响）评估因素**：
- 数据泄露范围（多少用户受影响？）
- 业务影响（财务损失？合规风险？）
- 系统可用性影响（服务中断多久？）

**为什么使用 4 级而非 3 级**：
> Critical 级别表示"必须立即修复"的威胁，与 `sdlc-security-audit` 的 Critical 级别对齐。这种对齐确保：
> - threat-modeling 识别的 Critical 威胁 → 必须在编码前解决
> - security-audit 识别的 Critical 漏洞 → 必须在发布前修复
> 两者共同构成"设计阶段安全 + 实现阶段安全"的双重保障。

---

### Step 4: 缓解措施生成

对每个 Critical/High 威胁，生成三层缓解措施：

| 控制类型 | 描述 | 示例 |
|----------|------|------|
| **技术控制** | 代码或配置层面的修复 | 实施 MFA、输入验证、速率限制、加密传输 |
| **流程控制** | 运维和监控层面的措施 | 异常登录告警、定期审计、安全培训 |
| **补偿控制** | 当主要控制不可行时的替代方案 | IP 白名单（当 MFA 不可行时）、WAF 规则 |

**缓解措施的设计原则**：
> 1. **可实施性**：每个缓解措施必须能在现有技术栈中实施。如果一个缓解措施需要更换整个认证框架，应考虑补偿控制
> 2. ** Defense in Depth（纵深防御）**：不依赖单一控制，而是多层控制叠加。例如：输入验证（技术）+ WAF（技术）+ 异常告警（流程）
> 3. **最小权限**：缓解措施应遵循最小权限原则，不引入新的过度授权

---

### Step 5: 安全测试用例生成

**为什么从缓解措施生成测试用例**：
> 威胁建模的常见问题是"识别了威胁、提出了缓解措施，但从未验证缓解措施是否有效"。通过将每个缓解措施转换为测试用例：
> 1. **可验证性**：威胁建模不再是"纸面工作"，而是有可执行的验收标准
> 2. **与测试流程集成**：安全测试用例可以纳入 `devforge-test-execution` 的测试套件
> 3. **回归防护**：后续迭代中，如果修改了相关代码，安全测试用例可以防止回归

**测试用例格式**：

```markdown
- **Test ID**: TC-SEC-{NNN}
- **对应威胁**: T-{NNN} ({STRIDE} against {module_id})
- **验证方法**: {具体的测试步骤}
- **通过标准**: {预期的通过条件}
- **测试类型**: {happy_path / abnormal / security}
```

**示例**：

```markdown
- **Test ID**: TC-SEC-001
- **对应威胁**: T-001 (Spoofing against UserService)
- **验证方法**: 
  1. 获取一个有效的用户 JWT 令牌
  2. 修改令牌中的用户 ID 为另一个用户
  3. 使用篡改后的令牌访问 /profile 接口
- **通过标准**: 返回 401 Unauthorized，系统检测到令牌篡改
- **测试类型**: security
```

---

### Step 6: 产物输出

**THREAT_MODEL_REPORT.md**：
- 威胁矩阵（所有识别的威胁及其评级）
- 按风险级别分组的缓解措施
- 安全测试用例列表
- STRIDE 覆盖率摘要

**architecture.xml 更新**：
- 在 `Security/ThreatModel` 节点下添加 `STRIDE` 子节点
- 每个威胁作为一个 `Threat` 节点：
  ```xml
  <ThreatModel>
    <STRIDE>
      <Threat category="Spoofing" module="UserService" mitigation="MFA" severity="Critical"/>
      <Threat category="DoS" module="UserService" mitigation="RateLimit" severity="High"/>
    </STRIDE>
  </ThreatModel>
  ```

**security.xml 更新**：
- 添加 `Mitigations` 章节
- 每个缓解措施关联到对应的威胁 ID

---

### Step 7: 自验证

**验证项**：

| 检查项 | 验证内容 | 失败时的行为 |
|--------|----------|-------------|
| **Module ID 有效性** | 每个威胁引用的 `module` 属性存在于 `architecture.xml/Module/@id` | 标记错误，要求检查模块名称拼写 |
| **缓解措施可实施性** | 每个缓解措施不依赖"理论上存在"的技术 | 标记警告，建议替换为补偿控制 |
| **STRIDE 覆盖率** | 6 个维度中每个维度至少有一个威胁被识别 | 如果某个维度无威胁，标记为"未识别威胁 — 请人工复核是否遗漏" |
| **接口覆盖** | 所有 public-facing 接口至少被一个威胁覆盖 | 标记警告，检查是否有遗漏的接口 |

**为什么 STRIDE 覆盖率检查很重要**：
> 如果某个 STRIDE 维度没有任何威胁，可能有两种情况：
> 1. 系统确实在该维度上非常安全（罕见）
> 2. 分析遗漏了该维度的威胁（更常见）
> 
> 强制要求每个维度至少一个威胁，防止"盲点"。即使最终确认某维度确实安全，也应该记录为"已评估，无威胁"。

---

### Step 8: 人工门控

**呈现内容**：
- 威胁摘要："威胁建模已完成。识别威胁 X 个（Critical Y 个，High Z 个）。"
- 关键威胁列表（Critical 和 High）
- 缓解措施摘要

**可用命令**：

| 命令 | 行为 |
|------|------|
| `[APPROVE]` | 标记威胁建模完成，转换 phase 到 `threat_modeling_completed` |
| `[FIX {threat_id}]` | 要求修复特定威胁后重新评估 |
| `[PAUSE]` | 暂停当前阶段 |
| `[SKIP]` | 跳过威胁建模（仅推荐用于低安全需求项目） |

**与 design-review 门控的区别**：
> design-review 使用 `[FIX {issue_id}]` + `[APPLY]` 的修复子流程，因为设计审查的问题通常涉及架构文档修改。
> threat-modeling 使用 `[FIX {threat_id}]` 要求修复威胁，但修复通常涉及代码实现（如添加 MFA、输入验证），因此修复后可能需要重新运行 security-audit 验证。

---

## 五、调用工具汇总

| 工具 | 用途 | 调用时机 |
|------|------|----------|
| `Read` | 读取 `architecture.xml` | Step 1 |
| `Read` | 读取 `PRD.md` | Step 1 |
| `Read` | 读取 `INTERFACE_CONTRACT.md` | Step 1 |
| `Read` | 读取 `security.xml` | Step 1 |
| `Read` | 读取现有 `THREAT_MODEL_REPORT.md`（如果存在） | Step 1（增量更新时） |
| `Write` | 写入 `THREAT_MODEL_REPORT.md` | Step 6 |
| `Edit` | 更新 `architecture.xml/Security/ThreatModel` | Step 6 |
| `Edit` | 更新 `security.xml/Mitigations` | Step 6 |
| `Grep` | 验证 Module ID 存在于 architecture.xml | Step 7 |

---

## 六、生成产物清单

| 产物文件 | 路径 | 用途 | 更新模式 |
|----------|------|------|----------|
| `THREAT_MODEL_REPORT.md` | `docs/architecture/validation/` | 威胁建模报告 | 新生成（可覆盖） |
| `architecture.xml` ThreatModel | `docs/architecture/system/` | XML 威胁节点 | Merge-update |
| `security.xml` Mitigations | `docs/architecture/system/` | 缓解措施章节 | Merge-update |
| `STATE.md` | `docs/architecture/system/` | phase → `threat_modeling_completed` | Selective update |

---

## 七、VCMF 检查点

| VCMF 原则 | 检查点 | 说明 |
|-----------|--------|------|
| **Design as Contract** | 每个威胁必须映射到 `architecture.xml` 中的特定 Module/Interface | 威胁不是凭空想象，而是基于架构元素的 |
| **Interface as Boundary** | 威胁模型必须覆盖所有跨模块信任边界 | 信任边界是最常见的攻击路径 |
| **Reality as Baseline** | 缓解措施必须可用现有技术实施 | 不提出"理论上可行"的控制 |
| **State as Responsibility** | 涉及状态的威胁必须引用 StateModel 所有权 | 数据泄露威胁需要知道谁拥有数据 |
| **XML as Authority** | ThreatModel 输出必须更新 `architecture.xml/Security/ThreatModel` 节点 | 威胁成为架构的一部分 |

---

## 八、流程设计原理（Why Designed This Way）

### 8.1 为什么使用 STRIDE 方法论

> **设计意图**：
> 1. **标准化**：STRIDE 是业界最广泛接受的威胁分类框架（微软提出，OWASP 推荐），使用标准方法论确保威胁覆盖的全面性
> 2. **可教授性**：STRIDE 的 6 个维度简单易学，即使非安全专家也能按图索骥
> 3. **可验证性**：可以明确检查"6 个维度是否都覆盖"，而自由式威胁分析无法验证覆盖度
> 4. **与工具生态兼容**：许多安全工具（如 Microsoft Threat Modeling Tool）使用 STRIDE，便于后续工具链集成

### 8.2 为什么是可选而非必经

| 对比 | 必经（如 design-review） | 可选（如 threat-modeling） |
|------|------------------------|--------------------------|
| **适用场景** | 所有项目 | 高安全需求项目 |
| **执行成本** | 必须承担 | 按需执行 |
| **合规要求** | 通用 | SOC 2 / ISO 27001 / 等保 |

> **设计意图**：
> - 内部工具、原型系统、低安全需求项目不需要正式的威胁建模
> - 但金融、医疗、政府等高风险行业项目，威胁建模是合规必需
> - `high-security` 标签的自动触发机制，确保高安全项目不会遗漏此步骤

### 8.3 为什么生成安全测试用例

> **设计意图**：> 传统威胁建模的"最后一公里问题"：识别了威胁、提出了缓解措施，但从未验证这些措施是否真正实施。> 通过生成安全测试用例：
> 1. **闭环验证**：威胁 → 缓解 → 测试 → 验证，形成完整闭环
> 2. **与 DevForge 测试体系集成**：TC-SEC-{NNN} 用例可以纳入 `devforge-test-execution` 的测试清单
> 3. **合规证据**：安全测试用例的执行记录是合规审计的关键证据

### 8.4 为什么更新 architecture.xml

> **设计意图**：> 威胁建模不应该是一个"外部文档"，而应该是架构的一部分：
> 1. **架构与安全的统一**：如果架构和安全文档分离，架构变更时安全文档容易过时
> 2. **下游消费**：`sdlc-security-audit` 可以读取 `architecture.xml/Security/ThreatModel` 节点，在代码扫描时重点关注已知威胁区域
> 3. **版本控制**：威胁模型随架构版本一起演进，Git 历史中可追溯威胁的引入和修复

### 8.5 为什么与 design-review 和 security-audit 形成三层安全验证

```
design-review (Attacker Lens)
    → 定性审查："这个设计是否有安全缺陷？"
    → 输出：问题列表

threat-modeling (STRIDE)
    → 结构化分析："系统面临哪些威胁？"
    → 输出：威胁矩阵 + 缓解措施 + 测试用例

security-audit (Rule-based Scan)
    → 定量扫描："代码中有哪些漏洞？"
    → 输出：漏洞报告 + 修复补丁
```

> **设计意图**：> 三层验证覆盖安全的不同层面和不同阶段：> - **design-review**：编码前，发现设计层面的安全问题（如"缺少审计日志"）
> - **threat-modeling**：编码前，系统性地识别所有威胁场景并规划缓解措施
> - **security-audit**：编码后，扫描具体的代码漏洞（如"SQL 注入"）
> 
> 三者互补：
> - threat-modeling 可能发现"缺少审计日志"，但不会发现"这个接口有 SQL 注入"
> - security-audit 可能发现"SQL 注入"，但不会系统性地分析"整个系统面临什么威胁"
> - design-review 可能发现"认证架构有问题"，但不会像 STRIDE 那样覆盖 6 个维度

---

## 九、常见误区与 Red Flags

### 9.1 与 design-review 和 security-audit 的边界误区

| 误区 | 正确做法 |
|------|----------|
| 用 threat-modeling 替代 design-review | design-review 覆盖安全、可操作性、可扩展性等多个维度；threat-modeling 只覆盖安全威胁。两者互补 |
| 用 threat-modeling 替代 security-audit | threat-modeling 在编码前识别系统级威胁；security-audit 在编码后扫描具体漏洞。两者互补 |
| 认为 design-review 已经发现了所有安全问题 | design-review 的 Attacker Lens 是自由式检查，可能遗漏某些 STRIDE 维度 |
| 认为 security-audit 可以替代威胁建模 | security-audit 扫描代码漏洞，不分析系统级威胁场景（如"缺少审计日志"） |

### 9.2 通用误区

| 误区 | 正确做法 |
|------|----------|
| 威胁描述过于笼统（如"系统可能被攻击"） | 每个威胁应具体到模块、接口、攻击方式（如"UserService/login 接口可被暴力破解"） |
| 缓解措施不可实施 | 每个缓解措施必须评估技术可行性，不可实施的应使用补偿控制 |
| 忽略 Low 级别威胁 | Low 威胁在特定条件下可能升级为 High，应记录并定期复查 |
| 不更新 architecture.xml | 威胁模型必须反馈到架构文档，否则架构与威胁分析脱节 |
| 不生成安全测试用例 | 测试用例是验证缓解措施有效性的唯一方式，不可省略 |
| 认为威胁建模只做一次 | 架构变更后应重新评估威胁模型，新增模块可能引入新威胁 |

### 9.3 SKILL.md 中的 Red Flags

SKILL.md 明确定义了以下红线：

| Red Flag | 说明 |
|----------|------|
| **Do NOT use if `architecture.xml` has not been approved** | 未批准的架构上进行威胁建模没有意义 |
| **Every threat must map to a specific Module/Interface** | 禁止生成与架构无关的"假想威胁" |
| **Mitigations must be implementable** | 禁止提出理论上不可实施的控制 |

---

## 十、总结

`devforge-threat-modeling` 是 DevForge SDLC Skill Chain v1.4 引入的**系统级安全分析引擎**，使用标准化的 STRIDE 方法论在编码前识别系统面临的威胁。

### 核心价值

1. **标准化威胁识别**：STRIDE 的 6 维度检查表确保威胁覆盖的全面性，避免"凭经验找问题"的遗漏
2. **风险量化评级**：Likelihood × Impact 矩阵将威胁分级，帮助团队优先处理最关键的漏洞
3. **可执行的缓解措施**：每个 Critical/High 威胁都有具体的技术/流程/补偿控制，不是泛泛而谈
4. **安全测试用例**：将缓解措施转换为可测试的需求，实现"威胁 → 缓解 → 验证"的闭环
5. **架构文档集成**：威胁模型更新到 `architecture.xml`，成为架构的有机组成部分
6. **三层安全验证**：与 design-review（设计审查）和 security-audit（代码扫描）形成互补的三层安全防线

### 适用场景

| 场景 | 推荐操作 |
|------|----------|
| 高安全需求项目（金融、医疗、政府） | design-review 后自动触发，不可跳过 |
| 一般项目 | 用户手动触发 `[THREAT_MODEL]`，推荐执行 |
| 低安全需求项目（内部工具、原型） | 可 `[SKIP]`，但建议至少执行简化的 Spoofing 和 Elevation 检查 |
| 架构新增模块后 | 重新触发，评估新模块引入的威胁 |
| 安全合规审计前 | 确保 THREAT_MODEL_REPORT.md 是最新版本 |
| 与 security-audit 配合 | threat-modeling 的测试用例纳入 security-audit 的扫描范围 |

### 与其他技能的协作

```
architecture-design (生成 architecture.xml)
    ↓
design-review (对抗性审查)
    ↓
[THREAT_MODEL] → devforge-threat-modeling (STRIDE 分析)
    → 输出威胁矩阵 + 缓解措施 + 测试用例
    → 更新 architecture.xml/Security/ThreatModel
    → 更新 security.xml/Mitigations
    ↓
project-scaffolding (按缓解措施配置安全基础设施)
    ↓
module-design (实现带安全控制的代码)
    ↓
test-execution (执行 TC-SEC 安全测试用例)
    ↓
security-audit (扫描代码漏洞，验证威胁是否被缓解)
```

### v1.4 设计决策

- **v1.4 引入**：`devforge-threat-modeling` 是 v1.4 的新增 Skill
- **设计背景**：v1.3 的 Triple Verification（validation + design-review + security-audit）覆盖了技术一致性、对抗性审查和代码安全，但缺少系统级的结构化威胁分析
- **v1.4 补充**：引入 STRIDE 威胁建模，完善安全验证体系，形成"设计审查 → 威胁建模 → 代码审计"的三层安全防线
- **未来演进**：可以与 `sdlc-security-audit` 的 SECURITY_FIX.patch 机制集成，自动生成威胁缓解的代码修复补丁

---

*分析基于 DevForge SDLC Skill Chain v1.4（2026-05-11）及 devforge-threat-modeling v1.4*
