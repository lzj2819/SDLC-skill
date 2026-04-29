---
title: DevForge State
description: Template for the file-based state used by the DevForge chain
---

# DevForge State

> **File path variant**: During initial development this file lives at `skill/artifacts/STATE.md`. During incremental iteration mode it lives at `docs/architecture/system/STATE.md`.

## 1. Immutable Goal (Never Overwritten)
> Read at the start of every skill invocation to prevent drift.

- Original product idea: [verbatim from user]
- Core success metrics: [quantifiable criteria]
- Scope boundary (in-scope / out-of-scope): [...]

## 2. Completed Steps (Append-Only, Never Overwritten)
> Each skill appends its key decisions here after completion.

- [YYYY-MM-DD HH:MM] devforge-requirement-analysis: [key decision summary]
- [YYYY-MM-DD HH:MM] devforge-architecture-design: [key decision summary]
- [YYYY-MM-DD HH:MM] devforge-architecture-validation: [key decision summary]
- [YYYY-MM-DD HH:MM] devforge-design-review: [key decision summary]
- [YYYY-MM-DD HH:MM] devforge-project-scaffolding: [key decision summary]
- [YYYY-MM-DD HH:MM] devforge-module-design: [module_id] - [key decision summary]
- [YYYY-MM-DD HH:MM] devforge-iteration-planning: [iteration scope summary]

## 3. DecisionDigest (Append-Only, Last 20 Entries)
> Quick-reference digest of key architectural and product decisions. Truncate older entries to keep the list at 20 items max.

- `[YYYY-MM-DD] [arch-dec-0001]`: Hexagonal for core domain (isolate LLM provider)
- `[YYYY-MM-DD] [prd-dec-0001]`: Scope payment module to P1 (defer crypto)

## 4. Current State (Overwritten)
> Reflects the latest progress.

- phase: [requirement_analysis_completed | architecture_design_completed | architecture_validated | design_review_completed | scaffolding_completed | module_design_completed | iteration_planning_completed | visualization_completed | ops_ready_completed | evolution_completed]
- DIVE:
  - Design: [pending | in_progress | completed]
  - Implement: [pending | in_progress | completed]
  - Verify: [pending | in_progress | completed]
  - Evolve: [pending | in_progress | completed]
- NextAction: [iterate | refactor | module | none]
  - `iterate`: Run devforge-iteration-planning for incremental features
  - `refactor`: Run devforge-architecture-design for architectural changes
  - `module`: Run devforge-module-design for the next un-designed module
  - `none`: No pending action; project is in steady state
- Next skill: [devforge-architecture-design | devforge-architecture-validation | devforge-design-review | devforge-project-scaffolding | devforge-module-design | devforge-iteration-planning | devforge-visualization | devforge-ops-ready | devforge-debug-assistant]

## 5. Module Registry (Updated by devforge-module-design and devforge-iteration-planning)
> Tracks the status of every module in the system.

```yaml
module_registry:
  - id: UserService
    status: scaffolded          # [pending | design_completed | scaffolded]
    path: modules/UserService/
    owner: team-auth
    interface_version: "1.0.0"
    digest: "Auth domain: JWT + RBAC, 3 components, 8 interfaces"  # 50-word max micro-summary
  - id: OrderService
    status: design_completed
    path: modules/OrderService/
    owner: team-commerce
    interface_version: "1.0.0"
    digest: "Commerce core: order lifecycle, inventory sync, 5 components"  # 50-word max micro-summary
  - id: PaymentService
    status: pending
    path: modules/PaymentService/
    owner: team-commerce
    interface_version: null
    digest: ""  # Populate after module design
```

## 6. Iteration History (Append-Only)
> Tracks all iterations after initial scaffolding.

```yaml
iteration_history:
  - iteration: 0
    date: 2026-04-24
    scope: "Initial system scaffolding"
    affected_modules: ["UserService", "OrderService"]
    status: completed
  - iteration: 1
    date: 2026-05-01
    scope: "Add payment module and user profile extension"
    affected_modules: ["PaymentService", "UserService"]
    status: planned
```

## 7. Compressed Context (Updated after every skill)
> 200-word digest for fast session recovery. New sessions read this first.

- **Project**: [Name and version]
- **Pattern**: [Selected architecture pattern]
- **Key Decisions**: [arch-dec-0001] [One-line summary]; [arch-dec-0002] [One-line summary]
- **Known Pitfalls**: [Top 3 risks, one line each]
- **Module Registry Summary**: [N scaffolded, M designed, P pending]
- **Current Iteration**: [Iteration number or "none"]

