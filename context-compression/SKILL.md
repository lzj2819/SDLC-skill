---
name: context-compression
description: Internal utility skill used by other SDLC skills to compress session context into a persistent digest. NOT for direct user invocation — called automatically by skills after completing their workflow.
---

# Context Compression

## Overview

This skill extracts the essential decisions, risks, and state from a completed skill execution and compresses them into a `Compressed Context` digest stored in `STATE.md`. The purpose is to enable fast session recovery: a new session can read the compressed context and immediately understand the project's current state without parsing all historical artifacts.

## When to Use

- **Automatically invoked** by `sdlc-requirement-analysis`, `sdlc-architecture-design`, `sdlc-architecture-validation`, `sdlc-design-review`, `sdlc-project-scaffolding`, `sdlc-module-design`, and `sdlc-iteration-planning` as their final step before the human gate.
- Do NOT invoke directly unless the user explicitly asks to "compress context" or "summarize project state".

## Input

- `STATE.md` (current state, including existing Compressed Context if any)
- The primary output artifact of the skill that just completed (e.g., `PRD.md`, `architecture.xml`, `VALIDATION_REPORT.md`)
- `DECISION_LOG.md` (recent entries)

## Workflow

1. **Read existing compressed context**
   - If `STATE.md` has a `Compressed Context` section, read it
   - If missing, start fresh

2. **Extract key facts from the completed skill**
   - Identify the top 3 decisions made in this skill execution
   - Identify the top 2 risks or pitfalls discovered
   - Identify any scope boundary changes
   - Identify the current phase and next action

3. **Generate digest**
   - Format: 200 words maximum, structured as bullet points
   - Each bullet follows: `[DecisionID]: [What] → [Why] → [Risk]`
   - Include: project name, selected pattern, module registry summary, current iteration
   - Avoid: full sentences, redundant details, file paths, code snippets

4. **Update STATE.md**
   - Overwrite the `Compressed Context` section with the new digest
   - Append a new entry to `Artifact Index` with the latest artifact's path, date, and one-line digest
   - Do NOT modify Immutable Goal, Completed Steps, or Known Pitfalls

5. **Update DecisionDigest list**
   - In `STATE.md`, maintain a `DecisionDigest` list (if not present, create it)
   - Append each new decision as: `[YYYY-MM-DD] [DecisionID]: [One-line summary]`
   - Keep only the last 20 entries; truncate older ones

## Output Specification

- Updated `STATE.md` with refreshed `Compressed Context`
- Updated `STATE.md` `Artifact Index`
- Updated `STATE.md` `DecisionDigest` list

## Example Compressed Context

```markdown
## Compressed Context
- **Project**: AI Legal Assistant v1.0
- **Pattern**: Microservices + BFF
- **Key Decisions**: [arch-dec-0001] Hexagonal for core domain (isolate LLM provider); [arch-dec-0002] BFF for mobile/web (team autonomy)
- **Known Pitfalls**: Auth service is SPOF; Redis session TTL undefined; LLM latency unbounded
- **Module Registry**: UserService(scaffolded), CaseService(design), PaymentService(pending)
- **Current Iteration**: Iteration 2 (add payment module)
```

## Red Flags

- Do NOT exceed 200 words in the compressed context
- Do NOT include file paths or code snippets
- Do NOT delete older compressed contexts — overwrite the section
- Do NOT compress if the skill execution failed or was aborted
