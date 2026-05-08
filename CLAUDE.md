# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is **DevForge SDLC Skill Chain v1.3**, a Claude Code skill chain that models a complete AI-driven software development lifecycle. It is not a traditional software project — the "code" consists of markdown-based skill definitions (`.md` files with YAML frontmatter) that Claude Code loads and interprets.

The chain covers 10 core stages from product ideation to production deployment, built on two methodologies:
- **VCMF** (Vibe Coding Maturity Framework) — 5 core principles: Design as Contract, Interface as Boundary, Reality as Baseline, State as Responsibility, XML as Authority
- **DIVE** (Design-Implement-Verify-Evolve) — the cyclic workflow mapped across the stages

## Validation & Distribution Commands

The project has no traditional build, lint, or test suite. Validation is done via scripts:

```bash
# Validate SKILL.md frontmatter across all skills (15 skills as of v1.3)
python scripts/package-plugin.py --mode all --output ./dist
# (Fails early if any SKILL.md lacks proper YAML frontmatter with name/description fields)

# Validate XML architecture artifacts for well-formedness, ref integrity, coupling consistency
./scripts/architecture-ci.sh [docs/architecture/]
# Requires: xmllint, bash. Default arch dir is docs/architecture.

# Deep XML cross-reference verification (ModuleDetail refs, Coupling targets, StateModel, Interface Consistency)
python scripts/xml-sync.py --verify-only [ARCH_DIR]

# Propagate system-level interface changes down to module Constraints
python scripts/xml-sync.py --sync [ARCH_DIR]
```

## Skill Chain Architecture

### Stage Flow (v1.3)

The chain uses **Workflow-Aggregate Decomposition**: each skill is the same "thinker" unfolding a complex problem from a different dimension, not a role relay race.

```
1. requirement-analysis (Design)
    ↓ [APPROVE]
2. architecture-design (Design deepen)
    ↓ [APPROVE]
    ┌──────────────────┬──────────────────┐
    ↓                  ↓                  ↓
3a. architecture-    3b. design-review   ← Both run by default
    validation          (adversarial)
    (technical)         inspection
    ↓ [APPROVE]         ↓ [APPROVE/FIX]
    └──────────────────┴──────────────────┘
                      ↓ [APPROVE]
4. project-scaffolding (Implement)
    ↓ [APPROVE]
5. module-design (Design, module-level)  ← Strictly after scaffolding
    ↓ [APPROVE / NEXT MODULE / MODULE_BATCH]
6. test-execution (Verify)  ← [TEST]
    ↓ [APPROVE / DEBUG]
7. iteration-planning (Evolve)  ← Loops back to 3a/3b if breaking
```

| Stage | Skill Directory | Trigger | DIVE Phase |
|-------|----------------|---------|------------|
| 1 | `devforge-requirement-analysis/` | User says "I want to build..." | Design |
| 2 | `devforge-architecture-design/` | `[APPROVE]` after PRD | Design |
| 3a | `devforge-architecture-validation/` | `[APPROVE]` after architecture | Verify |
| 3b | `devforge-design-review/` | `[DESIGN_REVIEW]` after validation | Verify |
| 4 | `devforge-project-scaffolding/` | `[APPROVE]` after validation/review | Implement |
| 5 | `devforge-module-design/` | `[MODULE {id}]` / `[MODULE_BATCH {ids}]` | Design |
| 6 | `devforge-test-execution/` | `[TEST]` | Verify |
| 7 | `devforge-iteration-planning/` | New requirements after scaffolding | Evolve |
| 8 | `devforge-visualization/` | `[VISUALIZE]` | — |
| 9 | `devforge-ops-ready/` | `[OPS]` | — |
| 10 | `devforge-debug-assistant/` | `[DEBUG]` or test failure | — |

Plus: `context-compression/` (utility), `devforge-security-audit/` (security scan), `extensions/` (domain-specific overlays: ai-agent-design, data-pipeline-design, mobile-app-design).

**Key flow rules:**
- Stages 3a and 3b both run by default (no longer mutually exclusive). User can `[SKIP_REVIEW]` or `[SKIP_VALIDATION]`.
- Stage 5 (`module-design`) requires `scaffolding_completed` — not `architecture_design_completed`.
- Stage 7 (`iteration-planning`) loops back to 3a/3b if `verification_gate::required` is true (breaking changes).

