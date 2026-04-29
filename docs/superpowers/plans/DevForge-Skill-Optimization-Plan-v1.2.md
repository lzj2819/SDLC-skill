# DevForge Skill Chain v1.2 优化实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为 DevForge SDLC Skill Chain v1.2 实施 6 项优化（文档门槛、介入机制、错误追踪、安全扫描、产物管理、搜索集成），新增 5 个模块并集成到现有流程。

**Architecture:** 模块化扩展策略——新增独立 Skill 和工具规范文件，现有 10 阶段流程保持不变，通过插入调用点实现集成。每个模块可独立验证和迭代。

**Tech Stack:** Markdown 规范文件 + Bash/Python 脚本（无额外依赖）

---

## 文件结构映射

```
SDLC-skill/
├── README.md                                    # [新建] 开发者入门
├── examples/
│   └── quickstart-todo-app.md                   # [新建] QuickStart 示例
├── skill/
│   ├── sdlc-security-audit/
│   │   └── SKILL.md                             # [新建] 安全扫描 Skill
│   ├── tools/
│   │   ├── error-tracing.md                     # [新建] 错误追踪规范
│   │   ├── artifact-manager.md                  # [新建] 产物管理规范
│   │   └── intervention-checkpoint.md           # [新建] 介入机制规范
│   └── references/
│       └── search-integration.md                # [新建] 搜索集成规范
├── scripts/
│   ├── architecture-ci.sh                       # [修改] 新增安全检查 job
│   └── xml-sync.py                              # [修改] 新增 --dry-run 和冲突检测
└── DevForge.md                                  # [修改] 插入各模块调用点
```

---

## Phase 1: 基础设施（文档门槛 + 错误追踪 + 产物管理）

### Task 1: 新建 README.md

**Files:**
- Create: `README.md`

- [ ] **Step 1: 写入 README 基础结构**

```markdown
# DevForge SDLC Skill Chain

> 基于 VCMF 与 DIVE 方法论的 AI 驱动软件开发生命周期工具链

## 一句话介绍

DevForge 是一套面向全栈软件工程的 AI Skill 链，将产品需求到代码脚手架的完整 SDLC 流程标准化为 10 个可迭代的阶段，确保推理链不断、上下文不丢失、产物可追溯。

## 3 分钟 QuickStart

查看 [examples/quickstart-todo-app.md](examples/quickstart-todo-app.md) 了解如何从空目录开始，在 10 个阶段内生成一个完整的 Todo 应用。

## 10 个阶段速查表

| 阶段 | Skill | 触发条件 | 产物 |
|------|-------|---------|------|
| 1 | PRD 方法论对齐 | 用户输入产品想法 | PRD 框架 |
| 2 | 敏捷 PRD 构建 | 阶段一 [APPROVE] | PRD.md |
| 3 | 深度架构设计 | 阶段二 [APPROVE] | architecture.xml + 测试用例 |
| 4 | LLM 沙盘模拟 | 阶段三 [APPROVE] | 验证报告 |
| 5 | 实施脚手架 | 阶段四 [APPROVE] | 完整项目代码 |
| 6 | 模块细化设计 | `[MODULE {id}]` | module-architecture.xml |
| 7 | 增量迭代规划 | 新需求 | ITERATION_PLAN.md |
| 8 | 架构可视化 | `[VISUALIZE]` | Mermaid 图表 |
| 9 | 生产就绪设施 | `[OPS]` | Terraform/K8s 配置 |
| 10 | 调试与重构 | `[DEBUG]` | DEBUG_REPORT.md |

## 目录结构

```
.
├── DevForge.md              # 核心 Skill 定义
├── examples/                # 示例项目
├── skill/                   # Skill 目录
│   ├── sdlc-security-audit/ # 安全扫描
│   ├── tools/               # 工具规范
│   └── references/          # 参考文档
├── scripts/                 # 自动化脚本
│   ├── architecture-ci.sh   # 架构一致性检查
│   └── xml-sync.py          # XML 同步与验证
└── 建议/                     # 设计文档
```

## 人类门控命令

| 命令 | 作用 |
|------|------|
| `[APPROVE]` | 确认当前阶段，进入下一阶段 |
| `[PAUSE]` | 暂停当前 Skill，保持上下文 |
| `[ROLLBACK {step}]` | 回滚到指定步骤 |
| `[EXPLAIN {TraceID}]` | 展开解释错误/决策 |
| `[EDIT {file}]` | 编辑文件后继续 |
| `[SKIP]` | 跳过可选步骤 |
| `[INJECT {context}]` | 补充上下文 |
| `[SECURITY_AUDIT]` | 触发安全扫描 |

## 常见问题

**Q: DevForge 与 Copilot/Cursor 有什么区别？**
A: DevForge 不是代码补全工具，而是一套完整的软件工程方法论框架，确保从需求到代码的推理链完整可追溯。

**Q: 是否必须走完所有 10 个阶段？**
A: 否。阶段 1-5 是核心链路（需求→架构→验证→审查→代码），阶段 6-10 按需触发。

**Q: 产物会重复生成吗？**
A: 遵循 artifact-manager 的 CRUD-Append 模式，已有内容不会被覆盖，只增量更新变更部分。
```

- [ ] **Step 2: 验证文件存在且内容完整**

