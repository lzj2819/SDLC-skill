# SDLC-skill P1 运维与可视化增强 — 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 创建两个独立 skill —— `sdlc-visualization`（架构可视化图表生成）和 `sdlc-ops-ready`（生产就绪基础设施生成），扩展 SDLC-skill 的生产交付能力。

**Architecture:** `sdlc-visualization` 解析 `architecture.xml` 产出 Mermaid 图表；`sdlc-ops-ready` 基于架构推断资源需求，生成 Terraform + K8s + 监控配置。两者均为独立 skill，通过用户显式触发调用。

**Tech Stack:** Markdown (SKILL.md)、Mermaid 语法、Terraform HCL、Kubernetes YAML、Prometheus/Grafana 配置

---

## 文件变更清单

| 文件 | 操作 | 说明 |
|------|------|------|
| `sdlc-visualization/SKILL.md` | 创建 | 新 skill：架构可视化 |
| `sdlc-ops-ready/SKILL.md` | 创建 | 新 skill：生产就绪基础设施 |
| `sdlc-ops-ready/references/aws-modules.md` | 创建 | AWS 特定资源映射 |
| `sdlc-ops-ready/references/azure-modules.md` | 创建 | Azure 特定资源映射 |
| `sdlc-ops-ready/references/gcp-modules.md` | 创建 | GCP 特定资源映射 |
| `sdlc-ops-ready/references/k8s-best-practices.md` | 创建 | K8s 通用最佳实践 |
| `软件开发全流程智能体技能(SDLC-Skill).md` | 修改 | 在总览中注册 P1 新 skill |

---

### Task 1: 创建 sdlc-visualization/SKILL.md

**Files:**
- Create: `sdlc-visualization/SKILL.md`

- [ ] **Step 1: 创建目录**

```bash
mkdir -p sdlc-visualization
```

- [ ] **Step 2: 编写 SKILL.md**

文件内容见下方完整模板。必须包含：
- 触发条件：`[VISUALIZE]` 或 "生成架构图"
- 输入：`architecture.xml` + `module-architecture.xml`（如有）
- 输出：4 个 Mermaid 图表文件
- 工作流：解析 XML → 生成系统上下文图 / 模块交互时序图 / 数据流图 / ER 图
- VCMF checkpoints

