# Artifact Manager 工具规范

> **版本**: v1.0  
> **适用范围**: 所有生成产物的 Skill  
> **生效日期**: 2026-04-29

---

## 1. 核心原则：CRUD-Append 模式

所有产物更新必须遵循以下四步流程，确保幂等性与手动修改的共存：

```
Read → Compute Diff → Update Delta → Preserve Manual
```

| 步骤 | 说明 |
|------|------|
| **Read** | 读取产物当前内容，解析现有结构与手动标记区域 |
| **Compute Diff** | 对比目标状态与当前状态，计算最小变更集（Delta） |
| **Update Delta** | 仅应用 Delta，不覆盖未变更部分 |
| **Preserve Manual** | 保留所有手动修改区域，遇到冲突时按规则处理 |

**关键约束**:
- 禁止全量覆盖已有产物（除非显式 `--force`）
- 手动修改区域具有最高优先级
- 每次更新必须注入版本元数据

---

## 2. 产物分类与更新策略

### 2.1 更新策略总览

| 产物类型 | 更新模式 | 策略说明 |
|----------|----------|----------|
| `PRD.md` | Append-only | 新增 User Story 追加到末尾，已有 Story 不修改 |
| `DECISION_LOG.md` | Append-only | 新决策追加到末尾，已有决策标记 `superseded` 而非删除 |
| `STATE.md` | Selective update | `Current State` 章节覆盖更新，历史状态追加到 `State History` |
| `architecture.xml` | Merge-update | 新增模块插入到对应层级，已有模块仅更新变更字段 |
| `module-architecture.xml` | Merge-update | 保留组件内的手动注释，仅更新结构变更 |
| `component-spec.xml` | Conservative update | 已有 Function 不覆盖，只新增缺失的 Function |
| `INTERFACE_CONTRACT.md` | Merge-update | 新增接口追加到末尾，已有接口更新版本号 |
| `PROJECT_SCAFFOLD/` | Overlay | 新增文件直接写入，已有非 `auto-generated` 标记文件跳过 |

### 2.2 各模式详细说明

#### Append-only（追加模式）

仅允许在文件末尾追加新内容，已有内容不可修改。

**适用产物**: `PRD.md`, `DECISION_LOG.md`

**规则**:
1. 新条目追加到文件末尾
2. 条目之间保留空行分隔
3. 每个条目必须包含唯一标识（如 Story ID、Decision ID）
4. 对于 `DECISION_LOG.md`，废弃决策追加 `Status: superseded by [新决策ID]` 而非删除原内容

**示例 — DECISION_LOG.md 更新**:

```markdown
<!-- GENERATED-BY: design-skill -->
<!-- GENERATED-AT: 2026-04-28T10:00:00Z -->
<!-- LAST-MODIFIED: 2026-04-29T14:30:00Z -->
<!-- UPDATE-RULE: append-only -->

## DECISION-001: 使用 React 作为前端框架

- **Status**: accepted
- **Date**: 2026-04-28
- **Context**: 团队熟悉 React 生态
- **Decision**: 采用 React 18 + TypeScript

## DECISION-002: 使用 PostgreSQL 作为主数据库

- **Status**: accepted
- **Date**: 2026-04-29
- **Context**: 需要关系型数据库支持复杂查询
- **Decision**: 采用 PostgreSQL 15

## DECISION-003: 废弃微服务架构，改用单体架构

- **Status**: superseded by DECISION-005
- **Date**: 2026-04-29
- **Context**: 团队规模小，微服务运维成本高
- **Decision**: 采用单体架构（后续被 DECISION-005 替代）

## DECISION-005: 采用模块化单体架构

- **Status**: accepted
- **Date**: 2026-04-30
- **Context**: 单体架构基础上需要模块边界清晰
- **Decision**: 采用模块化单体，内部按领域划分模块
```

#### Selective update（选择性更新）

特定章节覆盖更新，其余章节追加。

**适用产物**: `STATE.md`

**规则**:
1. `Current State` 章节：完全覆盖，反映最新状态
2. `State History` 章节：将上一版本的 `Current State` 追加为历史记录
3. 手动注释区域保留

**示例 — STATE.md 结构**:

