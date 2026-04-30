# DevForge SDLC Skill Chain v1.2

> 基于 **VCMF**（Vibe Coding Maturity Framework）与 **DIVE**（Design-Implement-Verify-Evolve）方法论的 AI 驱动软件开发生命周期工具链

[GitHub 仓库](https://github.com/lzj2819/DevForge) | [License: MIT](LICENSE)

---

## 一句话介绍

**DevForge** 是一套面向全栈软件工程的 Claude Code Skill 链，将"产品灵感 → 需求文档 → 架构设计 → 代码脚手架 → 生产部署"的完整 SDLC 流程标准化为 10 个可迭代阶段。每个阶段由独立的 Skill 驱动，通过 XML 权威架构、人类门控审核和自动化自校验，确保 AI 生成的每一行代码都可追溯、可验证、可演进。

---

## 3 分钟 QuickStart

想快速体验？参考完整示例：

**[examples/quickstart-todo-app.md](examples/quickstart-todo-app.md)** —— 从"我想做一个 Todo 应用"到生成可运行的全栈项目脚手架，只需 10 分钟。

### 极简安装

```bash
# 1. 克隆仓库
git clone https://github.com/lzj2819/DevForge.git
cd DevForge

# 2. 复制所有 Skill 到 Claude Code 用户目录（macOS/Linux）
cp -r devforge-requirement-analysis devforge-architecture-design \
  devforge-architecture-validation devforge-design-review \
  devforge-project-scaffolding devforge-module-design \
  devforge-iteration-planning devforge-visualization \
  devforge-ops-ready devforge-debug-assistant \
  context-compression extensions \
  ~/.claude/skills/

# 3. 重启 Claude Code 或运行 /reload
```

**Windows (PowerShell):**

```powershell
$target = "$env:USERPROFILE\.claude\skills"
@("devforge-requirement-analysis", "devforge-architecture-design",
  "devforge-architecture-validation", "devforge-design-review",
  "devforge-project-scaffolding", "devforge-module-design",
  "devforge-iteration-planning", "devforge-visualization",
  "devforge-ops-ready", "devforge-debug-assistant",
  "context-compression", "extensions") | ForEach-Object {
    Copy-Item -Path "$_" -Destination $target -Recurse -Force
}
```

### 通过 Claude Code 对话自动安装（推荐）

如果你已经打开了 Claude Code，可以直接粘贴以下提示词，让 Claude 自动完成克隆、复制和验证：

````markdown
请帮我安装 DevForge SDLC Skill Chain。按以下步骤执行：

1. **克隆仓库**（如果当前目录没有 DevForge 文件则克隆，否则跳过）：
   ```bash
   if [ ! -d "DevForge" ]; then git clone https://github.com/lzj2819/DevForge-skill.git DevForge; fi
   ```

2. **复制 Skill 到 Claude Code 用户目录**：
   - macOS/Linux: 复制 `DevForge/` 下所有 `devforge-*`、`context-compression`、`extensions` 目录到 `~/.claude/skills/`
   - Windows: 复制到 `%USERPROFILE%\.claude\skills\`

   请自动检测当前操作系统并执行对应命令。如果目标目录已存在同名 Skill，覆盖即可。

3. **验证安装**：列出 `~/.claude/skills/` 下的 `devforge-*` 目录，确认至少有 10 个 Skill 目录。

4. **提示我重启 Claude Code**：告诉我安装完成，需要运行 `/reload` 或重启 Claude Code 使 Skill 生效。

执行前请向我确认操作系统类型和安装路径。
````

> **注意**：Claude Code 执行 Bash 命令时可能弹出权限确认框，请点击"允许"。安装完成后必须运行 `/reload` 或重启 Claude Code 才能加载新 Skill。

### 第一步：启动需求分析

在 Claude Code 中输入：

```
我想做一个 [你的产品想法]
```

Claude 会自动调用 `devforge-requirement-analysis`，引导你完成 PRD 构建。

---

## 安装与使用指南

### Skill 加载机制

Claude Code 通过扫描特定目录下的 `SKILL.md` 文件自动识别 Skill。每个 `devforge-*/` 目录下的 `SKILL.md` 即为一个独立 Skill，Claude 会根据文件内容自动解析触发条件和行为指令。

**安装路径（二选一）：**

| 级别 | 路径 | 适用场景 |
|:---|:---|:---|
| **全局** | `~/.claude/skills/` (macOS/Linux)<br>`%USERPROFILE%\.claude\skills` (Windows) | 所有项目共用 DevForge |
| **项目级** | `{project}/.claude/skills/` | 仅当前项目使用，便于版本控制 |

> **推荐**：个人开发者用全局路径；团队协作时建议放入项目级路径并提交到 Git，确保团队成员使用相同版本。

### 验证安装

重启 Claude Code 后，输入以下任一命令验证 Skill 是否加载成功：

```
/skill list
```

或直接在对话中输入：

```
帮我分析一下这个产品的需求
```

如果 Claude 回复中出现了 "我将使用 `devforge-requirement-analysis` 为你进行需求分析" 等类似提示，说明 Skill 已正确加载。

### 各阶段调用方式

**自动触发（无需记忆 Skill 名称）：**

| 你的输入 | Claude 调用的 Skill |
|:---|:---|
| `我想做一个 [产品想法]` | `devforge-requirement-analysis` |
| `[APPROVE]`（在阶段完成后） | 进入下一阶段 |

**手动触发（按需调用）：**

| 指令 | 调用的 Skill | 示例 |
|:---|:---|:---|
| `[MODULE {module_id}]` | `devforge-module-design` | `[MODULE UserService]` |
| `[NEXT MODULE]` | `devforge-module-design` | 完成当前模块，进入下一个 |
| `[VISUALIZE]` | `devforge-visualization` | 生成当前架构的 Mermaid 图 |
| `[OPS]` | `devforge-ops-ready` | 生成 Terraform + K8s 配置 |
| `[DEBUG]` | `devforge-debug-assistant` | 启动调试模式 |
| `[SECURITY_AUDIT]` | `devforge-security-audit` | 触发安全专项扫描 |

**增量迭代模式（已有项目）：**

```
我需要新增 [功能描述]
```

Claude 会自动调用 `devforge-iteration-planning` 进行影响分析。

### 更新与卸载

**更新到新版：**

```bash
# 1. 拉取最新代码
git pull origin main

# 2. 重新复制（覆盖旧版本）
cp -r devforge-* context-compression extensions ~/.claude/skills/

# 3. 重启 Claude Code
```

**卸载：**

```bash
# 删除 Skill 目录即可
rm -rf ~/.claude/skills/devforge-*
rm -rf ~/.claude/skills/context-compression
rm -rf ~/.claude/skills/extensions
```

### 故障排查

| 现象 | 可能原因 | 解决方案 |
|:---|:---|:---|
| Claude 没有自动调用 DevForge Skill | Skill 未放入正确路径 | 确认路径为 `~/.claude/skills/` 而非 `~/.claude/` 子目录 |
| 提示 "找不到 Skill" | 目录名或文件名不正确 | 确认目录名为 `devforge-requirement-analysis` 等，内部有 `SKILL.md` |
| `[MODULE]` 命令无效 | 尚未完成阶段 2 架构设计 | 先完成需求分析和架构设计，确保 `STATE.md` 存在 |
| 产物文件没有生成 | 权限问题或路径错误 | 检查当前目录是否有写权限，确认 `skill/artifacts/` 或 `docs/architecture/` 存在 |
| Skill 行为与文档不符 | 版本不匹配 | 运行 `git log --oneline -1` 确认版本为 v1.2+ |

---

## 10 个阶段速查表

| 阶段 | Skill 名称 | 触发条件 | 核心产物 |
|:---:|:---|:---|:---|
| 1 | `devforge-requirement-analysis` | 用户输入产品想法 | `PRD.md` + `DECISION_LOG.md` + 需求追溯矩阵(RTM) |
| 2 | `devforge-architecture-design` | PRD 已批准 `[APPROVE]` | `ARCHITECTURE.md` + `INTERFACE_CONTRACT.md` + `architecture.xml` + `schema.sql` + `openapi.yaml` |
| 3 | `devforge-architecture-validation` | 架构已批准 | `VALIDATION_REPORT.md` + `VALIDATION_DELTA.md` + `health-check.sh` |
| 4 | `devforge-design-review` | 架构已批准（可选） | `DESIGN_REVIEW.md`（问题清单，非 PASS/FAIL） |
| 5 | `devforge-project-scaffolding` | 架构/验证已批准 | `PROJECT_SCAFFOLD/`（完整工程目录 + CI/CD + 测试夹具 + `.env.template`） |
| 6 | `devforge-module-design` | 输入 `[MODULE {module_id}]` | `module-architecture.xml` + `component-spec.xml` + 模块级 PRD |
| 7 | `devforge-iteration-planning` | 初始脚手架完成后有新需求 | `ITERATION_PRD.md` + `ITERATION_PLAN.md` + 增量架构更新 |
| 8 | `devforge-visualization` | 输入 `[VISUALIZE]` | Mermaid 架构图（系统上下文、模块交互、数据流、ER 图） |
| 9 | `devforge-ops-ready` | 输入 `[OPS]` | Terraform + K8s manifests + Prometheus/Grafana + 蓝绿/金丝雀发布 + 运维手册 |
| 10 | `devforge-debug-assistant` | 输入 `[DEBUG]` 或测试失败 | `DEBUG_REPORT.md`（根因分析 + 修复方案）或 `REFACTOR_REPORT.md`（重构建议） |

### DIVE 循环映射

```
Design（设计）
  ├── 阶段 1: 需求分析 —— 锁定目标与边界
  ├── 阶段 2: 架构设计 —— 动态模式评估 + 三层 XML 建模
  └── 阶段 6: 模块细化 —— 组件分解与接口契约

Implement（实现）
  └── 阶段 5: 项目脚手架 —— XML 驱动代码生成 + CI/CD + 透明测试

Verify（验证）
  ├── 阶段 3: 架构验证 —— LLM 沙盘模拟 + 一致性审计
  └── 阶段 4: 设计审查 —— 对抗性审查（攻击者/运维/扩展者视角）

Evolve（演进）
  └── 阶段 7: 增量迭代 —— 影响分析 + 接口版本控制 + XML 同步

Visualize / Operate / Debug（可视化/运维/调试）
  ├── 阶段 8: 架构可视化
  ├── 阶段 9: 生产就绪基础设施
  └── 阶段 10: 调试与重构助手
```

---

## 目录结构

```
DevForge/
├── .claude-plugin/                  # Claude Code 插件元数据
│   ├── plugin.json
│   └── marketplace.json
├── .env.example                     # 环境变量模板（API Key、数据库、云凭证）
├── LICENSE                          # MIT 许可证
├── README.md                        # 本文件
├── DevForge.md                      # 原始单体中文设计文档（参考用）
├── devforge-design.md               # Skill 链分解设计文档 v1.2
├── devforge-state.md                # STATE.md 模板规范
│
├── references/                      # 共享参考文档
│   ├── architecture-patterns.md     # 10 种架构模式库
│   ├── xml-schemas.md               # 三层 XML Schema 定义
│   ├── system-prompt-template.md    # 全局角色定义 + VCMF 约束
│   ├── context-management-protocol.md # 分层摘要 + 产物加载规则
│   ├── validation-scripts-manifest.md # 脚本能力映射
│   └── search-integration.md        # 搜索集成规范
│
├── tools/                           # 工具规范
│   ├── error-tracing.md             # 错误追踪规范
│   ├── artifact-manager.md          # 产物管理规范
│   └── intervention-checkpoint.md   # 介入机制规范
│
├── scripts/                         # 实用脚本
│   ├── architecture-ci.sh           # 架构一致性 CI 检查（含安全检查）
│   ├── xml-sync.py                  # XML 同步与验证
│   └── package-plugin.py            # 打包分发脚本
│
├── devforge-requirement-analysis/   # 阶段 1: 需求分析
│   └── SKILL.md
├── devforge-architecture-design/    # 阶段 2: 架构设计
│   └── SKILL.md
├── devforge-architecture-validation/ # 阶段 3: 架构验证
│   └── SKILL.md
├── devforge-design-review/          # 阶段 4: 设计审查
│   └── SKILL.md
├── devforge-project-scaffolding/    # 阶段 5: 项目脚手架
│   └── SKILL.md
├── devforge-module-design/          # 阶段 6: 模块细化
│   └── SKILL.md
├── devforge-iteration-planning/     # 阶段 7: 增量迭代
│   └── SKILL.md
├── devforge-visualization/          # 阶段 8: 架构可视化
│   └── SKILL.md
├── devforge-ops-ready/              # 阶段 9: 生产就绪
│   └── SKILL.md
├── devforge-debug-assistant/        # 阶段 10: 调试助手
│   └── SKILL.md
├── devforge-security-audit/         # 安全扫描 Skill
│   └── SKILL.md
│
├── context-compression/             # 内部工具: 上下文压缩
│   └── SKILL.md
│
└── extensions/                      # 领域扩展（动态加载）
    ├── ai-agent-design/
    │   ├── SKILL.md
    │   └── references/
    │       ├── dimensions.md
    │       └── anti-patterns.md
    ├── data-pipeline-design/
    │   └── SKILL.md
    └── mobile-app-design/
        └── SKILL.md
```

---

## 人类门控命令

在每个阶段完成时，系统会暂停并等待人类审核。支持以下指令：

| 指令 | 作用 | 使用场景 |
|:---|:---|:---|
| `[APPROVE]` | 批准当前阶段输出，进入下一阶段 | 确认产物无误，继续推进 |
| `[PAUSE]` | 暂停当前流程，保留状态 | 需要中断思考或等待外部确认 |
| `[ROLLBACK]` | 回退到上一阶段重新执行 | 发现前一阶段产物存在根本性问题 |
| `[EXPLAIN]` | 要求系统解释当前产物的某个部分 | 不理解某段设计或代码的意图 |
| `[EDIT]` | 要求修改当前产物的特定部分 | 需要调整需求、接口或实现细节 |
| `[SKIP]` | 跳过当前可选阶段 | 对可选阶段（如可视化、运维）暂时不需要 |
| `[INJECT]` | 注入额外上下文或约束 | 临时补充业务规则或技术约束 |
| `[SECURITY_AUDIT]` | 触发安全专项审查 | 对敏感模块或整体架构进行安全加固检查 |

### 模块级专用指令

| 指令 | 作用 |
|:---|:---|
| `[MODULE {module_id}]` | 对指定模块进行详细设计 |
| `[NEXT MODULE]` | 完成当前模块，进入下一个模块设计 |
| `[VISUALIZE]` | 生成架构可视化图表 |
| `[OPS]` | 生成生产就绪基础设施配置 |
| `[DEBUG]` | 启动调试与诊断模式 |

---

## VCMF 五大核心原则

- **Design as Contract（设计即契约）** —— 代码必须服从文档，每个产物必须可追溯至需求或架构决策
- **Interface as Boundary（接口即边界）** —— 任何跨模块调用必须有显式输入/输出 Schema 和错误契约
- **Reality as Baseline（现实为基线）** —— Mock 测试验证流程，真实环境验证功能
- **State as Responsibility（状态即责任）** —— 谁创建、谁持久化、谁读取、谁清理必须文档化并强制执行
- **XML as Authority（XML 为权威）** —— `component-spec.xml` 是代码生成的唯一真相源，CI 自动检查一致性

---

## 环境配置

> **零配置即可启动。** DevForge 的 Skill 是纯 Markdown 文件，安装后即可使用。
>
> 但部分阶段需要外部 API 凭证才能发挥全部能力。未配置时，Skill 会优雅降级而非报错。

| 阶段 | 需要什么 | 无配置时的行为 |
|:---|:---|:---|
| 架构验证 | LLM API Key + Base URL | 回退到 Mock 数据模拟 + 一致性检查 |
| 项目脚手架 | 数据库/缓存连接字符串 | 生成 `.env.template` 占位符 |
| 生产就绪 | 云平台凭证 (AWS/Azure/GCP) | 生成 Terraform 配置，`terraform apply` 延后执行 |

快速配置：

```bash
cp .env.example .env
# 按需填写 LLM API、数据库、云凭证等
```

---

## 常见问题 FAQ

### Q1: DevForge 和普通的 AI 代码生成有什么区别？

**A:** 普通 AI 代码生成是"一次性提示 → 一次性输出"，缺乏架构一致性和可追溯性。DevForge 的核心差异在于：

1. **分阶段门控** —— 每个阶段必须人类 `[APPROVE]` 后才能进入下一阶段，防止 AI "自说自话跑完全程"
2. **XML 权威架构** —— 三层 XML（系统/模块/组件）作为代码生成的唯一真相源，CI 自动检查代码与 XML 的一致性
3. **状态持久化** —— `STATE.md` 跨会话保存完整推理链，新会话读取 200 字压缩摘要即可快速恢复上下文
4. **自校验机制** —— 每个产物在提交人类审核前，自动检查语法有效性、Schema 合规性、可追溯性和交叉引用完整性

### Q2: 我的项目已经在进行中，还能用 DevForge 吗？

**A:** 可以。DevForge 支持**增量迭代模式**：

1. 将现有项目的 PRD、架构文档放入 `skill/artifacts/` 目录
2. 手动创建 `STATE.md`，填写 `Immutable Goal` 和 `Module Registry`
3. 直接调用 `devforge-iteration-planning` 输入新需求
4. Skill 会自动进行影响分析，只修改受影响的模块，保持现有代码不动

对于已有代码库，也可以调用 `devforge-debug-assistant` 进行代码健康扫描和重构建议，无需从头走完整流程。

### Q3: 10 个阶段都必须走一遍吗？会不会太慢？

**A:** 不是必须的。DevForge 采用**强制 + 可选**的混合模式：

- **强制阶段（1→2→5）**：需求分析 → 架构设计 → 项目脚手架，这是最小可行路径
- **推荐阶段（3、4）**：架构验证和设计审查，对关键系统强烈建议
- **可选阶段（6-10）**：模块细化、迭代规划、可视化、运维、调试，按需触发

实际使用中，一个简单的 CRUD 应用可能 30 分钟完成（阶段 1→2→5），一个复杂微服务系统可能需要数小时（完整 10 阶段 + 多轮迭代）。

### Q4: 支持哪些编程语言和技术栈？

**A:** DevForge 是**语言无关**的架构方法论。架构设计阶段生成的 XML、接口契约、测试用例是通用的；脚手架阶段根据你的选择生成对应语言的代码：

- **后端**: Python/FastAPI、Node.js/Express、Java/Spring Boot、Go/Gin、Rust/Actix
- **前端**: React/Vue/Angular、Next.js、Flutter
- **数据库**: PostgreSQL、MySQL、MongoDB、Redis
- **基础设施**: Docker、Kubernetes、Terraform、AWS/Azure/GCP

技术栈选择通过 PRD 阶段的领域标签自动推断，也可在架构设计阶段手动指定。

### Q5: 如何确保 AI 不会"遗忘"最初的需求？

**A:** DevForge 通过三重机制防止需求漂移：

1. **Immutable Goal** —— `STATE.md` 中的原始目标和成功指标**永远不可覆盖**，每个 Skill 启动时必须先读取
2. **可追溯性矩阵（RTM）** —— 每个架构决策、接口定义、测试用例都标注关联的 PRD 需求编号
3. **决策日志（DECISION_LOG）** —— 所有关键决策按时间戳追加记录，包含问题、答案、风险和拒绝的替代方案

如果某个阶段的输出偏离了原始目标，你可以在门控时使用 `[ROLLBACK]` 回退，系统会保留完整的历史推理链。

### Q6: DevForge 如何保障生成代码的安全性？

**A:** DevForge 内置了多层安全机制：

1. **安全扫描 Skill** —— `devforge-security-audit` 自动检测硬编码密钥、SQL 注入、XSS、不安全依赖等 8 类漏洞
2. **依赖 CVE 检查** —— 推荐任何第三方库前，自动搜索其 CVE 和维护状态
3. **黑名单机制** —— 禁止推荐已知漏洞库（如 VM2、有 RCE 漏洞的库）
4. **架构层安全审查** —— `devforge-design-review` 从攻击者视角审查加密、鉴权、输入验证等设计缺陷

### Q7: 如果 AI 生成错误，如何追踪根因？

**A:** DevForge 的错误追踪机制（`tools/error-tracing.md`）确保每个报错都包含：

1. **TraceID** —— 唯一标识，关联到具体决策和需求
2. **决策上下文** —— 报错关联到哪个架构决策（DecisionID）
3. **修复建议** —— 具体步骤指导如何修复
4. **相关产物链路** —— 从 PRD → 架构 → 代码的完整追溯链

开发者可以回复 `[EXPLAIN {TraceID}]` 要求 AI 展开完整推理链。

### Q8: 多次迭代后产物会不会越来越混乱？

**A:** DevForge 的产物管理遵循 CRUD-Append 模式（`tools/artifact-manager.md`）：

1. **幂等更新** —— 已有内容不会被覆盖，只增量更新变更部分
2. **冲突检测** —— 如果 AI 要更新的区域包含手动修改标记，会生成冲突报告等待人工解决
3. **版本标记** —— 每个产物头部自动注入生成时间和更新规则
4. **Artifact Index** —— `STATE.md` 维护所有产物的快速索引，避免遗漏

---

## 相关文档

| 文档 | 路径 | 说明 |
|:---|:---|:---|
| 原始单体设计文档 | `DevForge.md` | 完整的中文设计文档，含 10 阶段详细工作流 |
| Skill 分解设计文档 | `devforge-design.md` | v1.2 分解设计，含 DIVE 映射和 VCMF 集成 |
| STATE 模板规范 | `devforge-state.md` | `STATE.md` 的 8 大字段定义和示例 |
| 架构模式库 | `references/architecture-patterns.md` | 10 种架构模式的评估维度 |
| XML Schema 定义 | `references/xml-schemas.md` | 三层 XML 的 Schema 规范 |
| 上下文管理协议 | `references/context-management-protocol.md` | 分层摘要 + Token 阈值 + 产物加载规则 |

---

## 贡献与生态

DevForge 是 [VClaw](https://github.com/lzj2819/vclaw) 项目的一部分。欢迎提交 Issue 和 PR。

如需打包分发：

```bash
python scripts/package-plugin.py --mode all --output ./dist
```

---

*Version: v1.2 | Last Updated: 2026-04-29*
