# Validation Scripts Manifest

This document maps skill-document references to actual script capabilities. It serves as the single source of truth for what `scripts/` can and cannot do.

## scripts/architecture-ci.sh

**Referenced by:** `devforge-project-scaffolding/SKILL.md`, `devforge-architecture-validation/SKILL.md`

**Capabilities:**
| Check | Description | Status |
|-------|-------------|--------|
| XML well-formedness | Validates all `*.xml` files with `xmllint` | Implemented |
| Ref attribute integrity | Verifies all `ref="..."` attributes resolve to existing files | Implemented |
| Coupling target consistency | Verifies all `module="..."` in Coupling exist as Module ids | Implemented |
| StateModel completeness | Verifies all State entries have id, location, owner, lifecycle | Implemented |
| ModuleDetail references | Verifies all ModuleDetail refs point to existing module XML files | Implemented |

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
| Verify | `--verify-only` | Check ModuleDetail refs, Coupling targets, StateModel, Module Constraints vs System Interfaces | Implemented |
| Sync | `--sync` | Verify + propagate system-level interface changes to module Constraints | Implemented |

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
| Package | Creates distributable `.skill` packages and plugin zip | Implemented |

## Known Gaps and Mitigations

| Gap | Affected Skill | Mitigation |
|-----|---------------|------------|
| architecture-ci.sh missing Interface Consistency check (Rule 2) | `devforge-project-scaffolding` | LLM performs manual check during scaffolding internal verification |
| xml-sync.py missing ID Consistency check (Rule 1) | All skills | Checked implicitly during XML generation; LLM verifies during self-validation |
| xml-sync.py missing DDL Schema Validity (Rule 6) | `devforge-architecture-design` | LLM self-validation during DDL generation step |
