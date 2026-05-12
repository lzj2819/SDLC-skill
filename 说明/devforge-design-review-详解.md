# DevForge Design Review 深度解析

> 本文档基于 DevForge SDLC Skill Chain v1.4 的 `devforge-design-review` 技能定义（`SKILL.md`）进行深度分析。
>
> **定位**：Stage 3b，属于 DIVE 工作流的 **Verify（验证）** 阶段。
> **核心目标**：回答"即使架构文档技术自洽，设计本身是否有缺陷？"——如同人工代码审查。
> **关键差异**：与 3a（architecture-validation）不同，design-review **不产生 PASS/FAIL**，只产生问题清单。

---

## 一、整体流程概览（9个步骤 + FIX 子流程）

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  Step 1: 读取所有历史产物（Read All Historical Artifacts）                      │
│       ↓                                                                     │
│  Step 2: 攻击者视角（Attacker Lens）—— 安全与鲁棒性                              │
│       ↓                                                                     │
│  Step 3: 运维者视角（Operator Lens）—— 可运维性与可调试性                         │
│       ↓                                                                     │
│  Step 4: 扩展者视角（Extender Lens）—— 可扩展性与可演进性                         │
│       ↓                                                                     │
│  Step 5: 问题汇总分类（Consolidate Issue List）                                 │
│       ↓                                                                     │
│  Step 6: 生成 DESIGN_REVIEW.md                                               │
│       ↓                                                                     │
│  Step 7: 自验证 — 审查质量（Self-Validation: Review Quality）                   │
│       ↓                                                                     │
│  Step 8: 状态更新（State Update）                                             │
│       ↓                                                                     │
│  Step 9: 人机关卡（Human Gate）                                               │
│       ↓                                                                     │
│  [FIX {issue_id}] 子流程（可选）                                               │
│       ├── Fix Mode A: 架构/文档修改（Must Fix / Should Fix）                    │
│       └── Fix Mode B: 标记 TODO（Nice to Fix）                                 │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 二、输入来源（上游产物）

`devforge-design-review` 是 Triple Verification（三重验证）的第二环（3b），它需要读取**所有历史产物**（不是只读上一个阶段的输出）：

| 输入文件 | 来源阶段 | 在 Design Review 中的用途 |
|---------|---------|------------------------|
| `PRD.md` | requirement-analysis | 需求基准，验证架构决策是否可追溯；发现孤儿假设 |
| `STATE.md` | 全链条维护 | 了解项目状态、已知风险、历史决策 |
| `DECISION_LOG.md` | 全链条维护 | 交叉引用——每个问题必须关联到具体决策 |
| `ARCHITECTURE.md` | architecture-design | 架构设计文档，审查设计选择的合理性 |
| `architecture.xml` | architecture-design | XML 权威源，审查模块分解、接口、状态模型的设计质量 |
| `INTERFACE_CONTRACT.md` | architecture-design | 接口契约，审查边界处理的完备性 |
| `VALIDATION_REPORT.md` | architecture-validation (3a) | 参考 3a 的验证结果，避免重复发现技术不一致问题 |

**关键设计点**：design-review 读取"完整推理链，而不仅仅是结论"。这意味着 AI 需要理解当初为什么做了某个架构决策，然后质疑这个决策的合理性。

---

## 三、每一步详解与调用的工具

### Step 1: 读取所有历史产物（Read All Historical Artifacts）

