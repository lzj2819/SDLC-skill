# DevForge Ops Ready 流程深度分析

> 基于 DevForge SDLC Skill Chain v1.4 的 `devforge-ops-ready/SKILL.md` 及其关联工具规范文档进行系统性分析。
>
> **定位**：生产就绪基础设施生成 Skill，负责将 `architecture.xml` 转换为可部署的 Terraform、Kubernetes、监控和运维配置。

---

## 一、定位与核心区别

### 1.1 Skill 定位

`devforge-ops-ready` 是 DevForge SDLC Skill Chain 中专门负责**生产就绪基础设施**的独立 Skill。它的职责是：**将已批准的 `architecture.xml` 解析并转换为可执行的基础设施即代码（IaC）**，包括云资源编排（Terraform）、容器编排（Kubernetes）、监控告警（Prometheus + Grafana）、多环境管理和渐进部署策略。

与其他技能的关系：

| 维度 | `devforge-project-scaffolding` | `devforge-ops-ready` |
|------|------------------------------|---------------------|
| **职责** | 生成项目工程目录、CI/CD 配置、测试框架 | **生成生产基础设施、K8s 部署、监控、运维手册** |
| **输出** | `PROJECT_SCAFFOLD/` 目录结构、`.env.template` | **`infrastructure/` 目录、Terraform、K8s manifests、监控规则** |
| **面向阶段** | 开发阶段（Implement） | **运维阶段（Operate）** |
| **是否必经** | 是 | **否（可选）** |
| **DIVE 阶段** | Implement | **Operate** |

### 1.2 为什么需要独立的 Ops Ready Skill

> **设计意图**：
> 1. **关注点分离**：项目脚手架（scaffolding）负责开发环境的基础设施（如本地 docker-compose），而 ops-ready 负责生产环境的云基础设施。两者目标不同、复杂度不同
> 2. **阶段分离**： scaffolding 在模块设计前运行，ops-ready 在测试完成后运行。生产基础设施需要基于完整的架构和模块设计来推断资源需求
> 3. **专业技能要求**：生产基础设施涉及云平台、容器编排、监控、安全策略等专业知识，独立的 Skill 可以集中处理这些复杂逻辑
> 4. **可选性**：并非所有项目都需要生产级部署（如原型、内部工具），将 ops-ready 设计为可选步骤，避免不必要的开销

### 1.3 与 scaffolding 中生成的部署拓扑的区别

| 特性 | scaffolding 中的部署拓扑 | ops-ready 中的基础设施 |
|------|------------------------|----------------------|
| **目标环境** | 本地开发 / 测试 | **生产环境** |
| **技术栈** | `docker-compose.yml`（简单） | **Terraform + K8s + 监控**（完整） |
| **资源管理** | 手动配置 | **IaC 自动编排** |
| **多环境** | 单一环境 | **dev / staging / prod + Kustomize** |
| **监控** | 无 | **Prometheus + Grafana + 告警规则** |
| **渐进部署** | 无 | **蓝绿部署 + 金丝雀发布** |
| **服务网格** | 无 | **Istio（微服务架构时）** |

> **设计意图**：scaffolding 阶段的 `docker-compose.yml` 是为了让开发者快速在本地运行系统；ops-ready 阶段的 Terraform + K8s 是为了在生产环境稳定、可扩展、可监控地运行系统。两者互补而非替代。

---

## 二、触发条件与前置检查

### 2.1 触发条件

| 触发方式 | 场景 | 说明 |
|----------|------|------|
| **用户输入 `[OPS]`** | 测试完成后，用户需要生产部署配置 | 最常见的触发方式 |
| **自然语言触发** | 用户说 "generate deployment config" 或 "生成部署配置" | Skill 描述中定义的关键词匹配 |
| **架构更新后重新生成** | `architecture.xml` 发生变更后 | 可多次触发，基础设施配置会相应更新 |

### 2.2 前置条件校验

根据 `skill/tools/precondition-checker.md`：

| 校验项 | 要求 |
|--------|------|
| **Acceptable Phases** | `scaffolding_completed`, `module_design_completed`, `iteration_planning_completed` |
| **Minimum Phase** | `scaffolding_completed` |
| **Required Artifact** | `architecture.xml` |

**不满足条件时的行为**：
- 如果阶段早于 `scaffolding_completed` → 停止执行，提示用户先完成 `devforge-project-scaffolding`
- 如果 `architecture.xml` 不存在 → 停止执行，提示用户先完成 `devforge-architecture-design`

### 2.3 为什么要求 scaffolding_completed

> **设计意图**：
> - `scaffolding_completed` 意味着项目已经有了基本的工程结构和目录
> - ops-ready 生成的 `infrastructure/` 目录需要放入已存在的项目结构中
> - 此外，ops-ready 需要读取 `architecture.xml` 来推断资源需求，而 scaffolding 阶段已经将 architecture artifacts 复制到 `docs/architecture/` 目录
>
> **注意**：虽然 precondition-checker.md 中标记 ops-ready 的 minimum phase 为 `test_execution_completed`，但 SKILL.md 中明确接受 `scaffolding_completed`+。这反映了 ops-ready 的灵活性——可以在测试完成前就生成基础设施（用于提前准备环境），但通常在实际部署前运行。

