# DevForge Decomposition Design v1.3

> **Design Objective**: Decompose the original monolithic skill `DevForge.md` into composable skills that embed VCMF principles and the DIVE cycle. The skill chain models a "single thinker's iterative drafts" rather than a "role relay race": each skill is the same thinker unfolding the same complex problem from a different dimension, always holding the complete intent.
>
> **v1.1 Additions**: Three-layer XML architecture (System/Module/Component), dynamic pattern selection (10 patterns), module-level design skill, iteration planning skill, domain extensions (overlay mechanism), context compression utility, and XML-driven code generation.
>
> **v1.2 Additions**: Database schema (DDL) generation, OpenAPI 3.0 spec generation, test coverage integration, architecture visualization (Mermaid diagrams), production-ready infrastructure (Terraform/K8s/monitoring), progressive deployment (blue-green + canary), bug diagnosis & refactoring assistant, requirement traceability matrix (RTM), **context-management protocol** (layered summary + repo-index.md), **self-validation checkpoints** (syntax/schema/traceability), **language adaptation** (user-input language detection), and **technology stack validation** (active search before tool recommendation).
>
> **v1.3 Additions**: **Triple Verification Mechanism** (3a architecture-validation + 3b design-review + 3c security-audit), **`devforge-test-execution` skill** (unit/integration/e2e test execution + coverage reporting + RTM sync), **FIX sub-flow** with diff generation and auto re-validation in design-review, **verification phase continuity** (both validation and design-review run by default), **module-design strictly after scaffolding** (precondition enforcement), **native agent-based parallel batch mode** for module design (`[MODULE_BATCH]`), **cross-module interface compatibility check** in module-design self-validation, **iteration post-implementation validation loop** (breaking changes trigger re-validation), **P0/P1/P2 placeholder generation strategy** in scaffolding and module-design, **`docs/architecture/INDEX.md`** generation, **RTM real-time updates** across all skills, and **web research integration** in requirement-analysis.

---

## 1. Design Decisions

### 1.1 Selection Conclusion

Adopt **Option B: Workflow-Aggregate Decomposition (10 Skills + Utilities)**.

**Reasons**:
- Creates a natural skill chain where each skill maps cleanly to a DIVE stage
- Skill granularity is moderate, trigger conditions are clear, and users do not need to switch too frequently
- Aligns with the VCMF principles by inserting explicit checkpoints at every phase transition
- v1.1 additions (module-design, iteration-planning) extend the chain without breaking existing flow
- v1.2 additions (visualization, ops-ready, debug-assistant) provide optional post-scaffolding capabilities

### 1.2 Scope

**General-purpose**: Not tied to a specific architecture pattern. Applicable to Web apps, mobile apps, backend services, CLI tools, AI agents, data pipelines, and any other software engineering scenario.

---

## 2. Overall Architecture

```
User inputs a raw idea
    |
    v
+-----------------------------------------------------------+
|  1. devforge-requirement-analysis                             |
|  DIVE: Design                                             |
|  Outputs: PRD.md + RTM.md + DECISION_LOG.md               |
+-----------------------------------------------------------+
    | [APPROVE]
    v
+-----------------------------------------------------------+
|  2. devforge-architecture-design                              |
|  DIVE: Design (deepen)                                    |
|  Outputs: ARCHITECTURE.md + INTERFACE_CONTRACT.md         |
|           + architecture.xml + schema.sql + openapi.yaml  |
|           + module XML templates                          |
+-----------------------------------------------------------+
    | [APPROVE]
    v
    +-------------------------+-------------------------+-------------------------+
    |                         |                         | (Optional but recommended)
    v                         v                         v
+------------------+   +--------------------+   +----------------------+
| 3a. devforge-    |   | 3b. devforge-      |   | 3c. devforge-        |
| architecture-    |   | design-review      |   | security-audit       |
| validation       |   | DIVE: Verify       |   | DIVE: Verify         |
| Technical        |   | Adversarial        |   | Security scan        |
| consistency +    |   | inspection         |   | (8 dimensions + CVE) |
| XML delta report |   | (problem list)     |   |                      |
+------------------+   +--------------------+   +----------------------+
    | [APPROVE]            | [APPROVE / FIX]          | [APPROVE / SKIP]
    +----------------------+--------------------------+
                              v
+-----------------------------------------------------------+
|  4. devforge-project-scaffolding                              |
|  DIVE: Implement (infrastructure)                         |
|  Outputs: PROJECT_SCAFFOLD/ directory tree + .env.template|
|           + docs/sync-rules.md + docs/ADR.md + CHANGELOG  |
|           + CI/CD + deployment topology + test framework  |
|           + docs/architecture/INDEX.md + repo-index.md    |
+-----------------------------------------------------------+
    | [APPROVE]
    v
+-----------------------------------------------------------+
|  5. devforge-module-design                                    |
|  DIVE: Design (module-level) + Implement (code skeleton)  |
|  Trigger: [MODULE {id}] / [MODULE_BATCH {ids}]            |
|  Strictly after scaffolding                               |
|  Outputs: module-prd.md + module-architecture.xml         |
|           + component-spec.xml + test code                |
|           + precise code skeletons (from component-spec)  |
+-----------------------------------------------------------+
    | [APPROVE / NEXT MODULE]
    v
+-----------------------------------------------------------+
|  6. devforge-test-execution                                   |
|  DIVE: Verify                                             |
|  Trigger: [TEST]                                          |
|  Outputs: TEST_REPORT.md + TEST_COVERAGE_GAP.md         |
|           + Updated RTM.md                                |
+-----------------------------------------------------------+
    | [APPROVE / DEBUG]
    v
+-----------------------------------------------------------+
|  7. devforge-iteration-planning                               |
|  DIVE: Evolve                                             |
|  Trigger: New requirements after scaffolding              |
|  Outputs: ITERATION_PRD.md + ITERATION_PLAN.md            |
|           + Updated architecture.xml + VALIDATION_DELTA   |
|  Post-iteration: loops back to 3a/3b if breaking changes  |
+-----------------------------------------------------------+
    | [APPROVE]
    v
(Optional stages 8-10: visualization, ops-ready, debug-assistant)
```