```markdown
<!-- GENERATED-BY: state-skill -->
<!-- GENERATED-AT: 2026-04-29T14:30:00Z -->
<!-- LAST-MODIFIED: 2026-04-29T14:30:00Z -->
<!-- UPDATE-RULE: selective-update -->

# Current State

<!-- MANUAL: 以下区域在每次更新时会被覆盖，如需保留注释请放在 MANUAL 标记内 -->

## 迭代进度
- Sprint: 3
- 完成 Story: 12/15
- 当前阶段: 开发中

## 风险项
- 无

---

# State History

## 2026-04-28
- Sprint: 2
- 完成 Story: 8/12
- 当前阶段: 测试中

## 2026-04-21
- Sprint: 1
- 完成 Story: 5/10
- 当前阶段: 需求分析
```

#### Merge-update（合并更新）

按节点/条目合并，新增插入，已有更新变更字段。

**适用产物**: `architecture.xml`, `module-architecture.xml`, `INTERFACE_CONTRACT.md`

**规则**:
1. 以 ID 为键进行匹配
2. 新增节点：插入到对应父节点下
3. 已有节点：仅更新变更的属性/字段
4. 不存在的字段保留原值
5. 手动注释区域保留

**示例 — architecture.xml 合并逻辑**:

```xml
<!-- GENERATED-BY: architecture-skill -->
<!-- GENERATED-AT: 2026-04-29T14:30:00Z -->
<!-- LAST-MODIFIED: 2026-04-29T14:30:00Z -->
<!-- UPDATE-RULE: merge-update -->

<architecture version="1.2">
  <module id="user-service" name="用户服务">
    <!-- MANUAL: 该模块由用户团队维护 -->
    <component id="auth" type="service">
      <function id="login">用户登录</function>
      <function id="register">用户注册</function>
      <!-- MANUAL: 以下功能待实现 -->
      <function id="oauth">OAuth 登录</function>
    </component>
  </module>
  
  <!-- 新增模块：由本次迭代插入 -->
  <module id="order-service" name="订单服务">
    <component id="order-manager" type="service">
      <function id="create-order">创建订单</function>
      <function id="cancel-order">取消订单</function>
    </component>
  </module>
</architecture>
```

#### Conservative update（保守更新）

已有内容绝不覆盖，仅补充缺失内容。

**适用产物**: `component-spec.xml`

**规则**:
1. 以 Function ID 为键检查存在性
2. 已存在的 Function：完全跳过，不修改任何字段
3. 不存在的 Function：追加到对应组件下
4. 适用于开发者可能手动补充了详细实现的场景

**示例 — component-spec.xml 保守更新**:

```xml
<!-- GENERATED-BY: component-skill -->
<!-- GENERATED-AT: 2026-04-29T14:30:00Z -->
<!-- LAST-MODIFIED: 2026-04-29T14:30:00Z -->
<!-- UPDATE-RULE: conservative-update -->

<component-spec>
  <component id="payment-gateway">
    <!-- 已有 Function：由开发者手动补充了实现细节，Skill 不可覆盖 -->
    <function id="process-payment">
      <name>处理支付</name>
      <description>调用第三方支付接口</description>
      <!-- MANUAL: 实现细节由开发团队维护 -->
      <implementation>
        <step>1. 校验订单状态</step>
        <step>2. 调用支付宝接口</step>
        <step>3. 更新订单状态</step>
      </implementation>
    </function>
    
    <!-- 新增 Function：由本次 Skill 调用补充 -->
    <function id="refund">
      <name>退款</name>
      <description>处理退款请求</description>
    </function>
  </component>
</component-spec>
```

#### Overlay（覆盖模式）

文件系统级别的增量覆盖。

**适用产物**: `PROJECT_SCAFFOLD/`

**规则**:
1. 新增文件：直接写入目标目录
2. 已有文件：检查头部标记
   - 包含 `<!-- auto-generated -->` 或 `// auto-generated`：允许覆盖
   - 无标记或包含 `<!-- MANUAL -->` / `// MANUAL`：跳过，记录冲突
3. 目录结构：自动创建缺失的目录

**文件标记示例**:

```javascript
// auto-generated by scaffold-skill
// GENERATED-AT: 2026-04-29T14:30:00Z
// UPDATE-RULE: overlay

function generatedHelper() {
  // ...
}
```

---

## 3. 冲突检测规则

### 3.1 手动修改标记

以下标记用于标识手动修改区域，Skill 更新时必须识别并保护：

