# SDLC Skill Chain v1.1 PPT 内容大纲

> 基于 `E:\pythonproject\vclaw\vclaw\1.0.1\skill` v1.1 全部内容设计
> 结构：问题-解决方案叙事（Problem-Solution Narrative）+ 增量迭代独立章节
> 总页数：26 页
> 演讲时长：60 分钟

---

## Part 1：故事线铺垫（P1-P4）

### P1 封面
**页面标题**：SDLC Skill Chain **v1.1** — 从"角色接力"到"思考者草稿"  
**副标题**：基于 VCMF 与 DIVE 方法论的 AI 驱动软件开发生命周期  
**新增副标题行**：**三层 XML 架构 · 增量迭代 · 领域扩展**  
**视觉建议**：
- 深色背景（深蓝或深灰）
- 左侧放置 DIVE 循环图：Design → Implement → Verify → Evolve（环形箭头）
- 右侧大号白色标题文字
- 右下角新增小标签："v1.1 | 7 Skills + 3 Extensions"
- 底部小字：VClaw Project | 2026

---

### P2 议程
**页面标题**：今天讲什么  
**内容要点**（从 5 条扩展为 8 条）：
1. 一个流行的陷阱：多 Agent "角色接力赛"
2. 我们的答案：Single Thinker 迭代模型
3. **7** 次展开：从需求到模块细化的完整技能链
4. 推理锚点：让上下文永不丢失
5. **新增**：三层 XML 架构 — 代码围着文档转
6. **新增**：增量迭代 — 需求变更时不推翻重来
7. **新增**：领域扩展 — AI Agent / 数据管道 / 移动应用
8. 产物地图与使用方式
**视觉建议**：
- 左侧竖线时间轴，8 个节点
- 右侧每个节点配一个图标和一行文字
- 新增的三个节点（5/6/7）用高亮色区分

---

### P3 问题：传统多 Agent 的"三省六部"陷阱
**页面标题**：为什么"产品经理 → 架构师 → 开发 → 测试"在 AI 时代是错的？  
**核心内容**：
- **角色扮演制造假边界**
  - Agent 被框死在角色里，看到职责外的问题直接跳过
  - 最有价值的推理往往发生在边界上，但流水线模式封死了这个可能
- **信息在流转中死亡**
  - 每次交接传递的是压缩结论，不是推理过程
  - 原始意图衰减，隐含假设丢失，误差累积
- **最终输出"局部正确但整体漂移"**
  - 每个节点看起来合理，但整体已偏离最初目标
- **大厂都不这么做**
  - Anthropic / OpenAI / Google 三家没有一家采用"角色分工"模式
**微调（v1.1）**：
- 底部红字增加钩子："你得到的是一个模拟公司行为的系统，而不是一个**能持续演化**的系统"
**视觉建议**：
- 画一条水平流水线
- 4 个工位图标：PM（需求）→ 架构师（设计）→ 开发（代码）→ QA（测试）
- 工位之间箭头标注"信息衰减"，箭头逐渐变细/变灰
- 最右端输出一个歪斜/破损的产品图标
- 底部一行红字

---

### P4 我们的答案：Single Thinker 模型
**页面标题**：最好的多 Agent 系统，不像公司，像一个思考者的多次草稿  
**核心内容**：
- **同一思考者**：**7** 个 skill 是同一个大脑面对同一问题的 **7** 次展开
- **完整上下文**：每个 skill 读取**全部历史产物**，而非仅上一阶段的结论
- **推理链外化**：不依赖模型记忆，靠显式状态文件锚定
- **对抗性检验**：验证 Agent 专门找问题，不"接棒继续做"
- **新增（v1.1）**：**增量演化** — 不仅能从 0 搭建，还能在已有框架上持续生长
**视觉建议**：
- 中央一个大脑图标
- 向外辐射 **7** 条光线（不同颜色），光线末端分别是 7 个 skill 的简化图标
- 前 5 条光线（初始开发）用暖色，后 2 条（module-design + iteration-planning）用冷色
- 光线标注"完整上下文流动"（双向箭头）
- 底部引用：`"同一个大脑，在不同维度上展开推理，最终合并成一个连贯的结论"`

---

## Part 2：初始开发完整链路（P5-P16）

### P5 Skill 1：需求分析 — 锁定目标与边界
**页面标题**：sdlc-requirement-analysis：锁定目标与边界  
**核心内容**：
- 同一思考者**亲自初始化**推理锚点（STATE.md Immutable Goal）
- 通过 3-5 个针对性问题补全上下文，防止信息衰减
- 同时**播种决策日志**（DECISION_LOG.md），防止后续阶段漂移
- **领域标签提取**：从用户描述中提取项目特征标签（`ai_agent`、`event_driven` 等），为后续动态架构模式筛选做准备

