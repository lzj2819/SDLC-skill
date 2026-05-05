---
name: devforge-requirement-analysis
description: Use when a user provides an initial product idea or goal and needs a structured PRD with user stories, acceptance criteria, interface boundaries, and functional requirements
---

# DevForge Requirement Analysis

## Overview

Transform a raw product idea into a structured, reviewable PRD. This skill combines methodology alignment and PRD construction into one continuous workflow. It also seeds the Decision Log to prevent requirement drift across phases.

## VCMF Checkpoints

| Principle | Checkpoint in this Skill |
|-----------|--------------------------|
| Design as Contract | PRD must define closed-loop success metrics and scope boundaries |
| Interface as Boundary | Identify and list all cross-module interaction points in the PRD |
| Reality as Baseline | Acceptance criteria must be observable and testable |
| State as Responsibility | Document who owns each business state mentioned in user stories |

## When to Use

- The user says "I want to build..." or provides a vague product concept
- You need to produce a PRD before any architecture or code work can begin
- Do NOT use if a PRD already exists and has been approved

## Precondition Check

Read `skill/artifacts/STATE.md` if it exists. If `phase` is already `requirement_analysis_completed` or later, confirm with the user whether to overwrite or continue from the existing artifact.

## Language Adaptation

- System instructions and constraints in this skill are in English for maximum model compliance
- User-facing gate messages, summaries, and explanations use the same language as the user's most recent input
- If the user writes in Chinese, respond in Chinese. If English, respond in English

## Elicitation Principles

Apply these throughout steps 3–5:

- **Codebase-first**: If a question can be answered by reading existing code, prior PRDs, or `CONTEXT.md`, read first — do not ask the user.
- **One question at a time**: Ask one question, provide your recommended answer with a one-sentence rationale, wait for the user's confirmation or correction before continuing. When an answer reveals dependent questions, follow that branch instead of marching through a fixed list.
- **Sharpen language inline**: When the user uses ambiguous or overloaded terms (e.g., "user" vs "customer", "order" vs "transaction") or unquantified adjectives ("fast", "user-friendly"), propose a precise definition or quantification immediately, register it in the PRD's Terminology section — do not defer to step 8.
- **Capture decisions immediately**: Whenever a real trade-off is made, append it to `DECISION_LOG.md` right then — do not batch decisions for step 7.

## Workflow

1. **Methodology alignment**
   - Explain the "four-dimensional deduction" (Why / What / How / Modules)
   - State the five PRD quality standards (clear logic, closed loop, visuals, traceability, prioritization)
   - Surface edge-case questions (malicious traffic, third-party downtime, data consistency)

2. **State initialization**
   - Read `skill/artifacts/STATE.md` if it exists
   - If starting fresh, create `STATE.md` and populate the **Immutable Goal** section with the user's product idea, success metrics, and scope boundary
   - If `STATE.md` exists and `phase` is already `requirement_analysis_completed` or later, confirm with user whether to overwrite or continue

3. **Context gathering**
   - Following the Elicitation Principles, ask targeted questions about user personas, pain points, and business value — one at a time
   - For each question, provide your recommended answer with reasoning so the user can confirm or correct rather than answer from scratch
   - Cover at minimum: user personas, primary pain points, business value, and scope boundaries — follow conditional branches when an answer reveals them

4. **Cross-module interaction mapping**
   - Based on the gathered context, identify all cross-module or cross-system interactions
   - List them in a dedicated section of the PRD

5. **PRD generation**
   - Produce a structured PRD containing:
     - Project background and goals (Why + success metrics)
     - Target user personas and scenarios
     - Terminology (canonical definitions captured during elicitation, including any ambiguities resolved)
     - User stories with acceptance criteria (Given-When-Then or checklist)
     - Functional requirements graded P0 / P1 / P2
     - Non-functional requirements (performance, security, compliance)
     - Cross-module interaction points
     - Main process flow and fallback strategies
   - Write the PRD to `skill/artifacts/PRD.md`

