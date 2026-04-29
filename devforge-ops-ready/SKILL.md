---
name: devforge-ops-ready
description: Use when a project has completed scaffolding and the user needs production-ready infrastructure — Terraform, Kubernetes manifests, monitoring, and multi-environment deployment. Trigger when user says [OPS] or "generate deployment config".
---

# DevForge Ops Ready

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

## Language Adaptation

- System instructions and constraints in this skill are in English for maximum model compliance
- User-facing gate messages, summaries, and explanations use the same language as the user's most recent input
- If the user writes in Chinese, respond in Chinese. If English, respond in English

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

7. **Progressive deployment strategy**
   - Output: `infrastructure/kubernetes/overlays/prod/progressive/`
   - Generate K8s manifests for two deployment strategies:

     **Blue-Green Deployment** (`blue-green/`):
     - Two identical environments (blue = current, green = new)
     - Service selector switches traffic from blue to green after health check
     - Instant rollback: switch selector back to blue
     - Resource cost: 2x during transition

     **Canary Deployment** (`canary/`):
     - Primary deployment (100% traffic) + Canary deployment (5% traffic)
     - Traffic splitting via Ingress (nginx canary annotations or Istio VirtualService)
     - Automated promotion criteria:
       - Error rate < 1% for 10 minutes
       - P99 latency < baseline + 20% for 10 minutes
     - Automated rollback criteria:
       - Error rate > 5% for 2 minutes
       - P99 latency > baseline + 50% for 2 minutes
     - Gradual traffic shift: 5% → 25% → 50% → 100%

   - Generate `promotion-policy.yaml` defining the criteria and thresholds
   - Generate `rollback-policy.yaml` defining emergency rollback triggers

8. **Operational runbook generation**
   - Output: `docs/ops/runbook.md`
   - Sections:
     - Deployment procedure (Terraform apply order)
     - Rollback procedure (terraform plan + state backup)
     - Scaling guide (when to trigger HPA vs upgrade nodes)
     - Alert response (for each Prometheus rule, include diagnosis steps)
     - Security response (credential rotation, incident containment)

9. **Tool and config validation**
   - Before finalizing, verify infrastructure artifacts:
     - **Tool version validation**: For every third-party tool referenced (Terraform providers, Helm charts, Prometheus Operator, Istio), perform active search:
       - Search: "{tool_name} deprecated", "{tool_name} CVE", "{tool_name} maintenance status"
       - Verify last release/commit within 12 months
       - Flag any deprecation notice or security advisory
       - Follow the same 3-layer validation rule as `devforge-architecture-design` (Active Search → Knowledge Verification → Blacklist Enforcement)
     - **Terraform syntax validation**: Run `terraform fmt -check` and `terraform validate` (if Terraform CLI is available) or visually verify HCL syntax correctness
     - **Kubernetes manifest validation**: Verify all generated YAML is valid (`kubectl --dry-run=client apply -f` if cluster available, or YAML syntax check via `python -c "import yaml; yaml.safe_load(open('file'))"`)
     - **Prometheus rule validation**: Verify PromQL expressions are syntactically valid (search for known PromQL syntax if unsure)
     - **Resource traceability**: Confirm every Terraform resource and K8s manifest maps to at least one `Module` or `StateModel` in `architecture.xml`
   - If any check fails, fix the infrastructure artifacts before proceeding

10. **State update**
   - Update `STATE.md`: append to Completed Steps

11. **Human gate**
   - Present summary: "生产就绪基础设施已生成，包含 Terraform、K8s、监控和多环境配置。请确认当前阶段输出。回复 [APPROVE] 完成，或提出修改意见。"

## Output Specification

- `infrastructure/terraform/` — Terraform modules and root config
- `infrastructure/kubernetes/` — K8s manifests with Kustomize
- `infrastructure/kubernetes/overlays/prod/progressive/blue-green/` — Blue-green deployment manifests
- `infrastructure/kubernetes/overlays/prod/progressive/canary/` — Canary deployment manifests
- `infrastructure/kubernetes/overlays/prod/progressive/promotion-policy.yaml` — Promotion criteria
- `infrastructure/kubernetes/overlays/prod/progressive/rollback-policy.yaml` — Rollback triggers
- `infrastructure/monitoring/` — Prometheus rules + Grafana dashboards
- `infrastructure/multi-env/` — Environment-specific configs
- `docs/ops/runbook.md` — Operational manual

## Red Flags

- Do NOT generate resources not traceable to a `Module` or `StateModel`
- Do NOT skip the monitoring configuration
- Do NOT generate hard-coded credentials or secrets
- Do NOT proceed without the human gate
