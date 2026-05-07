# Intervention Checkpoint 工具规范

**版本**：v1.0  
**适用范围**：所有含人类门控的 Skill  
**最后更新**：2026/04/29

---

## 1. 目的

本文档定义 DevForge SDLC Skill Chain 中人类介入（Human-in-the-Loop）的统一交互规范。当前系统仅支持 `[APPROVE]` 单一门控指令，无法应对 AI 推理偏离、产物质量不达标、开发者有明确修改意见等复杂场景。通过扩展门控命令集，使开发者能够在任意步骤对 AI 进行精细干预，包括暂停审查、回滚重试、要求解释、直接编辑、跳过可选步骤、补充上下文等操作。

---

## 2. 交互命令表

所有含人类门控的 Skill 必须识别并响应以下命令。命令不区分大小写，但推荐使用大写格式以与产物标记区分。

| 命令 | 语法 | 作用 | 适用场景 |
|------|------|------|----------|
| `[PAUSE]` | `[PAUSE]` | 暂停当前 Skill，保持上下文和内存状态 | AI 生成内容看起来有问题，需要人工审查后再继续 |
| `[ROLLBACK {step_id}]` | `[ROLLBACK phase2-step3]` | 回滚到指定步骤，恢复该步骤执行前的产物状态 | 发现某一步推理错误，需要基于正确的状态重新执行 |
| `[EXPLAIN {TraceID}]` | `[EXPLAIN arch-dec-0042-ERR-001]` | 展开解释指定错误码或决策的完整推理链 | 不理解 AI 为什么得出某个结论，需要追溯决策依据 |
| `[EDIT {file_path}]` | `[EDIT architecture.xml]` | 开发者直接编辑指定文件后，AI 基于修改后的内容继续 | 开发者有具体修改意见，希望手动调整后让 AI 接续 |
| `[SKIP]` | `[SKIP]` | 跳过当前可选步骤，直接进入下一步 | 当前阶段为可选阶段（如可视化、运维配置），开发者认为无需执行 |
| `[INJECT {context}]` | `[INJECT 用户偏好使用 PostgreSQL]` | 向当前 Skill 补充额外上下文信息 | 发现 AI 遗漏了重要信息，或需求在对话中发生了变化 |

### 2.1 命令详细说明

#### `[PAUSE]` — 暂停

- **触发时机**：AI 完成某一步输出后，等待用户审批时
- **行为定义**：
  1. Skill 停止执行后续步骤
  2. 当前上下文（对话历史、内存状态、已加载产物）完整保留
  3. 向用户输出暂停确认信息，包含当前步骤编号和已完成的产物列表
  4. 用户可随时输入 `[RESUME]` 继续，或输入其他命令进行干预
- **恢复方式**：用户输入 `[RESUME]` 或任意非命令文本（视为继续）

#### `[ROLLBACK {step_id}]` — 回滚

- **step_id 格式**：`{phase}-{step}`，如 `phase2-step3`、`design-step2`
- **行为定义**：
  1. 解析目标步骤编号
  2. 读取该步骤执行前保存的 checkpoint 文件
  3. 恢复产物到 checkpoint 中的 `artifacts_snapshot` 状态
  4. 恢复上下文到 checkpoint 中的 `context_summary` 状态
  5. 从目标步骤重新开始执行
  6. 更新 `STATE.md` 中的 `Current State` 和 `State History`
- **约束**：只能回滚到当前 Skill 已执行的步骤，不能跨 Skill 回滚

#### `[EXPLAIN {TraceID}]` — 解释

- **TraceID 格式**：参考 `error-tracing.md` 中的 TraceID 规范，如 `{DecisionID}-{ErrorCode}-{Timestamp}`
- **行为定义**：
  1. 解析 TraceID，提取 DecisionID、ErrorCode 和时间戳
  2. 触发 error-tracing 展开模式（详见第 5 节）
  3. 输出完整的推理链：输入条件 → 决策依据 → 推理路径 → 结论 → 关联产物
  4. 如果 TraceID 对应一个错误，额外输出修复建议和关联的决策记录