6. **Requirement Traceability Matrix (RTM) generation**
   - After PRD is complete, generate `skill/artifacts/RTM.md`
   - RTM structure:
     - Columns: Requirement ID, User Story, Acceptance Criteria, Architecture Module, Component, Test Case ID, Status
     - Each P0/P1 requirement MUST have at least one mapped Module and Component
     - Status values: pending / designed / implemented / tested / verified
   - Initial status for all entries: `pending`
   - RTM is updated by subsequent skills:
     - `devforge-architecture-design` → update Architecture Module column
     - `devforge-module-design` → update Component column
     - `devforge-project-scaffolding` → update Test Case ID column
     - `devforge-architecture-validation` → update Status to verified

7. **Decision Log consolidation**
   - `DECISION_LOG.md` should already contain entries written inline during steps 3–5 (per Elicitation Principles)
   - Review the log and keep ONLY entries that satisfy at least one of:
     - **Hard to reverse**: changing the decision later would require significant rework (e.g., redrawing P0 scope)
     - **Surprising without context**: a future reader of the PRD would wonder "why was it scoped this way?"
     - **Backed by a real trade-off**: there were genuine alternatives, and the rejection rationale matters
   - Remove entries that fail all three — they belong in the PRD body or chat history, not the decision log
   - Each surviving entry must include: date, decision, reasoning, and rejected alternatives (when applicable)

8. **Self-validation: PRD completeness**
   - Before proceeding, verify PRD and RTM quality with automated checks:
     - **Section completeness**: Confirm all required sections exist in `PRD.md`: Project Background, User Personas, Terminology, User Stories, Functional Requirements (P0/P1/P2), Non-Functional Requirements, Cross-Module Interactions, Main Process Flow, Fallback Strategies
     - **Acceptance criteria observability**: Scan all acceptance criteria for unquantified adjectives ("fast", "user-friendly", "seamless", "robust"). If found, add quantified metrics or remove the adjective.
     - **Traceability coverage**: Verify every P0 and P1 requirement in `PRD.md` has a corresponding row in `RTM.md` with non-empty Architecture Module and Component columns (or mark as `pending` if not yet designed)
     - **Cross-module interaction consistency**: Verify that every interaction point listed in "Cross-Module Interactions" is referenced by at least one user story or functional requirement
   - If any check fails, fix the PRD or RTM before proceeding

9. **State update**
   - Read `skill/artifacts/STATE.md`
   - Write the **Immutable Goal** section if not already present (verbatim user idea + success metrics + scope boundary)
   - Append to **Completed Steps**: `[YYYY-MM-DD HH:MM] devforge-requirement-analysis: Locked P0/P1/P2 scope. Key decisions: [list]`
   - Set `phase: requirement_analysis_completed`
   - Set DIVE `Design: in_progress`, others `pending`
   - Update artifact statuses

10. **Human gate**
   - Present a concise PRD summary (3-5 bullets)
   - Say exactly: "PRD 和决策日志已生成。请确认当前阶段输出。回复 [APPROVE] 进入架构设计阶段，或提出修改意见。"
   - Do NOT proceed until the user replies [APPROVE]

<HARD-GATE>
Do NOT proceed to architecture-design, write any code, or scaffold any project until the user replies [APPROVE].
</HARD-GATE>

## Output Specification

- `skill/artifacts/PRD.md`
- `skill/artifacts/RTM.md` (Requirement Traceability Matrix)
- `skill/artifacts/DECISION_LOG.md`
- Must include P0/P1/P2 grading
- Must include acceptance criteria for every user story
- Must include at least one abnormal-path fallback
- Must include a "Cross-Module Interactions" section
- Must include a "Terminology" section capturing canonical definitions resolved during elicitation
- PRD describes **what users perceive and accept** — do NOT specify implementation choices (database, framework, caching, deployment topology); those belong to architecture-design

## Red Flags

- Do NOT skip the human gate
- Do NOT generate architecture or code during this phase
- Do NOT proceed without writing `PRD.md` and `DECISION_LOG.md`
- Do NOT lose edge-case analysis from the original conversation
- Do NOT let acceptance criteria contain unobservable adjectives like "fast" or "user-friendly" without quantification
- Do NOT batch elicitation questions when one-at-a-time would surface dependent branches
- Do NOT specify implementation choices (databases, frameworks, infrastructure) in the PRD body
- Do NOT defer terminology disputes or DECISION_LOG entries to the end of the workflow
