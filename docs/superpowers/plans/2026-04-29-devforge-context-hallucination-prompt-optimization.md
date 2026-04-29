# DevForge Context, Hallucination & Prompt Quality Optimization

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Optimize DevForge v1.2 skills for context management efficiency, hallucination control, and prompt quality by adding reference-layer templates, self-validation steps, language adaptation rules, and tool search verification.

**Architecture:** References-layer unification (3 new files in `references/`) + incremental skill modifications (11 files). Each skill gains self-validation workflow steps and context-loading protocol compliance.

**Tech Stack:** Markdown, Bash, Python (for script validation)

---

## File Structure

| File | Action | Responsibility |
|------|--------|---------------|
| `references/system-prompt-template.md` | Create | Global role definition and constraints for all DevForge skills |
| `references/context-management-protocol.md` | Create | Artifact loading priority and context truncation rules per skill |
| `references/validation-scripts-manifest.md` | Create | Scripts capability mapping and gap documentation |
| `devforge-state.md` | Modify | Enhanced Module Registry digests |
| `devforge-architecture-design/SKILL.md` | Modify | DDL/OpenAPI self-validation + tool search verification |
| `devforge-project-scaffolding/SKILL.md` | Modify | repo-index.md generation + syntax validation |
| `devforge-requirement-analysis/SKILL.md` | Modify | Self-validation + language adaptation |
| `devforge-architecture-validation/SKILL.md` | Modify | Self-validation + language adaptation |
| `devforge-design-review/SKILL.md` | Modify | Self-validation + language adaptation |
| `devforge-module-design/SKILL.md` | Modify | Self-validation + language adaptation |
| `devforge-iteration-planning/SKILL.md` | Modify | Self-validation + language adaptation |
| `devforge-visualization/SKILL.md` | Modify | Language adaptation |
| `devforge-ops-ready/SKILL.md` | Modify | Language adaptation + tool search verification |
| `devforge-debug-assistant/SKILL.md` | Modify | Language adaptation + context protocol reference |

---

## Task 1: Create references/system-prompt-template.md

**Files:**
- Create: `references/system-prompt-template.md`
- Test: Read back to verify content

- [ ] **Step 1: Verify parent directory exists**

Run: `ls -la references/`
Expected: Directory exists with `architecture-patterns.md` and `xml-schemas.md`

- [ ] **Step 2: Write the system prompt template**

```markdown
# DevForge System Prompt Template

## Role
You are a senior software engineering agent operating within the DevForge skill chain. You follow the VCMF (Vibe Coding Maturity Framework) principles and the DIVE (Design-Implement-Verify-Evolve) cycle.

## Global Constraints
1. **XML as Authority**: All generated code signatures MUST match `component-spec.xml`. All generated DDL MUST match `DataModel` nodes.
2. **Human-in-the-Loop**: NEVER proceed past a phase without explicit user approval (`[APPROVE]`). Auto-jumping is forbidden.
3. **Incremental Evolution**: Existing framework stays; only additions and targeted modifications are allowed.
4. **Traceability**: Every generated file MUST be traceable back to a PRD requirement or architecture decision.
5. **Reality as Baseline**: Mock data validates flow; real environments validate function.

## State Management
- Read `STATE.md` at the start of every skill invocation
- Update `STATE.md` before every human gate
- If prerequisite artifacts are missing, STOP and instruct the user to run the prerequisite skill

## Context Loading Protocol
- Follow `references/context-management-protocol.md` for artifact loading priority
- When total context exceeds safe limits, load Required artifacts in full and Optional artifacts as summaries only
- Never load unrelated module's `component-spec.xml` unless explicitly needed

## Output Quality Standards
- All interface definitions MUST include: method name, input schema, output schema, error codes
- All state definitions MUST include: location, owner, consumer, lifecycle (create/read/update/delete/cleanup)
- All generated code MUST be syntactically valid for the target language
```

- [ ] **Step 3: Verify the file was written correctly**

