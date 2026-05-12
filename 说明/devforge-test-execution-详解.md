# DevForge Test Execution 深度解析

> 本文档基于 DevForge SDLC Skill Chain v1.4 的 `devforge-test-execution` 技能定义（`SKILL.md`）进行深度分析。
>
> **定位**：Stage 6，属于 DIVE 工作流的 **Verify（验证）** 阶段。
> **核心目标**：回答"测试代码是否真的在运行并通过？"——将"已存在的测试"转化为"可验证的质量数据"。
> **关键约束**：只执行已有测试，不生成新测试；三层测试都必须执行；覆盖率不低于 80%。

---

## 一、整体流程概览（8个步骤）

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  Step 1: 测试清单加载（Test Checklist Load）                                   │
│       ↓                                                                     │
│  Step 2: 环境准备（Environment Preparation）                                   │
│       ↓                                                                     │
│  Step 3: 单元测试执行（Unit Test Execution）                                   │
│       ↓                                                                     │
│  Step 4: 集成测试执行（Integration Test Execution）                            │
│       ↓                                                                     │
│  Step 5: 端到端测试执行（End-to-End Test Execution）                            │
│       ↓                                                                     │
│  Step 6: 测试报告生成（Test Report Generation）                                │
│       ↓                                                                     │
│  Step 7: RTM 同步（RTM Synchronization）                                       │
│       ↓                                                                     │
│  Step 8: 人机关卡（Human Gate）                                               │
│       ↓                                                                     │
│  [DEBUG] → 进入 devforge-debug-assistant（可选）                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 二、输入来源（上游产物）

| 输入文件 | 来源阶段 | 在 Test Execution 中的用途 |
|---------|---------|------------------------|
| `RTM.md` | requirement-analysis（初始） | 提取测试清单，检查覆盖率缺口 |
| `PRD.md` | requirement-analysis | 端到端测试的验收标准基准 |
| `component-spec.xml` | module-design | 测试断言必须与函数签名匹配 |
| `tests/mock/` | module-design / scaffolding | 单元测试代码 |
| `tests/real/` | module-design / scaffolding | 集成测试代码 |
| `tests/end_to_end/` | module-design / scaffolding | 端到端测试代码 |
| `.env` / `.env.template` | scaffolding | 环境变量配置，决定 mock/real 模式 |
| 依赖配置文件 | scaffolding | `requirements.txt`、`package.json` 等 |

---

## 三、每一步详解与调用的工具

### Step 1: 测试清单加载（Test Checklist Load）

#### 做什么？
1. 读取 `RTM.md`，提取所有已有 `Test Case ID` 的行
2. 按模块分组
3. 识别**缺少测试覆盖**的 P0/P1 需求
4. 生成 `TEST_COVERAGE_GAP.md`

#### TEST_COVERAGE_GAP.md 内容

| 列 | 说明 |
|---|------|
| Requirement ID | 需求标识 |
| User Story | 关联的用户故事 |
| Priority | P0 / P1 / P2 |
| Module | 所属模块 |
| Status | `missing_test`（无测试）/ `test_generated`（有测试但尚未执行） |
| Action | 建议的补测动作 |

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Read` | 读取 `RTM.md` |
| `Write` | 生成 `TEST_COVERAGE_GAP.md` |

#### 为什么这样设计？
- **测试清单先行**：在执行之前先知道"应该测什么"，防止遗漏
- **P0/P1 优先**：核心需求必须有测试覆盖，P2 可以容忍缺口
- **覆盖率缺口的显性化**：TEST_COVERAGE_GAP 让团队知道"哪些需求还没有测试"，而不是事后才发现

---

### Step 2: 环境准备（Environment Preparation）

#### 做什么？
1. **检查 `.env` 文件**：
   - 如果存在 → 可以运行真实 LLM 测试
   - 如果不存在 → 配置为 mock-only 模式
2. **安装依赖**：
   - Python: `pip install -r requirements.txt`
   - Node.js: `npm install`
   - Java: `mvn install`
   - Go: `go mod download`

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Bash` | 检查 `.env`、安装依赖 |

#### 为什么这样设计？
- **环境即测试的一部分**：测试环境不稳定会导致测试结果不可信
- **Mock 模式降级**：没有 API Key 时不阻塞测试，而是切换到 mock-only 模式——体现优雅降级
- **依赖安装自动化**：开发者不需要手动执行安装命令

