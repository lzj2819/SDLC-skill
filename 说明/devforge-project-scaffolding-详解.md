# DevForge Project Scaffolding 深度解析

> 本文档基于 DevForge SDLC Skill Chain v1.4 的 `devforge-project-scaffolding` 技能定义（`SKILL.md`）进行深度分析。
>
> **定位**：Stage 4，属于 DIVE 工作流的 **Implement（实现）** 阶段。
> **核心目标**：将已批准的架构设计转化为可运行的项目基础设施——从"纸面设计"到"代码仓库"的关键转折点。
> **关键约束**：只生成基础设施，不生成业务逻辑代码（留给 module-design 阶段）。

---

## 一、整体流程概览（17个步骤）

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  Step 1: 读取所有产物（Read All Artifacts）                                    │
│       ↓                                                                     │
│  Step 2: 内部规划（Internal Planning）                                         │
│       ↓                                                                     │
│  Step 3: 目录树与依赖（Directory Tree + Dependencies）                         │
│       ↓                                                                     │
│  Step 4: 模块目录初始化（Module Directory Init）                               │
│       ↓                                                                     │
│  Step 5: 代码推理注释（Code Reasoning Comments）                               │
│       ↓                                                                     │
│  Step 6: 部署拓扑（Deployment Topology）                                       │
│       ↓                                                                     │
│  Step 7: CI/CD 流水线（CI/CD Pipeline）                                        │
│       ↓                                                                     │
│  Step 8: 环境配置模板（Environment Config Template）                            │
│       ↓                                                                     │
│  Step 9: 测试框架初始化（Test Framework Init）                                 │
│       ↓                                                                     │
│  Step 10: 文档同步规则（Documentation Sync Rules）                             │
│       ↓                                                                     │
│  Step 11: 架构决策记录 ADR（Architecture Decision Record）                     │
│       ↓                                                                     │
│  Step 12: 决策日志与变更日志（Decision Log + Changelog）                        │
│       ↓                                                                     │
│  Step 13: 自验证 — 产物质量（Self-Validation）                                  │
│       ↓                                                                     │
│  Step 14: 内部验证（Internal Verification）                                    │
│       ↓                                                                     │
│  Step 15: 可追溯性审计（Traceability Audit）                                   │
│       ↓                                                                     │
│  Step 16: 状态更新（State Update）                                             │
│       ↓                                                                     │
│  Step 17: 人机关卡（Human Gate）                                               │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 二、输入来源（上游产物）

`devforge-project-scaffolding` 是设计阶段到实现阶段的转折点，它需要读取**全部历史产物**（与 design-review 一样）：

| 输入文件 | 来源阶段 | 在 Scaffolding 中的用途 |
|---------|---------|----------------------|
| `PRD.md` | requirement-analysis | 需求基准，确保每个生成的文件都可追溯到需求 |
| `STATE.md` | 全链条维护 | 当前 phase、已知风险、模块注册表 |
| `DECISION_LOG.md` | 全链条维护 | 架构决策来源，生成代码注释中的决策引用 |
| `ARCHITECTURE.md` | architecture-design | 技术栈选择、Mock 数据定义 |
| `architecture.xml` | architecture-design | 模块列表、接口定义、StateModel、部署拓扑依据 |
| `INTERFACE_CONTRACT.md` | architecture-design | 确保生成的代码签名与契约一致 |
| `VALIDATION_REPORT.md` | architecture-validation (3a) | 参考验证结果，避免已知问题 |
| `DESIGN_REVIEW.md` | design-review (3b) | Must Fix / Should Fix 问题转为 TODO 注释 |
| `module-architecture.xml`（模块级，如存在） | architecture-design | 模块级约束和组件占位 |
| `component-spec.xml`（组件级，如存在） | module-design | 组件规格（迭代模式下可能存在） |

---

## 三、每一步详解与调用的工具

### Step 1: 读取所有产物（Read All Artifacts）