**Core Design Principles**:
1. **Composable**: Each skill has an independent trigger and can be invoked alone or in a chain.
2. **File-based State**: Global state is persisted via `STATE.md`, not LLM context. STATE.md is a reasoning chain anchor (12 sections: Immutable Goal, Completed Steps, DecisionDigest, Current State, Quality Gates, Module Registry, Iteration History, Compressed Context, Artifact Index, Known Pitfalls, Error Log, Intervention Log).
3. **Human-in-the-loop**: Every skill halts at `[APPROVE]`. Auto-jumping is forbidden.
4. **Subagent Ready**: Complex subtasks are executed via internal subagent dispatch, but the skill itself remains self-contained.
5. **Single Thinker Model**: All skills = same thinker unfolding the same problem from different dimensions, not workers passing documents. Each skill reads ALL historical artifacts, not just the previous phase's output.
6. **Adversarial Inspection**: Validation checks technical consistency; design-review finds flaws; security-audit scans vulnerabilities. The three complement each other and cannot substitute.
7. **XML as Authority**: `component-spec.xml` is the single source of truth for code generation. CI enforces consistency between code and XML.
8. **Incremental Evolution**: The existing framework stays; only additions and targeted modifications are allowed in iterations.
9. **Context Management**: Follow `references/context-management-protocol.md` for artifact loading priority. Use layered summaries (200-word global, 50-word module digest, 1-line decision index) and `repo-index.md` for rapid codebase navigation. Load only relevant artifacts to stay within context window limits (>50k / >150k token thresholds).
10. **Self-validation**: Every skill that produces artifacts includes an automated self-validation step before the human gate. Checks include: syntax validity, schema compliance, traceability coverage, cross-reference integrity, and cross-module interface compatibility.
11. **Language Adaptation**: Skill system instructions remain in English for maximum model compliance. All user-facing gate messages, summaries, and explanations adapt to the user's input language (Chinese/English/auto-detected).
12. **Technology Stack Validation**: Before recommending any third-party library, framework, or tool, perform active search (WebSearch/WebFetch) for deprecation notices, CVEs, and maintenance status. Blacklist known-vulnerable tools (e.g., VM2) without explicit user approval.
13. **Error Tracing**: All errors MUST follow `tools/error-tracing.md` format (TraceID, DecisionID linkage, fix suggestions).
14. **Artifact Management**: All artifacts MUST follow `tools/artifact-manager.md` CRUD-Append rules (read existing → compute diff → update delta → preserve manual edits).
15. **Intervention Checkpoint**: Human gate MUST support `[PAUSE]`, `[ROLLBACK]`, `[EXPLAIN]`, `[EDIT]`, `[SKIP]`, `[INJECT]`, `[FIX]`, `[APPLY]`, `[FORCE_APPROVE]`, `[SKIP_REVIEW]`, `[DESIGN_REVIEW]`, `[VALIDATE]`, `[TEST]`, `[MODULE_BATCH]` per `tools/intervention-checkpoint.md`.
16. **Security Audit**: Code generation MUST trigger `devforge-security-audit` scan; Critical issues MUST be fixed before proceeding.

---

## 3. Skill Detailed Design

### 3.1 `devforge-requirement-analysis`

```yaml
---
name: devforge-requirement-analysis
description: Use when a user provides an initial product idea or goal and needs a structured PRD with user stories, acceptance criteria, interface boundaries, and functional requirements
---
```

**Scope**: Aggregates original Phase 1 (PRD methodology alignment) + Phase 2 (agile and bulletproof PRD construction).

**Input**: A raw product idea or goal in natural language.

**Output**:
- `PROJECT_SCAFFOLD/docs/architecture/system/PRD.md`
- `PROJECT_SCAFFOLD/docs/architecture/system/DECISION_LOG.md` (seeded)

**VCMF Checkpoints**:
- Design as Contract: PRD must define closed-loop success metrics and scope boundaries
- Interface as Boundary: Identify and list all cross-module interaction points
- Reality as Baseline: Acceptance criteria must be observable and testable
- State as Responsibility: Document who owns each business state

**Key Workflow**:
1. Explain the "four-dimensional deduction" (Why / What / How / Modules)
2. State the five PRD quality standards
3. Surface edge-case questions (malicious traffic, third-party downtime)
4. Ask 3-5 targeted questions to fill context gaps
5. Extract project characteristic tags for dynamic pattern selection (e.g., `ai_agent`, `frontend_heavy`)
6. Identify cross-module interaction points
7. Generate structured PRD
8. Write PRD to `PROJECT_SCAFFOLD/docs/architecture/system/PRD.md`
9. Seed `PROJECT_SCAFFOLD/docs/architecture/system/DECISION_LOG.md`
10. Update `STATE.md`: `phase: requirement_analysis_completed`
11. Present summary and gate: "PRD 和决策日志已生成。请确认当前阶段输出。回复 [APPROVE] 进入架构设计阶段，或提出修改意见。"

---

### 3.2 `devforge-architecture-design`

```yaml
---
name: devforge-architecture-design
description: Use when a PRD has been approved and the user needs system architecture, interface contracts, test case design, and XML-based architecture modeling
---
```

**Scope**: Original Phase 3 (deep architecture modeling + dual-track test design). v1.1 adds dynamic pattern selection, three-layer XML, and domain extension loading.

**Input**: Approved `PROJECT_SCAFFOLD/docs/architecture/system/PRD.md`.

**Output**:
- `PROJECT_SCAFFOLD/docs/architecture/system/ARCHITECTURE.md`
- `PROJECT_SCAFFOLD/docs/architecture/system/INTERFACE_CONTRACT.md`
- `PROJECT_SCAFFOLD/docs/architecture/system/architecture.xml` (System Level)
- `PROJECT_SCAFFOLD/docs/architecture/modules/{module_id}/module-architecture.xml` (templates)

**VCMF Checkpoints**:
- Design as Contract: Architecture traceable back to PRD; no invented requirements
- Interface as Boundary: Every cross-module call has explicit Input/Output and error codes
- Reality as Baseline: Test cases cover happy path, abnormal path, and NFRs
- State as Responsibility: XML `<StateModel>` answers where, who writes, who reads, lifecycle

**Key Workflow**:
1. Read `STATE.md`, `PRD.md`, `DECISION_LOG.md`
2. Read `references/architecture-patterns.md` (10-pattern library)
3. Extract project characteristic tags from PRD; dynamically select top 4-6 most relevant patterns
4. If tags include `ai_agent`, `data_pipeline`, or `mobile_app`, load corresponding domain extension
5. Evaluate selected patterns in parallel with AI-specific dimensions (if applicable)
6. Design interface contracts from PRD cross-module interactions
7. Map state ownership for every stateful entity
8. Generate test cases (happy + abnormal + NFR)
9. Output strict System Level XML with `DecisionTrace`, `Module`, `DataModel`, `StateModel`, `Security`
10. For each `Module`, auto-generate `module-architecture.xml` template with pre-populated Constraints
11. Write `ARCHITECTURE.md` and `INTERFACE_CONTRACT.md`
12. Append decisions to `DECISION_LOG.md`
13. Update `STATE.md`: `phase: architecture_design_completed`
14. Gate: "架构设计、接口契约和 XML 模型已生成。请确认当前阶段输出。回复 [APPROVE] 进入架构验证阶段，或提出修改意见。"