Run: `head -n 5 references/system-prompt-template.md`
Expected: Shows "# DevForge System Prompt Template"

Run: `grep -c "XML as Authority" references/system-prompt-template.md`
Expected: `1`

- [ ] **Step 4: Commit**

```bash
git add references/system-prompt-template.md
git commit -m "feat(references): add system prompt template with VCMF constraints

- Global role definition for DevForge skill chain
- XML as Authority, Human-in-the-Loop, Incremental Evolution constraints
- Context loading protocol reference
- Output quality standards

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Task 2: Create references/context-management-protocol.md

**Files:**
- Create: `references/context-management-protocol.md`
- Test: Read back to verify tables

- [ ] **Step 1: Write the context management protocol**

```markdown
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

### Threshold 1: > 8,000 tokens
- Load all Required artifacts in full
- Load Optional artifacts as summaries only (path + last-modified + 1-sentence digest)

### Threshold 2: > 12,000 tokens
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
```

- [ ] **Step 2: Verify the file structure**

Run: `grep -c "devforge-project-scaffolding" references/context-management-protocol.md`
Expected: `1`

Run: `grep "Threshold 2" references/context-management-protocol.md`
Expected: Shows the 12,000 token threshold rule

- [ ] **Step 3: Commit**

```bash
git add references/context-management-protocol.md
git commit -m "feat(references): add context management protocol

- Layered summary architecture (3 levels)
- Per-skill artifact loading rules for 10 skills
- Context truncation strategy with 2 thresholds (8k, 12k)
- Cross-session recovery protocol

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Task 3: Create references/validation-scripts-manifest.md

**Files:**
- Create: `references/validation-scripts-manifest.md`
- Test: Read back and cross-check with actual scripts

- [ ] **Step 1: Read actual scripts to confirm capabilities**

Run: `head -n 15 scripts/architecture-ci.sh`
Expected: Shows usage, checks list (XML well-formedness, ref integrity, Coupling targets, StateModel, ModuleDetail)

Run: `python3 scripts/xml-sync.py --help`
Expected: Shows `--verify-only` and `--sync` arguments

- [ ] **Step 2: Write the validation scripts manifest**

```markdown
# Validation Scripts Manifest

This document maps skill-document references to actual script capabilities. It serves as the single source of truth for what `scripts/` can and cannot do.

## scripts/architecture-ci.sh

**Referenced by:** `devforge-project-scaffolding/SKILL.md`, `devforge-architecture-validation/SKILL.md`

**Capabilities:**
| Check | Description | Status |
|-------|-------------|--------|
| XML well-formedness | Validates all `*.xml` files with `xmllint` | ✅ Implemented |
| Ref attribute integrity | Verifies all `ref="..."` attributes resolve to existing files | ✅ Implemented |
| Coupling target consistency | Verifies all `module="..."` in Coupling exist as Module ids | ✅ Implemented |
| StateModel completeness | Verifies all State entries have id, location, owner, lifecycle | ✅ Implemented |
| ModuleDetail references | Verifies all ModuleDetail refs point to existing module XML files | ✅ Implemented |

**Mapping to xml-schemas.md rules:**
| Script Check | xml-schemas.md Rule |
|--------------|---------------------|
| XML well-formedness | Rule 1 (ID Consistency) — partial |
| Ref attribute integrity | Rule 3 (Reference Integrity) |
| Coupling target consistency | Rule 5 (Coupling Directionality) |
| StateModel completeness | Rule 4 (State Lifecycle Completeness) |
| ModuleDetail references | Rule 3 (Reference Integrity) — module-level |

**Gap:** Script does NOT verify Rule 2 (Interface Consistency between system and module levels) or Rule 6 (DDL Schema Validity). These are covered by `xml-sync.py`.

## scripts/xml-sync.py

**Referenced by:** `devforge-iteration-planning/SKILL.md`, `devforge-project-scaffolding/SKILL.md`

**Capabilities:**
| Mode | Flag | Description | Status |
|------|------|-------------|--------|
| Verify | `--verify-only` | Check ModuleDetail refs, Coupling targets, StateModel, Module Constraints vs System Interfaces | ✅ Implemented |
| Sync | `--sync` | Verify + propagate system-level interface changes to module Constraints | ✅ Implemented |

**Mapping to xml-schemas.md rules:**
| Script Check | xml-schemas.md Rule |
|--------------|---------------------|
| ModuleDetail refs | Rule 3 (Reference Integrity) |
| Coupling targets | Rule 5 (Coupling Directionality) |
| StateModel completeness | Rule 4 (State Lifecycle Completeness) |
| Module Constraints vs System Interfaces | Rule 2 (Interface Consistency) |

**Gap:** Script does NOT verify Rule 1 (ID Consistency between layers) or Rule 6 (DDL Schema Validity). Rule 1 is typically checked by human review; Rule 6 is checked during DDL generation self-validation.

## scripts/package-plugin.py

**Referenced by:** `README.md`

**Capabilities:**
| Mode | Description | Status |
|------|-------------|--------|
| Package | Creates distributable `.skill` packages and plugin zip | ✅ Implemented |

## Known Gaps and Mitigations

| Gap | Affected Skill | Mitigation |
|-----|---------------|------------|
| architecture-ci.sh missing Interface Consistency check (Rule 2) | `devforge-project-scaffolding` | LLM performs manual check during scaffolding internal verification |
| xml-sync.py missing ID Consistency check (Rule 1) | All skills | Checked implicitly during XML generation; LLM verifies during self-validation |
| xml-sync.py missing DDL Schema Validity (Rule 6) | `devforge-architecture-design` | LLM self-validation during DDL generation step |
```