### Three-Layer XML Architecture Authority

The chain enforces **XML as Authority** — all generated code must trace back to XML specs:

- **System Layer**: `architecture.xml` — modules, interfaces, data models, state model, decision trace
- **Module Layer**: `module-architecture.xml` — per-module decomposition, constraints, module-level state model
- **Component Layer**: `component-spec.xml` — per-component function signatures, dependencies, error handling, file paths

Schema definitions are in `references/xml-schemas.md`. Sync rules between XML and code are in `docs/sync-rules.md`.

### Context Management Protocol

Skills load artifacts according to a tiered strategy defined in `references/context-management-protocol.md`:

- **Level 1**: Global Compressed Context (200 words max) in `STATE.md`
- **Level 2**: Module Micro-Digests (50 words per module) in `STATE.md` Module Registry
- **Level 3**: Decision Index (1 line per decision) in `STATE.md` DecisionDigest

Each skill declares Required vs Optional artifacts. When context exceeds thresholds (>50k or >150k tokens), Optional artifacts load as summaries only.

### STATE.md as Central State File

`STATE.md` (template in `devforge-state.md`) is the single source of truth for cross-session continuity. It has 11 sections including Immutable Goal (never overwritten), Completed Steps (append-only), Module Registry, Iteration History, Compressed Context, Artifact Index, Error Log, and Intervention Log. The file path varies: `skill/artifacts/STATE.md` during initial development, `docs/architecture/system/STATE.md` during incremental iteration.

### Human Gate Commands

Every skill pauses for explicit human approval before proceeding. The supported commands are documented in all skills:

**Core commands:**
- `[APPROVE]` — proceed to next stage
- `[PAUSE]`, `[ROLLBACK]`, `[EXPLAIN]`, `[EDIT]`, `[SKIP]`, `[INJECT]`, `[SECURITY_AUDIT]`

**v1.3 extended commands** (defined in `skill/tools/intervention-checkpoint.md`):
- `[FIX <issue_id>]` — Enter fix sub-mode (design-review only)
- `[APPLY]` — Apply generated diff and trigger re-validation
- `[FORCE_APPROVE]` — Skip non-blocking validation failures
- `[SKIP_REVIEW]` — Skip design-review after validation passes
- `[DESIGN_REVIEW]` — Trigger design-review after validation passes
- `[VALIDATE]` — Re-run architecture-validation after iteration
- `[TEST]` — Trigger test-execution skill

**Module-level commands:**
- `[MODULE {id}]`, `[MODULE_BATCH {ids}]`, `[NEXT MODULE]`, `[VISUALIZE]`, `[OPS]`, `[DEBUG]`

### Skill File Structure

Every skill directory contains a single `SKILL.md` with:
1. YAML frontmatter (`name`, `description`)
2. Overview and VCMF checkpoints table
3. When to Use / Precondition Check
4. Language Adaptation rules (English for system instructions, user's language for gate messages)
5. Workflow steps
6. Human gate pause points

### Key Reference Documents

| File | Purpose |
|------|---------|
| `devforge-design.md` | Skill decomposition design v1.3 — the authoritative architecture of the chain itself |
| `devforge-state.md` | STATE.md template with 11-section specification |
| `references/architecture-patterns.md` | 10 architecture patterns with evaluation dimensions and selection matrix |
| `references/xml-schemas.md` | Three-layer XML schema definitions |
| `references/context-management-protocol.md` | Token thresholds and artifact loading rules per skill |
| `references/system-prompt-template.md` | Global role definition + VCMF constraints injected into all skills |
| `references/validation-scripts-manifest.md` | Maps script capabilities to XML schema rules, documents known gaps |
| `docs/sync-rules.md` | Bidirectional sync rules between XML, DDL, OpenAPI, and code |
| `skill/tools/artifact-manager.md` | CRUD-Append mode for generated artifacts |
| `skill/tools/error-tracing.md` | TraceID format and error logging protocol |
| `skill/tools/intervention-checkpoint.md` | Human intervention logging protocol + extended command definitions (v1.3) |

### Environment Configuration

`.env.example` defines optional API keys and credentials for enhanced capabilities (LLM validation, database scaffolding, cloud deployment). Skills degrade gracefully when these are absent. No configuration is required for basic operation.
