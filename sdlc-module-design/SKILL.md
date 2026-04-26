---
name: sdlc-module-design
description: Use when a system-level architecture has been approved and the user needs detailed design for a specific module, including module-level PRD, component decomposition, component interfaces, and module-level XML. Trigger when user says [MODULE {module_id}] or asks to design a specific module in detail.
---

# SDLC Module Design

## Overview

Given an approved system-level architecture, drill down into a single module to produce a complete module-level design. This skill treats the module as a "mini-system": it performs requirement analysis, architecture design, interface contract definition, and XML modeling — all scoped to this module's boundaries.

This is the "same thinker" facing the module-level view of the same problem.

## VCMF Checkpoints

| Principle | Checkpoint in this Skill |
|-----------|--------------------------|
| Design as Contract | Module design must trace back to the system-level PRD and architecture; no new requirements invented outside the module's system-level scope |
| Interface as Boundary | Every cross-component call must have explicit Input/Output types and error codes in `module-interface-contract.md` |
| Reality as Baseline | Module-level test cases must cover happy path, abnormal path, and state lifecycle edge cases |
| State as Responsibility | `ModuleStateModel` must answer: where stored, which component writes, which components read, lifecycle |

## When to Use

- The user has approved system-level architecture and wants to design a specific module in detail
- The user types `[MODULE {module_id}]` or says "design the {module} module"
- Do NOT use if system-level `architecture.xml` has not been approved

## Precondition Check

Before starting, read `skill/artifacts/STATE.md` (or `docs/architecture/system/STATE.md`).
- Acceptable phases: `architecture_design_completed`, `architecture_validated`, `design_review_completed`, `scaffolding_completed`, `module_design_completed`
- If phase is earlier than `architecture_design_completed`, stop and instruct the user to complete `sdlc-architecture-design` first
- If `architecture.xml` is missing, stop and instruct the user to complete system-level architecture first

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

8. **Module documentation**
   - Write `module-prd.md` containing:
     - Module background and scope (within system context)
     - Module-level user stories with acceptance criteria
     - Functional requirements graded P0/P1/P2
     - Non-functional requirements (performance, security relevant to this module)
     - Component responsibility map
     - Test case catalog
     - Mock data definitions

9. **State update**
   - Update `STATE.md`:
     - Append to **Completed Steps**: `[YYYY-MM-DD HH:MM] sdlc-module-design: Designed module [module_id]. Components: [list]. Key decisions: [summary]`
     - Update **Current State**: if all modules are designed, set `phase: module_design_completed`; otherwise keep current phase
     - Update **Module Registry**: append `{id: module_id, status: design_completed, path: modules/{module_id}/}`
     - Append any module-specific risks to **Known Pitfalls**

10. **Human gate**
    - Present module design summary (component list, interface count, test case count)
    - Say exactly: "模块 `{module_id}` 的详细设计已生成，包含模块级 PRD、组件分解、接口契约和 XML 模型。请确认当前阶段输出。回复 [APPROVE] 进入该模块的脚手架阶段，回复 [NEXT MODULE] 设计下一个模块，或提出修改意见。"
    - Do NOT proceed until [APPROVE] or [NEXT MODULE]

## Output Specification

- `skill/artifacts/modules/{module_id}/module-prd.md`
- `skill/artifacts/modules/{module_id}/module-architecture.xml` (strict schema)
- `skill/artifacts/modules/{module_id}/module-interface-contract.md`
- `skill/artifacts/modules/{module_id}/components/{component_id}/component-spec.xml` (template for each component)

## Red Flags

- Do NOT invent requirements not traceable to the system-level PRD
- Do NOT violate the module's system-level interface boundaries
- Do NOT skip the `ModuleStateModel` in the module XML
- Do NOT write vague component interfaces like "returns data"
- Do NOT proceed without the human gate
