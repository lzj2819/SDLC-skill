# SDLC Skill Chain v1.1

A standalone, composable set of Claude Code skills for the full software development lifecycle. Built on the VCMF (Vibe Coding Maturity Framework) and the DIVE (Design-Implement-Verify-Evolve) cycle.

The original monolithic Chinese design document is preserved at `软件开发全流程智能体技能(SDLC-Skill).md` for reference.

## Skills

| Skill | DIVE Stage | VCMF Principles | Purpose |
|-------|------------|-----------------|---------|
| `sdlc-requirement-analysis` | Design | Design as Contract, Interface as Boundary | Turn an idea into a structured PRD with user stories, acceptance criteria, and cross-module interaction points |
| `sdlc-architecture-design` | Design | Design as Contract, Interface as Boundary, State as Responsibility | Evaluate architecture patterns dynamically (10-pattern library), design interface contracts, model three-layer XML architecture (System/Module/Component), and define test cases |
| `sdlc-architecture-validation` | Verify | Interface as Boundary, Reality as Baseline | Technical validation via mock simulation, real-LLM format checks, consistency audits, and incremental delta reports |
| `sdlc-design-review` | Verify | Design as Contract, Interface as Boundary, Reality as Baseline, State as Responsibility | Adversarial inspection (Attacker/Operator/Extender lenses) to find design flaws; produces problem list, not PASS/FAIL |
| `sdlc-project-scaffolding` | Implement + Evolve | Reality as Baseline, State as Responsibility, Design as Contract, XML as Authority | Generate runnable project scaffolding with XML-driven code generation, CI/CD, transparent test fixtures, ADR, and evolution infrastructure |
| `sdlc-module-design` | Design (Module) | Design as Contract, Interface as Boundary, State as Responsibility | Deep-dive design for a single module: component decomposition, component interfaces, module-level XML, and component-spec templates |
| `sdlc-iteration-planning` | Evolve | Design as Contract, Interface as Boundary, Reality as Baseline, State as Responsibility | Incremental planning for new requirements: impact analysis, incremental PRD, interface versioning, XML sync, and iteration plan generation |

### Internal Utilities

| Skill | Purpose |
|-------|---------|
| `context-compression` | Automatically invoked by other skills after completion. Compresses session context into a 200-word digest stored in `STATE.md` for fast session recovery. |

### Domain Extensions

Located in `extensions/`. Dynamically loaded by `sdlc-architecture-design` when PRD characteristic tags match.

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

1. Invoke `sdlc-requirement-analysis` with your product idea.
2. After approving the PRD, invoke `sdlc-architecture-design`.
3. After approving the architecture, optionally invoke `sdlc-architecture-validation` for technical consistency checks.
4. (Recommended) Invoke `sdlc-design-review` for adversarial inspection.
5. After reviewing the issue list, invoke `sdlc-project-scaffolding`.
6. (Optional) For each module, invoke `sdlc-module-design` with `[MODULE {module_id}]`.

### Incremental Development (After Initial Scaffolding)

1. Invoke `sdlc-iteration-planning` with new requirements.
2. After approving the iteration plan, invoke `sdlc-module-design` for new modules or `sdlc-architecture-design` for architectural changes.
3. Invoke `sdlc-project-scaffolding` to generate/update code for affected modules.

## Artifact Index

| Artifact | Path | Produced By |
|----------|------|-------------|
| PRD | `skill/artifacts/PRD.md` | `sdlc-requirement-analysis` |
| Decision Log | `skill/artifacts/DECISION_LOG.md` | All skills (appended) |
| Interface Contract | `skill/artifacts/INTERFACE_CONTRACT.md` | `sdlc-architecture-design` |
| Architecture Design | `skill/artifacts/ARCHITECTURE.md` | `sdlc-architecture-design` |
| Architecture XML (System) | `skill/artifacts/architecture.xml` | `sdlc-architecture-design` |
| Module Architecture XML | `skill/artifacts/modules/{id}/module-architecture.xml` | `sdlc-module-design` |
| Component Spec XML | `skill/artifacts/modules/{id}/components/{cid}/component-spec.xml` | `sdlc-module-design` |
| Validation Report | `skill/artifacts/VALIDATION_REPORT.md` | `sdlc-architecture-validation` |
| Validation Delta | `docs/architecture/validation/VALIDATION_DELTA_*.md` | `sdlc-architecture-validation` |
| Design Review | `skill/artifacts/DESIGN_REVIEW.md` | `sdlc-design-review` |
| Health Check Script | `skill/artifacts/health-check.sh` | `sdlc-architecture-validation` |
| Iteration PRD | `skill/artifacts/ITERATION_PRD.md` | `sdlc-iteration-planning` |
| Iteration Plan | `skill/artifacts/ITERATION_PLAN.md` | `sdlc-iteration-planning` |
| Scaffolding | `skill/artifacts/PROJECT_SCAFFOLD/` | `sdlc-project-scaffolding` |

## Directory Structure

