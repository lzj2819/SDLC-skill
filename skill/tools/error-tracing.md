# Error Tracing 工具规范

**版本**：v1.0  
**适用范围**：所有 Skill 的报错输出  
**最后更新**：2026/04/29

---

## 1. 目的

本文档定义 DevForge SDLC Skill Chain 中所有 Skill 产生错误时必须遵循的统一格式规范。通过标准化的错误追踪机制，使每个报错可追溯到具体决策、需求和代码位置，降低排查成本，支持自动化日志解析与状态回滚。

---

## 2. 报错格式规范

所有 Skill 报错输出必须包含以下 8 个字段，缺一不可。

| 字段 | 说明 | 示例 |
|------|------|------|
| ErrorCode | 唯一错误编码 | `DESIGN-VAL-001` |
| 发生位置 | Skill 名称 → 步骤编号 → 产物文件:行号 | `DesignSkill → Step-3 → ARCHITECTURE.md:42` |
| TraceID | 全局唯一追踪标识 | `DEC-20260429-001-DESIGN-VAL-001-20260429143000` |
| 关联决策 | 触发该错误的决策记录 | `[DEC-20260429-001] 采用微服务架构` |
| 关联需求 | 对应的用户故事 | `US-003 (用户可实时查看订单状态)` |
| 上下文摘要 | 输入条件、推理路径、相关产物链 | 见模板 |
| 修复建议 | 可执行的修复步骤 | 编号列表 |
| 人工介入方式 | 用户可输入的交互指令 | `[EXPLAIN {TraceID}]` / `[ROLLBACK {步骤编号}]` |

---

## 3. 报错模板

```markdown
## [ERROR] {ErrorCode}: {一句话描述}

**发生位置**：{Skill名称} → {步骤编号} → {产物文件:行号}

**TraceID**：`{DecisionID}-{ErrorCode}-{Timestamp}`
- 关联决策：[{DecisionID}] {DecisionTitle}
- 关联需求：{US-ID} ({UserStoryTitle})

**上下文摘要**：
- 输入条件：{导致错误的输入/状态}
- 推理路径：{AI 基于什么前提得出该结论}
- 相关产物：{PRD.md:XX} → {ARCHITECTURE.md:YY} → {当前文件:ZZ}

**修复建议**：
1. {具体步骤 1}
2. {具体步骤 2}

**人工介入**：
- 回复 `[EXPLAIN {TraceID}]` 展开完整推理链
- 回复 `[ROLLBACK {步骤编号}]` 回滚到上一步
```

---

## 4. ErrorCode 命名规范

### 4.1 格式

```
{SkillPrefix}-{Category}-{Number}
```

- `SkillPrefix`：Skill 的 3~5 位大写字母缩写
- `Category`：2~3 位大写字母，表示错误类别
- `Number`：3 位数字，从 001 开始顺序递增

### 4.2 Skill Prefix 映射表

| Skill 名称 | Prefix | 说明 |
|-----------|--------|------|
| RequirementSkill | REQ | 需求分析 Skill |
| DesignSkill | DESIGN | 架构设计 Skill |
| CodeSkill | CODE | 代码生成 Skill |
| ReviewSkill | REV | 代码审查 Skill |
| TestSkill | TEST | 测试生成 Skill |
| DeploySkill | DEPLOY | 部署发布 Skill |
| StateManager | STATE | 状态管理 Skill |
| DecisionLog | DEC | 决策日志 Skill |
| ErrorTracer | TRACE | 错误追踪 Skill（本工具） |
| Orchestrator | ORCH | 编排调度 Skill |

### 4.3 Category 映射表

| Category | 代码 | 说明 |
|----------|------|------|
| Validation | VAL | 验证失败（Schema、规则、约束） |
| Dependency | DEP | 依赖缺失或冲突 |
| Timeout | TMO | 执行超时 |
| Permission | PERM | 权限不足 |
| Resource | RES | 资源不足（内存、磁盘、API 配额） |
| Logic | LOG | 业务逻辑错误 |
| Syntax | SYN | 语法错误 |
| Runtime | RUN | 运行时异常 |
| State | STA | 状态不一致 |
| Network | NET | 网络通信错误 |
| Config | CFG | 配置错误 |
| Unknown | UNK | 未知错误 |

