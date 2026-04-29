# Context Management Protocol

This document defines how DevForge skills load artifacts to stay within context window limits while preserving critical information.

## Layered Summary Architecture

### Level 1: Global Compressed Context (200 words max)
- Stored in `STATE.md` Compressed Context section
- Contains: project name, pattern, top 3 decisions, top 3 risks, module registry summary

### Level 2: Module Micro-Digests (50 words per module)
- Stored in `STATE.md` Module Registry `digest` field
- Contains: module responsibility, component count, interface count, key constraint

### Level 3: Decision Index (1 line per decision)
- Stored in `STATE.md` DecisionDigest list
- Format: `[YYYY-MM-DD] [ID]: One-line summary → see DECISION_LOG.md#{id}`

## Artifact Loading Rules per Skill

| Skill | Required (full load) | Optional (summary if context tight) |
|-------|---------------------|-------------------------------------|
| `devforge-requirement-analysis` | STATE.md (Immutable Goal only) | — |
| `devforge-architecture-design` | PRD.md, STATE.md, DECISION_LOG.md, references/architecture-patterns.md | Previous architecture.xml (if refactor) |
| `devforge-architecture-validation` | architecture.xml, INTERFACE_CONTRACT.md, PRD.md | VALIDATION_REPORT.md (previous) |
| `devforge-design-review` | PRD.md, STATE.md, DECISION_LOG.md, ARCHITECTURE.md, architecture.xml, INTERFACE_CONTRACT.md | VALIDATION_REPORT.md |
| `devforge-project-scaffolding` | PRD.md, STATE.md, ARCHITECTURE.md, architecture.xml, INTERFACE_CONTRACT.md | DESIGN_REVIEW.md (issue list only), VALIDATION_REPORT.md |
| `devforge-module-design` | PRD.md, architecture.xml, INTERFACE_CONTRACT.md, DECISION_LOG.md, STATE.md | Other module-architecture.xml files |
| `devforge-iteration-planning` | PRD.md, STATE.md, architecture.xml, INTERFACE_CONTRACT.md, all module-prd.md | — |
| `devforge-visualization` | architecture.xml, module-level XMLs (if available) | PRD.md (user stories only) |
| `devforge-ops-ready` | architecture.xml, STATE.md | — |
| `devforge-debug-assistant` | STATE.md, repo-index.md, component-spec.xml (target only), test output | Other component-spec.xml files |

## Context Truncation Strategy

When total loaded artifact token estimate exceeds thresholds:

### Threshold 1: > 50,000 tokens
- Load all Required artifacts in full
- Load Optional artifacts as summaries only (path + last-modified + 1-sentence digest)

### Threshold 2: > 150,000 tokens
- Load only the 2 most critical Required artifacts in full (STATE.md + current skill's primary input)
- Load all other artifacts as summaries only
- Log what was truncated to STATE.md Known Pitfalls

### Summary Format for Optional Artifacts
```
{filename} | Last: {YYYY-MM-DD} | Digest: {1-sentence summary}
```

## Cross-Session Recovery Protocol

1. New session reads `STATE.md` Compressed Context first
2. Reads Artifact Index to identify which artifacts exist
3. Loads Required artifacts based on current skill's needs
4. If an artifact is marked as modified within the last session but not yet validated, load it in full regardless of threshold
