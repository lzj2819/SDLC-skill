# DevForge SDLC Skill Chain v1.2 Optimization Design

## Overview

This document specifies the optimization plan for the 11 issues identified in the DevForge SDLC Skill Chain v1.2. The plan adopts the **"Structured Enhancement" approach**: all 11 issues are addressed in a single coordinated update, with 1 new skill added, 7 existing skills modified, and 2 reference documents updated.

## Issues Summary

| # | Issue | Priority | Solution Location |
|---|-------|----------|-------------------|
| 1 | PRD generation needs web search capability | P1 | Extend `devforge-requirement-analysis` |
| 2 | Stage order ambiguity (5 vs 6) | P0 | Fix `devforge-module-design` precondition |
| 3 | Validation phases not continuous + no fix rollback | P0 | Extend `devforge-design-review` + `intervention-checkpoint.md` |
| 4 | Module-design linkage, tests, unified storage, subagent | P1 | Modify `devforge-module-design` |
| 5 | Incomplete testing (no test execution skill) | P1 | **New `devforge-test-execution` skill** |
| 6 | requirements.txt and .env generation | Already Done | Verified in `devforge-project-scaffolding` |
| 7 | Iteration planning document updates + skip logic + re-validation | P0 | Modify `devforge-iteration-planning` |
| 8 | Module XML detail level + cross-module interface definitions | P2 | Modify `devforge-architecture-design` + `devforge-module-design` |
| 9 | Document classification and storage | P2 | Add `docs/architecture/INDEX.md` in `devforge-project-scaffolding` |
| 10 | PRD requirement grading (P0/P1/P2) sync with documents | P2 | Modify `devforge-project-scaffolding` |
| 11 | RTM.md real-time updates | P2 | Modify multiple skills + new `devforge-test-execution` |

---

## Part 1: Overall Stage Flow (Modified DIVE Mapping)

### Core Change
Replace the ambiguous branching with a **strict serial + optional parallel verification** hybrid structure.

```
1. requirement-analysis (Design)
    ↓ [APPROVE]
2. architecture-design (Design deepen)
    ↓ [APPROVE]
    ┌──────────────────┬──────────────────┐
    ↓                  ↓                  ↓
3a. architecture-    3b. design-review   ← Both run by default
    validation          (adversarial)       User can skip one
    (technical)         inspection
    ↓ [APPROVE]         ↓ [APPROVE/FIX]
    └──────────────────┴──────────────────┘
                      ↓ [APPROVE] (Both must pass to continue)
4. project-scaffolding (Implement)
    ↓ [APPROVE]
5. module-design (Design, module-level)  ← Strictly after scaffolding
    ↓ [APPROVE / NEXT MODULE]
    (All modules design_completed → continue)
6. test-execution (Verify)  ← [NEW SKILL]
    ↓ [APPROVE]
7. iteration-planning (Evolve)  ← Triggered only by incremental requirements
    ↓ [APPROVE]  →  Back to 3a/3b for re-verification  ← Required after breaking changes
```

### Key Rules

1. **Stages 3a and 3b are no longer mutually exclusive**: The default flow is 3a → 3b. Users can input `[SKIP_REVIEW]` at the 2→3a gate to run only technical validation, or `[SKIP_VALIDATION]` at the 3a pass point to run only design review (not recommended but allowed).

2. **Stage 5 has strict post-condition**: `devforge-module-design` precondition is unified to `scaffolding_completed` (no longer accepts `architecture_design_completed`), eliminating the ambiguity of "module design first or scaffolding first."

3. **Stage 6 is a new entry**: Triggered by `[TEST]` command, or automatically suggested after all modules are designed.

4. **Stage 7 exit adds a loop**: After iteration plan approval, if the impact type contains `breaking` or `modify_coupling`, must return to 3a/3b for re-verification.

### DIVE Mapping Update

| DIVE Phase | Skills | Change |
|------------|--------|--------|
| Design | 1 + 2 + 5 | module-design strictly after scaffolding |
| Implement | 4 | No change |
| Verify | 3a + 3b + **6** | New test-execution skill added |
| Evolve | 7 | Added loop back to Verify |
| Visualize | 8 | No change |
| Operate | 9 | No change |
| Debug | 10 | No change |