```markdown
---
name: sdlc-visualization
description: Use when a system architecture has been designed and the user wants visual diagrams (system context, module interaction, data flow, ER diagram) generated from the architecture XML. Trigger when user says [VISUALIZE] or "generate architecture diagrams".
---

# SDLC Visualization

## Overview

Generate visual architecture diagrams from an approved `architecture.xml`. This skill parses the XML model and produces Mermaid-syntax diagrams that can be rendered in Markdown viewers, documentation sites, and GitHub.

## VCMF Checkpoints

| Principle | Checkpoint in this Skill |
|-----------|--------------------------|
| Design as Contract | Diagrams must match `architecture.xml` exactly; no invented modules or interfaces |
| Interface as Boundary | Sequence diagram messages must match `Interface` definitions |
| Reality as Baseline | ER diagram relationships must have `Relationships` node or `Coupling` support |

## When to Use

- The user has approved an architecture and wants visual diagrams
- The user types `[VISUALIZE]` or says "generate architecture diagrams"
- Can be invoked after `sdlc-architecture-design` or at any time when `architecture.xml` exists

## Precondition Check

Read `skill/artifacts/STATE.md`. Acceptable phases: `architecture_design_completed`, `architecture_validated`, `design_review_completed`, `scaffolding_completed`, `module_design_completed`.

If `architecture.xml` is missing, stop and instruct the user to complete `sdlc-architecture-design` first.

## Workflow

1. **Parse architecture XML**
   - Read `skill/artifacts/architecture.xml` (or `docs/architecture/system/architecture.xml`)
   - Read module-level XMLs if available (`modules/{id}/module-architecture.xml`)
   - Build internal graph: modules, couplings, interfaces, data models

2. **Generate System Context Diagram**
   - Output: `docs/architecture/diagrams/system-context.mmd`
   - Mermaid syntax: `graph TD`
   - Nodes: User, External Systems (inferred from `Coupling`), each `Module`
   - Edges: API calls, data flows, event streams
   - Style: User = external actor (circle), Modules = boxes, External = clouds

3. **Generate Module Interaction Sequence Diagram**
   - Output: `docs/architecture/diagrams/module-interaction.mmd`
   - Mermaid syntax: `sequenceDiagram`
   - Select one core user story (from PRD) and trace module interactions
   - Each `Module` = participant
   - Each `Interface` method = message arrow
   - Include auth check and error response paths

4. **Generate Data Flow Diagram**
   - Output: `docs/architecture/diagrams/data-flow.mmd`
   - Mermaid syntax: `graph LR`
   - Nodes: Data sources, `Module`s, storage systems (from `StateModel`), external sinks
   - Edges: Data transformations, CRUD operations
   - Highlight: state ownership (who writes, who reads)

5. **Generate ER Diagram**
   - Output: `docs/architecture/diagrams/er-diagram.mmd`
   - Mermaid syntax: `erDiagram`
   - Each `DataModel` = entity with fields listed
   - Each `Relationships/Relationship` = relationship line with cardinality
   - Include primary key markers

6. **Consistency check**
   - Verify every module in diagrams exists in `architecture.xml`
   - Verify every interface in sequence diagram exists in `INTERFACE_CONTRACT.md`
   - Verify every entity in ER diagram exists in `DataModel`

7. **State update**
   - Update `STATE.md`: append to Completed Steps

8. **Human gate**
   - Present diagram summary: "已生成 4 张架构图：系统上下文图、模块交互时序图、数据流图、ER 图。请确认当前阶段输出。回复 [APPROVE] 完成，或提出修改意见。"

## Output Specification

- `docs/architecture/diagrams/system-context.mmd`
- `docs/architecture/diagrams/module-interaction.mmd`
- `docs/architecture/diagrams/data-flow.mmd`
- `docs/architecture/diagrams/er-diagram.mmd`

## Red Flags

- Do NOT invent modules not in `architecture.xml`
- Do NOT draw interfaces not in `INTERFACE_CONTRACT.md`
- Do NOT generate diagrams if `architecture.xml` is missing or unapproved
```

- [ ] **Step 3: 验证文件结构**

```bash
ls sdlc-visualization/SKILL.md
head -n 5 sdlc-visualization/SKILL.md
```

- [ ] **Step 4: 提交**

```bash
git add sdlc-visualization/
git commit -m "feat(visualization): add sdlc-visualization skill

- Generate 4 Mermaid diagrams from architecture.xml
- System context, module interaction, data flow, ER diagram
- VCMF checkpoints for diagram accuracy
- Human gate with [APPROVE] trigger

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

### Task 2: 创建 sdlc-ops-ready/SKILL.md

**Files:**
- Create: `sdlc-ops-ready/SKILL.md`
- Create: `sdlc-ops-ready/references/` (4 files)

- [ ] **Step 1: 创建目录**

```bash
mkdir -p sdlc-ops-ready/references
```

- [ ] **Step 2: 编写 SKILL.md**

```markdown
---
name: sdlc-ops-ready
description: Use when a project has completed scaffolding and the user needs production-ready infrastructure — Terraform, Kubernetes manifests, monitoring, and multi-environment deployment. Trigger when user says [OPS] or "generate deployment config".
---

# SDLC Ops Ready

## Overview

Generate production-grade infrastructure as code (IaC) from an approved architecture. This skill infers resource requirements from `architecture.xml`, produces Terraform configurations, Kubernetes manifests, monitoring setups, and an operational runbook.

## VCMF Checkpoints

| Principle | Checkpoint in this Skill |
|-----------|--------------------------|
| Design as Contract | Terraform resources must map 1:1 to `Module` nodes; no phantom resources |
| Interface as Boundary | K8s service ports must match `Interface` definitions |
| Reality as Baseline | Monitoring metrics must be collectable; no theoretical metrics |
| State as Responsibility | Database and cache persistence policies must match `StateModel` |

## When to Use

- The user has completed scaffolding and wants production deployment configs
- The user types `[OPS]` or says "generate deployment config"
- Do NOT use if `architecture.xml` has not been approved

## Precondition Check

