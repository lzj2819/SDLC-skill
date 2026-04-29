# DevForge v1.2+ 优化设计：上下文管理、幻觉率控制与 Prompt 质量

> **设计目标**：在不改变 DevForge 核心架构（纯 Markdown skill + Claude Code 运行时）的前提下，优化上下文管理效率、降低 LLM 幻觉率、提升 Prompt 工程化水平。
>
> **设计日期**：2026-04-29
> **设计版本**：v1.0
> **优化范围**：后三个维度（上下文管理、指令遵循与幻觉率、Prompt 质量），共 10 项

---

## 1. 设计约束（不变的东西）

1. **保持纯 Markdown skill 架构**：不引入独立 CLI 或运行时引擎
2. **不修改前三个维度的设计**：Standalone/Composable/耦合度保持现状
3. **兼容 v1.2 已有产出**：testcase、P0/P1/P2 计划不受影响
4. **最小侵入原则**：优先在 `references/` 层统一增强，减少逐个 skill 的重复修改

---

## 2. 总体方案：References 层统一增强 + Skill 层引用

```
references/
├── system-prompt-template.md          ← NEW: 全局 System Prompt 模板
├── context-management-protocol.md     ← NEW: 上下文加载/截断/分层策略
├── xml-schemas.md                     ← EXISTING: 扩展 Cross-Layer Rule 7
├── architecture-patterns.md           ← EXISTING: 不变
├── validation-scripts-manifest.md     ← NEW: scripts/ 能力与 skill 引用对齐表
devforge-state.md                      ← MODIFIED: 增强 Artifact Index + Module Registry
```

每个 skill 的 SKILL.md 在 Workflow 开头增加统一的引用指令：

```markdown
## Pre-execution Setup
1. Load `references/system-prompt-template.md` as role context
2. Apply `references/context-management-protocol.md` for artifact loading
3. Follow `references/validation-scripts-manifest.md` for script invocation rules
```

---

## 3. 上下文管理优化（4 项）

### 3.1 分层摘要机制（对应 4.1）

**修改文件**：`devforge-state.md`

**改动**：
- `Compressed Context` 保持 200 字全局摘要
- `Module Registry` 中每个模块增加 `digest` 字段（50 字微摘要）
- `DecisionDigest` 增强为可跳转索引格式：`[ID] [决策一句话] → 详见 DECISION_LOG.md#{id}`

**模板变更**：
```yaml
module_registry:
  - id: UserService
    status: scaffolded
    digest: "Auth domain: JWT + RBAC, 3 components, 8 interfaces"  # ← 新增
```

### 3.2 repo-index.md 代码库索引（对应 4.2）

**修改文件**：`devforge-project-scaffolding/SKILL.md`

**改动**：在 Workflow 第 3 步（Directory tree）之后增加：

```markdown
3.5. **Generate repo-index.md**
   - Output: `PROJECT_SCAFFOLD/docs/architecture/repo-index.md`
   - Contents:
     - Module directory tree with component leaf nodes
     - Quick lookup table: state owner → module → component
     - Interface signature index (method name + input/output schema names only)
     - Decision ID → file location mapping
```

### 3.3 最小必要上下文清单（对应 4.3）

**新建文件**：`references/context-management-protocol.md`

**内容**：为每个 skill 定义强制加载和可选加载的 artifact 清单：

| Skill | Required Artifacts | Optional (summary only if large) |
|-------|-------------------|----------------------------------|
| `devforge-requirement-analysis` | STATE.md (Immutable Goal only) | — |
| `devforge-architecture-design` | PRD.md, STATE.md, DECISION_LOG.md, architecture-patterns.md | Previous architecture.xml (if refactor) |
| `devforge-module-design` | PRD.md, architecture.xml, INTERFACE_CONTRACT.md, STATE.md | Other module-architecture.xml files |
| `devforge-project-scaffolding` | PRD.md, STATE.md, ARCHITECTURE.md, architecture.xml, INTERFACE_CONTRACT.md | DESIGN_REVIEW.md (issue list only), VALIDATION_REPORT.md |
| `devforge-debug-assistant` | STATE.md, repo-index.md, component-spec.xml (target only), test output | Other component-spec.xml files |
| `devforge-iteration-planning` | PRD.md, STATE.md, architecture.xml, INTERFACE_CONTRACT.md, all module-prd.md | — |

**协议规则**：
- 当 artifact 总 token 估计超过阈值（8000 tokens）时，Required 全载，Optional 仅载摘要
- 当总 token 估计超过 12000 tokens 时，Required 中除核心 2 个文件外，其余仅载摘要
- 摘要格式：文件路径 + 最后修改时间 + 1 句话内容摘要

