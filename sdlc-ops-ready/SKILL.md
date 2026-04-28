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