| 标记格式 | 适用文件类型 | 说明 |
|----------|--------------|------|
| `<!-- MANUAL: ... -->` | XML, HTML, Markdown | XML/HTML 风格注释 |
| `// MANUAL: ...` | JavaScript, TypeScript, Java, Go, C/C++ 等 | 单行注释 |
| `/* MANUAL: ... */` | CSS, C/C++, Java 等 | 多行注释 |
| `# MANUAL: ...` | Python, Shell, YAML, Ruby 等 | 井号注释 |
| `<!-- MANUAL -->` / `// MANUAL` | 所有支持注释的文件 | 标记整个区域为手动内容 |

### 3.2 冲突判定

当满足以下任一条件时，判定为冲突：

1. **字段覆盖冲突**: Skill 需要更新某字段，但该字段所在区域包含手动标记
2. **结构删除冲突**: Skill 需要删除某节点/条目，但该节点包含手动标记
3. **文件覆盖冲突**: Overlay 模式下，目标文件无 `auto-generated` 标记且 Skill 需要覆盖
4. **并发修改冲突**: `LAST-MODIFIED` 时间戳与 Skill 读取时不一致（可选检测）

### 3.3 冲突处理流程

```
检测到冲突
    │
    ▼
┌─────────────────┐
│ 1. 暂停更新      │
│    记录冲突位置   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 2. 生成冲突报告  │
│    包含：        │
│    - 冲突类型    │
│    - 涉及文件    │
│    - 手动标记位置│
│    - 建议操作    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐     ┌─────────────────┐
│ 3. 默认策略      │     │ 4. 人工介入      │
│    --dry-run:    │     │    无 --force   │
│    仅报告不修改  │◄────│    时要求确认    │
└────────┬────────┘     └─────────────────┘
         │
         ▼
┌─────────────────┐
│ 5. 强制更新      │
│    --force:      │
│    覆盖手动标记  │
│    ⚠️ 慎用      │
└─────────────────┘
```

**冲突报告格式**:

```markdown
## Conflict Report

### 冲突 1: 字段覆盖冲突
- **文件**: `component-spec.xml`
- **位置**: `/component[@id="payment-gateway"]/function[@id="process-payment"]/implementation`
- **手动标记**: `<!-- MANUAL: 实现细节由开发团队维护 -->`
- **Skill 意图**: 更新 implementation 节点
- **建议**: 手动合并或添加 --force 覆盖

### 冲突 2: 文件覆盖冲突
- **文件**: `src/utils/helper.js`
- **手动标记**: `// MANUAL: 自定义工具函数`
- **Skill 意图**: 重新生成 helper.js
- **建议**: 检查文件是否需要保留，或使用 --force 覆盖
```

---

## 4. 产物版本标记

### 4.1 头部元数据规范

所有产物文件头部必须注入以下元数据（XML 风格注释，兼容 Markdown）：

```xml
<!-- GENERATED-BY: {skill-name} -->
<!-- GENERATED-AT: {ISO-8601 时间戳} -->
<!-- LAST-MODIFIED: {ISO-8601 时间戳} -->
<!-- UPDATE-RULE: {append-only | selective-update | merge-update | conservative-update | overlay} -->
```

### 4.2 字段说明

| 字段 | 格式 | 说明 |
|------|------|------|
| `GENERATED-BY` | 小写连字符，如 `design-skill` | 首次生成该产物的 Skill 名称 |
| `GENERATED-AT` | ISO-8601 UTC，如 `2026-04-29T14:30:00Z` | 首次生成时间 |
| `LAST-MODIFIED` | ISO-8601 UTC | 最近一次更新时间 |
| `UPDATE-RULE` | 策略枚举值 | 该产物适用的更新策略 |

### 4.3 元数据更新规则

- `GENERATED-BY` 和 `GENERATED-AT`：**永不修改**，保留首次生成信息
- `LAST-MODIFIED`：**每次更新时更新**为当前时间
- `UPDATE-RULE`：**仅在策略变更时更新**，需人工确认

---

## 5. 产物统一目录结构

```
project-root/
├── docs/
│   ├── PRD.md                    # Append-only
│   ├── DECISION_LOG.md           # Append-only
│   ├── STATE.md                  # Selective-update
│   └── INTERFACE_CONTRACT.md     # Merge-update
├── design/
│   ├── architecture.xml          # Merge-update
│   ├── module-architecture.xml   # Merge-update
│   └── component-spec.xml        # Conservative-update
└── scaffold/                     # Overlay
    ├── src/
    ├── tests/
    └── config/