**VCMF 检查点**：
- Design as Contract：闭环指标与 Scope 边界
- Interface as Boundary：跨模块交互点识别
- Reality as Baseline：可观测、可测试的验收标准
- State as Responsibility：业务状态所有者文档化
**视觉建议**：
- 中央展示思考者图标，周围环绕 STATE.md 和 PRD 两个文件，有连线相连
- 底部标注："同一思考者，亲自播种推理锚点"

---

### P6 Skill 1：工作流与产物
**页面标题**：需求分析 — 工作流与产物  
**核心工作流（8 步）**：
1. 方法论对齐（四维推演：Why / What / How / Modules）
2. **状态初始化**（读取/创建 STATE.md，写入 Immutable Goal）
3. 上下文补全（3-5 个针对性问题）
4. **领域标签提取与特征分析** ← v1.1 新增
5. 跨模块交互点识别
6. PRD 生成 + 决策日志播种
7. **状态更新**（追加 Completed Steps）
8. 人类门控 `[APPROVE]`
**产物**：
- `skill/artifacts/PRD.md`
- `skill/artifacts/DECISION_LOG.md`（初始）
**视觉建议**：
- 左侧垂直流程图，8 个步骤用箭头连接
- 步骤 2 和 6 用高亮框标注（STATE.md 交互）
- 步骤 4 用新增色标注
- 右侧两个产物文件图标，配简短说明

---

### P7 Skill 2：架构设计 — 并行探索技术路径
**页面标题**：sdlc-architecture-design：并行探索技术路径  
**核心内容**：
- **10 种架构模式动态筛选**：从模式库中根据领域标签筛选最相关的 4-6 种进行评估，防止上下文爆炸
- **三层 XML 架构**：系统级（`architecture.xml`）→ 模块级（`module-architecture.xml`）→ 组件级（`component-spec.xml`）
- **推理外化**：XML 新增 `<DecisionTrace>` 节点，记录每个架构决策的 Question、Answer、Risk
- **领域扩展 overlay**：检测到 `ai_agent`/`data_pipeline`/`mobile_app` 等标签时，自动加载对应领域的额外评估维度和反模式

**10 种并行评估的架构模式**：
1. Layered（分层）
2. Hexagonal（六边形/端口适配器）
3. Event-Driven（事件驱动）
4. Microservice（微服务）
5. Client-Server（客户端-服务器）
6. Plugin-Based（插件化）
7. **CQRS**（命令查询职责分离）← v1.1 新增
8. **BFF**（Backend for Frontend）← v1.1 新增
9. **Serverless/FaaS**（无服务器函数）← v1.1 新增
10. **Micro-Frontends**（微前端）← v1.1 新增
**视觉建议**：
- 中央展示动态筛选漏斗：10 种模式输入 → 根据领域标签筛选 → 4-6 种模式进入评分矩阵
- 评分矩阵示意：4-6 行（筛选后的架构）× 5 列（评估维度），某一行高亮（推荐方案）
- 底部展示三层 XML 树状结构预览（system → module → component）

---

### P8 Skill 2：工作流与产物
**页面标题**：架构设计 — 工作流与产物  
**核心工作流（10 步）**：
1. **动态模式筛选**（根据领域标签从 10 种中筛选 4-6 种）← v1.1 更新
2. 并行探索 + 评分（orchestrator-worker 模式）
3. 接口契约设计（输入/输出/错误码）
4. 状态所有权映射（谁创建/写入/读取/清理）
5. 测试用例设计（happy + abnormal + NFR）
6. **三层 XML 建模**（系统级 + 模块级模板 + 组件级模板）← v1.1 更新
7. 架构文档编写
8. 决策日志更新（含完整推理链 + DecisionTrace）
9. 状态更新（追加 Completed Steps + Known Pitfalls）
10. 人类门控 `[APPROVE]`
**产物**：
- `skill/artifacts/ARCHITECTURE.md`
- `skill/artifacts/INTERFACE_CONTRACT.md`
- `skill/artifacts/architecture.xml`（含 DecisionTrace 和 ModuleDetail 引用）
- **新增产物**：`references/architecture-patterns.md`（10 种模式库）、`references/xml-schemas.md`（Schema 定义）
**视觉建议**：
- 左侧流程图，步骤 1 和 6 高亮
- 右侧 3 个产物文件图标 + 2 个 reference 文件图标
- XML 结构预览（三层树状图：system → module → component）

---

