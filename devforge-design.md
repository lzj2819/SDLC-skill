# DevForge Decomposition Design v1.1

> **Design Objective**: Decompose the original monolithic skill `软件开发全流程智能体技能(DevForge).md` into composable skills that embed VCMF principles and the DIVE cycle. The skill chain models a "single thinker's iterative drafts" rather than a "role relay race": each skill is the same thinker unfolding the same complex problem from a different dimension, always holding the complete intent.
>
> **v1.1 Additions**: Three-layer XML architecture (System/Module/Component), dynamic pattern selection (10 patterns), module-level design skill, iteration planning skill, domain extensions (overlay mechanism), context compression utility, and XML-driven code generation.

---

## 1. Design Decisions

### 1.1 Selection Conclusion

Adopt **Option B: Workflow-Aggregate Decomposition (7 Skills + Utilities)**.

**Reasons**:
- Creates a natural skill chain where each skill maps cleanly to a DIVE stage
- Skill granularity is moderate, trigger conditions are clear, and users do not need to switch too frequently
- Aligns with the VCMF principles by inserting explicit checkpoints at every phase transition
- v1.1 additions (module-design, iteration-planning) extend the chain without breaking existing flow

### 1.2 Scope

**General-purpose**: Not tied to a specific architecture pattern. Applicable to Web apps, mobile apps, backend services, CLI tools, AI agents, data pipelines, and any other software engineering scenario.

---

## 2. Overall Architecture

```
User inputs a raw idea
    |
    v
+-----------------------------------------------------------+
|  devforge-requirement-analysis                                |
|  DIVE: Design                                             |
|  1st Unfold: Lock goal and boundaries                     |
|  Outputs: PRD.md + DECISION_LOG.md                        |
+-----------------------------------------------------------+
    | [APPROVE]
    v
+-----------------------------------------------------------+
|  devforge-architecture-design                                 |
|  DIVE: Design (deepen)                                    |
|  2nd Unfold: Dynamic pattern exploration + synthesis      |
|  Internal: orchestrator-worker + domain extension overlay |
|  Outputs: ARCHITECTURE.md + INTERFACE_CONTRACT.md         |
|           + architecture.xml (System Level)               |
|           + module-architecture.xml templates             |
+-----------------------------------------------------------+
    | [APPROVE]
    v
    +-------------------------+-------------------------+
    |                         |
    v                         v
+------------------+   +---------------------------+
| devforge-architecture|   | devforge-design-review         |
| -validation      |   | DIVE: Verify               |
| (Optional)       |   | 3rd Unfold: Skeptical      |
| Technical        |   |    examination (NOT gate)  |
| consistency +    |   | Output: DESIGN_REVIEW.md   |
| XML delta report |   | (problem list, no PASS/FAIL)|
+------------------+   +---------------------------+
    |                         | [APPROVE / FIX]
    +-------------------------+
                              v
+-----------------------------------------------------------+
|  devforge-project-scaffolding                                 |
|  DIVE: Implement + Evolve                                 |
|  4th Unfold: Ground with full context                     |
|  Reads ALL historical artifacts + XML specs               |
|  Outputs: PROJECT_SCAFFOLD/ + .env.template               |
|           + docs/sync-rules.md + docs/ADR.md + CHANGELOG  |
|           + XML-driven code skeletons                     |
+-----------------------------------------------------------+
    | [APPROVE]
    v
+-----------------------------------------------------------+
|  (Optional) devforge-module-design                            |
|  DIVE: Design (module-level)                              |
|  Trigger: [MODULE {id}]                                   |
|  Outputs: module-prd.md + module-architecture.xml         |
|           + component-spec.xml templates                  |
+-----------------------------------------------------------+
    | [APPROVE / NEXT MODULE]
    v
+-----------------------------------------------------------+
|  (Iteration) devforge-iteration-planning                      |
|  DIVE: Evolve                                             |
|  Trigger: New requirements after scaffolding              |
|  Outputs: ITERATION_PRD.md + ITERATION_PLAN.md            |
|           + Updated architecture.xml + VALIDATION_DELTA   |
+-----------------------------------------------------------+
    | [APPROVE]
    v
   Done (or loop back to module-design / architecture-design)
```