Run: `cat README.md | head -20`
Expected: 输出包含 "# DevForge SDLC Skill Chain"

- [ ] **Step 3: 提交**

```bash
git add README.md
git commit -m "docs: add README.md with QuickStart reference and gate commands"
```

---

### Task 2: 新建 QuickStart 示例

**Files:**
- Create: `examples/quickstart-todo-app.md`

- [ ] **Step 1: 写入 QuickStart 示例**

```markdown
# QuickStart: Todo 应用

本示例展示如何使用 DevForge 从空目录开始，在 10 个阶段内生成一个完整的 Todo 应用。

## 起点

空目录，用户输入：
> "我想做一个 Todo 应用，可以添加任务、标记完成、设置截止日期。"

## 阶段一：PRD 方法论对齐

**输入**：产品想法
**AI 动作**：
1. 阐述"四维推演"（Why/What/How/Modules）
2. 提出 3-5 个补全问题
3. 提取领域标签：`frontend_heavy`, `high_read_write_ratio`

**产物**：无（仅对话）
**门控**：用户回答补全问题后回复 `[APPROVE]`

## 阶段二：敏捷 PRD 构建

**输入**：阶段一的对话上下文
**AI 动作**：生成结构化 PRD.md

**产物**：`PRD.md`
- 项目背景：个人任务管理
- 用户故事：US-001（添加任务）、US-002（标记完成）、US-003（设置截止日期）
- 核心需求：P0（CRUD）、P1（截止日期提醒）
- 非功能性需求：响应时间 < 200ms

**门控**：用户确认 PRD 后回复 `[APPROVE]`

## 阶段三：深度架构设计

**输入**：PRD.md + STATE.md
**AI 动作**：
1. 动态筛选架构模式（标签匹配）
2. 并行评估 4-6 种模式
3. 生成三层 XML 架构

**产物**：
- `architecture.xml`（系统级）
- `modules/TaskService/module-architecture.xml`（模块级）
- `modules/TaskService/components/TaskController/component-spec.xml`（组件级）
- `INTERFACE_CONTRACT.md`

**门控**：用户确认架构后回复 `[APPROVE]`

## 阶段四：LLM 沙盘模拟

**输入**：三层 XML + Mock 数据
**AI 动作**：虚拟执行数据流，验证接口一致性

**产物**：`VALIDATION_REPORT.md`
**门控**：沙盘通过后回复 `[APPROVE]`

## 阶段五：实施脚手架

**输入**：全部历史产物
**AI 动作**：
1. 生成项目目录树
2. 生成依赖配置（package.json）
3. 从 component-spec.xml 生成代码骨架
4. 生成测试夹具
5. 生成 CI/CD 配置

**产物**：`PROJECT_SCAFFOLD/`（完整可运行项目）
**门控**：用户确认代码后回复 `[APPROVE]`

## 阶段六（按需）：模块细化

输入 `[MODULE TaskService]` 触发，生成模块内部详细设计。

## 增量迭代

后续新增"任务分类"功能时，调用阶段七 `sdlc-iteration-planning`，只做增量更新。
```

- [ ] **Step 2: 验证文件存在**

Run: `ls examples/quickstart-todo-app.md`
Expected: 文件存在

- [ ] **Step 3: 提交**

```bash
git add examples/quickstart-todo-app.md
git commit -m "docs: add Todo app QuickStart example"
```

---

### Task 3: 新建 error-tracing 工具规范

**Files:**
- Create: `skill/tools/error-tracing.md`

- [ ] **Step 1: 写入错误追踪规范**

```markdown
# Error Tracing 工具规范

**版本**: v1.0
**适用范围**: 所有 Skill 的报错输出

## 目的

确保每个报错可追踪到具体决策、需求和代码位置，提供修复建议，降低开发者调试成本。

## 报错格式规范

所有 Skill 在报错时必须使用以下格式：

```markdown
## [ERROR] {ErrorCode}: {一句话描述}

**发生位置**：{Skill名称} → {步骤编号} → {产物文件:行号}

**TraceID**：`{DecisionID}-{ErrorCode}-{Timestamp}`
- 关联决策：[{DecisionID}] {DecisionTitle}
- 关联需求：{US-ID} ({UserStoryTitle})

**上下文摘要**：
- 输入条件：{导致错误的输入/状态}
- 推理路径：{AI 基于什么前提得出该结论}
- 相关产物：
  - PRD.md:{行号}
  - ARCHITECTURE.md:{行号}
  - {当前文件}:{行号}

**修复建议**：
1. {具体步骤 1}
2. {具体步骤 2}

**人工介入**：
- 回复 `[EXPLAIN {TraceID}]` 展开完整推理链
- 回复 `[ROLLBACK {步骤编号}]` 回滚到上一步
```

## ErrorCode 命名规范

格式：`{SkillPrefix}-{Category}-{Number}`

| Skill | Prefix | Category |
|-------|--------|---------|
| sdlc-requirement-analysis | `REQ` | `SCHEMA`, `SCOPE`, `CONFLICT` |
| sdlc-architecture-design | `ARCH` | `XML`, `CONTRACT`, `PATTERN` |
| sdlc-architecture-validation | `VAL` | `CONSISTENCY`, `MOCK`, `SCHEMA` |
| sdlc-project-scaffolding | `SCAF` | `CODE`, `DEPENDENCY`, `PATH` |
| sdlc-module-design | `MOD` | `COMPONENT`, `INTERFACE` |

## 与 STATE.md 集成

在 STATE.md 中追加 `ErrorLog` 字段：

```yaml
ErrorLog:
  - timestamp: "2026-04-29T10:00:00Z"
    traceId: "arch-dec-0042-ERR-001-20260429100000"
    errorCode: "ARCH-XML-001"
    status: pending
    location: "sdlc-architecture-design → Step 5 → architecture.xml:42"
  - timestamp: "2026-04-29T10:05:00Z"
    traceId: "arch-dec-0042-ERR-001-20260429100000"
    errorCode: "ARCH-XML-001"
    status: fixed
