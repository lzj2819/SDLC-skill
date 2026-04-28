# DevForge Chain v1.2

A standalone, composable set of Claude Code skills for the full software development lifecycle. Built on the VCMF (Vibe Coding Maturity Framework) and the DIVE (Design-Implement-Verify-Evolve) cycle.

[GitHub Repository](https://github.com/lzj2819/DevForge) | [License: MIT](LICENSE)

The original monolithic Chinese design document is preserved at `DevForge.md` for reference.

## Skills

| Skill | DIVE Stage | VCMF Principles | Purpose |
|-------|------------|-----------------|---------|
| `devforge-requirement-analysis` | Design | Design as Contract, Interface as Boundary | Turn an idea into a structured PRD with user stories, acceptance criteria, and cross-module interaction points |
| `devforge-architecture-design` | Design | Design as Contract, Interface as Boundary, State as Responsibility | Evaluate architecture patterns dynamically (10-pattern library), design interface contracts, model three-layer XML architecture (System/Module/Component), and define test cases |
| `devforge-architecture-validation` | Verify | Interface as Boundary, Reality as Baseline | Technical validation via mock simulation, real-LLM format checks, consistency audits, and incremental delta reports |
| `devforge-design-review` | Verify | Design as Contract, Interface as Boundary, Reality as Baseline, State as Responsibility | Adversarial inspection (Attacker/Operator/Extender lenses) to find design flaws; produces problem list, not PASS/FAIL |
| `devforge-project-scaffolding` | Implement + Evolve | Reality as Baseline, State as Responsibility, Design as Contract, XML as Authority | Generate runnable project scaffolding with XML-driven code generation, CI/CD, transparent test fixtures, ADR, and evolution infrastructure |
| `devforge-module-design` | Design (Module) | Design as Contract, Interface as Boundary, State as Responsibility | Deep-dive design for a single module: component decomposition, component interfaces, module-level XML, and component-spec templates |
| `devforge-iteration-planning` | Evolve | Design as Contract, Interface as Boundary, Reality as Baseline, State as Responsibility | Incremental planning for new requirements: impact analysis, incremental PRD, interface versioning, XML sync, and iteration plan generation |
| `devforge-visualization` | Visualize | Design as Contract, Reality as Baseline | Generate Mermaid diagrams (system-context, module-interaction, data-flow, ER) from `architecture.xml` |
| `devforge-ops-ready` | Operate | Design as Contract, Interface as Boundary, Reality as Baseline, State as Responsibility | Production infrastructure: Terraform, K8s manifests, Prometheus/Grafana monitoring, blue-green + canary progressive deployment, operational runbook |
| `devforge-debug-assistant` | Debug | Design as Contract, Interface as Boundary, Reality as Baseline, State as Responsibility | Bug diagnosis with root cause analysis + refactoring suggestions with code health scan |

### Internal Utilities

| Skill | Purpose |
|-------|---------|
| `context-compression` | Automatically invoked by other skills after completion. Compresses session context into a 200-word digest stored in `STATE.md` for fast session recovery. |

### Domain Extensions

Located in `extensions/`. Dynamically loaded by `devforge-architecture-design` when PRD characteristic tags match.

| Extension | Trigger Tags | Purpose |
|-----------|--------------|---------|
| `ai-agent-design` | `ai_agent`, `llm_orchestration`, `tool_use` | Additional evaluation dimensions (Tool Latency, Context Window Efficiency, Memory Integration), AI-specific anti-patterns, mandatory modules (Orchestrator, LLMGateway, ToolRegistry, MemoryStore, SecurityJudge) |
| `data-pipeline-design` | `data_pipeline`, `etl`, `streaming` | Schema Evolution, Idempotency, Backpressure, Data Lineage dimensions |
| `mobile-app-design` | `mobile_app`, `ios`, `android` | Offline Support, Battery Efficiency, Push Delivery dimensions |

## VCMF Principles

- **Design as Contract** — Code must obey documents, not the other way around. Every artifact must be traceable back to a requirement or design decision.
- **Interface as Boundary** — Any cross-module or cross-layer call must have an explicitly defined input/output schema and error contract before implementation begins.
- **Reality as Baseline** — Mock tests validate flow; real environments validate function. Semantic-sensitive points must be tested against real LLMs when possible.
- **State as Responsibility** — Who creates a state, who persists it, who reads it, and who cleans it up must be documented and enforced in both architecture and code.
- **XML as Authority** — `component-spec.xml` is the single source of truth for code generation. Function signatures, error handling, and file paths must match the XML specification. CI enforces this.

## Three-Layer XML Architecture

```
system-architecture.xml          ← System level: modules, cross-module interfaces, state ownership, security
├── modules/
│   ├── UserService/
│   │   └── module-architecture.xml   ← Module level: component decomposition, component interfaces, module state
│   │       └── components/
│   │           ├── AuthController/
│   │           │   └── component-spec.xml  ← Component level: function signatures, logic steps, error handling, tests
│   │           └── UserRepository/
│   │               └── component-spec.xml
│   └── OrderService/
│       └── module-architecture.xml
└── shared/
    └── common-types.xml
```

## Shared State

All skills read from and write to `skill/artifacts/STATE.md` (or `docs/architecture/system/STATE.md` in iteration mode). Artifacts are stored in `skill/artifacts/`.

Key state sections:
- **Immutable Goal** — Never overwritten; prevents drift
- **Completed Steps** — Append-only reasoning chain
- **Current State** — Phase, DIVE progress, NextAction
- **Module Registry** — Tracks status of every module
- **Iteration History** — All iterations after initial scaffolding
- **Compressed Context** — 200-word digest for fast session recovery
- **Artifact Index** — Quick reference to all artifacts

## Usage Flow

### Initial Development

1. Invoke `devforge-requirement-analysis` with your product idea.
2. After approving the PRD, invoke `devforge-architecture-design`.
3. After approving the architecture, optionally invoke `devforge-architecture-validation` for technical consistency checks.
4. (Recommended) Invoke `devforge-design-review` for adversarial inspection.
5. After reviewing the issue list, invoke `devforge-project-scaffolding`.
6. (Optional) For each module, invoke `devforge-module-design` with `[MODULE {module_id}]`.

### Incremental Development (After Initial Scaffolding)

1. Invoke `devforge-iteration-planning` with new requirements.
2. After approving the iteration plan, invoke `devforge-module-design` for new modules or `devforge-architecture-design` for architectural changes.
3. Invoke `devforge-project-scaffolding` to generate/update code for affected modules.

## Artifact Index

| Artifact | Path | Produced By |
|----------|------|-------------|
| PRD | `skill/artifacts/PRD.md` | `devforge-requirement-analysis` |
| Decision Log | `skill/artifacts/DECISION_LOG.md` | All skills (appended) |
| Interface Contract | `skill/artifacts/INTERFACE_CONTRACT.md` | `devforge-architecture-design` |
| Architecture Design | `skill/artifacts/ARCHITECTURE.md` | `devforge-architecture-design` |
| Architecture XML (System) | `skill/artifacts/architecture.xml` | `devforge-architecture-design` |
| Module Architecture XML | `skill/artifacts/modules/{id}/module-architecture.xml` | `devforge-module-design` |
| Component Spec XML | `skill/artifacts/modules/{id}/components/{cid}/component-spec.xml` | `devforge-module-design` |
| Validation Report | `skill/artifacts/VALIDATION_REPORT.md` | `devforge-architecture-validation` |
| Validation Delta | `docs/architecture/validation/VALIDATION_DELTA_*.md` | `devforge-architecture-validation` |
| Design Review | `skill/artifacts/DESIGN_REVIEW.md` | `devforge-design-review` |
| Health Check Script | `skill/artifacts/health-check.sh` | `devforge-architecture-validation` |
| Iteration PRD | `skill/artifacts/ITERATION_PRD.md` | `devforge-iteration-planning` |
| Iteration Plan | `skill/artifacts/ITERATION_PLAN.md` | `devforge-iteration-planning` |
| Scaffolding | `skill/artifacts/PROJECT_SCAFFOLD/` | `devforge-project-scaffolding` |
| RTM | `skill/artifacts/RTM.md` | `devforge-requirement-analysis` |
| Database Schema | `skill/artifacts/schema.sql` | `devforge-architecture-design` |
| OpenAPI Spec | `skill/artifacts/openapi.yaml` | `devforge-architecture-design` |
| ERD | `skill/artifacts/ERD.md` | `devforge-architecture-design` |
| Debug Report | `skill/artifacts/DEBUG_REPORT.md` | `devforge-debug-assistant` |
| Refactor Report | `skill/artifacts/REFACTOR_REPORT.md` | `devforge-debug-assistant` |

## Installation

### Option 1: Clone and Copy (Recommended for Personal Use)

```bash
# Clone this repository
git clone https://github.com/lzj2819/DevForge.git
cd DevForge

# Copy all skills to Claude Code user skills directory (macOS/Linux)
cp -r devforge-requirement-analysis devforge-architecture-design devforge-architecture-validation \
  devforge-design-review devforge-project-scaffolding devforge-module-design \
  devforge-iteration-planning devforge-visualization devforge-ops-ready \
  devforge-debug-assistant context-compression extensions \
  ~/.claude/skills/
```

**Windows (PowerShell):**
```powershell
# Clone this repository
git clone https://github.com/lzj2819/DevForge.git
cd DevForge

# Copy all skill directories
$target = "$env:USERPROFILE\.claude\skills"

@("devforge-requirement-analysis", "devforge-architecture-design", "devforge-architecture-validation",
  "devforge-design-review", "devforge-project-scaffolding", "devforge-module-design",
  "devforge-iteration-planning", "devforge-visualization", "devforge-ops-ready",
  "devforge-debug-assistant", "context-compression", "extensions") | ForEach-Object {
    Copy-Item -Path "$_" -Destination $target -Recurse -Force
}
```

After copying, restart Claude Code or run `/reload` to pick up the new skills.

### Option 2: Install via Plugin Marketplace

Add this marketplace to your Claude Code configuration:

```json
// ~/.claude/config.json
{
  "pluginMarketplaces": [
    {
      "name": "vclaw-devforge",
      "url": "https://raw.githubusercontent.com/lzj2819/DevForge/main/.claude-plugin/marketplace.json"
    }
  ]
}
```

Then install the plugin:
```
/plugin install DevForge-chain@vclaw-devforge
```

### Option 3: Manual Per-Skill Installation

Install only the skills you need:

```bash
git clone https://github.com/lzj2819/DevForge.git
cd DevForge

# Example: Install only requirement analysis and architecture design
cp -r devforge-requirement-analysis ~/.claude/skills/
cp -r devforge-architecture-design ~/.claude/skills/
```

## Verification

After installation, verify the skills are loaded:

```
/skills
```

You should see all 10 core skills plus context-compression and domain extensions listed.

## Directory Structure

```
DevForge/
├── .claude-plugin/
│   ├── plugin.json          # Plugin metadata for Claude Code
│   └── marketplace.json     # Marketplace entry for distribution
├── LICENSE                  # MIT License
├── README.md                # This file
├── devforge-design.md           # Skill chain design document
├── devforge-state.md            # STATE.md template specification
├── references/              # Shared reference documents
│   ├── architecture-patterns.md
│   └── xml-schemas.md
├── scripts/                 # Utility scripts
│   ├── architecture-ci.sh
│   ├── package-plugin.py    # Packaging script for distribution
│   └── xml-sync.py
├── devforge-requirement-analysis/   # Core skill 1
├── devforge-architecture-design/    # Core skill 2
├── devforge-architecture-validation/ # Core skill 3
├── devforge-design-review/          # Core skill 4
├── devforge-project-scaffolding/    # Core skill 5
├── devforge-module-design/          # Core skill 6
├── devforge-iteration-planning/     # Core skill 7
├── devforge-visualization/          # Core skill 8 (v1.2)
├── devforge-ops-ready/              # Core skill 9 (v1.2)
├── devforge-debug-assistant/        # Core skill 10 (v1.2)
├── context-compression/         # Internal utility
└── extensions/                  # Domain-specific extensions
    ├── ai-agent-design/
    ├── data-pipeline-design/
    └── mobile-app-design/
```

## Packaging

To create distributable packages:

```bash
# Package all skills individually + full plugin zip
python scripts/package-plugin.py --mode all --output ./dist
```

Outputs:
- `dist/DevForge-chain-v1.1.0.zip` — Full plugin package
- `dist/skills/*.skill` — Individual skill packages

## Contributing

This skill chain is part of the [VClaw](https://github.com/lzj2819/vclaw) project. For the full 6-layer AI Agent system, see the main repository.
