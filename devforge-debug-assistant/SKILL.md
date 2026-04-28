---
name: devforge-debug-assistant
description: Use when tests are failing, logs show anomalies, or the user wants code-level improvements. Provides bug diagnosis, root cause analysis, and refactoring suggestions. Trigger when user says [DEBUG] or "fix this bug" or "refactor this code".
---

# DevForge Debug Assistant

## Overview

Analyze failing tests, error logs, or existing code to provide actionable bug fixes and refactoring suggestions. This skill bridges the gap between "code exists" and "code is correct and maintainable."

## VCMF Checkpoints

| Principle | Checkpoint in this Skill |
|-----------|--------------------------|
| Design as Contract | Bug fixes must not violate `INTERFACE_CONTRACT.md` or `component-spec.xml` |
| Interface as Boundary | Refactoring must preserve all public interfaces unless explicitly approved |
| Reality as Baseline | Diagnosis must be based on actual test output / logs, not speculation |
| State as Responsibility | Bug fixes involving state must respect `StateModel` ownership |

## When to Use

- Tests are failing and the user needs diagnosis + fix
- Error logs contain exceptions or anomalies
- The user wants to improve code quality (refactoring)
- The user types `[DEBUG]` or says "fix this bug" / "refactor this"
- Do NOT use if no code or tests exist yet (use `devforge-project-scaffolding` first)

## Precondition Check

Read `skill/artifacts/STATE.md`. Acceptable phases: `scaffolding_completed`, `module_design_completed`, `iteration_planning_completed`.

If no code exists, stop and instruct the user to complete scaffolding first.

## Workflow

### Mode A: Bug Diagnosis and Fix

1. **Collect evidence**
   - Read failing test output (from CI logs or local test run)
   - Read relevant source code files
   - Read `component-spec.xml` for the affected component
   - Read error stack traces and log excerpts

2. **Root cause analysis**
   - Trace the failure from symptom to cause:
     - Test assertion failure → what value was expected vs actual?
     - Exception → which line threw? What was the input?
     - Timeout → which dependency was slow? Is there a retry mechanism?
   - Check against common categories:
     - Logic error (wrong condition, off-by-one)
     - State error (race condition, uninitialized state)
     - Interface mismatch (schema changed but consumer not updated)
     - Dependency failure (mock not set up, external service down)
     - XML divergence (code signature differs from `component-spec.xml`)

3. **Propose fix**
   - Provide the minimal code change to fix the bug
   - Include inline comment explaining the root cause
   - Verify the fix does not break other tests
   - If the fix requires interface changes, flag as breaking and warn user

4. **Generate debug report**
   - Output: `skill/artifacts/DEBUG_REPORT.md`
   - Contents:
     - Symptom summary
     - Root cause (with code references)
     - Proposed fix (diff format)
     - Regression risk assessment
     - Verification steps (how to confirm the fix)

### Mode B: Refactoring Suggestion

1. **Code health scan**
   - Read source code of the target module/component
   - Read `component-spec.xml` and `INTERFACE_CONTRACT.md`
   - Read `DESIGN_REVIEW.md` for known issues

2. **Identify improvement opportunities**
   - Check for code smells:
     - Long function (> 50 lines)
     - Deep nesting (> 3 levels)
     - Duplicated logic
     - Magic numbers/strings
     - Tight coupling (direct dependency on concrete class)
     - Missing error handling paths
   - Check for architecture alignment:
     - Does code match `component-spec.xml` signatures?
     - Does state management match `StateModel`?
     - Are interfaces using the correct schemas?

3. **Propose refactorings**
   - For each issue, provide:
     - Location (file:line)
     - Problem description
     - Refactoring strategy (extract method, introduce interface, etc.)
     - Before/after code snippet
     - Risk level (low / medium / high — high = may affect behavior)

4. **Generate refactor report**
   - Output: `skill/artifacts/REFACTOR_REPORT.md`
   - Contents:
     - Issue list with severity (Must Fix / Should Fix / Nice to Fix)
     - Before/after snippets
     - Risk assessment per refactoring
     - Suggested execution order (low risk first)

5. **Human gate**
   - Present summary: "调试/重构报告已生成。回复 [APPROVE FIX] 应用修复，回复 [APPROVE REFACTOR] 应用重构，回复 [SPECIFIC {issue_id}] 只处理特定问题，或提出修改意见。"

## Output Specification

- `skill/artifacts/DEBUG_REPORT.md` (for bug diagnosis mode)
- `skill/artifacts/REFACTOR_REPORT.md` (for refactoring mode)

## Red Flags

- Do NOT propose fixes that violate `INTERFACE_CONTRACT.md` without explicit user approval
- Do NOT refactor without preserving public interface contracts
- Do NOT diagnose based on speculation; always reference actual test output or logs
- Do NOT skip the human gate before applying changes
