---
name: devforge-project-scaffolding
description: Use when architecture design (and optional validation) is approved and the user needs concrete project scaffolding, CI/CD pipelines, transparent test fixtures, and evolution infrastructure
---

# DevForge Project Scaffolding

## Overview

Generate hard deliverables by grounding all historical conclusions into runnable code. Reads the full reasoning chain (PRD, STATE, DECISION_LOG, ARCHITECTURE, XML, INTERFACE_CONTRACT, VALIDATION_REPORT, DESIGN_REVIEW) to ensure every generated file traces back to its origin. Output includes directory trees, dependency files, CI/CD configs, deployment topologies, test fixtures, code-level reasoning comments, and an Architecture Decision Record (ADR).

## VCMF Checkpoints

| Principle | Checkpoint in this Skill |
|-----------|--------------------------|
| Design as Contract | Every generated infrastructure file must be traceable to PRD or Architecture artifacts |
| Interface as Boundary | CI/CD pipeline must include architecture consistency check job |
| Reality as Baseline | Tests directory structure must support both mock tests and real-LLM tests with `skipif` mechanism |
| State as Responsibility | Generated state management code (infrastructure layer only) must match `StateModel` ownership in XML |
| XML as Authority | `docs/architecture/INDEX.md` must correctly index all XML artifacts; CI enforces XML consistency |

## When to Use

- The user has approved architecture design (and optional validation)
- You need to produce runnable project scaffolding
- Do NOT use if architecture has not been approved

## Precondition Check

Read `skill/artifacts/STATE.md`. Acceptable phases: `architecture_design_completed`, `architecture_validated`, `design_review_completed`, `module_design_completed`, `iteration_planning_completed`. If phase is not in this list, stop and instruct the user to complete prior phases.

## Language Adaptation

- System instructions and constraints in this skill are in English for maximum model compliance
- User-facing gate messages, summaries, and explanations use the same language as the user's most recent input
- If the user writes in Chinese, respond in Chinese. If English, respond in English

## Workflow

1. **Read all artifacts**
   - Load ALL historical artifacts:
     - `PRD.md` (requirements origin)
     - `STATE.md` (current phase + known pitfalls + module registry)
     - `DECISION_LOG.md` (reasoning chain)
     - `ARCHITECTURE.md` (design summary)
     - `architecture.xml` (strict schema + DecisionTrace + ModuleDetail refs)
     - `INTERFACE_CONTRACT.md` (I/O boundaries)
     - `VALIDATION_REPORT.md` (if present, technical validation results)
     - `DESIGN_REVIEW.md` (if present, issue list)
     - Module-level artifacts (if present): `modules/{module_id}/module-architecture.xml`, `modules/{module_id}/module-interface-contract.md`
     - Component-level artifacts (if present): `modules/{module_id}/components/{component_id}/component-spec.xml`

2. **Internal planning**
   - Create an implementation plan for the scaffolding work:
     - Which files to create
     - Which directories to set up
     - Which tests to generate
   - Keep the plan lightweight (a short bullet list is sufficient)

3. **Directory tree and dependencies**
   - Generate the project directory tree under `skill/artifacts/PROJECT_SCAFFOLD/`
   - Generate architecture documentation tree under `docs/architecture/`:
     - System-level artifacts → `docs/architecture/system/`
     - Module-level artifacts → `docs/architecture/modules/{module_id}/`
     - Generate `.gitattributes` marking `*.xml` as `diff=text`
   - Generate `docs/architecture/INDEX.md` with:
     - System-level artifact links
     - Module table (Module | PRD | XML | Interface Contract | Components) — initially empty module rows, to be filled by module-design
     - Generated artifact links (validation reports, diagrams)
   - Generate dependency config files (package.json, requirements.txt, pom.xml, Cargo.toml, etc.) based on the chosen tech stack
   - **Repository index generation**: Generate `repo-index.md` at project root with structure:
     - Hierarchical file tree (max depth 3, exclude `node_modules/`, `.git/`, `__pycache__/`, `*.lock`)
     - Per-directory summary: purpose, key files, approximate LOC
     - Module-to-directory mapping cross-reference
     - This index is consumed by `devforge-debug-assistant` and `devforge-ops-ready` for rapid context recovery

