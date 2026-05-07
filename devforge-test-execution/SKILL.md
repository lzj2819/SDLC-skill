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