---

## Part 2: Issue 1 — Web Search in PRD Generation

### Change Location
`devforge-requirement-analysis/SKILL.md`: Insert new Step 3.5 between existing Step 3 (Context gathering) and Step 4 (Cross-module interaction mapping).

### Trigger Condition
After Step 3 completes, automatically determine if web search is needed:
- The domain/product type mentioned by the user has insufficient information in training data (e.g., emerging technologies, niche industries), OR
- The user requests competitor analysis, industry standards, or compliance requirements.

### Search Scope (Strictly Limited)

| Search Purpose | Example Query | Result Usage |
|----------------|---------------|--------------|
| Industry background | `{domain} industry standards 2025`, `{domain} common user pain points` | Enrich PRD Project Background |
| Competitor reference | `{product type} competitors features comparison` | Validate user story completeness; do NOT copy features |
| Terminology standardization | `{ambiguous term} definition standard` | Fill Terminology section |
| Compliance requirements | `{domain} compliance requirements GDPR/SOC2` | Fill Non-functional Requirements |

**Forbidden searches**:
- Technology selection (databases, frameworks, cloud services) — reserved for architecture-design
- Specific code implementations — reserved for scaffolding

### Result Processing

1. Search result summary is written to `DECISION_LOG.md` (NOT directly mixed into PRD):
   ```
   [YYYY-MM-DD] [RESEARCH-{id}]: Web search on "{query}"
   - Source: {URL}
   - Key finding: {1-sentence summary}
   - Relevance to PRD: {which section}
   ```
2. PRD only cites the conclusion of the research (e.g., "According to industry reports, the target user's average DAU is X"), without retaining raw search data.
3. Search results are cached for 24h (reuses `references/search-integration.md` cache rules).

### Gate Adjustment
Step 10 human gate adds one sentence: "This PRD is based on {N} external research conclusions. Detailed references are in DECISION_LOG.md."

---

## Part 3: Issue 3 — Verification Phase Continuity + Fix Rollback Mechanism

### 3.1 Default Flow for Both Verification Phases

**Modified default flow** (no longer either/or):

```
After architecture-design completes
    ↓ [APPROVE]
architecture-validation runs first
    ↓
If validation PASS:
    → Auto-prompt: "Technical validation passed. Continue with design-review?
       Reply [DESIGN_REVIEW] for adversarial inspection,
       or [SKIP_REVIEW] to proceed directly to scaffolding."
    → If user replies [DESIGN_REVIEW]:
        design-review runs
            ↓
            Generates DESIGN_REVIEW.md (issue list)
                ↓
                User decision:
                - [APPROVE] → scaffolding
                - [FIX <issue_id>] → Enter fix sub-flow (see 3.2)
```

**If validation FAIL**:
- Existing mechanism: `[RETRY]` returns to architecture-design
- **Enhancement**: `VALIDATION_DELTA.md` marks `blocking: true/false`. If all failures are non-blocking (warning level), allow user to input `[FORCE_APPROVE]` to continue to design-review.

### 3.2 design-review FIX Sub-Flow (NEW)

Current SKILL.md has `[FIX <issue_id>]` command but no subsequent behavior defined. **New FIX sub-flow**:

**FIX Command Processing Logic**:

```
User inputs [FIX <issue_id>]
    ↓
Determine issue severity:
    ├─ Must Fix / Should Fix → Execute "Fix Mode A" (current skill directly modifies)
    └─ Nice to Fix → Execute "Fix Mode B" (mark TODO, do not block flow)
```

**Fix Mode A (Architecture/Document Modification)**:
1. design-review skill does NOT exit; enters Fix sub-mode:
   - Reads the source file pointed to by the issue (`architecture.xml`, `INTERFACE_CONTRACT.md`, or `DECISION_LOG.md`)
   - Generates a diff of the modified file based on the issue's `suggested fix`
   - Writes diff to `DESIGN_REVIEW_FIX_{issue_id}.md`
   - Asks user: "Fix scheme for issue {id} generated. Reply [APPLY] to apply and re-validate, [EDIT] to manually adjust, or [IGNORE] to accept the risk."