#### 做什么？
加载全部历史产物，包括系统级、模块级、组件级的所有文档。

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Read` | 读取上述所有文件 |

#### 为什么这样设计？
- **Single Thinker 模型**：scaffolding 不是"无脑代码生成"，而是"基于完整上下文的结构化代码生成"
- **可追溯性起点**：从这一步开始，每个生成的文件都必须能回答"这个文件服务于哪个 PRD 需求"
- **风险继承**：DESIGN_REVIEW.md 中的问题需要在代码中体现为 TODO 注释

---

### Step 2: 内部规划（Internal Planning）

#### 做什么？
创建一个轻量级的实现计划：
- 需要创建哪些文件
- 需要建立哪些目录
- 需要生成哪些测试框架

**要求**：保持轻量（简短的 bullet list 即可）。

#### 为什么这样设计？
- **防止过度规划**：scaffolding 是基础设施生成，不需要详细的模块实现计划（那是 module-design 的事）
- **结构化执行**：即使轻量，也有计划可依，避免遗漏关键文件
- **与人类计划的区别**：这是 AI 内部执行的规划，不需要人类审阅

---

### Step 3: 目录树与依赖（Directory Tree + Dependencies）

#### 做什么？
生成以下内容：

| 产物 | 说明 |
|------|------|
| **项目目录树** | `PROJECT_SCAFFOLD/` 下的完整目录结构 |
| **架构文档树** | `docs/architecture/system/` 和 `docs/architecture/modules/{module_id}/` |
| **`.gitattributes`** | 标记 `*.xml` 为 `diff=text`，确保 Git 正确显示 XML 差异 |
| **`docs/architecture/INDEX.md`** | 统一文档索引，含系统级产物链接、模块表、生成产物链接 |
| **依赖配置文件** | `package.json`、`requirements.txt`、`pom.xml`、`Cargo.toml` 等 |
| **`repo-index.md`** | 项目根目录的仓库索引，供 debug/ops 技能快速恢复上下文 |

#### `repo-index.md` 的结构
- 层级文件树（最大深度 3，排除 `node_modules/`、`.git/`、`__pycache__/`、`*.lock`）
- 每个目录的摘要：用途、关键文件、大致代码行数
- 模块到目录的交叉引用映射

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Bash` / `PowerShell` | 创建目录结构 |
| `Write` | 生成 `INDEX.md`、`.gitattributes`、`repo-index.md`、依赖配置文件 |

#### 为什么这样设计？
- **INDEX.md 是架构文档的入口**：开发者和审阅者第一眼看到的就是这个索引
- **模块表初始为空**：模块行由后续的 `module-design` 填充，体现"脚手架只搭框架，内容后续补充"
- **`.gitattributes`**：XML 文件默认可能被 Git 当作二进制，标记为 `diff=text` 确保可读差异
- **`repo-index.md` 供下游技能使用**：`devforge-debug-assistant` 和 `devforge-ops-ready` 需要快速了解代码库结构

---

### Step 4: 模块目录初始化（Module Directory Initialization）

#### 做什么？
读取 `architecture.xml` 中的 `Module` 列表，为每个模块创建目录：

```
PROJECT_SCAFFOLD/src/modules/{module_id}/
  └── __init__.py  (或语言等效文件)
```

**关键约束**：
- **只生成 `__init__.py` + header comment**
- **不生成**任何函数签名、类定义或业务逻辑占位符