---

## 5. 与 STATE.md 集成

### 5.1 ErrorLog 字段格式

`STATE.md` 中必须包含 `ErrorLog` 区块，记录当前会话中所有未关闭的错误。

```markdown
## ErrorLog

| TraceID | ErrorCode | 状态 | 发生时间 | 关闭时间 | 关联决策 | 关联需求 |
|---------|-----------|------|----------|----------|----------|----------|
| DEC-001-DESIGN-VAL-001-20260429143000 | DESIGN-VAL-001 | OPEN | 2026-04-29 14:30:00 | - | DEC-20260429-001 | US-003 |
| DEC-002-CODE-SYN-001-20260429144500 | CODE-SYN-001 | CLOSED | 2026-04-29 14:45:00 | 2026-04-29 15:00:00 | DEC-20260429-002 | US-005 |
```

### 5.2 状态说明

- `OPEN`：错误已产生，尚未修复
- `PENDING`：等待人工介入或外部依赖
- `CLOSED`：已修复并验证通过
- `IGNORED`：经人工确认可忽略（需记录理由）

### 5.3 集成规则

1. Skill 产生错误时，必须同步向 `STATE.md` 的 `ErrorLog` 追加一行记录
2. 错误状态变更时（修复完成或人工关闭），必须更新 `ErrorLog` 中的 `状态` 和 `关闭时间` 字段
3. 每次会话启动时，`Orchestrator` 必须检查 `ErrorLog` 中是否存在 `OPEN` 状态的错误，并提示用户优先处理

---

## 6. 与 DECISION_LOG.md 集成

### 6.1 ValidationStatus 字段

每条决策记录在 `DECISION_LOG.md` 中必须包含 `ValidationStatus` 字段，用于追踪该决策引发的验证错误。

```markdown
## [DEC-20260429-001] 采用微服务架构

**上下文**：订单服务需要独立扩展  
**决策**：将单体应用拆分为用户服务、订单服务、库存服务  
**影响范围**：ARCHITECTURE.md, docker-compose.yml, CI/CD 流程  
**ValidationStatus**：FAILED  
**关联错误**：
- DESIGN-VAL-001 (TraceID: DEC-001-DESIGN-VAL-001-20260429143000)
```

### 6.2 ValidationStatus 取值

| 状态 | 说明 |
|------|------|
| PENDING | 决策已记录，尚未执行验证 |
| PASSED | 验证通过，无关联错误 |
| FAILED | 验证失败，存在关联错误 |
| OVERRIDDEN | 决策被后续决策覆盖 |

### 6.3 集成规则

1. 当错误产生且关联到某条决策时，必须更新 `DECISION_LOG.md` 中对应决策的 `ValidationStatus` 为 `FAILED`
2. 必须在决策记录的 `关联错误` 列表中追加该错误的 `ErrorCode` 和 `TraceID`
3. 错误修复后，如果该决策下所有关联错误均已 `CLOSED`，则 `ValidationStatus` 可更新为 `PASSED`

---

## 7. 使用示例

### 7.1 场景：XML Schema 验证失败

**背景**：`DesignSkill` 在生成 `ARCHITECTURE.md` 后，使用 XML Schema 对产物进行验证，发现 `<service>` 节点缺少必需的 `id` 属性。

**报错输出**：