2. If user replies `[APPLY]`:
   - Applies diff to modify source file
   - **Automatically triggers architecture-validation to re-run** (because document has changed)
   - After validation passes, **remains in design-review phase**, letting user confirm remaining issues
3. If all Must Fix / Should Fix issues are resolved:
   - Update `DESIGN_REVIEW.md`, mark resolved issues as `resolved`
   - User can reply `[APPROVE]` to enter scaffolding

**Fix Mode B (Mark TODO)**:
- Mark issue as `deferred` in `DESIGN_REVIEW.md`
- During scaffolding phase, convert these deferred issues into `TODO` comments in code (scaffolding already supports this behavior, no change needed)

### 3.3 FIX Command Standardization in intervention-checkpoint.md

Add FIX command specification to `skill/tools/intervention-checkpoint.md`:

| Command | Behavior | Applicable Phase |
|---------|----------|------------------|
| `[FIX <issue_id>]` | Enter fix sub-mode, generate diff, trigger re-validation after applying | design-review |
| `[APPLY]` | Apply diff and continue | design-review fix sub-mode |
| `[FORCE_APPROVE]` | Skip blocking validation failure | architecture-validation |
| `[SKIP_REVIEW]` | Skip design-review | After architecture-validation passes |

### 3.4 State Flow Diagram

```
architecture-validation
    ├── PASS → Prompt [DESIGN_REVIEW] / [SKIP_REVIEW]
    │              ├── [DESIGN_REVIEW] → design-review
    │              │       ├── [APPROVE] → scaffolding
    │              │       ├── [FIX id] → Fix sub-mode
    │              │       │       ├── [APPLY] → Re-run validation
    │              │       │       │                   └── PASS → Back to design-review
    │              │       │       └── [IGNORE] → Back to design-review
    │              │       └── [PAUSE] / [ROLLBACK]
    │              └── [SKIP_REVIEW] → scaffolding
    └── FAIL → [RETRY] → architecture-design
             → [FORCE_APPROVE] → design-review (if all non-blocking)
```

---

## Part 4: Issue 5 — New `devforge-test-execution` Skill

### Positioning
Fills the gap of "test code has been generated but no one executes validation." It does NOT generate tests (scaffolding/module-design already does that), but **executes tests, analyzes results, and generates test reports**.

### Trigger Conditions
- User inputs `[TEST]`
- Or after all modules are design_completed, system prompts: "All module designs complete. Run test validation? Reply `[TEST]` to execute."
- Or after iteration-planning implementation completes (as a verification step)

### Precondition
`STATE.md` phase is `module_design_completed` or `scaffolding_completed`. Code and test files must exist.

### Workflow (8 Steps)

**Step 1: Test Checklist Load**
- Read `RTM.md`, extract all rows with non-empty `Test Case ID`
- Group by module, identify requirements with missing test coverage (P0/P1 requirements with Status ≠ tested/verified)
- Output: `TEST_COVERAGE_GAP.md` (list of missing coverage)

**Step 2: Test Environment Preparation**
- Check if `.env` exists (needed for real tests with API keys)
- If no `.env`, generate test run configuration using mock mode
- Run `pip install -r requirements.txt` (or corresponding language dependency installation)

**Step 3: Unit Test Execution**
- Run all tests in `tests/mock/` directory
- Collect coverage report (pytest-cov / jest / jacoco)
- If coverage < 80%, mark as `coverage_failure`

**Step 4: Integration Test Execution**
- Run `tests/real/` (tests with `skipif`)
- Statistics: skipped vs passed vs failed
- If API key exists, run real-LLM tests; otherwise mark as `skipped` and record

**Step 5: End-to-End Test Execution (Based on PRD)**
Core innovation of this skill:
- Read `PRD.md` User Stories, generate an end-to-end test script for each P0 story (if not generated during scaffolding)
- End-to-end tests MUST include PRD reference in file header:
  ```python
  # E2E Test: US-001 — User Login Flow
  # Source: PRD.md::User Stories::US-001
  # Acceptance Criteria: AC-1.1, AC-1.2
  ```