---

## 三、输出产物

`devforge-ops-ready` 生成完整的生产基础设施配置，按技术栈组织目录：

| 产物目录 | 路径 | 内容 | 用途 |
|----------|------|------|------|
| **Terraform** | `infrastructure/terraform/` | 云资源编排配置 | 自动创建/管理云资源 |
| **Kubernetes** | `infrastructure/kubernetes/` | K8s 部署清单 + Kustomize | 容器编排和部署 |
| **渐进部署** | `infrastructure/kubernetes/overlays/prod/progressive/` | 蓝绿部署 + 金丝雀发布配置 | 零停机发布和回滚 |
| **监控** | `infrastructure/monitoring/` | Prometheus 规则 + Grafana 仪表盘 | 可观测性和告警 |
| **多环境** | `infrastructure/multi-env/` | 环境特定变量文件 | dev/staging/prod 差异化配置 |
| **服务网格** | `infrastructure/istio/` | VirtualService、DestinationRule、Gateway | 微服务流量管理（可选） |
| **可观测性** | `infrastructure/otel/` | OpenTelemetry Collector + Jaeger | 分布式追踪（可选） |
| **密钥管理** | `infrastructure/vault/` | Vault 策略和动态密钥配置 | 密钥轮换（可选） |
| **网络策略** | `infrastructure/network-policies/` | K8s NetworkPolicy | 零信任网络安全（可选） |
| **运维手册** | `docs/ops/runbook.md` | 部署、回滚、扩容、告警响应手册 | 运维团队操作指南 |

### 3.1 产物总览图

```
infrastructure/
├── terraform/
│   ├── main.tf              # 编排所有模块
│   ├── variables.tf         # 环境变量定义
│   ├── outputs.tf           # 输出端点/凭证
│   └── modules/
│       ├── network/         # VPC、子网、安全组
│       ├── compute/         # 容器服务/虚拟机
│       ├── database/        # 托管数据库 + 副本
│       ├── cache/           # Redis/ElastiCache
│       └── storage/         # 对象存储
├── kubernetes/
│   ├── base/
│   │   ├── deployment.yaml  # 容器规格、健康探针
│   │   ├── service.yaml     # ClusterIP、端口映射
│   │   ├── ingress.yaml     # 路由规则
│   │   ├── hpa.yaml         # 水平自动扩缩容
│   │   ├── configmap.yaml   # 非敏感配置
│   │   └── secret.yaml      # 加密密钥（占位）
│   └── overlays/
│       ├── dev/             # 开发环境补丁
│       ├── staging/         # 预发布环境补丁
│       └── prod/            # 生产环境补丁
│           └── progressive/
│               ├── blue-green/    # 蓝绿部署
│               ├── canary/        # 金丝雀发布
│               ├── promotion-policy.yaml   # 升级策略
│               └── rollback-policy.yaml    # 回滚策略
├── monitoring/
│   ├── prometheus/
│   │   └── rules.yml        # RED 指标 + 告警规则
│   └── grafana/
│       └── dashboards/
│           └── system.json  # 模块级仪表盘
├── multi-env/
│   ├── dev.tfvars           # 最小资源、调试日志
│   ├── staging.tfvars       # 中等资源、预发布数据
│   └── prod.tfvars          # 高资源、加密、多可用区
├── istio/                   # (微服务时生成)
│   ├── virtualservices.yaml
│   ├── destinationrules.yaml
│   └── gateway.yaml
├── otel/                    # (微服务时生成)
│   ├── otel-collector-config.yaml
│   └── jaeger-deployment.yaml
├── vault/                   # (微服务时生成)
│   ├── vault-policy-{module}.hcl
│   ├── dynamic-secrets.yaml
│   └── kv-secrets.yaml
└── network-policies/        # (微服务时生成)
    ├── default-deny.yaml
    └── {module}-allow.yaml

docs/ops/
└── runbook.md               # 运维手册
```

---

## 四、完整工作流程

`devforge-ops-ready` 的工作流程分为 11 个步骤（含 7a 微服务增强步骤）：

```
Step 1: 云平台选择
    → 询问用户 AWS / Azure / GCP / Private Cloud
    → 加载对应平台参考文件

Step 2: 资源需求推断
    → 解析 architecture.xml
    → Module 数量 → 服务数量
    → StateModel → 数据库/缓存/存储需求
    → Security → 网络隔离/TLS/加密需求
    → 估算资源规格

Step 3: Terraform 生成
    → 生成 main.tf / variables.tf / outputs.tf
    → 生成模块化 Terraform 配置（network/compute/database/cache/storage）

Step 4: Kubernetes manifests 生成
    → 使用 Kustomize 管理多环境
    → 每个 Module → deployment + service + hpa
    → 共享资源 → ingress + configmap + secret

Step 5: 监控配置生成
    → Prometheus RED 指标规则
    → Grafana 仪表盘（每模块一行）
    → 告警规则（错误率/延迟/流量下降）

Step 6: 多环境配置
    → Terraform workspace（dev/staging/prod）
    → 环境特定变量文件

Step 7: 渐进部署策略
    → 蓝绿部署清单
    → 金丝雀发布清单 + 自动升级/回滚策略

Step 7a: 微服务基础设施（条件触发）
    → Istio 服务网格配置
    → OpenTelemetry + Jaeger 追踪
    → Vault 密钥管理
    → K8s NetworkPolicy

Step 8: 运维手册生成
    → 部署流程、回滚流程、扩容指南、告警响应

Step 9: 工具和配置验证
    → 工具版本验证（CVE/弃用检查）
    → Terraform 语法验证
    → K8s YAML 验证
    → PromQL 验证
    → 资源可追溯性检查

Step 10: 状态更新
    → 追加 Completed Steps

Step 11: 人工门控
    → 呈现基础设施摘要，等待用户确认
```