#### 做什么？
加载全部历史产物，理解完整的决策链条：
- `PRD.md`：原始需求
- `STATE.md`：项目状态和历史记录
- `DECISION_LOG.md`：关键决策记录
- `ARCHITECTURE.md`：架构设计文档
- `architecture.xml`：XML 架构权威源
- `INTERFACE_CONTRACT.md`：接口契约

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Read` | 读取上述所有文件 |

#### 为什么这样设计？
- **Single Thinker 模型**：所有 DevForge 技能都是"同一个思考者从不同维度展开复杂问题"
- **审查需要完整上下文**：如果只读 `architecture.xml`，无法理解"为什么当初选择了微服务而不是单体"——而这个"为什么"正是审查要质疑的对象
- **交叉引用基础**：后续步骤要求每个问题都必须关联到具体的决策或需求，没有完整历史产物做不到

---

### Step 2: 攻击者视角（Attacker Lens）—— 安全与鲁棒性

#### 做什么？
以攻击者/黑客的视角审视架构，提出以下问题：

| 审查项 | 具体问题 |
|--------|---------|
| **输入边界验证** | 每个模块是否验证输入边界？（空值、越界、注入攻击） |
| **竞态条件** | 状态转换中是否存在竞态条件？ |
| **外部依赖故障** | 数据库/API 故障时是否有降级路径？ |
| **单点故障** | 系统中是否存在单点故障？ |
| **数据加密** | 传输中（in transit）和静态（at rest）的数据是否加密？ |
| **认证与授权** | 每个边界是否都强制执行认证和授权？ |

#### 为什么这样设计？
- **Red Team（红队）思维**：不是"防御者怎么想的"，而是"攻击者会怎么做"
- **与 security-audit（3c）的分工**：
  - design-review（3b）的 Attacker Lens 关注**设计层面的安全缺陷**（如"模块 A 没有输入验证"）
  - security-audit（3c）关注**实现层面的安全漏洞**（如"依赖库有 CVE"、"密钥硬编码"）
- **预防性审查**：在写代码之前发现安全问题，修复成本比编码后低 10-100 倍

---

### Step 3: 运维者视角（Operator Lens）—— 可运维性与可调试性

#### 做什么？
以系统运维工程师的视角审视架构，提出以下问题：

| 审查项 | 具体问题 |
|--------|---------|
| **故障定位** | 模块故障时，能否快速定位根因？ |
| **日志覆盖** | 日志策略是否覆盖所有关键路径？ |
| **配置热更新** | 配置变更是否需要重启服务？ |
| **测试覆盖** | 测试覆盖是否充分（Mock + 真实环境）？ |
| **文档同步** | 文档和代码是否同步？ |
| **监控告警** | 系统能否被有效监控和告警？ |

#### 为什么这样设计？
- **DevOps 左移**：可运维性不是部署后才考虑的事，而是设计阶段就要审查
- **现实教训**：很多系统功能完美，但一出问题就找不到日志、无法调试，导致 MTTR（平均修复时间）极长
- **与 architecture-validation 的区别**：validation 检查"日志模块是否存在"，design-review 检查"日志是否覆盖了所有关键路径、格式是否统一、是否包含 TraceID"

---

### Step 4: 扩展者视角（Extender Lens）—— 可扩展性与可演进性

#### 做什么？
以未来扩展者的视角审视架构，提出以下问题：

| 审查项 | 具体问题 |
|--------|---------|
| **容量瓶颈** | 用户负载增长 10 倍时，哪个模块最先成为瓶颈？ |
| **新增功能成本** | 增加新功能模块时，需要修改多少现有代码？ |
| **向后兼容** | 接口契约是否支持向后兼容演进？ |
| **状态所有权** | 状态所有权是否清晰（谁创建、写入、读取、清理）？ |
| **依赖可替换** | 外部依赖能否在不重写核心逻辑的情况下替换？ |

#### 为什么这样设计？
- **未来视角**：大多数架构评审只关注"现在能不能工作"，而 Extender Lens 关注"6 个月后还能不能工作"
- **技术债务预防**："增加一个新模块要改 20 个文件"——这种设计在评审阶段就被标记为风险
- **VCMF "State as Responsibility"**：特别检查 `StateModel` 的生命周期完整性（create/read/update/delete/cleanup）

---

### Step 5: 问题汇总分类（Consolidate Issue List）

#### 做什么？
将三个镜头发现的问题统一分类为四个等级：

| 等级 | 定义 | 处理方式 |
|------|------|---------|
| **Must Fix** | 会导致系统失败或安全漏洞的关键缺陷 | 必须修复，阻塞进入 scaffolding |
| **Should Fix** | 高风险问题，应在上线前解决 | 强烈建议修复，但不阻塞（用户可选择接受风险） |
| **Nice to Fix** | 低风险改进项 | 可延期，在 scaffolding 中标记为 TODO |
| **Documented Risks** | 已接受的风险，需有明确的缓解策略 | 记录并在 DECISION_LOG 中备案 |

同时，**每个问题必须交叉引用到 `DECISION_LOG.md` 中的架构决策**。

#### 为什么这样设计？
- **不产生 PASS/FAIL**：这是 design-review 与 architecture-validation 最核心的区别
  - validation（3a）= 编译器：只有 PASS/FAIL 两种结果
  - design-review（3b）= 代码审查：发现问题，但由人类决定如何处理
- **四级分类的精细度**：
  - Must/Should/Nice 让团队知道优先级
  - Documented Risks 承认了"不是所有风险都值得修复"的现实——关键是明确记录和接受
- **强制关联 DECISION_LOG**：
  - 防止 AI"编造"问题
  - 每个问题都有根因："因为做了决策 X，所以产生了问题 Y"

---

### Step 6: 生成 DESIGN_REVIEW.md

#### 做什么？
生成审查报告，写入 `PROJECT_SCAFFOLD/docs/architecture/validation/DESIGN_REVIEW.md`。

#### 报告结构

| 章节 | 内容 |
|------|------|
| **Review Metadata** | 审查日期、审查的产物清单 |
| **Must Fix** | 关键缺陷列表（含 ID、描述、位置、影响、建议修复方案） |
| **Should Fix** | 高风险问题列表 |
| **Nice to Fix** | 低风险改进项列表 |
| **Documented Risks** | 已接受的风险（含缓解策略） |
| **Cross-Reference Table** | 问题与 DECISION_LOG 决策的交叉引用表 |

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Write` | 生成 `DESIGN_REVIEW.md` |

