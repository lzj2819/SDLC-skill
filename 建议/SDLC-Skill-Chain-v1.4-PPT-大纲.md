# DevForge SDLC Skill Chain v1.4 PPT 内容大纲

> 基于 `E:\pythonproject\vclaw\SDLC-skill` v1.4 全部内容设计
> 结构：DIVE循环叙事（Design-Implement-Verify-Evolve）+ 支撑体系 + 版本演进
> 总页数：35 页
> 演讲时长：75-90 分钟

---

## Part 1：开场与问题定义（P1-P4）

### P1 封面
**页面标题**：DevForge SDLC Skill Chain **v1.4** — 从"产品灵感"到"生产部署"的完整 AI 驱动生命周期  
**副标题**：基于 VCMF 与 DIVE 方法论的 12 阶段 Skill 链 + 6 大领域扩展  
**新增副标题行**：**三层 XML 权威架构 · 三重验证机制 · 增量迭代 · 生产就绪**
**视觉建议**：
- 深色背景（午夜蓝 #1E2761）
- 中央 DIVE 循环图：Design → Implement → Verify → Evolve（环形箭头，金色高亮）
- 外环标注 12 个阶段编号，内环标注 4 个 DIVE 阶段
- 底部标签："v1.4 | 12 Stages + 6 Extensions + 16-Section STATE"
- 右下角：VClaw Project | 2026

---

### P2 议程
**页面标题**：今天讲什么 — 一条从想法到生产的完整路径  
**内容要点**（10 条）：
1. 一个流行的陷阱：把 AI 当成"一次性代码生成器"
2. 我们的答案：Single Thinker 的 DIVE 迭代模型
3. **Design**：需求分析 → 架构设计（锁定目标与技术路径）
4. **Verify**：三重验证 — 技术自洽 + 对抗审查 + 安全扫描 + 威胁建模
5. **Implement**：项目脚手架 → 模块细化（从 XML 到精确代码骨架）
6. **Verify**：测试执行 — 单元/集成/E2E + 覆盖率门控
7. **增强能力**：可视化 + 生产就绪 + 调试助手 + 数据管道
8. **Evolve**：增量迭代 — 在已有框架上优雅生长
9. **支撑体系**：6 个领域扩展 + STATE.md 推理锚点 + 上下文压缩
10. 产物地图与使用方式
**视觉建议**：
- 左侧 DIVE 四象限环形图，每个象限标注对应阶段编号
- 右侧 10 个节点垂直排列，每个节点配图标
- Design(蓝) / Implement(绿) / Verify(橙) / Evolve(紫) 四色区分

---

### P3 问题：为什么"一次性 AI 代码生成"不够？
**页面标题**：为什么生成代码只是开始，而非结束？  
**核心内容**：
- **没有架构约束的代码 = 技术债务加速器**
  - AI 每次生成都是"从头开始"，不继承之前的架构决策
  - 函数签名、错误处理、状态管理每次都不一样
- **需求在会话中漂移**
  - 多轮对话后，最初的业务目标被遗忘
  - 没有 Immutable Goal 的锚定，输出越来越偏离初衷
- **无法验证 correctness**
  - 生成即结束，没有自洽性检查、没有对抗审查、没有测试执行
  - 代码"看起来对"和"真的对"之间的差距无人填补
- **从 0 搭建可以，增量演进不行**
  - 新需求来了只能"重新描述一遍"
  - 已有代码和架构无法被增量修改
**v1.4 新增钩子**：
- 底部红字："你得到的是一段代码，而不是一个**可演进、可验证、可运维**的系统"
**视觉建议**：
- 中央一个断裂的链条（象征断裂的 SDLC）
- 四个断点分别标注：无架构约束、需求漂移、无验证、无法演进
- 底部红色大字强调钩子

---

### P4 我们的答案：Single Thinker + DIVE 循环
**页面标题**：最好的 AI 工程系统，像一个思考者的多次草稿  
**核心内容**：
- **同一思考者**：12 个 skill 是同一个大脑面对同一问题的 12 次展开
- **完整上下文**：每个 skill 读取**全部历史产物**，而非仅上一阶段的结论
- **DIVE 循环**：
  - **Design**：需求分析 → 架构设计 → 模块细化（锁定"做什么"和"怎么做"）
  - **Implement**：脚手架 → 代码骨架（把设计落地为可运行项目）
  - **Verify**：三重验证 → 测试执行（确保"做对"而非"做完"）
  - **Evolve**：增量迭代（软件持续生长，不推翻重来）
- **推理链外化**：不依赖模型记忆，靠 STATE.md + 三层 XML 锚定
- **对抗性检验**：验证、审查、安全审计三视角互补，不能互相替代
**视觉建议**：
- 中央一个大脑图标，周围 DIVE 四环循环
- 12 条光线从大脑辐射到外围的 12 个阶段节点
- 光线标注"完整上下文流动"（双向箭头）
- 底部引用：`"同一个大脑，在不同维度上展开推理，最终合并成一个连贯的结论"`

---

## Part 2：Design — 从想法到设计（P5-P10）

### P5 Skill 1：需求分析 — 为什么要先锁定目标？
**页面标题**：devforge-requirement-analysis：如果需求模糊，一切后续都是浪费  
**为什么需要**：
- AI 生成代码最大的浪费来源：需求理解偏差 → 架构错误 → 代码返工
- 没有 PRD 的闭环指标，无法判断"做完了"还是"做对了"
- 没有领域标签提取，架构设计时会盲目评估所有模式
**具体有什么用**：
- 通过 3-5 个针对性问题补全上下文，防止信息衰减
- 提取项目特征标签（`ai_agent`、`event_driven`、`microservice` 等），为动态模式筛选做准备
- 播种 DECISION_LOG.md，记录"当时为什么这样决定"，防止后续阶段漂移
- 生成 RTM（需求追溯矩阵），让每个后续产物都能回溯到需求源头
**产物**：`PRD.md` + `DECISION_LOG.md`（初始）+ `RTM.md`
**VCMF 检查点**：
- Design as Contract：闭环指标与 Scope 边界
- Interface as Boundary：跨模块交互点识别
- Reality as Baseline：可观测、可测试的验收标准
- State as Responsibility：业务状态所有者文档化
**视觉建议**：
- 左侧：一个靶心图标（锁定目标）
- 右侧：PRD + DECISION_LOG + RTM 三个文件，有箭头指向后续阶段
- 底部标注："同一思考者，亲自播种推理锚点"