### P9 Skill 3：技术验证 — 可选检查点
**页面标题**：sdlc-architecture-validation：技术一致性检查  
**核心内容**：
- **收窄职责**：只做技术自洽性检查，不做全面 QA 测试
- 安全/错误/工具选择验证 → **移交给 design-review** 处理
- 产出技术验证报告，**不控制是否进入下一阶段**
- **VALIDATION_DELTA**：对比上次验证结果，只报告新增/已解决的问题

**核心工作流（11 步）**：
1. API 就绪检查
2. XML vs Interface Contract 一致性
3. XML vs PRD 一致性（防孤儿模块）
4. Mock 注入 + 模块级模拟
5. Real-LLM 格式验证（仅 schema 合规）
6. 推演打印（Trace Logging）
7. 自修复循环（失败则 `[RETRY]`）
8. **生成 VALIDATION_DELTA.md** ← v1.1 新增
9. 健康检查脚本生成
10. 状态更新
11. 人类门控 `[APPROVE]`
**产物**：
- `VALIDATION_REPORT.md`
- **VALIDATION_DELTA.md** ← v1.1 新增
- `health-check.sh`
**视觉建议**：
- 中央展示显微镜图标，聚焦技术细节检查
- 旁边放置"对比报告"小图标（VALIDATION_DELTA）
- 底部标注："收窄职责，只做技术自洽性检查"

---

### P10 Skill 3 vs Skill 4：验证与审查，为什么分开？
**页面标题**：验证是"检查自洽"，审查是"专门挑刺"  
**对比表格**：
| 维度 | sdlc-architecture-validation | sdlc-design-review |
|------|------------------------------|-------------------|
| 核心问题 | "架构文档是否自洽？" | "设计是否有漏洞？" |
| 方法 | 一致性检查、Mock 模拟、拓扑连通 | 攻击者/维护者/扩展者三视角 |
| 输出 | PASS/FAIL + 验证报告 + **增量对比报告** | **问题清单**（无 PASS/FAIL） |
| 角色定位 | 技术审计员 | **红队（Red Team）** |
| 是否控制流程 | 是（失败则阻塞） | **否**（只提供问题，用户决策） |
**视觉建议**：
- 左右对比两栏
- 左侧蓝色背景（冷静检查），右侧红色背景（对抗挑刺）
- 中间竖线分隔，上方大字："分工 ≠ 分阶段，而是分职责"

---

### P11 Skill 4：设计审查 — 对抗性检验（Red Team）
**页面标题**：sdlc-design-review：对抗性检验（Red Team）  
**核心理念**：
- **唯一任务是找问题**，不是"接棒继续做"
- **不产出 PASS/FAIL**，产出问题清单供用户决策
- 三个独立视角审视：
**攻击者视角（Security & Robustness）**：
- 输入边界验证？竞态条件？依赖故障降级？单点故障？加密？
**维护者视角（Operability & Debuggability）**：
- 根因定位？日志覆盖？配置热更新？测试覆盖？文档同步？
**扩展者视角（Scalability & Evolvability）**：
- 10x 扩容瓶颈？功能新增成本？向后兼容？状态所有权清晰？
- **新增（v1.1）**：接口版本升级时是否保持兼容？breaking 变更是否有版本号升级？
**视觉建议**：
- 中央一个盾牌图标，表面有裂纹
- 三支箭从三个方向射入盾牌，分别标注：
  - 🔴 Attacker（攻击者）
  - 🟡 Operator（维护者）
  - 🟢 Extender（扩展者）
- 盾牌下方散落问题清单卡片

---

### P12 Skill 4：工作流与产物
**页面标题**：设计审查 — 工作流与产物  
**核心工作流（8 步）**：
1. 读取**全部历史产物**（PRD / STATE / DECISION_LOG / ARCHITECTURE / XML / INTERFACE）
2. 攻击者视角检查
3. 维护者视角检查
4. 扩展者视角检查（含向后兼容性检查）
5. 整合问题清单（4 级分类）
6. 交叉引用到 DECISION_LOG 的架构决策
7. 更新 STATE.md Known Pitfalls
8. 人类门控 `[APPROVE / FIX <id>]`
**问题清单 4 级分类**：
| 级别 | 含义 | 处理策略 |
|------|------|---------|
| 🔴 Must Fix | 致命缺陷，会导致系统故障或安全漏洞 | 必须修复 |
| 🟡 Should Fix | 高风险，应在生产环境前解决 | 强烈建议修复 |
| 🟢 Nice to Fix | 低风险改进 | 可选 |
| ⚪ Documented Risks | 已认知并接受的风险 | 记录并监控 |
**产物**：`skill/artifacts/DESIGN_REVIEW.md`（纯问题清单，无 PASS/FAIL）
**视觉建议**：
- 左侧流程图，3 个视角用不同颜色标注
- 右侧问题清单表格预览（4 行示例数据，每行不同颜色）

