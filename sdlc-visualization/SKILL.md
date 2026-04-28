---
name: sdlc-visualization
description: Use when a system architecture has been designed and the user wants visual diagrams (system context, module interaction, data flow, ER diagram) generated from the architecture XML. Trigger when user says [VISUALIZE] or "generate architecture diagrams".
---

# SDLC Visualization

## Overview

Generate visual architecture diagrams from an approved `architecture.xml`. This skill parses the XML model and produces Mermaid-syntax diagrams that can be rendered in Markdown viewers, documentation sites, and GitHub.

## VCMF Checkpoints

| Principle | Checkpoint in this Skill |
|-----------|--------------------------|
| Design as Contract | Diagrams must match `architecture.xml` exactly; no invented modules or interfaces |
| Interface as Boundary | Sequence diagram messages must match `Interface` definitions |
| Reality as Baseline | ER diagram relationships must have `Relationships` node or `Coupling` support |

## When to Use

- The user has approved an architecture and wants visual diagrams
- The user types `[VISUALIZE]` or says "generate architecture diagrams"
- Can be invoked after `sdlc-architecture-design` or at any time when `architecture.xml` exists

## Precondition Check

Read `skill/artifacts/STATE.md`. Acceptable phases: `architecture_design_completed`, `architecture_validated`, `design_review_completed`, `scaffolding_completed`, `module_design_completed`.

If `architecture.xml` is missing, stop and instruct the user to complete `sdlc-architecture-design` first.

## Workflow

1. **Parse architecture XML**
   - Read `skill/artifacts/architecture.xml` (or `docs/architecture/system/architecture.xml`)
   - Read module-level XMLs if available (`modules/{id}/module-architecture.xml`)
   - Build internal graph: modules, couplings, interfaces, data models

2. **Generate System Context Diagram**
   - Output: `docs/architecture/diagrams/system-context.mmd`
   - Mermaid syntax: `graph TD`
   - Nodes: User, External Systems (inferred from `Coupling`), each `Module`
   - Edges: API calls, data flows, event streams
   - Style: User = external actor (circle), Modules = boxes, External = clouds

3. **Generate Module Interaction Sequence Diagram**
   - Output: `docs/architecture/diagrams/module-interaction.mmd`
   - Mermaid syntax: `sequenceDiagram`
   - Select one core user story (from PRD) and trace module interactions
   - Each `Module` = participant
   - Each `Interface` method = message arrow
   - Include auth check and error response paths

4. **Generate Data Flow Diagram**
   - Output: `docs/architecture/diagrams/data-flow.mmd`
   - Mermaid syntax: `graph LR`
   - Nodes: Data sources, `Module`s, storage systems (from `StateModel`), external sinks
   - Edges: Data transformations, CRUD operations
   - Highlight: state ownership (who writes, who reads)

5. **Generate ER Diagram**
   - Output: `docs/architecture/diagrams/er-diagram.mmd`
   - Mermaid syntax: `erDiagram`
   - Each `DataModel` = entity with fields listed
   - Each `Relationships/Relationship` = relationship line with cardinality
   - Include primary key markers

6. **Consistency check**
   - Verify every module in diagrams exists in `architecture.xml`
   - Verify every interface in sequence diagram exists in `INTERFACE_CONTRACT.md`
   - Verify every entity in ER diagram exists in `DataModel`

7. **State update**
   - Update `STATE.md`: append to Completed Steps

8. **Human gate**
   - Present diagram summary: "已生成 4 张架构图：系统上下文图、模块交互时序图、数据流图、ER 图。请确认当前阶段输出。回复 [APPROVE] 完成，或提出修改意见。"

## Output Specification

- `docs/architecture/diagrams/system-context.mmd`
- `docs/architecture/diagrams/module-interaction.mmd`
- `docs/architecture/diagrams/data-flow.mmd`
- `docs/architecture/diagrams/er-diagram.mmd`

## Red Flags

- Do NOT invent modules not in `architecture.xml`
- Do NOT draw interfaces not in `INTERFACE_CONTRACT.md`
- Do NOT generate diagrams if `architecture.xml` is missing or unapproved