---

### 3.3 `devforge-architecture-validation`

```yaml
---
name: devforge-architecture-validation
description: Use when a system architecture XML and interface contracts have been approved and the user wants to validate them through LLM-based sandbox simulation with mock data
---
```

**Scope**: Original Phase 4 (LLM sandbox simulation + architecture self-check). v1.1 adds XML delta reports and reference integrity checks.

**Input**:
- `PROJECT_SCAFFOLD/docs/architecture/system/PRD.md`
- `PROJECT_SCAFFOLD/docs/architecture/system/ARCHITECTURE.md`
- `PROJECT_SCAFFOLD/docs/architecture/system/INTERFACE_CONTRACT.md`
- `PROJECT_SCAFFOLD/docs/architecture/system/architecture.xml`
- Module-level XMLs (if exist)

**Output**:
- `PROJECT_SCAFFOLD/docs/architecture/validation/VALIDATION_REPORT.md`
- `PROJECT_SCAFFOLD/docs/architecture/validation/VALIDATION_DELTA_{YYYYMMDD}.md`
- `PROJECT_SCAFFOLD/docs/architecture/validation/health-check.sh`

**VCMF Checkpoints**:
- Design as Contract: Verify XML modules trace back to PRD requirements
- Interface as Boundary: Verify every `Coupling` in XML matches `INTERFACE_CONTRACT.md`
- Reality as Baseline: Run real-LLM validation on semantic-sensitive points; degrade to mock+consistency if no API key
- State as Responsibility: Verify `StateModel` lifecycle definitions are internally consistent

**Key Workflow**:
1. Read XML, PRD, and module-level XMLs
2. Check API Key / Base URL availability
3. Consistency check: XML vs Interface Contract
4. Consistency check: XML vs PRD
5. Reference integrity check: all `ref` attributes resolve to existing files
6. Mock injection and module-by-module simulation
7. Real-LLM validation on minimal coverage set (if API key available)
8. Print simulation trace
9. Compare with previous validation report; generate `VALIDATION_DELTA.md`
10. If any check fails: report failure and ask for `[RETRY]`; do NOT proceed to scaffolding
11. If all pass: write `VALIDATION_REPORT.md`, `VALIDATION_DELTA.md`, and generate `health-check.sh`
12. Update `STATE.md`: `phase: architecture_validated`
13. Gate: "架构验证报告和健康检查脚本已生成。请确认当前阶段输出。回复 [APPROVE] 进入项目脚手架阶段，或提出修改意见。"

---

### 3.4 `devforge-design-review`

```yaml
---
name: devforge-design-review
description: Use when a system architecture has been designed and the user wants an adversarial inspection to find design flaws before implementation begins
---
```

**Scope**: Adversarial inspection (Red Team mode) of approved architecture.

**Input**: All historical artifacts (PRD, STATE, DECISION_LOG, ARCHITECTURE, XML, INTERFACE_CONTRACT).

**Output**:
- `PROJECT_SCAFFOLD/docs/architecture/validation/DESIGN_REVIEW.md`

**VCMF Checkpoints**:
- Design as Contract: Flag orphaned assumptions; verify decisions trace to PRD
- Interface as Boundary: Verify interfaces handle edge cases and failure modes
- Reality as Baseline: Verify mock data covers abnormal paths and NFR stress
- State as Responsibility: Verify every StateModel has complete lifecycle

**Key Workflow**:
1. Read ALL historical artifacts (full reasoning chain, not conclusions)
2. Attacker Lens: input validation, race conditions, dependency failure, encryption
3. Operator Lens: debuggability, logging, config changes, test coverage, doc sync
4. Extender Lens: 10x scalability, feature addition cost, backward compatibility, state ownership
5. Consolidate: Must Fix / Should Fix / Nice to Fix / Documented Risks
6. Cross-reference issues to DECISION_LOG architecture decisions
7. Write DESIGN_REVIEW.md
8. Update STATE.md Known Pitfalls
9. Gate: "设计审查报告已生成。这不是'通过/不通过'的检查..."

**Important**: This skill does NOT produce PASS/FAIL. It produces a problem list. The user decides what to fix.

---

### 3.5 `devforge-project-scaffolding`

```yaml
---
name: devforge-project-scaffolding
description: Use when architecture design (and optional validation) is approved and the user needs concrete project scaffolding, CI/CD pipelines, transparent test fixtures, and evolution infrastructure
---
```

**Scope**: Original Phase 5 (scaffolding + transparent test engineering). **v1.3 refactor**: XML-driven code generation moved to `devforge-module-design`; scaffolding now generates infrastructure only. Module directory structure initialized with header comments only (no business logic placeholders).

**Input**: All prior artifacts + XML schemas.

**Output**:
- `PROJECT_SCAFFOLD/` directory tree with runnable files
- `PROJECT_SCAFFOLD/docs/architecture/system/` and `PROJECT_SCAFFOLD/docs/architecture/modules/{id}/`
- `PROJECT_SCAFFOLD/.env.template`
- `PROJECT_SCAFFOLD/docs/sync-rules.md`
- `PROJECT_SCAFFOLD/docs/ADR.md`
- `PROJECT_SCAFFOLD/CHANGELOG.md`
- `PROJECT_SCAFFOLD/docs/architecture/INDEX.md`
- `PROJECT_SCAFFOLD/repo-index.md`

**VCMF Checkpoints**:
- Design as Contract: Every generated infrastructure file traceable to PRD or Architecture
- Interface as Boundary: CI/CD pipeline includes architecture consistency check job
- Reality as Baseline: Tests directory structure supports both mock and real-LLM tests with `skipif`; coverage threshold 80%
- State as Responsibility: Generated infrastructure matches `StateModel` ownership
- XML as Authority: `docs/architecture/INDEX.md` correctly indexes all XML artifacts; CI enforces XML consistency