---

### P13 Skill 5：项目脚手架 — 携带完整上下文落地为代码
**页面标题**：sdlc-project-scaffolding：携带完整上下文落地为代码  
**核心内容**：
- 读取**全部历史产物**（包括 DESIGN_REVIEW 问题清单），携带完整上下文落地为代码
- 每个核心模块头部携带**推理链注释**（关联架构决策 ID + 为什么存在 + 已知风险）
- DESIGN_REVIEW 的 Must Fix / Should Fix 自动转为**内联 TODO**
- 生成 **ADR（架构决策记录）**作为代码库中的持久推理锚点
- **XML 驱动代码生成**：函数签名、错误码、文件路径**必须与 component-spec.xml 一致**
- 架构 XML 自动复制到 `docs/architecture/`，生成 `.gitattributes`
- **新增 `architecture-check` CI job**：运行 `xml-sync.py --verify-only` 确保代码与 XML 同步

**视觉建议**：
- 中央展示工人手持完整历史卷轴（PRD + XML + Design Review）
- 代码区域出现注释和 TODO 标记
- 旁边有 XML → 代码的箭头示意图，标注"XML 驱动代码生成"

---

### P14 Skill 5：工作流与产物
**页面标题**：项目脚手架 — 工作流与产物  
**核心工作流（关键步骤）**：
1. 读取全部历史产物（8+ 个文件）
2. 轻量规划
3. 目录树 + 依赖配置
4. **XML 驱动代码骨架生成**（匹配 component-spec.xml 的 Signature / ErrorHandling / FilePath）← v1.1 更新
5. **代码推理注释** + 内联 TODO
6. 部署拓扑 + **架构产物同步到 `docs/architecture/`** ← v1.1 更新
7. CI/CD（**新增 `architecture-check` job**）← v1.1 更新
8. 测试夹具（mock / real / e2e）
9. **ADR 生成**
10. 决策日志 + CHANGELOG
11. 内部验证
12. **回溯验证**（抽查 3-5 个文件的可追溯性 + **XML ↔ 代码一致性**）← v1.1 更新
13. 人类门控 `[APPROVE]`
**产物**：
- `skill/artifacts/PROJECT_SCAFFOLD/`（完整可运行项目）
- `PROJECT_SCAFFOLD/docs/ADR.md`
- `PROJECT_SCAFFOLD/docs/sync-rules.md`
- `PROJECT_SCAFFOLD/CHANGELOG.md`
- `PROJECT_SCAFFOLD/.env.template`
- **新增**：`scripts/architecture-ci.sh`（CI 健康检查）
- **新增**：`scripts/xml-sync.py`（XML 同步与验证）
**视觉建议**：
- 左侧流程图，步骤 4、6、7、12 高亮（v1.1 更新点）
- 右侧产物树状图（PROJECT_SCAFFOLD 目录结构展开）

---

### P15 Skill 6（新增）：模块细化设计 — 从系统到组件
**页面标题**：sdlc-module-design：从模块架构到组件契约  
**核心内容**：
- **触发条件**：用户输入 `[MODULE {module_id}]`，系统级架构已批准
- **锁定模块边界**：从 `architecture.xml` 中提取该模块的接口契约、耦合依赖和状态责任
- **模块级需求分析**：从 PRD 中筛选涉及该模块的 user stories，拆解为 1-3 个模块级 user stories
- **组件分解**：将模块拆分为 3-6 个内部组件（entry_point / domain_service / repository / utility / gateway）
- **组件接口设计**：显式定义方法名、输入/输出 Schema、错误码
- **两层 XML 产出**：`module-architecture.xml`（模块级）+ `component-spec.xml`（组件级）
**视觉建议**：
- 左侧：一个模块（如 UserService）被放大镜放大
- 右侧：模块内部拆分为 4-5 个组件方块，组件之间用带契约标签的箭头连接
- 底部：两个 XML 文件图标（module-architecture.xml + component-spec.xml）

---

### P16 Skill 6：工作流与产物
**页面标题**：模块细化设计 — 工作流与产物  
**核心工作流（7 步）**：
1. 锁定模块边界（从系统 XML 提取契约、耦合、状态）
2. 模块级需求分析（从 PRD 筛选相关 user stories，分级 P0/P1/P2）
3. 组件分解（3-6 个组件：entry_point / domain_service / repository / utility / gateway）
4. 组件接口设计（方法签名 + 输入/输出 Schema + 错误码）
5. 模块级 XML 建模（`module-architecture.xml`：Components、ComponentInterfaces、ModuleStateModel）
6. 组件级 XML 模板生成（`component-spec.xml`：Metadata、Functions、Dependencies 占位）
7. 人类门控 `[APPROVE / NEXT MODULE]`
**产物**：
- `modules/{module_id}/module-architecture.xml`
- `modules/{module_id}/components/{component_id}/component-spec.xml`
**视觉建议**：
- 左侧流程图，步骤 3-6 为核心，用高亮框标注
- 右侧展示 module-architecture.xml 的结构预览（Components / ComponentInterfaces / ModuleStateModel）