- **与 error-tracing 的关系**：`[EXPLAIN]` 是 error-tracing 的人工触发入口，两者共享决策日志和错误日志数据

#### `[EDIT {file_path}]` — 编辑

- **file_path 格式**：相对于项目根目录的相对路径，如 `design/architecture.xml`、`docs/PRD.md`
- **行为定义**：
  1. Skill 暂停，向用户输出待编辑文件的当前内容摘要
  2. 用户在外部编辑器中修改文件并保存
  3. 用户输入 `[DONE]` 或 `[CONTINUE]` 通知 Skill 编辑完成
  4. Skill 重新读取该文件，检测变更内容
  5. Skill 基于修改后的内容继续执行后续步骤
  6. 在 `STATE.md` 中记录本次人工编辑的变更摘要
- **约束**：编辑的文件必须是当前 Skill 已生成或依赖的产物，不能编辑无关文件

#### `[SKIP]` — 跳过

- **适用条件**：当前步骤必须被标记为 `optional: true`
- **行为定义**：
  1. Skill 跳过当前步骤的执行逻辑
  2. 该步骤的产物标记为 `SKIPPED`
  3. 直接进入下一步骤
  4. 在 `STATE.md` 中记录跳过原因（如用户提供）
- **强制跳过**：如果当前步骤不是可选步骤，Skill 必须拒绝跳过并提示用户该步骤为必需

#### `[INJECT {context}]` — 上下文注入

- **context 格式**：任意自然语言文本，描述需要补充的信息
- **行为定义**：
  1. Skill 将注入的上下文追加到当前会话的内存中
  2. 上下文对当前 Skill 的后续步骤生效
  3. 如果注入的内容与已有上下文冲突，Skill 必须提示用户确认覆盖或合并
  4. 在 `STATE.md` 中记录上下文变更日志
- **持久性**：注入的上下文仅在当前 Skill 执行期间有效，不会自动写入 `DECISION_LOG.md`，除非用户显式要求

---

## 3. Checkpoint 机制

### 3.1 自动保存

每个 Skill 在执行任意步骤前，必须自动保存 checkpoint 文件。Checkpoint 文件保存在项目根目录的 `.devforge/checkpoints/` 目录下。

#### Checkpoint 文件命名

```
{skill_name}_{step_id}_{timestamp}.json
```

- `skill_name`：当前执行的 Skill 名称，如 `DesignSkill`
- `step_id`：当前步骤编号，如 `phase2-step3`
- `timestamp`：ISO-8601 格式，如 `20260429T143000Z`

示例：`DesignSkill_phase2-step3_20260429T143000Z.json`

#### Checkpoint 文件内容

```json
{
  "timestamp": "2026-04-29T14:30:00Z",
  "skill": "DesignSkill",
  "step": "phase2-step3",
  "step_name": "生成模块架构图",
  "artifacts_snapshot": {
    "design/architecture.xml": {
      "hash": "sha256:abc123...",
      "path": ".devforge/checkpoints/snapshots/DesignSkill_phase2-step3_architecture.xml"
    },
    "docs/DECISION_LOG.md": {
      "hash": "sha256:def456...",
      "path": ".devforge/checkpoints/snapshots/DesignSkill_phase2-step3_DECISION_LOG.md"
    }
  },
  "context_summary": {
    "session_id": "sess-20260429-001",
    "prerequisites": ["phase2-step1", "phase2-step2"],
    "decisions_made": ["DEC-20260429-001", "DEC-20260429-002"],
    "user_inputs": [
      "系统需要支持 10万 QPS",
      "团队熟悉 Java 生态"
    ],
    "memory_state": {
      "current_focus": "微服务拆分策略",
      "pending_questions": [],
      "confirmed_constraints": ["使用 Spring Boot", "MySQL 主从"]
    }
  },
  "next_action": {
    "type": "generate",
    "target": "design/module-architecture.xml",
    "description": "基于已确认的架构决策生成模块级架构文档"
  }
}
```

#### 字段说明

