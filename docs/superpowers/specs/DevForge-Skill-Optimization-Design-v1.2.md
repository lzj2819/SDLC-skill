# DevForge Skill Chain v1.2 优化设计文档

> 日期：2026-04-29
> 范围：解决 8 个评估问题中除成本问题外的 6 个问题
> 策略：模块化扩展（新增 Skill + 工具规范，不修改现有 10 阶段流程）

---

## 1. 概述

本文档基于对 DevForge SDLC Skill Chain v1.2 的全面评估，针对 6 个关键问题设计优化方案。

**不优化的内容（用户明确排除）**：
- 问题 5：上下文注入策略与 API 费用优化
- 问题 6：ROI 量化分析

**待优化的 6 个问题**：
1. 开发者接入门槛（文档与示例）
2. AI 走偏时的开发者介入机制
3. 报错信息清晰度与上下文追踪
4. 安全漏洞扫描能力
7. 产物存储统一性与幂等更新
8. 搜索/工具/Skill 调用机会

**设计原则**：
- 模块化扩展：新增独立 Skill 和工具规范，现有 10 个阶段流程保持不变
- 可独立验证：每个新模块可单独测试和迭代
- 向后兼容：现有产物和 STATE.md 结构不变

---

## 2. 问题分析与解决方案映射

| 问题 | 当前状态 | 优化目标 | 解决方案 |
|------|---------|---------|---------|
| 1. 接入门槛高 | 仅有 PPT 大纲和设计文档，无 QuickStart | 降低新手接入成本 | README.md + QuickStart 示例 |
| 2. 介入困难 | 仅 `[APPROVE]` 门控，无精细控制 | 支持回滚、暂停、解释、编辑 | intervention-checkpoint 工具规范 |
| 3. 报错不清晰 | 报错不关联 DecisionID，无修复建议 | 可追踪推理上下文 | error-tracing 工具规范 |
| 4. 安全漏洞 | 无代码级安全扫描 Skill | 内置自动化安全审计 | sdlc-security-audit Skill |
| 7. 产物重复生成 | 无幂等更新机制 | 增量更新，避免覆盖 | artifact-manager 工具规范 |
| 8. 搜索未充分利用 | 仅技术栈验证时搜索 | 全链路搜索集成 | search-integration 参考规范 |

---

## 3. 新增模块设计

### 3.1 目录结构

```
SDLC-skill/
├── skill/
│   ├── sdlc-security-audit/
│   │   └── SKILL.md               # 代码级安全扫描 Skill
│   ├── tools/
│   │   ├── error-tracing.md        # 错误追踪规范
│   │   ├── artifact-manager.md     # 产物管理规范
│   │   └── intervention-checkpoint.md  # 开发者介入机制
│   └── references/
│       └── search-integration.md   # 搜索调度规范
├── examples/
│   └── quickstart-todo-app.md      # QuickStart 端到端示例
└── README.md                       # 开发者入门文档
```

### 3.2 sdlc-security-audit（代码级安全扫描）

**定位**：独立可选 Skill，作为 design-review 的补充，专注代码级实现漏洞。

**触发条件**：
- 阶段三生成 `architecture.xml` 后（架构层安全检查）
- 阶段五生成代码骨架后（代码级安全检查）
- 阶段六生成 `component-spec.xml` 后（组件级安全检查）
- 用户手动输入 `[SECURITY_AUDIT]`

**扫描维度**：

| 检查项 | 严重程度 | 检测方式 |
|--------|---------|---------|
| 硬编码密钥/Token | 🔴 Critical | 正则匹配 API Key、密码、私钥模式 |
| SQL 注入风险 | 🔴 Critical | 检测字符串拼接 SQL、无参数化查询 |
| XSS/注入漏洞 | 🔴 Critical | 检测未转义输出、危险 innerHTML |
| 不安全的依赖 | 🟡 High | WebSearch 检查 CVE |
| 不安全的文件操作 | 🟡 High | 检测路径遍历、任意文件读写 |
| 敏感数据日志 | 🟡 High | 检测密码/Token 被打印到日志 |
| 弱加密算法 | 🟢 Medium | 检测 MD5/SHA1、硬编码盐值 |
| 越权访问 | 🟢 Medium | 检测缺少权限校验的接口 |