### 3.4 Artifact Index 增强（对应 4.4）

**修改文件**：`devforge-state.md`

**改动**：Artifact Index 表格增加 `digest` 列：

```markdown
| Artifact | Path | Last Modified | Digest |
|----------|------|---------------|--------|
| PRD | skill/artifacts/PRD.md | 2026-04-29 | 8 user stories, P0-P2 scoped, 11 cross-module interactions |
```

---

## 4. 指令遵循与幻觉率优化（4 项）

### 4.1 验证 Scripts 与 Skill 文档对齐（对应 5.1）

**新建文件**：`references/validation-scripts-manifest.md`

**内容**：
- 列出 `scripts/architecture-ci.sh` 的 5 项检查能力与 `xml-schemas.md` 的 6 条规则的映射关系
- 列出 `scripts/xml-sync.py` 的实际 CLI 参数（`--verify-only`, `--sync`）
- 标注 skill 文档中引用的脚本功能是否已实现
- 若存在未实现的引用，标记为 `GAP` 并给出替代方案（如"暂时由 LLM 手动检查替代"）

**验证清单**：
| Skill 文档引用 | Script 实际能力 | 状态 |
|---------------|----------------|------|
| `architecture-ci.sh` 运行 5 项检查 | 已实现 | ✅ |
| `xml-sync.py --verify-only` 验证签名一致性 | 需验证 | 🔍 |
| `xml-sync.py --sync` 跨层同步 | 需验证 | 🔍 |

### 4.2 DDL/OpenAPI 生成后自校验（对应 5.3）

**修改文件**：`devforge-architecture-design/SKILL.md`

**改动**：在 DDL 生成步骤（第 6 步）和 OpenAPI 生成步骤（第 7 步）之后各增加一个校验子步骤：

```markdown
6.1. **Self-validation: schema.sql**
   - Check: Every CREATE TABLE ends with `);`
   - Check: Every ALTER TABLE has valid FOREIGN KEY syntax
   - Check: No `VARCHAR()` without length parameter
   - Check: Primary key fields are NOT NULL
   - If any check fails, regenerate the failing statement before proceeding

7.1. **Self-validation: openapi.yaml**
   - Check: All `$ref` values start with `#/components/schemas/`
   - Check: All paths have at least one response defined
   - Check: Schema names in `components/schemas` match DataModel names in architecture.xml
   - Check: YAML indentation is consistent (2 spaces)
   - If any check fails, regenerate the failing section before proceeding
```

### 4.3 工具推荐前强制搜索验证（对应 5.4）

**修改文件**：`devforge-architecture-design/SKILL.md`

**改动**：在"Technology Stack Recommendation"子步骤中增加：

```markdown
**Technology Stack Validation Rule**：
Before recommending any third-party library, framework, or tool, you MUST perform the following verification in order:

1. **Active Search** (Primary):
   - Use `WebSearch` or `WebFetch` to search: "{tool_name} deprecated", "{tool_name} CVE", "{tool_name} maintenance status"
   - Check the project's GitHub repository or official website for:
     - Last commit/release date (within 12 months = actively maintained)
     - Any deprecation notice or archive status
     - Open security advisories
   - If search tools are unavailable, proceed to step 2 with a disclaimer

2. **Knowledge Verification** (Fallback):
   - Cross-check against your training knowledge for known issues
   - Add disclaimer: "⚠️ This recommendation is based on available information; please verify current status before adoption."

3. **Blacklist Enforcement** (Always):
   - NEVER recommend the following without explicit user approval:
     - VM2 (critical sandbox escape CVEs, project archived)
     - Any library with known RCE vulnerabilities in the last 12 months
   - If a searched tool matches the blacklist or shows deprecation/security issues, you MUST:
     - Flag it explicitly in the recommendation
     - Provide an actively maintained alternative
     - Document the risk in DECISION_LOG.md
```

### 4.4 代码骨架语法检查要求（对应 5.5）

**修改文件**：`devforge-project-scaffolding/SKILL.md`

**改动**：在 Workflow 第 13 步（Internal verification）中增加：

```markdown
13.1. **Syntax validation**
   - For Python files: verify with `python -m py_compile {file}`
   - For TypeScript files: verify with `tsc --noEmit` (if tsconfig exists)
   - For Go files: verify with `go build ./...`
   - For Java files: verify with `mvn compile` or `javac` (single file)
   - Mark any file failing syntax check as `SYNTAX_GAP` in STATE.md Known Pitfalls