---

### P6 Skill 2：架构设计 — 为什么需要"模式筛选"而非"拍脑袋"？
**页面标题**：devforge-architecture-design：10 种模式动态筛选，防止上下文爆炸  
**为什么需要**：
- 让 AI 直接"设计架构"，它会陷入选择 paralysis 或随意选择熟悉模式
- 不加筛选地评估所有模式 = 上下文爆炸，输出泛泛而谈
- 没有 XML 权威架构，代码生成阶段会随意偏离接口契约
**具体有什么用**：
- **动态模式筛选**：从 10 种架构模式库中，根据领域标签筛选最相关的 4-6 种进行评估
- **三层 XML 架构**：系统级（`architecture.xml`）→ 模块级（`module-architecture.xml`）→ 组件级（`component-spec.xml`）
- **推理外化**：XML 新增 `<DecisionTrace>` 节点，记录每个架构决策的 Question、Answer、Risk
- **领域扩展 overlay**：检测到 `ai_agent`/`data_pipeline`/`mobile_app` 等标签时，自动加载对应领域的额外评估维度和反模式
- **v1.4 新增**：安全架构建模（弱算法黑名单）、数据库 Schema（DDL）、OpenAPI 3.0 规范
**10 种并行评估的架构模式**：
1. Layered（分层）
2. Hexagonal（六边形/端口适配器）
3. Event-Driven（事件驱动）
4. Microservice（微服务）
5. Client-Server（客户端-服务器）
6. Plugin-Based（插件化）
7. CQRS（命令查询职责分离）
8. BFF（Backend for Frontend）
9. Serverless/FaaS（无服务器函数）
10. Micro-Frontends（微前端）
**视觉建议**：
- 中央展示动态筛选漏斗：10 种模式输入 → 根据领域标签筛选 → 4-6 种模式进入评分矩阵
- 评分矩阵示意：4-6 行 × 5 列评估维度，某一行高亮（推荐方案）
- 底部展示三层 XML 树状结构预览（system → module → component）

---

### P7 三层 XML 架构权威 — 代码围着文档转
**页面标题**：XML as Authority — 为什么代码必须服从文档？  
**核心内容**：
- **问题**：传统 AI 生成中，代码和文档是两张皮 — 文档写一套，代码生成另一套
- **解决方案**：`component-spec.xml` 是代码生成的单一起源
  - 函数签名必须与 XML 一致
  - 错误码必须与 XML 一致
  - 文件路径必须与 XML 一致
- **CI 自动校验**：`architecture-check` job 运行 `xml-sync.py --verify-only`
- **三层引用链**：
  ```
  system-architecture.xml
  ├── modules/UserService/module-architecture.xml
  │   └── components/AuthController/component-spec.xml
  │       └── Functions/Login (签名 → 代码)
  ```
**v1.4 新增**：
- `security.xml` — 安全节点（Authorization/ThreatModel/KeyManagement/Audit）
- `dataflow.xml` — 数据管道拓扑（data-pipeline skill 产出）
**视觉建议**：
- 左侧：XML 文件树（三层）
- 中间：箭头 → "代码生成"
- 右侧：代码文件，函数签名与 XML 一一对应
- 底部：CI 检查通过/失败的徽章

---

### P8 四重验证机制总览 — 为什么需要四个验证视角？
**页面标题**：验证（3a）+ 审查（3b）+ 安全（3c）+ 威胁建模（3d）  
**核心论点**：单一验证视角必然遗漏问题。四个视角互补，不能互相替代。
**对比表格**：
| 维度 | 3a. architecture-validation | 3b. design-review | 3c. security-audit | 3d. threat-modeling |
|------|------------------------------|-------------------|--------------------|---------------------|
| **核心问题** | "设计文档是否自洽？" | "设计是否有漏洞？" | "设计是否有安全漏洞？" | "系统面临哪些威胁？" |
| **视角** | 技术一致性（工程师） | 对抗审查（红队） | 安全扫描（审计员） | 威胁分析（安全架构师） |
| **方法** | XML Schema、Mock 模拟、拓扑连通 | 攻击者/维护者/扩展者三视角 | 8 类漏洞扫描 + CVE 检查 | STRIDE 方法论 |
| **输出** | PASS/FAIL + 增量对比报告 | 问题清单（无 PASS/FAIL） | 风险等级报告 | 威胁矩阵 + 缓解方案 |
| **控制流程** | 失败则阻塞 | 只提供问题，用户决策 | 严重问题必须修复 | 可选但推荐 |
| **类比** | 编译器类型检查 | 代码审查 | 安全渗透测试 | 威胁情报分析 |
**v1.4 新增**：
- 3c `security-audit` 自动生成 `SECURITY_FIX.patch`，`[APPLY]` 一键修复
- 3d `threat-modeling`（STRIDE）是 v1.4 新增，为高风险系统提供结构化威胁分析
**视觉建议**：
- 四个盾牌并排，分别用蓝/红/橙/紫标注
- 盾牌之间有虚线连接，标注"互补而非替代"
- 底部大字："四个视角 = 四道保险"

---

### P9 Skill 3a/3b/3c/3d：四个验证视角详解
**页面标题**：每一道验证，堵住一类不同的风险  
**3a. architecture-validation（技术自洽）**：
- XML vs Interface Contract 一致性
- XML vs PRD 一致性（防孤儿模块）
- Mock 注入 + 模块级模拟
- 生成 `VALIDATION_DELTA.md` — 只报告新增/已解决的问题
**3b. design-review（对抗挑刺）**：
- 唯一任务是找问题，不产出 PASS/FAIL
- 攻击者视角：输入边界、竞态条件、依赖故障降级
- 维护者视角：根因定位、日志覆盖、配置热更新
- 扩展者视角：10x 扩容瓶颈、向后兼容、接口版本控制
**3c. security-audit（安全扫描）**：
- 8 类漏洞扫描（硬编码密钥、SQL 注入、XSS、不安全依赖等）
- CVE 检查 + 黑名单机制（VM2、已知 RCE 库）
- 自动修复 diff 生成
**3d. threat-modeling（威胁建模）v1.4 新增**：
- STRIDE 六维分析（欺骗、篡改、抵赖、信息泄露、拒绝服务、权限提升）
- 风险评级矩阵（可能性 × 影响）
- 缓解方案生成 + 安全测试用例
**视觉建议**：
- 2×2 网格，每个象限一个验证视角
- 每个象限配图标 + 一句话总结 + 关键产出文件名