```

**目录规则**:
1. 产物按类型放入对应目录
2. Skill 生成产物时必须使用相对路径（相对于项目根目录）
3. 目录不存在时自动创建
4. 产物文件命名必须全大写（如 `PRD.md`）或全小写连字符（如 `component-spec.xml`）

---

## 6. 与 xml-sync.py 集成

### 6.1 工具定位

`xml-sync.py` 是 Artifact Manager 的底层执行工具，负责实际的 XML 合并操作。

### 6.2 参数规范

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--base` | 路径 | 是 | 现有产物路径（当前状态） |
| `--incoming` | 路径 | 是 | 新生成内容路径（目标状态） |
| `--output` | 路径 | 否 | 输出路径，默认覆盖 `--base` |
| `--rule` | 枚举 | 是 | 更新规则：`merge-update` / `conservative-update` |
| `--dry-run` | 标志 | 否 | 仅生成冲突报告，不修改文件 |
| `--force` | 标志 | 否 | 强制覆盖手动标记区域 |

### 6.3 调用示例

```bash
# 标准合并更新
python xml-sync.py \
  --base design/architecture.xml \
  --incoming /tmp/new-architecture.xml \
  --rule merge-update

# 仅检测冲突，不修改文件
python xml-sync.py \
  --base design/component-spec.xml \
  --incoming /tmp/new-component-spec.xml \
  --rule conservative-update \
  --dry-run

# 强制覆盖（慎用）
python xml-sync.py \
  --base design/module-architecture.xml \
  --incoming /tmp/new-module-architecture.xml \
  --rule merge-update \
  --force
```

### 6.4 返回值

| 退出码 | 含义 |
|--------|------|
| `0` | 更新成功，无冲突 |
| `1` | 存在冲突，已生成冲突报告（仅 `--dry-run`） |
| `2` | 存在冲突，更新已中止 |
| `3` | 参数错误 |
| `4` | 文件读写错误 |

---

## 7. 使用示例

### 7.1 示例一：迭代新增模块

**场景**: 第 3 轮迭代需要为系统新增 `inventory-service`（库存服务）。

**步骤**:

1. **Read**: 读取现有 `architecture.xml`

```xml
<architecture version="1.1">
  <module id="user-service" name="用户服务">
    <component id="auth" type="service"/>
  </module>
</architecture>
```

2. **Compute Diff**: Skill 生成目标状态

```xml
<architecture version="1.2">
  <module id="user-service" name="用户服务">
    <component id="auth" type="service"/>
  </module>
  <module id="inventory-service" name="库存服务">
    <component id="stock-manager" type="service"/>
  </module>
</architecture>
```

3. **Update Delta**: 应用 Merge-update 规则
   - `user-service` 模块：无变更，跳过
   - `inventory-service` 模块：新增，插入到 `architecture` 根节点下
   - 更新 `version="1.2"`
   - 更新 `LAST-MODIFIED`

4. **Preserve Manual**: 检查无手动标记冲突，完成更新

**结果**:

```xml
<!-- GENERATED-BY: architecture-skill -->
<!-- GENERATED-AT: 2026-04-21T10:00:00Z -->
<!-- LAST-MODIFIED: 2026-04-29T14:30:00Z -->
<!-- UPDATE-RULE: merge-update -->

<architecture version="1.2">
  <module id="user-service" name="用户服务">
    <component id="auth" type="service"/>
  </module>
  <module id="inventory-service" name="库存服务">
    <component id="stock-manager" type="service"/>
  </module>
</architecture>
```

### 7.2 示例二：组件接口变更

**场景**: `payment-gateway` 组件新增 `refund` 功能，同时已有 `process-payment` 被开发者手动补充了实现细节。

**现有 `component-spec.xml`**:

```xml
<!-- GENERATED-BY: component-skill -->
<!-- GENERATED-AT: 2026-04-21T10:00:00Z -->
<!-- LAST-MODIFIED: 2026-04-25T16:00:00Z -->
<!-- UPDATE-RULE: conservative-update -->

<component-spec>
  <component id="payment-gateway">
    <function id="process-payment">
      <name>处理支付</name>
      <description>调用第三方支付接口</description>
      <!-- MANUAL: 实现细节由开发团队维护 -->
      <implementation>
        <step>1. 校验订单状态</step>
        <step>2. 调用支付宝接口</step>
        <step>3. 更新订单状态</step>
      </implementation>
    </function>
  </component>
</component-spec>
```

