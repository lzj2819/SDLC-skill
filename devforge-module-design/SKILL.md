---
name: devforge-module-design
description: Use when a system-level architecture has been approved and the user needs detailed design for a specific module, including module-level PRD, component decomposition, component interfaces, and module-level XML. Trigger when user says [MODULE {module_id}] or asks to design a specific module in detail.
---

# DevForge Module Design

## Overview

Given an approved system-level architecture, drill down into a single module to produce a complete module-level design. This skill treats the module as a "mini-system": it performs requirement analysis, architecture design, interface contract definition, and XML modeling — all scoped to this module's boundaries.

This is the "same thinker" facing the module-level view of the same problem.

## VCMF Checkpoints

| Principle | Checkpoint in this Skill |
|-----------|--------------------------|
| Design as Contract | Module design must trace back to the system-level PRD and architecture; generated code skeletons must trace back to `component-spec.xml` |
| Interface as Boundary | Every cross-component call must have explicit Input/Output types and error codes in `module-interface-contract.md`; generated code signatures must match |
| Reality as Baseline | Module-level test cases must cover happy path, abnormal path, and state lifecycle edge cases |
| State as Responsibility | `ModuleStateModel` must answer: where stored, which component writes, which components read, lifecycle |
| XML as Authority | Generated code skeletons must strictly match `component-spec.xml` signatures and error handling |

## When to Use

- The user has approved system-level architecture and wants to design a specific module in detail
- The user types `[MODULE {module_id}]` or says "design the {module} module"
- The user types `[MODULE_BATCH {id1},{id2},...]` to design multiple modules in parallel
- Do NOT use if system-level `architecture.xml` has not been approved

## Precondition Check

Before starting, read `skill/artifacts/STATE.md` (or `docs/architecture/system/STATE.md`).
- Acceptable phases: `scaffolding_completed`, `module_design_completed`
- If phase is earlier than `scaffolding_completed`, stop and instruct the user to complete `devforge-project-scaffolding` first
- If `architecture.xml` is missing, stop and instruct the user to complete system-level architecture first

## Language Adaptation

- System instructions and constraints in this skill are in English for maximum model compliance
- User-facing gate messages, summaries, and explanations use the same language as the user's most recent input
- If the user writes in Chinese, respond in Chinese. If English, respond in English

## Workflow

1. **Load parent context**
   - Read `PRD.md` (full system requirements)
   - Read `architecture.xml` (system-level architecture)
   - Read `INTERFACE_CONTRACT.md` (system-level I/O boundaries)
   - Read `DECISION_LOG.md` (reasoning chain)
   - Read `STATE.md` (module registry, if any modules already designed)
   - Identify the target `module_id` from user input (e.g., `[MODULE UserService]`)

2. **Lock module boundaries**
   - Extract the target module's system-level definition from `architecture.xml`:
     - `Module/@id`, `Module/@owner`
     - `Module/Responsibility`
     - `Module/Interface` (all Input/Output schemas and error codes)
     - `Module/Coupling` (all DependsOn entries)
     - `Module/ModuleDetail/@ref` (path to existing module XML template)
   - Load the existing module XML template if it exists
   - Write down the **boundary constraint**: this module MUST honor its system-level interface; internal design freedom exists only within these boundaries

3. **Module-level requirement analysis**
   - Scan the system `PRD.md` for all user stories, requirements, and acceptance criteria that involve this module
   - For each relevant system-level user story, create 1-3 **module-level user stories** that describe how this module fulfills its portion
   - Grade module-level requirements P0 / P1 / P2
   - Define module-level acceptance criteria (observable and testable)
   - Identify module-specific edge cases and fallback strategies

4. **Component decomposition**
   - Decompose the module into 3-6 internal components based on the module's responsibility
   - Common component types:
     - `entry_point`: Controllers, handlers, or API endpoints
     - `domain_service`: Core business logic
     - `repository`: Data access and persistence
     - `utility`: Cross-cutting helpers (token generation, validation, etc.)
     - `gateway`: External service clients
   - For each component, define: `id`, `type`, `responsibility`
   - Assign ownership: which component is the primary writer/reader for each module-level state

5. **Component interface design**
   - Define explicit interfaces between components
   - For each interface, document: method name, input schema, output schema, error codes
   - Ensure interface directions do not violate the system-level `Coupling` constraints
   - Write `module-interface-contract.md`