Read `skill/artifacts/STATE.md`. Acceptable phases: `scaffolding_completed`, `module_design_completed`, `iteration_planning_completed`.

If `architecture.xml` is missing, stop and instruct the user to complete prior phases first.

## Workflow

1. **Cloud platform selection**
   - Ask user: AWS / Azure / GCP / Private Cloud (default: AWS)
   - Load corresponding reference file from `references/{platform}-modules.md`

2. **Resource requirement inference**
   - Read `architecture.xml` and count `Module` nodes → number of services
   - Read `StateModel` nodes → database, cache, blob storage requirements
   - Read `Security` nodes → network isolation, TLS, encryption-at-rest requirements
   - Estimate resource sizing per module (CPU/memory based on module complexity)

3. **Terraform generation**
   - Output: `infrastructure/terraform/`
   - Structure:
     - `main.tf` — orchestrates all modules
     - `variables.tf` — environment-specific variables
     - `outputs.tf` — exported endpoints and credentials
     - `modules/network/` — VPC, subnets, security groups, NAT gateway
     - `modules/compute/` — container service (ECS/EKS/AKS/GKE) or VM
     - `modules/database/` — managed DB (RDS/Cloud SQL/Aurora) + replicas
     - `modules/cache/` — Redis/ElastiCache/MemoryStore
     - `modules/storage/` — S3/Blob/GCS for static assets and backups
   - Each `Module` in XML → one compute resource group
   - Each `StateModel` with `location="PostgreSQL"` → one DB instance
   - Each `StateModel` with `location="Redis"` → one cache cluster

4. **Kubernetes manifests generation**
   - Output: `infrastructure/kubernetes/`
   - Use Kustomize for environment management:
     - `base/` — shared manifests (deployment, service, ingress, HPA)
     - `overlays/dev/` — dev environment patches
     - `overlays/staging/` — staging patches
     - `overlays/prod/` — production patches (replicas, resources, anti-affinity)
   - Per module:
     - `deployment.yaml` — container spec, env vars, health probes
     - `service.yaml` — cluster IP, port mapping from `Interface`
     - `hpa.yaml` — HorizontalPodAutoscaler (CPU/memory thresholds)
   - Shared:
     - `ingress.yaml` — route rules per module interface
     - `configmap.yaml` — non-secret config
     - `secret.yaml` — encrypted secrets (placeholder)

5. **Monitoring configuration generation**
   - Output: `infrastructure/monitoring/`
   - Prometheus rules (`prometheus/rules.yml`):
     - Auto-generate RED metrics per module interface:
       - Rate: `rate(http_requests_total{module="X"}[5m])`
       - Errors: `rate(http_requests_total{module="X",status=~"5.."}[5m])`
       - Duration: `histogram_quantile(0.99, rate(http_request_duration_seconds_bucket{module="X"}[5m]))`
     - Alert rules:
       - High error rate (> 1% for 5m)
       - High latency (p99 > 500ms for 5m)
       - Low request rate (drop > 50% for 10m)
   - Grafana dashboards (`grafana/dashboards/system.json`):
     - Row per module
     - Panels: request rate, error rate, latency distribution, resource usage

6. **Multi-environment configuration**
   - Output: `infrastructure/multi-env/`
   - Terraform workspace setup (`dev`, `staging`, `prod`)
   - Environment-specific variable files:
     - `dev.tfvars` — minimal resources, debug logging
     - `staging.tfvars` — medium resources, pre-prod data
     - `prod.tfvars` — high resources, encryption, backup, multi-AZ

7. **Operational runbook generation**
   - Output: `docs/ops/runbook.md`
   - Sections:
     - Deployment procedure (Terraform apply order)
     - Rollback procedure (terraform plan + state backup)
     - Scaling guide (when to trigger HPA vs upgrade nodes)
     - Alert response (for each Prometheus rule, include diagnosis steps)
     - Security response (credential rotation, incident containment)

8. **State update**
   - Update `STATE.md`: append to Completed Steps

9. **Human gate**
   - Present summary: "生产就绪基础设施已生成，包含 Terraform、K8s、监控和多环境配置。请确认当前阶段输出。回复 [APPROVE] 完成，或提出修改意见。"

## Output Specification