---

### Step 3: 单元测试执行（Unit Test Execution）

#### 做什么？
运行 `tests/mock/` 目录下的所有单元测试：

| 语言 | 命令 | 覆盖率报告 |
|------|------|-----------|
| Python | `pytest tests/mock/ --cov=src --cov-report=xml --cov-report=term` | `coverage.xml` |
| Node.js | `jest tests/mock/ --coverage` | `coverage/` 目录 |
| Java | `mvn test` + `mvn jacoco:report` | `target/site/jacoco/` |
| Go | `go test -coverprofile=coverage.out ./tests/mock/...` | `coverage.out` |

**如果覆盖率 < 80%，标记 `coverage_failure`。**

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Bash` | 执行测试命令 |

#### 为什么这样设计？
- **Mock 测试是单元测试的主力**：不依赖外部服务，执行快、稳定性高
- **覆盖率是硬性门槛**：80% 是 DevForge 的默认质量门禁
- **覆盖率报告标准化**：生成 XML/JSON 格式的覆盖率报告，便于 CI 集成和趋势对比

---

### Step 4: 集成测试执行（Integration Test Execution）

#### 做什么？
运行 `tests/real/` 目录下的集成测试：

| 场景 | 处理方式 |
|------|---------|
| **有 API Key**（`.env` 存在） | 运行真实 LLM 测试 |
| **无 API Key**（`.env` 不存在） | 测试被 `skipif` 自动跳过，标记为 `skipped` |

统计结果：skipped vs passed vs failed

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Bash` | 执行集成测试命令 |

#### 为什么这样设计？
- **真实集成验证**：mock 测试验证逻辑，real 测试验证集成——两者互补
- **`skipif` 机制**：无 API Key 时自动跳过，不失败也不阻塞——避免开发者因为没有 API Key 而无法运行测试套件
- **统计分离**：明确区分"跳过"、"通过"、"失败"三种状态

---

### Step 5: 端到端测试执行（End-to-End Test Execution）

#### 做什么？
1. 读取 `PRD.md` 的 User Stories
2. 确保每个 **P0 用户故事**都有对应的端到端测试
3. 运行 `tests/end_to_end/` 目录下的测试
4. 将失败映射到 PRD 需求 ID

#### E2E 测试文件头规范
```python
# E2E Test: US-001 — User Login Flow
# Source: PRD.md::User Stories::US-001
# Acceptance Criteria: AC-1.1, AC-1.2
```

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Read` | 读取 `PRD.md` 用户故事 |
| `Bash` | 执行端到端测试 |

#### 为什么这样设计？
- **P0 全覆盖**：端到端测试验证完整用户流程，P0 用户故事没有 E2E 测试 = 高风险
- **PRD 可追溯**：E2E 测试头注释标明它验证哪个用户故事、哪些验收标准——失败时能快速定位到需求
- **三层测试金字塔**：
  ```
        /\
       /  \     E2E (少而精，覆盖核心流程)
      /____\
     /      \   Integration (中等数量，覆盖模块间交互)
    /________\  Unit (大量，覆盖组件内部逻辑)
  ```

---

### Step 6: 测试报告生成（Test Report Generation）

#### 做什么？
生成 `TEST_REPORT.md`，包含：

| 章节 | 内容 |
|------|------|
| **Summary** | 单元/集成/端到端的通过率 |
| **Coverage Trend** | 与上次运行的覆盖率对比趋势 |
| **Failure Details** | 失败测试 → 失败原因 → 关联的 PRD 需求 → 修复方向 |
| **Missing Coverage** | 没有 Test Case ID 的 P0/P1 需求 |

#### Failure Details 示例
```markdown
### Failure: test_login_invalid_password (TC-UserService-AuthController-002)

- **Test**: `tests/mock/UserService/auth_controller_test.py::test_login_invalid_password`
- **Reason**: `AssertionError: expected 401, got 200`
- **PRD Requirement**: REQ-001 (User Authentication)
- **Component**: `component-spec.xml::AuthController::login`
- **Fix Direction**: AuthController.login() 未正确处理无效密码场景，需补充错误处理逻辑
```

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Write` | 生成 `TEST_REPORT.md` |

#### 为什么这样设计？
- **可操作的报告**：不是简单的"通过了 X 个，失败了 Y 个"，而是"失败了哪个测试、为什么失败、对应哪个需求、怎么修"
- **覆盖率趋势**：与上次运行对比，判断质量是在改善还是恶化
- **Failure → PRD → Component 的链路**：让开发者从测试失败快速定位到需要修改的代码位置