---

### P10 Skill 3a vs 3b vs 3c vs 3d：为什么要分开？
**页面标题**：验证是"检查自洽"，审查是"专门挑刺"，安全是"扫描漏洞"，威胁是"预判攻击"  
**核心对比**（延续 P8 表格，更详细）：
- **3a 保证"文档没写错"** — 如果 XML 和接口契约矛盾，后续代码必然出错
- **3b 保证"设计没漏想"** — 即使文档自洽，设计决策本身可能有缺陷（如没考虑缓存雪崩）
- **3c 保证"实现没漏洞"** — 即使设计合理，依赖库可能有 CVE，代码可能有注入点
- **3d 保证"没被攻击者盯上"** — 从攻击者视角系统性地预判威胁，而非被动等待漏洞出现
**关键原则**：3a 和 3b **默认都运行**，3c 可选但推荐，3d 针对 high-security 项目自动触发
**视觉建议**：
- 一条流水线从左到右：设计文档 → [3a 类型检查] → [3b 代码审查] → [3c 渗透测试] → [3d 威胁情报]
- 每个检查站配通过/警告/阻塞图标

---

## Part 3：Implement — 从设计到代码（P11-P15）

### P11 Skill 4：项目脚手架 — 为什么需要"携带完整上下文落地"？
**页面标题**：devforge-project-scaffolding：设计不落地 = 纸上谈兵  
**为什么需要**：
- 传统 AI 生成：只给"示例代码"，不给完整工程（CI/CD、测试框架、部署配置）
- 没有 XML 同步的脚手架：代码和架构文档很快脱节
- 没有 ADR 和同步规则：3 个月后没人记得"当时为什么这样设计"
**具体有什么用**：
- 读取**全部历史产物**（包括 DESIGN_REVIEW 问题清单），携带完整上下文落地
- 每个核心模块头部携带**推理链注释**（关联架构决策 ID + 为什么存在 + 已知风险）
- DESIGN_REVIEW 的 Must Fix / Should Fix 自动转为**内联 TODO**
- 生成 **ADR（架构决策记录）**作为代码库中的持久推理锚点
- 架构 XML 自动复制到 `docs/architecture/`，生成 `INDEX.md` 和 `repo-index.md`
- **v1.3 变更**：XML 驱动的精确代码骨架**移至 module-design**；脚手架只生成基础设施和模块目录结构
**产物**：
- `PROJECT_SCAFFOLD/`（完整可运行项目目录）
- `docs/ADR.md` + `docs/sync-rules.md` + `CHANGELOG.md`
- `.env.template`
- CI/CD 配置（含 `architecture-check` job）
- `docs/architecture/INDEX.md` + `repo-index.md`
**视觉建议**：
- 中央：工人手持完整历史卷轴（PRD + XML + Design Review）
- 代码区域出现注释和 TODO 标记
- 右侧展示 PROJECT_SCAFFOLD 目录树

---

### P12 Skill 5：模块细化设计 — 为什么需要"从系统到组件"？
**页面标题**：devforge-module-design：系统架构是地图，模块设计是施工图纸  
**为什么需要**：
- `architecture.xml` 只到模块级别，模块内部的组件分解需要更细粒度的设计
- 没有 `component-spec.xml`，代码生成阶段会随意编写函数签名
- 模块间接口兼容性如果不检查，集成时会出现"类型不匹配"
**具体有什么用**：
- **锁定模块边界**：从 `architecture.xml` 中提取该模块的接口契约、耦合依赖和状态责任
- **模块级需求分析**：从 PRD 中筛选涉及该模块的 user stories，拆解为模块级 stories
- **组件分解**：将模块拆分为 3-6 个内部组件（entry_point / domain_service / repository / utility / gateway）
- **组件接口设计**：显式定义方法名、输入/输出 Schema、错误码
- **P0/P1/P2 代码骨架策略**：
  - P0：完整接口 stub + 最小可工作实现
  - P1：接口 stub + `raise NotImplementedError`
  - P2：文件头注释 + 空函数定义
- **v1.4 新增**：微服务代码生成 — gRPC proto、Saga 编排配置、弹性模式（熔断/限流/重试）
- **自校验**：跨模块接口兼容性检查、Schema 合规性、PRD 可追溯性
**产物**：
- `module-prd.md` + `module-architecture.xml` + `module-interface-contract.md`
- `components/{id}/component-spec.xml`
- 精确代码骨架（严格匹配 component-spec.xml）
- 模块级测试代码
**视觉建议**：
- 左侧：一个模块（如 UserService）被放大镜放大
- 右侧：模块内部拆分为 4-5 个组件方块，组件之间用带契约标签的箭头连接
- 底部：P0/P1/P2 三层代码示例

---

### P13 Skill 5：模块设计工作流与产物
**页面标题**：模块细化 — 从 `[MODULE {id}]` 到可运行代码骨架  
**核心工作流（12 步）**：
1. 加载父上下文（PRD、系统 XML、接口契约、STATE.md Module Registry）
2. 锁定模块边界（从系统 XML 提取）
3. 模块级需求分析（筛选 user stories，分级 P0/P1/P2）
4. 组件分解（3-6 个组件）
5. 组件接口设计（方法签名 + Schema + 错误码）
6. 填充 `module-architecture.xml`（Constraints、Components、ComponentInterfaces、ModuleStateModel）
7. 生成 `component-spec.xml` 模板
8. P0/P1/P2 代码骨架生成
9. 生成模块级测试代码
10. 编写 `module-prd.md`
11. **自校验**（跨模块接口兼容性、Schema 合规、PRD 可追溯）
12. 人类门控 `[APPROVE / NEXT MODULE / MODULE_BATCH]`
**并行批量模式** `[MODULE_BATCH {ids}]`：
- 耦合分析 → 检测循环依赖 → 并行分派子 Agent → 一致性检查 → 冲突解决
**视觉建议**：
- 左侧垂直流程图，12 个步骤
- 步骤 6-8 用高亮框标注（XML → 代码骨架的核心链路）
- 右侧展示产物树状图

---

## Part 4：Verify — 从代码到质量（P16-P18）