- `infrastructure/terraform/` — Terraform modules and root config
- `infrastructure/kubernetes/` — K8s manifests with Kustomize
- `infrastructure/monitoring/` — Prometheus rules + Grafana dashboards
- `infrastructure/multi-env/` — Environment-specific configs
- `docs/ops/runbook.md` — Operational manual

## Red Flags

- Do NOT generate resources not traceable to a `Module` or `StateModel`
- Do NOT skip the monitoring configuration
- Do NOT generate hard-coded credentials or secrets
- Do NOT proceed without the human gate
```

- [ ] **Step 3: 创建 references 文件**

**aws-modules.md:**
```markdown
# AWS Resource Mapping

## Compute
| Architecture Module | AWS Resource | Notes |
|---------------------|--------------|-------|
| Entry-point module | ECS Service + ALB | Or EKS Deployment + Ingress |
| Internal service | ECS Service (private) | No public ALB |
| Background worker | ECS Service + SQS | Event-driven processing |

## Database
| StateModel Location | AWS Resource | Notes |
|---------------------|--------------|-------|
| PostgreSQL | RDS PostgreSQL | Multi-AZ for prod |
| MySQL | RDS MySQL | |
| Redis | ElastiCache Redis | Cluster mode for prod |
| MongoDB | DocumentDB | |

## Storage
| Use Case | AWS Resource |
|----------|--------------|
| Static assets | S3 + CloudFront |
| Backups | S3 ( Glacier for long-term) |
| Logs | CloudWatch Logs |

## Network
- VPC with public + private subnets
- NAT Gateway for outbound from private subnets
- Security Groups per module (least privilege)
- AWS WAF for public-facing ALB
```

**azure-modules.md:**
```markdown
# Azure Resource Mapping

## Compute
| Architecture Module | Azure Resource | Notes |
|---------------------|----------------|-------|
| Entry-point module | Container Apps / AKS | AKS for complex microservices |
| Internal service | Container Apps (internal) | |
| Background worker | Container Instances + Service Bus | |

## Database
| StateModel Location | Azure Resource | Notes |
|---------------------|----------------|-------|
| PostgreSQL | Azure Database for PostgreSQL | Flexible Server |
| MySQL | Azure Database for MySQL | |
| Redis | Azure Cache for Redis | Enterprise tier for cluster |
| SQL Server | Azure SQL Database | |

## Storage
| Use Case | Azure Resource |
|----------|----------------|
| Static assets | Blob Storage + CDN |
| Backups | Blob Storage (Cool tier) |
| Logs | Log Analytics |

## Network
- VNet with subnets
- NSG per subnet
- Azure Firewall for egress control
- Application Gateway for ingress
```

**gcp-modules.md:**
```markdown
# GCP Resource Mapping

## Compute
| Architecture Module | GCP Resource | Notes |
|---------------------|--------------|-------|
| Entry-point module | Cloud Run / GKE | Cloud Run for simple, GKE for complex |
| Internal service | Cloud Run (internal) | VPC connector |
| Background worker | Cloud Run Jobs + Pub/Sub | |

## Database
| StateModel Location | GCP Resource | Notes |
|---------------------|--------------|-------|
| PostgreSQL | Cloud SQL PostgreSQL | High availability for prod |
| MySQL | Cloud SQL MySQL | |
| Redis | Memorystore Redis | |
| Firestore | Firestore Native | |

## Storage
| Use Case | GCP Resource |
|----------|--------------|
| Static assets | Cloud Storage + Cloud CDN |
| Backups | Cloud Storage (Nearline) |
| Logs | Cloud Logging |

## Network
- VPC with subnets
- Cloud NAT for private egress
- Cloud Armor for WAF
- Cloud Load Balancing for ingress
```

**k8s-best-practices.md:**
```markdown
# Kubernetes Best Practices

## General
- Use Kustomize for environment management
- One Deployment per microservice module
- Use ConfigMaps for non-secret config, Secrets for sensitive data
- Liveness and Readiness probes on every container
- Resource requests and limits on every container

## Security
- Run containers as non-root
- Use NetworkPolicies for inter-service traffic control
- Enable Pod Security Standards (restricted)
- Use cert-manager for TLS certificates