**工作流程**：
1. 读取目标产物（代码/XML/配置文件）
2. 按维度执行静态规则扫描（正则+模式匹配）
3. 对依赖项调用 WebSearch 检查 CVE
4. 生成 `SECURITY_AUDIT_REPORT.md`
5. 更新 `STATE.md` 的 `Known Pitfalls`
6. 人类门控：`[APPROVE]` / `[FIX]` / `[IGNORE]`

**输出产物**：
- `docs/architecture/security/SECURITY_AUDIT_REPORT.md`
- 内联代码注释 `// SECURITY-AUDIT: [id] - 风险说明`

### 3.3 tools/error-tracing（错误追踪与上下文关联）

**定位**：工具规范，被所有 Skill 在报错时遵循。

**核心机制**：每个报错包含 `TraceID = DecisionID + ErrorCode`，自动关联 `DECISION_LOG.md`。

**报错格式规范**：

```markdown
## [ERROR] {ErrorCode}: {一句话描述}

**发生位置**：{Skill名称} → {步骤编号} → {产物文件:行号}

**TraceID**：`{DecisionID}-{ErrorCode}-{Timestamp}`
- 关联决策：[arch-dec-0042] Use JWT for auth
- 关联需求：US-001 (Login feature)

**上下文摘要**：
- 输入条件：{导致错误的输入/状态}
- 推理路径：{AI 基于什么前提得出该结论}
- 相关产物：{PRD.md:XX} → {ARCHITECTURE.md:YY} → {当前文件:ZZ}

**修复建议**：
1. {具体步骤 1}
2. {具体步骤 2}

**如需人工介入**：回复 `[EXPLAIN TraceID]` 展开解释，或 `[ROLLBACK 步骤编号]` 回滚。
```

**与 STATE.md 集成**：
- 新增 `ErrorLog` 字段（追加）
- 格式：`[2026-04-29 10:00] {TraceID} {ErrorCode} {Status: fixed/pending}`

### 3.4 tools/artifact-manager（产物幂等更新与冲突检测）

**定位**：工具规范，被所有生成产物的 Skill 遵循。

**核心原则**：CRUD-Append 模式——读取现有内容 → 计算差异 → 只更新变更部分 → 保留用户手动修改。

**产物分类与更新策略**：

| 产物类型 | 更新模式 | 说明 |
|---------|---------|------|
| `PRD.md` | Append-only | 新增 User Story 追加到末尾 |
| `DECISION_LOG.md` | Append-only | 新决策追加，已有决策标记 `superseded` |
| `STATE.md` | Selective update | `Current State` 覆盖，其余追加 |
| `architecture.xml` | Merge-update | 新增模块插入，已有模块更新变更字段 |
| `module-architecture.xml` | Merge-update | 保留组件内手动注释 |
| `component-spec.xml` | Conservative update | 已有 `<Function>` 不覆盖，只新增 |
| `PROJECT_SCAFFOLD/` | Overlay | 新增文件写入，已有非 `auto-generated` 文件跳过 |

**冲突检测规则**：
1. 生成前读取现有文件，计算 SHA256
2. 检测 `<!-- MANUAL: -->` 或 `// MANUAL:` 标记
3. 无冲突 → 直接 merge
4. 有冲突 → 生成 `ARTIFACT_MERGE_CONFLICT.md` 等待人工解决

**产物版本标记**（头部自动注入）：
```markdown
<!-- GENERATED-BY: {skill_name} -->
<!-- GENERATED-AT: {ISO8601} -->
<!-- UPDATE-RULE: {merge|append|overlay} -->
```

### 3.5 tools/intervention-checkpoint（开发者介入与回滚）

**定位**：工具规范，扩展人类门控机制。

**新增交互命令**：

| 命令 | 作用 |
|------|------|
| `[PAUSE]` | 暂停当前 Skill，保持上下文，开发者可输入问题 |
| `[ROLLBACK {step_id}]` | 回滚到指定步骤，重新执行 |
| `[EXPLAIN {TraceID}]` | 展开解释某个错误/决策的完整推理链 |
| `[EDIT {file_path}]` | 开发者直接编辑文件后，AI 基于修改继续 |
| `[SKIP]` | 跳过当前可选步骤 |
| `[INJECT {context}]` | 开发者补充额外上下文，AI 重新评估 |