---

## Part 3：增量迭代与领域扩展（P17-P21）

### P17 Skill 7（新增）：增量迭代规划 — 新需求来了怎么办
**页面标题**：sdlc-iteration-planning：在已有框架上优雅生长  
**核心内容**：
- **触发条件**：初始脚手架已完成，用户提出新需求或功能扩展
- **范围验证**：对比新需求与 `STATE.md` 中的 **Immutable Goal**，超出范围则标记为"范围升级"
- **影响分析矩阵**：标注每个新需求影响的模块（新增 / 修改 / 无影响）和严重程度（breaking / additive / internal）
- **接口版本控制**：breaking 变更需升级接口版本号，additive 变更保持兼容
- **XML 同步**：系统级变更自动传播到模块级和组件级 XML
**视觉建议**：
- 左侧：一座已建好的建筑（已有系统）
- 右侧：新增楼层/房间（新模块）和改造房间（已有模块升级）
- 箭头标注："不拆承重墙，只做增量改造"

---

### P18 Skill 7：工作流与产物
**页面标题**：增量迭代规划 — 工作流与产物  
**核心工作流（6 步）**：
1. 范围验证（对比 Immutable Goal）
2. 影响分析（影响矩阵 + 严重程度标注：breaking / additive / internal）
3. 增量 PRD（只编写新增/变更 user stories，标注 `relates_to: US-XXX`）
4. 增量架构设计（新增模块 → 完整 module-design；修改模块 → 更新 XML，保持接口版本兼容）
5. XML 同步（系统级变更 → 自动传播到模块级 → 组件级约束）
6. 迭代计划生成（执行顺序、涉及模块、回滚标准）+ 人类门控 `[APPROVE / MODIFY / REJECT]`
**产物**：
- `skill/artifacts/ITERATION_PRD.md`
- `skill/artifacts/ITERATION_PLAN.md`
- 更新后的 `module-architecture.xml` / `component-spec.xml`
- 更新后的 `STATE.md`（Iteration History、Module Registry、interface_version）
**视觉建议**：
- 左侧流程图，步骤 2（影响矩阵）和 5（XML 同步）用高亮框标注
- 右侧展示影响矩阵示例（模块 × 需求，格子标注新增/修改/无影响 + breaking/additive）

---

### P19 增量场景演示：两个月后要加支付模块
**页面标题**：一个完整的增量迭代故事  
**故事线**：
1. **起点**：系统已有 UserService + OrderService（Iteration 0 已完成，STATE.md 中 Module Registry 记录状态）
2. **新需求**：新增 PaymentService + 用户资料扩展
3. **Iteration 1 启动**：调用 `sdlc-iteration-planning`
4. **影响分析**：
   - PaymentService：**新增模块**（走完整 module-design + scaffolding）
   - UserService：**修改模块**（additive：新增 `profile` 字段，接口版本 1.0.0 → 1.1.0）
   - OrderService：无影响
5. **XML 同步**：`architecture.xml` 新增 PaymentService 节点 → 自动生成 `modules/PaymentService/module-architecture.xml` 模板
6. **执行**：按 ITERATION_PLAN.md 逐个模块实施，走 `[APPROVE]` 门控
7. **完成**：STATE.md 更新 Iteration History，Module Registry 新增 PaymentService 记录
**视觉建议**：
- 时间轴从左到右
- 起点（已有建筑：UserService + OrderService）→ 触发（红色闪电：新需求）→ 分析（影响矩阵气泡）→ 实施（新增绿色方块 PaymentService + 修改黄色方块 UserService）→ 完成（STATE.md 更新）

---

### P20 领域扩展机制速览
**页面标题**：当项目遇上 AI Agent / 数据管道 / 移动应用  
**核心内容**：
- **触发机制**：`sdlc-architecture-design` 检测到 PRD 特征标签时，动态加载对应扩展
  - `ai_agent` / `llm_orchestration` / `tool_use` → 加载 ai-agent-design
  - `data_pipeline` / `etl` / `streaming` → 加载 data-pipeline-design
  - `mobile_app` / `ios` / `android` → 加载 mobile-app-design
