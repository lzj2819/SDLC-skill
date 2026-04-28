# SDLC Skill Chain v1.0.1 PPT 内容大纲

> 基于 `E:\pythonproject\vclaw\vclaw\1.0.1\skill` 全部内容设计
> 结构：问题-解决方案叙事（Problem-Solution Narrative）
> 总页数：19页

---

## 第一部分：故事线铺垫（P1-P4）

### P1 封面
**页面标题**：SDLC Skill Chain v1.0.1 — 从"角色接力"到"思考者草稿"
**副标题**：基于 VCMF 与 DIVE 方法论的 AI 驱动软件开发生命周期
**视觉建议**：
- 深色背景（深蓝或深灰）
- 左侧放置 DIVE 循环图：Design → Implement → Verify → Evolve（环形箭头）
- 右侧大号白色标题文字
- 底部小字：VClaw Project | 2026

---

### P2 议程
**页面标题**：今天讲什么
**内容要点**：
1. 一个流行的陷阱：多 Agent "角色接力赛"
2. 我们的答案：Single Thinker 迭代模型
3. 5 次展开：从需求到代码的完整技能链
4. 推理锚点：让上下文永不丢失
5. 产物地图与使用方式
**视觉建议**：
- 左侧竖线时间轴，5个节点
- 右侧每个节点配一个图标和一行文字
- 当前章节节点高亮（从第一个开始）

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
**视觉建议**：
- 画一条水平流水线
- 4个工位图标：PM（需求）→ 架构师（设计）→ 开发（代码）→ QA（测试）
- 工位之间箭头标注"信息衰减"，箭头逐渐变细/变灰
- 最右端输出一个歪斜/破损的产品图标
- 底部一行红字："你得到的是一个模拟公司行为的系统，而不是一个解决问题的系统"

---

### P4 我们的答案：Single Thinker 模型
**页面标题**：最好的多 Agent 系统，不像公司，像一个思考者的多次草稿
**核心内容**：
- **同一思考者**：5 个 skill 是同一个大脑面对同一问题的 5 次展开
- **完整上下文**：每个 skill 读取**全部历史产物**，而非仅上一阶段的结论
- **推理链外化**：不依赖模型记忆，靠显式状态文件锚定
- **对抗性检验**：验证 Agent 专门找问题，不"接棒继续做"
**视觉建议**：
- 中央一个大脑图标
- 向外辐射 5 条光线（不同颜色），光线末端分别是 5 个 skill 的简化图标
- 光线标注"完整上下文流动"（双向箭头）
- 底部引用：`"同一个大脑，在不同维度上展开推理，最终合并成一个连贯的结论"`

---

## 第二部分：5 个 Skill 详细展开（P5-P14）

### P5 Skill 1：需求分析 — 第一次展开
**页面标题**：sdlc-requirement-analysis：锁定目标与边界
**旧 vs 新对比**：
| 旧做法 | 新做法 |
|--------|--------|
| PM 写 PRD，丢给架构师，自己不再参与 | 同一思考者**亲自初始化**推理锚点（STATE.md Immutable Goal） |
| 上下文在交接中丢失 | 通过 3-5 个针对性问题补全上下文 |
| 只有结论文档 | 同时**播种决策日志**，防止后续阶段漂移 |
**VCMF 检查点**：
- Design as Contract：闭环指标与 Scope 边界
- Interface as Boundary：跨模块交互点识别
- Reality as Baseline：可观测、可测试的验收标准
- State as Responsibility：业务状态所有者文档化
**视觉建议**：
- 左右分栏：左侧"旧"（一个人写文档，箭头指向下一个工位，箭头断裂），右侧"新"（同一个人，旁边出现 STATE.md 和 PRD 两个文件，有连线相连）

---