```

---

## 5. Prompt 质量优化（4 项）

### 5.1 统一 System Prompt 模板（对应 6.1）

**新建文件**：`references/system-prompt-template.md`

**内容**：

```markdown
# DevForge System Prompt Template

## Role
You are a senior software engineering agent operating within the DevForge skill chain. You follow the VCMF (Vibe Coding Maturity Framework) principles and the DIVE (Design-Implement-Verify-Evolve) cycle.

## Global Constraints
1. **XML as Authority**: All generated code signatures MUST match `component-spec.xml`. All generated DDL MUST match `DataModel` nodes.
2. **Human-in-the-Loop**: NEVER proceed past a phase without explicit user approval (`[APPROVE]`). Auto-jumping is forbidden.
3. **Incremental Evolution**: Existing framework stays; only additions and targeted modifications are allowed.
4. **Traceability**: Every generated file MUST be traceable back to a PRD requirement or architecture decision.
5. **Reality as Baseline**: Mock data validates flow; real environments validate function.

## State Management
- Read `STATE.md` at the start of every skill invocation
- Update `STATE.md` before every human gate
- If prerequisite artifacts are missing, STOP and instruct the user to run the prerequisite skill

## Context Loading Protocol
- Follow `references/context-management-protocol.md` for artifact loading priority
- When total context exceeds safe limits, load Required artifacts in full and Optional artifacts as summaries only
- Never load unrelated module's `component-spec.xml` unless explicitly needed

## Output Quality Standards
- All interface definitions MUST include: method name, input schema, output schema, error codes
- All state definitions MUST include: location, owner, consumer, lifecycle (create/read/update/delete/cleanup)
- All generated code MUST be syntactically valid for the target language
```

### 5.2 语言风格自适应（对应 6.3）

**修改文件**：所有 SKILL.md 的 Human Gate 部分

**改动**：不强制统一语言。改为：

```markdown
## Language Adaptation Rule
- System instructions, constraints, and VCMF checkpoints MUST remain in English for maximum model compliance
- User-facing gate messages, summaries, and explanations MUST use the same language as the user's most recent input
- If the user's input is in Chinese, respond in Chinese. If English, respond in English.
```

**具体改动点**：
- `HARD-GATE` 标签保持英文（模型识别用）
- 人类门控消息改为双语模板或动态跟随用户语言
- `devforge-design.md` 的 VCMF Integration Mapping 表格保持英文

### 5.3 上下文截断策略（对应 6.4）

**已包含在 3.3**（`references/context-management-protocol.md` 中定义）。

额外增加：每个 SKILL.md 的 Workflow 第 1 步修改为：

```markdown
1. **Read artifacts with context protocol**
   - Apply `references/context-management-protocol.md` loading rules
   - If total artifact size exceeds threshold, prioritize:
     a. STATE.md (full)
     b. Current skill's primary input artifact (full)
     c. All other artifacts (summary mode)
   - Log what was loaded in full vs summary to the session
```

### 5.4 自我纠错/校验回退指令（对应 6.5）

**修改文件**：所有核心 skill 的 Workflow 末尾

**改动**：在每个 skill 的最后一个工作步骤之前增加：

**devforge-requirement-analysis**：
```markdown
X. **Self-validation**
   - Verify: Every user story has acceptance criteria
   - Verify: Every acceptance criterion is observable (no adjectives like "fast" without quantification)
   - Verify: Cross-module interactions section is not empty
   - If any check fails, fix before presenting the human gate
```

**devforge-architecture-design**：
```markdown
X. **Self-validation**
   - Verify: Every module in architecture.xml traces to a PRD requirement
   - Verify: Every DataModel has required="true" on primary key fields
   - Verify: schema.sql passes mental syntax check (parentheses balanced, semicolons present)
   - Verify: openapi.yaml has no dangling $ref
   - If any check fails, fix before presenting the human gate
```

**devforge-project-scaffolding**：
```markdown
X. **Self-validation**
   - Verify: Generated code signatures match INTERFACE_CONTRACT.md
   - Verify: File paths in generated code match component-spec.xml Metadata/FilePath
   - Verify: At least 3 files sampled for traceability (PRD req → code file)
   - Verify: No hard-coded secrets in any file
   - If any check fails, fix before presenting the human gate
```

**devforge-architecture-validation**：
```markdown
X. **Self-validation**
   - Verify: VALIDATION_REPORT.md clearly states PASS/FAIL per module
   - Verify: health-check.sh is not empty and references real files
   - Verify: If real-LLM validation was skipped, this is explicitly noted
   - If any check fails, fix before presenting the human gate