- **三个扩展**：
  1. **ai-agent-design**：新增 5 个评估维度（Tool Latency、Context Window Efficiency、Memory Integration 等）+ 10 个 AI 反模式（God Agent、Prompt Injection、Tool Amnesia 等）
  2. **data-pipeline-design**：Schema Evolution、Idempotency、Backpressure、Data Lineage
  3. **mobile-app-design**：Offline Support、Battery Efficiency、Push Delivery
- **overlay 机制**：扩展评估维度与基础模式库叠加，不替换原有评估
**视觉建议**：
- 中央：基础架构设计 skill 的图标
- 三个方向延伸出扩展卡片，每个卡片有触发标签 + 新增维度列表
- 卡片与中央用虚线连接，表示"动态加载"
- 底部小字："10 种基础模式 + 3 个领域扩展 = 按需组合的评估体系"

---

### P21 上下文压缩机制
**页面标题**：跨 Session 快速恢复：200 字摘要  
**核心内容**：
- **问题**：7 个 skill 跑完后，session 上下文非常长，下次如何快速接续？
- **解决方案**：每个 skill 完成后**自动调用** `context-compression`，提取关键信息：
  - Top 3 决策（DecisionID + What + Why + Risk）
  - Top 2 风险或陷阱
  - 当前 phase 和 NextAction（iterate / refactor / module / none）
- **产物**：`STATE.md` 的 `Compressed Context` 字段（200 字以内）
- **使用场景**：用户 3 天后回来，只需读这 200 字 + 当前的 `NextAction`，即可知道该调用哪个 skill
- **Artifact Index 同步**：同时更新产物索引表，确保跨 session 不丢失产物引用
**视觉建议**：
- 左侧：一本厚厚的书（全部历史产物：PRD / XML / 代码 / 日志）
- 中间：一个压缩机图标（标注 "context-compression"）
- 右侧：一张小卡片（200 字摘要示例）
- 箭头标注："7 个 skill 全部产物 → 200 字摘要 → 5 秒恢复上下文"

---

## Part 4：推理锚点、产物地图与总结（P22-P26）

### P22 STATE.md：从 4 分类到 9 分类
**页面标题**：跨 Session 推理链锚点：v1.1 的 9 分类设计  
**核心内容**：
- **Immutable Goal**（不变，永不覆盖）— 原始产品想法 + 成功指标 + Scope 边界
- **Completed Steps**（追加，永不覆盖）— 7 个 skill 的执行记录
- **DecisionDigest（新增）**— 最近 20 条关键决策摘要，格式 `[日期] [决策ID]: 一句话`
- **Current State**（覆盖）— phase、DIVE 进度、**NextAction**（iterate / refactor / module / none）
- **Module Registry（新增）**— 每个模块的状态（pending / design_completed / scaffolded）、接口版本号
- **Iteration History（新增）**— 所有迭代记录（iteration / date / scope / affected_modules / status）
- **Compressed Context（新增）**— 200 字摘要，支持跨 session 快速恢复
- **Artifact Index（新增）**— 12+ 项产物的快速索引表（路径 / 修改时间 / 摘要）
- **Known Pitfalls & Risks**（追加）— 风险沉淀
**路径变体说明**：
- 初始开发阶段：`skill/artifacts/STATE.md`
- 增量迭代阶段：`docs/architecture/system/STATE.md`

**9 分类设计详情**：
- **Immutable Goal**：原始产品想法 + 成功指标 + Scope 边界（永不覆盖）
- **Completed Steps**：7 个 skill 的执行记录（追加，永不覆盖）
- **DecisionDigest**：最近 20 条关键决策摘要（`[日期] [决策ID]: 一句话`）
- **Current State**：phase、DIVE 进度、NextAction（iterate / refactor / module / none）
- **Module Registry**：每个模块的状态 + 接口版本号
- **Iteration History**：所有迭代记录（iteration / date / scope / affected_modules / status）
- **Compressed Context**：200 字摘要，支持跨 session 快速恢复
- **Artifact Index**：12+ 项产物的快速索引表
- **Known Pitfalls & Risks**：风险沉淀（追加）

**视觉建议**：
- 一个打开的笔记本，9 个分区用不同颜色标注
- 分区 1 绿色（Immutable）、分区 2 蓝色（Completed Steps）、分区 3 紫色（DecisionDigest）、分区 4 橙色（Current State，有刷新箭头）、分区 5 青色（Module Registry）、分区 6 粉色（Iteration History）、分区 7 灰色（Compressed Context）、分区 8 黄色（Artifact Index）、分区 9 红色（Known Pitfalls）
- 新增分区（3/5/6/7/8）用闪烁/高亮效果
- 左侧箭头标注："下一个 session 从这里继续"

---

