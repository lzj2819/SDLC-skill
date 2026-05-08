# DevForge SDLC v1.2 Optimization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Address all 11 identified issues in the DevForge SDLC Skill Chain v1.2 by modifying 7 existing skills, creating 1 new skill, and updating 1 reference document.

**Architecture:** Skill chain stage order is clarified (module-design strictly after scaffolding); a new test-execution skill fills the verification gap; FIX rollback mechanisms close the validation loop; web search enriches PRD generation.

**Tech Stack:** Markdown skill definitions (YAML frontmatter), shell validation scripts (`scripts/package-plugin.py`, `scripts/architecture-ci.sh`)

---

## File Structure

### Files to Create
| File | Responsibility |
|------|---------------|
| `devforge-test-execution/SKILL.md` | New skill: execute tests, generate reports, sync RTM |

### Files to Modify
| File | Responsibility | Key Changes |
|------|---------------|-------------|
| `skill/tools/intervention-checkpoint.md` | Human gate command definitions | Add FIX/APPLY/FORCE_APPROVE/SKIP_REVIEW specs |
| `devforge-requirement-analysis/SKILL.md` | PRD generation | Add Step 3.5 Web Research |
| `devforge-architecture-design/SKILL.md` | System architecture | Add StateModel skeleton to module XML templates |
| `devforge-architecture-validation/SKILL.md` | Technical validation | Add `[FORCE_APPROVE]` gate for non-blocking failures |
| `devforge-design-review/SKILL.md` | Adversarial inspection | Add FIX sub-flow with diff + re-validation |
| `devforge-project-scaffolding/SKILL.md` | Code generation | Update gate text, add INDEX.md generation, P0/P1/P2 placeholders |
| `devforge-module-design/SKILL.md` | Module deep-dive | Change precondition, add test code gen, subagent batch mode, cross-module check |
| `devforge-iteration-planning/SKILL.md` | Incremental planning | Add verification_gate, RTM updates, post-iteration validation prompt |

### Validation Method
- After each SKILL.md modification: `python scripts/package-plugin.py --mode all --output ./dist`
- Expected: No frontmatter errors, all skills packaged successfully

---

### Task 1: Update intervention-checkpoint.md with FIX Command Specifications

**Files:**
- Modify: `skill/tools/intervention-checkpoint.md`

- [ ] **Step 1: Read current intervention-checkpoint.md**

Read the file to locate the existing command table.

- [ ] **Step 2: Add new command rows**

After the existing command table, add the following section:

```markdown
## Extended Commands (v1.2)

| Command | Behavior | Applicable Stage | Preconditions |
|---------|----------|------------------|---------------|
| `[FIX <issue_id>]` | Enter fix sub-mode: reads source file, generates diff, asks for apply/edit/ignore | design-review | DESIGN_REVIEW.md exists with matching issue_id |
| `[APPLY]` | Apply the generated diff and trigger re-validation | design-review fix sub-mode | diff file exists and is valid |
| `[FORCE_APPROVE]` | Skip blocking validation failures and proceed to design-review | architecture-validation | All failures are non-blocking (warning level) |
| `[SKIP_REVIEW]` | Skip design-review and proceed directly to scaffolding | architecture-validation | Validation has passed |
| `[DESIGN_REVIEW]` | Trigger design-review after validation passes | architecture-validation | Validation has passed |
| `[VALIDATE]` | Re-run architecture-validation after iteration implementation | iteration-planning | Iteration contains breaking changes |
| `[TEST]` | Trigger test-execution skill | Any post-scaffolding stage | Tests exist in PROJECT_SCAFFOLD/tests/ |
```

- [ ] **Step 3: Run frontmatter validation**

```bash
python scripts/package-plugin.py --mode all --output ./dist
```

Expected: No errors. All skills packaged.

- [ ] **Step 4: Commit**

```bash
git add skill/tools/intervention-checkpoint.md
git commit -m "feat: extend intervention commands with FIX, FORCE_APPROVE, SKIP_REVIEW, DESIGN_REVIEW, VALIDATE, TEST"
```

---

### Task 2: Add Web Research Step to requirement-analysis

**Files:**
- Modify: `devforge-requirement-analysis/SKILL.md`

- [ ] **Step 1: Read the workflow section**

Locate lines 46-107 (Workflow steps 1-10).

- [ ] **Step 2: Insert Step 3.5 between Step 3 and Step 4**

Replace the transition from Step 3 to Step 4. After Step 3 (Context gathering), add:

```markdown
3.5. **Web Research (conditional)**
   - After Step 3 completes, determine if web search is needed:
     - Search IF: the user's domain/product type has insufficient information in training data (emerging tech, niche industries), OR user requests competitor analysis, industry standards, or compliance requirements
   - **Search scope** (strictly limited):
     - Industry background: `{domain} industry standards 2025`, `{domain} common user pain points`
     - Competitor reference: `{product type} competitors features comparison`
     - Terminology standardization: `{ambiguous term} definition standard`
     - Compliance requirements: `{domain} compliance requirements GDPR/SOC2`
   - **Forbidden searches**: Technology selection (databases, frameworks, cloud services), specific code implementations
   - **Result processing**:
     - Write search result summary to `DECISION_LOG.md`:
       ```
       [YYYY-MM-DD] [RESEARCH-{id}]: Web search on "{query}"
       - Source: {URL}
       - Key finding: {1-sentence summary}
       - Relevance to PRD: {which section}
       ```
     - PRD only cites conclusions, not raw data
     - Cache results for 24h (reuse `references/search-integration.md` cache rules)
```

And update the original Step 4 to become Step 4 (renumbered from original Step 4).

- [ ] **Step 3: Update gate text**

In Step 10 (Human gate), change the presentation line from:

"PRD 和决策日志已生成。请确认当前阶段输出。回复 [APPROVE] 进入架构设计阶段，或提出修改意见。"

To:

"PRD 和决策日志已生成。本次 PRD 基于 {N} 条外部研究结论，详细引用见 DECISION_LOG.md。请确认当前阶段输出。回复 [APPROVE] 进入架构设计阶段，或提出修改意见。"

- [ ] **Step 4: Update Output Specification**

Add to Output Specification section:
```markdown
- Search result references in `DECISION_LOG.md` (if web research was performed)
```

- [ ] **Step 5: Validate frontmatter**

```bash
python scripts/package-plugin.py --mode all --output ./dist
```

Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add devforge-requirement-analysis/SKILL.md
git commit -m "feat(requirement-analysis): add web research step (3.5) for industry/competitor/compliance search"
```

---

### Task 3: Enhance architecture-design module XML template

**Files:**
- Modify: `devforge-architecture-design/SKILL.md`

- [ ] **Step 1: Locate Step 10**

Find the step that auto-generates `module-architecture.xml` templates.

- [ ] **Step 2: Add StateModel skeleton to template generation**

In Step 10, enhance the template generation instruction. After generating `Constraints/InterfaceConstraint`, add:

```markdown
   - For each `Module`, pre-fill `module-architecture.xml` template with:
     - `Constraints/InterfaceConstraint`: Copy system-level Input/Output schemas
     - `ModuleStateModel` skeleton: For each stateful entity mentioned in the module's `Responsibility`, add a `State` entry with:
       - `id`, `location=system`, `owner` (empty, to be filled by module-design), `lifecycle` (empty, to be filled)
```

- [ ] **Step 3: Validate frontmatter**

```bash
python scripts/package-plugin.py --mode all --output ./dist
```

Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add devforge-architecture-design/SKILL.md
git commit -m "feat(architecture-design): add ModuleStateModel skeleton to module XML templates"
```

---

### Task 4: Add FORCE_APPROVE to architecture-validation

**Files:**
- Modify: `devforge-architecture-validation/SKILL.md`

- [ ] **Step 1: Locate the self-healing loop (Step 8)**

Find the section describing what happens when validation fails.

- [ ] **Step 2: Add non-blocking failure handling**

Replace the existing failure handling in Step 8:

```markdown
8. **Self-healing loop**
   - Classify each failure as `blocking` (would cause system failure) or `non-blocking` (warning/observation)
   - If any `blocking` validation fails:
     - Document the failure in the report
     - Tell the user: "架构校验未通过，存在阻塞性问题。请回复 [RETRY] 退回架构设计阶段修改 XML，或提出修改意见。"
     - Do NOT proceed to scaffolding
   - If all failures are `non-blocking`:
     - Tell the user: "架构校验发现 {N} 个非阻塞性警告。回复 [FORCE_APPROVE] 跳过警告继续到设计审查阶段，或回复 [RETRY] 修改。"
   - If all pass:
     - Write `skill/artifacts/VALIDATION_REPORT.md`...
```

- [ ] **Step 3: Update gate text**

In Step 12 (Human gate), change from:

"架构验证报告和健康检查脚本已生成。请确认当前阶段输出。回复 [APPROVE] 进入项目脚手架阶段，或提出修改意见。"

To:

"架构验证报告和健康检查脚本已生成。请确认当前阶段输出。回复 [APPROVE] 进入设计审查阶段（推荐），回复 [SKIP_REVIEW] 跳过审查直接进入项目脚手架阶段，或提出修改意见。"

- [ ] **Step 4: Update Output Specification**

Add:
```markdown
- `VALIDATION_REPORT.md` must mark each failure as `blocking: true/false`
```

- [ ] **Step 5: Validate frontmatter**

```bash
python scripts/package-plugin.py --mode all --output ./dist
```

Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add devforge-architecture-validation/SKILL.md
git commit -m "feat(architecture-validation): add FORCE_APPROVE for non-blocking failures, SKIP_REVIEW option"
```

---

### Task 5: Add FIX sub-flow to design-review (Part 1 - Workflow)

**Files:**
- Modify: `devforge-design-review/SKILL.md`

- [ ] **Step 1: Add FIX sub-flow section after existing Workflow**

After the existing Workflow section (after Step 9 Human gate), add:

```markdown
## FIX Sub-Flow

When the user replies `[FIX <issue_id>]` at the human gate:

1. **Lookup issue**: Read `DESIGN_REVIEW.md`, locate the issue by ID. If not found, ask user to re-enter.
2. **Classify severity**: Check issue severity:
   - `Must Fix` / `Should Fix` → Fix Mode A
   - `Nice to Fix` → Fix Mode B
3. **Fix Mode A** (Architecture/document modification):
   - Read the source file pointed to by the issue (`architecture.xml`, `INTERFACE_CONTRACT.md`, or `DECISION_LOG.md`)
   - Generate a diff based on the issue's `suggested fix`
   - Write diff to `DESIGN_REVIEW_FIX_{issue_id}.md`
   - Ask user: "已生成 issue {id} 的修复方案。回复 [APPLY] 应用修改并重新验证，回复 [EDIT] 手动调整，回复 [IGNORE] 接受风险。"
   - If `[APPLY]`:
     - Apply diff to source file
     - **Automatically trigger architecture-validation re-run** (because document changed)
     - After validation passes, **return to design-review**, letting user confirm remaining issues
   - If `[EDIT]`:
     - Present the diff and allow user to provide corrections
     - Re-generate diff and ask again
   - If `[IGNORE]`:
     - Mark issue as `ignored` in `DESIGN_REVIEW.md`
     - Return to design-review gate
4. **Fix Mode B** (Mark TODO):
   - Mark issue as `deferred` in `DESIGN_REVIEW.md`
   - During scaffolding, these deferred issues become inline `TODO` comments in code
   - Return to design-review gate
5. **Completion check**: After each fix, check if all `Must Fix` / `Should Fix` issues are resolved. If yes, update `DESIGN_REVIEW.md` to mark them `resolved` and allow `[APPROVE]`.
```

- [ ] **Step 2: Update gate text**

Change Step 9 gate text from:

"设计审查报告已生成。这不是'通过/不通过'的检查，而是一份问题清单。请审阅上述问题，决定哪些需要修复、哪些可以接受。回复 [APPROVE] 进入项目脚手架阶段，回复 [FIX <issue_id>] 要求修复特定问题，或提出修改意见。"

To:

"设计审查报告已生成。这不是'通过/不通过'的检查，而是一份问题清单。请审阅上述问题，决定哪些需要修复、哪些可以接受。回复 [APPROVE] 进入项目脚手架阶段，回复 [FIX <issue_id>] 进入修复模式，回复 [PAUSE] 暂停，或提出修改意见。"

- [ ] **Step 3: Update Output Specification**

Add:
```markdown
- `DESIGN_REVIEW_FIX_{issue_id}.md` (generated during FIX sub-flow)
- Issues marked `resolved`, `deferred`, or `ignored` in `DESIGN_REVIEW.md`
```

- [ ] **Step 4: Validate frontmatter**

```bash
python scripts/package-plugin.py --mode all --output ./dist
```

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add devforge-design-review/SKILL.md
git commit -m "feat(design-review): add FIX sub-flow with diff generation and auto re-validation"
```

---

### Task 6: Update scaffolding gate, INDEX.md, and P0/P1/P2 placeholders

**Files:**
- Modify: `devforge-project-scaffolding/SKILL.md`

- [ ] **Step 1: Update gate text**

Change Step 17 gate text from:

"项目脚手架已生成，包含工程目录、CI/CD 配置、测试脚本、文档同步规则和环境变量模板。请确认当前阶段输出。回复 [APPROVE] 完成全流程，或提出修改意见。"