---

### Step 1: 云平台选择

**为什么需要选择云平台**：
> 不同的云平台（AWS、Azure、GCP、私有云）有不同的资源类型、API 和最佳实践。ops-ready 需要根据用户选择的平台生成对应的 Terraform provider 和资源配置。

**选择方式**：
- 直接询问用户：`AWS / Azure / GCP / Private Cloud`
- 默认值：`AWS`（最广泛使用的云平台）

**平台参考文件**：
- `references/aws-modules.md`
- `references/azure-modules.md`
- `references/gcp-modules.md`
- `references/private-cloud-modules.md`

> 这些参考文件定义了各平台的标准模块和配置模式，确保生成的 IaC 遵循云平台的最佳实践。

---

### Step 2: 资源需求推断

这是 ops-ready 的核心逻辑步骤——**从架构 XML 推断需要多少云资源**。

**推断规则**：

| XML 节点 | 推断的资源 | 推断逻辑 |
|----------|-----------|----------|
| `SystemArchitecture/Module` | 计算资源（ECS/EKS 任务、VM） | 每个 Module → 一个 compute resource group |
| `StateModel/State/@location="PostgreSQL"` | 托管数据库（RDS/Cloud SQL） | 每个数据库类型 → 一个 DB 实例 |
| `StateModel/State/@location="Redis"` | 缓存集群（ElastiCache/MemoryStore） | 每个缓存类型 → 一个 cache cluster |
| `StateModel/State/@location="S3"` 或 blob | 对象存储（S3/GCS/Blob） | 一个存储 bucket |
| `Security/Encryption/@inTransit` | TLS 证书/终止 | 在 Ingress/Gateway 上配置 TLS |
| `Security/Encryption/@atRest` | 磁盘加密 | 在 DB/Storage 上启用加密 |
| `Module/Coupling/DependsOn` | 网络连通性 | 安全组规则允许模块间通信 |

**资源规格估算**：
> 基于模块的复杂度（接口数量、StateModel 数量、Coupling 数量）估算 CPU/内存需求：
> - 简单模块（1-2 接口，无状态）：0.5 vCPU / 512MB
> - 中等模块（3-5 接口，有状态）：1 vCPU / 1GB
> - 复杂模块（6+ 接口，高耦合）：2 vCPU / 2GB
> 
> 这种估算不是精确的，但为初始部署提供了合理的起点。实际资源需求应在运行后根据监控数据调整。

---

### Step 3: Terraform 生成

**输出目录**：`infrastructure/terraform/`

**文件结构**：

| 文件/目录 | 用途 | 与 architecture.xml 的映射 |
|----------|------|---------------------------|
| `main.tf` | 根模块，编排所有子模块 | 引用所有子模块 |
| `variables.tf` | 环境变量定义 | 可配置参数（区域、实例类型） |
| `outputs.tf` | 输出端点和凭证 | 数据库地址、负载均衡器 DNS |
| `modules/network/` | VPC、子网、NAT 网关、安全组 | 系统网络基础设施 |
| `modules/compute/` | 容器服务或 VM | 每个 Module 一个资源组 |
| `modules/database/` | 托管数据库 + 副本 | `StateModel` 中声明的数据库 |
| `modules/cache/` | Redis/ElastiCache | `StateModel` 中声明的缓存 |
| `modules/storage/` | 对象存储 | 静态资源和备份存储 |

**映射规则**：

```
architecture.xml Module          →  Terraform compute module resource group
architecture.xml StateModel      →  Terraform database/cache/storage module
architecture.xml Security        →  Terraform encryption + network isolation
architecture.xml Coupling        →  Terraform security group rules
```

**为什么使用模块化 Terraform**：
> 1. **可维护性**：每个云资源类型（网络、计算、数据库）独立管理，变更影响范围可控
> 2. **可复用性**：模块可在多个环境（dev/staging/prod）中复用
> 3. **与架构对齐**：每个 Module 对应一个 compute resource group，保持架构与基础设施的 1:1 映射

---

### Step 4: Kubernetes manifests 生成

**输出目录**：`infrastructure/kubernetes/`

**为什么使用 Kustomize**：
> Kustomize 是 Kubernetes 原生的配置管理工具，无需模板引擎（如 Helm 的 Jinja2），使用 patch 机制管理多环境差异：
> - `base/` 目录包含共享的 manifests
> - `overlays/{env}/` 目录包含环境特定的 patch
> - 这种"基础 + 覆盖"模式与 DevForge 的"XML 权威 + 环境差异"理念一致