---

### Step 7: RTM 同步（RTM Synchronization）

#### 做什么？
更新 `RTM.md` 的测试相关列：

| 测试结果 | RTM Status 更新 |
|---------|----------------|
| **测试通过** | `Status` → `tested` |
| **测试失败** | `Status` → `implemented`（**不降级为 pending**） |
| **缺少测试** | `Status` 保持原值（通常是 `implemented`） |

同时更新 `Test Case ID` 列（如测试用例有新增）。

#### 调用的工具
| 工具 | 用途 |
|------|------|
| `Read` | 读取当前 `RTM.md` |
| `Edit` / `Write` | 更新 RTM 的 Test Case ID 和 Status 列 |

#### 为什么这样设计？
- **RTM 的实时更新**：测试执行结果立即反映到需求追溯矩阵中
- **不降级原则**：失败的测试状态从 `implemented` 保持为 `implemented`，而不是降级为 `pending`。因为代码已经实现了（只是有 bug），需求的状态不应该回退
- **可追溯性的闭环**：PRD → 模块设计 → 代码实现 → 测试执行 → RTM 更新，形成完整链条

---

### Step 8: 人机关卡（Human Gate）

#### 做什么？
1. 展示测试报告摘要：
   ```
   测试报告已生成。单元测试通过率 X%，集成测试通过率 Y%，端到端测试通过率 Z%。
   ```
2. 列出可用命令

#### 可用命令

| 命令 | 作用 | 可用条件 |
|------|------|---------|
| `[APPROVE]` | 标记测试阶段完成 | always |
| `[DEBUG]` | 进入调试模式修复失败 | **仅在有失败测试时可用** |
| `[RETEST]` | 重新运行所有测试 | always |
| `[PAUSE]` | 暂停当前阶段 | always |
| `[ROLLBACK {step_id}]` | 回滚到指定步骤 | always |
| `[EDIT {file_path}]` | 手动编辑文件 | always |
| `[INJECT {context}]` | 补充上下文约束 | always |
| `[EXPLAIN {TraceID}]` | 展开解释推理链 | always |

#### 关键约束：HARD-GATE
```markdown
<HARD-GATE>
Do NOT allow transition to iteration-planning or ops-ready if tests are failing 
or coverage is below the configured threshold. 
Test failures must be resolved or explicitly [FORCE_APPROVE]d before proceeding.
</HARD-GATE>
```

#### 为什么这样设计？
- **质量门禁**：测试失败或覆盖率不足时，不能自动进入后续阶段
- **`[DEBUG]` 的衔接**：发现测试失败 → `[DEBUG]` → 进入 `devforge-debug-assistant` → 修复 → `[RETEST]` → 验证
- **`[RETEST]` 的必要性**：开发者可能手动修复了代码，需要重新运行测试验证
- **与 architecture-validation（3a）HARD-GATE 的对比**：
  - validation（3a）失败 → 系统自动阻止继续
  - test-execution（6）失败 → 可以通过 `[DEBUG]` 修复后再继续，或通过 `[FORCE_APPROVE]` 人为决定继续

---

## 四、核心输出产物清单

| 产物 | 路径 | 作用 | 下游消费者 |
|------|------|------|-----------|
| **TEST_REPORT.md** | `docs/architecture/validation/TEST_REPORT.md` | 完整测试报告（通过率、覆盖率趋势、失败详情） | 开发者（修复参考）、iteration-planning（质量评估） |
| **TEST_COVERAGE_GAP.md** | `docs/architecture/validation/TEST_COVERAGE_GAP.md` | 缺少测试覆盖的需求清单 | module-design（补测指导）、iteration-planning（技术债务） |
| **RTM.md（更新）** | `docs/architecture/system/RTM.md` | 测试状态和 Test Case ID 更新 | 全链条技能（状态追踪） |
| **覆盖率报告** | `coverage.xml` / `coverage/` / `target/site/jacoco/` | 机器可读的覆盖率数据 | CI/CD（门禁判断） |

---

## 五、流程设计哲学深度解析

### 1. 为什么 Test Execution 不生成测试，只执行测试？

这是 test-execution 与 module-design 的明确分工：