#### 为什么这样设计？
- **结构化报告**：人类审阅者可以快速定位到自己关心的严重级别
- **交叉引用表**：让决策者理解"这个问题源于哪个架构决策"，避免头痛医头
- **不含 PASS/FAIL**：报告末尾不会写"审查通过"或"审查不通过"——这是人类的决定权

---

### Step 7: 自验证 — 审查质量（Self-Validation: Review Quality）

#### 做什么？
执行 5 项自动检查，确保审查报告本身的质量：

| 检查 ID | 检查项 | 通过标准 |
|---------|--------|---------|
| REV-LENS-COVERAGE | **镜头覆盖度** | 三个镜头（Attacker/Operator/Extender）都有问题；如果某个镜头没有发现问题，需添加注释"No issues identified from [Lens] perspective — re-verify" |
| REV-SEVERITY-COMPLETE | **严重级别完整性** | 每个问题都有 severity 标签（Must Fix / Should Fix / Nice to Fix / Documented Risks） |
| REV-ARTIFACT-GROUNDING | **产物锚定性** | 每个问题至少引用一个源产物（PRD 需求 ID、architecture.xml Module ID、或 DECISION_LOG 条目 ID）；无源引用的问题被标记为"可能编造" |
| REV-NO-PASS-FAIL | **无 PASS/FAIL** | 文档中不能出现 "PASS"、"FAIL" 或 "verdict" 字样 |
| REV-XREF-VALID | **交叉引用有效性** | 引用的 DECISION_LOG ID 在 `DECISION_LOG.md` 中真实存在；引用的 PRD 需求在 `PRD.md` 中真实存在 |

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Read` | 读取 `DESIGN_REVIEW.md`、`DECISION_LOG.md`、`PRD.md` 进行验证 |
| `Grep` | 搜索 "PASS"、"FAIL"、"verdict" 等禁用词 |

#### 为什么这样设计？
- **审查审查者**：如果连审查报告本身都有问题（比如漏了一个镜头、编造了一个问题），那审查结果不可信
- **防止 AI 幻觉**：`REV-ARTIFACT-GROUNDING` 强制每个问题都有源产物引用，防止 AI 凭空捏造问题
- **强制执行"无 PASS/FAIL"**：通过 `Grep` 检查，确保 AI 不会无意识地在报告中写出"审查通过"——那是人类的权力

---

### Step 8: 状态更新（State Update）

#### 做什么？
更新 `STATE.md`：

1. **Known Pitfalls & Risks 追加**：将所有发现的风险添加到已知风险列表
2. **Completed Steps 追加**：
   ```
   [YYYY-MM-DD HH:MM] devforge-design-review: 
   Identified X Must Fix, Y Should Fix, Z Nice to Fix, W Documented Risks. 
   Cross-referenced to N architecture decisions.
   ```
3. **设置 phase**：`design_review_completed`（或保持现有 phase，如果 validation 尚未运行）

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Read` | 读取当前 STATE.md |
| `Write` / `Edit` | 更新 STATE.md |

#### 为什么这样设计？
- **风险知识库**：`Known Pitfalls` 是 append-only 的，即使某些风险被接受（Documented Risks），它们仍然被记录，供未来参考
- **Phase 设置**：`design_review_completed` 是进入 `project-scaffolding` 的可接受前置条件之一

---

### Step 9: 人机关卡（Human Gate）

#### 做什么？
1. 展示问题摘要（按严重级别统计）
2. 明确告知："设计审查报告已生成。这不是'通过/不通过'的检查，而是一份问题清单。"
3. 列出可用命令并等待用户回复

#### 可用命令