To:

"项目脚手架已生成，包含工程目录、CI/CD 配置、测试脚本、文档同步规则和环境变量模板。请确认当前阶段输出。回复 [APPROVE] 进入模块详细设计阶段，或提出修改意见。"

- [ ] **Step 2: Add INDEX.md generation**

In Step 3 (Directory tree and dependencies), after generating `.gitattributes`, add:

```markdown
   - Generate `docs/architecture/INDEX.md` with:
     - System-level artifact links
     - Module table (Module | PRD | XML | Interface Contract | Components) — initially empty module rows, to be filled by module-design
     - Generated artifact links (validation reports, diagrams)
```

- [ ] **Step 3: Add P0/P1/P2 placeholder rules**

In Step 4 (Core code skeleton), add after "Leave business logic as well-documented placeholders or minimal implementations":

```markdown
   - **P0/P1/P2 code generation rules**:
     - **P0 modules**: Generate complete business logic skeleton with minimal working implementation (not empty placeholders)
     - **P1 modules**: Generate complete interface stubs with TODO comments. Function body: `raise NotImplementedError("P1: implement per module-prd")` (or language equivalent)
     - **P2 modules**: Generate directory structure and empty files with module header comments only
   - **Module header comment template** (add to every generated module file):
     ```python
     # Module: {module_id}
     # Priority: {P0/P1/P2}
     # PRD Reference: PRD.md::Functional Requirements::{req_id}
     # Status: {placeholder/minimal-implemented/full-implemented}
     # Architecture Decision: {DecisionTrace ID}
     # Known Risk: {DESIGN_REVIEW issue IDs if applicable}
     ```
```

- [ ] **Step 4: Update State update to include INDEX.md**

In Step 16 (State update), add:
```markdown
   - Update `docs/architecture/INDEX.md` with generated artifact links
```

- [ ] **Step 5: Validate frontmatter**

```bash
python scripts/package-plugin.py --mode all --output ./dist
```

Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add devforge-project-scaffolding/SKILL.md
git commit -m "feat(scaffolding): update gate text, add INDEX.md generation, P0/P1/P2 placeholder rules"
```

---

### Task 7: Update module-design precondition and add test code generation

**Files:**
- Modify: `devforge-module-design/SKILL.md`

- [ ] **Step 1: Change precondition**

Change the precondition from:
```markdown
- Acceptable phases: `architecture_design_completed`, `architecture_validated`, `design_review_completed`, `scaffolding_completed`, `module_design_completed`
```

To:
```markdown
- Acceptable phases: `scaffolding_completed`, `module_design_completed`
```

And change the early-stop instruction from:
```markdown
- If phase is earlier than `architecture_design_completed`, stop and instruct the user to complete `devforge-architecture-design` first
```

To:
```markdown
- If phase is earlier than `scaffolding_completed`, stop and instruct the user to complete `devforge-project-scaffolding` first
```

- [ ] **Step 2: Add Step 7.5 (Test Code Generation)**

After Step 7 (Module-level test case design), add:

```markdown
7.5. **Test code generation**
   - Read the `tests/` directory structure generated by scaffolding
   - For each component, generate test files:
     - `tests/mock/{module_id}/{component_id}_test.py` (or language equivalent)
     - Test function names map to module-prd.md Test Case IDs
     - Each test function header:
       ```python
       # Test: TC-{module_id}-{component_id}-001
       # Source: module-prd.md::Test Case Catalog::TC-001
       # Component: component-spec.xml::{component_id}
       ```
   - If `tests/end_to_end/` lacks module-related end-to-end tests, generate a basic version with PRD user story reference
   - Write all test files to `PROJECT_SCAFFOLD/tests/...`
```

- [ ] **Step 3: Update output paths**

Change Output Specification from:
```markdown
- `skill/artifacts/modules/{module_id}/module-prd.md`
- `skill/artifacts/modules/{module_id}/module-architecture.xml`
- `skill/artifacts/modules/{module_id}/module-interface-contract.md`
- `skill/artifacts/modules/{module_id}/components/{component_id}/component-spec.xml`
```

To:
```markdown
- `PROJECT_SCAFFOLD/modules/{module_id}/module-prd.md`
- `PROJECT_SCAFFOLD/modules/{module_id}/module-architecture.xml`
- `PROJECT_SCAFFOLD/modules/{module_id}/module-interface-contract.md`
- `PROJECT_SCAFFOLD/modules/{module_id}/components/{component_id}/component-spec.xml`
- `PROJECT_SCAFFOLD/tests/mock/{module_id}/{component_id}_test.*`
```

- [ ] **Step 4: Validate frontmatter**

```bash
python scripts/package-plugin.py --mode all --output ./dist
```

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add devforge-module-design/SKILL.md
git commit -m "feat(module-design): change precondition to scaffolding_completed, add test code generation (step 7.5), update output paths"
```

