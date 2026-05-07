---
name: devforge-iteration-planning
description: Use when a project has completed initial scaffolding and the user wants to add new requirements, features, or modules incrementally without rewriting the existing architecture. Trigger when user says "add new feature", "next iteration", "incremental requirement", or proposes changes after scaffolding is complete.
---

# DevForge Iteration Planning

## Overview

Given an approved architecture and a new set of requirements, produce an incremental plan that adds to the existing system without invalidating prior design decisions. The core principle is: **the existing framework stays; only additions and targeted modifications are allowed**.

This skill performs impact analysis, writes an incremental PRD, updates architecture artifacts, and produces a step-by-step iteration plan.

## VCMF Checkpoints

| Principle | Checkpoint in this Skill |
|-----------|--------------------------|
| Design as Contract | New requirements must trace to existing PRD scope or be explicitly flagged as out-of-scope escalation |
| Interface as Boundary | Any interface change must be versioned; old interfaces remain compatible or have explicit migration path |
| Reality as Baseline | Impact analysis must identify every module affected by the new requirement; no hidden dependencies |
| State as Responsibility | New or modified state entries must declare their relationship to existing state (independent, derived, or replacement) |

## When to Use

- The user has completed initial scaffolding and wants to add new functionality
- The user says "I need to add...", "next version should include...", "can we also support..."
- Do NOT use if the user wants to redesign or refactor existing architecture (use `devforge-architecture-design` instead)

## Precondition Check

Before starting, read `skill/artifacts/STATE.md` (or `docs/architecture/system/STATE.md`).
- Acceptable phases: `scaffolding_completed`, `module_design_completed`, `iteration_planning_completed`, `evolution_completed`
- If phase is earlier than `scaffolding_completed`, stop and instruct the user to complete prior phases first
- If `architecture.xml` is missing, stop — the system has no architecture baseline to increment upon

## Language Adaptation

- System instructions and constraints in this skill are in English for maximum model compliance
- User-facing gate messages, summaries, and explanations use the same language as the user's most recent input
- If the user writes in Chinese, respond in Chinese. If English, respond in English

## Workflow

1. **Load full baseline**
   - Read `PRD.md` (existing requirements baseline)
   - Read `architecture.xml` (system-level architecture baseline)
   - Read `INTERFACE_CONTRACT.md` (existing I/O contracts)
   - Read `DECISION_LOG.md` (reasoning chain to preserve)
   - Read `STATE.md` (module registry, iteration history)
   - Read all existing `module-prd.md` files (if module-level designs exist)
   - Read `DESIGN_REVIEW.md` (known issues that might interact with new requirements)
   - Collect the user's new requirement description

2. **Scope validation**
   - Compare new requirements against the **Immutable Goal** in `STATE.md`
   - If new requirements fall outside the original scope boundary, flag as **scope escalation**
     - Ask user: "This requirement is outside the original scope boundary [quote boundary]. Do you want to: [A] Expand scope boundary and continue, [B] Defer to future project, [C] Treat as separate sub-project?"
   - If within scope, proceed

3. **Impact analysis**
   - For each new requirement, analyze its impact on the existing architecture:
     - **New module required?** → Mark as "add_module"
     - **Existing module needs new capability?** → Mark as "modify_module:{module_id}"
     - **Existing module interface needs extension?** → Mark as "extend_interface:{module_id}"
     - **Cross-module interaction changes?** → Mark as "modify_coupling"
     - **State model changes?** → Mark as "modify_state"
     - **No impact?** → Mark as "no_impact" (rare)
   - Produce an **Impact Matrix**:
     ```
     | Requirement | Affected Module | Impact Type | Severity |
     ```
   - Severity levels: `breaking` (changes existing interface), `additive` (new interface only), `internal` (module-internal only)

4. **Incremental PRD**
   - Write `ITERATION_PRD.md` containing ONLY the new/modified requirements:
     - For additive requirements: new user stories with `relates_to: US-XXX` linking to original PRD
     - For modified requirements: delta description (what changes, what stays the same)
     - Acceptance criteria for each new/modified user story
     - Explicit backward compatibility requirements if severity is `breaking`
   - Do NOT copy unchanged requirements from the original PRD

5. **Incremental architecture design**
   - For each "add_module" impact:
     - Treat as a new bounded context
     - Design module interface, coupling, and state ownership
     - Append new `Module` node to `architecture.xml`
     - Generate module XML template (same rules as `devforge-architecture-design`)
   - For each "modify_module" or "extend_interface" impact:
     - Read the existing `module-architecture.xml` (or module template if not yet detailed)
     - Add new components or extend existing component interfaces
     - Update `module-interface-contract.md` with new methods
     - Update `component-spec.xml` templates for affected components
   - For each "modify_coupling" impact:
     - Update `Coupling` nodes in `architecture.xml`
     - Ensure no circular dependencies are introduced
   - For each "modify_state" impact:
     - Update `StateModel` in system XML and affected module XMLs
     - Document state migration strategy if existing state format changes

6. **XML synchronization**
   - Run `scripts/xml-sync.py --sync` (or simulate its logic) to propagate changes:
     - System-level interface changes → Module `Constraints`
     - Module-level component changes → Component `component-spec.xml` templates
     - New error codes → All relevant `ErrorCodes` and `ErrorHandling` nodes
   - Generate a **sync report** listing all files modified and changes made

