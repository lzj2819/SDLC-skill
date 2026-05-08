# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is **DevForge SDLC Skill Chain v1.3**, a Claude Code skill chain that models a complete AI-driven software development lifecycle. It is not a traditional software project — the "code" consists of markdown-based skill definitions (`.md` files with YAML frontmatter) that Claude Code loads and interprets.

The chain covers 10 core stages from product ideation to production deployment, built on two methodologies:
- **VCMF** (Vibe Coding Maturity Framework) — 5 core principles: Design as Contract, Interface as Boundary, Reality as Baseline, State as Responsibility, XML as Authority
- **DIVE** (Design-Implement-Verify-Evolve) — the cyclic workflow mapped across the stages

## Development Commands

This project has no traditional build system. Validation and packaging are done via scripts:

### Validation

```bash
# Validate all SKILL.md frontmatter (fails if any skill lacks proper YAML frontmatter)
python scripts/package-plugin.py --mode all --output ./dist

# Validate XML artifacts for well-formedness and reference integrity
./scripts/architecture-ci.sh [docs/architecture/]
# Requires: xmllint, bash.

# Deep XML cross-reference verification
python scripts/xml-sync.py --verify-only [ARCH_DIR]

# Propagate system-level interface changes down to module Constraints
python scripts/xml-sync.py --sync [ARCH_DIR]
```

### Packaging & Distribution

```bash
# Package as plugin ZIP + individual .skill files
python scripts/package-plugin.py --mode all --output ./dist

# Output:
#   ./dist/DevForge-chain-v{version}.zip   (full plugin)
#   ./dist/skills/{name}.skill              (individual skill packages)
```

### Installer Maintenance

When adding or renaming a skill directory, update all four installer scripts:
- `install.sh` — `coreSkills` array
- `install.ps1` — `$coreSkills` array
- `uninstall.sh` — `skills` array
- `uninstall.ps1` — `$skills` array

## Skill Chain Architecture

### Stage Flow (v1.3)

The chain uses **Workflow-Aggregate Decomposition**: each skill is the same "thinker" unfolding a complex problem from a different dimension, not a role relay race.