```

## 与 DECISION_LOG.md 集成

每个 Decision 新增 `ValidationStatus` 字段：

```markdown
### [arch-dec-0042] Use JWT for auth

- **Status**: accepted
- **ValidationStatus**: failed-with-ARCH-XML-001
- **ErrorLog**: [TraceID: arch-dec-0042-ERR-001-20260429100000]
```

## 使用示例

### 场景：XML Schema 验证失败

```markdown
## [ERROR] ARCH-XML-001: Invalid Schema in architecture.xml

**发生位置**：sdlc-architecture-design → Step 5 → architecture.xml:42

**TraceID**：`arch-dec-0042-ERR-001-20260429100000`
- 关联决策：[arch-dec-0042] Use JWT for auth
- 关联需求：US-001 (User login)

**上下文摘要**：
- 输入条件：Decision [arch-dec-0042] 指定 JWT 认证，但 XML 中 <Security> 节点缺失 <Authentication> 子节点
- 推理路径：Decision → XML 建模 → Schema 验证 → 发现 <Authentication> 缺失
- 相关产物：
  - PRD.md:15 (US-001 要求登录功能)
  - DECISION_LOG.md:42 (arch-dec-0042 决策)
  - architecture.xml:42 (缺失节点位置)

**修复建议**：
1. 在 architecture.xml:42 添加 `<Authentication type="JWT" issuer="UserService" />`
2. 重新运行 Schema 验证

**人工介入**：
- 回复 `[EXPLAIN arch-dec-0042-ERR-001-20260429100000]` 展开完整推理
- 回复 `[ROLLBACK phase3-step5]` 回滚到架构设计步骤 5
```
```

- [ ] **Step 2: 验证文件存在且格式正确**

Run: `cat skill/tools/error-tracing.md | grep "## 报错格式规范"`
Expected: 输出匹配

- [ ] **Step 3: 提交**

```bash
git add skill/tools/error-tracing.md
git commit -m "docs(tools): add error-tracing specification with TraceID and DecisionID linkage"
```

---

### Task 4: 新建 artifact-manager 工具规范

**Files:**
- Create: `skill/tools/artifact-manager.md`

- [ ] **Step 1: 写入产物管理规范**

```markdown
# Artifact Manager 工具规范

**版本**: v1.0
**适用范围**: 所有生成产物的 Skill

## 目的

确保产物更新遵循幂等性原则，避免重复生成覆盖已有内容，支持增量更新和冲突检测。

## 核心原则：CRUD-Append

所有产物写入遵循：
1. **Read**: 读取现有内容
2. **Compute Diff**: 计算新旧差异
3. **Update Delta**: 只更新变更部分
4. **Preserve Manual**: 保留用户手动修改

## 产物分类与更新策略

| 产物类型 | 更新模式 | 策略说明 |
|---------|---------|---------|
| `PRD.md` | Append-only | 新增 User Story 追加到末尾，已有 US 不变 |
| `DECISION_LOG.md` | Append-only | 新决策追加，已有决策标记 `superseded` |
| `STATE.md` | Selective update | `Current State` 覆盖，其余字段追加 |
| `architecture.xml` | Merge-update | 新增模块插入，已有模块更新变更字段 |
| `module-architecture.xml` | Merge-update | 保留组件内手动注释 |
| `component-spec.xml` | Conservative update | 已有 `<Function>` 不覆盖，只新增缺失 |
| `INTERFACE_CONTRACT.md` | Merge-update | 新增接口追加，已有接口更新版本号 |
| `PROJECT_SCAFFOLD/` | Overlay | 新增文件写入，已有非 `auto-generated` 文件跳过 |

## 冲突检测规则

1. **手动修改标记**：用户手动修改的内容应标记为 `<!-- MANUAL: {description} -->` 或 `// MANUAL: {description}`
2. **冲突判定**：如果 AI 要更新的区域包含手动标记，则判定为冲突
3. **冲突处理**：
   - 生成 `ARTIFACT_MERGE_CONFLICT.md`
   - 列出冲突点（文件路径、行号、AI 建议内容、现有手动内容）
   - 等待人工解决

## 产物版本标记

每个产物头部自动注入：

```markdown
<!-- GENERATED-BY: {skill_name} -->
<!-- GENERATED-AT: {ISO8601_timestamp} -->
<!-- LAST-MODIFIED: {ISO8601_timestamp} -->
<!-- UPDATE-RULE: {merge|append|overlay|conservative} -->
<!-- DO-NOT-EDIT-MANUALLY-UNLESS-MARKED -->
```

## 产物统一目录