**每模块生成的 manifests**：

| Manifest | 内容 | 与 XML 的映射 |
|----------|------|--------------|
| `deployment.yaml` | 容器规格、环境变量、健康探针 | `Module` 的复杂度决定资源请求/限制 |
| `service.yaml` | ClusterIP、端口映射 | `Interface/Input/@protocol` 决定端口 |
| `hpa.yaml` | 水平自动扩缩容（CPU/内存阈值） | 模块接口数量推断并发需求 |

**共享 manifests**：

| Manifest | 内容 |
|----------|------|
| `ingress.yaml` | 路由规则，按模块接口映射路径 |
| `configmap.yaml` | 非敏感配置（如日志级别、超时设置） |
| `secret.yaml` | 加密密钥（占位符，实际值由 Vault/环境注入） |

**Kustomize 结构示例**：

```yaml
# base/kustomization.yaml
resources:
  - deployment.yaml
  - service.yaml
  - ingress.yaml
  - hpa.yaml

# overlays/prod/kustomization.yaml
resources:
  - ../../base
patches:
  - path: replicas-patch.yaml  # 增加副本数
  - path: resources-patch.yaml # 增加资源限制
  - path: affinity-patch.yaml  # 添加反亲和性
```

---

### Step 5: 监控配置生成

**输出目录**：`infrastructure/monitoring/`

**为什么自动生成监控**：
> 生产系统的可观测性不是可选的，而是必需的。ops-ready 自动生成监控配置，确保：
> 1. 每个模块都有对应的监控指标
> 2. 关键告警规则覆盖常见故障场景
> 3. 仪表盘提供系统级视图

**Prometheus RED 指标**：

RED 是云原生监控的黄金指标组合：

| 指标 | PromQL | 用途 | 告警阈值 |
|------|--------|------|----------|
| **Rate** | `rate(http_requests_total{module="X"}[5m])` | 请求速率 | 下降 > 50% 持续 10m |
| **Errors** | `rate(http_requests_total{module="X",status=~"5.."}[5m])` | 错误率 | > 1% 持续 5m |
| **Duration** | `histogram_quantile(0.99, rate(http_request_duration_seconds_bucket{module="X"}[5m]))` | P99 延迟 | > 500ms 持续 5m |

> **设计意图**：RED 指标覆盖了"系统是否健康"的核心问题：
> - Rate → "系统是否在工作？"（流量是否突然下降）
> - Errors → "系统是否在出错？"（错误率是否超标）
> - Duration → "系统是否够快？"（延迟是否增加）

**Grafana 仪表盘结构**：

| Row | 内容 | 来源 |
|-----|------|------|
| Overview | 系统整体请求量、错误率、P99 延迟 | 所有模块聚合 |
| Module: X | 模块 X 的详细指标 | 模块 X 的 RED 指标 |
| Module: Y | 模块 Y 的详细指标 | 模块 Y 的 RED 指标 |
| Infrastructure | CPU、内存、磁盘、网络 | Node exporter / cAdvisor |

---

### Step 6: 多环境配置

**输出目录**：`infrastructure/multi-env/`

**为什么需要多环境**：
> 生产系统通常需要至少 3 个环境：
> - **dev**：开发调试，资源最小化，日志级别 debug
> - **staging**：预发布验证，数据接近生产，用于最终测试
> - **prod**：生产环境，高可用、加密、备份、多可用区

**环境差异化配置**：

| 维度 | dev | staging | prod |
|------|-----|---------|------|
| **资源规格** | 最小（1 副本） | 中等（2 副本） | 高（3+ 副本，多可用区） |
| **日志级别** | debug | info | warn/error |
| **数据** | 空/模拟数据 | 预发布数据集 | 真实生产数据 |
| **加密** | 可选 | 启用 | 强制 + 密钥轮换 |
| **备份** | 无 | 每日 | 实时 + 跨区域 |
| **监控** | 基础 | 完整 | 完整 + PagerDuty |

**Terraform workspace**：
> 使用 Terraform workspace 管理多环境状态：
> ```bash
> terraform workspace new dev
> terraform workspace new staging
> terraform workspace new prod
> ```
> 每个 workspace 独立的 state 文件，避免环境间互相影响。

---

### Step 7: 渐进部署策略

**输出目录**：`infrastructure/kubernetes/overlays/prod/progressive/`

**为什么需要渐进部署**：
> 传统的"直接替换全部实例"部署方式风险高——如果新版本有问题，所有用户都会受影响。渐进部署通过控制流量切换来降低风险。

#### 蓝绿部署（Blue-Green）

**原理**：
```
部署前：Service → Blue (100% 流量)
部署中：Service → Blue (100%) + Green (0%, 健康检查中)
切换后：Service → Green (100% 流量)
回滚：  Service → Blue (100% 流量) [瞬间完成]
```

**资源成本**：切换期间需要 2x 资源（Blue + Green 同时运行）

**适用场景**：
- 需要瞬时回滚（金融交易、支付系统）
- 资源充足，可以接受 2x 成本
- 数据库 schema 不发生变化（或向前兼容）

#### 金丝雀发布（Canary）