---

### Task 8: Add subagent batch mode and cross-module compatibility check to module-design

**Files:**
- Modify: `devforge-module-design/SKILL.md`

- [ ] **Step 1: Add batch mode trigger**

In "When to Use" section, add:
```markdown
- The user types `[MODULE_BATCH {id1},{id2},...]` to design multiple modules in parallel
```

- [ ] **Step 2: Add batch mode execution logic**

Add new section after "Workflow":

```markdown
## Parallel Batch Mode

When triggered by `[MODULE_BATCH {id1},{id2},...]`:

1. **Coupling analysis**: Read `architecture.xml`, analyze inter-module `Coupling` relationships. If circular dependencies exist between requested modules, fall back to serial mode and warn user.
2. **Parallel dispatch**: If no circular dependencies, construct an independent subagent prompt per module (containing parent context + scoped 11-step workflow) and dispatch all subagents in parallel using the native `Agent` tool. Each subagent executes the 11-step workflow for one module independently and writes outputs to `PROJECT_SCAFFOLD/modules/{id}/`.
3. **Consistency check** (after all subagents complete):
   - Cross-module interface compatibility: Verify each module's system-level output matches downstream module's system-level input schema
   - Shared StateModel conflicts: Flag any state entries with same `id` but different definitions across modules
4. **Conflict resolution**: If conflicts found, enter coordination mode — present conflicts to user and fix sequentially.
5. **Result collection**: After all subagents complete, read all generated `module-architecture.xml`, `module-interface-contract.md`, and `component-spec.xml` files. Verify each module's output files exist and are non-empty.
6. **Human gate (batch)**: Present batch summary with each module's component count and status. List all available commands (`[APPROVE]`, `[NEXT MODULE]`, `[PAUSE]`, `[ROLLBACK]`, `[EDIT]`, `[INJECT]`, `[MODULE {id}]`).
7. **Fallback**: If parallel `Agent` dispatch is unavailable (platform limitation or single-agent mode), fall back to serial `[MODULE {id}]` → `[NEXT MODULE]`.
```

- [ ] **Step 3: Add cross-module compatibility to self-validation**

In Step 9 (Self-validation), add as check item 7:
```markdown
   - **Cross-module interface compatibility**: Verify every system-level output interface schema in the current module matches the corresponding input schema of all downstream modules (per `Coupling/DependsOn` in `architecture.xml`). Flag any `interface_mismatch` and prevent marking `design_completed` until resolved.
```

- [ ] **Step 4: Update State update for INDEX.md**

In Step 10 (State update), add:
```markdown
   - Update `docs/architecture/INDEX.md`: append module row with links to generated artifacts
```

- [ ] **Step 5: Validate frontmatter**

```bash
python scripts/package-plugin.py --mode all --output ./dist
```

Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add devforge-module-design/SKILL.md
git commit -m "feat(module-design): add subagent batch mode, cross-module interface compatibility check, INDEX.md updates"
```

---

### Task 9: Add verification_gate and RTM updates to iteration-planning

**Files:**
- Modify: `devforge-iteration-planning/SKILL.md`

- [ ] **Step 1: Add verification_gate to ITERATION_PLAN.md**

In Step 8 (Iteration plan generation), enhance `ITERATION_PLAN.md` output:

```markdown
   - Write `ITERATION_PLAN.md` containing:
     - Iteration goal (one sentence)
     - Scope summary
     - Affected module checklist with required skill flows
     - Execution order
     - Human gate points
     - Risk summary
     - Rollback criteria
     - **verification_gate** (new):
       ```yaml
       verification_gate:
         required: true  # If any impact type is breaking or modify_coupling
         skills_to_rerun: [architecture-validation, design-review]
         trigger_condition: "any breaking change or coupling modification"
       ```