**Key Workflow**:
1. Read all prior artifacts, `STATE.md`, and `references/xml-schemas.md`
2. Internal lightweight planning (files, tests, directories)
3. Generate directory tree and dependency configs
4. Copy architecture artifacts to `docs/architecture/`; generate `.gitattributes`
5. Generate `docs/architecture/INDEX.md` with system-level links, module table, and artifact registry
6. Generate `repo-index.md` (max depth 3 file tree + directory summaries + module-to-directory cross-reference)
7. Generate module directory structure — **only** `__init__.py` (or equivalent) with header comments; **NO function signatures or business logic placeholders**
8. **No code skeletons generated** — business logic code is generated by `devforge-module-design` after `component-spec.xml` is created
9. Generate deployment topology (`docker-compose.yml` or K8s manifests)
10. Generate CI/CD config with `architecture-check` job (runs `architecture-ci.sh` + `xml-sync.py --verify-only`) and coverage check job (80% threshold)
11. Generate `.env.template`
12. Generate transparent test fixtures organized into `tests/mock/`, `tests/real/`, `tests/end_to_end/` — **test framework only, no specific test cases**
13. Generate `docs/sync-rules.md` and `docs/ADR.md`
14. Update `DECISION_LOG.md` and generate `CHANGELOG.md`
15. Internal verification + traceability audit (sample 3-5 files)
16. Update `STATE.md`: `phase: scaffolding_completed`
17. Gate: "项目基础设施已生成，包含工程目录、CI/CD 配置、测试框架、文档同步规则和环境变量模板。业务代码将在模块详细设计阶段生成。请确认当前阶段输出。回复 [APPROVE] 进入模块详细设计阶段，或提出修改意见。"

---

### 3.6 `devforge-module-design` (v1.1 New, v1.3 Enhanced)

```yaml
---
name: devforge-module-design
description: Use when a system-level architecture has been approved and scaffolding is complete, and the user needs detailed design for a specific module, including module-level PRD, component decomposition, component interfaces, module-level XML, test code, and precise code skeletons. Trigger when user says [MODULE {module_id}] or [MODULE_BATCH {ids}].
---
```

**Scope**: Deep-dive design for a single module within an approved system architecture. **v1.3 strict precondition**: requires `scaffolding_completed`. Generates code skeletons with P0/P1/P2 placeholder strategy and cross-module interface compatibility check.

**Input**: System-level PRD, `architecture.xml`, `INTERFACE_CONTRACT.md`, `STATE.md`, target `module_id`.

**Output**:
- `PROJECT_SCAFFOLD/docs/architecture/modules/{module_id}/module-prd.md`
- `PROJECT_SCAFFOLD/docs/architecture/modules/{module_id}/module-architecture.xml`
- `PROJECT_SCAFFOLD/docs/architecture/modules/{module_id}/module-interface-contract.md`
- `PROJECT_SCAFFOLD/docs/architecture/modules/{module_id}/components/{component_id}/component-spec.xml`
- `PROJECT_SCAFFOLD/tests/mock/{module_id}/{component_id}_test.*`
- `PROJECT_SCAFFOLD/{component_file_path}` — precise code skeletons for each component

**VCMF Checkpoints**:
- Design as Contract: Module design traces back to system-level PRD; no invented requirements
- Interface as Boundary: Every cross-component call has explicit Input/Output and error codes; cross-module interfaces honor system-level contracts
- Reality as Baseline: Module-level test cases cover happy path, abnormal path, and state lifecycle
- State as Responsibility: `ModuleStateModel` answers where, which component writes, which reads, lifecycle
- XML as Authority: Generated code skeletons strictly match `component-spec.xml` signatures and error handling

**Key Workflow**:
1. Load parent context (PRD, system XML, interface contracts, STATE.md Module Registry)
2. Lock module boundaries (extract system-level module definition)
3. Module-level requirement analysis (filter and decompose system user stories)
4. Component decomposition (3-6 components: entry_point, domain_service, repository, utility, gateway)
5. Component interface design
6. Fill `module-architecture.xml` with Constraints (copied from system-level interfaces), Components, ComponentInterfaces, ModuleStateModel
7. Generate `component-spec.xml` templates for each component
8. **P0/P1/P2 code skeleton generation strategy**:
   - P0 components: complete interface stubs with minimal working implementation (non-empty function bodies returning reasonable defaults)
   - P1 components: interface stubs with `raise NotImplementedError` (or language equivalent)
   - P2 components: file header comments + empty function/class definitions only
9. Generate module-level test code
10. Write `module-prd.md`
11. **Self-validation** (v1.3): cross-module interface compatibility check, schema compliance, PRD traceability, state lifecycle completeness, code skeleton compliance
12. Update `STATE.md` Module Registry + `INDEX.md`
13. Gate: "模块 `{module_id}` 的详细设计已生成，包含模块级 PRD、组件分解、接口契约、XML 模型和精确代码骨架。请确认当前阶段输出。回复 [APPROVE] 继续，回复 [NEXT MODULE] 设计下一个模块，回复 [MODULE_BATCH] 批量设计多个模块，或提出修改意见。"

**Parallel Batch Mode** (`[MODULE_BATCH {id1},{id2},...]`):
1. Coupling analysis: detect circular dependencies; if found, fall back to serial mode
2. Parallel dispatch: construct independent subagent prompts per module, dispatch via native `Agent` tool
3. Result collection: verify all output files exist and are non-empty
4. Consistency check: cross-module interface compatibility, shared StateModel conflicts, dependency completeness
5. Conflict resolution: present conflict matrix; user chooses `[FIX]`, `[DEFER]`, or `[ROLLBACK]`
6. Batch human gate: summary of all modules + conflict resolution status

---

### 3.7 `devforge-test-execution` (v1.3 New)

```yaml
---
name: devforge-test-execution
description: Use when tests have been generated and the user needs to execute them, analyze results, generate coverage reports, and update the Requirement Traceability Matrix. Trigger when user says [TEST].
---
```

**Scope**: Execute all generated tests (unit, integration, end-to-end), analyze results, generate test reports, and synchronize the RTM.

**Input**: `RTM.md`, `PRD.md`, `tests/` directory.

**Output**:
- `docs/architecture/validation/TEST_REPORT.md`
- `docs/architecture/validation/TEST_COVERAGE_GAP.md`
- Updated `RTM.md`

**VCMF Checkpoints**:
- Design as Contract: Every failing test must map back to a PRD requirement ID
- Interface as Boundary: Test input/output must match `component-spec.xml` signatures
- Reality as Baseline: Coverage report must be generated and compared against 80% threshold
- State as Responsibility: State lifecycle tests must verify `StateModel` ownership
- XML as Authority: Test assertions verify code behavior against `component-spec.xml` function contracts