**原理**：
```
阶段 0：Primary (100%) + Canary (0%)
阶段 1：Primary (95%) + Canary (5%)  [观察 10 分钟]
阶段 2：Primary (75%) + Canary (25%)  [观察 10 分钟]
阶段 3：Primary (50%) + Canary (50%)  [观察 10 分钟]
阶段 4：Primary (0%) + Canary (100%)  [完成]
```

**自动升级条件**（`promotion-policy.yaml`）：
- 错误率 < 1% 持续 10 分钟
- P99 延迟 < 基线 + 20% 持续 10 分钟

**自动回滚条件**（`rollback-policy.yaml`）：
- 错误率 > 5% 持续 2 分钟
- P99 延迟 > 基线 + 50% 持续 2 分钟

**适用场景**：
- 需要逐步验证新版本稳定性
- 资源有限，无法承担 2x 成本
- 用户流量大，不能承受全量故障

> **设计意图**：提供两种渐进部署策略，让用户根据项目特性选择：
> - 蓝绿 = "快速回滚、高资源成本"
> - 金丝雀 = "渐进验证、低资源成本"
> 两种策略的配置都自动生成，降低运维团队的学习成本。

---

### Step 7a: 微服务基础设施（条件触发）

**触发条件**：`architecture.xml/@type="microservice"`

当系统架构类型为微服务时，ops-ready 自动生成额外的基础设施组件：

#### Istio 服务网格

**输出**：`infrastructure/istio/`

| 配置 | 用途 | 与 XML 的映射 |
|------|------|--------------|
| `virtualservices.yaml` | 流量路由、超时、重试 | 每个 Module 一个 VirtualService，路由规则来自 `Interface` |
| `destinationrules.yaml` | 子集定义、mTLS 策略 | 每个 Module 一个 DestinationRule，子集按版本划分 |
| `gateway.yaml` | 入口网关、TLS 终止 | 系统级入口，TLS 来自 `Security/Encryption/@inTransit` |

**默认策略**：
- mTLS 严格模式（服务间通信强制加密）
- 超时 30 秒
- 重试 3 次

> **设计意图**：微服务架构下，服务间通信复杂（N² 问题）。Istio 通过 sidecar 代理统一处理流量管理、安全、可观测性，避免每个服务单独实现这些逻辑。

#### OpenTelemetry + Jaeger

**输出**：`infrastructure/otel/`

| 配置 | 用途 |
|------|------|
| `otel-collector-config.yaml` | 收集指标、日志、追踪，批量处理后导出到后端 |
| `jaeger-deployment.yaml` | 分布式追踪存储和查询（开发环境用 all-in-one，生产用 Elasticsearch 后端） |

> **设计意图**：微服务架构下，一个用户请求可能经过 5-10 个服务。没有分布式追踪，定位延迟瓶颈几乎不可能。OpenTelemetry 是云原生可观测性的标准，Jaeger 是常用的追踪后端。

#### Vault 密钥管理

**输出**：`infrastructure/vault/`

| 配置 | 用途 |
|------|------|
| `vault-policy-{module_id}.hcl` | 每个模块的密钥访问策略（最小权限原则） |
| `dynamic-secrets.yaml` | 数据库凭证动态生成和自动轮换 |
| `kv-secrets.yaml` | 静态密钥路径和版本管理 |

> **设计意图**：生产环境中，密钥硬编码是严重的安全隐患。Vault 提供动态密钥（每次请求生成临时凭证）和自动轮换（定期更换凭证），大幅降低密钥泄露风险。

#### K8s NetworkPolicy

**输出**：`infrastructure/network-policies/`

| 配置 | 用途 |
|------|------|
| `default-deny.yaml` | 默认拒绝所有入站/出站流量（零信任起点） |
| `{module_id}-allow.yaml` | 基于 `Coupling/DependsOn` 的显式允许规则 |

> **设计意图**：默认拒绝 + 显式允许是实现零信任网络的基础。只有架构中声明了依赖关系的模块才能通信，即使某个模块被入侵，攻击者也无法随意访问其他模块。

---

### Step 8: 运维手册生成

**输出文件**：`docs/ops/runbook.md`

**为什么需要运维手册**：
> 基础设施代码（Terraform、K8s）定义了"系统是什么"，但运维手册定义了"如何操作系统"。两者缺一不可。

**手册章节**：

| 章节 | 内容 | 为什么重要 |
|------|------|-----------|
| **部署流程** | Terraform apply 的顺序、前置检查、验证步骤 | 确保部署按正确顺序执行 |
| **回滚流程** | terraform plan + state 备份、紧急回滚命令 | 故障时的救命文档 |
| **扩容指南** | 何时触发 HPA vs 升级节点、扩容顺序 | 避免资源不足时的盲目操作 |
| **告警响应** | 每个 Prometheus 告警的诊断步骤和修复命令 | 缩短 MTTR（平均修复时间） |
| **安全响应** | 凭证轮换、事件隔离、取证步骤 | 安全事件的应急处理 |

---

### Step 9: 工具和配置验证

ops-ready 在最终输出前执行多层验证：

#### 9.1 工具版本验证

**为什么需要**：
> 基础设施工具（Terraform provider、Helm chart、Istio）如果过时或存在已知 CVE，可能导致安全漏洞或兼容性问题。

