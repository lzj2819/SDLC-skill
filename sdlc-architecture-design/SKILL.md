---
name: sdlc-architecture-design
description: Use when a PRD has been approved and the user needs system architecture, interface contracts, test case design, and XML-based architecture modeling
---

# SDLC Architecture Design

## Overview

Given an approved PRD and full historical context, evaluate multiple architecture patterns in parallel (orchestrator-worker), synthesize a recommendation with full reasoning, design explicit interface contracts, define state ownership, and produce a high-dimensional system architecture in XML.

## Parallel Exploration Model

This skill uses an orchestrator-worker pattern internally:
- **Orchestrator**: Reads PRD + full history, defines evaluation dimensions, dispatches parallel workers
- **Workers**: Each worker evaluates ONE architecture pattern independently
- **Synthesis**: Orchestrator compares score matrices, produces recommendation with full reasoning chain

## VCMF Checkpoints

| Principle | Checkpoint in this Skill |
|-----------|--------------------------|
| Design as Contract | Architecture must be traceable back to PRD requirements; no invented requirements |
| Interface as Boundary | Every cross-module call must have explicit Input/Output types and error codes in INTERFACE_CONTRACT.md |
| Reality as Baseline | Test cases must cover happy path, abnormal path, and NFR scenarios |
| State as Responsibility | XML `<StateModel>` must answer: where stored, who writes, who reads, lifecycle |

## When to Use

- The user has approved a PRD and wants to move to architecture
- You need to generate interface contracts, test cases, and an XML architecture model
- Do NOT use if `skill/artifacts/PRD.md` does not exist or has not been approved

## Precondition Check

Before starting, read `skill/artifacts/STATE.md`. Acceptable entry phases: `requirement_analysis_completed` (initial design), `iteration_planning_completed` (architecture refactor within iteration), `evolution_completed` (post-evolution redesign). If `PRD.md` is missing, stop and ask the user to run `sdlc-requirement-analysis` first.

## Workflow

1. **Architecture parallel exploration**
   - Read `PRD.md`, `STATE.md`, `DECISION_LOG.md` (full historical context)
   - Read `skill/references/architecture-patterns.md` (full pattern library with evaluation dimensions)
   - Define evaluation dimensions from PRD requirements (e.g., coupling, data isolation, scalability, team familiarity, maintenance cost)
   - **Dynamic pattern selection**: Extract project characteristic tags from the PRD (e.g., `frontend_heavy`, `high_read_write_ratio`, `event_driven`, `multi_tenant`, `team_autonomy`, `complex_domain`). Match tags against the Pattern Selection Matrix in `architecture-patterns.md` to select the top 4-6 most relevant patterns. If fewer than 4 tags match, default to: Layered, Hexagonal, Event-Driven, Microservice, Client-Server.
   - Ask the user if they have a preferred architecture pattern; if yes, evaluate that pattern plus 2 alternatives for comparison
   - If no preference, evaluate the dynamically selected patterns in parallel (4-6 patterns)
   - For each pattern, produce: fit score per dimension (using the Score Guide from `architecture-patterns.md`), key strengths, key risks
   - Synthesize: score matrix, recommended pattern, and **full reasoning chain** (why chosen, why others rejected)

2. **Interface contract design**
   - Based on the "Cross-Module Interactions" section in the PRD, define every interface explicitly
   - For each interface, document: method name, input schema, output schema, error codes, serialization format
   - Write `skill/artifacts/INTERFACE_CONTRACT.md`

3. **State ownership mapping**
   - Identify every stateful entity mentioned in the PRD
   - For each state, define: storage location, writer, readers, lifecycle policy
   - Embed this information into the XML `<StateModel>`

4. **Test case design**
   - Based on User Stories and AC, generate test cases for happy paths and abnormal paths
   - Define standardized Mock business data structures
   - Define NFR-specific test cases (performance, security)

5. **XML architecture modeling**
   - Read `skill/references/xml-schemas.md` (strict schema definitions for all three XML layers)
   - Output a strict XML file at `skill/artifacts/architecture.xml` (or `docs/architecture/system/architecture.xml` if in iteration mode)
   - Must validate against the System Level schema defined in `xml-schemas.md`
   - Must contain:
     - `SystemArchitecture` root with `type` attribute and `version` attribute
     - `DecisionTrace` node with `Decision` children (id, date, Question, Answer, Risk)
     - `Module` nodes with `Interface` (Input/Output), `Coupling` (DependsOn), and `ModuleDetail` (ref to module-level XML)
     - `DataModel` nodes with `Fields` and `CacheStrategy`
     - `StateModel` nodes with `State` (location, owner, consumer, lifecycle)
     - `Security` nodes with `Authentication` and `Encryption`
   - **Module Level XML templates**: For each `Module` defined in the system XML, auto-generate a template at `skill/artifacts/modules/{module_id}/module-architecture.xml` (or `docs/architecture/modules/{module_id}/`). The template must validate against the Module Level schema in `xml-schemas.md` and include:
     - `ParentSystem` reference back to the system XML
     - `Constraints` section pre-populated with the module's system-level interface obligations (Input/Output schemas copied from system `Module/Interface`)
     - `Components` placeholder with at least one example `Component` node showing the expected structure
     - `ComponentInterfaces` placeholder
     - `ModuleStateModel` placeholder pre-populated with any system-level `State` entries owned by this module
   - **Reference integrity**: Ensure all `ModuleDetail/@ref` attributes use relative paths that resolve correctly from the system XML location

6. **Architecture documentation**
   - Write `skill/artifacts/ARCHITECTURE.md` containing:
     - Selected architecture and justification
     - Interface contract summary
     - Test case catalog
     - Mock data definitions

7. **Decision Log update**
   - Append architecture decisions to `skill/artifacts/DECISION_LOG.md`
   - Each entry MUST include:
     - Date and decision ID
     - Evaluation dimensions and score matrix
     - Full reasoning chain (why recommended, why each alternative rejected)
     - Rejected alternatives with specific reasons

8. **State update**
   - Update `STATE.md`:
     - Append to **Completed Steps**: `[YYYY-MM-DD HH:MM] sdlc-architecture-design: Evaluated N patterns. Selected [pattern]. Key reasoning: [summary]`
     - Append to **Known Pitfalls** any risks identified during evaluation
     - Set `phase: architecture_design_completed`
     - Set DIVE `Design: completed`, `Implement: pending`

9. **Human gate**
   - Present architecture summary and XML outline
   - Say exactly: "架构设计、接口契约和 XML 模型已生成。请确认当前阶段输出。回复 [APPROVE] 进入架构验证阶段，或提出修改意见。"
   - Do NOT proceed until [APPROVE]

<HARD-GATE>
Do NOT proceed to architecture-validation or scaffolding until the user replies [APPROVE].
</HARD-GATE>

## Output Specification

- `skill/artifacts/ARCHITECTURE.md`
- `skill/artifacts/INTERFACE_CONTRACT.md`
- `skill/artifacts/architecture.xml` (strict schema)

## Red Flags

- Do NOT invent requirements not in the PRD
- Do NOT skip the XML schema constraints (must include `StateModel`)
- Do NOT write vague interface contracts like "returns data"
- Do NOT proceed without the human gate
