# SDLC-skill P2 开发者体验进阶 — 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现 P2 优化项：Bug 定位修复、重构建议、需求追溯矩阵、多环境部署策略，完成 SDLC-skill v1.2 的全部功能增强。

**Architecture:** 新增 `sdlc-debug-assistant` skill（统一处理 Bug 定位和重构建议）；扩展 `sdlc-requirement-analysis` 在 PRD 阶段自动生成 RTM；扩展 `sdlc-ops-ready` 增加蓝绿/金丝雀发布策略。

**Tech Stack:** Markdown (SKILL.md)、Mermaid 语法、K8s 渐进式发布配置

---

## 文件变更清单

| 文件 | 操作 | 说明 |
|------|------|------|
| `sdlc-debug-assistant/SKILL.md` | 创建 | 新 skill：Bug 定位 + 重构建议 |
| `sdlc-requirement-analysis/SKILL.md` | 修改 | PRD 生成时自动输出 RTM |
| `sdlc-ops-ready/SKILL.md` | 修改 | 增加蓝绿/金丝雀发布策略 |
| `软件开发全流程智能体技能(SDLC-Skill).md` | 修改 | 注册 debug-assistant |

---

### Task 1: 创建 sdlc-debug-assistant/SKILL.md

**Files:**
- Create: `sdlc-debug-assistant/SKILL.md`

- [ ] **Step 1: 创建目录**

```bash
mkdir -p sdlc-debug-assistant
```

- [ ] **Step 2: 编写 SKILL.md**

```markdown
---
name: sdlc-debug-assistant
description: Use when tests are failing, logs show anomalies, or the user wants code-level improvements. Provides bug diagnosis, root cause analysis, and refactoring suggestions. Trigger when user says [DEBUG] or "fix this bug" or "refactor this code".
---

# SDLC Debug Assistant

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
- Do NOT use if no code or tests exist yet (use `sdlc-project-scaffolding` first)

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
```

- [ ] **Step 3: 提交**

```bash
git add sdlc-debug-assistant/
git commit -m "feat(debug-assistant): add sdlc-debug-assistant skill

- Bug diagnosis with root cause analysis
- Automated fix proposals with regression risk assessment
- Code refactoring suggestions with before/after snippets
- Two modes: DEBUG (bug fix) and REFACTOR (improvement)
- VCMF checkpoints for safe modifications

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

### Task 2: 扩展 sdlc-requirement-analysis 自动生成 RTM

**Files:**
- Modify: `sdlc-requirement-analysis/SKILL.md`

- [ ] **Step 1: 在 PRD 生成步骤中增加 RTM 输出**

找到 Step 5 (PRD generation) 的输出描述，在 `Write the PRD to skill/artifacts/PRD.md` 之后增加：

```
6. **Requirement Traceability Matrix (RTM) generation**
   - After PRD is complete, generate `skill/artifacts/RTM.md`
   - RTM structure:
     - Columns: Requirement ID, User Story, Acceptance Criteria, Architecture Module, Component, Test Case ID, Status
     - Each P0/P1 requirement MUST have at least one mapped Module and Component
     - Status values: pending / designed / implemented / tested / verified
   - Initial status for all entries: `pending`
   - RTM is updated by subsequent skills:
     - `sdlc-architecture-design` → update Architecture Module column
     - `sdlc-module-design` → update Component column
     - `sdlc-project-scaffolding` → update Test Case ID column
     - `sdlc-architecture-validation` → update Status to verified
```

- [ ] **Step 2: 更新 Output Specification**

在 Output Specification 中增加：
```
- `skill/artifacts/RTM.md` (Requirement Traceability Matrix)
```

- [ ] **Step 3: 提交**

```bash
git add sdlc-requirement-analysis/SKILL.md
git commit -m "feat(requirement-analysis): auto-generate RTM with PRD

- Add RTM generation step after PRD creation
- Map requirements to modules, components, and test cases
- Track status through SDLC pipeline
- Updated Output Specification

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

### Task 3: 扩展 sdlc-ops-ready 增加蓝绿/金丝雀发布

**Files:**
- Modify: `sdlc-ops-ready/SKILL.md`

- [ ] **Step 1: 在工作流中增加渐进式发布步骤**

在 Step 6 (Multi-environment configuration) 之后插入新步骤：