**验证规则**：
- 搜索 `{tool_name} deprecated` — 检查是否已被弃用
- 搜索 `{tool_name} CVE` — 检查已知安全漏洞
- 验证最后发布/提交在 12 个月内 — 确保工具仍在维护

**三层验证**（与 `devforge-architecture-design` 相同）：
1. **主动搜索**（Active Search）— WebSearch/WebFetch
2. **知识验证**（Knowledge Verification）— 交叉验证搜索结果
3. **黑名单执行**（Blacklist Enforcement）— 拒绝已知不安全的工具

#### 9.2 Terraform 语法验证

- `terraform fmt -check` — 检查格式
- `terraform validate` — 验证语法和引用（如果 Terraform CLI 可用）

#### 9.3 Kubernetes YAML 验证

- `kubectl --dry-run=client apply -f` — 验证 YAML 语法和 schema（如果集群可用）
- `python -c "import yaml; yaml.safe_load(open('file'))"` — 基础 YAML 语法检查

#### 9.4 Prometheus 规则验证

- 验证 PromQL 表达式语法
- 检查指标名称是否符合命名规范

#### 9.5 资源可追溯性验证

**核心检查**：
> 每个 Terraform 资源和 K8s manifest 必须映射到至少一个 `Module` 或 `StateModel`。

**验证方法**：
```
对每个生成的资源：
  检查资源标签/注释中是否包含 module_id
  确认该 module_id 存在于 architecture.xml/Module/@id
  或确认资源类型（DB/cache）对应 StateModel/@location
```

> **设计意图**：这是 VCMF "XML as Authority" 原则在基础设施层的体现——如果存在无法追溯到 XML 的资源，说明 ops-ready "发明了"不需要的基础设施，可能导致资源浪费或安全漏洞。

---

### Step 10: 状态更新

根据 `skill/tools/state-updater.md`：

- **不转换 phase**：`devforge-ops-ready` 不改变当前阶段（它是一个可选的辅助步骤）
- **追加到 Completed Steps**：记录本次基础设施生成操作
- **不修改其他 STATE.md 章节**

---

### Step 11: 人工门控

**呈现内容**：
- 基础设施摘要："生产就绪基础设施已生成，包含 Terraform、K8s、监控和多环境配置。请确认当前阶段输出。"

**可用命令**：

| 命令 | 行为 |
|------|------|
| `[APPROVE]` | 标记生产就绪阶段完成 |
| `[PAUSE]` | 暂停当前阶段，保留上下文 |
| `[ROLLBACK {step_id}]` | 回滚到指定步骤重新执行 |
| `[EDIT {file_path}]` | 手动编辑文件后让 AI 继续 |
| `[INJECT {context}]` | 补充额外上下文约束 |
| `[SKIP]` | 跳过当前可选步骤 |
| `[EXPLAIN {TraceID}]` | 展开解释某个决策/错误的推理链 |

**自然语言反馈处理**：
> 如果用户输入自然语言（如"数据库实例规格太小了"），Skill 分析反馈、定位产物、应用修改、重新呈现门控。

---

## 五、调用工具汇总

| 工具 | 用途 | 调用时机 |
|------|------|----------|
| `Read` | 读取 `architecture.xml` | Step 2 |
| `Read` | 读取 `STATE.md` | Step 2（检查模块状态） |
| `Read` | 读取平台参考文件 | Step 1 |
| `WebSearch` / `WebFetch` | 工具版本验证（CVE/弃用检查） | Step 9 |
| `Bash` | `terraform fmt -check` / `terraform validate` | Step 9 |
| `Bash` | `kubectl --dry-run=client apply -f` | Step 9 |
| `Bash` | `python -c "import yaml; ..."` | Step 9 |
| `Write` | 写入 Terraform 配置 | Step 3 |
| `Write` | 写入 K8s manifests | Step 4 |
| `Write` | 写入监控配置 | Step 5 |
| `Write` | 写入运维手册 | Step 8 |
| `Grep` | 验证资源可追溯性 | Step 9 |

---

## 六、生成产物清单

| 产物文件/目录 | 路径 | 用途 | 更新模式 |
|--------------|------|------|----------|
| Terraform 根模块 | `infrastructure/terraform/` | 云资源编排 | Overlay |
| K8s 基础 manifests | `infrastructure/kubernetes/base/` | 共享部署配置 | Overlay |
| K8s 环境 overlays | `infrastructure/kubernetes/overlays/` | 环境特定补丁 | Overlay |
| 蓝绿部署 | `infrastructure/kubernetes/overlays/prod/progressive/blue-green/` | 零停机发布 | Overlay |
| 金丝雀发布 | `infrastructure/kubernetes/overlays/prod/progressive/canary/` | 渐进发布 | Overlay |
| 升级/回滚策略 | `infrastructure/kubernetes/overlays/prod/progressive/*-policy.yaml` | 自动化策略 | Overlay |
| Prometheus 规则 | `infrastructure/monitoring/prometheus/rules.yml` | 告警规则 | Overlay |
| Grafana 仪表盘 | `infrastructure/monitoring/grafana/dashboards/system.json` | 可视化监控 | Overlay |
| 多环境变量 | `infrastructure/multi-env/*.tfvars` | 环境配置 | Overlay |
| Istio 配置 | `infrastructure/istio/` | 服务网格 | Overlay（微服务时） |
| OpenTelemetry | `infrastructure/otel/` | 分布式追踪 | Overlay（微服务时） |
| Vault 策略 | `infrastructure/vault/` | 密钥管理 | Overlay（微服务时） |
| 网络策略 | `infrastructure/network-policies/` | 零信任网络 | Overlay（微服务时） |
| 运维手册 | `docs/ops/runbook.md` | 操作指南 | Overlay |
| STATE.md Completed Steps | `docs/architecture/system/` | 记录操作 | Append-only |