7. **Interface versioning**
   - For any `breaking` severity change:
     - Increment the affected interface version (e.g., `v1.0` → `v1.1` or `v2.0`)
     - Document deprecation timeline for old interface if applicable
     - Update `INTERFACE_CONTRACT.md` with version history
   - For `additive` changes:
     - Append new methods/errors to existing interface sections
     - Mark with `[ADDED v1.1]` annotation

8. **Iteration plan generation**
   - Write `ITERATION_PLAN.md` containing:
     - Iteration goal (one sentence)
     - Scope summary (what's in, what's explicitly out)
     - Affected module checklist with required skill flows:
       ```
       | Module | Impact Type | Required Skills | Status |
       | UserService | extend_interface | design-review + scaffolding | pending |
       | PaymentService | add_module | requirement-analysis + architecture-design + ... | pending |
       ```
     - Execution order (dependencies between modules)
     - Human gate points
     - Risk summary (breaking changes, backward compatibility concerns)
     - Rollback criteria (when to abort the iteration)
     - **verification_gate**:
       ```yaml
       verification_gate:
         required: true  # If any impact type is breaking or modify_coupling
         skills_to_rerun: [architecture-validation, design-review]
         trigger_condition: "any breaking change or coupling modification"
       ```

8.5. **Post-iteration validation prompt**
   - After the iteration's scaffolding is complete, if `ITERATION_PLAN.md::verification_gate::required` is true:
     - Prompt user: "迭代实施涉及架构变更。回复 `[VALIDATE]` 重新运行架构验证，回复 `[SKIP]` 跳过（不推荐）。"
     - If user replies `[VALIDATE]`, trigger `devforge-architecture-validation`

9. **Self-validation: iteration plan consistency**
   - Before finalizing, verify iteration artifacts with automated checks:
     - **Impact matrix completeness**: Confirm every new requirement in `ITERATION_PRD.md` has a corresponding row in the Impact Matrix with non-empty Affected Module, Impact Type, and Severity
     - **No circular dependencies**: Scan updated `architecture.xml` `Coupling` nodes for circular dependencies among affected modules. If found, break the cycle before proceeding.
     - **Versioning correctness**: Verify that every `breaking` severity change has an incremented interface version in `INTERFACE_CONTRACT.md`; verify `additive` changes are annotated with `[ADDED vX.Y]`
     - **Incremental PRD purity**: Confirm `ITERATION_PRD.md` contains ONLY new or modified requirements. If any unchanged requirement is copied from the original PRD, remove it.
     - **Sync report completeness**: Verify the XML sync report lists every file that was modified during XML synchronization. If any modified file is missing from the report, add it.
     - **Backward compatibility documentation**: For every `breaking` change, confirm `ITERATION_PLAN.md` contains a backward compatibility or migration strategy
   - If any check fails, fix the iteration artifacts before proceeding

10. **State update**
   - Update `STATE.md`:
     - Append to **Completed Steps**: `[YYYY-MM-DD HH:MM] devforge-iteration-planning: Analyzed [N] new requirements. Impact: [X] modules affected. Iteration scope: [summary]`
     - Update **Current State**:
       - `phase: iteration_planning_completed`
       - `NextAction: iterate` (indicates we are in an iteration loop)
     - Update **Iteration History**: append new iteration entry with date, scope, and affected modules
     - Update **Module Registry**: add new modules with status `pending`; update affected modules' status if they change
     - Append iteration-specific risks to **Known Pitfalls**
   - Update `RTM.md`:
     - Append new requirements from iteration with Status=`pending`
     - For affected modules with breaking interface changes, downgrade existing requirement Status from `verified` to `implemented`

11. **Human gate**
    - Present iteration summary:
      - Number of new requirements
      - Impact matrix (modules affected, severity)
      - Execution order and estimated skill flow
    - Say exactly: "迭代计划已生成。本次迭代涉及 [N] 个模块，其中 [X] 个新增、[Y] 个修改。请确认当前阶段输出。回复 [APPROVE] 按迭代计划逐个模块实施。**如果本次迭代包含 breaking changes，实施后将自动触发重新验证。** 回复 [MODIFY] 调整迭代范围，回复 [REJECT] 放弃本次迭代。"
    - Do NOT proceed until [APPROVE]

## Output Specification

- `skill/artifacts/ITERATION_PRD.md` (or `docs/architecture/system/ITERATION_PRD.md`)
- `skill/artifacts/ITERATION_PLAN.md` (or `docs/architecture/system/ITERATION_PLAN.md`)
- Updated `architecture.xml` with new/modified modules, interfaces, and couplings
- Updated `INTERFACE_CONTRACT.md` with versioned interface changes
- Updated module-level XML files for affected modules
- Sync report documenting all propagated changes

## Red Flags

- Do NOT modify existing architecture decisions in `DECISION_LOG.md` (append only)
- Do NOT change the core framework pattern (e.g., microservice → monolith) in an iteration
- Do NOT skip impact analysis — every new requirement must have a traced impact
- Do NOT ignore breaking changes — they must be explicitly versioned and communicated
- Do NOT proceed without the human gate