```

**devforge-design-review**：
```markdown
X. **Self-validation**
   - Verify: At least one issue found under each lens (Attacker, Operator, Extender)
   - Verify: No PASS/FAIL verdict language used (only problem list)
   - Verify: Every Must Fix issue references a DECISION_LOG entry
   - If any check fails, fix before presenting the human gate
```

**devforge-module-design**：
```markdown
X. **Self-validation**
   - Verify: Module design traces back to system-level PRD (no invented requirements)
   - Verify: Component interfaces do not violate system-level Coupling constraints
   - Verify: ModuleStateModel defines lifecycle for all owned states
   - If any check fails, fix before presenting the human gate
```

**devforge-iteration-planning**：
```markdown
X. **Self-validation**
   - Verify: Every new requirement has a traced impact in the Impact Matrix
   - Verify: Breaking changes have version increments documented
   - Verify: ITERATION_PRD.md does not duplicate unchanged requirements from original PRD
   - If any check fails, fix before presenting the human gate
```

---

## 6. 文件变更清单

| 文件 | 操作 | 说明 |
|------|------|------|
| `references/system-prompt-template.md` | **新建** | 全局 System Prompt 模板 |
| `references/context-management-protocol.md` | **新建** | 上下文加载/截断/分层策略 + 各 skill 最小必要上下文清单 |
| `references/validation-scripts-manifest.md` | **新建** | scripts/ 能力与 skill 引用对齐表 + GAP 标注 |
| `devforge-state.md` | **修改** | Module Registry 增加 digest 字段；Artifact Index 增加 digest 列 |
| `devforge-architecture-design/SKILL.md` | **修改** | 增加 DDL/OpenAPI 自校验步骤；增加技术栈验证规则 |
| `devforge-project-scaffolding/SKILL.md` | **修改** | 增加 repo-index.md 生成步骤；增加语法验证步骤 |
| `devforge-requirement-analysis/SKILL.md` | **修改** | Workflow 末尾增加 Self-validation 步骤；增加语言自适应规则 |
| `devforge-architecture-validation/SKILL.md` | **修改** | Workflow 末尾增加 Self-validation 步骤；增加语言自适应规则 |
| `devforge-design-review/SKILL.md` | **修改** | Workflow 末尾增加 Self-validation 步骤；增加语言自适应规则 |
| `devforge-module-design/SKILL.md` | **修改** | Workflow 末尾增加 Self-validation 步骤；增加语言自适应规则 |
| `devforge-iteration-planning/SKILL.md` | **修改** | Workflow 末尾增加 Self-validation 步骤；增加语言自适应规则 |
| `devforge-visualization/SKILL.md` | **修改** | 增加语言自适应规则（无需 self-validation，为纯转换 skill） |
| `devforge-ops-ready/SKILL.md` | **修改** | 增加语言自适应规则；增加工具验证规则 |
| `devforge-debug-assistant/SKILL.md` | **修改** | 增加语言自适应规则；增加上下文协议引用 |

---

## 7. 风险评估

| 风险 | 影响 | 缓解措施 |
|------|------|----------|
| 修改 10+ 个 skill 文件可能引入不一致 | 中 | 所有 skill 统一在 Workflow 第 1 步引用 `references/` 层模板，skill 特有内容最小化 |
| System Prompt 过长导致上下文膨胀 | 低 | system-prompt-template.md 控制在 500 tokens 以内；通过 context-management-protocol.md 动态控制加载 |
| 语言自适应导致模型混淆 | 低 | 系统指令固定英文，仅用户门控消息跟随用户语言；`HARD-GATE` 标签保持英文不变 |
| scripts 验证清单发现大量 GAP | 中 | 清单中标注 GAP 后，skill 文档中增加临时替代指令（如"LLM 手动检查"） |

---

## 8. 成功标准

- [ ] `references/system-prompt-template.md` 存在且可被所有 skill 引用
- [ ] `references/context-management-protocol.md` 定义了 10 个 skill 的最小必要上下文清单
- [ ] `devforge-state.md` 的 Module Registry 和 Artifact Index 包含 digest 字段
- [ ] `devforge-architecture-design` 工作流包含 DDL/OpenAPI 自校验步骤
- [ ] `devforge-architecture-design` 包含工具推荐前验证规则（含 VM2 等已知问题工具黑名单）
- [ ] `devforge-project-scaffolding` 工作流包含 repo-index.md 生成和语法验证步骤
- [ ] 所有 10 个核心 skill 的 Workflow 末尾增加 Self-validation 步骤
- [ ] 所有 skill 的人类门控支持语言自适应
- [ ] `references/validation-scripts-manifest.md` 完成 scripts/ 与 skill 文档的对齐验证