```

- [ ] **Step 2: Update gate text**

Change Step 11 gate text from:

"迭代计划已生成。本次迭代涉及 [N] 个模块，其中 [X] 个新增、[Y] 个修改。请确认当前阶段输出。回复 [APPROVE] 按迭代计划逐个模块实施，回复 [MODIFY] 调整迭代范围，回复 [REJECT] 放弃本次迭代。"

To:

"迭代计划已生成。本次迭代涉及 [N] 个模块，其中 [X] 个新增、[Y] 个修改。请确认当前阶段输出。回复 [APPROVE] 按迭代计划逐个模块实施。**如果本次迭代包含 breaking changes，实施后将自动触发重新验证。** 回复 [MODIFY] 调整迭代范围，回复 [REJECT] 放弃本次迭代。"

- [ ] **Step 3: Add post-iteration validation to workflow**

Add new step after Step 8:

```markdown
8.5. **Post-iteration validation prompt**
   - After the iteration's scaffolding is complete, if `ITERATION_PLAN.md::verification_gate::required` is true:
     - Prompt user: "迭代实施涉及架构变更。回复 `[VALIDATE]` 重新运行架构验证，回复 `[SKIP]` 跳过（不推荐）。"
     - If user replies `[VALIDATE]`, trigger `devforge-architecture-validation`
```

- [ ] **Step 4: Update State update for RTM**

In Step 10 (State update), add:
```markdown
   - Update `RTM.md`:
     - Append new requirements from iteration with Status=`pending`
     - For affected modules with breaking interface changes, downgrade existing requirement Status from `verified` to `implemented`
```

- [ ] **Step 5: Validate frontmatter**

```bash
python scripts/package-plugin.py --mode all --output ./dist
```

Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add devforge-iteration-planning/SKILL.md
git commit -m "feat(iteration-planning): add verification_gate, post-iteration validation prompt, RTM updates"
```

---

### Task 10: Create devforge-test-execution skill

**Files:**
- Create: `devforge-test-execution/SKILL.md`

- [ ] **Step 1: Create the new skill file**

Write the complete `SKILL.md`:

```markdown
---
name: devforge-test-execution
description: Use when tests have been generated and the user needs to execute them, analyze results, generate coverage reports, and update the Requirement Traceability Matrix. Trigger when user says [TEST] or after module design is complete.
---

# DevForge Test Execution

## Overview

Execute all generated tests (unit, integration, end-to-end), analyze results, generate test reports, and synchronize the RTM. This skill bridges the gap between "test code exists" and "tests are running and passing."

## VCMF Checkpoints

| Principle | Checkpoint in this Skill |
|-----------|--------------------------|
| Design as Contract | Every failing test must map back to a PRD requirement ID |
| Interface as Boundary | Test input/output must match `component-spec.xml` signatures |
| Reality as Baseline | Coverage report must be generated and compared against 80% threshold |
| State as Responsibility | State lifecycle tests must verify `StateModel` ownership |

## When to Use

- User inputs `[TEST]`
- All modules are design_completed and user needs test validation
- After iteration-planning implementation completes
- Do NOT use if no tests exist yet (use `devforge-project-scaffolding` first)

## Precondition Check

Read `STATE.md`. Acceptable phases: `module_design_completed`, `scaffolding_completed`, `iteration_planning_completed`. If no code or tests exist, stop and instruct user to complete scaffolding first.

## Language Adaptation

- System instructions in English for maximum model compliance
- User-facing gate messages in user's input language

## Workflow

1. **Test checklist load**
   - Read `RTM.md`, extract all rows with non-empty `Test Case ID`
   - Group by module, identify P0/P1 requirements with missing test coverage
   - Output `docs/architecture/validation/TEST_COVERAGE_GAP.md`

2. **Environment preparation**
   - Check `.env` exists (for real tests requiring API keys)
   - If no `.env`, configure test run in mock mode
   - Install dependencies (requirements.txt, package.json, etc.)

3. **Unit test execution**
   - Run `tests/mock/` directory
   - Collect coverage report (pytest-cov / jest / jacoco)
   - If coverage < 80%, mark `coverage_failure`

4. **Integration test execution**
   - Run `tests/real/` (with `skipif`)
   - Stats: skipped vs passed vs failed
   - If API key available, run real-LLM tests; else mark `skipped`

5. **End-to-end test execution (PRD-based)**
   - Read `PRD.md` User Stories, ensure each P0 story has end-to-end test
   - End-to-end test header MUST reference PRD:
     ```python
     # E2E Test: US-001 — User Login Flow
     # Source: PRD.md::User Stories::US-001
     # Acceptance Criteria: AC-1.1, AC-1.2
     ```
   - Run `tests/end_to_end/`
   - Map failures to PRD requirement IDs

6. **Test report generation**
   - Output `docs/architecture/validation/TEST_REPORT.md`:
     - Summary: unit/integration/e2e pass rates
     - Coverage trend vs last run
     - Failure details: test → reason → PRD req → fix direction
     - Missing coverage: P0/P1 without Test Case ID

7. **RTM synchronization**
   - Passed tests → Status: `tested`
   - Failed tests → Status: `implemented` (not downgraded)
   - Update `RTM.md` Test Case ID and Status columns

8. **Gate**
   - "测试报告已生成。单元测试通过率 X%，集成测试通过率 Y%，端到端测试通过率 Z%。回复 `[APPROVE]` 标记测试阶段完成，回复 `[DEBUG]` 进入调试模式修复失败，回复 `[RETEST]` 重新运行。"
   - If failures exist, offer `[DEBUG]` to enter `devforge-debug-assistant`

## Output Specification

- `docs/architecture/validation/TEST_REPORT.md`
- `docs/architecture/validation/TEST_COVERAGE_GAP.md`
- Updated `RTM.md`

## Red Flags

- Do NOT proceed without executing all three test tiers (mock, real, e2e)
- Do NOT downgrade RTM Status from `implemented` to `pending` for failed tests
- Do NOT skip the human gate before applying changes
- Do NOT generate tests — only execute existing ones
```