### P14 Skill 6：测试执行 — 为什么"生成了测试"不等于"测试过了"？
**页面标题**：devforge-test-execution：生成测试是设计，执行测试是验证  
**为什么需要（v1.3 新增）**：
- 传统流程：AI 生成测试代码，但从不运行 — 测试本身可能有语法错误
- 没有覆盖率报告，无法知道"测了多少"
- 没有 RTM 同步，无法知道"每个需求是否都被测试覆盖"
**具体有什么用**：
- **单元测试执行**（`tests/mock/`）— 覆盖率阈值 80%
- **集成测试执行**（`tests/real/` with `skipif`）— 真实环境验证
- **端到端测试执行**（`tests/end_to_end/`）— 映射到 PRD User Stories
- **覆盖率报告生成**：`TEST_COVERAGE_GAP.md` — 标注未覆盖的代码路径
- **RTM 实时同步**：测试通过的项标记为 `tested`，失败的标记为 `implemented`
- 测试失败时可直接触发 `[DEBUG]` 进入调试模式
**产物**：`TEST_REPORT.md` + `TEST_COVERAGE_GAP.md` + 更新后的 `RTM.md`
**视觉建议**：
- 左侧：三层测试金字塔（单元 → 集成 → E2E）
- 右侧：覆盖率仪表盘（80% 阈值线）
- 底部：RTM 同步示意（需求 → 测试 → 状态）

---

### P15 测试执行工作流与产物
**页面标题**：测试执行 — 从 `[TEST]` 到质量报告  
**核心工作流（8 步）**：
1. 从 `RTM.md` 加载测试清单
2. 环境准备（`.env` 检查、mock 模式降级）
3. 单元测试执行 + 覆盖率检查（≥80%）
4. 集成测试执行（真实 LLM / 数据库）
5. 端到端测试执行（用户故事级）
6. 测试报告生成（通过率、覆盖率趋势、失败详情）
7. RTM 同步（状态更新）
8. 人类门控 `[APPROVE / DEBUG / RETEST]`
**质量门控**：
- 单元测试覆盖率 < 80% → CI 失败
- 任何 Critical 级测试失败 → 阻塞发布
**视觉建议**：
- 左侧流程图
- 右侧展示 TEST_REPORT 结构预览 + 覆盖率趋势图

---

## Part 5：可选增强能力 — 从"能跑"到"能扛"（P19-P24）

### P16 可选增强总览
**页面标题**：8 个核心阶段之后，还有 4 个专项能力  
**核心内容**：
DevForge 的核心路径是 1→2→3a→3b→4→5→6→7（强制/推荐），但生产环境还需要：
- **可视化**：降低架构认知负荷（Mermaid 图自动生成）
- **生产就绪**：从本地可运行到云原生可部署（Terraform + K8s + 监控）
- **调试助手**：测试失败 / 生产事故时的快速诊断
- **威胁建模 + 数据管道**：安全与数据的专项能力（v1.4）
**触发方式**：全部按需触发（`[VISUALIZE]`、`[OPS]`、`[DEBUG]`、`[THREAT_MODEL]`、`[DATA_PIPELINE]`）
**视觉建议**：
- 核心路径用实线箭头（1→2→3a→3b→4→5→6→7）
- 可选增强用虚线箭头从核心路径分支出去
- 每个分支配图标和触发命令

---

### P17 Skill 8：架构可视化 — 降低认知负荷
**页面标题**：devforge-visualization：一图胜千言  
**为什么需要**：
- XML 架构正确但不易读，人类需要图形化理解
- 手动维护架构图 = 图和代码必然不同步
- 新成员加入时，需要快速理解系统全貌
**具体有什么用**：
- 从 `architecture.xml` **自动生成** Mermaid 图表
- 系统上下文图（System Context）：系统 + 外部依赖
- 模块交互时序图（Module Interaction）：核心用户故事调用链
- 数据流图（Data Flow）：数据在模块间的转换路径
- ER 图（Entity Relationship）：从 `DataModel` 节点生成
- **关键优势**：图和 XML 同源，XML 更新则图自动更新
**产物**：`docs/architecture/diagrams/` 下的 4 类图表
**视觉建议**：
- 左侧：`architecture.xml` 片段
- 中间：箭头 → "自动解析"
- 右侧：4 张 Mermaid 图预览（系统上下文、时序、数据流、ER）

---

### P18 Skill 9：生产就绪 — 从"能跑"到"能扛"
**页面标题**：devforge-ops-ready：生产环境不是"部署上去就行"  
**为什么需要**：
- AI 生成的代码往往只考虑"功能正确"，不考虑"运维可观测"
- 没有 Terraform / K8s 配置，手动部署易出错
- 没有监控和告警，故障发现靠用户投诉
**具体有什么用**：
- **Terraform**：网络、计算、数据库、缓存、存储模块
- **Kubernetes**：Kustomize 多环境（base + dev/staging/prod overlays）
- **监控**：Prometheus RED 指标 + Grafana 仪表盘
- **渐进部署**：蓝绿部署 + 金丝雀发布（含提升/回滚策略）
- **运维手册**：`docs/ops/runbook.md`
**v1.4 新增微服务基础设施**：
- **Istio Service Mesh**：VirtualService、DestinationRule、Gateway
- **OpenTelemetry**：Collector + Jaeger 链路追踪
- **Vault**：动态密钥、策略管理
- **Network Policies**：零信任网络安全
**产物**：`infrastructure/` 完整目录树 + `docs/ops/runbook.md`
**视觉建议**：
- 分层展示：Terraform（基础设施层）→ K8s（编排层）→ Istio（服务网格层）→ 监控（可观测层）
- 每层配图标和关键文件

---

### P19 Skill 10：调试助手 — 快速定位根因
**页面标题**：devforge-debug-assistant：Bug 不是终点，是改进的起点  
**为什么需要**：
- 测试失败时，堆栈信息不能告诉"为什么设计导致了这个问题"
- 生产事故需要关联架构决策，才能避免同类问题
- 重构需要评估风险，不能"重写再说"
**具体有什么用**：
- **Mode A - Bug 修复**：收集证据 → 根因分析 → 最小修复方案 → `DEBUG_REPORT.md`
- **Mode B - 重构建议**：代码健康扫描 → 改进机会识别 → `REFACTOR_REPORT.md`
- **Mode C - 生产事故诊断**：日志/指标/链路分析 → 根因定位
- 所有修复必须尊重 `INTERFACE_CONTRACT.md` 和 `StateModel`
**入口条件**：接受 `test_execution_completed` 作为入口（测试失败后直接调用）
**产物**：`DEBUG_REPORT.md` 或 `REFACTOR_REPORT.md`
**视觉建议**：
- 左侧：故障输入（测试失败 / 日志异常 / 代码异味）
- 中间：三个模式分支（Bug / 重构 / 事故）
- 右侧：报告输出