#### Header Comment 模板
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

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Read` | 读取 `architecture.xml` 获取模块列表 |
| `Write` | 生成每个模块的 `__init__.py` |

#### 为什么这样设计？
- **严格区分 scaffolding 和 module-design**：
  - scaffolding = 基础设施（目录、配置、框架）
  - module-design = 业务逻辑（组件分解、接口、代码骨架）
- **防止提前实现**：如果 scaffolding 就生成了业务逻辑占位符，开发者可能提前开始编码，绕过 module-design 的详细设计
- **Header comment 的可追溯性**：每个模块文件头都标明它服务于哪个 PRD 需求、哪个架构决策、有什么已知风险——这是 VCMF "Design as Contract" 在代码层面的体现

---

### Step 5: 代码推理注释（Code Reasoning Comments）

#### 做什么？
在每个核心模块的头部注释中，嵌入以下信息：

| 信息类型 | 来源 | 作用 |
|---------|------|------|
| **架构决策 ID** | `DECISION_LOG` 或 XML `DecisionTrace` | 解释"为什么这个模块存在" |
| **推理说明** | PRD 需求 | 解释"这个模块服务于什么需求" |
| **已知风险** | `DESIGN_REVIEW.md` | 标记已识别的风险 |
| **TODO 注释** | DESIGN_REVIEW Must Fix / Should Fix | 将审查问题转化为代码中的 TODO |

#### 为什么这样设计？
- **知识不丢失**：6 个月后开发者看这个文件，能理解当初的设计意图
- **TODO 传承**：DESIGN_REVIEW 的 Must Fix / Should Fix 如果不修复，不能就这样消失——它们必须转化为代码中的 TODO，确保不会被遗忘
- **VCMF "Design as Contract"**：代码不是孤立存在的，它是架构决策的具体实现，必须标明其"血统"

---

### Step 6: 部署拓扑（Deployment Topology）

#### 做什么？
生成容器化部署配置：

| 产物 | 说明 |
|------|------|
| `docker-compose.yml` | 本地开发环境编排 |
| Kubernetes manifests（基础） | 生产环境部署 |
| 容器化策略 README | 简短的部署说明 |

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Write` | 生成部署配置文件 |

#### 为什么这样设计？
- **开发即生产**：从第一天起就考虑部署，避免"本地能跑，上线不行"
- **与 architecture.xml 对齐**：部署拓扑基于 XML 中的模块列表和耦合关系
- **基础设施即代码**：部署配置也是代码，纳入版本控制

---

### Step 7: CI/CD 流水线（CI/CD Pipeline）

#### 做什么？
生成 CI/CD 配置文件（如 `.github/workflows/ci.yml` 或 `.gitlab-ci.yml`），包含以下 Job：

##### Job 1: 基础流程
- 依赖安装
- 代码静态检查（lint）
- Mock 测试执行
- 真实 LLM 测试执行（带 `continue-on-error` 或 skip 逻辑，缺失 API Key 不导致构建失败）

##### Job 2: 覆盖率检查（Coverage Check）
| 语言 | 命令 | 阈值 |
|------|------|------|
| Python | `pytest --cov=src --cov-report=xml --cov-report=term --cov-fail-under=80` | 80% |
| Node.js | `jest --coverage --coverageThreshold='{"global":{"lines":80}}'` | 80% |
| Java | `mvn jacoco:check` with `minimum` line ratio 0.80 | 80% |
| Go | `go test -coverprofile=coverage.out ./...` + `go tool cover -func=coverage.out` | 80% |

**CI 必须失败**如果覆盖率低于阈值。

##### Job 3: 架构一致性检查（Architecture Consistency Check）
运行以下脚本，确保代码与 XML 规范保持同步：
- `scripts/architecture-ci.sh`
- `scripts/xml-sync.py --verify-only`

**此 Job 必须失败**如果：
- XML 文件格式损坏
- 组件函数签名与 `component-spec.xml` 偏离
- 模块约束不再匹配系统级接口
- 任何 `ref` 属性指向缺失文件

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Write` | 生成 CI/CD 配置文件 |

#### 为什么这样设计？
- **质量门禁（Quality Gate）**：80% 覆盖率是硬性门槛，防止技术债务累积
- **架构一致性检查是核心设计**：这是 VCMF "XML as Authority" 在 CI 中的落地——代码必须与 XML 保持一致，否则构建失败
- **`continue-on-error` 的真实 LLM 测试**：没有 API Key 时测试被跳过，但不阻塞构建——体现优雅降级
- **多语言支持**：根据技术栈选择对应的覆盖率工具和命令

---

### Step 8: 环境配置模板（Environment Config Template）

#### 做什么？
生成 `.env.template`，列出所有必需的环境变量：
- API keys
- Base URLs
- Model names
- Database URLs

顶部添加注释块，说明**禁止硬编码密钥**。

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Write` | 生成 `.env.template` |

#### 为什么这样设计？
- **安全基线**：从项目第一天就建立"密钥进环境变量"的安全文化
- **配置与代码分离**：所有外部依赖（数据库、第三方 API）通过环境变量配置，支持多环境部署
- **开发者体验**：新开发者克隆项目后，只需复制 `.env.template` 为 `.env` 并填入值即可运行