### P23 产物地图：12 项产物 + 三层 XML 引用链
**页面标题**：从想法到代码，每一步留下什么？（v1.1 完整版）  
**产物表格**（从 10 行扩展为 14 行）：
| 产物 | 路径 | 由谁产出 | 作用 |
|------|------|---------|------|
| PRD | `skill/artifacts/PRD.md` | Skill 1 | 需求源头 |
| Decision Log | `skill/artifacts/DECISION_LOG.md` | 全部 Skill | 完整推理链 |
| Interface Contract | `skill/artifacts/INTERFACE_CONTRACT.md` | Skill 2 | I/O 边界定义 |
| Architecture Design | `skill/artifacts/ARCHITECTURE.md` | Skill 2 | 设计摘要 |
| Architecture XML（系统级） | `skill/artifacts/architecture.xml` | Skill 2 | 模块划分 + 跨模块接口 + DecisionTrace |
| **Module Architecture XML** | `modules/{id}/module-architecture.xml` | **Skill 6** | 组件分解 + 组件接口 + 模块状态 |
| **Component Spec XML** | `modules/{id}/components/{cid}/component-spec.xml` | **Skill 6** | 函数签名 + 逻辑步骤 + 错误处理 + 代码生成模板 |
| Validation Report | `skill/artifacts/VALIDATION_REPORT.md` | Skill 3 | 技术自洽性 |
| **Validation Delta** | `docs/architecture/validation/VALIDATION_DELTA_*.md` | **Skill 3** | 增量对比（新增/已解决问题） |
| Design Review | `skill/artifacts/DESIGN_REVIEW.md` | Skill 4 | 问题清单 |
| Health Check | `skill/artifacts/health-check.sh` | Skill 3 | 可运行检查脚本 |
| **Iteration PRD** | `skill/artifacts/ITERATION_PRD.md` | **Skill 7** | 增量需求 |
| **Iteration Plan** | `skill/artifacts/ITERATION_PLAN.md` | **Skill 7** | 执行顺序 + 回滚标准 |
| Scaffold | `skill/artifacts/PROJECT_SCAFFOLD/` | Skill 5 | 完整可运行项目 |
| ADR | `PROJECT_SCAFFOLD/docs/ADR.md` | Skill 5 | 代码库中的推理锚点 |
**三层 XML 引用链示意图**：
```
system-architecture.xml          ← 系统级
├── modules/
│   ├── UserService/
│   │   └── module-architecture.xml   ← 模块级
│   │       └── components/
│   │           ├── AuthController/
│   │           │   └── component-spec.xml  ← 组件级
│   │           └── UserRepository/
│   │               └── component-spec.xml
│   └── OrderService/
│       └── module-architecture.xml
└── shared/
    └── common-types.xml
```
**视觉建议**：
- 横向流程图，7 个 skill 从左到右排列
- 每个 skill 下方对齐其产物，产物用文件图标表示
- 产物之间有连线表示引用关系（如 XML → 引用 Interface Contract）
- 底部独立展示三层 XML 树状图

---

### P24 使用流程：双轨对比
**页面标题**：初始开发 vs 增量迭代 — 两条轨道，同一套规则  
**左侧：初始开发（7 步）**：
1. `sdlc-requirement-analysis` → 输入产品想法 → 输出 PRD → `[APPROVE]`
2. `sdlc-architecture-design` → 读取 PRD + STATE + DECISION_LOG → 输出架构 + XML → `[APPROVE]`
3. `sdlc-architecture-validation`（可选）→ 技术一致性检查 → `[APPROVE]`
4. `sdlc-design-review`（推荐）→ 对抗性审查 → `[APPROVE / FIX <id>]`
5. `sdlc-project-scaffolding` → 读取全部历史 → 输出项目 → `[APPROVE]`
6. `sdlc-module-design`（按需，每个模块）→ 模块细化 → `[APPROVE / NEXT MODULE]`
7. 结束，`NextAction: none`

**右侧：增量迭代（3 步）**：
1. `sdlc-iteration-planning` → 新需求 → 影响分析 + ITERATION_PLAN → `[APPROVE]`
2. `sdlc-module-design`（新模块）或 `sdlc-architecture-design`（架构变更）→ `[APPROVE]`
3. `sdlc-project-scaffolding` → 生成/更新代码 → `[APPROVE]`

**中间共用红线（3 条）**：
1. 每个 skill 启动时**读取 STATE.md + 全部历史产物**
2. 每个 skill 结束前**更新 STATE.md**（追加 Completed Steps + Known Pitfalls + DecisionDigest）
3. **禁止自动跳转**，必须等待人类 `[APPROVE]`