| 字段 | 类型 | 说明 |
|------|------|------|
| `timestamp` | string | checkpoint 保存时间，ISO-8601 UTC |
| `skill` | string | 当前 Skill 名称 |
| `step` | string | 步骤编号 |
| `step_name` | string | 步骤的人类可读名称 |
| `artifacts_snapshot` | object | 该步骤执行前的所有产物快照，键为相对路径，值为包含 hash 和快照路径的对象 |
| `context_summary` | object | 当前会话上下文摘要 |
| `context_summary.session_id` | string | 会话唯一标识 |
| `context_summary.prerequisites` | array | 已执行的前置步骤列表 |
| `context_summary.decisions_made` | array | 当前会话中已记录的决策 ID 列表 |
| `context_summary.user_inputs` | array | 用户在当前会话中提供的关键输入 |
| `context_summary.memory_state` | object | Skill 内存状态，包含当前关注点、待处理问题、已确认约束等 |
| `next_action` | object | 该 checkpoint 对应的下一步计划 |

### 3.2 回滚流程

当用户输入 `[ROLLBACK {step_id}]` 时，Skill 必须按以下流程执行：

```
用户输入 [ROLLBACK phase2-step3]
    │
    ▼
┌─────────────────┐
│ 1. 解析命令      │
│    提取目标 step_id: phase2-step3
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 2. 查找 checkpoint│
│    匹配文件:     │
│    DesignSkill_phase2-step3_*.json
└────────┬────────┘
         │
         ▼
┌─────────────────┐     ┌─────────────────┐
│ 3. 验证 checkpoint│──►│ 3a. 未找到      │
│    检查完整性    │     │    报错并列出   │
└────────┬────────┘     │    可用回滚点   │
         │              └─────────────────┘
         ▼
┌─────────────────┐
│ 4. 恢复产物      │
│    将 artifacts_snapshot
│    中的文件复制回项目目录
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 5. 恢复上下文    │
│    加载 context_summary
│    到 Skill 内存
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 6. 重新执行      │
│    从 phase2-step3
│    开始执行后续步骤
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 7. 更新 STATE.md │
│    追加回滚记录  │
│    到 State History
└─────────────────┘
```

#### 回滚记录格式（STATE.md）

```markdown
## State History

### 2026-04-29 14:45:00 — ROLLBACK

- **触发命令**：`[ROLLBACK phase2-step3]`
- **回滚目标**：DesignSkill → phase2-step3（生成模块架构图）
- **回滚原因**：用户认为微服务拆分粒度过细，需要重新调整
- **恢复产物**：
  - `design/architecture.xml` (hash: sha256:abc123...)
  - `docs/DECISION_LOG.md` (hash: sha256:def456...)
- **已作废的后续产物**：
  - `design/module-architecture.xml`（phase2-step4 生成，已删除）
- **恢复后的状态**：phase2-step3 执行前
```

### 3.3 Checkpoint 清理策略

- **保留策略**：默认保留最近 10 个 checkpoint，更早的自动归档到 `.devforge/checkpoints/archive/`
- **会话结束**：Skill 正常完成后，该会话的所有 checkpoint 保留 7 天，之后自动清理
- **手动清理**：用户可通过命令 `[CLEANUP CHECKPOINTS]` 手动触发清理

---

## 4. 与 error-tracing 集成

### 4.1 `[EXPLAIN]` 触发 error-tracing 展开模式

当用户输入 `[EXPLAIN {TraceID}]` 时，系统按以下流程与 `error-tracing.md` 定义的机制集成：

```
用户输入 [EXPLAIN DEC-20260429-001-DESIGN-VAL-001-20260429143000]
    │
    ▼
┌─────────────────┐
│ 1. 解析 TraceID  │
│    提取:        │
│    - DecisionID: DEC-20260429-001
│    - ErrorCode: DESIGN-VAL-001
│    - Timestamp: 20260429143000
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 2. 查询 DECISION_LOG.md
│    获取关联决策的完整记录
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 3. 查询 STATE.md │
│    获取 ErrorLog 中
│    该 TraceID 的状态
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 4. 构建完整推理链 │
│    输出展开报告  │
└─────────────────┘
```

### 4.2 展开报告格式