```
1. requirement-analysis (Design)
    ↓ [APPROVE]
2. architecture-design (Design deepen)
    ↓ [APPROVE]
    ┌──────────────────┬──────────────────┬──────────────────┐
    ↓                  ↓                  ↓                  ↓
3a. architecture-    3b. design-review   3c. security-audit (optional)
    validation          (adversarial)       (security scan)
    (technical)         inspection          (optional)
    ↓ [APPROVE]         ↓ [APPROVE/FIX]     ↓ [APPROVE/SKIP]
    └──────────────────┴──────────────────┴──────────────────┘
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
| 3c | `devforge-security-audit/` | `[SECURITY_AUDIT]` after design-review | Verify |
| 4 | `devforge-project-scaffolding/` | `[APPROVE]` after validation/review | Implement (infrastructure) |
| 5 | `devforge-module-design/` | `[MODULE {id}]` / `[MODULE_BATCH {ids}]` | Design + Implement (code skeleton) |
| 6 | `devforge-test-execution/` | `[TEST]` | Verify |
| 7 | `devforge-iteration-planning/` | New requirements after scaffolding | Evolve |
| 8 | `devforge-visualization/` | `[VISUALIZE]` | — |
| 9 | `devforge-ops-ready/` | `[OPS]` | — |
| 10 | `devforge-debug-assistant/` | `[DEBUG]` or test failure | — |

Plus: `skill/tools/context-compression.md` (utility tool — invoked by other skills), `devforge-security-audit/` (security scan), `extensions/` (domain-specific overlays: ai-agent-design, data-pipeline-design, mobile-app-design).

**Key flow rules:**
- Stages 3a and 3b both run by default. Stage 3c (security-audit) is optional but recommended. User can `[SKIP_REVIEW]` or `[SKIP_VALIDATION]`.
- Stage 5 (`module-design`) requires `scaffolding_completed` — not `architecture_design_completed`.
- Stage 7 (`iteration-planning`) loops back to 3a/3b if `verification_gate::required` is true (breaking changes).

### Stage 3: Triple Verification Mechanism

| Dimension | 3a. architecture-validation | 3b. design-review | 3c. security-audit |
|-----------|---------------------------|-------------------|-------------------|
| **Purpose** | Verify "design is correctly specified" | Verify "design has no gaps/errors" | Verify "design has no security flaws" |
| **Perspective** | Technical consistency (engineer view) | Adversarial review (critic view) | Security scan (auditor view) |
| **Input** | architecture.xml, INTERFACE_CONTRACT.md | PRD, architecture.xml, DECISION_LOG | architecture.xml, code, dependencies |
| **Check items** | XML Schema compliance, interface consistency, PRD traceability | Security, operability, scalability | Vulnerabilities, secrets, compliance |
| **Output** | VALIDATION_REPORT.md (PASS/FAIL) | DESIGN_REVIEW.md (issue list, no PASS/FAIL) | SECURITY_AUDIT_REPORT.md (risk levels) |
| **Result** | Fail must be fixed before continuing | Issues can be accepted, deferred, or fixed | Critical issues must be fixed before deployment |
| **Analogy** | Compiler type checking | Code review | Security penetration test |

**Relationship**: validation ensures "design documents are self-consistent", design-review ensures "design decisions are correct", security-audit ensures "design is secure". The three complement each other and cannot substitute for one another.

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

`STATE.md` (template in `devforge-state.md`) is the single source of truth for cross-session continuity. It has 11 sections including Immutable Goal (never overwritten), Completed Steps (append-only), Module Registry, Iteration History, Compressed Context, Artifact Index, Error Log, and Intervention Log. The file path varies: `PROJECT_SCAFFOLD/docs/architecture/system/STATE.md`.

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

## Skill Maintenance Rules

When modifying any skill, check for cross-file dependencies:

| If you change... | You must also update... |
|:---|:---|
| Add/remove a skill directory | `install.sh`, `install.ps1`, `uninstall.sh`, `uninstall.ps1` (skill arrays); `README.md` (stage table); `.claude-plugin/marketplace.json` (plugin count) |
| Add/remove/rename a tool spec in `skill/tools/` | All skills that reference the tool spec |
| Add a new human gate command | `skill/tools/intervention-checkpoint.md` (canonical command spec) + all skills that use the command |
| Add a new artifact type | `skill/tools/artifact-manager.md` (update strategy table) + `devforge-state.md` (artifact index section) |
| Modify STATE.md structure | `devforge-state.md` (template) + all skills that read/write STATE.md |
| Change stage flow or precondition | All downstream skills' precondition checks + `devforge-design.md` (flow diagram) + `README.md` (stage table) + `skill/tools/precondition-checker.md` (phase map) |
| Add a new VCMF checkpoint column | All existing skills' VCMF tables + `references/system-prompt-template.md` + `skill/tools/validation-engine.md` (check library) |

### Adding a New Skill

1. Create `{skill-name}/SKILL.md` with valid YAML frontmatter (`name`, `description`)
2. Add VCMF checkpoints table (align with existing skills, include `Inherited from` column)
3. Add Precondition Check section (reference `skill/tools/precondition-checker.md` with acceptable phases)
4. Add Language Adaptation section (reference `skill/tools/language-adaptation.md`)
5. Define workflow steps
6. Add Self-validation section (reference `skill/tools/validation-engine.md` for common checks, add skill-specific checks)
7. Add State Update section (reference `skill/tools/state-updater.md`)
8. Add Human gate with complete command list
9. Add `<HARD-GATE>` if this is a required (non-optional) stage
10. Add to `devforge-design.md` flow diagram and stage table
11. Update `README.md` stage table
12. Update all four installer scripts
13. Update `skill/tools/precondition-checker.md` phase map if this skill introduces new phase transitions
14. Run `python scripts/package-plugin.py --mode all` to validate frontmatter

### Project Directory Structure

```
DevForge/
├── devforge-*/           # Skill directories (each contains one SKILL.md)
├── skill/tools/          # Shared tool specifications referenced by skills
│   ├── precondition-checker.md
│   ├── language-adaptation.md
│   ├── validation-engine.md
│   ├── state-updater.md
│   ├── context-compression.md
│   ├── artifact-manager.md
│   ├── error-tracing.md
│   └── intervention-checkpoint.md
├── references/           # Shared reference documents (schemas, patterns, protocols)
├── extensions/           # Domain-specific overlay skills (ai-agent-design, etc.)
├── scripts/              # Validation and packaging scripts
└── .claude-plugin/       # Plugin metadata
```

### Skill File Structure

Every skill directory contains a single `SKILL.md` with:
1. YAML frontmatter (`name`, `description`)
2. Overview and VCMF checkpoints table (with `Inherited from` column)
3. When to Use / Precondition Check (references `skill/tools/precondition-checker.md`)
4. Language Adaptation (references `skill/tools/language-adaptation.md`)
5. Workflow steps
6. Self-validation (references `skill/tools/validation-engine.md` for common checks)
7. State Update (references `skill/tools/state-updater.md`)
8. Human gate pause points

### Key Reference Documents

| File | Purpose |
|------|---------|
| `DevForge.md` | Original monolithic Chinese design document (reference-only, pre-decomposition) |
| `devforge-design.md` | Skill decomposition design v1.3 — the authoritative architecture of the chain itself |
| `devforge-state.md` | STATE.md template with 12-section specification (includes Quality Gates) |
| `references/architecture-patterns.md` | 10 architecture patterns with evaluation dimensions and selection matrix |
| `references/xml-schemas.md` | Three-layer XML schema definitions |
| `references/context-management-protocol.md` | Token thresholds and artifact loading rules per skill |
| `references/system-prompt-template.md` | Global role definition + VCMF constraints injected into all skills |
| `references/validation-scripts-manifest.md` | Maps script capabilities to XML schema rules, documents known gaps |
| `docs/sync-rules.md` | Bidirectional sync rules between XML, DDL, OpenAPI, and code |
| `skill/tools/artifact-manager.md` | CRUD-Append mode for generated artifacts |
| `skill/tools/error-tracing.md` | TraceID format and error logging protocol |
| `skill/tools/intervention-checkpoint.md` | Human intervention logging protocol + extended command definitions (v1.3) |
| `skill/tools/precondition-checker.md` | Standardized precondition check template + phase transition map |
| `skill/tools/language-adaptation.md` | Language handling rules (English system instructions, user language for gates) |
| `skill/tools/validation-engine.md` | Self-validation framework + common checks library (9 check IDs) |
| `skill/tools/state-updater.md` | Standardized STATE.md update template + phase transition map |
| `skill/tools/context-compression.md` | Session context compression into STATE.md Compressed Context |

### Environment Configuration

`.env.example` defines optional API keys and credentials for enhanced capabilities (LLM validation, database scaffolding, cloud deployment). Skills degrade gracefully when these are absent. No configuration is required for basic operation.

## Version Bump Checklist

When releasing a new version (e.g., v1.2 → v1.3):

1. Update `.claude-plugin/plugin.json` → `version`
2. Update `.claude-plugin/marketplace.json` → `version` and `description`
3. Update `README.md` → version header and footer
4. Update `CLAUDE.md` → version references in stage tables
5. Run `python scripts/package-plugin.py --mode all --output ./dist` (must pass)
6. Tag the release: `git tag v1.3.0`