**Key Workflow**:
1. Test checklist load from `RTM.md`
2. Environment preparation (`.env` check, mock mode fallback)
3. Unit test execution (`tests/mock/`) — coverage threshold 80%
4. Integration test execution (`tests/real/` with `skipif`)
5. End-to-end test execution (`tests/end_to_end/`) mapped to PRD User Stories
6. Test report generation (pass rates, coverage trend, failure details)
7. RTM synchronization: passed → `tested`, failed → `implemented`
8. Gate: "测试报告已生成。单元测试通过率 X%，集成测试通过率 Y%，端到端测试通过率 Z%。回复 [APPROVE] 标记测试阶段完成，回复 [DEBUG] 进入调试模式，回复 [RETEST] 重新运行。"

---

### 3.8 `devforge-iteration-planning` (v1.1 New, v1.3 Enhanced)

```yaml
---
name: devforge-iteration-planning
description: Use when a project has completed initial scaffolding and the user wants to add new requirements, features, or modules incrementally without rewriting the existing architecture.
---
```

**Scope**: Incremental planning for new requirements after initial scaffolding is complete.

**Input**: All historical artifacts + new requirement description.

**Output**:
- `PROJECT_SCAFFOLD/docs/architecture/system/ITERATION_PRD.md`
- `PROJECT_SCAFFOLD/docs/architecture/system/ITERATION_PLAN.md`
- Updated `PROJECT_SCAFFOLD/docs/architecture/system/architecture.xml` (incremental changes)
- Updated `PROJECT_SCAFFOLD/docs/architecture/system/INTERFACE_CONTRACT.md` (versioned changes)
- Sync report

**VCMF Checkpoints**:
- Design as Contract: New requirements trace to existing PRD scope or are explicitly flagged as escalation
- Interface as Boundary: Any interface change is versioned; old interfaces remain compatible
- Reality as Baseline: Impact analysis identifies every module affected
- State as Responsibility: New/modified state declares relationship to existing state

**Key Workflow**:
1. Load full baseline (all artifacts + STATE.md)
2. Scope validation (compare against Immutable Goal)
3. Impact analysis (affected modules, severity: breaking/additive/internal)
4. Write incremental PRD (only new/changed requirements)
5. Incremental architecture design (new modules or interface extensions)
6. XML synchronization (propagate changes across layers)
7. Interface versioning (increment version for breaking changes)
8. Generate `ITERATION_PLAN.md` (execution order, affected modules, rollback criteria)
9. Update `STATE.md`: `phase: iteration_planning_completed`, `NextAction: iterate`
10. Gate: "迭代计划已生成。回复 [APPROVE] 按迭代计划逐个模块实施，回复 [MODIFY] 调整迭代范围，回复 [REJECT] 放弃本次迭代。"

---

---

## 4. Global State Management (`STATE.md`)

All skills MUST read `STATE.md` at startup and MUST update it before the human gate.

If a prerequisite artifact is missing or the phase does not match, the skill MUST stop and instruct the user to run the prerequisite skill.

The `STATE.md` contains 12 sections:
1. **Immutable Goal** — Never overwritten
2. **Completed Steps** — Append-only reasoning chain
3. **DecisionDigest** — Append-only, last 20 entries (1-line per decision)
4. **Current State** — Phase, DIVE progress, NextAction, Next skill
5. **Quality Gates** — Configurable thresholds (coverage, performance, security)
6. **Module Registry** — Status of every module (includes `digest` field: 50-word micro-summary)
7. **Iteration History** — All iterations after initial scaffolding
8. **Compressed Context** — 200-word digest for fast session recovery
9. **Artifact Index** — Quick reference to all artifacts
10. **Known Pitfalls & Risks** — Append-only
11. **Error Log** — Every error reported via error-tracing.md format
12. **Intervention Log** — Every human intervention via intervention-checkpoint.md

**Context Loading Protocol** (`references/context-management-protocol.md`):
- Layered summary architecture: Level 1 (200-word global), Level 2 (50-word module digest), Level 3 (1-line decision index)
- Artifact loading rules per skill: Required vs Optional artifacts with full/summary loading
- Context truncation thresholds: 
  - >50,000 tokens: load Optional artifacts as summaries only
  - >150,000 tokens: load only 2 most critical Required artifacts in full
- Cross-session recovery: New sessions read Compressed Context first, then Artifact Index, then Required artifacts

The `Decisions Log` (`DECISION_LOG.md`) records key decisions with:
- Date, Decision ID, Question, Answer, Risk
- Evaluation dimensions and score matrix (for architecture decisions)
- Full reasoning chain (why recommended, why each alternative rejected)
- Rejected alternatives with specific reasons

This prevents requirement drift across multi-turn conversations.

---

## 5. Directory Structure