### P6 Skill 1：工作流与产物
**页面标题**：需求分析 — 工作流与产物
**核心工作流（7步）**：
1. 方法论对齐（四维推演：Why / What / How / Modules）
2. **状态初始化**（读取/创建 STATE.md，写入 Immutable Goal）
3. 上下文补全（3-5 个针对性问题）
4. 跨模块交互点识别
5. PRD 生成 + 决策日志播种
6. **状态更新**（追加 Completed Steps）
7. 人类门控 `[APPROVE]`
**产物**：
- `skill/artifacts/PRD.md`
- `skill/artifacts/DECISION_LOG.md`（初始）
**视觉建议**：
- 左侧垂直流程图，7 个步骤用箭头连接
- 步骤 2 和 6 用高亮框标注（STATE.md 交互）
- 右侧两个产物文件图标，配简短说明

---

### P7 Skill 2：架构设计 — 第二次展开
**页面标题**：sdlc-architecture-design：并行探索技术路径
**旧 vs 新对比**：
| 旧做法 | 新做法 |
|--------|--------|
| 架构师凭经验选一种架构，写文档丢给开发 | 同一思考者读取**完整历史**（PRD + STATE + DECISION_LOG） |
| 单一路径深度优先 | **orchestrator-worker 并行评估** 6 种架构模式 |
| 只记录结论（"选 Hexagonal"） | 产出**完整推理链**（为什么选 A，为什么 B/C/D/E/F 被否） |
| 架构文档无推理痕迹 | XML 新增 `<DecisionTrace>` 节点，推理外化到文档中 |
**6 种并行评估的架构模式**：
1. Layered（分层）
2. Hexagonal（六边形/端口适配器）
3. Event-Driven（事件驱动）
4. Microservice（微服务）
5. Client-Server（客户端-服务器）
6. Plugin-Based（插件化）
**视觉建议**：
- 左右分栏：左侧"旧"（一个人指着一种架构，表情自信但盲目），右侧"新"（一个 orchestrator 分派 6 个 worker 并行评估，结果汇总成评分矩阵）
- 评分矩阵示意：6 行（架构）× 5 列（评估维度），某一行高亮（推荐方案）

---

### P8 Skill 2：工作流与产物
**页面标题**：架构设计 — 工作流与产物
**核心工作流（9步）**：
1. 并行探索（6 种架构模式评分）
2. 接口契约设计（输入/输出/错误码）
3. 状态所有权映射（谁创建/写入/读取/清理）
4. 测试用例设计（happy + abnormal + NFR）
5. XML 建模（含 DecisionTrace）
6. 架构文档编写
7. 决策日志更新（含完整推理链）
8. 状态更新（追加 Completed Steps + Known Pitfalls）
9. 人类门控 `[APPROVE]`
**产物**：
- `skill/artifacts/ARCHITECTURE.md`
- `skill/artifacts/INTERFACE_CONTRACT.md`
- `skill/artifacts/architecture.xml`（含 DecisionTrace）
**视觉建议**：
- 左侧流程图，步骤 5 和 7 高亮
- 右侧 3 个产物文件图标
- XML 结构预览（`<DecisionTrace>` 节点高亮显示）

---

### P9 Skill 3：技术验证 — 可选检查点
**页面标题**：sdlc-architecture-validation：技术一致性检查
**旧 vs 新对比**：
| 旧做法 | 新做法 |
|--------|--------|
| QA 接棒做全面测试，发现问题逐级上报 | **收窄职责**：只做技术自洽性检查 |
| 安全/错误/工具选择都测 | 安全/错误/工具选择验证 → **移交给 design-review** |
| 产出 PASS/FAIL，控制流程 | 产出技术验证报告，**不控制是否进入下一阶段** |
**核心工作流（11步）**：
1. API 就绪检查
2. XML vs Interface Contract 一致性
3. XML vs PRD 一致性（防孤儿模块）
4. Mock 注入 + 模块级模拟
5. Real-LLM 格式验证（仅 schema 合规）
6. 推演打印（Trace Logging）
7. 自修复循环（失败则 `[RETRY]`）
8. 健康检查脚本生成
9. 状态更新
10. 人类门控 `[APPROVE]`
**产物**：`VALIDATION_REPORT.md` + `health-check.sh`
**视觉建议**：
- 左右分栏：左侧"旧"（QA 拿着大锤全面测试，满头大汗），右侧"新"（聚焦显微镜检查技术细节，旁边标注"对抗审查 → design-review"）