```
docs/architecture/
├── system/
│   ├── PRD.md
│   ├── architecture.xml
│   ├── INTERFACE_CONTRACT.md
│   └── STATE.md
├── modules/
│   └── {module_id}/
│       ├── module-architecture.xml
│       └── components/
│           └── {component_id}/
│               └── component-spec.xml
├── validation/
│   └── VALIDATION_DELTA_*.md
├── security/
│   └── SECURITY_AUDIT_REPORT.md
└── merge-conflicts/
    └── ARTIFACT_MERGE_CONFLICT_*.md
```

## 与 xml-sync.py 集成

`xml-sync.py` 新增参数：

```bash
# 预览变更而不写入
python xml-sync.py --dry-run

# 强制覆盖手动标记（需二次确认）
python xml-sync.py --force
```

`xml-sync.py` 在 `sync` 模式时调用 artifact-manager 的 merge 逻辑处理 XML 文件更新。

## 使用示例

### 场景：迭代新增模块

已有 `architecture.xml` 包含 UserService 模块，迭代新增 PaymentService：

1. artifact-manager 读取现有 `architecture.xml`
2. 检测新模块 PaymentService（XML 中新增 `<Module id="PaymentService">`）
3. 插入新模块节点，保留所有已有模块不变
4. 更新产物头部 `LAST-MODIFIED` 时间戳
5. 写入文件

### 场景：组件接口变更

已有 `component-spec.xml` 包含 `login()` 函数，迭代新增 `logout()`：

1. artifact-manager 读取现有 `component-spec.xml`
2. 检测新增 `<Function id="logout">` 节点
3. 仅追加新函数节点，保留 `login()` 不变
4. 如果 `login()` 已有 `// MANUAL:` 注释，完全保留
```

- [ ] **Step 2: 验证文件存在**

Run: `ls skill/tools/artifact-manager.md`
Expected: 文件存在

- [ ] **Step 3: 提交**

```bash
git add skill/tools/artifact-manager.md
git commit -m "docs(tools): add artifact-manager specification with CRUD-Append and conflict detection"
```

---

### Task 5: 修改 DevForge.md 集成 error-tracing 和 artifact-manager

**Files:**
- Modify: `DevForge.md`（多处插入引用）

- [ ] **Step 1: 在全局约束中插入工具引用**

在 `DevForge.md` 的约束与原则部分（第 278 行附近），新增两条约束：

```markdown
* **错误追踪规范**：所有报错遵循 `skill/tools/error-tracing.md` 格式，包含 TraceID 和 DecisionID 关联。
* **产物管理规范**：所有产物生成遵循 `skill/tools/artifact-manager.md` 的 CRUD-Append 模式，避免覆盖已有内容。
```

- [ ] **Step 2: 在阶段四插入 error-tracing**

在阶段四（LLM 沙盘模拟）的"自修复循环"部分（第 155 行附近），修改描述为：

```markdown
5. **自修复循环 (Self-Healing Loop)**：若发现流程断点、数据格式冲突、或安全校验失败等问题，则必须：
   - 使用 error-tracing 格式生成错误报告（含 TraceID 和修复建议）
   - 更新 STATE.md 的 ErrorLog
   - 报错退回阶段三修改 XML，直到跑通
```

- [ ] **Step 3: 在阶段五插入 artifact-manager**

在阶段五（实施脚手架）的"工程脚手架"部分（第 166 行附近），在"输出项目基础目录树"之前插入：

```markdown
1. **产物幂等更新**：在写入任何产物前，调用 artifact-manager 的 CRUD-Append 逻辑：
   - 读取现有产物（如果存在）
   - 计算差异，只更新变更部分
   - 检测手动修改标记，生成冲突报告（如有）
   - 写入产物并更新版本标记
```

- [ ] **Step 4: 验证修改**

Run: `grep -c "error-tracing" DevForge.md && grep -c "artifact-manager" DevForge.md`
Expected: 两个输出都大于 0

- [ ] **Step 5: 提交**

```bash
git add DevForge.md
git commit -m "feat(DevForge): integrate error-tracing and artifact-manager tools into workflow"
```

---

## Phase 2: 交互增强（介入机制）

### Task 6: 新建 intervention-checkpoint 工具规范

**Files:**
- Create: `skill/tools/intervention-checkpoint.md`

- [ ] **Step 1: 写入介入机制规范**

```markdown
# Intervention Checkpoint 工具规范

**版本**: v1.0
**适用范围**: 所有含人类门控的 Skill

## 目的

扩展人类门控机制，使开发者能够在 AI 走偏时精细介入、回滚、修正，而不只有通过/拒绝两个选项。

## 新增交互命令

| 命令 | 语法 | 作用 | 适用场景 |
|------|------|------|---------|
| `[PAUSE]` | `[PAUSE]` | 暂停当前 Skill，保持上下文，开发者可输入问题 | AI 生成内容看起来有问题，需要思考 |
| `[ROLLBACK {step_id}]` | `[ROLLBACK phase2-step3]` | 回滚到指定步骤，重新执行 | 发现某一步推理错误 |
| `[EXPLAIN {TraceID}]` | `[EXPLAIN arch-dec-0042-ERR-001]` | 展开解释错误/决策的完整推理链 | 不理解 AI 为什么得出某个结论 |
| `[EDIT {file_path}]` | `[EDIT architecture.xml]` | 开发者直接编辑文件后，AI 基于修改继续 | 开发者有具体修改意见 |
| `[SKIP]` | `[SKIP]` | 跳过当前可选步骤 | 阶段八可视化、阶段九运维等可选步骤 |
| `[INJECT {context}]` | `[INJECT 用户偏好使用 PostgreSQL 而非 MySQL]` | 补充额外上下文，AI 重新评估当前步骤 | 发现 AI 遗漏了重要信息 |