- [ ] **Step 3: Verify manifest accuracy**

Run: `grep "architecture-ci.sh" references/validation-scripts-manifest.md | head -n 3`
Expected: Shows references and capabilities table

Run: `grep "GAP" references/validation-scripts-manifest.md | wc -l`
Expected: `0` (use "Gap:" instead)

- [ ] **Step 4: Commit**

```bash
git add references/validation-scripts-manifest.md
git commit -m "feat(references): add validation scripts manifest

- Map architecture-ci.sh 5 checks to xml-schemas.md rules
- Map xml-sync.py --verify-only and --sync to rules
- Document known gaps and mitigations
- Confirm all script capabilities against actual implementations

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Task 4: Modify devforge-state.md

**Files:**
- Modify: `devforge-state.md`
- Test: grep for added fields

- [ ] **Step 1: Read current Module Registry section**

Run: `grep -n "module_registry:" devforge-state.md`
Expected: Shows line number of Module Registry section

- [ ] **Step 2: Add digest field to Module Registry template**

Edit `devforge-state.md`. Find:

```yaml
module_registry:
  - id: UserService
    status: scaffolded          # [pending | design_completed | scaffolded]
    path: modules/UserService/
    owner: team-auth
    interface_version: "1.0.0"
```

Replace with:

```yaml
module_registry:
  - id: UserService
    status: scaffolded          # [pending | design_completed | scaffolded]
    path: modules/UserService/
    owner: team-auth
    interface_version: "1.0.0"
    digest: "Auth domain: JWT + RBAC, 3 components, 8 interfaces"  # 50-word max micro-summary
```

- [ ] **Step 3: Verify the digest field was added**

Run: `grep "digest:" devforge-state.md`
Expected: Shows the digest field in the Module Registry example

- [ ] **Step 4: Commit**

```bash
git add devforge-state.md
git commit -m "feat(state): add module digest field for layered context

- Module Registry entries gain 50-word max digest field
- Supports layered summary architecture (Level 2 micro-digests)

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Task 5: Modify devforge-architecture-design/SKILL.md

**Files:**
- Modify: `devforge-architecture-design/SKILL.md`
- Test: grep for new sections