## 8. Artifact Index (Updated after every skill)
> Quick reference to all generated artifacts.

| Artifact | Path | Last Modified | Digest |
|----------|------|---------------|--------|
| PRD | skill/artifacts/PRD.md | 2026-04-24 | 5 user stories, P0-P2 scoped |
| Decision Log | skill/artifacts/DECISION_LOG.md | 2026-04-24 | 3 major decisions recorded |
| Interface Contract | skill/artifacts/INTERFACE_CONTRACT.md | 2026-04-24 | 12 interfaces defined |
| Architecture Design | skill/artifacts/ARCHITECTURE.md | 2026-04-24 | Microservice + BFF |
| Architecture XML | skill/artifacts/architecture.xml | 2026-04-24 | 3 modules, 2 shared contracts |
| Validation Report | skill/artifacts/VALIDATION_REPORT.md | 2026-04-24 | All modules PASS |
| Validation Delta | docs/architecture/validation/VALIDATION_DELTA_20260424.md | 2026-04-24 | Initial validation |
| Design Review | skill/artifacts/DESIGN_REVIEW.md | 2026-04-24 | 2 medium risks flagged |
| Health Check Script | skill/artifacts/health-check.sh | 2026-04-24 | 5 checks implemented |
| Iteration PRD | skill/artifacts/ITERATION_PRD.md | 2026-04-24 | Scope delta for v1.1 |
| Iteration Plan | skill/artifacts/ITERATION_PRD.md | 2026-04-24 | 2 modules affected |
| Scaffolding | skill/artifacts/PROJECT_SCAFFOLD/ | 2026-04-24 | Docker + CI ready |
| RTM | skill/artifacts/RTM.md | 2026-04-24 | P0/P1 requirements mapped |
| Database Schema | skill/artifacts/schema.sql | 2026-04-24 | DDL from DataModel |
| OpenAPI Spec | skill/artifacts/openapi.yaml | 2026-04-24 | REST API contracts |
| ERD | skill/artifacts/ERD.md | 2026-04-24 | Entity relationship diagram |
| Debug Report | skill/artifacts/DEBUG_REPORT.md | 2026-04-24 | Bug diagnosis result |
| Refactor Report | skill/artifacts/REFACTOR_REPORT.md | 2026-04-24 | Code health scan result |
| System Prompt | references/system-prompt-template.md | 2026-04-29 | Global role definition + VCMF constraints |
| Context Protocol | references/context-management-protocol.md | 2026-04-29 | Layered summary + artifact loading rules |
| Validation Scripts Manifest | references/validation-scripts-manifest.md | 2026-04-29 | Script capability mapping + known gaps |

## 9. Known Pitfalls & Risks (Append-Only)
> Every skill MUST append risks discovered during its unfold.

- [YYYY-MM-DD] Risk: [description]. Mitigation: [strategy].

## 10. Error Log (Append-Only)
> Every error reported via error-tracing MUST be logged here.

```yaml
ErrorLog:
  - timestamp: "2026-04-29T10:00:00Z"
    traceId: "arch-dec-0042-ERR-001-20260429100000"
    errorCode: "ARCH-XML-001"
    status: pending          # [pending | fixed | ignored]
    location: "devforge-architecture-design → Step 5 → architecture.xml:42"
    fixCommit: ""           # Populated when status becomes fixed
  - timestamp: "2026-04-29T10:05:00Z"
    traceId: "arch-dec-0042-ERR-001-20260429100000"
    errorCode: "ARCH-XML-001"
    status: fixed
    location: "devforge-architecture-design → Step 5 → architecture.xml:42"
    fixCommit: "abc1234"
```

## 11. Intervention Log (Append-Only)
> Every human intervention via intervention-checkpoint MUST be logged here.

```yaml
InterventionLog:
  - timestamp: "2026-04-29T11:00:00Z"
    type: "ROLLBACK"         # [PAUSE | ROLLBACK | EXPLAIN | EDIT | SKIP | INJECT]
    stepId: "phase3-step5"
    reason: "架构设计走偏，需重新评估单体 vs 微服务"
    outcome: "重新评估后选择单体架构"
  - timestamp: "2026-04-29T11:30:00Z"
    type: "INJECT"
    stepId: "phase1-step4"
    reason: "补充技术约束：团队规模=2人"
    outcome: "PRD 更新为适合小团队的简化方案"
```