```markdown
## [EXPLAIN] TraceID: DEC-20260429-001-DESIGN-VAL-001-20260429143000

### 关联决策

- **决策 ID**：[DEC-20260429-001]
- **决策标题**：采用微服务架构
- **决策时间**：2026-04-29 14:00:00
- **决策上下文**：订单服务需要独立扩展
- **决策内容**：将单体应用拆分为用户服务、订单服务、库存服务
- **ValidationStatus**：FAILED

### 关联错误

- **ErrorCode**：DESIGN-VAL-001
- **错误描述**：XML Schema 验证失败 — service 节点缺少必需属性 id
- **发生位置**：DesignSkill → Step-3 → ARCHITECTURE.md:42
- **当前状态**：OPEN（未修复）

### 完整推理链

```
[输入条件]
  用户要求：系统需要支持 10万 QPS
  团队约束：熟悉 Java 生态，运维团队 3 人
  
  [推理路径]
    Step 1: 高 QPS → 需要水平扩展 → 考虑微服务架构
    Step 2: 微服务架构 → 需要服务拆分 → 拆分为 3 个服务
    Step 3: 生成架构文档 → 使用 XML 描述服务拓扑
    Step 4: Schema 验证 → 发现 service 节点缺少 id 属性
    
  [结论]
    架构决策本身（微服务）与验证错误（XML 格式）是独立问题
    错误原因：Step-3 生成 XML 时遗漏了 id 属性
```

### 关联产物链

1. `docs/PRD.md:15` — 需求定义（10万 QPS）
2. `docs/DECISION_LOG.md:8` — 架构决策（采用微服务）
3. `design/ARCHITECTURE.md:42` — 错误发生位置（service 节点缺少 id）

### 修复建议

1. 检查 ARCHITECTURE.md 第 42 行的 `<service>` 节点，补充 `id="order-service"` 属性
2. 重新运行 Schema 验证命令
3. 如果 Schema 本身有误，更新 `service-schema.xsd`

### 可选操作

- 回复 `[ROLLBACK Step-2]` 回滚到决策记录步骤，重新确认架构方案
- 回复 `[EDIT design/ARCHITECTURE.md]` 手动修复 XML
- 回复 `[INJECT 运维团队只有 3 人，建议采用模块化单体]` 补充约束并重新决策
```

### 4.3 集成规则

1. `[EXPLAIN]` 命令必须能够解析 `error-tracing.md` 定义的所有 TraceID 格式
2. 如果 TraceID 不存在于 `STATE.md` 的 `ErrorLog` 中，Skill 必须提示用户检查 TraceID 是否正确
3. 展开报告必须包含 `error-tracing.md` 要求的全部 8 个字段（ErrorCode、发生位置、TraceID、关联决策、关联需求、上下文摘要、修复建议、人工介入方式）
4. 展开报告底部必须提供可操作的建议命令，引导用户下一步行动

---

## 5. 使用示例

### 5.1 场景一：架构设计走偏

**背景**：`DesignSkill` 在 phase2-step2（架构风格选择）中，AI 基于"高 QPS"需求推荐了微服务架构。但用户认为团队规模小（3 人），单体架构更合适。

**对话流程**：

```
AI: [GATE] phase2-step2 完成 — 架构风格选择
    基于需求 PRD.md:12（支持 10万 QPS），推荐采用微服务架构：
    - 用户服务 (user-service)
    - 订单服务 (order-service)
    - 库存服务 (inventory-service)
    
    请审批：[APPROVE] / [PAUSE] / [ROLLBACK] / [EXPLAIN] / [EDIT] / [SKIP] / [INJECT]

用户: [INJECT 运维团队只有 3 人，微服务运维成本太高，建议采用模块化单体架构]

AI: 收到上下文注入。重新评估：
    - 团队规模：3 人（新约束）
    - 运维成本：微服务 > 模块化单体
    - 调整建议：采用模块化单体架构，内部按领域划分模块
    
    更新后的架构方案：
    - 单体应用，内部包含 user-module、order-module、inventory-module
    - 模块间通过内部 API 通信
    - 未来团队扩展后可平滑迁移到微服务
    
    请审批：[APPROVE] / [PAUSE] / [ROLLBACK] / [EXPLAIN] / [EDIT] / [SKIP] / [INJECT]

用户: [APPROVE]

AI: 已批准。继续执行 phase2-step3...
```