- Run all `tests/end_to_end/` tests
- Map each failure back to PRD requirement ID

**Step 6: Test Report Generation**
- Output `TEST_REPORT.md`, containing:
  - Summary: unit test pass rate / integration test pass rate / end-to-end test pass rate
  - Coverage trend (compared to last test run)
  - Failure details: test name → failure reason → associated PRD requirement → suggested fix direction
  - Missing coverage: P0/P1 requirements without Test Case ID

**Step 7: RTM Synchronization**
- Update Status to `tested` for requirements corresponding to passed tests
- Keep Status as `implemented` for failed test requirements (do not downgrade to pending)
- Update `RTM.md` Test Case ID and Status columns

**Step 8: Gate**
> "Test report generated. Unit test pass rate X%, integration Y%, end-to-end Z%. Reply `[APPROVE]` to mark test phase complete, `[DEBUG]` to enter debug mode for failures, or `[RETEST]` to re-run."

### Output Files
- `docs/architecture/validation/TEST_REPORT.md`
- `docs/architecture/validation/TEST_COVERAGE_GAP.md`
- Updated `RTM.md`

### Relationship with debug-assistant

| | test-execution | debug-assistant |
|--|---------------|-----------------|
| Input | Test code + PRD | Failed test output + logs |
| Output | Test report + coverage | Diagnosis report + fix proposal |
| Relationship | Predecessor: execute first, discover issues | Successor: then diagnose, fix issues |
| Trigger | `[TEST]` | `[DEBUG]` |

**After test-execution discovers failures, user can directly reply `[DEBUG]` to enter debug-assistant for diagnosis.**

**Transition Rule**: If `TEST_REPORT.md` contains any failed test, the test-execution gate MUST offer `[DEBUG]` as an option. The debug-assistant precondition accepts `test_execution_completed` as an acceptable phase, and its Mode A (Bug Diagnosis) auto-loads `TEST_REPORT.md` as primary evidence.

---

## Part 5: Issues 2/4/7 — Stage Linkage, Module Design Enhancement, Iteration Verification Loop

### 5.1 Stage Order Clarification (Issue 2)

**Changes**:
- `devforge-module-design/SKILL.md` precondition changed from `architecture_design_completed or later` to strictly `scaffolding_completed`
- `devforge-project-scaffolding/SKILL.md` gate text changed from "Reply `[APPROVE]` to complete full workflow" to:
  > "Project scaffolding generated. Reply `[APPROVE]` to enter module detailed design phase, or provide modification feedback."

**Benefits of module-design after scaffolding**:
- Scaffolding has already generated system-level directory structure and interface stubs; module-design only needs to fill internal implementations
- module-design can directly write `component-spec.xml` into scaffolding-generated directories (no copy needed later)
- Test code can be directly written to `tests/mock/` and `tests/end_to_end/` (directories already exist)

### 5.2 Module-Design Test Code Generation (Issue 4b)

Current module-design Step 7 only generates "test case design" (documentation). **Enhanced to simultaneously generate runnable test code**:

**New Step 7.5: Test Code Generation**
- Read scaffolding-generated `tests/` directory structure
- Generate corresponding test files for each component:
  - `tests/mock/{module_id}/{component_id}_test.py` (or corresponding language)
  - Test function names map to module-prd.md Test Case IDs
  - Each test function header comment:
    ```python
    # Test: TC-{module_id}-{component_id}-001
    # Source: module-prd.md::Test Case Catalog::TC-001
    # Component: component-spec.xml::AuthController
    ```
- If `tests/end_to_end/` lacks module-related end-to-end tests, generate a basic version

**Unified Output Paths**:
- All module-design outputs are directly written to `PROJECT_SCAFFOLD/` corresponding locations:
  - `PROJECT_SCAFFOLD/modules/{module_id}/module-prd.md`
  - `PROJECT_SCAFFOLD/modules/{module_id}/module-architecture.xml`
  - `PROJECT_SCAFFOLD/modules/{module_id}/module-interface-contract.md`
  - `PROJECT_SCAFFOLD/modules/{module_id}/components/{component_id}/component-spec.xml`
  - `PROJECT_SCAFFOLD/tests/mock/{module_id}/...`