---

### P20 Skill 11：威胁建模 — 预判攻击而非被动防御（v1.4 新增）
**页面标题**：devforge-threat-modeling：STRIDE 方法论 + 风险评级矩阵  
**为什么需要**：
- security-audit 发现的是"已知漏洞"，威胁建模发现的是"未知攻击面"
- 安全设计应该在编码前完成，而非渗透测试后补丁
- 合规要求（如金融、医疗）需要结构化的威胁分析文档
**具体有什么用**：
- **STRIDE 六维分析**：
  - S（欺骗）— 身份伪造
  - T（篡改）— 数据修改
  - R（抵赖）— 不可否认性缺失
  - I（信息泄露）— 敏感数据暴露
  - D（拒绝服务）— 可用性攻击
  - E（权限提升）— 越权访问
- **风险评级**：可能性 × 影响 = Critical/High/Medium/Low
- **缓解方案**：技术控制 + 流程控制 + 补偿控制
- **安全测试用例**：将缓解措施转化为可测试需求
- 更新 `architecture.xml` 的 `Security/ThreatModel` 节点
**产物**：`THREAT_MODEL_REPORT.md` + 更新的 `architecture.xml` + `security.xml`
**视觉建议**：
- 中央：STRIDE 六边形，每个顶点一个威胁类别
- 周围：风险矩阵（4×4 网格）
- 底部：威胁 → 缓解 → 测试用例的转化链

---

### P21 Skill 12：数据管道 — 数据基础设施设计（v1.4 新增）
**页面标题**：devforge-data-pipeline：从 OLTP 到 OLAP 的完整数据链路  
**为什么需要**：
- 现代系统不仅是"增删改查"，还需要数据分析、报表、机器学习
- 数据管道设计错误会导致数据不一致、延迟、重复消费
- 没有数据血缘追踪，无法回答"这个数字从哪来"
**具体有什么用**：
- **数据流拓扑**：`dataflow.xml` — Source → Ingestion → Transform → Storage → Consumption
- **维度建模**：`schema-olap.sql` — 事实表、维度表、聚合表（星型/雪花模型）
- **ETL DAG**：Airflow / Prefect 任务依赖、重试策略、幂等性检查
- **数据质量规则**：行数增量、空值率、新鲜度、PII 扫描
- 自校验：无孤立节点、SQL 语法有效、无循环依赖
**产物**：`dataflow.xml` + `schema-olap.sql` + `dags/{id}.py` + `data-quality-rules.yaml`
**视觉建议**：
- 数据流管道图（Source → Ingest → Transform → Storage → Consume）
- 下方展示星型 schema 示例（事实表居中，维度表环绕）
- 右侧展示 Airflow DAG 代码片段

---

## Part 6：Evolve — 从交付到演进（P22-P26）

### P22 Skill 7：增量迭代规划 — 为什么"新需求"不等于"重新来"？
**页面标题**：devforge-iteration-planning：在已有框架上优雅生长  
**为什么需要**：
- 软件生命周期中，80% 的时间是维护而非初始开发
- 传统 AI 生成：新需求来了只能"重新描述"，已有代码无法被增量修改
- 没有影响分析，一个小改动可能破坏多个模块
**具体有什么用**：
- **范围验证**：对比新需求与 `STATE.md` 中的 **Immutable Goal**，超出范围则标记为"范围升级"
- **影响分析矩阵**：标注每个新需求影响的模块（新增 / 修改 / 无影响）和严重程度（breaking / additive / internal）
- **接口版本控制**：breaking 变更需升级接口版本号，additive 变更保持兼容
- **XML 同步**：系统级变更自动传播到模块级和组件级 XML
- **迭代后验证**：breaking changes 自动触发重新验证（3a/3b）
**产物**：`ITERATION_PRD.md` + `ITERATION_PLAN.md` + 更新的 XML + `VALIDATION_DELTA`
**视觉建议**：
- 左侧：一座已建好的建筑（已有系统）
- 右侧：新增楼层/房间（新模块）和改造房间（已有模块升级）
- 箭头标注："不拆承重墙，只做增量改造"

---

### P23 Skill 7：增量迭代工作流
**页面标题**：增量迭代 — 从"新需求"到"更新后的系统"  
**核心工作流（8 步）**：
1. 加载完整基线（全部产物 + STATE.md）
2. 范围验证（对比 Immutable Goal）
3. 影响分析（影响矩阵 + 严重程度：breaking / additive / internal）
4. 编写增量 PRD（只编写新增/变更 user stories，标注 `relates_to: US-XXX`）
5. 增量架构设计（新模块 → 完整 module-design；修改模块 → 更新 XML，保持接口版本兼容）
6. XML 同步（系统级 → 模块级 → 组件级约束自动传播）
7. 接口版本控制（breaking → 升主版本；additive → 升次版本）
8. 生成 `ITERATION_PLAN.md`（执行顺序、涉及模块、回滚标准）+ 人类门控 `[APPROVE / MODIFY / REJECT]`
**视觉建议**：
- 左侧流程图，步骤 2（影响矩阵）和 6（XML 同步）用高亮框标注
- 右侧展示影响矩阵示例（模块 × 需求，格子标注新增/修改/无影响 + breaking/additive）

---

### P24 增量场景演示：两个月后要加支付模块
**页面标题**：一个完整的增量迭代故事  
**故事线**：
1. **起点**：系统已有 UserService + OrderService（Iteration 0 已完成，STATE.md 中 Module Registry 记录状态）
2. **新需求**：新增 PaymentService + 用户资料扩展
3. **Iteration 1 启动**：调用 `devforge-iteration-planning`
4. **影响分析**：
   - PaymentService：**新增模块**（走完整 module-design + scaffolding）
   - UserService：**修改模块**（additive：新增 `profile` 字段，接口版本 1.0.0 → 1.1.0）
   - OrderService：无影响
5. **XML 同步**：`architecture.xml` 新增 PaymentService 节点 → 自动生成 `modules/PaymentService/module-architecture.xml` 模板
6. **执行**：按 ITERATION_PLAN.md 逐个模块实施，走 `[APPROVE]` 门控
7. **验证**：完成后自动触发 `[VALIDATE]` 检查接口兼容性
8. **完成**：STATE.md 更新 Iteration History，Module Registry 新增 PaymentService 记录
**视觉建议**：
- 时间轴从左到右
- 起点（已有建筑）→ 触发（红色闪电）→ 分析（影响矩阵）→ 实施（新增绿色 + 修改黄色）→ 验证（检查图标）→ 完成（STATE.md 更新）