**Core Design Principles**:
1. **Composable**: Each skill has an independent trigger and can be invoked alone or in a chain.
2. **File-based State**: Global state is persisted via `STATE.md`, not LLM context. STATE.md is a reasoning chain anchor (8 categories: Immutable Goal, Completed Steps, Current State, Module Registry, Iteration History, Compressed Context, Artifact Index, Known Pitfalls).
3. **Human-in-the-loop**: Every skill halts at `[APPROVE]`. Auto-jumping is forbidden.
4. **Subagent Ready**: Complex subtasks are executed via internal subagent dispatch, but the skill itself remains self-contained.
5. **Single Thinker Model**: All skills = same thinker unfolding the same problem from different dimensions, not workers passing documents. Each skill reads ALL historical artifacts, not just the previous phase's output.
6. **Adversarial Inspection**: Validation checks technical consistency; design-review finds flaws. The reviewer is a skeptic, not a successor.
7. **XML as Authority**: `component-spec.xml` is the single source of truth for code generation. CI enforces consistency between code and XML.
8. **Incremental Evolution**: The existing framework stays; only additions and targeted modifications are allowed in iterations.

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
- `skill/artifacts/PRD.md`
- `skill/artifacts/DECISION_LOG.md` (seeded)

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
8. Write PRD to `skill/artifacts/PRD.md`
9. Seed `skill/artifacts/DECISION_LOG.md`
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

**Input**: Approved `skill/artifacts/PRD.md`.

**Output**:
- `skill/artifacts/ARCHITECTURE.md`
- `skill/artifacts/INTERFACE_CONTRACT.md`
- `skill/artifacts/architecture.xml` (System Level)
- `skill/artifacts/modules/{module_id}/module-architecture.xml` (templates)

**VCMF Checkpoints**:
- Design as Contract: Architecture traceable back to PRD; no invented requirements
- Interface as Boundary: Every cross-module call has explicit Input/Output and error codes
- Reality as Baseline: Test cases cover happy path, abnormal path, and NFRs
- State as Responsibility: XML `<StateModel>` answers where, who writes, who reads, lifecycle

**Key Workflow**:
1. Read `STATE.md`, `PRD.md`, `DECISION_LOG.md`
2. Read `skill/references/architecture-patterns.md` (10-pattern library)
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
- `skill/artifacts/PRD.md`
- `skill/artifacts/ARCHITECTURE.md`
- `skill/artifacts/INTERFACE_CONTRACT.md`
- `skill/artifacts/architecture.xml`
- Module-level XMLs (if exist)

**Output**:
- `skill/artifacts/VALIDATION_REPORT.md`
- `docs/architecture/validation/VALIDATION_DELTA_{YYYYMMDD}.md`
- `skill/artifacts/health-check.sh`

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
- `skill/artifacts/DESIGN_REVIEW.md`

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

**Scope**: Original Phase 5 (scaffolding + transparent test engineering). v1.1 adds XML-driven code generation, architecture CI checks, and `docs/architecture/` output.

**Input**: All prior artifacts + XML schemas.

**Output**:
- `skill/artifacts/PROJECT_SCAFFOLD/` directory tree with runnable files
- `docs/architecture/system/` and `docs/architecture/modules/{id}/`
- `.env.template`
- `docs/sync-rules.md`
- `CHANGELOG.md`

**VCMF Checkpoints**:
- Design as Contract: Every generated file traceable to PRD or Architecture
- Interface as Boundary: Generated code signatures match `INTERFACE_CONTRACT.md` and `component-spec.xml`
- Reality as Baseline: Tests include both mock and real-LLM tests with `skipif`
- State as Responsibility: Generated state management matches `StateModel` ownership
- XML as Authority: Generated code skeletons strictly match `component-spec.xml`