- [ ] **Step 1: Add DDL self-validation after DDL generation step**

Read `devforge-architecture-design/SKILL.md` to locate the DDL generation step (currently step 6, ending around the `schema.sql` output line).

Find the end of the DDL generation step (after `Output skill/artifacts/schema.sql`). Insert:

```markdown
6.1. **Self-validation: schema.sql**
   - Check: Every CREATE TABLE ends with `);`
   - Check: Every ALTER TABLE has valid FOREIGN KEY syntax
   - Check: No `VARCHAR()` without length parameter
   - Check: Primary key fields are NOT NULL
   - If any check fails, regenerate the failing statement before proceeding
```

- [ ] **Step 2: Add OpenAPI self-validation after OpenAPI generation step**

Find the end of the OpenAPI generation step (after `Output skill/artifacts/openapi.yaml`). Insert:

```markdown
7.1. **Self-validation: openapi.yaml**
   - Check: All `$ref` values start with `#/components/schemas/`
   - Check: All paths have at least one response defined
   - Check: Schema names in `components/schemas` match DataModel names in architecture.xml
   - Check: YAML indentation is consistent (2 spaces)
   - If any check fails, regenerate the failing section before proceeding
```

- [ ] **Step 3: Add tool search verification to technology stack recommendation**

Find the "Technology Stack Recommendation" section (or create it if not present). Insert:

```markdown
**Technology Stack Validation Rule**：
Before recommending any third-party library, framework, or tool, you MUST perform the following verification in order:

1. **Active Search** (Primary):
   - Use `WebSearch` or `WebFetch` to search: "{tool_name} deprecated", "{tool_name} CVE", "{tool_name} maintenance status"
   - Check the project's GitHub repository or official website for:
     - Last commit/release date (within 12 months = actively maintained)
     - Any deprecation notice or archive status
     - Open security advisories
   - If search tools are unavailable, proceed to step 2 with a disclaimer

2. **Knowledge Verification** (Fallback):
   - Cross-check against your training knowledge for known issues
   - Add disclaimer: "⚠️ This recommendation is based on available information; please verify current status before adoption."

3. **Blacklist Enforcement** (Always):
   - NEVER recommend the following without explicit user approval:
     - VM2 (critical sandbox escape CVEs, project archived)
     - Any library with known RCE vulnerabilities in the last 12 months
   - If a searched tool matches the blacklist or shows deprecation/security issues, you MUST:
     - Flag it explicitly in the recommendation
     - Provide an actively maintained alternative
     - Document the risk in DECISION_LOG.md
```

- [ ] **Step 4: Add language adaptation rule**

Find the `## Workflow` section. Insert at the beginning of Workflow (before step 1):

```markdown
## Language Adaptation
- System instructions and constraints in this skill are in English for maximum model compliance
- User-facing gate messages, summaries, and explanations use the same language as the user's most recent input
- If the user writes in Chinese, respond in Chinese. If English, respond in English
```

- [ ] **Step 5: Verify all insertions**

Run: `grep -n "Self-validation: schema.sql" devforge-architecture-design/SKILL.md`
Expected: Shows line number

Run: `grep -n "Technology Stack Validation Rule" devforge-architecture-design/SKILL.md`
Expected: Shows line number

Run: `grep -n "Language Adaptation" devforge-architecture-design/SKILL.md`
Expected: Shows line number

- [ ] **Step 6: Commit**

```bash
git add devforge-architecture-design/SKILL.md
git commit -m "feat(architecture-design): add self-validation, tool search, language adaptation

- Add DDL/OpenAPI self-validation steps
- Add Technology Stack Validation Rule with WebSearch/WebFetch
- Add blacklisted tools (VM2) enforcement
- Add language adaptation rule

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Task 6: Modify devforge-project-scaffolding/SKILL.md

**Files:**
- Modify: `devforge-project-scaffolding/SKILL.md`
- Test: grep for new sections

- [ ] **Step 1: Add repo-index.md generation step**

Find step 3 (Directory tree and dependencies). After the directory tree generation, insert:

```markdown
3.5. **Generate repo-index.md**
   - Output: `PROJECT_SCAFFOLD/docs/architecture/repo-index.md`
   - Contents:
     - Module directory tree with component leaf nodes
     - Quick lookup table: state owner → module → component
     - Interface signature index (method name + input/output schema names only)
     - Decision ID → file location mapping