**STATE.md 记录**：

```markdown
## State History

### 2026-04-29 15:00:00 — CONTEXT INJECTION

- **触发命令**：`[INJECT 运维团队只有 3 人...]`
- **注入内容**：运维团队只有 3 人，微服务运维成本太高，建议采用模块化单体架构
- **影响步骤**：DesignSkill → phase2-step2
- **结果**：架构风格从"微服务"调整为"模块化单体"
- **新增决策**：[DEC-20260429-003] 采用模块化单体架构（覆盖 DEC-20260429-001）
```

### 5.2 场景二：XML 验证失败回滚

**背景**：`DesignSkill` 在 phase2-step4（生成 module-architecture.xml）后，Schema 验证失败。用户希望回滚到 phase2-step3 重新生成。

**对话流程**：

```
AI: [ERROR] DESIGN-VAL-001: XML Schema 验证失败
    
    **发生位置**：DesignSkill → Step-4 → module-architecture.xml:28
    **TraceID**：`DEC-20260429-002-DESIGN-VAL-001-20260429150000`
    
    **修复建议**：
    1. 补充缺失的 id 属性
    2. 重新运行验证
    
    **人工介入**：
    - 回复 `[EXPLAIN DEC-20260429-002-DESIGN-VAL-001-20260429150000]` 展开完整推理链
    - 回复 `[ROLLBACK phase2-step3]` 回滚到模块架构设计前
    - 回复 `[EDIT design/module-architecture.xml]` 手动修复

用户: [ROLLBACK phase2-step3]

AI: 正在回滚到 phase2-step3...
    
    [1/4] 读取 checkpoint: DesignSkill_phase2-step3_20260429T145000Z.json
    [2/4] 恢复产物：
          - design/architecture.xml (已恢复)
          - docs/DECISION_LOG.md (已恢复)
    [3/4] 恢复上下文：模块架构设计前的状态
    [4/4] 更新 STATE.md
    
    回滚完成。当前状态：phase2-step3 执行前
    
    重新执行 phase2-step3（生成模块架构图）...
    
    [GATE] phase2-step3 完成 — 生成模块架构图
    ...
```

**Checkpoint 文件**（回滚前自动保存）：

```json
{
  "timestamp": "2026-04-29T14:50:00Z",
  "skill": "DesignSkill",
  "step": "phase2-step3",
  "step_name": "生成模块架构图",
  "artifacts_snapshot": {
    "design/architecture.xml": {
      "hash": "sha256:a1b2c3...",
      "path": ".devforge/checkpoints/snapshots/DesignSkill_phase2-step3_architecture.xml"
    },
    "docs/DECISION_LOG.md": {
      "hash": "sha256:d4e5f6...",
      "path": ".devforge/checkpoints/snapshots/DesignSkill_phase2-step3_DECISION_LOG.md"
    }
  },
  "context_summary": {
    "session_id": "sess-20260429-001",
    "prerequisites": ["phase2-step1", "phase2-step2"],
    "decisions_made": ["DEC-20260429-001", "DEC-20260429-002"],
    "user_inputs": ["系统需要支持 10万 QPS", "团队熟悉 Java 生态"],
    "memory_state": {
      "current_focus": "模块级架构设计",
      "pending_questions": [],
      "confirmed_constraints": ["使用 Spring Boot", "MySQL 主从", "模块化单体架构"]
    }
  },
  "next_action": {
    "type": "generate",
    "target": "design/module-architecture.xml",
    "description": "基于已确认的架构决策生成模块级架构文档"
  }
}
```

### 5.3 场景三：开发者直接编辑产物

**背景**：`CodeSkill` 生成了 `src/services/UserService.java`，开发者认为其中的错误处理逻辑不够完善，希望手动修改后再让 AI 继续生成测试代码。

**对话流程**：