**Checkpoint 机制**：
- 每个 Skill 执行前自动保存 `checkpoints/{skill_name}_{timestamp}.md`
- 包含：产物快照 + 上下文摘要 + 下一步计划
- `[ROLLBACK]` 时读取最近 checkpoint 恢复

### 3.6 references/search-integration（全链路搜索调度）

**定位**：参考规范，定义各阶段搜索调用点和结果引用格式。

**搜索调用点**：

| 阶段 | 搜索场景 | 调用工具 |
|------|---------|---------|
| 阶段一（PRD） | 竞品分析、市场验证 | WebSearch |
| 阶段三（架构） | 框架版本、CVE、性能基准 | WebSearch + WebFetch |
| 阶段五（脚手架） | 依赖最佳实践、Docker 镜像安全 | WebSearch |
| security-audit | 依赖 CVE、漏洞利用详情 | WebSearch |
| 全链路 | 工具弃用通知、维护状态 | WebSearch |

**搜索结果引用规范**：
- 标注 `[Search: {query}]` 和 `[Source: {URL}]`
- 结果存入 `DECISION_LOG.md` 的 `Evidence` 字段
- 同一查询 24h 内缓存

### 3.7 README.md + QuickStart

**README.md 结构**：
1. 一句话介绍
2. 3 分钟 QuickStart
3. 10 个阶段速查表
4. 目录结构说明
5. 人类门控命令参考
6. 常见问题 FAQ

**QuickStart 示例**：`examples/quickstart-todo-app.md`
- 从空目录开始，完整走完 10 个阶段
- 每个阶段展示：输入 → 产物 → 门控命令
- 最终生成可运行的 Todo 应用

---

## 4. 现有文件集成点

### 4.1 DevForge.md 修改

| 阶段 | 修改内容 |
|------|---------|
| 阶段三（架构设计） | 架构评审后插入 security-audit 调用点 |
| 阶段四（沙盘模拟） | 报错时应用 error-tracing 格式 |
| 阶段五（脚手架） | 产物写入前调用 artifact-manager；代码生成后调用 security-audit |
| 阶段六（模块设计） | 产物写入前调用 artifact-manager |
| 全局约束 | 新增 intervention-checkpoint 命令说明 |

### 4.2 scripts/ 修改

| 文件 | 修改内容 |
|------|---------|
| `architecture-ci.sh` | 新增安全检查 job；集成 artifact-manager 的冲突检测 |
| `xml-sync.py` | 新增 `--dry-run` 参数；集成 artifact-manager 的 merge 逻辑 |

---

## 5. 实施计划概述

### Phase 1：基础设施（高优先级）
1. 新建 `README.md` 和 `examples/quickstart-todo-app.md`
2. 新建 `skill/tools/error-tracing.md`
3. 新建 `skill/tools/artifact-manager.md`
4. 修改 `DevForge.md` 集成 error-tracing 和 artifact-manager

### Phase 2：交互增强（中优先级）
1. 新建 `skill/tools/intervention-checkpoint.md`
2. 修改 `DevForge.md` 集成 intervention-checkpoint 命令

### Phase 3：安全能力（中优先级）
1. 新建 `skill/sdlc-security-audit/SKILL.md`
2. 修改 `DevForge.md` 在阶段三、五插入调用点
3. 修改 `scripts/architecture-ci.sh` 新增安全检查

### Phase 4：搜索集成（低优先级）
1. 新建 `skill/references/search-integration.md`
2. 修改各阶段 SKILL 定义，插入搜索调用点

---

## 6. 自检清单

- [x] 无 TBD/TODO 占位符
- [x] 各模块间无矛盾
- [x] 现有 10 阶段流程未被修改（仅插入调用点）
- [x] 产物路径与 v1.2 一致
- [x] STATE.md 结构向后兼容
- [x] 安全扫描维度覆盖 OWASP Top 10 核心风险