---

### P25 数据管道作为数据基础设施的演进
**页面标题**：数据管道 — 增量迭代中的数据视角（v1.4）  
**核心内容**：
- 当系统从"业务系统"演进为"数据驱动系统"时，需要专门的数据基础设施
- `devforge-data-pipeline` 不是替代 `devforge-iteration-planning`，而是**在迭代中叠加数据能力**
- 典型触发场景：
  - "我们需要用户行为分析报表"
  - "需要接入实时数据流做推荐"
  - "现有数据库性能不够，需要 OLAP"
- 与核心迭代的协作：数据流拓扑（`dataflow.xml`）引用 `architecture.xml` 的模块定义，确保数据管道和业务系统同源
**视觉建议**：
- 上方：业务系统迭代（已有的 7 步流程）
- 下方：数据管道叠加（`[DATA_PIPELINE]` 触发）
- 中间：共享 `architecture.xml` 和 `STATE.md`

---

## Part 7：支撑体系 — 让 12 个 Skill 协同运转（P26-P30）

### P26 领域扩展机制 — 6 个扩展按需加载
**页面标题**：当项目遇上 AI Agent / 前端 UI / 可观测性 / 性能测试  
**核心内容**：
- **触发机制**：`devforge-architecture-design` 检测到 PRD 特征标签时，动态加载对应扩展
- **6 个扩展**（v1.4 从 3 个扩展到 6 个）：
  1. **ai-agent-design**：Tool Latency、Context Window Efficiency、Memory Integration + 10 个 AI 反模式
  2. **data-pipeline-design**：Schema Evolution、Idempotency、Backpressure、Data Lineage（参考级）
  3. **mobile-app-design**：Offline Support、Battery Efficiency、Push Delivery
  4. **frontend-ui-system-design（v1.4 P1 新增）**：组件分层、设计系统、性能预算（LCP/FID/CLS）
  5. **observability-engineering（v1.4 P1 新增）**：SLO/SLI 定义、结构化日志、分级告警、值班表
  6. **performance-testing（v1.4 P1 新增）**：k6/Artillery 负载测试、基线配置、CI 回归检测
- **特征标签驱动**：`ui-heavy` → 加载 frontend；`high-observability` → 加载 observability；`performance-critical` → 加载 performance-testing
- **overlay 机制**：扩展评估维度与基础模式库叠加，不替换原有评估
**视觉建议**：
- 中央：基础架构设计 skill 的图标
- 六个方向延伸出扩展卡片，每个卡片有触发标签 + 新增维度列表
- 卡片与中央用虚线连接，表示"动态加载"
- 底部小字："10 种基础模式 + 6 个领域扩展 = 按需组合的评估体系"

---

### P27 STATE.md 16 分类 — 跨 Session 推理链锚点
**页面标题**：STATE.md：从 4 分类（v1.0）到 16 分类（v1.4）  
**核心内容**：
16 个 section 的设计逻辑：
| 分类 | 类型 | 作用 |
|------|------|------|
| Immutable Goal | 永不覆盖 | 原始产品想法 + 成功指标 + Scope 边界 |
| Completed Steps | 追加 | 12 个 skill 的执行记录 |
| DecisionDigest | 追加（最近 20 条） | 关键决策一句话摘要 |
| Current State | 覆盖 | phase、DIVE 进度、NextAction |
| Quality Gates | 覆盖 | 可配置阈值（覆盖率、性能、安全） |
| Module Registry | 追加 | 每个模块状态 + 接口版本 + 50 字微摘要 |
| Iteration History | 追加 | 所有迭代记录 |
| Compressed Context | 覆盖 | 200 字摘要，跨 session 快速恢复 |
| Artifact Index | 追加 | 所有产物的快速索引表 |
| Characteristic Tags（v1.4 新增） | 覆盖 | 项目特征标签，驱动扩展加载 |
| Loaded Extensions（v1.4 新增） | 覆盖 | 已加载的领域扩展列表 |
| Security Posture（v1.4 新增） | 追加 | 安全态势摘要（漏洞数、风险等级） |
| Data Pipeline Status（v1.4 新增） | 覆盖 | 数据管道状态（如有） |
| Known Pitfalls & Risks | 追加 | 风险沉淀 |
| Error Log | 追加 | 按 error-tracing.md 格式的错误记录 |
| Intervention Log | 追加 | 每次人类干预的记录 |
**路径**：`PROJECT_SCAFFOLD/docs/architecture/system/STATE.md`
**视觉建议**：
- 一个打开的笔记本，16 个分区用不同颜色标注
- 分区按功能分组：锚定类（绿色）、追踪类（蓝色）、状态类（橙色）、扩展类（紫色）
- 新增分区（v1.4）用闪烁/高亮效果

---

### P28 上下文压缩 — 200 字恢复 5 天前的 session
**页面标题**：context-compression：跨 Session 快速恢复  
**核心内容**：
- **问题**：12 个 skill 跑完后，session 上下文非常长，下次如何快速接续？
- **解决方案**：每个 skill 完成后**自动调用** `context-compression`，提取关键信息：
  - Top 3 决策（DecisionID + What + Why + Risk）
  - Top 2 风险或陷阱
  - 当前 phase 和 NextAction（iterate / refactor / module / none）
- **产物**：`STATE.md` 的 `Compressed Context` 字段（200 字以内）
- **使用场景**：用户 5 天后回来，只需读这 200 字 + 当前的 `NextAction`，即可知道该调用哪个 skill
- **三层加载策略**：
  - Level 1：200 字全局摘要
  - Level 2：50 字模块微摘要（Module Registry digest）
  - Level 3：1 行决策索引（DecisionDigest）
- **Token 阈值**：>50k 时 Optional 产物加载摘要；>150k 时只加载 2 个最关键的 Required 产物
**视觉建议**：
- 左侧：一本厚厚的书（全部历史产物）
- 中间：压缩机图标（标注 "context-compression"）
- 右侧：一张小卡片（200 字摘要示例）
- 箭头标注："12 个 skill 全部产物 → 200 字摘要 → 5 秒恢复上下文"

---