---

## 七、VCMF 检查点

`devforge-ops-ready` 的 VCMF 检查点体现了它作为"XML 到基础设施映射"的定位：

| VCMF 原则 | 检查点 | 说明 |
|-----------|--------|------|
| **Design as Contract** | Terraform 资源必须 1:1 映射到 `Module` 节点；禁止 phantom resources | 每个云资源都有对应的架构模块 |
| **Interface as Boundary** | K8s service 端口必须匹配 `Interface` 定义 | 接口契约在基础设施层可见 |
| **Reality as Baseline** | 监控指标必须可收集；禁止理论指标 | 只生成实际可观测的指标 |
| **State as Responsibility** | 数据库和缓存的持久化策略必须匹配 `StateModel` | 状态所有权在基础设施层强制执行 |
| **XML as Authority** | 每个生成的资源必须可通过 `Module` 或 `StateModel` 节点 ID 追溯 | 一致性检查的核心 |

---

## 八、流程设计原理（Why Designed This Way）

### 8.1 为什么是可选步骤

| 对比 | 必经（如 scaffolding） | 可选（如 ops-ready） |
|------|----------------------|---------------------|
| **适用场景** | 所有项目 | 需要生产部署的项目 |
| **执行成本** | 必须承担 | 按需执行 |
| **核心价值** | 开发基础设施 | **生产基础设施** |

> **设计意图**：
> - 原型项目、内部工具、学习项目可能不需要 Terraform + K8s 的复杂基础设施
> - 但所有面向用户的产品系统都需要生产级部署配置
> - 将 ops-ready 设为可选，避免对简单项目施加不必要的复杂度

### 8.2 为什么从 XML 推断资源而非让用户手动指定

> **设计意图**：
> 1. **减少人为错误**：手动指定资源容易遗漏（如忘记为缓存创建 Redis 集群）
> 2. **保持一致性**：如果架构中有 5 个模块，基础设施中就应该有 5 个 compute resource groups
> 3. **自动更新**：架构变更后重新运行 ops-ready，基础设施自动同步
> 4. **VCMF 原则**："XML 是权威"——基础设施是架构的投影，而非独立设计
>
> **局限性**：
> - XML 推断的初始资源规格是估算值，需要根据实际负载调整
> - 某些特殊资源（如 GPU、专用硬件）无法在 XML 中表达，需要手动补充

### 8.3 为什么使用 Terraform + K8s 而非单一工具

| 工具 | 职责 | 为什么需要 |
|------|------|-----------|
| **Terraform** | 云资源编排（VPC、DB、缓存、存储） | 云资源生命周期管理 |
| **Kubernetes** | 容器编排（部署、服务、扩缩容） | 应用运行时管理 |
| **Kustomize** | K8s 多环境管理 | 环境差异的声明式管理 |
| **Prometheus** | 指标收集和告警 | 可观测性 |
| **Grafana** | 指标可视化 | 运维仪表盘 |

> **设计意图**：这是云原生领域的标准工具链（Cloud Native Foundation 推荐）。每个工具专注一个层面：
> - Terraform = 基础设施层（Infrastructure Layer）
> - K8s = 编排层（Orchestration Layer）
> - Prometheus/Grafana = 可观测性层（Observability Layer）
> 分层工具链允许团队替换其中一层而不影响其他层。

### 8.4 为什么渐进部署策略自动生成

> **设计意图**：
> 1. **降低运维门槛**：蓝绿部署和金丝雀发布的配置复杂（涉及 Service selector、Ingress annotation、监控指标判断）。自动生成让这些高级部署策略对中小团队也可用
> 2. **与监控集成**：渐进部署策略依赖 Prometheus 指标（错误率、延迟）。ops-ready 同时生成监控和部署策略，确保两者指标名称一致
> 3. **标准化**：所有使用 DevForge 的项目都使用相同的渐进部署模式，降低团队间认知差异

### 8.5 为什么微服务基础设施条件触发

> **设计意图**：
> Istio、OpenTelemetry、Vault、NetworkPolicy 是微服务架构的"高级装备"：
> - 单体应用不需要服务网格（没有服务间通信）
> - 单体应用不需要分布式追踪（请求只在单个进程内）
> - 单体应用的网络策略更简单（默认允许即可）
> 
> 通过 `architecture.xml/@type` 条件触发，避免对非微服务项目生成不必要的复杂配置。

### 8.6 为什么资源可追溯性检查是必需的