## Checkpoint 机制

### 自动保存

每个 Skill 执行前自动保存 checkpoint：

```
checkpoints/
├── sdlc-requirement-analysis_20260429T100000.md
├── sdlc-architecture-design_20260429T101500.md
└── sdlc-project-scaffolding_20260429T110000.md
```

每个 checkpoint 包含：
- `timestamp`: ISO8601 时间戳
- `skill`: 当前 Skill 名称
- `step`: 当前步骤编号
- `artifacts_snapshot`: 所有产物的内容快照（SHA256）
- `context_summary`: 当前上下文摘要（200 字）
- `next_action`: 下一步计划

### 回滚流程

1. 用户输入 `[ROLLBACK phase2-step3]`
2. 系统解析 `phase2` 对应 `sdlc-architecture-design`，`step3` 对应第 3 步
3. 读取该 Skill 最近一次的 checkpoint
4. 恢复产物到 checkpoint 快照状态
5. 从步骤 3 开始重新执行
6. 更新 STATE.md 的 `Current State`

### 与 error-tracing 集成

`[EXPLAIN {TraceID}]` 命令触发 error-tracing 的展开模式：
- 读取 TraceID 关联的 DecisionID
- 从 DECISION_LOG.md 提取完整决策上下文
- 从 STATE.md 提取相关步骤历史
- 生成解释报告（含推理路径、相关产物、修复建议）

## 使用示例

### 场景：架构设计走偏

AI 在阶段三推荐了微服务架构，但用户认为单体应用更合适：

1. 用户输入 `[PAUSE]`
2. 用户输入 "项目团队只有 2 人，微服务过于复杂，请重新评估"
3. 用户输入 `[INJECT 团队规模=2人，优先简单可维护]`
4. AI 重新评估，从 checkpoint 恢复并重新执行阶段三
5. AI 重新推荐单体架构 + 清晰模块化
6. 用户输入 `[APPROVE]`

### 场景：XML 验证失败回滚

阶段四沙盘模拟发现 XML 错误：

1. AI 报错（使用 error-tracing 格式，TraceID: arch-dec-0042-ERR-001）
2. 用户输入 `[EXPLAIN arch-dec-0042-ERR-001]`
3. AI 展开解释：决策 [arch-dec-0042] 要求 JWT，但 XML 缺失 Authentication 节点
4. 用户输入 `[ROLLBACK phase3-step5]`
5. 系统回滚到阶段三步骤 5，AI 重新生成 XML
```

- [ ] **Step 2: 验证文件存在**

Run: `ls skill/tools/intervention-checkpoint.md`
Expected: 文件存在

- [ ] **Step 3: 提交**

```bash
git add skill/tools/intervention-checkpoint.md
git commit -m "docs(tools): add intervention-checkpoint with rollback, pause, explain commands"
```

---

### Task 7: 修改 DevForge.md 集成 intervention-checkpoint

**Files:**
- Modify: `DevForge.md`

- [ ] **Step 1: 在人类门控部分扩展命令**

在 `DevForge.md` 的人类审核门控部分（第 46 行附近），修改门控消息为：

```markdown
**🛑 人类审核门控 (Human-in-the-loop Gate)**：

在每一个阶段完成时，必须停止输出，并向用户发送：

"**请确认当前阶段输出。回复 [APPROVE] 进入下一阶段，[PAUSE] 暂停讨论，[ROLLBACK] 回滚当前步骤，或提出修改意见。**"

可用命令：
- `[APPROVE]` - 确认并继续
- `[PAUSE]` - 暂停，保持上下文
- `[ROLLBACK {step_id}]` - 回滚到指定步骤
- `[EXPLAIN {TraceID}]` - 展开解释
- `[EDIT {file_path}]` - 编辑文件后继续
- `[SKIP]` - 跳过可选步骤
- `[INJECT {context}]` - 补充上下文
```

- [ ] **Step 2: 在全局约束中插入引用**

在约束与原则部分新增：

```markdown
* **介入机制规范**：遵循 `skill/tools/intervention-checkpoint.md`，支持 checkpoint 回滚和精细介入。
```

- [ ] **Step 3: 提交**

```bash
git add DevForge.md
git commit -m "feat(DevForge): expand gate commands with intervention-checkpoint (PAUSE, ROLLBACK, EXPLAIN, EDIT, SKIP, INJECT)"
```

---

## Phase 3: 安全能力（安全扫描）

### Task 8: 新建 sdlc-security-audit Skill

**Files:**
- Create: `skill/sdlc-security-audit/SKILL.md`

- [ ] **Step 1: 写入安全扫描 Skill**

```markdown
# sdlc-security-audit

**版本**: v1.0
**类型**: 独立可选 Skill
**定位**: 代码级安全扫描，作为 design-review 的补充

## 触发条件