4. **Module directory initialization**
   - Read the `Module` list from `architecture.xml`
   - For each module, create the module directory under `PROJECT_SCAFFOLD/src/modules/{module_id}/` (or language-equivalent path)
   - Generate only `__init__.py` (or language equivalent) with a module header comment
   - **Do NOT generate** any function signatures, class definitions, or business logic placeholders at this stage
   - Module header comment template:
     ```python
     # Module: {module_id}
     # Priority: {P0/P1/P2}
     # PRD Reference: PRD.md::Functional Requirements::{req_id}
     # Status: scaffolding-completed (awaiting module-design)
     # Architecture Decision: {DecisionTrace ID}
     # Known Risk: {DESIGN_REVIEW issue IDs if applicable}
     #
     # NOTE: This module's component decomposition and interface contracts
     # will be generated by devforge-module-design. Do not implement
     # business logic until module-design is approved.
     ```

5. **Code reasoning comments**
   - Every core module MUST include a header comment linking it to architecture decisions:
     - Architecture Decision ID (from DECISION_LOG or XML DecisionTrace)
     - Reasoning: why this module exists, what PRD requirement it serves
     - Known Risk: any DESIGN_REVIEW issues that apply to this module
   - Every DESIGN_REVIEW issue marked "Must Fix" or "Should Fix" MUST be translated into an inline TODO with issue ID and priority

6. **Deployment topology**
   - Generate `docker-compose.yml` or basic Kubernetes manifests
   - Document containerization strategy in a short README inside the scaffold

7. **CI/CD pipeline**
   - Generate CI config (e.g., `.github/workflows/ci.yml` or `.gitlab-ci.yml`)
   - Must include: dependency install, lint, mock test execution, real test execution (with `continue-on-error` or skip logic so missing API keys do not fail the build)
   - **Coverage check job**: After test execution, run coverage analysis with minimum threshold:
     - Python: `pytest --cov=src --cov-report=xml --cov-report=term --cov-fail-under=80`
     - Node.js: `jest --coverage --coverageThreshold='{"global":{"lines":80}}'`
     - Java: `mvn jacoco:check` with `minimum` line ratio 0.80
     - Go: `go test -coverprofile=coverage.out ./...` + `go tool cover -func=coverage.out` with threshold check
     - Upload coverage report as artifact (e.g., `coverage.xml`, `coverage/`, `target/site/jacoco/`)
     - CI MUST fail if coverage is below the threshold
   - **Architecture consistency check job**: Add a job that runs `scripts/architecture-ci.sh` and `scripts/xml-sync.py --verify-only` to ensure code remains synchronized with XML specifications. This job should fail the build if:
     - XML files are malformed
     - Component function signatures in code diverge from `component-spec.xml`
     - Module constraints no longer match system-level interfaces
     - Any `ref` attribute points to a missing file

8. **Environment configuration template**
   - Generate `.env.template` listing all required environment variables (API keys, base URLs, model names, database URLs)
   - Add a comment block at the top explaining that no secrets should be hard-coded

9. **Test framework initialization**
   - Create test directory structure:
     - `tests/mock/` — for future mock-based unit and integration tests
     - `tests/real/` — for future real-LLM tests with `pytest.mark.skipif` (or equivalent)
     - `tests/end_to_end/` — for future end-to-end flow tests
   - Generate framework configuration files (e.g., `conftest.py`, `pytest.ini`, `jest.config.js`)
   - Generate test base classes and utilities (e.g., `MockLLMClient`, `TestDataFactory`)
   - **Do NOT generate** specific test cases at this stage — those are generated by `devforge-module-design`
   - Generate `tests/README.md` documenting test organization rules

10. **Documentation sync rules**
   - Generate `docs/sync-rules.md` mapping:
     - Code change type -> Documents to update
   - Example rows:
     - `src/l*/` code changes -> `src/l*/tests/README.md` + `docs/*.xml`
     - Function signature change -> corresponding `component-spec.xml`
     - New module directory -> `architecture.xml` + module registry update
   - Generate `docs/architecture/sync-rules.md` for architecture-specific mappings:
     - System interface change -> propagate to affected `module-architecture.xml` Constraints
     - Component signature change -> verify against `INTERFACE_CONTRACT.md`
     - New error code -> update all relevant XML `ErrorCodes` and `ErrorHandling` nodes

11. **Architecture Decision Record (ADR)**
    - Generate `PROJECT_SCAFFOLD/docs/ADR.md`
    - Transform `DECISION_LOG.md` entries into human-readable ADR format:
      - Status: Accepted / Deprecated / Superseded
      - Context: What forces were at play
      - Decision: What was decided
      - Consequences: Positive and negative