| 命令 | 作用 |
|------|------|
| `[APPROVE]` | 批准并继续（进入 project-scaffolding 阶段） |
| `[FIX <issue_id>]` | 进入修复模式，修复指定问题 |
| `[PAUSE]` | 暂停当前阶段，保留上下文 |
| `[ROLLBACK {step_id}]` | 回滚到指定步骤重新执行 |
| `[EDIT {file_path}]` | 手动编辑文件后让 AI 继续 |
| `[INJECT {context}]` | 补充额外上下文约束 |
| `[EXPLAIN {TraceID}]` | 展开解释某个决策/错误的推理链 |

#### 关键约束：HARD-GATE
```markdown
<HARD-GATE>
Do NOT proceed to project-scaffolding until the user replies [APPROVE]. 
This skill does NOT produce a PASS/FAIL conclusion.
</HARD-GATE>
```

#### 为什么这样设计？
- **人类是最终决策者**：design-review 只提供问题清单，由人类决定"修不修""什么时候修"
- **与 validation（3a）的 HARD-GATE 对比**：
  - validation 失败 → 不能继续（系统自动阻止）
  - design-review 发现 Must Fix → **仍然可以** `[APPROVE]` 继续（人类决定接受风险）
  - 这是"代码审查"和"编译检查"的本质区别

---

## 四、FIX 子流程详解

当用户在关卡回复 `[FIX <issue_id>]` 时，触发 FIX 子流程：

### FIX 子流程步骤

```
[FIX {issue_id}]
    │
    ├── Step 1: 查找问题 ──→ 读取 DESIGN_REVIEW.md，定位 issue
    │
    ├── Step 2: 分类严重级别
    │       ├── Must Fix / Should Fix ──→ Fix Mode A（架构/文档修改）
    │       └── Nice to Fix ──→ Fix Mode B（标记 TODO）
    │
    ├── Fix Mode A:
    │       ├── 读取源文件（architecture.xml / INTERFACE_CONTRACT.md / DECISION_LOG.md）
    │       ├── 基于 suggested fix 生成 diff
    │       ├── 写入 DESIGN_REVIEW_FIX_{issue_id}.md
    │       ├── 询问用户：[APPLY] / [EDIT] / [IGNORE]
    │       ├── [APPLY] → 应用 diff → 自动触发 architecture-validation 重新运行
    │       │                    → 验证通过后返回 design-review 关卡
    │       ├── [EDIT] → 展示 diff → 用户修正 → 重新生成 diff
    │       └── [IGNORE] → 标记 issue 为 ignored → 返回关卡
    │
    ├── Fix Mode B:
    │       ├── 标记 issue 为 deferred
    │       ├── 在 scaffolding 阶段转为代码中的 TODO 注释
    │       └── 返回 design-review 关卡
    │
    └── Step 5: 完成检查
            ├── 所有 Must Fix / Should Fix 已解决 → 允许 [APPROVE]
            └── 仍有未解决 Must Fix / Should Fix → 继续 FIX 流程
```

### 为什么设计 FIX 子流程？

- **闭环修复**：发现问题 → 生成修复方案 → 应用修复 → 重新验证，形成完整闭环
- **自动触发 re-validation**：应用修复后自动运行 `architecture-validation`（3a），确保修改没有引入新的技术不一致
- **三种用户选择**：
  - `[APPLY]`：信任 AI 的修复方案，自动应用
  - `[EDIT]`：人类审查并调整修复方案
  - `[IGNORE]`：人类决定接受风险，issue 被记录为"已知晓但选择不修复"
- **TODO 传承**：Nice to Fix 的问题不阻塞流程，但会转化为代码中的 TODO 注释，确保不会被遗忘

---

## 五、核心输出产物清单

| 产物 | 路径 | 作用 | 下游消费者 |
|------|------|------|-----------|
| **DESIGN_REVIEW.md** | `docs/architecture/validation/DESIGN_REVIEW.md` | 完整的设计审查报告，含四级分类的问题清单和决策交叉引用 | project-scaffolding（参考风险）、iteration-planning（评估技术债务） |
| **DESIGN_REVIEW_FIX_{issue_id}.md** | 临时文件 | 单个 issue 的修复 diff 方案 | 用户审阅后应用或忽略 |

---

## 六、流程设计哲学深度解析

### 1. 为什么 Design Review 不产生 PASS/FAIL？

这是 design-review 与 architecture-validation 最本质的区别：