```
skill/
├── README.md
├── sdlc-design.md
├── sdlc-state.md
├── sdlc-plan.md
├── 软件开发全流程智能体技能(SDLC-Skill).md
├── references/
│   ├── architecture-patterns.md      # 10-pattern library with evaluation dimensions
│   └── xml-schemas.md                # Three-layer XML schema definitions
├── scripts/
│   ├── architecture-ci.sh            # CI health check script
│   └── xml-sync.py                   # XML sync and validation script
├── artifacts/                        # Generated artifacts (or docs/architecture/ in iteration mode)
│   ├── STATE.md
│   ├── PRD.md
│   ├── DECISION_LOG.md
│   ├── INTERFACE_CONTRACT.md
│   ├── ARCHITECTURE.md
│   ├── architecture.xml
│   ├── VALIDATION_REPORT.md
│   ├── VALIDATION_DELTA.md
│   ├── DESIGN_REVIEW.md
│   ├── ITERATION_PRD.md
│   ├── ITERATION_PLAN.md
│   ├── health-check.sh
│   └── PROJECT_SCAFFOLD/
│       └── docs/
│           ├── sync-rules.md
│           └── ADR.md
├── sdlc-requirement-analysis/
│   └── SKILL.md
├── sdlc-architecture-design/
│   └── SKILL.md
├── sdlc-architecture-validation/
│   └── SKILL.md
├── sdlc-design-review/
│   └── SKILL.md
├── sdlc-project-scaffolding/
│   └── SKILL.md
├── sdlc-module-design/
│   └── SKILL.md
├── sdlc-iteration-planning/
│   └── SKILL.md
├── context-compression/
│   └── SKILL.md
└── extensions/
    ├── ai-agent-design/
    │   ├── SKILL.md
    │   └── references/
    │       ├── dimensions.md
    │       └── anti-patterns.md
    ├── data-pipeline-design/
    │   ├── SKILL.md
    │   └── references/
    │       ├── schema-evolution.md
    │       └── idempotency-patterns.md
    └── mobile-app-design/
        ├── SKILL.md
        └── references/
            ├── offline-first.md
            └── push-notification.md
```

## Installation

### Option 1: Copy to User Skills (Recommended for Personal Use)

Copy the entire `skill/` directory into your Claude Code user skills folder:

**macOS / Linux:**
```bash
# Clone or navigate to the repository
cd vclaw/1.0.1/skill

# Copy all skills to Claude Code user skills directory
cp -r sdlc-requirement-analysis sdlc-architecture-design sdlc-architecture-validation \
  sdlc-design-review sdlc-project-scaffolding sdlc-module-design \
  sdlc-iteration-planning context-compression extensions \
  ~/.claude/skills/
```

**Windows (PowerShell):**
```powershell
# Copy all skill directories
$source = "E:\pythonproject\vclaw\vclaw\1.0.1\skill"
$target = "$env:USERPROFILE\.claude\skills"

@("sdlc-requirement-analysis", "sdlc-architecture-design", "sdlc-architecture-validation",
  "sdlc-design-review", "sdlc-project-scaffolding", "sdlc-module-design",
  "sdlc-iteration-planning", "context-compression", "extensions") | ForEach-Object {
    Copy-Item -Path "$source\$_" -Destination $target -Recurse -Force
}
```

After copying, restart Claude Code or run `/reload` to pick up the new skills.

### Option 2: Install as Plugin (For Distribution)

To distribute this skill chain like `superpowers` so others can install it via `/plugin install`:

1. **Publish as a GitHub repository** (or keep in your existing repo)
2. **Users add your marketplace** to their Claude Code config:
   ```json
   // ~/.claude/config.json
   {
     "pluginMarketplaces": [
       {
         "name": "vclaw-sdlc",
         "url": "https://raw.githubusercontent.com/lzj2819/vclaw/main/1.0.1/skill/.claude-plugin/marketplace.json"
       }
     ]
   }
   ```
3. **Users install the plugin**:
   ```
   /plugin install sdlc-skill-chain@vclaw-sdlc
   ```

### Option 3: Manual Per-Skill Installation

Install only the skills you need:

```bash
# Example: Install only requirement analysis and architecture design
cp -r sdlc-requirement-analysis ~/.claude/skills/
cp -r sdlc-architecture-design ~/.claude/skills/
```

## Verification

After installation, verify the skills are loaded:

```
/skills
```

You should see all 7 core skills plus context-compression and domain extensions listed.

## Plugin Structure

This directory is structured as a Claude Code plugin:

```
skill/
├── .claude-plugin/
│   ├── plugin.json          # Plugin metadata for Claude Code
│   └── marketplace.json     # Marketplace entry for distribution
├── sdlc-requirement-analysis/   # Core skill 1
├── sdlc-architecture-design/    # Core skill 2
├── sdlc-architecture-validation/ # Core skill 3
├── sdlc-design-review/          # Core skill 4
├── sdlc-project-scaffolding/    # Core skill 5
├── sdlc-module-design/          # Core skill 6
├── sdlc-iteration-planning/     # Core skill 7
├── context-compression/         # Internal utility
├── extensions/                  # Domain-specific extensions
└── README.md
```

## Packaging

To create a distributable `.skill` package for individual skills:

```bash
# Requires skill-creator tool
python /path/to/skill-creator/scripts/package_skill.py sdlc-requirement-analysis/
```

For the full skill chain, distribute this entire directory as a plugin package.