**视觉建议**：
- 左右双轨铁路图
- 左侧轨道较长（7 站），右侧轨道较短（3 站）
- 两轨在底部汇入同一个"STATE.md 状态管理"枢纽
- 每个站点配一个红色闸门图标 `[APPROVE]`
- Skill 3 用虚线框标注"可选"，Skill 4 用实线框标注"推荐"

---

### P25 VCMF 5 原则回顾
**页面标题**：v1.1 新增第 5 条原则：XML 作为权威  
**内容（5 个卡片）**：
1. 🔗 **Design as Contract** — 代码必须服从文档，每个产物必须可追溯回需求或设计决策
2. 💾 **Interface as Boundary** — 任何跨模块或跨层调用必须有显式输入/输出 Schema 和错误契约
3. 🔍 **Reality as Baseline** — Mock 测试验证流程；真实环境验证功能；语义敏感点必须用真实 LLM 测试
4. 🛡️ **State as Responsibility** — 谁创建、谁持久化、谁读取、谁清理状态必须文档化并强制执行
5. 📄 **XML as Authority（v.1.1 新增）** — `component-spec.xml` 是代码生成的单一起源。函数签名、错误处理、文件路径必须匹配 XML 规格，CI 自动检查一致性
**视觉建议**：
- 5 个彩色方块横向排列（2+3 或 1 行 5 个）
- 每个方块内：大图标 + 原则标题 + 一行解释
- 第 5 个方块用特别强调色（如金色边框），内部展示：XML 文件 → 箭头 → 代码文件，标注"Single Source of Truth"
- 底部小字：来源 — VCMF (Vibe Coding Maturity Framework)

---

### P26 总结 + Q&A
**页面标题**：一句话总结  
**核心句（大字居中）**：
> 最好的多 Agent 系统，不像公司。它更像一个思考者的多次草稿——同一个大脑，在不同维度上展开推理，最终合并成一个连贯的结论。

**关键数字（更新为 7 个卡片）**：
- **7** 个 skill = 同一思考者的 7 次展开
- **10** 种架构模式动态筛选（从 6 扩展）
- **3** 个审查视角（攻击者 / 维护者 / 扩展者）
- **3** 层 XML 架构（系统 / 模块 / 组件）
- **9** 分类 STATE.md 推理锚点（从 4 扩展）
- **3** 个领域扩展（AI Agent / 数据管道 / 移动应用）
- **0** 个角色边界（无 PM / 架构师 / QA 标签）

**下一步行动**：
- 查看 `skill/README.md` 开始使用
- 阅读 `skill/sdlc-design.md` 了解完整设计

**视觉建议**：
- 中央大字引用（深色背景 + 白色文字）
- 下方 7 个数字卡片（2 行排列：4 + 3）
- 底部"Q&A"和"感谢聆听"字样
- 最后一页可以配一个简洁的二维码（链接到项目仓库）

---

## 附录：演讲者备注

### 时间分配建议（60 分钟演讲）
- P1-P4（铺垫）：10 分钟
- P5-P16（初始开发 6 个 Skill）：32 分钟（每个 Skill 平均 2.5 分钟，architecture-design 和 project-scaffolding 可适当延长）
- P17-P21（增量迭代 + 领域扩展 + 上下文压缩）：10 分钟
- P22-P26（推理锚点、产物地图、总结）：6 分钟
- Q&A：2 分钟

### 重点强调页
- **P3**：一定要讲透"信息在流转中死亡"，这是整个设计的动机；新增钩子"能持续演化"为后面的增量迭代做铺垫
- **P7**：强调"动态筛选"是防止上下文爆炸的关键创新，三层 XML 是 v1.1 最核心的架构变更
- **P10**：最容易混淆的地方，必须讲清验证（技术审计）和审查（红队挑刺）的区别
- **P13-P14**：XML 驱动代码生成 + CI 一致性检查是 v1.1 的硬核交付升级
- **P15-P16**：module-design 是新增 skill，说明为什么从"只有一个 architecture.xml"进化到"三层 XML"
- **P17-P19**：增量迭代是 v1.1 最具吸引力的能力，用"加支付模块"的故事帮助听众建立直觉
- **P22**：STATE.md 9 分类是跨 session 连续性的关键，用笔记本比喻帮助理解

### 视觉风格建议
- 主色调：深蓝（#1a365d）+ 白色文字，强调色用橙色（#ed8936）
- 核心内容页采用"问题 → 方案"或"机制 → 示例"的叙事结构
- 重点内容用高亮色标注，方便听众快速识别关键信息
- 图标风格统一：使用扁平化图标，避免 3D 效果
- 字体：标题用无衬线粗体（如 Microsoft YaHei Bold），正文用常规体