## Observability
- Prometheus Operator for metrics collection
- Fluentd/Fluent Bit for log aggregation
- Jaeger/Tempo for distributed tracing (if needed)

## Scaling
- HPA based on CPU (target 70%) and memory (target 80%)
- VPA for right-sizing recommendations (optional)
- Cluster Autoscaler for node scaling

## Reliability
- PodDisruptionBudget for critical services
- TopologySpreadConstraints for AZ distribution
- Anti-affinity for stateful services
```

- [ ] **Step 4: 提交**

```bash
git add sdlc-ops-ready/
git commit -m "feat(ops-ready): add sdlc-ops-ready skill with cloud references

- Generate Terraform, K8s, monitoring, and multi-env configs
- Support AWS, Azure, GCP via reference modules
- Include K8s best practices guide
- Auto-generate RED metrics and Grafana dashboards
- Produce operational runbook

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

### Task 3: 更新根目录 SKILL.md 注册新 skill

**Files:**
- Modify: `软件开发全流程智能体技能(SDLC-Skill).md`

- [ ] **Step 1: 在总览中增加 P1 skill 的说明**

找到文件末尾的 Workflow 部分（Phase 五之后），在 Phase 七之后追加：

```markdown
### **阶段八：架构可视化（可选）(Phase 8: Visualization)**

**触发条件**：用户输入 `[VISUALIZE]` 或要求生成架构图。

**执行动作**：

1. 解析 `architecture.xml` 生成 Mermaid 图表：
   - 系统上下文图：展示系统与外部依赖的交互
   - 模块交互时序图：展示核心用户故事的模块调用链
   - 数据流图：展示数据在模块间的流转
   - ER 图：展示实体关系
2. 输出到 `docs/architecture/diagrams/`

---

### **阶段九：生产就绪基础设施（可选）(Phase 9: Ops Ready)**

**触发条件**：用户输入 `[OPS]` 或要求生成部署配置。

**执行动作**：

1. 资源需求推断：根据模块数量和状态模型推断计算/存储/缓存需求
2. 生成 Terraform 配置（网络、计算、数据库、缓存分层）
3. 生成 K8s manifests（Kustomize 管理多环境）
4. 生成监控配置（Prometheus RED 指标 + Grafana 仪表盘）
5. 生成多环境配置（dev/staging/prod）
6. 生成运维手册（部署、回滚、扩容、告警响应）
```

- [ ] **Step 2: 提交**

```bash
git add 软件开发全流程智能体技能\(SDLC-Skill\).md
git commit -m "docs: register P1 skills in main SDLC overview

- Add Phase 8: Visualization (sdlc-visualization)
- Add Phase 9: Ops Ready (sdlc-ops-ready)

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

### Task 4: P1 一致性验证

- [ ] **Step 1: 验证所有新文件存在**

```bash
ls sdlc-visualization/SKILL.md
ls sdlc-ops-ready/SKILL.md
ls sdlc-ops-ready/references/aws-modules.md
ls sdlc-ops-ready/references/azure-modules.md
ls sdlc-ops-ready/references/gcp-modules.md
ls sdlc-ops-ready/references/k8s-best-practices.md
```

- [ ] **Step 2: 验证提交历史**

```bash
git log --oneline -5
```
Expected: 能看到 P1 相关的提交。

- [ ] **Step 3: 验证根目录 SKILL.md 更新**

```bash
grep -n "阶段八" 软件开发全流程智能体技能\(SDLC-Skill\).md
grep -n "阶段九" 软件开发全流程智能体技能\(SDLC-Skill\).md
```

---

## Spec 覆盖度检查

| Spec 要求 | 实现任务 | 状态 |
|-----------|----------|------|
| sdlc-visualization skill | Task 1 | ✅ |
| 4 类 Mermaid 图表 | Task 1 | ✅ |
| sdlc-ops-ready skill | Task 2 | ✅ |
| Terraform 生成 | Task 2 | ✅ |
| K8s manifests 生成 | Task 2 | ✅ |
| 监控配置生成 | Task 2 | ✅ |
| 多环境配置 | Task 2 | ✅ |
| 运维手册生成 | Task 2 | ✅ |
| 云平台参考模块 | Task 2 | ✅ |
| 根目录 SKILL.md 注册 | Task 3 | ✅ |