```
7. **Progressive deployment strategy**
   - Output: `infrastructure/kubernetes/overlays/prod/progressive/`
   - Generate K8s manifests for two deployment strategies:
     
     **Blue-Green Deployment** (`blue-green/`):
     - Two identical environments (blue = current, green = new)
     - Service selector switches traffic from blue to green after health check
     - Instant rollback: switch selector back to blue
     - Resource cost: 2x during transition
     
     **Canary Deployment** (`canary/`):
     - Primary deployment (100% traffic) + Canary deployment (5% traffic)
     - Traffic splitting via Ingress (nginx canary annotations or Istio VirtualService)
     - Automated promotion criteria:
       - Error rate < 1% for 10 minutes
       - P99 latency < baseline + 20% for 10 minutes
     - Automated rollback criteria:
       - Error rate > 5% for 2 minutes
       - P99 latency > baseline + 50% for 2 minutes
     - Gradual traffic shift: 5% → 25% → 50% → 100%
     
   - Generate `promotion-policy.yaml` defining the criteria and thresholds
   - Generate `rollback-policy.yaml` defining emergency rollback triggers
```

- [ ] **Step 2: 更新 Output Specification**

增加：
```
- `infrastructure/kubernetes/overlays/prod/progressive/blue-green/` — Blue-green deployment manifests
- `infrastructure/kubernetes/overlays/prod/progressive/canary/` — Canary deployment manifests
- `infrastructure/kubernetes/overlays/prod/progressive/promotion-policy.yaml` — Promotion criteria
- `infrastructure/kubernetes/overlays/prod/progressive/rollback-policy.yaml` — Rollback triggers
```

- [ ] **Step 3: 提交**

```bash
git add sdlc-ops-ready/SKILL.md
git commit -m "feat(ops-ready): add progressive deployment strategies

- Blue-green deployment with instant rollback
- Canary deployment with automated promotion/rollback criteria
- Traffic splitting via Ingress annotations
- Error rate and latency-based thresholds

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

### Task 4: 更新根目录 SKILL.md 注册 debug-assistant

**Files:**
- Modify: `软件开发全流程智能体技能(SDLC-Skill).md`

- [ ] **Step 1: 在阶段九之后增加阶段十**

在阶段九（Ops Ready）之后、约束与原则之前插入：

```markdown
---

### **阶段十：调试与重构助手（可选）(Phase 10: Debug & Refactor)**

**触发条件**：用户输入 `[DEBUG]`、测试失败、或要求重构代码。

**执行动作**：

1. **Bug 诊断模式**：
   - 收集测试失败证据（断言差异、异常堆栈、日志）
   - 根因分析（逻辑错误、状态错误、接口不匹配、依赖失败）
   - 生成最小修复方案 + 回归风险评估
   - 输出 `DEBUG_REPORT.md`

2. **重构建议模式**：
   - 扫描代码健康度（代码坏味道、架构对齐性）
   - 提供重构策略（提取方法、引入接口等）
   - 输出 `REFACTOR_REPORT.md`
```

- [ ] **Step 2: 提交**

```bash
git add 软件开发全流程智能体技能\(SDLC-Skill\).md
git commit -m "docs: register P2 debug-assistant in main SDLC overview

- Add Phase 10: Debug & Refactor (sdlc-debug-assistant)

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

### Task 5: P2 一致性验证

- [ ] **Step 1: 验证所有文件存在**

```bash
ls sdlc-debug-assistant/SKILL.md
ls sdlc-requirement-analysis/SKILL.md
ls sdlc-ops-ready/SKILL.md
```

- [ ] **Step 2: 验证提交历史**

```bash
git log --oneline -5
```

- [ ] **Step 3: 验证根目录 SKILL.md 包含阶段十**

```bash
grep -n "阶段十" 软件开发全流程智能体技能\(SDLC-Skill\).md
```

---

## Spec 覆盖度检查

| Spec 要求 | 实现任务 | 状态 |
|-----------|----------|------|
| Bug 定位与修复建议 | Task 1 (Mode A) | ✅ |
| 代码重构建议 | Task 1 (Mode B) | ✅ |
| 需求追溯矩阵 (RTM) | Task 2 | ✅ |
| 多环境部署策略 | Task 3 (蓝绿 + 金丝雀) | ✅ |
| 根目录注册 | Task 4 | ✅ |