```
AI: [GATE] phase3-step5 完成 — 生成 UserService.java
    文件路径：src/services/UserService.java
    主要功能：用户注册、登录、信息查询
    
    请审批：[APPROVE] / [PAUSE] / [ROLLBACK] / [EXPLAIN] / [EDIT] / [SKIP] / [INJECT]

用户: [EDIT src/services/UserService.java]

AI: 已暂停。请编辑文件：src/services/UserService.java
    
    当前文件摘要：
    - 第 1-20 行：包声明和导入
    - 第 21-45 行：UserService 类定义
    - 第 46-60 行：register 方法
    - 第 61-75 行：login 方法
    - 第 76-90 行：getUserInfo 方法
    
    编辑完成后，请回复 [DONE] 或 [CONTINUE]

[用户在外部编辑器中修改文件，补充了异常处理和日志记录]

用户: [DONE]

AI: 检测到文件变更：
    - 新增：全局异常捕获（第 25-35 行）
    - 修改：register 方法错误处理（第 52-58 行）
    - 新增：SLF4J 日志记录（第 15 行导入，各方法内添加）
    
    变更已记录到 STATE.md。
    
    继续执行 phase3-step6（生成 UserServiceTest.java）...
```

---

## 6. 命令响应规范

### 6.1 门控提示格式

每个含人类门控的步骤完成后，AI 必须输出以下格式的提示：

```markdown
[GATE] {skill_name} → {step_id} 完成 — {step_name}

{步骤产物的简要摘要}

请审批：[APPROVE] / [PAUSE] / [ROLLBACK {step_id}] / [EXPLAIN {TraceID}] / [EDIT {file_path}] / [SKIP] / [INJECT {context}]
```

### 6.2 命令响应时间要求

| 命令 | 最大响应时间 | 说明 |
|------|-------------|------|
| `[PAUSE]` | 即时 | 立即暂停，输出确认信息 |
| `[ROLLBACK]` | < 5 秒 | 读取 checkpoint、恢复产物、更新状态 |
| `[EXPLAIN]` | < 3 秒 | 查询日志、构建推理链、输出报告 |
| `[EDIT]` | 即时 | 输出文件摘要，等待用户编辑 |
| `[SKIP]` | 即时 | 标记跳过，进入下一步 |
| `[INJECT]` | 即时 | 追加上下文，重新评估当前步骤 |

### 6.3 无效命令处理

当用户输入无法识别的命令时，Skill 必须：

1. 提示命令无效
2. 列出当前可用的命令列表
3. 保持当前状态不变，等待有效输入

```markdown
无法识别命令：`[REDO]`

当前可用命令：
- [APPROVE] — 批准并继续
- [PAUSE] — 暂停当前 Skill
- [ROLLBACK phase2-step3] — 回滚到指定步骤
- [EXPLAIN DEC-...] — 展开解释指定 TraceID
- [EDIT design/architecture.xml] — 编辑指定文件
- [SKIP] — 跳过当前可选步骤
- [INJECT {context}] — 补充上下文

请重新输入命令。
```

---

## 7. 与 STATE.md 集成

### 7.1 InterventionLog 字段

`STATE.md` 中必须包含 `InterventionLog` 区块，记录当前会话中所有的人为干预操作。

```markdown
## InterventionLog

| 时间 | 命令 | 触发步骤 | 操作摘要 | 结果 |
|------|------|----------|----------|------|
| 2026-04-29 15:00:00 | [INJECT] | DesignSkill → phase2-step2 | 补充团队规模约束 | 架构风格调整为模块化单体 |
| 2026-04-29 15:30:00 | [ROLLBACK] | DesignSkill → phase2-step3 | XML 验证失败回滚 | 回滚成功，重新执行 phase2-step3 |
| 2026-04-29 16:00:00 | [EDIT] | CodeSkill → phase3-step5 | 手动编辑 UserService.java | 补充异常处理和日志记录 |
| 2026-04-29 16:15:00 | [SKIP] | DeploySkill → phase5-step2 | 跳过可视化配置 | 标记为 SKIPPED |
```

### 7.2 集成规则