6. **Module-level XML modeling**
   - Read `skill/references/xml-schemas.md` (Module Level schema)
   - Fill the module XML template (`module-architecture.xml`) with:
     - `Constraints/InterfaceConstraint`: Copy system-level Input/Output schemas
     - `Components`: All decomposed components with `ComponentDetail` refs
     - `ComponentInterfaces`: All inter-component calls
     - `ModuleStateModel`: All state entries owned by this module
   - For each component, generate a `component-spec.xml` template at `modules/{module_id}/components/{component_id}/component-spec.xml`
     - Include `ParentModule` ref
     - Include `Metadata` placeholder (Language, Framework, FilePath)
     - Include `Functions` placeholder
     - Include `Dependencies` placeholder

7. **Module-level test case design**
   - Based on module-level user stories and acceptance criteria, generate test cases:
     - Happy path tests for each component
     - Abnormal path tests (invalid input, dependency failure, state conflict)
     - State lifecycle tests (create, read, update, delete, cleanup)
   - Define mock data structures for component-level testing

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

8. **Component code skeleton generation**
   - Read the freshly generated `component-spec.xml` for each component
   - Generate precise code skeletons that strictly match:
     - Function signatures must match `ComponentSpec/Functions/Function/Signature`
     - Error handling must cover all `ComponentSpec/Functions/Function/ErrorHandling/Error` entries
     - File paths must match `ComponentSpec/Metadata/FilePath`
     - Add inline comments referencing the XML node ID (e.g., `# Implements component-spec.xml::AuthController::login`)
   - Generate code skeletons by component priority:
     - **P0 components**: Generate complete interface stubs with minimal working implementation (non-empty function bodies returning reasonable defaults)
     - **P1 components**: Generate interface stubs with `raise NotImplementedError("P1: implement per module-prd")` (or language equivalent)
     - **P2 components**: Generate file header comments + empty function/class definitions only
   - Write generated files to `PROJECT_SCAFFOLD/{FilePath}` (overwriting scaffolding-generated `__init__.py` or creating new files as needed)
   - Add module header comment to every generated file:
     ```python
     # Module: {module_id}
     # Component: {component_id}
     # Priority: {P0/P1/P2}
     # Source: component-spec.xml::{component_id}
     # Status: {placeholder/minimal-implemented}
     ```

9. **Module documentation**
   - Write `module-prd.md` containing:
     - Module background and scope (within system context)
     - Module-level user stories with acceptance criteria
     - Functional requirements graded P0/P1/P2
     - Non-functional requirements (performance, security relevant to this module)
     - Component responsibility map
     - Test case catalog
     - Mock data definitions

10. **Self-validation: module design consistency**
    - Before finalizing, verify module-level artifacts with automated checks:
      - **Schema compliance**: Confirm `module-architecture.xml` contains all required nodes: `ParentSystem`, `Constraints`, `Components`, `ComponentInterfaces`, `ModuleStateModel`
      - **System interface honor**: Verify every `Constraints/InterfaceConstraint` in `module-architecture.xml` matches the corresponding system-level `Module/Interface` in `architecture.xml`. Flag any missing or divergent schema.
      - **Component spec coverage**: Verify every component listed in `module-architecture.xml/Components` has a corresponding `component-spec.xml` file generated
      - **PRD traceability**: Confirm every module-level user story in `module-prd.md` cites at least one system-level PRD requirement or user story ID
      - **State lifecycle completeness**: Verify every `ModuleStateModel/State` entry has `location`, `owner` (component ID), `consumer` (component IDs), and `lifecycle` (create/read/update/delete/cleanup) attributes
      - **Interface explicitness**: Grep `module-interface-contract.md` for vague phrases like "returns data" or "handles errors". If found, replace with explicit schema and error code definitions.
      - **Cross-module interface compatibility**: Verify every system-level output interface schema in the current module matches the corresponding input schema of all downstream modules (per `Coupling/DependsOn` in `architecture.xml`). Flag any `interface_mismatch` and prevent marking `design_completed` until resolved.
      - **Code skeleton compliance**: For each generated code file, verify:
        - Function signatures match the corresponding `component-spec.xml` entries
        - All `ErrorHandling/Error` entries have corresponding error handling code
        - File paths match `ComponentSpec/Metadata/FilePath`
        - Every file has a traceability comment linking to component-spec.xml
    - If any check fails, fix the module artifacts before proceeding

11. **State update**
    - Update `STATE.md`:
      - Append to **Completed Steps**: `[YYYY-MM-DD HH:MM] devforge-module-design: Designed module [module_id]. Components: [list]. Key decisions: [summary]`
      - Update **Current State**: if all modules are designed, set `phase: module_design_completed`; otherwise keep current phase
      - Update **Module Registry**: append `{id: module_id, status: design_completed, path: modules/{module_id}/}`
      - Append any module-specific risks to **Known Pitfalls**
    - Update `docs/architecture/INDEX.md`: append module row with links to generated artifacts