12. **Decision Log and Changelog**
    - Append scaffolding decisions to `skill/artifacts/DECISION_LOG.md`
    - Generate `skill/artifacts/PROJECT_SCAFFOLD/CHANGELOG.md` with an initial entry

13. **Self-validation: generated artifacts**
    - Run automated checks on all generated files BEFORE proceeding:
      - **Syntax validation**: For each generated code file, verify syntactic validity:
        - Python: `python -m py_compile <file>` must pass
        - JavaScript/TypeScript: `npx tsc --noEmit` (if tsconfig exists) or `node --check` for JS
        - Java: `javac -d /tmp/compiled <file>` must compile (stub main if needed)
        - Go: `go build ./...` must pass
        - YAML: `python -c "import yaml; yaml.safe_load(open('<file>'))"` must pass
        - JSON: `python -m json.tool <file>` must pass
      - **XML validation**: Run `scripts/architecture-ci.sh` on all `*.xml` files
    - If any check fails, regenerate the failing file before proceeding

14. **Internal verification**
    - Verify that:
      - All generated file paths match the planned structure
      - All interface signatures in generated code match `INTERFACE_CONTRACT.md`
      - `.env.template` covers all external dependencies mentioned in architecture
      - CI config references existing test directories

15. **Traceability audit**
    - Randomly sample 3-5 generated files
    - For each file, answer:
      - What PRD requirement does this file trace back to?
      - What INTERFACE_CONTRACT entry does its signature trace back to?
      - Does its state management match the XML StateModel?
    - If any answer is untraceable, mark as traceability gap and append to STATE.md Known Pitfalls

16. **State update**
    - Update `STATE.md`:
      - Append to **Completed Steps**: `[YYYY-MM-DD HH:MM] devforge-project-scaffolding: Generated PROJECT_SCAFFOLD with [N] files`
      - Update **Current State**: `phase: scaffolding_completed`, DIVE `Implement: infrastructure_completed`, `Verify: pending`, `Evolve: pending`
   - Update `docs/architecture/INDEX.md` with generated artifact links

17. **Human gate**
    - Present a summary of generated files (bullet list)
    - Say exactly: "项目基础设施已生成，包含工程目录、CI/CD 配置、测试框架、文档同步规则和环境变量模板。业务代码将在模块详细设计阶段生成。请确认当前阶段输出。回复 [APPROVE] 进入模块详细设计阶段，或提出修改意见。"
    - Then list all available commands:
      ```
      可用命令：
      - [APPROVE] — 批准并继续（进入模块详细设计阶段）
      - [PAUSE] — 暂停当前阶段，保留上下文
      - [ROLLBACK {step_id}] — 回滚到指定步骤重新执行
      - [EDIT {file_path}] — 手动编辑文件后让 AI 继续
      - [INJECT {context}] — 补充额外上下文约束
      - [SKIP] — 跳过当前可选步骤
      - [EXPLAIN {TraceID}] — 展开解释某个决策/错误的推理链
      ```
    - If user inputs natural language feedback (e.g., "这里需要修改"), treat as modification request — do NOT treat as invalid command; analyze the feedback, apply changes, and re-present the gate with updated output
    - Do NOT mark complete without [APPROVE] or explicit continue command

<HARD-GATE>
Do NOT mark the DevForge workflow as complete until the user replies [APPROVE] or explicitly asks to continue.
</HARD-GATE>

## Output Specification

- `skill/artifacts/PROJECT_SCAFFOLD/` containing concrete, runnable files
- `skill/artifacts/PROJECT_SCAFFOLD/.env.template`
- `skill/artifacts/PROJECT_SCAFFOLD/docs/sync-rules.md`
- `skill/artifacts/PROJECT_SCAFFOLD/docs/ADR.md`
- `skill/artifacts/PROJECT_SCAFFOLD/CHANGELOG.md`
- Code reasoning comments in every core module header
- Inline TODOs for every DESIGN_REVIEW Must Fix / Should Fix issue
- No placeholder text or abstract suggestions allowed

## Red Flags

- Do NOT output vague advice like "you should add error handling"
- Do NOT skip the CI/CD config
- Do NOT proceed without the human gate
- Do NOT forget to inject logging into tests
- Do NOT generate hard-coded API keys or secrets in any file
- Do NOT create interface signatures that contradict `INTERFACE_CONTRACT.md`
- Do NOT generate function signatures or business logic placeholders in this phase
- Do NOT create test cases — only test framework and directory structure