---

### Step 9: 测试框架初始化（Test Framework Initialization）

#### 做什么？
创建测试目录结构和框架配置：

```
tests/
├── mock/              # Mock 基础的单元测试和集成测试
├── real/              # 真实 LLM 测试（带 skipif 机制）
└── end_to_end/        # 端到端流程测试
```

同时生成：
- 框架配置文件（`conftest.py`、`pytest.ini`、`jest.config.js` 等）
- 测试基类和工具类（`MockLLMClient`、`TestDataFactory`）
- `tests/README.md`（测试组织规则说明）

**关键约束**：
- **只生成测试框架和目录结构**
- **不生成具体测试用例**（由 `devforge-module-design` 阶段生成）

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Write` | 生成测试框架文件和配置 |

#### 为什么这样设计？
- **测试先行（Test-First）**：在写业务代码之前，测试框架已经就绪
- **Mock vs Real 分离**：
  - `tests/mock/`：不依赖外部服务的快速测试，用于日常开发
  - `tests/real/`：依赖真实 LLM API 的测试，用于验证集成——带 `skipif`，无 API Key 时自动跳过
- **端到端测试**：覆盖完整用户流程，验证系统级集成
- **框架就绪，用例后补**：测试用例需要基于具体的组件设计（`component-spec.xml`），所以在 module-design 阶段生成

---

### Step 10: 文档同步规则（Documentation Sync Rules）

#### 做什么？
生成两份同步规则文档：

##### `docs/sync-rules.md`（代码级同步规则）
映射代码变更类型到需要更新的文档：

| 代码变更类型 | 需要更新的文档 |
|-------------|--------------|
| `src/*/` 代码变更 | `src/*/tests/README.md` + `docs/*.xml` |
| 函数签名变更 | 对应的 `component-spec.xml` |
| 新增模块目录 | `architecture.xml` + 模块注册表 |

##### `docs/architecture/sync-rules.md`（架构级同步规则）
映射架构变更到级联更新：

| 架构变更类型 | 级联更新 |
|-------------|---------|
| 系统接口变更 | 传播到受影响的 `module-architecture.xml` Constraints |
| 组件签名变更 | 验证与 `INTERFACE_CONTRACT.md` 的一致性 |
| 新增错误码 | 更新所有相关 XML `ErrorCodes` 和 `ErrorHandling` 节点 |

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Write` | 生成同步规则文档 |

#### 为什么这样设计？
- **防止文档腐烂（Documentation Rot）**：代码改了，文档没改——这是软件项目的常见问题
- **变更驱动更新**：开发者不需要记住"改了什么要更新什么文档"，只需查 sync-rules
- **双向同步**：不仅代码变更影响文档，架构变更也影响代码——双向约束确保一致性
- **CI 集成基础**：architecture consistency check job 就是基于这些规则实现的

---

### Step 11: 架构决策记录 ADR（Architecture Decision Record）

#### 做什么？
生成 `docs/ADR.md`，将 `DECISION_LOG.md` 的条目转化为标准 ADR 格式：

| ADR 字段 | 内容来源 |
|---------|---------|
| **Status** | Accepted / Deprecated / Superseded |
| **Context** | 当时的决策背景和压力因素 |
| **Decision** | 最终选择 |
| **Consequences** | 正面和负面影响 |

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Read` | 读取 `DECISION_LOG.md` |
| `Write` | 生成 `ADR.md` |

#### 为什么这样设计？
- **ADR 是行业标准格式**：比原始的 DECISION_LOG 更结构化，便于人类阅读
- **Status 字段的价值**：标记哪些决策仍然有效、哪些已被取代——防止过时的决策误导后续开发
- **Consequences 的双面性**：不仅记录好处，也记录代价——让未来的决策者理解"我们为这个选择付出了什么"

---

### Step 12: 决策日志与变更日志（Decision Log + Changelog）

#### 做什么？
- 将 scaffolding 相关的决策追加到 `DECISION_LOG.md`
- 生成初始的 `CHANGELOG.md`

#### 为什么这样设计？
- **决策连续性**：scaffolding 阶段也会做决策（如"选择 pytest 作为测试框架"），这些决策需要记录
- **CHANGELOG 初始化**：从项目第一天起就有变更日志，养成记录变更的习惯
- **Append-only**：DECISION_LOG 是 append-only 的，永不覆盖历史

---

### Step 13: 自验证 — 产物质量（Self-Validation: Generated Artifacts）

#### 做什么？
对所有生成的文件执行语法验证：

| 文件类型 | 验证命令 |
|---------|---------|
| Python | `python -m py_compile <file>` |
| JavaScript/TypeScript | `npx tsc --noEmit` 或 `node --check` |
| Java | `javac -d /tmp/compiled <file>` |
| Go | `go build ./...` |
| YAML | `python -c "import yaml; yaml.safe_load(open('<file>'))"` |
| JSON | `python -m json.tool <file>` |
| XML | `scripts/architecture-ci.sh` |

**如果任何检查失败，重新生成失败的文件。**

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Bash` | 运行各种语法验证命令 |

#### 为什么这样设计？
- **零 Broken Build**：scaffolding 生成的代码必须是可编译/可解析的，不能生成语法错误的文件
- **多语言覆盖**：根据技术栈选择对应的验证工具
- **失败即修复**：不将语法错误留给人类发现，AI 自己修复

---

### Step 14: 内部验证（Internal Verification）

#### 做什么？
验证以下内容：

| 验证项 | 检查内容 |
|--------|---------|
| **文件路径匹配** | 所有生成的文件路径是否与计划一致 |
| **接口签名匹配** | 生成的代码签名是否与 `INTERFACE_CONTRACT.md` 一致 |
| **环境变量覆盖** | `.env.template` 是否覆盖了架构中提到的所有外部依赖 |
| **CI 配置引用** | CI 配置是否引用了存在的测试目录 |

#### 为什么这样设计？
- **规划与实际的一致性**：Step 2 做了计划，Step 14 验证执行结果与计划是否一致
- **接口契约的落地检查**：scaffolding 虽然没有生成业务逻辑，但任何生成的接口签名都必须与契约一致

---

### Step 15: 可追溯性审计（Traceability Audit）

#### 做什么？
随机抽样 3-5 个生成的文件，回答以下问题：

| 问题 | 追溯目标 |
|------|---------|
| 这个文件追溯回哪个 PRD 需求？ | PRD.md |
| 它的签名追溯回哪个 INTERFACE_CONTRACT 条目？ | INTERFACE_CONTRACT.md |
| 它的状态管理是否与 XML StateModel 匹配？ | architecture.xml |

如果任何答案不可追溯，标记为可追溯性缺口，并追加到 `STATE.md` 的 Known Pitfalls。

#### 为什么这样设计？
- **质量抽检**：无法对每个文件都做完整审计，随机抽样是高效且有效的质量控制手段
- **可追溯性闭环**：VCMF "Design as Contract" 要求每个代码文件都能追溯到其设计来源
- **缺口记录**：发现的可追溯性问题进入 Known Pitfalls，供后续迭代处理

---

### Step 16: 状态更新（State Update）

#### 做什么？
更新 `STATE.md`：

1. **Completed Steps 追加**：
   ```
   [YYYY-MM-DD HH:MM] devforge-project-scaffolding: 
   Generated PROJECT_SCAFFOLD with [N] files.
   ```
2. **设置 DIVE 状态**：
   - `Implement: infrastructure_completed`
   - `Verify: pending`
   - `Evolve: pending`
3. **更新 INDEX.md**：添加生成产物的链接

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Read` | 读取当前 STATE.md |
| `Write` / `Edit` | 更新 STATE.md |

#### 为什么这样设计？
- **DIVE 状态映射**：scaffolding 属于 Implement 阶段的基础设施部分
- `infrastructure_completed` 而非 `completed`：因为业务逻辑尚未实现（module-design 负责）
- **INDEX.md 实时更新**：让后续技能知道 scaffolding 产物在哪里

---

### Step 17: 人机关卡（Human Gate）

#### 做什么？
1. 展示生成的文件摘要（bullet list）
2. 明确告知："项目基础设施已生成，包含工程目录、CI/CD 配置、测试框架、文档同步规则和环境变量模板。业务代码将在模块详细设计阶段生成。"
3. 列出可用命令并等待用户回复

#### 可用命令

| 命令 | 作用 |
|------|------|
| `[APPROVE]` | 批准并继续（进入模块详细设计阶段） |
| `[PAUSE]` | 暂停当前阶段，保留上下文 |
| `[ROLLBACK {step_id}]` | 回滚到指定步骤重新执行 |
| `[EDIT {file_path}]` | 手动编辑文件后让 AI 继续 |
| `[INJECT {context}]` | 补充额外上下文约束 |
| `[SKIP]` | 跳过当前可选步骤 |
| `[EXPLAIN {TraceID}]` | 展开解释某个决策/错误的推理链 |

#### 关键约束：HARD-GATE
```markdown
<HARD-GATE>
Do NOT mark the DevForge workflow as complete until the user replies [APPROVE] 
or explicitly asks to continue.
</HARD-GATE>
```

#### 为什么这样设计？
- **基础设施确认**：scaffolding 生成的是项目骨架，人类需要确认这个骨架是否正确
- **明确告知"业务代码后续生成"**：防止用户误以为 scaffolding 后项目就完整了
- **与 module-design 的衔接**：`[APPROVE]` 后进入 module-design 阶段，开始生成业务逻辑

---

## 四、核心输出产物清单

| 产物 | 路径 | 作用 | 下游消费者 |
|------|------|------|-----------|
| **项目目录树** | `PROJECT_SCAFFOLD/` | 完整的可运行项目基础设施 | module-design（填充业务逻辑） |
| **`.env.template`** | `PROJECT_SCAFFOLD/.env.template` | 环境变量模板 | 开发者（填入实际值） |
| **`docs/sync-rules.md`** | `PROJECT_SCAFFOLD/docs/sync-rules.md` | 代码-文档同步规则 | 开发者日常参考；CI 架构一致性检查 |
| **`docs/ADR.md`** | `PROJECT_SCAFFOLD/docs/ADR.md` | 架构决策记录（ADR 格式） | 新成员理解设计背景 |
| **`CHANGELOG.md`** | `PROJECT_SCAFFOLD/CHANGELOG.md` | 变更日志 | 版本发布时引用 |
| **`docs/architecture/INDEX.md`** | `PROJECT_SCAFFOLD/docs/architecture/INDEX.md` | 架构文档统一索引 | 全链条技能参考 |
| **`repo-index.md`** | `PROJECT_SCAFFOLD/repo-index.md` | 仓库索引 | debug-assistant、ops-ready |
| **模块 `__init__.py`** | `src/modules/{id}/__init__.py` | 模块初始化文件（仅 header comment） | module-design（在此基础上生成组件） |
| **CI/CD 配置** | `.github/workflows/ci.yml` 或等效文件 | 持续集成流水线 | GitHub/GitLab CI |
| **部署配置** | `docker-compose.yml` / K8s manifests | 容器化部署 | 运维团队 |
| **测试框架** | `tests/` 目录 + 配置文件 | 测试基础设施 | module-design（生成具体测试用例） |

---

## 五、流程设计哲学深度解析

### 1. 为什么 Scaffolding 不生成业务逻辑代码？

这是 scaffolding 与 module-design 的核心分工：

| 维度 | Scaffolding（Stage 4） | Module-Design（Stage 5） |
|------|----------------------|-------------------------|
| **关注点** | 基础设施、配置、框架 | 组件分解、接口、业务逻辑骨架 |
| **输入** | architecture.xml（模块列表） | module-architecture.xml（组件列表） |
| **输出** | `__init__.py`（仅 header） | `component-spec.xml` + 代码骨架 |
| **粒度** | 模块级 | 组件级 |

**设计意图**：
- **防止绕过设计**：如果 scaffolding 就生成了业务逻辑占位符，开发者可能直接开始填代码，跳过 module-design 的详细设计
- **关注点分离**：基础设施和业务逻辑是两种不同的心智模型，分开处理更高效
- **严格前置条件**：module-design 的前置条件是 `scaffolding_completed`，确保基础设施就绪后才设计业务逻辑

### 2. 为什么 CI 要包含架构一致性检查？

这是 VCMF "XML as Authority" 的核心落地：

```
开发者修改代码 ──→ Git Push ──→ CI 运行 architecture-ci.sh ──→ 
    检查代码签名是否与 component-spec.xml 一致
    检查 module-architecture.xml 是否匹配 system architecture.xml
    检查所有 ref 属性是否指向存在文件
    ──→ 不一致则构建失败
```

**设计意图**：
- **防止架构漂移**：随着开发进行，代码逐渐偏离原始设计——架构一致性检查在每次提交时阻止这种漂移
- **可执行架构**：架构不是静态文档，而是 CI 中的活检查
- **自动化 enforcement**：不需要人工审查每个 PR 的架构一致性，CI 自动完成

### 3. 为什么有 `repo-index.md`？

**问题场景**：
- 项目进行到第 10 轮迭代，代码库有 200+ 文件
- 新开发者加入，需要快速理解项目结构
- `devforge-debug-assistant` 需要定位某个模块对应的文件

**repo-index.md 的价值**：
- 层级文件树（max depth 3）：快速浏览而不被淹没
- 每个目录的摘要和 LOC：了解代码分布
- 模块到目录的交叉引用："UserService 模块对应的代码在哪里？"

**为什么不是简单的 `tree` 命令输出？**
- `tree` 只是文件列表，没有语义信息
- `repo-index.md` 包含"这个目录是做什么的"、"关键文件有哪些"等语义摘要

### 4. 为什么覆盖率阈值是 80%？

| 阈值 | 含义 | 适用场景 |
|------|------|---------|
| 60% | 基础覆盖 | 原型/POC 项目 |
| **80%** | **良好覆盖** | **生产级项目（DevForge 默认）** |
| 90% | 严格覆盖 | 金融/医疗等高风险行业 |
| 100% | 完全覆盖 | 理想状态，实际难以持续维持 |

**DevForge 选择 80% 的理由**：
- **生产就绪的底线**：低于 80% 意味着大量代码未经测试，风险不可接受
- **可达成性**：80% 是一个既有挑战性又可达成的目标
- **与 Quality Gates 的关联**：STATE.md 中的 Quality Gates 定义了可配置的阈值，80% 是默认值

### 5. 为什么 `.env.template` 从项目第一天就存在？

**安全最佳实践**：
- 第 1 天：`.env.template` 存在，说明"密钥应该放在环境变量中"
- 第 10 天：新开发者克隆项目，自然复制 `.env.template` 为 `.env`
- 第 100 天：没有出现密钥泄露事故

**反面教材**：
- 很多项目开始时没有 `.env.template`
- 开发者为了方便，把 API Key 硬编码在代码中
- 代码推送到 GitHub → 密钥泄露 → 安全事故

DevForge 从 scaffolding 阶段就防止这个问题。

---

## 六、与 DIVE 工作流的关系

```
Design（设计）          Implement（实现）         Verify（验证）           Evolve（演进）
   │                        │                        │                       │
   ├── requirement-analysis  │                        │                       │
   ├── architecture-design   │                        │                       │
   │      │                  │                        │                       │
   │      ↓                  │                        │                       │
   │  [APPROVE]              │                        │                       │
   │      │                  │                        │                       │
   ├── architecture-validation│                       │                       │
   ├── design-review         │                        │                       │
   │      │                  │                        │                       │
   │      ↓                  ↓                        │                       │
   │  [APPROVE]       ┌─────────────┐                │                       │
   │                  │ scaffolding │ ← 你在这里      │                       │
   │                  │ (基础设施)   │                │                       │
   │                  └─────────────┘                │                       │
   │                         │                       │                       │
   │                         ↓                       │                       │
   │                   [APPROVE]                     │                       │
   │                         │                       │                       │
   │                  ┌─────────────┐                │                       │
   │                  │module-design│                │                       │
   │                  │(业务逻辑)   │                │                       │
   │                  └─────────────┘                │                       │
   │                         │                       │                       │
   │                         ↓                       ↓                       │
   │                   [APPROVE]               test-execution                │
   │                                                 │                       │
   │                                                 ↓                       │
   │                                           [APPROVE/DEBUG]               │
   │                                                 │                       │
   └─────────────────────────────────────────────────┴───────────────────────┘
                                                     ↓
                                              iteration-planning
```

Scaffolding 是 **Implement 阶段的起点**，它完成了"可运行环境"的搭建，为后续的 module-design（业务逻辑实现）和 test-execution（验证）奠定了基础。

---

## 七、VCMF 五原则在 Project Scaffolding 中的体现

| VCMF 原则 | 在 Project Scaffolding 中的体现 |
|-----------|--------------------------------|
| **Design as Contract** | 每个生成的文件都必须追溯到 PRD 或 Architecture 产物；模块 header comment 标明 PRD Reference 和 Architecture Decision；Step 15 可追溯性审计验证这一原则 |
| **Interface as Boundary** | CI/CD pipeline 包含 architecture consistency check job，确保代码签名与 `INTERFACE_CONTRACT.md` 一致；模块目录结构反映接口边界 |
| **Reality as Baseline** | 测试目录结构支持 Mock 和真实 LLM 测试（带 `skipif`）；覆盖率检查阈值 80%；所有生成的代码必须通过语法验证 |
| **State as Responsibility** | 生成的状态管理基础设施（数据库连接、缓存配置）与 `StateModel` 的所有权定义匹配；环境变量模板覆盖所有状态存储的外部依赖 |
| **XML as Authority** | `docs/architecture/INDEX.md` 正确索引所有 XML 产物；CI 强制执行 XML 一致性检查（`architecture-ci.sh` + `xml-sync.py`）；代码签名必须与 `component-spec.xml` 一致 |

---

## 八、与其他技能的协作边界

### 与上游技能的关系

```
architecture-design (2) ──→ 提供 architecture.xml、INTERFACE_CONTRACT.md、技术栈选择
architecture-validation (3a) ──→ 提供 VALIDATION_REPORT.md（参考已知技术问题）
design-review (3b) ──→ 提供 DESIGN_REVIEW.md（Must Fix / Should Fix 转为 TODO）
                           ↓
                    project-scaffolding (4)
```

### 与下游 `devforge-module-design`（Stage 5）的关系

```
project-scaffolding (4) ──→ module-design (5)
    模块目录已初始化              填充组件分解、接口、代码骨架
    __init__.py (仅 header)      生成 component-spec.xml
    测试框架已就绪                生成具体测试用例
    CI 已配置                    运行测试验证模块设计
```

**关键约束**：module-design 的 precondition 是 `scaffolding_completed`，确保基础设施就绪后才设计业务逻辑。

### 与 `devforge-debug-assistant` / `devforge-ops-ready` 的关系

```
project-scaffolding (4) ──→ 生成 repo-index.md
                               ↓
                    ┌─────────────────────┐
                    ↓                     ↓
         debug-assistant (10)      ops-ready (9)
         （通过 repo-index 快速        （通过 repo-index 了解
          定位代码和模块）              代码库结构生成运维配置）
```

---

## 九、总结

`devforge-project-scaffolding` 是 DevForge 链条中从"设计"到"实现"的**关键转折点**。它的核心价值在于：

1. **从文档到代码**：将已批准的架构设计转化为可编译、可运行的项目基础设施
2. **只搭骨架，不填肉**：严格区分基础设施和业务逻辑，防止绕过 module-design
3. **质量门禁内嵌**：CI 中的覆盖率检查和架构一致性检查确保质量标准从第一天起就得到执行
4. **可追溯性贯穿**：每个文件都有 header comment 标明其设计来源；随机审计确保可追溯性
5. **安全基线建立**：`.env.template` 从项目第一天就建立"密钥不硬编码"的安全文化
6. **文档同步规则**：防止代码与文档脱节，建立双向同步机制

它是 DIVE 工作流 **Implement 阶段的奠基者**——没有 scaffolding 搭建的基础设施，后续的 module-design、test-execution、iteration-planning 都无从谈起。

---

> 生成日期：2026-05-12
> 基于：DevForge SDLC Skill Chain v1.4
> 关联文档：devforge-design-review-详解.md（Stage 3b）、devforge-module-design/SKILL.md（Stage 5）