12. **Human gate**
    - Present module design summary (component list, interface count, test case count)
    - Say exactly: "模块 `{module_id}` 的详细设计已生成，包含模块级 PRD、组件分解、接口契约、XML 模型和精确代码骨架。请确认当前阶段输出。"
    - Then list all available commands:
      ```
      可用命令：
      - [APPROVE] — 批准并继续（进入该模块的测试执行阶段）
      - [NEXT MODULE] — 设计下一个模块
      - [PAUSE] — 暂停当前阶段，保留上下文，稍后输入任意内容继续
      - [ROLLBACK {step_id}] — 回滚到指定步骤重新执行（如 [ROLLBACK step3]）
      - [EDIT {file_path}] — 手动编辑文件后让 AI 继续（如 [EDIT module-prd.md]）
      - [INJECT {context}] — 补充额外上下文约束（如 [INJECT 改用 Redis 缓存]）
      - [SKIP] — 跳过当前可选步骤
      - [EXPLAIN {TraceID}] — 展开解释某个决策/错误的推理链
      ```
    - Do NOT proceed until user explicitly inputs a valid command or modification feedback

## Parallel Batch Mode (Native Agent-Based)

When triggered by `[MODULE_BATCH {id1},{id2},...]`:

1. **Coupling analysis**: Read `architecture.xml`, analyze inter-module `Coupling` relationships. If circular dependencies exist between requested modules, fall back to serial mode and warn user.
2. **Parallel dispatch** (if no circular dependencies):
   - For each module `{id}`, construct an independent subagent prompt containing:
     - The module's system-level definition from `architecture.xml`
     - Full parent context (`PRD.md`, `INTERFACE_CONTRACT.md`, `DECISION_LOG.md`, `STATE.md`)
     - The exact 12-step workflow from this skill scoped to that single module
     - Boundary constraint: honor system-level interfaces, no new requirements outside scope
   - Dispatch all subagents **in parallel** using the native `Agent` tool (one call per module in a single message)
   - Each subagent independently executes the full 12-step workflow and writes its outputs to `PROJECT_SCAFFOLD/modules/{id}/`
   - Subagents do NOT have human gates; they run to completion and return results

3. **Result collection** (after all subagents complete):
   - Read all generated `module-architecture.xml` files
   - Read all generated `module-interface-contract.md` files
   - Read all generated `component-spec.xml` files
   - Verify each module's output files exist and are non-empty

4. **Consistency check**:
   - Cross-module interface compatibility: Verify each module's system-level output matches downstream module's system-level input schema
   - Shared StateModel conflicts: Flag any state entries with same `id` but different definitions across modules
   - Inter-module dependency completeness: Verify every `DependsOn` target has a corresponding module design completed

5. **Conflict resolution**:
   - If no conflicts: update `STATE.md` for all modules at once, append to Module Registry, then present batch summary
   - If conflicts found: present conflict list to user and enter **coordination mode** — fix conflicts sequentially before updating state

6. **Human gate (batch)**:
   - Present summary: "已并行完成 {N} 个模块的详细设计。"
   - List each module with component count and status
   - If conflicts were found and resolved, note: "已解决 {M} 处跨模块冲突"
   - List available commands:
     ```
     可用命令：
     - [APPROVE] — 批准全部模块，继续下一阶段
     - [NEXT MODULE] — 继续设计剩余模块（如有）
     - [PAUSE] — 暂停审查
     - [ROLLBACK {step_id}] — 回滚到某一步重新执行
     - [EDIT {file_path}] — 手动编辑后让 AI 继续
     - [INJECT {context}] — 补充上下文约束
     - [MODULE {id}] — 单独重新设计某个模块
     ```

7. **Fallback**: If parallel `Agent` dispatch is unavailable (platform limitation or single-agent mode), fall back to serial `[MODULE {id}]` -> `[NEXT MODULE]`.

## Output Specification

- `PROJECT_SCAFFOLD/modules/{module_id}/module-prd.md`
- `PROJECT_SCAFFOLD/modules/{module_id}/module-architecture.xml` (strict schema)
- `PROJECT_SCAFFOLD/modules/{module_id}/module-interface-contract.md`
- `PROJECT_SCAFFOLD/modules/{module_id}/components/{component_id}/component-spec.xml` (template for each component)
- `PROJECT_SCAFFOLD/tests/mock/{module_id}/{component_id}_test.*`
- `PROJECT_SCAFFOLD/{component_file_path}` — precise code skeletons for each component (generated from `component-spec.xml`)

## Red Flags

- Do NOT invent requirements not traceable to the system-level PRD
- Do NOT violate the module's system-level interface boundaries
- Do NOT skip the `ModuleStateModel` in the module XML
- Do NOT write vague component interfaces like "returns data"
- Do NOT proceed without the human gate