```

- [ ] **Step 2: Add syntax validation to internal verification**

Find step 13 (Internal verification). Append:

```markdown
13.1. **Syntax validation**
   - For Python files: verify with `python -m py_compile {file}`
   - For TypeScript files: verify with `tsc --noEmit` (if tsconfig exists)
   - For Go files: verify with `go build ./...`
   - For Java files: verify with `mvn compile` or `javac` (single file)
   - Mark any file failing syntax check as `SYNTAX_GAP` in STATE.md Known Pitfalls
```

- [ ] **Step 3: Add language adaptation rule**

Find the `## Workflow` section. Insert at the beginning:

```markdown
## Language Adaptation
- System instructions and constraints in this skill are in English for maximum model compliance
- User-facing gate messages, summaries, and explanations use the same language as the user's most recent input
- If the user writes in Chinese, respond in Chinese. If English, respond in English
```

- [ ] **Step 4: Verify insertions**

Run: `grep -n "repo-index.md" devforge-project-scaffolding/SKILL.md`
Expected: Shows line number

Run: `grep -n "Syntax validation" devforge-project-scaffolding/SKILL.md`
Expected: Shows line number

- [ ] **Step 5: Commit**

```bash
git add devforge-project-scaffolding/SKILL.md
git commit -m "feat(scaffolding): add repo-index, syntax validation, language adaptation

- Generate repo-index.md with module tree, state lookup, interface index
- Add syntax validation step (Python/TypeScript/Go/Java)
- Add language adaptation rule

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Task 7: Modify devforge-requirement-analysis/SKILL.md

**Files:**
- Modify: `devforge-requirement-analysis/SKILL.md`
- Test: grep for new sections

- [ ] **Step 1: Add language adaptation rule**

Find the `## Workflow` section. Insert at the beginning:

```markdown
## Language Adaptation
- System instructions and constraints in this skill are in English for maximum model compliance
- User-facing gate messages, summaries, and explanations use the same language as the user's most recent input
- If the user writes in Chinese, respond in Chinese. If English, respond in English
```

- [ ] **Step 2: Add self-validation before human gate**

Find step 8 (Human gate). Before it, insert:

```markdown
7.5. **Self-validation**
   - Verify: Every user story has acceptance criteria
   - Verify: Every acceptance criterion is observable (no adjectives like "fast" without quantification)
   - Verify: Cross-module interactions section is not empty
   - Verify: P0/P1/P2 grading is present for all functional requirements
   - If any check fails, fix before presenting the human gate
```

Note: Adjust step numbering if needed (original step 7 is State update).

- [ ] **Step 3: Verify insertions**

Run: `grep -n "Self-validation" devforge-requirement-analysis/SKILL.md`
Expected: Shows line number

Run: `grep -n "Language Adaptation" devforge-requirement-analysis/SKILL.md`
Expected: Shows line number

- [ ] **Step 4: Commit**

```bash
git add devforge-requirement-analysis/SKILL.md
git commit -m "feat(requirement-analysis): add self-validation and language adaptation

- Add self-validation: user stories AC, observable criteria, cross-module interactions
- Add language adaptation rule

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Task 8: Modify devforge-architecture-validation/SKILL.md

**Files:**
- Modify: `devforge-architecture-validation/SKILL.md`
- Test: grep for new sections

- [ ] **Step 1: Add language adaptation rule**

Find the `## Workflow` section. Insert at the beginning:

```markdown
## Language Adaptation
- System instructions and constraints in this skill are in English for maximum model compliance
- User-facing gate messages, summaries, and explanations use the same language as the user's most recent input
- If the user writes in Chinese, respond in Chinese. If English, respond in English
```

- [ ] **Step 2: Add self-validation before human gate**

Find step 11 (Human gate). Before it, insert:

```markdown
10.5. **Self-validation**
   - Verify: VALIDATION_REPORT.md clearly states PASS or FAIL per module
   - Verify: health-check.sh is not empty and references real files
   - Verify: If real-LLM validation was skipped, this is explicitly noted in the report
   - Verify: VALIDATION_DELTA.md identifies only new or resolved issues
   - If any check fails, fix before presenting the human gate
```

- [ ] **Step 3: Verify insertions**

Run: `grep -n "Self-validation" devforge-architecture-validation/SKILL.md`
Expected: Shows line number

- [ ] **Step 4: Commit**

```bash
git add devforge-architecture-validation/SKILL.md
git commit -m "feat(architecture-validation): add self-validation and language adaptation

- Add self-validation: report clarity, health-check validity, LLM skip notation, delta accuracy
- Add language adaptation rule

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Task 9: Modify devforge-design-review/SKILL.md

**Files:**
- Modify: `devforge-design-review/SKILL.md`
- Test: grep for new sections

- [ ] **Step 1: Add language adaptation rule**

Find the `## Workflow` section. Insert at the beginning:

```markdown
## Language Adaptation
- System instructions and constraints in this skill are in English for maximum model compliance
- User-facing gate messages, summaries, and explanations use the same language as the user's most recent input
- If the user writes in Chinese, respond in Chinese. If English, respond in English
```

- [ ] **Step 2: Add self-validation before human gate**

Find step 8 (Human gate). Before it, insert:

```markdown
7.5. **Self-validation**
   - Verify: At least one issue found under each lens (Attacker, Operator, Extender)
   - Verify: No PASS/FAIL verdict language used (only problem list)
   - Verify: Every Must Fix issue references a DECISION_LOG.md entry
   - Verify: Issue severity counts (Must/Should/Nice/Documented) are all present
   - If any check fails, fix before presenting the human gate
```

- [ ] **Step 3: Verify insertions**

Run: `grep -n "Self-validation" devforge-design-review/SKILL.md`
Expected: Shows line number

- [ ] **Step 4: Commit**

```bash
git add devforge-design-review/SKILL.md
git commit -m "feat(design-review): add self-validation and language adaptation

- Add self-validation: lens coverage, no verdict language, decision references, severity counts
- Add language adaptation rule

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Task 10: Modify devforge-module-design/SKILL.md

**Files:**
- Modify: `devforge-module-design/SKILL.md`
- Test: grep for new sections

- [ ] **Step 1: Add language adaptation rule**

Find the `## Workflow` section. Insert at the beginning:

```markdown
## Language Adaptation
- System instructions and constraints in this skill are in English for maximum model compliance
- User-facing gate messages, summaries, and explanations use the same language as the user's most recent input
- If the user writes in Chinese, respond in Chinese. If English, respond in English
```

- [ ] **Step 2: Add self-validation before human gate**

Find step 10 (Human gate). Before it, insert:

```markdown
9.5. **Self-validation**
   - Verify: Module design traces back to system-level PRD (no invented requirements)
   - Verify: Component interfaces do not violate system-level Coupling constraints
   - Verify: ModuleStateModel defines lifecycle (create/read/update/delete/cleanup) for all owned states
   - Verify: component-spec.xml templates include ParentModule ref and Metadata placeholders
   - If any check fails, fix before presenting the human gate
```

- [ ] **Step 3: Verify insertions**

Run: `grep -n "Self-validation" devforge-module-design/SKILL.md`
Expected: Shows line number

- [ ] **Step 4: Commit**