**Skill 生成目标状态**:

```xml
<component-spec>
  <component id="payment-gateway">
    <function id="process-payment">
      <name>处理支付</name>
      <description>调用第三方支付接口</description>
    </function>
    <function id="refund">
      <name>退款</name>
      <description>处理退款请求</description>
    </function>
  </component>
</component-spec>
```

**Conservative update 处理**:

1. `process-payment` 已存在 → **跳过**，保留开发者手动补充的 `implementation`
2. `refund` 不存在 → **追加**
3. 更新 `LAST-MODIFIED`

**结果**:

```xml
<!-- GENERATED-BY: component-skill -->
<!-- GENERATED-AT: 2026-04-21T10:00:00Z -->
<!-- LAST-MODIFIED: 2026-04-29T14:30:00Z -->
<!-- UPDATE-RULE: conservative-update -->

<component-spec>
  <component id="payment-gateway">
    <function id="process-payment">
      <name>处理支付</name>
      <description>调用第三方支付接口</description>
      <!-- MANUAL: 实现细节由开发团队维护 -->
      <implementation>
        <step>1. 校验订单状态</step>
        <step>2. 调用支付宝接口</step>
        <step>3. 更新订单状态</step>
      </implementation>
    </function>
    <function id="refund">
      <name>退款</name>
      <description>处理退款请求</description>
    </function>
  </component>
</component-spec>
```

### 7.3 示例三：冲突处理

**场景**: Skill 需要更新 `module-architecture.xml` 中 `user-service` 的结构，但该模块包含手动注释。

**现有文件**:

```xml
<module id="user-service" name="用户服务">
  <!-- MANUAL: 该模块由用户团队维护，请勿自动修改结构 -->
  <component id="auth" type="service"/>
</module>
```

**Skill 意图**: 将 `auth` 组件重命名为 `authentication`

**标准模式（无 `--force`）**:

```bash
python xml-sync.py \
  --base design/module-architecture.xml \
  --incoming /tmp/new-module-architecture.xml \
  --rule merge-update
```

**输出**:

```
Conflict detected. Update aborted.

Conflict Report:
- File: design/module-architecture.xml
- Location: /module[@id="user-service"]
- Manual marker: <!-- MANUAL: 该模块由用户团队维护... -->
- Intent: Rename component "auth" to "authentication"
- Suggestion: Manual merge or use --force to override

Exit code: 2
```

**强制模式（`--force`）**:

```bash
python xml-sync.py \
  --base design/module-architecture.xml \
  --incoming /tmp/new-module-architecture.xml \
  --rule merge-update \
  --force
```

**输出**:

```
Warning: Overriding manual marker at /module[@id="user-service"]
Update completed.

Exit code: 0
```

---

## 8. 附录

### 8.1 更新策略速查表

| 如果你需要... | 使用模式 | 典型产物 |
|---------------|----------|----------|
| 追加新条目，不碰已有内容 | Append-only | PRD.md, DECISION_LOG.md |
| 更新当前状态，保留历史 | Selective update | STATE.md |
| 按 ID 合并，更新变更字段 | Merge-update | architecture.xml, module-architecture.xml, INTERFACE_CONTRACT.md |
| 已有内容绝不覆盖 | Conservative update | component-spec.xml |
| 文件系统级别的增量写入 | Overlay | PROJECT_SCAFFOLD/ |

### 8.2 手动标记最佳实践

1. **尽量精确**: 标记到最小范围，避免标记整个文件
2. **说明原因**: `<!-- MANUAL: 原因说明 -->` 比单纯的 `<!-- MANUAL -->` 更有帮助
3. **定期审查**: 手动标记过多会影响 Skill 自动更新效果
4. **版本控制**: 所有产物必须纳入版本控制（Git），以便追踪变更

### 8.3 异常处理

| 异常场景 | 处理方式 |
|----------|----------|
| 产物文件缺失 | 视为首次生成，直接写入 |
| 元数据缺失或损坏 | 视为首次生成，重新注入元数据 |
| 更新规则与文件类型不匹配 | 警告并中止，要求人工确认 |
| xml-sync.py 执行失败 | 记录错误日志，保留原文件，通知用户 |

---

> **维护者**: DevForge 核心团队  
> **问题反馈**: 请在项目 Issue 区提交  
> **修订历史**:  
> - v1.0 (2026-04-29): 初始版本