**Key Workflow**:
1. Read all prior artifacts, `STATE.md`, and `skill/references/xml-schemas.md`
2. Internal lightweight planning (files, tests, directories)
3. Generate directory tree and dependency configs
4. Copy architecture artifacts to `docs/architecture/`; generate `.gitattributes`
5. Generate core code skeleton matching interface contracts
6. **XML-driven generation**: If `component-spec.xml` exists, generate code matching Signatures and ErrorHandling
7. Generate deployment topology (`docker-compose.yml` or K8s manifests)
8. Generate CI/CD config with `architecture-check` job (runs `architecture-ci.sh` + `xml-sync.py --verify-only`)
9. Generate `.env.template`
10. Generate transparent test fixtures organized into `tests/mock/`, `tests/real/`, `tests/end_to_end/`
11. Generate `docs/sync-rules.md`
12. Update `DECISION_LOG.md` and generate `CHANGELOG.md`
13. Internal verification (signatures match XML, paths correct, CI references valid)
14. Update `STATE.md`: `phase: scaffolding_completed`
15. Gate: "项目脚手架已生成，包含工程目录、CI/CD 配置、测试脚本、文档同步规则和环境变量模板。请确认当前阶段输出。回复 [APPROVE] 完成全流程，或提出修改意见。"

---

### 3.6 `devforge-module-design` (v1.1 New)

```yaml
---
name: devforge-module-design
description: Use when a system-level architecture has been approved and the user needs detailed design for a specific module, including module-level PRD, component decomposition, component interfaces, and module-level XML. Trigger when user says [MODULE {module_id}] or asks to design a specific module in detail.
---
```

**Scope**: Deep-dive design for a single module within an approved system architecture.

**Input**: System-level PRD, `architecture.xml`, `INTERFACE_CONTRACT.md`, target `module_id`.

**Output**:
- `modules/{module_id}/module-prd.md`
- `modules/{module_id}/module-architecture.xml`
- `modules/{module_id}/module-interface-contract.md`
- `modules/{module_id}/components/{component_id}/component-spec.xml` (templates)

**VCMF Checkpoints**:
- Design as Contract: Module design traces back to system-level PRD; no invented requirements
- Interface as Boundary: Every cross-component call has explicit Input/Output and error codes
- Reality as Baseline: Module-level test cases cover happy path, abnormal path, and state lifecycle
- State as Responsibility: `ModuleStateModel` answers where, which component writes, which reads, lifecycle

**Key Workflow**:
1. Load parent context (PRD, system XML, interface contracts)
2. Lock module boundaries (extract system-level module definition)
3. Module-level requirement analysis (filter and decompose system user stories)
4. Component decomposition (3-6 components: entry_point, domain_service, repository, utility)
5. Component interface design
6. Fill `module-architecture.xml` with Constraints, Components, ComponentInterfaces, ModuleStateModel
7. Generate `component-spec.xml` templates for each component
8. Generate module-level test cases
9. Write `module-prd.md`
10. Update `STATE.md` Module Registry
11. Gate: "模块 `{module_id}` 的详细设计已生成。回复 [APPROVE] 进入该模块的脚手架阶段，回复 [NEXT MODULE] 设计下一个模块，或提出修改意见。"

---

### 3.7 `devforge-iteration-planning` (v1.1 New)

```yaml
---
name: devforge-iteration-planning
description: Use when a project has completed initial scaffolding and the user wants to add new requirements, features, or modules incrementally without rewriting the existing architecture.
---
```

**Scope**: Incremental planning for new requirements after initial scaffolding is complete.

**Input**: All historical artifacts + new requirement description.

**Output**:
- `ITERATION_PRD.md`
- `ITERATION_PLAN.md`
- Updated `architecture.xml` (incremental changes)
- Updated `INTERFACE_CONTRACT.md` (versioned changes)
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

### 3.8 `context-compression` (v1.1 Internal Utility)

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

## 4. Global State Management (`STATE.md`)

All skills MUST read `STATE.md` at startup and MUST update it before the human gate.

If a prerequisite artifact is missing or the phase does not match, the skill MUST stop and instruct the user to run the prerequisite skill.

The `STATE.md` contains 8 sections:
1. **Immutable Goal** — Never overwritten
2. **Completed Steps** — Append-only reasoning chain
3. **Current State** — Phase, DIVE progress, NextAction
4. **Module Registry** — Status of every module
5. **Iteration History** — All iterations after initial scaffolding
6. **Compressed Context** — 200-word digest for fast session recovery
7. **Artifact Index** — Quick reference to all artifacts
8. **Known Pitfalls & Risks** — Append-only

The `Decisions Log` (`DECISION_LOG.md`) records key decisions with:
- Date, Decision ID, Question, Answer, Risk
- Evaluation dimensions and score matrix (for architecture decisions)
- Full reasoning chain (why recommended, why each alternative rejected)
- Rejected alternatives with specific reasons