- 阶段三生成 `architecture.xml` 后（架构层安全检查）
- 阶段五生成代码骨架后（代码级安全检查）
- 阶段六生成 `component-spec.xml` 后（组件级安全检查）
- 用户手动输入 `[SECURITY_AUDIT]`

## 扫描维度

### 🔴 Critical（必须修复）

| 检查项 | 检测方式 | 示例风险 |
|--------|---------|---------|
| 硬编码密钥/Token | 正则匹配 API Key、密码、私钥模式 | `api_key = "sk-12345"` |
| SQL 注入风险 | 检测字符串拼接 SQL、无参数化查询 | `query = "SELECT * FROM users WHERE id = " + userId` |
| XSS/注入漏洞 | 检测未转义输出、危险 innerHTML | `element.innerHTML = userInput` |

### 🟡 High（强烈建议修复）

| 检查项 | 检测方式 | 示例风险 |
|--------|---------|---------|
| 不安全的依赖 | WebSearch 检查 CVE | 依赖包存在已知漏洞 |
| 不安全的文件操作 | 检测路径遍历、任意文件读写 | `open("../" + filename)` |
| 敏感数据日志 | 检测密码/Token 被打印到日志 | `logger.info(f"Password: {password}")` |

### 🟢 Medium（可选修复）

| 检查项 | 检测方式 | 示例风险 |
|--------|---------|---------|
| 弱加密算法 | 检测 MD5/SHA1、硬编码盐值 | `hashlib.md5(password)` |
| 越权访问 | 检测缺少权限校验的接口 | `@app.route("/admin")` 无权限装饰器 |

## 工作流程

1. **读取目标产物**
   - 代码文件（.py, .js, .ts, .java 等）
   - 配置文件（.env, .yaml, .json）
   - XML 架构文件

2. **静态规则扫描**
   - 按维度执行正则匹配和模式检测
   - 生成初步问题列表

3. **依赖安全扫描**
   - 提取依赖列表（package.json, requirements.txt, pom.xml）
   - 对每个依赖调用 WebSearch 检查 CVE
   - 格式：`WebSearch "{package_name} CVE 2026"`

4. **生成报告**
   - 生成 `SECURITY_AUDIT_REPORT.md`
   - 按严重程度分类
   - 每个问题包含：位置、风险描述、修复建议、参考链接

5. **更新状态**
   - 将 Critical 和 High 级别问题写入 STATE.md 的 `Known Pitfalls`
   - 关联到 DECISION_LOG.md（如适用）

6. **人类门控**
   - `[APPROVE]` - 接受风险（仅 Medium/Low 级别可批准）
   - `[FIX]` - 自动修复（仅支持简单替换，如硬编码密钥提取到 .env）
   - `[IGNORE]` - 标记为误报（记录到 IGNORE_LIST.md）

## 输出产物

### SECURITY_AUDIT_REPORT.md

```markdown
# Security Audit Report

**Generated**: 2026-04-29T10:00:00Z
**Scope**: PROJECT_SCAFFOLD/
**Auditor**: sdlc-security-audit v1.0

## 🔴 Critical (2)

### CRIT-001: Hardcoded API Key
- **File**: `src/config.py:15`
- **Line**: `API_KEY = "sk-abc123"`
- **Risk**: 密钥泄露，可能导致未授权访问
- **Fix**: 提取到 `.env` 文件，使用 `os.getenv("API_KEY")`
- **Rule**: hardcoded-secret

### CRIT-002: SQL Injection
- **File**: `src/repository.py:42`
- **Line**: `query = f"SELECT * FROM tasks WHERE id = {task_id}"`
- **Risk**: 攻击者可注入恶意 SQL
- **Fix**: 使用参数化查询 `query = "SELECT * FROM tasks WHERE id = ?"`
- **Rule**: sql-injection

## 🟡 High (1)

### HIGH-001: Dependency CVE
- **Package**: `lodash@4.17.20`
- **CVE**: CVE-2021-23337
- **Risk**: 原型污染漏洞
- **Fix**: 升级到 `lodash@4.17.21`
- **Evidence**: [Search: lodash CVE 2021]

## 🟢 Medium (0)

无

## 修复建议优先级

1. [P0] 修复 CRIT-001：提取所有硬编码密钥到 .env
2. [P0] 修复 CRIT-002：替换所有字符串拼接 SQL 为参数化查询
3. [P1] 修复 HIGH-001：升级 lodash 到安全版本
```

### 内联代码注释

在扫描出的问题代码位置添加注释：

```python
# SECURITY-AUDIT: CRIT-001 - Hardcoded API Key detected
# Fix: Move to .env and use os.getenv()
API_KEY = "sk-abc123"  # noqa: security
```

## 与 design-review 的区别