---

### P10 Skill 3 vs Skill 4：验证与审查，为什么分开？
**页面标题**：验证是"检查自洽"，审查是"专门挑刺"
**对比表格**：
| 维度 | sdlc-architecture-validation | sdlc-design-review |
|------|------------------------------|-------------------|
| 核心问题 | "架构文档是否自洽？" | "设计是否有漏洞？" |
| 方法 | 一致性检查、Mock 模拟、拓扑连通 | 攻击者/维护者/扩展者三视角 |
| 输出 | PASS/FAIL + 验证报告 | **问题清单**（无 PASS/FAIL） |
| 角色定位 | 技术审计员 | **红队（Red Team）** |
| 是否控制流程 | 是（失败则阻塞） | **否**（只提供问题，用户决策） |
**视觉建议**：
- 左右对比两栏
- 左侧蓝色背景（冷静检查），右侧红色背景（对抗挑刺）
- 中间竖线分隔，上方大字："分工 ≠ 分阶段，而是分职责"

---

### P11 Skill 4：设计审查 — 第三次展开（新增）
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
**核心工作流（8步）**：
1. 读取**全部历史产物**（PRD / STATE / DECISION_LOG / ARCHITECTURE / XML / INTERFACE）
2. 攻击者视角检查
3. 维护者视角检查
4. 扩展者视角检查
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

### P13 Skill 5：项目脚手架 — 第四次展开
**页面标题**：sdlc-project-scaffolding：携带完整上下文落地为代码
**旧 vs 新对比**：
| 旧做法 | 新做法 |
|--------|--------|
| 开发按架构图施工，遇到模糊点就猜测 | 读取**全部历史产物**（包括 DESIGN_REVIEW 问题清单） |
| 代码与决策脱节 | 每个核心模块头部携带**推理链注释**（关联架构决策 ID + 为什么存在 + 已知风险） |
| 问题清单被忽略 | DESIGN_REVIEW 的 Must Fix / Should Fix 自动转为**内联 TODO** |
| 无历史记录留在代码库 | 生成 **ADR（架构决策记录）**作为代码库中的持久推理锚点 |
**视觉建议**：
- 左右分栏：左侧"旧"（工人对着模糊的图纸施工，头上冒问号），右侧"新"（工人手持完整历史卷轴，代码中出现注释和 TODO 标记，旁边有 ADR 文档）

---

### P14 Skill 5：工作流与产物
**页面标题**：项目脚手架 — 工作流与产物
**核心工作流（16步，关键步骤）**：
1. 读取全部历史产物（8 个文件）
2. 轻量规划
3. 目录树 + 依赖配置
4. 核心代码骨架（匹配接口契约）
5. **代码推理注释** + 内联 TODO
6. 部署拓扑 + CI/CD
7. 测试夹具（mock / real / e2e）
8. **ADR 生成**
9. 决策日志 + CHANGELOG
10. 内部验证
11. **回溯验证**（抽查 3-5 个文件的可追溯性）
12. 人类门控 `[APPROVE]`
**产物**：
- `skill/artifacts/PROJECT_SCAFFOLD/`（完整可运行项目）
- `PROJECT_SCAFFOLD/docs/ADR.md`
- `PROJECT_SCAFFOLD/docs/sync-rules.md`
- `PROJECT_SCAFFOLD/CHANGELOG.md`
- `PROJECT_SCAFFOLD/.env.template`
**视觉建议**：
- 左侧流程图，步骤 5、8、11 高亮（新增关键步骤）
- 右侧产物树状图（PROJECT_SCAFFOLD 目录结构展开）