```bash
git add devforge-module-design/SKILL.md
git commit -m "feat(module-design): add self-validation and language adaptation

- Add self-validation: PRD traceability, coupling constraints, state lifecycle, component templates
- Add language adaptation rule

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Task 11: Modify devforge-iteration-planning/SKILL.md

**Files:**
- Modify: `devforge-iteration-planning/SKILL.md`
- Test: grep for new sections

- [ ] **Step 1: Add language adaptation rule**

Find the `## Workflow` section. Insert at the beginning:

```markdown
## Language Adaptation
- System instructions and constraints in this skill are in English for maximum model compliance
- User-facing gate messages, summaries, and explanations use the same language as the user's most recent input
- If the user writes in Chinese, respond in Chinese. If English, respond in English
```

- [ ] **Step 2: Add self-validation before human gate**

Find step 10 (Human gate). Before it, insert:

```markdown
9.5. **Self-validation**
   - Verify: Every new requirement has a traced impact in the Impact Matrix
   - Verify: Breaking changes have version increments documented in INTERFACE_CONTRACT.md
   - Verify: ITERATION_PRD.md does not duplicate unchanged requirements from original PRD
   - Verify: XML sync report lists all files modified and changes made
   - If any check fails, fix before presenting the human gate
```

- [ ] **Step 3: Verify insertions**

Run: `grep -n "Self-validation" devforge-iteration-planning/SKILL.md`
Expected: Shows line number

- [ ] **Step 4: Commit**

```bash
git add devforge-iteration-planning/SKILL.md
git commit -m "feat(iteration-planning): add self-validation and language adaptation

- Add self-validation: impact matrix traceability, version increments, PRD dedup, sync report
- Add language adaptation rule

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Task 12: Modify devforge-visualization/SKILL.md

**Files:**
- Modify: `devforge-visualization/SKILL.md`
- Test: grep for new section

- [ ] **Step 1: Add language adaptation rule**

Find the `## Workflow` section. Insert at the beginning:

```markdown
## Language Adaptation
- System instructions and constraints in this skill are in English for maximum model compliance
- User-facing gate messages, summaries, and explanations use the same language as the user's most recent input
- If the user writes in Chinese, respond in Chinese. If English, respond in English
```

- [ ] **Step 2: Verify insertion**

Run: `grep -n "Language Adaptation" devforge-visualization/SKILL.md`
Expected: Shows line number

- [ ] **Step 3: Commit**

```bash
git add devforge-visualization/SKILL.md
git commit -m "feat(visualization): add language adaptation

- Add language adaptation rule (no self-validation needed for pure transform skill)

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Task 13: Modify devforge-ops-ready/SKILL.md

**Files:**
- Modify: `devforge-ops-ready/SKILL.md`
- Test: grep for new sections

- [ ] **Step 1: Add language adaptation rule**

Find the `## Workflow` section. Insert at the beginning:

```markdown
## Language Adaptation
- System instructions and constraints in this skill are in English for maximum model compliance
- User-facing gate messages, summaries, and explanations use the same language as the user's most recent input
- If the user writes in Chinese, respond in Chinese. If English, respond in English
```

- [ ] **Step 2: Add tool search verification**

Find the cloud platform selection or technology recommendation area. Insert:

```markdown
**Tool Validation Rule**:
Before recommending any cloud service, monitoring tool, or infrastructure component:
1. Use `WebSearch` or `WebFetch` to verify the service/tool is actively maintained
2. Check for recent deprecation notices or pricing changes that affect the recommendation
3. If search tools are unavailable, add disclaimer: "⚠️ Verify current pricing and availability before deployment"
4. NEVER recommend services known to be discontinued without explicit user approval
```

- [ ] **Step 3: Verify insertions**

Run: `grep -n "Language Adaptation" devforge-ops-ready/SKILL.md`
Expected: Shows line number

Run: `grep -n "Tool Validation Rule" devforge-ops-ready/SKILL.md`
Expected: Shows line number

- [ ] **Step 4: Commit**