| 阶段 | 职责 | 原因 |
|------|------|------|
| **module-design** | 生成测试用例和测试代码 | 测试用例需要基于组件设计（component-spec.xml），在 design 阶段生成最合理 |
| **test-execution** | 执行已有测试并分析报告 | 执行是验证行为，与设计行为分离——关注点分离 |

**反面场景**：如果 test-execution 也生成测试：
- 测试质量难以保证（生成者也是执行者，缺乏独立验证）
- 测试与设计的耦合不清晰
- 执行逻辑变得复杂（既要生成又要执行）

### 2. 为什么 RTM 失败状态不降级为 pending？

**关键设计决策**：

| 状态 | 含义 | 测试失败时的处理 |
|------|------|----------------|
| `pending` | 尚未实现 | ❌ 不降级 |
| `designed` | 设计完成 | ❌ 不降级 |
| `implemented` | 代码已实现 | ✅ 保持为 `implemented` |
| `tested` | 测试通过 | ❌ 测试失败时不能标记为 `tested` |

**原因**：
- **语义准确性**：`implemented` 表示"代码已经写了"，测试失败不改变"代码已写"这个事实
- **防止状态震荡**：如果失败就降级为 `pending`，修复后再升为 `implemented`，状态会反复震荡
- **工作流完整性**：需求的状态演进应该是单向的（pending → designed → implemented → tested → verified），不应该回退

### 3. 为什么三层测试都要执行？

| 测试层级 | 验证目标 | 执行速度 | 稳定性 |
|---------|---------|---------|--------|
| **Unit (Mock)** | 组件内部逻辑 | 快 | 高 |
| **Integration (Real)** | 模块间交互、真实 LLM 集成 | 中等 | 中等（依赖外部服务） |
| **End-to-End** | 完整用户流程 | 慢 | 高 |

**缺少任何一层的后果**：
- 缺少 Unit → 组件内部逻辑未经验证，bug 隐藏
- 缺少 Integration → 模块间接口问题（如 JSON 格式不匹配）无法发现
- 缺少 E2E → 用户流程断裂（如"登录后跳转失败"）无法发现

**三层测试是互补的**，不是替代关系。

### 4. 为什么覆盖率阈值是 80% 且 CI 必须失败？

| 阈值 | 含义 | DevForge 选择 |
|------|------|--------------|
| 60% | 基础覆盖 | ❌ 不足以保证质量 |
| **80%** | **良好覆盖** | ✅ **默认阈值** |
| 90% | 严格覆盖 | 金融/医疗等高风险行业可配置 |
| 100% | 完全覆盖 | 理想状态，实际难以维持 |

**"CI 必须失败"的设计意图**：
- **自动化 enforcement**：不需要人工审查每个 PR 的覆盖率
- **防止技术债务累积**：如果允许低覆盖率代码合并，技术债务会指数增长
- **Quality Gates 的可配置性**：STATE.md 中的 Quality Gates 允许项目根据风险等级调整阈值

### 5. 为什么 TEST_COVERAGE_GAP 在测试执行前生成？

**顺序的重要性**：

```
Step 1: 加载 RTM → 生成 TEST_COVERAGE_GAP（"应该测什么"）
Step 3-5: 执行测试（"实际测了什么"）
Step 6: 生成 TEST_REPORT → 包含 Missing Coverage（"还有什么没测"）
```

**原因**：
- **期望管理**：在执行之前先告诉用户"这些需求还没有测试"
- **防止盲目乐观**：即使所有现有测试都通过了，也可能有需求完全没有测试覆盖
- **与 TEST_REPORT 的互补**：
  - TEST_COVERAGE_GAP = "哪些需求没有测试"（基于 RTM 的需求视角）
  - TEST_REPORT Missing Coverage = "哪些代码路径没有覆盖"（基于代码的覆盖率视角）

---

## 六、与 DIVE 工作流的关系

```
Design                          Implement                    Verify
   │                               │                           │
   ├── requirement-analysis        │                           │
   ├── architecture-design         │                           │
   │      │                        │                           │
   │      ↓                        │                           │
   │  [APPROVE]                    │                           │
   │      │                        │                           │
   ├── architecture-validation     │                           │
   ├── design-review               │                           │
   │      │                        │                           │
   │      ↓                        ↓                           │
   │  [APPROVE]               scaffolding                     │
   │                               │                           │
   │      [APPROVE]                ↓                           │
   │                          module-design                    │
   │                               │                           │
   │      [APPROVE]                ↓                           ↓
   │                          ┌──────────┐                     │
   │                          │ test-    │ ← 你在这里           │
   │                          │ execution│   (执行+分析+报告)    │
   │                          └──────────┘                     │
   │                               │                           │
   │                          [APPROVE/DEBUG]                  │
   │                               │                           │
   │                               ↓                           │
   │                          iteration-planning               │
   │                          (Evolve)                         │
   │                               │                           │
   └───────────────────────────────┴───────────────────────────┘
```