---

## 第三部分：推理锚点、产物地图与总结（P15-P19）

### P15 推理锚点：STATE.md — 让上下文永不丢失
**页面标题**：跨 Session 推理链锚点：STATE.md 的 4 分类设计
**核心内容**：
- **Immutable Goal**（不变，永不覆盖）
  - 原始产品想法 + 成功指标 + Scope 边界
  - 每次 skill 启动时读取，防止目标漂移
- **Completed Steps**（追加，永不覆盖）
  - 格式：`[2026-04-20 10:00] sdlc-requirement-analysis: Locked P0/P1/P2 scope`
  - 保留完整历史推理链，下一个 session 读到的不是压缩结论
- **Current State**（覆盖，反映最新）
  - 当前 phase、DIVE 进度、下一个推荐 skill
- **Known Pitfalls**（追加，风险沉淀）
  - 已发现的风险和规避策略，避免下一个 session 重复踩坑
**对比**：
| 旧版 | v1.0.1 |
|------|--------|
| `phase: requirement_analysis_completed`（简单标记） | 4 分类推理锚点 |
| 信息被"压缩传递" | 信息被"连续积累" |
**视觉建议**：
- 一个打开的笔记本，4 个分区用不同颜色标注
- 分区 1 绿色（Immutable）、分区 2 蓝色（Completed Steps，有滚动条示意追加）、分区 3 橙色（Current State，有刷新箭头）、分区 4 红色（Known Pitfalls）
- 左侧箭头标注："下一个 session 从这里继续"

---

### P16 产物地图：全链路产物索引
**页面标题**：从想法到代码，每一步留下什么？
**产物表格**：
| 产物 | 路径 | 由谁产出 | 作用 |
|------|------|---------|------|
| PRD | `skill/artifacts/PRD.md` | Skill 1 | 需求源头 |
| Decision Log | `skill/artifacts/DECISION_LOG.md` | 全部 Skill | 完整推理链 |
| Interface Contract | `skill/artifacts/INTERFACE_CONTRACT.md` | Skill 2 | I/O 边界定义 |
| Architecture | `skill/artifacts/ARCHITECTURE.md` | Skill 2 | 设计摘要 |
| Architecture XML | `skill/artifacts/architecture.xml` | Skill 2 | 严格 Schema + DecisionTrace |
| Validation Report | `skill/artifacts/VALIDATION_REPORT.md` | Skill 3 | 技术自洽性 |
| Design Review | `skill/artifacts/DESIGN_REVIEW.md` | Skill 4 | 问题清单 |
| Health Check | `skill/artifacts/health-check.sh` | Skill 3 | 可运行检查脚本 |
| Scaffold | `skill/artifacts/PROJECT_SCAFFOLD/` | Skill 5 | 完整可运行项目 |
| ADR | `PROJECT_SCAFFOLD/docs/ADR.md` | Skill 5 | 代码库中的推理锚点 |
**视觉建议**：
- 横向流程图，5 个 skill 从左到右排列
- 每个 skill 下方对齐其产物，产物用文件图标表示
- 产物之间有连线表示引用关系（如 XML → 引用 Interface Contract）

---