| 维度 | architecture-validation（3a） | design-review（3b） |
|------|------------------------------|---------------------|
| **类比** | 编译器类型检查 | 人工代码审查 |
| **判定标准** | 客观（XML Schema 是否匹配） | 主观（设计是否合理） |
| **输出** | PASS / FAIL | 问题清单 |
| **谁决定继续** | 系统（FAIL 则自动阻止） | 人类（即使 Must Fix 也可选择继续） |
| **修复义务** | 失败必须修复 | 问题可选择接受、延期或修复 |

**关键洞察**：设计质量不是一个布尔值。一个架构可能有 10 个问题，但团队根据资源和时间决定先修 3 个——这是人类的判断，AI 不能替人类做这个决定。

### 2. 为什么需要三个镜头（Three Lenses）？

| 镜头 | 角色 | 关注点 | 常见问题 |
|------|------|--------|---------|
| **Attacker** | 黑客/安全研究员 | "我怎么搞垮这个系统？" | 输入验证缺失、竞态条件、单点故障、加密缺失 |
| **Operator** | SRE/运维工程师 | "系统出问题时我怎么排查？" | 日志不足、监控缺失、配置需重启、文档不同步 |
| **Extender** | 未来开发者 | "6 个月后加新功能有多难？" | 紧耦合、无向后兼容、状态所有权模糊、替换成本高 |

**为什么不是两个或四个？**
- **Attacker + Operator + Extender** 覆盖了软件生命周期的三大核心维度：安全运行、稳定运维、持续演进
- 缺少任何一个镜头都会导致盲区：
  - 缺 Attacker → 安全问题被忽视
  - 缺 Operator → 上线后运维噩梦
  - 缺 Extender → 技术债务累积

### 3. 为什么强制关联 DECISION_LOG？

**防止 AI 编造问题**：
- 如果 AI 可以随便说"这个设计有问题"，那审查结果不可信
- 强制关联 DECISION_LOG 确保每个问题都有根因："因为做了决策 X，所以产生了问题 Y"

**帮助决策者理解权衡**：
- "微服务架构（决策 arch-dec-0003）导致了分布式事务复杂度（问题 DR-005）"
- 这让决策者理解：这不是"设计错了"，而是"选择 A 带来了副作用 B"

### 4. 为什么 Must Fix 也能被 [APPROVE] 跳过？

这体现了 design-review 的核心哲学：**人类拥有最终决策权**。

**场景**：
- Design Review 发现一个 Must Fix："支付模块没有实现幂等性，重复提交会导致重复扣款"
- 但产品经理说："我们下周必须上线 MVP，幂等性在 V1.1 再做"
- 团队决定接受这个风险，并在 DECISION_LOG 中记录

**AI 的正确行为**：
- 标记这个问题为 Must Fix
- 解释风险
- **但不阻止团队继续**
- 人类回复 `[APPROVE]` 后，AI 继续到 scaffolding

**与 validation（3a）的对比**：
- validation 发现 XML 中 Module A 依赖 Module B 但 Module B 不存在 → **系统自动阻止继续**
- design-review 发现"没有幂等性" → **人类决定是否接受风险**
- 前者是事实判断（依赖不存在 = 无法运行），后者是价值判断（风险可接受度因人而异）

### 5. 为什么 FIX 子流程要自动触发 re-validation？

**闭环保证**：
```
发现问题 → 生成修复 → 应用修复 → 重新验证 → 确认修复未引入新问题
```

**防止修复引入回归**：
- 修改 `architecture.xml` 修复一个问题，可能破坏另一个模块的接口契约
- 自动触发 `architecture-validation`（3a）确保技术一致性仍然成立
- 这是"修复后再编译一次"的架构等价物

---

## 七、与 Triple Verification（三重验证）的关系

`devforge-design-review` 是 Triple Verification 的第二环（3b）：

| 维度 | 3a. architecture-validation | **3b. design-review（本文档）** | 3c. security-audit |
|------|---------------------------|-------------------------------|-------------------|
| **目的** | 验证"设计在技术层面是否正确指定" | **验证"设计是否有缺陷/遗漏"** | 验证"设计是否有安全漏洞" |
| **视角** | 技术一致性（工程师视角） | **对抗性审查（批评者视角）** | 安全扫描（审计者视角） |
| **输入** | architecture.xml, INTERFACE_CONTRACT.md | **PRD, architecture.xml, DECISION_LOG** | architecture.xml, 代码, 依赖 |
| **检查项** | XML Schema 合规、接口一致性、PRD 可追溯性 | **安全、可运维性、可扩展性** | 漏洞、密钥泄露、合规性 |
| **输出** | VALIDATION_REPORT.md（PASS/FAIL） | **DESIGN_REVIEW.md（问题清单，无 PASS/FAIL）** | SECURITY_AUDIT_REPORT.md（风险等级） |
| **结果** | 失败必须修复才能继续 | **问题可接受、延期或修复** | 严重问题必须修复才能部署 |
| **类比** | 编译器类型检查 | **代码审查** | 安全渗透测试 |