Test-execution 是 **Verify 阶段的最终执行者**——它将 design 和 implement 阶段的产物转化为可量化的质量数据。

---

## 七、VCMF 五原则在 Test Execution 中的体现

| VCMF 原则 | 在 Test Execution 中的体现 |
|-----------|--------------------------|
| **Design as Contract** | 每个失败测试必须映射回 PRD 需求 ID（TEST_REPORT Failure Details）；RTM 同步确保测试状态与需求状态关联 |
| **Interface as Boundary** | 测试输入/输出必须与 `component-spec.xml` 签名匹配；集成测试验证模块间接口在真实环境下的行为 |
| **Reality as Baseline** | 覆盖率报告必须生成并与 80% 阈值对比；三层测试（mock/real/e2e）覆盖不同现实场景；E2E 测试基于 PRD 验收标准 |
| **State as Responsibility** | 状态生命周期测试验证 `StateModel` 的所有权（create/read/update/delete/cleanup）；确保状态操作由正确组件执行 |
| **XML as Authority** | 测试断言验证代码行为是否符合 `component-spec.xml` 的函数契约；如果代码行为偏离 spec，测试应失败 |

---

## 八、与其他技能的协作边界

### 与 `devforge-module-design`（上游）的关系

```
module-design (5) ──→ test-execution (6)
    测试代码              执行测试代码
    component-spec.xml    测试断言基准
    module-prd.md         E2E 测试来源
    tests/mock/           单元测试输入
    tests/real/           集成测试输入
    tests/end_to_end/     E2E 测试输入
```

### 与 `devforge-debug-assistant`（下游衔接）的关系

```
test-execution (6) ──→ [DEBUG] ──→ debug-assistant (10)
    测试失败报告            根因分析和修复建议
    TEST_REPORT.md         DEBUG_REPORT.md
```

**衔接机制**：
- 测试执行发现失败 → 人机关卡提供 `[DEBUG]` 命令
- 用户选择 `[DEBUG]` → 触发 `devforge-debug-assistant`
- debug-assistant 分析失败原因 → 生成修复方案
- 修复后 → `[RETEST]` → 重新运行 test-execution 验证

### 与 `devforge-iteration-planning`（下游）的关系

```
test-execution (6) ──→ [APPROVE] ──→ iteration-planning (7)
    TEST_REPORT.md          质量基线
    TEST_COVERAGE_GAP.md    技术债务清单
```

### 与 `devforge-ops-ready`（下游可选）的关系

```
test-execution (6) ──→ [APPROVE] ──→ ops-ready (9)
    覆盖率报告              监控告警基线
```

---

## 九、总结

`devforge-test-execution` 是 DevForge 链条中的**质量验证执行者**。它的核心价值在于：

1. **从"有测试"到"测试在运行"**：将 module-design 生成的测试代码实际执行，转化为可量化的质量数据
2. **三层测试全覆盖**：Unit + Integration + E2E 形成完整的测试金字塔
3. **覆盖率硬性门槛**：80% 阈值 + CI 失败机制确保质量标准不被妥协
4. **可追溯的报告**：每个失败都链接到 PRD 需求和 component-spec，提供可操作的修复方向
5. **RTM 实时同步**：测试状态即时反映到需求追溯矩阵，保持可追溯性闭环
6. **与 Debug 的无缝衔接**：`[DEBUG]` 命令让测试失败 → 根因分析 → 修复 → 重新验证的流程自动化

它是 DIVE 工作流 **Verify 阶段的终点**——设计被验证、实现被测试、质量被量化。只有通过 test-execution 的验证，项目才有资格进入 Evolve（迭代）或 Operate（运维）阶段。

---

> 生成日期：2026-05-12
> 基于：DevForge SDLC Skill Chain v1.4
> 关联文档：devforge-module-design-详解.md（Stage 5）、devforge-debug-assistant/SKILL.md（Stage 10）