```
DevForge/
├── .claude-plugin/                  # Claude Code plugin metadata
│   ├── plugin.json
│   └── marketplace.json
├── .env.example                     # Environment variable template
├── LICENSE                          # MIT License
├── README.md                        # Project overview
├── DevForge.md                      # Original monolithic Chinese design document (reference)
├── devforge-design.md               # Skill chain decomposition design (this document)
├── devforge-state.md                # STATE.md template specification (12 sections)
│
├── references/                      # Shared reference documents
│   ├── architecture-patterns.md     # 10-pattern library with evaluation dimensions
│   ├── xml-schemas.md               # Three-layer XML schema definitions (System/Module/Component)
│   ├── system-prompt-template.md    # Global role definition + VCMF constraints
│   ├── context-management-protocol.md # Layered summary + artifact loading rules + token thresholds
│   ├── validation-scripts-manifest.md # Script capability mapping + known gaps
│   └── search-integration.md        # Phase-based search triggers + citation rules
│
├── skill/                           # Internal tools (invoked by other skills)
│   └── tools/
│       ├── context-compression.md   # Automatic context compression after each skill
│       ├── error-tracing.md         # Error format spec with TraceID + DecisionID linkage
│       ├── artifact-manager.md      # CRUD-Append + conflict detection rules
│       ├── intervention-checkpoint.md # Human-in-the-loop commands + checkpoint mechanism
│       ├── precondition-checker.md  # Phase precondition validation
│       ├── state-updater.md         # STATE.md update protocol
│       ├── language-adaptation.md   # User language detection rules
│       └── validation-engine.md     # Common self-validation checks library
│
├── scripts/                         # Utility scripts
│   ├── architecture-ci.sh           # Architecture consistency CI check (incl. security)
│   ├── xml-sync.py                  # XML sync and validation (verify-only + sync modes)
│   └── package-plugin.py            # Packaging script for distribution
│
├── devforge-requirement-analysis/   # Stage 1: Requirement Analysis
│   └── SKILL.md
├── devforge-architecture-design/    # Stage 2: Architecture Design
│   └── SKILL.md
├── devforge-architecture-validation/ # Stage 3a: Architecture Validation
│   └── SKILL.md
├── devforge-design-review/          # Stage 3b: Design Review (adversarial inspection)
│   └── SKILL.md
├── devforge-project-scaffolding/    # Stage 4: Project Scaffolding
│   └── SKILL.md
├── devforge-module-design/          # Stage 5: Module Design (strictly after scaffolding)
│   └── SKILL.md
├── devforge-test-execution/         # Stage 6: Test Execution (v1.3)
│   └── SKILL.md
├── devforge-iteration-planning/     # Stage 7: Iteration Planning
│   └── SKILL.md
├── devforge-visualization/          # Stage 8: Architecture Visualization
│   └── SKILL.md
├── devforge-ops-ready/              # Stage 9: Production-Ready Infrastructure
│   └── SKILL.md
├── devforge-debug-assistant/        # Stage 10: Debug & Refactor Assistant
│   └── SKILL.md
│
└── extensions/                      # Domain-specific overlays (dynamic loading)
    ├── ai-agent-design/
    │   ├── SKILL.md
    │   └── references/
    │       ├── dimensions.md
    │       └── anti-patterns.md
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

---

## 6. VCMF Integration Mapping

| Skill | Design as Contract | Interface as Boundary | Reality as Baseline | State as Responsibility | XML as Authority |
|-------|-------------------|----------------------|---------------------|------------------------|-----------------|
| `devforge-requirement-analysis` | PRD success metrics & scope boundaries | Cross-module interaction points | Observable acceptance criteria | State ownership documented | PRD references XML schema locations |
| `devforge-architecture-design` | Traceability to PRD; no invented reqs | Interface contracts in markdown + XML | Test cases for all paths + NFRs | `<StateModel>` in XML | System + Module XML templates |
| `devforge-architecture-validation` | XML modules traceable to PRD | `Coupling` matches Interface Contract | Real-LLM semantic validation (degraded OK) | `StateModel` consistency check | Reference integrity + schema compliance |
| `devforge-design-review` | Flag orphaned assumptions | Verify edge case handling | Verify mock data coverage | Verify complete lifecycle | Verify XML artifacts are complete |
| `devforge-project-scaffolding` | Every file traceable to artifact | CI/CD pipeline includes arch-check job | Mock + real tests generated; coverage 80% | Code matches `StateModel` | `INDEX.md` indexes all XML artifacts |
| `devforge-module-design` | Traces to system PRD scope | Component interface contracts; cross-module compatibility | Module-level test cases | `ModuleStateModel` | Fills module + component XML; skeletons match spec |
| `devforge-test-execution` | Failing tests map to PRD req IDs | Test I/O matches `component-spec.xml` | Coverage report vs 80% threshold | State lifecycle tests verify ownership | Test assertions verify XML function contracts |
| `devforge-iteration-planning` | Scope validation against Immutable Goal | Versioned interface changes | Impact analysis identifies all affected modules | State migration strategy | XML sync across all three layers |
| `devforge-visualization` | Diagrams reflect approved XML | Shows all cross-module interfaces | Data flow matches `<Coupling>` definitions | Shows state ownership (writes vs reads) | All elements verifiable by node ID |
| `devforge-ops-ready` | Resources map 1:1 to `Module` nodes | K8s ports match `Interface` definitions | Monitoring metrics are collectable | Persistence policies match `StateModel` | Every resource traceable to `Module`/`StateModel` |
| `devforge-debug-assistant` | Fixes respect `INTERFACE_CONTRACT.md` | Refactoring preserves public interfaces | Diagnosis based on actual test output/logs | State fixes respect `StateModel` ownership | Fixes update `component-spec.xml` if XML is source |

## 6.1 Triple Verification Mechanism (v1.3)

| Dimension | 3a. architecture-validation | 3b. design-review | 3c. security-audit |
|-----------|---------------------------|-------------------|-------------------|
| **Purpose** | Verify "design is correctly specified" | Verify "design has no gaps/errors" | Verify "design has no security flaws" |
| **Perspective** | Technical consistency (engineer view) | Adversarial review (critic view) | Security scan (auditor view) |
| **Input** | architecture.xml, INTERFACE_CONTRACT.md | PRD, architecture.xml, DECISION_LOG | architecture.xml, code, dependencies |
| **Check items** | XML Schema compliance, interface consistency, PRD traceability | Security, operability, scalability | Vulnerabilities, secrets, compliance |
| **Output** | VALIDATION_REPORT.md (PASS/FAIL) | DESIGN_REVIEW.md (issue list, no PASS/FAIL) | SECURITY_AUDIT_REPORT.md (risk levels) |
| **Result** | Fail must be fixed before continuing | Issues can be accepted, deferred, or fixed | Critical issues must be fixed before deployment |
| **Analogy** | Compiler type checking | Code review | Security penetration test |

**Relationship**: validation ensures "design documents are self-consistent", design-review ensures "design decisions are correct", security-audit ensures "design is secure". The three complement each other and cannot substitute for one another.

**Flow rules**: Stages 3a and 3b both run by default. Stage 3c (security-audit) is optional but recommended. User can `[SKIP_REVIEW]` or `[SKIP_VALIDATION]`.

---

## 7. DIVE Cycle Mapping

| DIVE Stage | Skills | Key Activity |
|------------|--------|--------------|
| **Design** | `devforge-requirement-analysis` + `devforge-architecture-design` + `devforge-module-design` | Lock requirements, interfaces, state ownership, architecture, component decomposition, code skeletons |
| **Implement** | `devforge-project-scaffolding` | Generate infrastructure, CI/CD, test framework, deployment topology |
| **Verify** | `devforge-architecture-validation` + `devforge-design-review` + `devforge-test-execution` | Technical consistency check + adversarial inspection + security scan + test execution + coverage |
| **Evolve** | `devforge-iteration-planning` | Impact analysis, incremental PRD, interface versioning, XML sync; loops back to 3a/3b if breaking changes |
| **Visualize** | `devforge-visualization` | Mermaid diagrams from `architecture.xml` |
| **Operate** | `devforge-ops-ready` | Terraform, K8s, monitoring, progressive deployment |
| **Debug** | `devforge-debug-assistant` | Bug diagnosis + refactoring + production incident analysis; accepts `test_execution_completed` as entry point |

---

### 3.8 `devforge-visualization` (v1.2 New)

```yaml
---
name: devforge-visualization
description: Use when a system architecture XML has been approved and the user wants visual diagrams. Trigger when user says [VISUALIZE] or "generate architecture diagram".
---
```

**Scope**: Generate Mermaid-based architecture diagrams from `architecture.xml`.

**Input**: Approved `PROJECT_SCAFFOLD/docs/architecture/system/architecture.xml`.

**Output**:
- `docs/architecture/diagrams/system-context.md`
- `docs/architecture/diagrams/module-interaction.md`
- `docs/architecture/diagrams/data-flow.md`
- `docs/architecture/diagrams/er-diagram.md`

**VCMF Checkpoints**:
- Design as Contract: Diagrams must reflect approved XML, not invention
- Interface as Boundary: Interaction diagrams must show all cross-module interfaces
- Reality as Baseline: Data flow must match actual XML `<Coupling>` definitions

**Key Workflow**:
1. Parse `architecture.xml`
2. Generate system context diagram (system + external dependencies)
3. Generate module interaction sequence diagram (core user story call chains)
4. Generate data flow diagram (data transformation across modules)
5. Generate ER diagram from `DataModel` nodes
6. Output all diagrams to `docs/architecture/diagrams/`
7. Gate: "架构可视化图表已生成。回复 [APPROVE] 完成，或提出修改意见。"

---

### 3.9 `devforge-ops-ready` (v1.2 New)

```yaml
---
name: devforge-ops-ready
description: Use when a project has completed scaffolding and the user needs production-ready infrastructure. Trigger when user says [OPS] or "generate deployment config".
---
```

**Scope**: Generate Terraform, Kubernetes, monitoring, and progressive deployment configurations.

**Input**: Approved `architecture.xml`, `STATE.md`.

**Output**:
- `infrastructure/terraform/` — Terraform modules (network, compute, database, cache, storage)
- `infrastructure/kubernetes/` — K8s manifests with Kustomize (base + dev/staging/prod overlays)
- `infrastructure/monitoring/` — Prometheus rules + Grafana dashboards
- `infrastructure/multi-env/` — Environment-specific Terraform variables
- `infrastructure/kubernetes/overlays/prod/progressive/blue-green/` — Blue-green deployment
- `infrastructure/kubernetes/overlays/prod/progressive/canary/` — Canary deployment
- `docs/ops/runbook.md` — Operational manual

**VCMF Checkpoints**:
- Design as Contract: Terraform resources map 1:1 to `Module` nodes
- Interface as Boundary: K8s service ports match `Interface` definitions
- Reality as Baseline: Monitoring metrics are collectable
- State as Responsibility: Persistence policies match `StateModel`

**Key Workflow**:
1. Read `architecture.xml` and infer resource requirements
2. Generate Terraform configuration
3. Generate K8s manifests with Kustomize
4. Generate monitoring (Prometheus RED metrics + Grafana dashboards)
5. Generate multi-environment configs
6. Generate progressive deployment manifests (blue-green + canary with promotion/rollback policies)
7. Generate operational runbook
8. Update `STATE.md`
9. Gate: "生产就绪基础设施已生成。回复 [APPROVE] 完成，或提出修改意见。"

---

### 3.10 `devforge-debug-assistant` (v1.2 New)

```yaml
---
name: devforge-debug-assistant
description: Use when tests are failing, logs show anomalies, or the user wants code-level improvements. Trigger when user says [DEBUG] or "fix this bug" or "refactor this code".
---
```

**Scope**: Bug diagnosis with root cause analysis and refactoring suggestions.

**Input**: Failing test output, error logs, source code, `component-spec.xml`.

**Output**:
- Mode A: `PROJECT_SCAFFOLD/docs/architecture/system/DEBUG_REPORT.md`
- Mode B: `PROJECT_SCAFFOLD/docs/architecture/system/REFACTOR_REPORT.md`

**VCMF Checkpoints**:
- Design as Contract: Fixes must not violate `INTERFACE_CONTRACT.md`
- Interface as Boundary: Refactoring must preserve public interfaces
- Reality as Baseline: Diagnosis based on actual test output / logs
- State as Responsibility: Bug fixes involving state must respect `StateModel` ownership

**Key Workflow (Mode A - Bug Fix)**:
1. Collect evidence (failing tests, stack traces, logs)
2. Root cause analysis (logic error, state error, interface mismatch, dependency failure)
3. Propose minimal fix with regression risk assessment
4. Generate `DEBUG_REPORT.md`
5. Human gate: "调试报告已生成。回复 [APPROVE FIX] 应用修复，或提出修改意见。"

**Key Workflow (Mode B - Refactor)**:
1. Code health scan (code smells, architecture alignment)
2. Identify improvement opportunities
3. Propose refactorings with before/after snippets and risk levels
4. Generate `REFACTOR_REPORT.md`
5. Human gate: "重构报告已生成。回复 [APPROVE REFACTOR] 应用重构，或提出修改意见。"

---

### 3.11 `context-compression` (v1.1 Internal Utility)

```yaml
---
name: context-compression
description: Internal utility skill used by other DevForges to compress session context into a persistent digest. NOT for direct user invocation.
---
```

**Scope**: Automatic context compression after each skill completes.

**Input**: `STATE.md` + primary output artifact of completed skill + `DECISION_LOG.md`.

**Output**: Updated `STATE.md` (Compressed Context, Artifact Index, DecisionDigest).

**Key Workflow**:
1. Read existing compressed context
2. Extract top 3 decisions and top 2 risks from completed skill
3. Generate 200-word digest
4. Update Compressed Context section in STATE.md
5. Append to Artifact Index
6. Update DecisionDigest list (keep last 20 entries)

---

## 8. Implementation Path (v1.2 Completed)

### Completed in v1.2

- [x] Database schema (DDL) generation (`schema.sql`, `ERD.md`) in `devforge-architecture-design`
- [x] OpenAPI 3.0 specification generation (`openapi.yaml`) in `devforge-architecture-design`
- [x] Test coverage integration (pytest-cov, jest, jacoco, Go cover) in `devforge-project-scaffolding`
- [x] `devforge-visualization/SKILL.md` — Mermaid diagram generation
- [x] `devforge-ops-ready/SKILL.md` — Terraform, K8s, monitoring, multi-env, runbook
- [x] Progressive deployment strategies (blue-green + canary) in `devforge-ops-ready`
- [x] `devforge-debug-assistant/SKILL.md` — Bug diagnosis + refactoring suggestions
- [x] RTM (Requirement Traceability Matrix) auto-generation in `devforge-requirement-analysis`
- [x] Phase 8/9/10 registered in `DevForge.md`
- [x] Context management protocol (`references/context-management-protocol.md`) — layered summaries, artifact loading rules, token thresholds
- [x] `repo-index.md` generation in `devforge-project-scaffolding` — rapid codebase navigation for debug/ops skills
- [x] Module Registry `digest` field in `devforge-state.md` — 50-word micro-summaries for context recovery
- [x] Self-validation checkpoints — syntax validation, schema compliance, traceability checks across 7 skills
- [x] Language adaptation — all 10 skills adapt user-facing output to user's input language
- [x] Technology stack validation rule — active search (WebSearch/WebFetch) before recommending tools; blacklist enforcement (VM2, RCE libs)
- [x] `references/system-prompt-template.md` — global VCMF constraints + output quality standards
- [x] `references/validation-scripts-manifest.md` — script capability mapping + gap documentation

### Completed in v1.3

- [x] **Triple Verification Mechanism** — architecture-validation (3a) + design-review (3b) + security-audit (3c) with clear separation of concerns
- [x] **`devforge-test-execution` skill** — unit/integration/e2e test execution, coverage reporting (80% threshold), RTM synchronization
- [x] **Verification phase continuity** — both validation (3a) and design-review (3b) run by default; user can `[SKIP_REVIEW]`
- [x] **FIX sub-flow** — `[FIX <issue_id>]` generates diff, `[APPLY]` triggers auto re-validation in design-review
- [x] **Module-design strictly after scaffolding** — precondition check enforces `scaffolding_completed`
- [x] **Native agent-based parallel batch mode** — `[MODULE_BATCH {ids}]` dispatches subagents in parallel with consistency check
- [x] **Cross-module interface compatibility check** — module-design self-validation verifies output schemas match downstream input schemas
- [x] **Iteration post-implementation validation loop** — breaking changes trigger `[VALIDATE]` prompt after iteration scaffolding
- [x] **P0/P1/P2 placeholder generation strategy** — P0 stubs with working defaults, P1 with `NotImplementedError`, P2 with empty definitions
- [x] **`docs/architecture/INDEX.md` generation** — unified document registry + module table in scaffolding
- [x] **RTM real-time updates** — all skills update RTM columns progressively (Module → Component → Test Case → Status)
- [x] **Web research integration** — requirement-analysis performs conditional WebSearch for competitor analysis and industry standards
- [x] **Quality Gates** — configurable thresholds (coverage, performance, security) in STATE.md
- [x] **12-section STATE.md** — added DecisionDigest, Quality Gates, Error Log, Intervention Log
- [x] **Production incident diagnosis** (Mode C) — debug-assistant supports production log/metric/trace analysis

### Completed in v1.1

- [x] Dynamic pattern library (`references/architecture-patterns.md`, 10 patterns)
- [x] Three-layer XML schema (`references/xml-schemas.md`)
- [x] XML CI scripts (`scripts/architecture-ci.sh`, `scripts/xml-sync.py`)
- [x] `devforge-module-design/SKILL.md`
- [x] `devforge-iteration-planning/SKILL.md`
- [x] `context-compression/SKILL.md`
- [x] Domain extensions (`extensions/ai-agent-design/`, `extensions/data-pipeline-design/`, `extensions/mobile-app-design/`)
- [x] Updated `devforge-state.md` with Module Registry, Iteration History, Compressed Context, Artifact Index
- [x] Updated precondition checks across all skills for iteration states
- [x] Updated `devforge-project-scaffolding` for XML-driven code generation and architecture CI
- [x] Updated `devforge-architecture-validation` for `VALIDATION_DELTA.md`

---

## 9. Constraints and Principles (Inherited from Original Design)

- **Global memory first**: `STATE.md` and artifacts are the single source of truth
- **Gate is absolute**: Must wait for human `[APPROVE]`; auto-jumping is forbidden
- **Hard deliverables**: Every phase must produce actual code, YAML, CI configs, and test scripts with logging — no abstract "advice"
- **Privacy management**: All API keys and tokens must live in `.env` files only
- **XML as Authority**: Code signatures must match `component-spec.xml`; CI enforces this
- **Incremental Evolution**: Existing framework stays; only additions and targeted modifications allowed
- **Context Management**: Follow `references/context-management-protocol.md` for artifact loading. Use layered summaries (200-word global, 50-word module digest, 1-line decision index). Respect >50k / >150k token thresholds.
- **Self-validation**: Every artifact-producing skill runs automated checks before the human gate (syntax, schema, traceability, cross-reference integrity, cross-module interface compatibility).
- **Language Adaptation**: System instructions in English; user-facing messages in the user's input language.
- **Technology Stack Validation**: Active search before recommending tools; never recommend blacklisted libraries (VM2, known RCE) without explicit approval.
- **Error Tracing**: All errors MUST follow `skill/tools/error-tracing.md` format (TraceID, DecisionID linkage, fix suggestions).
- **Artifact Management**: All artifacts MUST follow `skill/tools/artifact-manager.md` CRUD-Append rules (read existing → compute diff → update delta → preserve manual edits).
- **Intervention Checkpoint**: Human gate MUST support `[PAUSE]`, `[ROLLBACK]`, `[EXPLAIN]`, `[EDIT]`, `[SKIP]`, `[INJECT]`, `[FIX]`, `[APPLY]`, `[FORCE_APPROVE]`, `[SKIP_REVIEW]`, `[DESIGN_REVIEW]`, `[VALIDATE]`, `[TEST]`, `[MODULE_BATCH]` per `skill/tools/intervention-checkpoint.md`.
- **Security Audit**: Code generation MUST trigger `devforge-security-audit` scan; Critical issues MUST be fixed before proceeding.
- **Search Integration**: Tool recommendations MUST follow `references/search-integration.md` (WebSearch for CVE, deprecation, benchmarks; cache 24h).
- **Test Coverage**: All projects must maintain ≥80% unit test coverage; CI must fail if below threshold.

---

*Design Document Version: v1.3*
*Date: 2026-05-08*