1. 每次人为干预操作完成后，必须同步向 `STATE.md` 的 `InterventionLog` 追加一行记录
2. `InterventionLog` 与 `ErrorLog` 相互独立，但同一事件可能同时触发两条记录（如 `[ROLLBACK]` 因错误触发时，ErrorLog 记录错误状态，InterventionLog 记录回滚操作）
3. 会话结束时，`Orchestrator` 必须汇总 `InterventionLog`，生成干预统计报告

---

## Extended Commands (v1.2)

| Command | Behavior | Applicable Stage | Preconditions |
|---------|----------|------------------|---------------|
| `[FIX <issue_id>]` | Enter fix sub-mode: reads source file, generates diff, asks for apply/edit/ignore | design-review | DESIGN_REVIEW.md exists with matching issue_id |
| `[APPLY]` | Apply the generated diff and trigger re-validation | design-review fix sub-mode | diff file exists and is valid |
| `[FORCE_APPROVE]` | Skip blocking validation failures and proceed to design-review | architecture-validation | All failures are non-blocking (warning level) |
| `[SKIP_REVIEW]` | Skip design-review and proceed directly to scaffolding | architecture-validation | Validation has passed |
| `[DESIGN_REVIEW]` | Trigger design-review after validation passes | architecture-validation | Validation has passed |
| `[VALIDATE]` | Re-run architecture-validation after iteration implementation | iteration-planning | Iteration contains breaking changes |
| `[TEST]` | Trigger test-execution skill | Any post-scaffolding stage | Tests exist in PROJECT_SCAFFOLD/tests/ |

---

## 8. 附录

### 8.1 命令速查表

| 如果你需要... | 使用命令 | 示例 |
|---------------|----------|------|
| 批准并继续 | `[APPROVE]` | `[APPROVE]` |
| 暂停审查 | `[PAUSE]` | `[PAUSE]` |
| 回滚到某一步 | `[ROLLBACK {step_id}]` | `[ROLLBACK phase2-step3]` |
| 要求解释决策/错误 | `[EXPLAIN {TraceID}]` | `[EXPLAIN DEC-001-DESIGN-VAL-001-20260429143000]` |
| 手动编辑文件 | `[EDIT {file_path}]` | `[EDIT design/architecture.xml]` |
| 跳过可选步骤 | `[SKIP]` | `[SKIP]` |
| 补充上下文 | `[INJECT {context}]` | `[INJECT 用户偏好使用 PostgreSQL]` |
| 恢复暂停的 Skill | `[RESUME]` | `[RESUME]` |
| 通知编辑完成 | `[DONE]` / `[CONTINUE]` | `[DONE]` |

### 8.2 与现有工具的关系

| 工具 | 关系 | 说明 |
|------|------|------|
| `error-tracing.md` | 强依赖 | `[EXPLAIN]` 命令触发 error-tracing 展开模式，共享 TraceID 和决策日志 |
| `artifact-manager.md` | 协作 | `[EDIT]` 命令使用 Artifact Manager 的冲突检测和版本标记机制 |
| `STATE.md` | 强依赖 | 所有干预操作必须同步到 `InterventionLog` 和 `State History` |
| `DECISION_LOG.md` | 协作 | `[ROLLBACK]` 和 `[EXPLAIN]` 需要查询决策日志 |

### 8.3 实现 Checklist

- [ ] Skill 门控提示包含所有 7 个命令选项
- [ ] `[PAUSE]` 暂停后上下文完整保留
- [ ] `[ROLLBACK]` 能正确读取 checkpoint 并恢复产物
- [ ] `[EXPLAIN]` 能正确解析 TraceID 并输出展开报告
- [ ] `[EDIT]` 支持外部编辑后重新加载文件
- [ ] `[SKIP]` 能正确识别可选步骤并拒绝跳过必需步骤
- [ ] `[INJECT]` 注入的上下文对后续步骤生效
- [ ] 每个步骤执行前自动保存 checkpoint
- [ ] `STATE.md` 包含 `InterventionLog` 区块
- [ ] 无效命令提示可用命令列表

---

> **维护者**：DevForge 核心团队  
> **问题反馈**：请在项目 Issue 区提交  
> **修订历史**：
> - v1.0 (2026-04-29): 初始版本，定义 6 个新增命令 + checkpoint 机制 + error-tracing 集成