- [ ] **Step 2: Validate frontmatter**

```bash
python scripts/package-plugin.py --mode all --output ./dist
```

Expected: PASS. New skill packaged successfully.

- [ ] **Step 3: Commit**

```bash
git add devforge-test-execution/SKILL.md
git commit -m "feat(test-execution): add new skill for test execution, reporting, and RTM sync"
```

---

### Task 11: Update devforge-debug-assistant to accept test-execution as predecessor

**Files:**
- Modify: `devforge-debug-assistant/SKILL.md`

- [ ] **Step 1: Update precondition**

Add to acceptable phases:
```markdown
- `test_execution_completed` (if entering from test-execution with failures)
```

- [ ] **Step 2: Add TEST_REPORT.md as evidence source**

In Mode A Step 1 (Collect evidence), add:
```markdown
   - Read `docs/architecture/validation/TEST_REPORT.md` (if entering from test-execution)
```

- [ ] **Step 3: Validate frontmatter**

```bash
python scripts/package-plugin.py --mode all --output ./dist
```

Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add devforge-debug-assistant/SKILL.md
git commit -m "feat(debug-assistant): accept test_execution_completed phase, load TEST_REPORT.md as evidence"
```

---

### Task 12: Final validation and update design doc

**Files:**
- Modify: `devforge-design.md`

- [ ] **Step 1: Update architecture diagram**

Locate the architecture diagram in `devforge-design.md` (around line 32-125). Update it to reflect:
- module-design after scaffolding
- test-execution between module-design and iteration-planning
- iteration-planning looping back to validation

Replace the diagram with:

```
User inputs a raw idea
    |
    v
+-----------------------------------------------------------+
|  devforge-requirement-analysis                                |
|  DIVE: Design                                             |
|  Outputs: PRD.md + RTM.md + DECISION_LOG.md               |
+-----------------------------------------------------------+
    | [APPROVE]
    v
+-----------------------------------------------------------+
|  devforge-architecture-design                                 |
|  DIVE: Design (deepen)                                    |
|  Outputs: ARCHITECTURE.md + INTERFACE_CONTRACT.md         |
|           + architecture.xml + module XML templates       |
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
|  Outputs: PROJECT_SCAFFOLD/ + .env.template               |
|           + docs/sync-rules.md + docs/ADR.md + CHANGELOG  |
|           + XML-driven code skeletons + docs/architecture/INDEX.md |
+-----------------------------------------------------------+
    | [APPROVE]
    v
+-----------------------------------------------------------+
|  (Optional) devforge-module-design                            |
|  DIVE: Design (module-level)                              |
|  Trigger: [MODULE {id}] / [MODULE_BATCH {ids}]           |
|  Outputs: module-prd.md + module-architecture.xml         |
|           + component-spec.xml + test code                |
+-----------------------------------------------------------+
    | [APPROVE / NEXT MODULE]
    v
+-----------------------------------------------------------+
|  devforge-test-execution  [NEW]                             |
|  DIVE: Verify                                             |
|  Trigger: [TEST]                                          |
|  Outputs: TEST_REPORT.md + TEST_COVERAGE_GAP.md         |
|           + Updated RTM.md                                |
+-----------------------------------------------------------+
    | [APPROVE / DEBUG]
    v