### P29 产物地图 — 从想法到部署，每一步留下什么？
**页面标题**：完整产物地图：20+ 项产物 + 三层 XML 引用链  
**产物表格**（v1.4 完整版，20 项）：
| 产物 | 路径 | 由谁产出 | 作用 |
|------|------|---------|------|
| PRD | `docs/architecture/system/PRD.md` | Skill 1 | 需求源头 |
| RTM | `docs/architecture/system/RTM.md` | Skill 1 | 需求追溯矩阵 |
| Decision Log | `docs/architecture/system/DECISION_LOG.md` | 全部 Skill | 完整推理链 |
| Interface Contract | `docs/architecture/system/INTERFACE_CONTRACT.md` | Skill 2 | I/O 边界定义 |
| Architecture Design | `docs/architecture/system/ARCHITECTURE.md` | Skill 2 | 设计摘要 |
| Architecture XML（系统级） | `docs/architecture/system/architecture.xml` | Skill 2 | 模块 + 接口 + DecisionTrace + Security |
| Schema DDL | `docs/architecture/system/schema.sql` | Skill 2 | 数据库 Schema |
| OpenAPI Spec | `docs/architecture/system/openapi.yaml` | Skill 2 | API 规范 |
| Module Architecture XML | `docs/architecture/modules/{id}/module-architecture.xml` | Skill 5 | 组件分解 + 组件接口 |
| Component Spec XML | `docs/architecture/modules/{id}/components/{cid}/component-spec.xml` | Skill 5 | 函数签名 + 错误处理 + 代码模板 |
| Validation Report | `docs/architecture/validation/VALIDATION_REPORT.md` | Skill 3a | 技术自洽性 |
| Validation Delta | `docs/architecture/validation/VALIDATION_DELTA_*.md` | Skill 3a | 增量对比 |
| Design Review | `docs/architecture/validation/DESIGN_REVIEW.md` | Skill 3b | 问题清单 |
| Security Audit Report | `docs/architecture/validation/SECURITY_AUDIT_REPORT.md` | Skill 3c | 风险等级 + 修复 patch |
| Threat Model Report | `docs/architecture/validation/THREAT_MODEL_REPORT.md` | Skill 11 | STRIDE 威胁矩阵 |
| Test Report | `docs/architecture/validation/TEST_REPORT.md` | Skill 6 | 测试结果 + 覆盖率 |
| Coverage Gap | `docs/architecture/validation/TEST_COVERAGE_GAP.md` | Skill 6 | 未覆盖路径 |
| Iteration PRD | `docs/architecture/system/ITERATION_PRD.md` | Skill 7 | 增量需求 |
| Iteration Plan | `docs/architecture/system/ITERATION_PLAN.md` | Skill 7 | 执行顺序 + 回滚标准 |
| Dataflow XML | `docs/architecture/system/dataflow.xml` | Skill 12 | 数据管道拓扑 |
| OLAP Schema | `docs/architecture/system/schema-olap.sql` | Skill 12 | 维度模型 |
| Scaffold | `PROJECT_SCAFFOLD/` | Skill 4 | 完整可运行项目 |
| ADR | `PROJECT_SCAFFOLD/docs/ADR.md` | Skill 4 | 架构决策记录 |
**视觉建议**：
- 横向流程图，12 个阶段从左到右排列
- 每个阶段下方对齐其产物，产物用文件图标表示
- 产物之间有连线表示引用关系
- 底部独立展示三层 XML 树状图

---

### P30 使用流程：双轨对比
**页面标题**：初始开发 vs 增量迭代 — 两条轨道，同一套规则  
**左侧：初始开发（7 步）**：
1. `devforge-requirement-analysis` → 输入产品想法 → 输出 PRD → `[APPROVE]`
2. `devforge-architecture-design` → 读取 PRD + STATE + DECISION_LOG → 输出架构 + XML → `[APPROVE]`
3. `devforge-architecture-validation` + `devforge-design-review` + `devforge-security-audit` → 三重验证 → `[APPROVE / FIX]`
4. `devforge-project-scaffolding` → 读取全部历史 → 输出项目 → `[APPROVE]`
5. `devforge-module-design`（按需，每个模块 / 批量）→ 模块细化 → `[APPROVE / NEXT MODULE]`
6. `devforge-test-execution` → `[TEST]` → 测试报告 → `[APPROVE / DEBUG]`
7. 结束，`NextAction: none`，或按需触发可视化/运维/调试

**右侧：增量迭代（3-4 步）**：
1. `devforge-iteration-planning` → 新需求 → 影响分析 + ITERATION_PLAN → `[APPROVE]`
2. `devforge-module-design`（新模块）或 `devforge-architecture-design`（架构变更）→ `[APPROVE]`
3. `devforge-project-scaffolding` → 生成/更新代码 → `[APPROVE]`
4. `devforge-test-execution` → 验证变更 → `[APPROVE]`

**中间共用红线（3 条）**：
1. 每个 skill 启动时**读取 STATE.md + 全部历史产物**
2. 每个 skill 结束前**更新 STATE.md**（追加 Completed Steps + Known Pitfalls + DecisionDigest）
3. **禁止自动跳转**，必须等待人类 `[APPROVE]`
**视觉建议**：
- 左右双轨铁路图
- 左侧轨道较长（7 站），右侧轨道较短（4 站）
- 两轨在底部汇入同一个"STATE.md 状态管理"枢纽
- 每个站点配一个红色闸门图标 `[APPROVE]`
- 可选阶段用虚线框，推荐阶段用实线框

---

## Part 8：总结与展望（P31-P35）

### P31 VCMF 5 原则回顾
**页面标题**：v1.4 的 5 条不变原则  
**内容（5 个卡片）**：
1. 🔗 **Design as Contract** — 代码必须服从文档，每个产物必须可追溯回需求或设计决策
2. 💾 **Interface as Boundary** — 任何跨模块或跨层调用必须有显式输入/输出 Schema 和错误契约
3. 🔍 **Reality as Baseline** — Mock 测试验证流程；真实环境验证功能；语义敏感点必须用真实 LLM 测试
4. 🛡️ **State as Responsibility** — 谁创建、谁持久化、谁读取、谁清理状态必须文档化并强制执行
5. 📄 **XML as Authority** — `component-spec.xml` 是代码生成的单一起源。函数签名、错误处理、文件路径必须匹配 XML 规格，CI 自动检查一致性
**v1.4 演进**：
- 第 5 条从"仅限代码生成"扩展到"数据管道 also 以 dataflow.xml 为权威"
**视觉建议**：
- 5 个彩色方块横向排列
- 每个方块内：大图标 + 原则标题 + 一行解释
- 第 5 个方块用特别强调色（金色边框），内部展示：XML 文件 → 箭头 → 代码文件
- 底部小字：来源 — VCMF (Vibe Coding Maturity Framework)