```markdown
## [ERROR] DESIGN-VAL-001: XML Schema 验证失败 — service 节点缺少必需属性 id

**发生位置**：DesignSkill → Step-3 (架构文档生成) → ARCHITECTURE.md:42

**TraceID**：`DEC-20260429-001-DESIGN-VAL-001-20260429143000`
- 关联决策：[DEC-20260429-001] 采用微服务架构
- 关联需求：US-003 (用户可实时查看订单状态)

**上下文摘要**：
- 输入条件：AI 基于决策 DEC-20260429-001 生成微服务架构文档，Schema 要求每个 `<service>` 节点必须包含唯一 `id` 属性
- 推理路径：决策要求拆分 3 个服务 → 生成 XML 结构 → 第 2 个 `<service>` 节点遗漏 `id` 属性 → Schema 验证触发
- 相关产物：PRD.md:15 (需求定义) → DECISION_LOG.md:8 (架构决策) → ARCHITECTURE.md:42 (当前错误位置)

**修复建议**：
1. 检查 ARCHITECTURE.md 第 42 行的 `<service>` 节点，补充 `id="order-service"` 属性
2. 重新运行 Schema 验证命令：`validate-xml ARCHITECTURE.md --schema=service-schema.xsd`
3. 若 Schema 本身有误，更新 `service-schema.xsd` 并同步修改验证规则

**人工介入**：
- 回复 `[EXPLAIN DEC-20260429-001-DESIGN-VAL-001-20260429143000]` 展开完整推理链
- 回复 `[ROLLBACK Step-2]` 回滚到决策记录步骤，重新确认架构拆分方案
```

### 7.2 STATE.md 同步记录

```markdown
## ErrorLog

| TraceID | ErrorCode | 状态 | 发生时间 | 关闭时间 | 关联决策 | 关联需求 |
|---------|-----------|------|----------|----------|----------|----------|
| DEC-20260429-001-DESIGN-VAL-001-20260429143000 | DESIGN-VAL-001 | OPEN | 2026-04-29 14:30:00 | - | DEC-20260429-001 | US-003 |
```

### 7.3 DECISION_LOG.md 同步记录

```markdown
## [DEC-20260429-001] 采用微服务架构

**上下文**：订单服务需要独立扩展  
**决策**：将单体应用拆分为用户服务、订单服务、库存服务  
**影响范围**：ARCHITECTURE.md, docker-compose.yml, CI/CD 流程  
**ValidationStatus**：FAILED  
**关联错误**：
- DESIGN-VAL-001 (TraceID: DEC-20260429-001-DESIGN-VAL-001-20260429143000)
```

---

## 8. 自动化解析规则

为支持工具链自动解析错误日志，所有报错输出必须满足以下约束：

1. **TraceID 格式**：`{DecisionID}-{ErrorCode}-{YYYYMMDDhhmmss}`，使用反引号包裹
2. **时间戳统一**：使用北京时间（UTC+8），格式 `YYYY-MM-DD HH:MM:SS`
3. **文件位置格式**：`{文件名}:{行号}`，行号为纯数字
4. **决策引用格式**：`[{DecisionID}] {DecisionTitle}`，DecisionID 必须存在于 `DECISION_LOG.md`
5. **需求引用格式**：`{US-ID} ({UserStoryTitle})`，US-ID 必须存在于 `PRD.md`
6. **人工指令格式**：方括号包裹的大写指令，参数使用空格分隔

---

## 9. 附录：快速参考卡

### 9.1 错误产生 checklist

- [ ] ErrorCode 符合 `{Prefix}-{Category}-{Number}` 格式
- [ ] 发生位置精确到文件行号
- [ ] TraceID 全局唯一且包含时间戳
- [ ] 关联决策存在于 DECISION_LOG.md
- [ ] 关联需求存在于 PRD.md
- [ ] 上下文摘要包含输入、推理、产物链
- [ ] 修复建议至少 1 条，步骤可执行
- [ ] 人工介入指令格式正确
- [ ] STATE.md ErrorLog 已同步追加
- [ ] DECISION_LOG.md ValidationStatus 已更新

### 9.2 常见错误速查

| 场景 | ErrorCode 示例 |
|------|---------------|
| PRD 需求冲突 | REQ-VAL-001 |
| 架构图生成超时 | DESIGN-TMO-001 |
| 代码语法错误 | CODE-SYN-001 |
| 单元测试失败 | TEST-LOG-001 |
| 部署配置缺失 | DEPLOY-CFG-001 |
| 状态文件损坏 | STATE-RUN-001 |
| 决策日志不一致 | DEC-STA-001 |