**核心原则**：三者互补，不可互相替代。
- validation 确保"设计文档自洽" → design-review 确保"设计决策正确" → security-audit 确保"设计安全"
- validation 通过了，不代表设计没有缺陷（design-review 可能发现问题）
- design-review 没问题，不代表设计安全（security-audit 可能发现漏洞）

---

## 八、VCMF 五原则在 Design Review 中的体现

| VCMF 原则 | 在 Design Review 中的体现 |
|-----------|--------------------------|
| **Design as Contract** | Step 2 验证架构决策是否可追溯回 PRD；Step 5 的 Documented Risks 确保已接受的风险有明确备案；标记孤儿假设（orphaned assumptions） |
| **Interface as Boundary** | Attacker Lens 检查每个边界是否都有输入验证和认证授权；Operator Lens 检查接口是否支持故障排查；Extender Lens 检查接口是否支持向后兼容演进 |
| **Reality as Baseline** | Operator Lens 检查日志、监控、告警是否可实际运行；Attacker Lens 检查降级路径是否真实可行；Extender Lens 检查 10x 扩容假设是否有数据支撑 |
| **State as Responsibility** | Extender Lens 验证每个 `StateModel` 是否有完整的生命周期（create/read/update/delete/cleanup）；检查状态所有权是否清晰 |
| **XML as Authority** | 验证 XML 产物是否完整、一致、无推测性元素；交叉引用验证确保 XML 中的每个模块 ID、决策 ID 都是真实的 |

---

## 九、与其他技能的协作边界

### 与 `devforge-architecture-validation`（3a，并行上游）的关系

```
architecture-validation (3a) ──┐
    VALIDATION_REPORT.md        │──→ design-review (3b) 读取参考
                                │      （避免重复发现技术不一致问题）
architecture-design (2) ────────┘
    所有产物 ─────────────────→ design-review (3b) 审查对象
```

**关键区别**：
- validation（3a）问："XML 和契约一致吗？" → 是/否
- design-review（3b）问："即使一致，设计本身好吗？" → 问题清单

### 与 `devforge-security-audit`（3c，并行下游）的关系

```
design-review (3b) ──→ [APPROVE] ──→ security-audit (3c)（可选）
    Attacker Lens（设计层面安全）    security-audit（实现层面安全）
```

**分工**：
- design-review 的 Attacker Lens 发现"设计中没有输入验证"
- security-audit 发现"依赖库 lodash 版本有 CVE-2021-23337"
- 前者是架构问题，后者是实现问题

### 与 `devforge-project-scaffolding`（下游）的关系

```
design-review [APPROVE] ──→ project-scaffolding (4)
    DESIGN_REVIEW.md          → 参考已知风险
    deferred issues           → 转为代码中的 TODO 注释
```

### 与 `devforge-iteration-planning`（循环回）的关系

```
iteration-planning (7) ──→ 新需求 ──→ 可能触发重新审查
    如果新增模块或重大接口变更    → 提示用户运行 [DESIGN_REVIEW]
```

---

## 十、总结

`devforge-design-review` 是 DevForge 链条中的**对抗性审查者**。它的核心价值在于：

1. **不是守门员，而是顾问**：只提供问题清单，不替人类做"通过/不通过"的决定
2. **三维立体审查**：Attacker + Operator + Extender 三个镜头覆盖安全、运维、演进三大维度
3. **完整历史上下文**：读取所有历史产物，理解"为什么做这个决策"，然后质疑它
4. **闭环修复**：FIX 子流程支持发现问题 → 生成修复 → 应用修复 → 重新验证的完整闭环
5. **风险知识传承**：发现的风险进入 STATE.md 的 Known Pitfalls，供全链条参考

它是 Triple Verification 的**第二道防线**——如同资深工程师的代码审查，在编译器检查通过之后，再从设计合理性、可维护性、安全性等更高维度审视系统。

---

> 生成日期：2026-05-12
> 基于：DevForge SDLC Skill Chain v1.4
> 关联文档：devforge-architecture-validation-详解.md（Stage 3a）