---

### P32 版本演进：v1.0 → v1.4 的能力增长
**页面标题**：从 5 个 Skill 到 12 个阶段 + 6 个扩展  
**时间轴**：
| 版本 | 关键能力 | Skill 数 |
|------|---------|---------|
| v1.0 | 基础 SDLC：需求 → 架构 → 验证 → 审查 → 脚手架 | 5 |
| v1.1 | 三层 XML、模块设计、增量迭代、上下文压缩、3 个扩展 | 7 + 3 |
| v1.2 | 可视化、生产就绪、调试助手、数据库/OpenAPI、RTM | 10 + 3 |
| v1.3 | 三重验证、测试执行、批量模块设计、FIX 子流程、质量门控 | 12 + 3 |
| v1.4 | 威胁建模、数据管道、微服务基础设施、3 个新扩展、安全自动修复 | 14 + 6 |
**核心逻辑**：
- 每个版本增加的不是"更多功能"，而是"更完整的工程闭环"
- v1.0-1.1：从 0 搭建的闭环
- v1.2-1.3：生产就绪的闭环
- v1.4：安全与数据基础设施的闭环
**视觉建议**：
- 水平时间轴，5 个版本节点
- 每个节点配关键图标和数字
- 曲线向上，表示能力增长

---

### P33 关键数字
**页面标题**：DevForge v1.4 的关键数字  
**核心数字（8 个卡片）**：
- **12** 个阶段 = 从需求到数据管道的完整链路
- **14** 个 Skill = 同一思考者的 14 次展开（12 核心 + context-compression + security-audit）
- **10** 种架构模式动态筛选
- **3** 层 XML 架构（系统 / 模块 / 组件）
- **4** 个验证视角（技术自洽 / 对抗审查 / 安全扫描 / 威胁建模）
- **16** 分类 STATE.md 推理锚点
- **6** 个领域扩展（AI Agent / 数据管道 / 移动应用 / 前端 UI / 可观测性 / 性能测试）
- **0** 个角色边界（无 PM / 架构师 / QA 标签 — 同一思考者）
**视觉建议**：
- 2 行 × 4 列卡片网格
- 每个卡片：大号数字 + 标题 + 一行解释
- 深色背景 + 高对比度数字

---

### P34 一句话总结
**页面标题**：DevForge 是什么？  
**核心句（大字居中）**：
> 最好的 AI 工程系统，不像一次性代码生成器。它更像一个思考者的多次草稿 —— 同一个大脑，在 Design、Implement、Verify、Evolve 四个维度上反复展开推理，最终交付一个可演进、可验证、可运维的系统。
**下方三行补充**：
- 不是生成代码，而是**管理复杂度**
- 不是替代工程师，而是**放大工程师的判断力**
- 不是一次性的，而是**持续演进的**
**视觉建议**：
- 深色背景 + 白色大字引用
- 底部三行用渐变色区分（蓝 → 绿 → 紫）

---

### P35 Q&A + 下一步行动
**页面标题**：开始使用 DevForge  
**内容**：
- **一键安装**：
  ```bash
  curl -sSL https://raw.githubusercontent.com/lzj2819/DevForge-skill/main/install.sh | bash
  ```
- **第一步**：在 Claude Code 中输入 `我想做一个 [你的产品想法]`
- **完整文档**：`README.md` | `devforge-design.md` | `devforge-state.md`
- **快速体验**：`examples/quickstart-todo-app.md`（10 分钟从想法到可运行项目）
- **GitHub**：https://github.com/lzj2819/DevForge-skill
**视觉建议**：
- 中央：安装命令代码块（带语法高亮）
- 下方：文档链接和 GitHub 二维码
- 底部："Q&A" 和 "感谢聆听"

---

## 附录：演讲者备注

### 时间分配建议（75-90 分钟演讲）
- P1-P4（开场与问题）：10 分钟
- P5-P10（Design 阶段）：18 分钟（每个 Skill 平均 3 分钟）
- P11-P15（Implement 阶段）：12 分钟
- P16-P18（Verify 测试执行）：8 分钟
- P19-P24（可选增强 + Evolve）：15 分钟
- P25-P30（支撑体系）：10 分钟
- P31-P35（总结与 Q&A）：7 分钟
- Q&A：5-10 分钟

### 重点强调页
- **P3**：一定要讲透"没有架构约束的代码 = 技术债务加速器"，这是整个设计的动机
- **P7**：三层 XML 是 DevForge 最核心的架构创新，用"代码围着文档转"帮助听众建立直觉
- **P8-P9**：三重验证是最容易混淆的概念，必须用"编译器 / 代码审查 / 渗透测试 / 威胁情报"的类比讲清楚
- **P11-P12**：脚手架和模块设计的分工 — 脚手架做基础设施，模块设计做精确代码骨架
- **P14**：测试执行是 v1.3 新增，强调"生成测试 ≠ 执行测试"
- **P18**：ops-ready 的 v1.4 微服务增强（Istio/OTel/Vault）是生产级系统的关键
- **P20-P21**：威胁建模和数据管道是 v1.4 的两个全新能力，说明它们填补了哪些空白
- **P26**：6 个领域扩展展示了 DevForge 的扩展性，不是封闭系统
- **P27**：STATE.md 16 分类是跨 session 连续性的关键
- **P32**：版本演进图展示项目的持续迭代能力

### 视觉风格建议
- **主色调**：午夜蓝（#1E2761）+ 冰蓝（#CADCFC）+ 白色文字，强调色用珊瑚橙（#F96167）
- **DIVE 四阶段配色**：Design(蓝 #065A82) / Implement(绿 #2C5F2D) / Verify(橙 #B85042) / Evolve(紫 #6D2E46)
- 核心内容页采用"问题 → 方案"或"为什么 → 做什么"的叙事结构
- 重点内容用强调色标注，方便听众快速识别
- 图标风格统一：使用扁平化图标，避免 3D 效果
- 字体：标题用无衬线粗体（Microsoft YaHei Bold），正文用常规体
- 每页必须有视觉元素（图、表、图标、代码块），禁止纯文字页