This prevents requirement drift across multi-turn conversations.

---

## 5. Directory Structure

```
skill/
├── README.md
├── devforge-design.md
├── devforge-plan.md
├── devforge-state.md
├── 软件开发全流程智能体技能(DevForge).md
├── references/
│   ├── architecture-patterns.md      # 10-pattern library with evaluation dimensions
│   └── xml-schemas.md                # Three-layer XML schema definitions
├── scripts/
│   ├── architecture-ci.sh            # CI health check script
│   └── xml-sync.py                   # XML sync and validation script
├── artifacts/                        # Generated artifacts (or docs/architecture/ in iteration mode)
│   ├── STATE.md
│   ├── PRD.md
│   ├── DECISION_LOG.md
│   ├── INTERFACE_CONTRACT.md
│   ├── ARCHITECTURE.md
│   ├── architecture.xml
│   ├── VALIDATION_REPORT.md
│   ├── VALIDATION_DELTA.md
│   ├── DESIGN_REVIEW.md
│   ├── ITERATION_PRD.md
│   ├── ITERATION_PLAN.md
│   ├── health-check.sh
│   └── PROJECT_SCAFFOLD/
│       └── docs/
│           ├── sync-rules.md
│           └── ADR.md
├── devforge-requirement-analysis/
│   └── SKILL.md
├── devforge-architecture-design/
│   └── SKILL.md
├── devforge-architecture-validation/
│   └── SKILL.md
├── devforge-design-review/
│   └── SKILL.md
├── devforge-project-scaffolding/
│   └── SKILL.md
├── devforge-module-design/
│   └── SKILL.md
├── devforge-iteration-planning/
│   └── SKILL.md
├── context-compression/
│   └── SKILL.md
└── extensions/
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
| `devforge-requirement-analysis` | PRD success metrics & scope boundaries | Cross-module interaction points | Observable acceptance criteria | State ownership documented | — |
| `devforge-architecture-design` | Traceability to PRD; no invented reqs | Interface contracts in markdown + XML | Test cases for all paths + NFRs | `<StateModel>` in XML | System + Module XML templates |
| `devforge-architecture-validation` | XML modules traceable to PRD | `Coupling` matches Interface Contract | Real-LLM semantic validation (degraded OK) | `StateModel` consistency check | Reference integrity check |
| `devforge-design-review` | Flag orphaned assumptions | Verify edge case handling | Verify mock data coverage | Verify complete lifecycle | — |
| `devforge-project-scaffolding` | Every file traceable to artifact | Code signatures match contracts | Mock + real tests generated | Code matches `StateModel` | Code matches `component-spec.xml` |
| `devforge-module-design` | Traces to system PRD scope | Component interface contracts | Module-level test cases | `ModuleStateModel` | Fills module + component XML |
| `devforge-iteration-planning` | Scope validation against Immutable Goal | Versioned interface changes | Impact analysis identifies all affected modules | State migration strategy | XML sync across layers |

---

## 7. DIVE Cycle Mapping

| DIVE Stage | Skills | Key Activity |
|------------|--------|--------------|
| **Design** | `devforge-requirement-analysis` + `devforge-architecture-design` + `devforge-module-design` | Lock the "things that should not change": requirements, interfaces, state ownership, architecture, component decomposition |
| **Implement** | `devforge-project-scaffolding` | Generate runnable project skeleton with infrastructure code and XML-driven code generation |
| **Verify** | `devforge-architecture-validation` + `devforge-design-review` | Mock flow validation + real-LLM semantic checks + consistency audits + adversarial inspection |
| **Evolve** | `devforge-iteration-planning` | Impact analysis, incremental PRD, interface versioning, XML sync, iteration planning |

---

## 8. Implementation Path (v1.1 Completed)

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
- **Hard deliverables**: Phase 5 must produce actual code, YAML, CI configs, and test scripts with logging
- **Privacy management**: All API keys and tokens must live in `.env` files only
- **XML as Authority**: Code signatures must match `component-spec.xml`; CI enforces this
- **Incremental Evolution**: Existing framework stays; only additions and targeted modifications allowed

---

*Design Document Version: v1.1*
*Date: 2026-04-24*