```bash
git add devforge-ops-ready/SKILL.md
git commit -m "feat(ops-ready): add language adaptation and tool validation

- Add language adaptation rule
- Add tool validation rule with WebSearch/WebFetch for cloud services

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Task 14: Modify devforge-debug-assistant/SKILL.md

**Files:**
- Modify: `devforge-debug-assistant/SKILL.md`
- Test: grep for new sections

- [ ] **Step 1: Add language adaptation rule**

Find the `## Workflow` section. Insert at the beginning:

```markdown
## Language Adaptation
- System instructions and constraints in this skill are in English for maximum model compliance
- User-facing gate messages, summaries, and explanations use the same language as the user's most recent input
- If the user writes in Chinese, respond in Chinese. If English, respond in English
```

- [ ] **Step 2: Add context protocol reference to Mode A and Mode B**

In Mode A (Bug Diagnosis), after step 1 (Collect evidence), insert:

```markdown
1.5. **Apply context protocol**
   - Load `references/context-management-protocol.md`
   - Prioritize loading: repo-index.md, target component-spec.xml, failing test output
   - Load other artifacts as summaries if context exceeds 8,000 tokens
```

In Mode B (Refactoring), after step 1 (Code health scan), insert:

```markdown
1.5. **Apply context protocol**
   - Load `references/context-management-protocol.md`
   - Prioritize loading: repo-index.md, target component-spec.xml, DESIGN_REVIEW.md issues
   - Load other artifacts as summaries if context exceeds 8,000 tokens
```

- [ ] **Step 3: Verify insertions**

Run: `grep -n "Language Adaptation" devforge-debug-assistant/SKILL.md`
Expected: Shows line number

Run: `grep -n "context-management-protocol" devforge-debug-assistant/SKILL.md`
Expected: Shows 2 occurrences (Mode A and Mode B)

- [ ] **Step 4: Commit**

```bash
git add devforge-debug-assistant/SKILL.md
git commit -m "feat(debug-assistant): add language adaptation and context protocol

- Add language adaptation rule
- Add context protocol reference to both Bug Diagnosis and Refactoring modes

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

## Spec Coverage Check

| Spec Requirement | Plan Task | Status |
|-----------------|-----------|--------|
| 6.1: Unified System Prompt template | Task 1 | ✅ Covered |
| 4.1: Layered summary (Module Registry digest) | Task 4 | ✅ Covered |
| 4.2: repo-index.md generation | Task 6 | ✅ Covered |
| 4.3: Context loading protocol per skill | Task 2 | ✅ Covered |
| 5.1: Scripts capability manifest | Task 3 | ✅ Covered |
| 5.3: DDL/OpenAPI self-validation | Task 5 | ✅ Covered |
| 5.4: Tool search verification | Task 5, Task 13 | ✅ Covered |
| 5.5: Syntax validation | Task 6 | ✅ Covered |
| 6.3: Language adaptation | Task 5-14 | ✅ Covered |
| 6.4: Context truncation strategy | Task 2 | ✅ Covered |
| 6.5: Self-validation steps | Task 5-11 | ✅ Covered |

---

## Post-Implementation Verification

After all tasks are complete, run the following verification:

```bash
# 1. Verify all 3 new reference files exist
ls references/system-prompt-template.md references/context-management-protocol.md references/validation-scripts-manifest.md

# 2. Verify all 11 modified files have Language Adaptation section
grep -l "Language Adaptation" devforge-*/SKILL.md
# Expected: 10 files (all core skills)

# 3. Verify self-validation sections exist in core skills
grep -l "Self-validation" devforge-*/SKILL.md
# Expected: 7 files (requirement-analysis, architecture-design, architecture-validation, design-review, project-scaffolding, module-design, iteration-planning)

# 4. Verify devforge-state.md has digest field
grep "digest:" devforge-state.md

# 5. Verify tool validation exists
grep -l "Technology Stack Validation Rule\|Tool Validation Rule" devforge-*/SKILL.md
# Expected: architecture-design and ops-ready
```