### P17 如何使用：5 步调用流程
**页面标题**：开始使用：一条命令启动一次展开
**使用流程**：
1. `sdlc-requirement-analysis` → 输入产品想法 → 输出 PRD → `[APPROVE]`
2. `sdlc-architecture-design` → 读取 PRD + STATE + DECISION_LOG → 输出架构 → `[APPROVE]`
3. `sdlc-architecture-validation`（可选）→ 技术一致性检查 → `[APPROVE]`
4. `sdlc-design-review`（推荐）→ 对抗性审查 → `[APPROVE / FIX <id>]`
5. `sdlc-project-scaffolding` → 读取全部历史 → 输出项目 → `[APPROVE]`
**关键约束（3条红线）**：
1. 每个 skill 启动时**读取 STATE.md + 全部历史产物**
2. 每个 skill 结束前**更新 STATE.md**（追加 Completed Steps + Known Pitfalls）
3. **禁止自动跳转**，必须等待人类 `[APPROVE]`
**视觉建议**：
- 左侧垂直流程图，5 个 skill 用箭头连接
- 每个 skill 旁边有一个红色闸门图标，标注 `[APPROVE]`
- Skill 3 用虚线框标注"可选"，Skill 4 用实线框标注"推荐"
- 右侧大字："读取全部历史 → 执行 → 更新状态 → 等待确认"

---

### P18 核心原则回顾：5 条架构原则
**页面标题**：从三大厂商实践中提炼的 5 条原则
**内容（5 个卡片）**：
1. 🔗 **推理链不能断，只能分叉再合并**
   - 主 agent 持有完整意图，子调用结果回流，不是传给下一个 agent
2. 💾 **显式外部状态，不靠模型记住**
   - progress.txt / git history / spec 文件 / STATE.md
3. 🔍 **多 Agent 的价值是并行覆盖，不是分工**
   - 用更多 token 覆盖更大搜索空间
4. 🛡️ **验证 Agent 是否定者，不是接棒者**
   - 对抗性检验，不是流水线传递
5. 🔧 **工具是工具，不是角色**
   - 给 Agent 配什么工具远比贴什么标签重要
**视觉建议**：
- 5 个彩色方块横向排列（或 2+3 排列）
- 每个方块内：大图标 + 原则标题 + 一行解释
- 底部小字：来源 — Anthropic / OpenAI / Google 工程实践

---

### P19 总结 + Q&A
**页面标题**：一句话总结
**核心句（大字居中）**：
> 最好的多 Agent 系统，不像公司。它更像一个思考者的多次草稿——同一个大脑，在不同维度上展开推理，最终合并成一个连贯的结论。
**关键数字（5 个卡片）**：
- **5** 个 skill = 同一思考者的 5 次展开
- **6** 种架构模式并行评估
- **3** 个审查视角（攻击者 / 维护者 / 扩展者）
- **4** 分类 STATE.md 推理锚点
- **0** 个角色边界（无 PM / 架构师 / QA 标签）
**下一步行动**：
- 查看 `skill/README.md` 开始使用
- 阅读 `skill/sdlc-design.md` 了解完整设计
**视觉建议**：
- 中央大字引用（深色背景 + 白色文字）
- 下方 5 个数字卡片横向排列
- 底部"Q&A"和"感谢聆听"字样
- 最后一页可以配一个简洁的二维码（链接到项目仓库）

---

## 附录：演讲者备注

### 时间分配建议（45 分钟演讲）
- P1-P4（铺垫）：8 分钟
- P5-P14（5 个 Skill）：25 分钟（每个 Skill 约 5 分钟）
- P15-P19（总结）：10 分钟
- Q&A：2 分钟

### 重点强调页
- **P3**：一定要讲透"信息在流转中死亡"，这是整个设计的动机
- **P7**：强调 orchestrator-worker 并行评估和 DecisionTrace 是核心创新
- **P10**：这是最容易混淆的地方，必须讲清验证和审查的区别
- **P11**：design-review 是新增 skill，说明为什么从 4 个变成 5 个
- **P15**：STATE.md 是跨 session 连续性的关键，用笔记本比喻帮助理解

### 视觉风格建议
- 主色调：深蓝（#1a365d）+ 白色文字，强调色用橙色（#ed8936）
- 每页保持"旧 vs 新"的左右对比结构（前 14 页）
- 图标风格统一：使用扁平化图标，避免 3D 效果
- 字体：标题用无衬线粗体（如 Microsoft YaHei Bold），正文用常规体