| 维度 | sdlc-security-audit | sdlc-design-review |
|------|---------------------|-------------------|
| 关注点 | 代码级实现漏洞 | 架构级设计缺陷 |
| 方法 | 静态规则扫描 + CVE 检查 | 攻击者/维护者/扩展者三视角 |
| 输出 | 问题清单 + 自动修复建议 | 问题清单（无自动修复） |
| 触发 | 自动生成或手动 `[SECURITY_AUDIT]` | 手动触发 |
```

- [ ] **Step 2: 验证文件存在**

Run: `ls skill/sdlc-security-audit/SKILL.md`
Expected: 文件存在

- [ ] **Step 3: 提交**

```bash
git add skill/sdlc-security-audit/SKILL.md
git commit -m "feat(skill): add sdlc-security-audit with 8-dimension scanning and CVE checking"
```

---

### Task 9: 修改 DevForge.md 集成 security-audit

**Files:**
- Modify: `DevForge.md`

- [ ] **Step 1: 在阶段三插入安全扫描调用点**

在阶段三（深度架构设计）结束前（第 132 行附近），在"自校验"之后插入：

```markdown
7. **安全扫描（可选）**：
   - 调用 `sdlc-security-audit` 对 `architecture.xml` 进行架构层安全检查
   - 扫描 `<Security>` 节点完整性、`<Authentication>` 配置、`<Encryption>` 策略
   - 产物：`SECURITY_AUDIT_REPORT.md`（架构层）
```

- [ ] **Step 2: 在阶段五插入安全扫描调用点**

在阶段五（实施脚手架）的"工程脚手架"部分（第 166 行附近），在"架构产物同步"之后插入：

```markdown
5. **安全扫描**：
   - 调用 `sdlc-security-audit` 对生成的代码骨架进行安全扫描
   - 扫描硬编码密钥、SQL 注入、XSS、不安全依赖等
   - 产物：`SECURITY_AUDIT_REPORT.md`（代码层）
   - Must Fix 问题自动转为内联 TODO
```

- [ ] **Step 3: 在全局约束中插入安全原则**

在约束与原则部分新增：

```markdown
* **安全扫描**：代码生成后必须执行 `sdlc-security-audit`，Critical 级别问题必须修复后方可进入下一阶段。
```

- [ ] **Step 4: 提交**

```bash
git add DevForge.md
git commit -m "feat(DevForge): integrate sdlc-security-audit at architecture and scaffolding phases"
```

---

### Task 10: 修改 scripts/architecture-ci.sh 新增安全检查

**Files:**
- Modify: `scripts/architecture-ci.sh`

- [ ] **Step 1: 新增安全检查 job**

在现有检查之后新增第 6 项检查：

```bash
# 6. Security checks
echo ""
echo "[6/6] Checking security best practices..."
while IFS= read -r -d '' codefile; do
    # Check for hardcoded secrets
    if grep -Ei '(password|secret|token|key)\s*=\s*["\'][^"\']+["\']' "$codefile" 2>/dev/null; then
        echo "  WARN: Potential hardcoded secret in $codefile"
    fi
    # Check for SQL injection patterns
    if grep -Ei '(select|insert|update|delete).*\+.*\$' "$codefile" 2>/dev/null; then
        echo "  WARN: Potential SQL injection in $codefile"
    fi