+-----------------------------------------------------------+
|  (Iteration) devforge-iteration-planning                      |
|  DIVE: Evolve                                             |
|  Trigger: New requirements after scaffolding              |
|  Outputs: ITERATION_PRD.md + ITERATION_PLAN.md            |
|           + Updated architecture.xml + VALIDATION_DELTA   |
|  Post-iteration: loops back to validation if breaking     |
+-----------------------------------------------------------+
    | [APPROVE]
    v
(Optional stages 8-10: visualization, ops-ready, debug-assistant)
```

- [ ] **Step 2: Update DIVE mapping table**

Locate the DIVE mapping table (around line 596-606). Update to:

```markdown
| DIVE Stage | Skills | Key Activity |
|------------|--------|--------------|
| **Design** | `devforge-requirement-analysis` + `devforge-architecture-design` + `devforge-module-design` | Lock requirements, interfaces, state ownership, architecture, component decomposition |
| **Implement** | `devforge-project-scaffolding` | Generate runnable skeleton with infrastructure and XML-driven code |
| **Verify** | `devforge-architecture-validation` + `devforge-design-review` + **devforge-test-execution** | Mock flow validation + adversarial inspection + test execution + coverage |
| **Evolve** | `devforge-iteration-planning` | Impact analysis, incremental PRD, interface versioning, XML sync, with post-iteration validation loop |
| **Visualize** | `devforge-visualization` | Mermaid diagrams from `architecture.xml` |
| **Operate** | `devforge-ops-ready` | Terraform, K8s, monitoring, progressive deployment |
| **Debug** | `devforge-debug-assistant` | Bug diagnosis + refactoring, accepts `test_execution_completed` as entry point |
```

- [ ] **Step 3: Update implementation path checklist**

Add to v1.2 completed features (or create v1.3 section if preferred):
```markdown
### v1.3 Planned (from optimization design)
- [ ] PRD web research integration
- [ ] Verification phase continuity (both validation + design-review run)
- [ ] FIX sub-flow with diff generation and auto re-validation
- [ ] devforge-test-execution skill
- [ ] Module-design strictly after scaffolding
- [ ] Module-design subagent batch mode
- [ ] Cross-module interface compatibility check
- [ ] Iteration post-implementation validation loop
- [ ] P0/P1/P2 placeholder generation strategy
- [ ] docs/architecture/INDEX.md generation
- [ ] RTM real-time updates across all skills
```

- [ ] **Step 4: Commit**

```bash
git add devforge-design.md
git commit -m "docs(design): update architecture diagram, DIVE mapping, and v1.3 checklist"
```

---

## Plan Self-Review

### Spec Coverage Check

| Spec Requirement | Implementing Task | Status |
|-----------------|-------------------|--------|
| Issue 1: Web search in PRD | Task 2 | Covered |
| Issue 2: Stage order (5/6) | Task 6 gate + Task 7 precondition | Covered |
| Issue 3: Validation continuity + FIX | Task 4 + Task 5 | Covered |
| Issue 4a: module-design after scaffolding | Task 7 precondition | Covered |
| Issue 4b: Test code in module-design | Task 7 step 7.5 | Covered |
| Issue 4c: Unified storage | Task 7 output paths + Task 6 INDEX | Covered |
| Issue 4d: Subagent batch mode | Task 8 | Covered |
| Issue 5: New test-execution skill | Task 10 | Covered |
| Issue 6: requirements.txt/.env | Already done in scaffolding | No task needed |
| Issue 7: Iteration verification loop | Task 9 | Covered |
| Issue 8: Module XML + cross-module check | Task 3 + Task 8 | Covered |
| Issue 9: Document classification | Task 6 INDEX.md | Covered |
| Issue 10: P0/P1/P2 placeholder | Task 6 | Covered |
| Issue 11: RTM real-time updates | Task 9 + Task 10 + Task 7 | Covered |
| test-execution → debug-assistant handoff | Task 11 | Covered |

### Placeholder Scan

- No "TBD", "TODO", "implement later", "fill in details" found
- No "Add appropriate error handling" without specifics
- No "Similar to Task N" references
- All file paths are exact

### Type Consistency Check

- `phase` values consistent across all modified skills
- Command names (`[FIX]`, `[APPLY]`, `[FORCE_APPROVE]`, `[SKIP_REVIEW]`, `[DESIGN_REVIEW]`, `[VALIDATE]`, `[TEST]`) consistent between `intervention-checkpoint.md`, `design-review`, `architecture-validation`, and `iteration-planning`
- Output paths consistent (`PROJECT_SCAFFOLD/` vs `skill/artifacts/`)

---

*Plan version: 1.0*
*Date: 2026-05-07*
*Status: Ready for execution*