### 5.3 Module-Design Subagent Parallel Mode (Issue 4d)

**New parallel mode trigger**: User inputs `[MODULE_BATCH {id1},{id2},...]`

**Execution Logic**:
1. Main agent reads system-level architecture, analyzes inter-module coupling relationships
2. If no circular dependencies between modules, construct an independent subagent prompt per module (parent context + scoped 11-step workflow) and dispatch all subagents in parallel using the native `Agent` tool
3. Each subagent independently executes module-design's 11 steps (one module each) and writes outputs to `PROJECT_SCAFFOLD/modules/{id}/`
4. After all subagents complete, main agent collects results and performs consistency checks:
   - Cross-module interface consistency
   - Shared StateModel definition conflicts
5. If conflicts exist, enter coordination mode (fix sequentially)

**Fallback**: If parallel `Agent` dispatch is unavailable (platform limitation or single-agent mode), fall back to serial `[MODULE {id}]` → `[NEXT MODULE]`.

### 5.4 Iteration Planning Verification Loop (Issue 7c)

**Modify `devforge-iteration-planning/SKILL.md`**:

**Workflow Step 8 Enhancement**:
After generating `ITERATION_PLAN.md`, add `verification_requirements` field:

```yaml
# ITERATION_PLAN.md new field
verification_gate:
  required: true  # If impact type contains breaking or modify_coupling
  skills_to_rerun: [architecture-validation, design-review]
  trigger_condition: "any breaking change or coupling modification"
```

**Gate Text Enhancement**:
> "Iteration plan generated... Reply `[APPROVE]` to implement according to plan. **If this iteration contains breaking changes, re-validation will be automatically triggered after implementation.** Reply `[MODIFY]` to adjust scope, or `[REJECT]` to abandon."

**Post-Implementation Flow**:
- After scaffolding in iteration completes, if `ITERATION_PLAN.md::verification_gate::required` is true:
  - Auto-prompt user: "Iteration implementation involves architecture changes. Reply `[VALIDATE]` to re-run architecture validation, or `[SKIP]` to skip (not recommended)."
  - If user replies `[VALIDATE]`, return to Stage 3a (architecture-validation)

### 5.5 Document Unified Storage (Issue 4c)

**Unified Rule**:
- `skill/artifacts/` is only a **temporary workspace** (during skill execution)
- **Final authoritative location** for all architecture documents is `PROJECT_SCAFFOLD/docs/architecture/`
- Each skill's State update step explicitly states: "Copy generated documents from `skill/artifacts/` to corresponding locations in `docs/architecture/`"

---

## Part 6: Issues 8/9/10/11 — Remaining Enhancements

### 6.1 Module XML Document and Cross-Module Interface Compatibility (Issue 8)

**Scaffolding Stage Template Enhancement**:
- Stage 2 (architecture-design) generated `module-architecture.xml` template, in addition to `Constraints`, pre-fills `ModuleStateModel` skeleton (only fills `id` and `location=system`, leaves `owner` and `lifecycle` empty)
- This allows scaffolding stage to reference complete path structure

**module-design self-validation Enhancement (New Check Item)**:
Add a 7th item to existing 6 checks:
- **Cross-module interface compatibility**: Verify that the current module's system-level output interface schema is compatible with all downstream modules' system-level input interface schemas
- Implementation: Read current module's `Coupling/DependsOn` targets in `architecture.xml`, compare `Output` and `Input` schema definitions
- If incompatible, mark as `interface_mismatch`, preventing the module from being marked `design_completed`

### 6.2 Document Classification Storage (Issue 9)

Current status is already good; only minor adjustments needed:
- All XML documents are already stored by level: `system/`, `modules/{id}/`, `modules/{id}/components/{cid}/`
- Only missing: **unified index**

**New `docs/architecture/INDEX.md`**:
- Generated by `devforge-project-scaffolding` with system-level entries pre-filled
- Appended by `devforge-module-design` after each module design completion (adds module row)
- Appended by `devforge-iteration-planning` when new modules are added