done < <(find "$ARCH_DIR" -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.java" \) -print0)
```

- [ ] **Step 2: 更新检查总数**

将脚本头部的注释从 "[1/5]" 改为 "[1/6]"，所有步骤编号更新。

- [ ] **Step 3: 验证脚本语法**

Run: `bash -n scripts/architecture-ci.sh`
Expected: 无错误输出

- [ ] **Step 4: 提交**

```bash
git add scripts/architecture-ci.sh
git commit -m "feat(ci): add security checks for hardcoded secrets and SQL injection patterns"
```

---

## Phase 4: 搜索集成

### Task 11: 新建 search-integration 参考规范

**Files:**
- Create: `skill/references/search-integration.md`

- [ ] **Step 1: 写入搜索集成规范**

```markdown
# Search Integration 参考规范

**版本**: v1.0
**适用范围**: 所有 Skill 的技术验证和决策环节

## 目的

系统化搜索调用，确保在需要外部信息验证时主动搜索，避免依赖过时知识，同时防止搜索滥用导致成本上升。

## 各阶段搜索调用点

### 阶段一：PRD 方法论对齐

| 场景 | 搜索查询 | 用途 |
|------|---------|------|
| 竞品分析 | `WebSearch "{product_category} competitors 2026"` | 了解市场现有方案 |
| 技术可行性 | `WebSearch "{technology} limitations 2026"` | 评估技术选型风险 |

### 阶段三：深度架构设计

| 场景 | 搜索查询 | 用途 |
|------|---------|------|
| 框架版本 | `WebSearch "{framework} latest version 2026"` | 确保推荐最新稳定版 |
| CVE 检查 | `WebSearch "{framework/library} CVE 2026"` | 排除已知漏洞版本 |
| 性能基准 | `WebSearch "{framework} performance benchmark 2026"` | 获取实际性能数据 |
| 架构模式 | `WebSearch "{pattern} best practices 2026"` | 验证架构模式适用性 |

### 阶段五：实施脚手架

| 场景 | 搜索查询 | 用途 |
|------|---------|------|
| 依赖最佳实践 | `WebSearch "{package} best practices 2026"` | 获取配置建议 |
| Docker 镜像安全 | `WebSearch "{base_image} CVE 2026"` | 选择安全的基础镜像 |

### sdlc-security-audit

| 场景 | 搜索查询 | 用途 |
|------|---------|------|
| 依赖 CVE | `WebSearch "{package} CVE 2026"` | 验证依赖安全性 |
| 漏洞详情 | `WebSearch "{CVE-ID} exploit details"` | 评估漏洞影响范围 |

## 搜索结果引用规范

所有搜索结论必须包含：

```markdown
**搜索来源**：
- Query: `{实际搜索查询}`
- Source: [{标题}]({URL})
- Date: {搜索结果日期}
- Summary: {一句话摘要}
```

搜索结果存入 `DECISION_LOG.md` 的 `Evidence` 字段：

```markdown
### [arch-dec-0042] Use JWT for auth

- **Evidence**: 
  - [Search: "JWT vs Session 2026 best practices"]
    - Source: [Stateless Authentication with JWT](https://example.com/jwt-guide)
    - Summary: JWT 适合微服务，但需注意 token 刷新机制
```

## 搜索缓存规则

为避免重复搜索和成本浪费：

1. **查询缓存**：同一查询 24 小时内缓存结果
2. **结果标注**：所有搜索结果标注日期，超过 30 天的结果需重新验证
3. **必要搜索清单**：仅在下述场景触发搜索
   - 推荐第三方依赖时
   - 选择技术框架时
   - 安全检查（CVE）时
   - 用户明确要求竞品分析时

## 禁止搜索场景

以下场景不应触发搜索（使用训练知识即可）：
- 通用编程语言语法
- 基础算法实现
- 标准库 API 使用
- 通用设计模式解释

## 使用示例

### 场景：推荐数据库

AI 在阶段三需要为项目推荐数据库：

1. 提取项目特征：`high_read_write_ratio`, `multi_tenant`
2. 触发搜索：`WebSearch "PostgreSQL vs MongoDB high read write ratio 2026"`
3. 获取结果：
   - Source: [PostgreSQL Performance Tips](https://example.com/pg-perf)
   - Summary: PostgreSQL 14+ 的并行查询和分区表适合高读写比场景
4. 将结果存入 DECISION_LOG.md 的 Evidence
5. 基于搜索结果推荐 PostgreSQL

### 场景：依赖安全检查

sdlc-security-audit 扫描到 `lodash@4.17.20`：

1. 触发搜索：`WebSearch "lodash 4.17.20 CVE 2026"`
2. 获取结果：
   - CVE: CVE-2021-23337
   - Severity: High
   - Fix: Upgrade to 4.17.21
3. 将结果写入 SECURITY_AUDIT_REPORT.md
```

- [ ] **Step 2: 验证文件存在**

Run: `ls skill/references/search-integration.md`
Expected: 文件存在

- [ ] **Step 3: 提交**

```bash
git add skill/references/search-integration.md
git commit -m "docs(references): add search-integration with phase-based triggers and citation rules"
```

---

### Task 12: 修改 DevForge.md 集成搜索调用点

**Files:**
- Modify: `DevForge.md`

- [ ] **Step 1: 在阶段一插入搜索**

在阶段一的"上下文补全"之后插入：

```markdown
6. **竞品与技术调研**：
   - 根据产品想法，调用 WebSearch 进行竞品分析和技术可行性验证
   - 遵循 `skill/references/search-integration.md` 的调用点和引用规范
   - 结果存入 DECISION_LOG.md 的 Evidence 字段
```

- [ ] **Step 2: 在阶段三插入搜索**

在阶段三的"技术栈验证"部分（已存在），强化搜索要求：

```markdown
- **主动搜索**（优先）：使用 WebSearch/WebFetch 搜索 "{tool_name} deprecated"、"{tool_name} CVE"、"{tool_name} maintenance status"
- 遵循 `skill/references/search-integration.md` 的搜索缓存规则
- 搜索结果作为 DECISION_LOG.md 的 Evidence
```

- [ ] **Step 3: 在全局约束中插入搜索原则**

在约束与原则部分新增：

```markdown
* **搜索集成**：技术选型和安全检查时必须遵循 `skill/references/search-integration.md`，主动搜索验证依赖状态和 CVE。
```

- [ ] **Step 4: 提交**

```bash
git add DevForge.md
git commit -m "feat(DevForge): integrate search-integration at requirement and architecture phases"
```

---

## 自检清单

### Spec 覆盖检查

- [x] 问题 1（接入门槛）：README.md + QuickStart 示例
- [x] 问题 2（介入机制）：intervention-checkpoint 工具 + DevForge.md 集成
- [x] 问题 3（错误追踪）：error-tracing 工具 + DevForge.md 集成
- [x] 问题 4（安全漏洞）：sdlc-security-audit Skill + CI 集成
- [x] 问题 7（产物管理）：artifact-manager 工具 + DevForge.md 集成
- [x] 问题 8（搜索集成）：search-integration 参考 + DevForge.md 集成

### Placeholder 扫描

- [x] 无 TBD/TODO
- [x] 无 "implement later"
- [x] 所有步骤包含具体代码/命令
- [x] 所有文件路径明确

### 类型一致性

- [x] ErrorCode 格式统一：`{Prefix}-{Category}-{Number}`
- [x] TraceID 格式统一：`{DecisionID}-{ErrorCode}-{Timestamp}`
- [x] 产物路径统一使用 `docs/architecture/` 结构
- [x] 门控命令格式统一：`[COMMAND]`

---

## 执行选项

**计划完成并保存到 `建议/DevForge-Skill-Optimization-Plan-v1.2.md`。**

**两种执行方式：**

**1. Subagent-Driven（推荐）** - 为每个 Task 分派独立子代理，逐任务审查，快速迭代

**2. Inline Execution** - 在本会话中逐任务执行，批量执行并设置检查点

**选择哪种方式执行？**