> **设计意图**：
> 这是防止"基础设施膨胀"（Infrastructure Bloat）的关键机制：
> - 没有可追溯性检查 → AI 可能生成 XML 中不存在的资源（如"我觉得这里需要一个消息队列"）
> - 有可追溯性检查 → 每个资源都必须有 XML 依据
> 
> 这与 DevForge 的核心原则一致：架构是设计的权威，基础设施是架构的忠实实现。

---

## 九、常见误区与 Red Flags

### 9.1 与 scaffolding 的边界误区

| 误区 | 正确做法 |
|------|----------|
| 认为 scaffolding 已经生成了部署配置，不需要 ops-ready | scaffolding 只生成 `docker-compose.yml`（本地开发），ops-ready 生成 Terraform + K8s（生产环境），两者互补 |
| 在 scaffolding 阶段就生成完整的 Terraform 配置 | scaffolding 只生成基础的 CI/CD 配置，云基础设施在 ops-ready 阶段生成 |
| 修改了 architecture.xml 但不重新运行 ops-ready | 架构变更后必须重新运行 ops-ready，确保基础设施同步 |

### 9.2 通用误区

| 误区 | 正确做法 |
|------|----------|
| 认为生成的资源规格是最终值 | 初始规格是估算值，应根据监控数据持续调整 |
| 手动修改 Terraform 后不再使用 ops-ready | 手动修改应使用 `[EDIT]` 命令让 AI 纳入，否则下次重新生成会覆盖 |
| 忽略 monitoring/ 目录 | 监控是生产系统的必需组件，不应跳过 |
| 在 secret.yaml 中填充真实密钥 | secret.yaml 应只包含占位符，真实密钥由 Vault/环境变量注入 |
| 跳过工具版本验证 | 过时的 Terraform provider 可能有已知 CVE，必须通过验证 |
| 认为蓝绿部署和金丝雀必须同时使用 | 两者是替代方案，根据项目特性选择其一即可 |
| 忽略运维手册 | runbook.md 是故障时的救命文档，应定期更新 |

### 9.3 SKILL.md 中的 Red Flags

SKILL.md 明确定义了以下红线：

| Red Flag | 说明 |
|----------|------|
| **Do NOT generate resources not traceable to a `Module` or `StateModel`** | 禁止生成 XML 中不存在的资源 |
| **Do NOT skip the monitoring configuration** | 监控是生产必需，不能跳过 |
| **Do NOT generate hard-coded credentials or secrets** | 禁止硬编码密钥，必须使用 Vault/环境变量 |
| **Do NOT proceed without the human gate** | 必须通过人工审批 |

---

## 十、总结

`devforge-ops-ready` 是 DevForge SDLC Skill Chain 中的**生产基础设施工厂**——它将架构设计转换为可执行、可部署、可监控的云原生基础设施。

### 核心价值

1. **架构到基础设施的自动映射**：从 `architecture.xml` 自动推断资源需求，减少人为遗漏
2. **云原生最佳实践**：Terraform + K8s + Prometheus + Grafana 的标准工具链
3. **多环境管理**：Kustomize 的 base + overlay 模式管理 dev/staging/prod 差异
4. **渐进部署**：自动生成蓝绿部署和金丝雀发布配置，降低发布风险
5. **微服务增强**：条件触发的 Istio、OpenTelemetry、Vault、NetworkPolicy
6. **VCMF 可追溯性**：每个资源都可追溯到 XML 节点，防止基础设施膨胀
7. **运维手册**：自动生成操作指南，缩短故障修复时间

### 适用场景

| 场景 | 推荐操作 |
|------|----------|
| 新项目准备生产部署 | 触发 `[OPS]` 生成完整基础设施 |
| 架构变更后同步基础设施 | 重新触发 `[OPS]`，更新 Terraform 和 K8s |
| 添加新模块后 | 重新触发 `[OPS]`，为新模块生成部署配置 |
| 微服务架构项目 | 确保生成 Istio、OpenTelemetry、Vault、NetworkPolicy |
| 安全审计前 | 检查 Vault 策略和 NetworkPolicy 是否完整 |
| 性能优化 | 根据监控数据调整 HPA 阈值和资源请求/限制 |

### 与其他技能的协作

```
architecture-design (生成 architecture.xml)
    ↓
project-scaffolding (生成工程目录和 CI/CD)
    ↓
module-design (生成模块级代码)
    ↓
test-execution (运行测试)
    ↓
[OPS] → devforge-ops-ready (生成生产基础设施)
    ↓
iteration-planning (后续迭代，可能更新架构)
    ↓
[OPS] → devforge-ops-ready (重新生成基础设施)
```

### v1.2 / v1.4 设计演进

- **v1.2 引入**：Terraform、K8s、Prometheus、Grafana、蓝绿部署、金丝雀发布
- **v1.4 增强**：Istio 服务网格、OpenTelemetry、Vault、NetworkPolicy（微服务架构时）
- **设计趋势**：ops-ready 从"基础部署配置"向"完整生产平台"演进，涵盖从基础设施到可观测性到安全的全栈运维能力

---

*分析基于 DevForge SDLC Skill Chain v1.4（2026-05-11）及 devforge-ops-ready v1.4*