```markdown
# Architecture Document Index

## System Level
- [System Architecture](system/architecture.xml)
- [Interface Contract](system/INTERFACE_CONTRACT.md)
- [State Model](system/STATE.md)

## Modules
| Module | PRD | XML | Interface Contract | Components |
|--------|-----|-----|-------------------|------------|
| UserService | [module-prd](modules/UserService/module-prd.md) | [xml](modules/UserService/module-architecture.xml) | [contract](modules/UserService/module-interface-contract.md) | AuthController, UserRepository... |

## Generated
- [Validation Reports](validation/)
- [Diagrams](diagrams/)
```

### 6.3 PRD Requirement Grading and Document Sync (Issue 10)

**P0/P1/P2 Placeholder Strategy**:

**Scaffolding Stage Code Generation Rules**:
- **P0 modules**: Generate complete business logic skeleton (function body has minimal implementation, not empty)
- **P1 modules**: Generate complete interface stubs + TODO comments (function body is `raise NotImplementedError("P1: implement per module-prd")`)
- **P2 modules**: Only generate directory structure and empty files (files exist but only contain module header comments)

**Header Comment Template**:
```python
# Module: {module_id}
# Priority: {P0/P1/P2}
# PRD Reference: PRD.md::Functional Requirements::{req_id}
# Status: {placeholder/minimal-implemented/full-implemented}
# TODO: P1 implementation scheduled for iteration {N}
```

**Architecture Document Strategy**:
- architecture-design stage **must cover all modules** (including P2), because module coupling and interfaces need to be determined during system design
- But module-design stage can be **on-demand**: design P0 modules first, defer P1/P2 modules to corresponding iterations

### 6.4 RTM.md Real-Time Updates (Issue 11)

**Current Mechanism**: Each skill updates RTM at the end. **Enhanced to more frequent update points**:

| Update Trigger | Update Content | Responsible Skill |
|---------------|----------------|-------------------|
| PRD generation | Add all requirement rows, Status=pending | requirement-analysis |
| Architecture design | Fill Architecture Module column | architecture-design |
| Module design | Fill Component column | module-design |
| Scaffolding | Fill Test Case ID column | project-scaffolding |
| **Test execution** | **Update Status: implemented → tested** | **test-execution (NEW)** |
| Architecture validation | Update Status: tested → verified | architecture-validation |

**iteration-planning RTM Update**:
- In iteration-planning Step 10 (State update), add:
  - Append iteration-added requirements to RTM (Status=pending)
  - Update existing requirement rows of affected modules (if interface changes, downgrade Status from verified to implemented)

---

## Implementation Scope Summary

### Files to Modify

| File | Changes |
|------|---------|
| `devforge-requirement-analysis/SKILL.md` | Add Step 3.5 Web Research |
| `devforge-architecture-design/SKILL.md` | Enhance module XML template with StateModel skeleton |
| `devforge-architecture-validation/SKILL.md` | Add `[FORCE_APPROVE]` gate option |
| `devforge-design-review/SKILL.md` | Add FIX sub-flow with diff generation and re-validation trigger |
| `devforge-project-scaffolding/SKILL.md` | Update gate text, add INDEX.md generation, add P0/P1/P2 placeholder rules |
| `devforge-module-design/SKILL.md` | Change precondition to scaffolding_completed, add test code generation (Step 7.5), add subagent batch mode, add cross-module compatibility check |
| `devforge-iteration-planning/SKILL.md` | Add verification_gate to ITERATION_PLAN.md, add RTM update, add post-iteration validation prompt |
| `skill/tools/intervention-checkpoint.md` | Add FIX/APPLY/FORCE_APPROVE/SKIP_REVIEW command specs |

### New Files to Create

| File | Description |
|------|-------------|
| `devforge-test-execution/SKILL.md` | New skill with 8-step workflow |

### No-Change Files (Already Satisfied)

| File | Reason |
|------|--------|
| `devforge-project-scaffolding/SKILL.md` (requirements.txt/.env) | Already generates dependency configs and `.env.template` (Issue 6) |

---

## Design Document Version

- **Version**: 1.0
- **Date**: 2026-05-07
- **Author**: Claude Code
- **Status**: Pending user review
