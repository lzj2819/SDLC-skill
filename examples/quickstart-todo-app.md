# QuickStart: Todo 应用

本示例展示如何使用 DevForge SDLC Skill Chain，从一句简单的需求描述开始，逐步生成一个可运行的 Todo 应用项目。

---

## 起点

**当前状态**：空目录（`mkdir todo-app && cd todo-app`）

**用户输入**：
> "我想做一个 Todo 应用，可以添加任务、标记完成、设置截止日期。"

---

## 阶段一：PRD 方法论对齐

### 输入
- 用户原始需求：`我想做一个 Todo 应用，可以添加任务、标记完成、设置截止日期。`
- 项目类型：Web 应用（默认全栈）
- 目标用户：个人用户

### AI 动作
1. 解析用户意图，识别核心功能（CRUD + 状态管理 + 时间属性）
2. 选择匹配的 SDLC 模板：`standard-web-app`
3. 初始化项目元数据（`PROJECT_META.md`）
4. 评估技术栈偏好（无特殊要求时采用推荐默认值）

### 产物

**PROJECT_META.md**
```markdown
# 项目元数据

## 基本信息
- 项目名称: Todo App
- 项目类型: Web Application
- 目标用户: 个人用户
- 创建日期: 2026-04-29

## 核心需求
1. 添加任务（任务名称、描述、截止日期）
2. 标记任务完成/未完成
3. 查看任务列表（按状态筛选）
4. 删除任务

## 技术栈（推荐）
- 前端: React + TypeScript + Tailwind CSS
- 后端: Node.js + Express
- 数据库: SQLite（开发）/ PostgreSQL（生产）
- 状态管理: React Context + useReducer

## 质量门禁
- 代码覆盖率 >= 80%
- Lighthouse 性能评分 >= 90
- 无高危安全漏洞
```

### 门控命令
```bash
# 验证项目元数据完整性
devforge validate --stage=1 --file=PROJECT_META.md

# 预期输出
[PASS] 项目元数据格式正确
[PASS] 核心需求已识别（4项）
[PASS] 技术栈推荐已生成
[INFO] 进入阶段二：敏捷 PRD 构建
```

---

## 阶段二：敏捷 PRD 构建

### 输入
- `PROJECT_META.md`
- 用户补充约束：无（使用默认值）

### AI 动作
1. 基于核心需求生成用户故事地图
2. 定义功能优先级（MoSCoW 法则）
3. 编写详细 PRD 文档，包含：
   - 用户故事与验收标准
   - 功能规格说明
   - 非功能需求（性能、安全、可用性）
   - 数据模型初稿
   - UI/UX 线框图描述

### 产物

**PRD.md**（内容概述）

```markdown
# Todo App 产品需求文档

## 1. 用户故事

### US-001 添加任务
**作为** 用户
**我希望** 创建一个新的待办任务
**以便** 记录我需要完成的工作

**验收标准：**
- 可以输入任务标题（必填，最多 100 字符）
- 可以输入任务描述（可选，最多 500 字符）
- 可以设置截止日期（可选，日期选择器）
- 提交后任务出现在列表顶部
- 标题为空时显示错误提示

### US-002 标记完成
**作为** 用户
**我希望** 将任务标记为已完成
**以便** 跟踪我的进度

**验收标准：**
- 每个任务旁有复选框
- 点击后任务状态切换（完成/未完成）
- 已完成的任务显示删除线样式
- 支持批量标记（可选）

### US-003 查看任务列表
**作为** 用户
**我希望** 按状态筛选任务
**以便** 专注于当前工作

**验收标准：**
- 默认显示所有任务
- 可按状态筛选：全部 / 进行中 / 已完成
- 任务按创建时间倒序排列
- 支持按截止日期排序

### US-004 删除任务
**作为** 用户
**我希望** 删除不需要的任务
**以便** 保持列表整洁

**验收标准：**
- 每个任务旁有删除按钮
- 删除前显示确认对话框
- 删除后任务不可恢复

## 2. 非功能需求

### 性能
- 首屏加载时间 < 2 秒
- 任务列表支持 1000+ 条目不卡顿

### 可用性
- 响应式设计，支持移动端
- 支持键盘快捷键（Enter 创建任务）

### 安全
- 输入防 XSS 过滤
- 本地数据持久化加密（可选）

## 3. 数据模型

```typescript
interface Task {
  id: string;           // UUID
  title: string;        // 任务标题
  description: string;  // 任务描述
  dueDate: Date | null; // 截止日期
  completed: boolean;   // 完成状态
  createdAt: Date;      // 创建时间
  updatedAt: Date;      // 更新时间
}
```

## 4. UI 线框图描述

### 主页面布局
```
+-----------------------------+
|  Todo App          [筛选器]  |
+-----------------------------+
|  [输入框...] [+ 添加]        |
+-----------------------------+
|  [ ] 买 groceries      [删除] |
|      截止日期: 2026-05-01    |
+-----------------------------+
|  [x] 完成报告          [删除] |
|      ~~截止日期: 2026-04-28~~ |
+-----------------------------+
|         [底部统计]           |
+-----------------------------+
```
```

### 门控命令
```bash
# 验证 PRD 完整性
devforge validate --stage=2 --file=PRD.md

# 预期输出
[PASS] 用户故事 >= 1 个（实际：4 个）
[PASS] 每个用户故事包含验收标准
[PASS] 数据模型已定义
[PASS] 非功能需求已覆盖（性能、安全、可用性）
[INFO] 进入阶段三：深度架构设计
```

---

## 阶段三：深度架构设计

### 输入
- `PROJECT_META.md`
- `PRD.md`

### AI 动作
1. 将 PRD 转化为技术架构文档
2. 定义系统边界与模块划分
3. 设计组件层次结构
4. 制定接口契约（前后端 API 规范）
5. 生成架构图描述

### 产物

#### architecture.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<architecture>
  <system name="TodoApp">
    <layer name="presentation">
      <component name="App" type="container">
        <component name="Header" type="ui"/>
        <component name="TaskInput" type="ui"/>
        <component name="TaskList" type="ui">
          <component name="TaskItem" type="ui"/>
        </component>
        <component name="TaskFilter" type="ui"/>
        <component name="TaskStats" type="ui"/>
      </component>
    </layer>
    
    <layer name="application">
      <component name="TaskContext" type="state-management"/>
      <component name="TaskReducer" type="business-logic"/>
      <component name="TaskActions" type="action-creator"/>
    </layer>
    
    <layer name="infrastructure">
      <component name="TaskRepository" type="repository"/>
      <component name="LocalStorageAdapter" type="storage"/>
      <component name="DateUtils" type="utility"/>
    </layer>
  </system>
  
  <patterns>
    <pattern name="Flux" applied-to="application-layer"/>
    <pattern name="Repository" applied-to="infrastructure-layer"/>
    <pattern name="Compound-Component" applied-to="TaskList"/>
  </patterns>
</architecture>
```

#### module-architecture.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<modules>
  <module name="todo-core" responsibility="核心业务逻辑">
    <exports>
      <export name="Task" type="interface"/>
      <export name="TaskStatus" type="enum"/>
      <export name="TaskFilterType" type="enum"/>
    </exports>
    <dependencies/>
  </module>
  
  <module name="todo-ui" responsibility="用户界面组件">
    <exports>
      <export name="TaskInput" type="component"/>
      <export name="TaskList" type="component"/>
      <export name="TaskItem" type="component"/>
      <export name="TaskFilter" type="component"/>
      <export name="TaskStats" type="component"/>
    </exports>
    <dependencies>
      <dependency module="todo-core"/>
      <dependency module="todo-state"/>
    </dependencies>
  </module>
  
  <module name="todo-state" responsibility="状态管理">
    <exports>
      <export name="TaskProvider" type="component"/>
      <export name="useTasks" type="hook"/>
      <export name="useTaskActions" type="hook"/>
    </exports>
    <dependencies>
      <dependency module="todo-core"/>
      <dependency module="todo-storage"/>
    </dependencies>
  </module>
  
  <module name="todo-storage" responsibility="数据持久化">
    <exports>
      <export name="StorageAdapter" type="interface"/>
      <export name="LocalStorageAdapter" type="class"/>
    </exports>
    <dependencies>
      <dependency module="todo-core"/>
    </dependencies>
  </module>
</modules>
```

#### component-spec.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<components>
  <component name="TaskInput">
    <props>
      <prop name="onSubmit" type="(task: Omit&lt;Task, 'id' | 'createdAt' | 'updatedAt'&gt;) => void" required="true"/>
    </props>
    <state>
      <state name="title" type="string" initial="''"/>
      <state name="description" type="string" initial="''"/>
      <state name="dueDate" type="string" initial="''"/>
      <state name="error" type="string | null" initial="null"/>
    </state>
    <validation>
      <rule field="title" condition="length > 0" error="标题不能为空"/>
      <rule field="title" condition="length <= 100" error="标题最多 100 字符"/>
    </validation>
    <accessibility>
      <role value="form"/>
      <label for="title-input" value="任务标题"/>
      <label for="description-input" value="任务描述"/>
      <label for="due-date-input" value="截止日期"/>
    </accessibility>
  </component>
  
  <component name="TaskItem">
    <props>
      <prop name="task" type="Task" required="true"/>
      <prop name="onToggle" type="(id: string) => void" required="true"/>
      <prop name="onDelete" type="(id: string) => void" required="true"/>
    </props>
    <render-conditions>
      <condition when="task.completed" style="text-decoration: line-through"/>
      <condition when="task.dueDate && isOverdue(task.dueDate)" style="color: red"/>
    </render-conditions>
  </component>
  
  <component name="TaskList">
    <props>
      <prop name="tasks" type="Task[]" required="true"/>
      <prop name="filter" type="TaskFilterType" required="true"/>
    </props>
    <computed>
      <computed name="filteredTasks" expression="tasks.filter(t => matchFilter(t, filter))"/>
    </computed>
  </component>
</components>
```

#### INTERFACE_CONTRACT.md
```markdown
# 接口契约

## 内部模块接口

### todo-core -> todo-state
```typescript
// 状态操作接口
interface TaskState {
  tasks: Task[];
  filter: TaskFilterType;
}

type TaskAction =
  | { type: 'ADD_TASK'; payload: Omit<Task, 'id' | 'createdAt' | 'updatedAt'> }
  | { type: 'TOGGLE_TASK'; payload: { id: string } }
  | { type: 'DELETE_TASK'; payload: { id: string } }
  | { type: 'SET_FILTER'; payload: { filter: TaskFilterType } };
```

### todo-state -> todo-storage
```typescript
// 存储适配器接口
interface StorageAdapter {
  load(): Promise<Task[]>;
  save(tasks: Task[]): Promise<void>;
}
```

### todo-ui -> todo-state
```typescript
// React Hooks 接口
function useTasks(): Task[];
function useTaskActions(): {
  addTask: (task: Omit<Task, 'id' | 'createdAt' | 'updatedAt'>) => void;
  toggleTask: (id: string) => void;
  deleteTask: (id: string) => void;
  setFilter: (filter: TaskFilterType) => void;
};
```

## 外部 API 接口（预留）

如需后端服务，REST API 规范如下：

```
GET    /api/tasks          # 获取任务列表
POST   /api/tasks          # 创建任务
PATCH  /api/tasks/:id      # 更新任务
DELETE /api/tasks/:id      # 删除任务
```

## 版本策略
- 内部模块：同步版本（统一迭代）
- 外部 API：语义化版本（SemVer）
```

### 门控命令
```bash
# 验证架构设计完整性
devforge validate --stage=3

# 预期输出
[PASS] architecture.xml 格式正确
[PASS] module-architecture.xml 依赖无循环
[PASS] component-spec.xml 组件定义完整
[PASS] INTERFACE_CONTRACT.md 接口已定义
[INFO] 进入阶段四：LLM 沙盘模拟
```

---

## 阶段四：LLM 沙盘模拟

### 输入
- `architecture.xml`
- `module-architecture.xml`
- `component-spec.xml`
- `INTERFACE_CONTRACT.md`

### AI 动作
1. 模拟架构执行流程
2. 检测潜在问题（循环依赖、性能瓶颈、安全漏洞）
3. 验证组件交互一致性
4. 生成风险评估报告

### 产物

**VALIDATION_REPORT.md**
```markdown
# 架构验证报告

## 执行摘要
- 验证时间: 2026-04-29
- 验证范围: 完整架构
- 总体评级: PASS（低风险）

## 详细结果

### 1. 依赖分析
- [PASS] 无循环依赖
- [PASS] 模块边界清晰
- [INFO] 建议：todo-storage 可进一步拆分为 sync/async 适配器

### 2. 性能评估
- [PASS] 组件渲染复杂度 O(n)
- [PASS] 状态更新路径 <= 3 层
- [WARN] TaskList 大数据量时建议虚拟滚动（>500 条）

### 3. 安全扫描
- [PASS] 输入验证已覆盖
- [PASS] XSS 防护策略已定义
- [INFO] 建议：LocalStorage 数据考虑加密存储

### 4. 可测试性
- [PASS] 业务逻辑与 UI 分离
- [PASS] 存储层可 Mock
- [PASS] 纯函数占比 > 80%

## 风险登记册
| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|----------|
| 本地存储容量限制 | 中 | 低 | 添加存储配额检查 |
| 多标签页数据同步 | 低 | 中 | 使用 storage 事件监听 |

## 建议优化
1. 添加任务搜索功能（未来迭代）
2. 考虑 IndexedDB 替代 LocalStorage（大数据量场景）
3. 添加导入/导出功能（数据备份）
```

### 门控命令
```bash
# 验证架构通过性
devforge validate --stage=4 --file=VALIDATION_REPORT.md

# 预期输出
[PASS] 验证报告格式正确
[PASS] 无阻塞性风险（CRITICAL/HIGH）
[PASS] 所有架构文档一致性检查通过
[INFO] 进入阶段五：实施脚手架
```

---

## 阶段五：实施脚手架

### 输入
- 所有前期文档（PRD.md、architecture.xml、component-spec.xml、INTERFACE_CONTRACT.md）
- `VALIDATION_REPORT.md`

### AI 动作
1. 初始化项目结构
2. 生成配置文件（package.json、tsconfig.json、vite.config.ts 等）
3. 按模块架构生成源代码：
   - 类型定义（todo-core）
   - 存储层（todo-storage）
   - 状态管理（todo-state）
   - UI 组件（todo-ui）
4. 生成测试文件
5. 生成 README 和启动脚本

### 产物

**完整项目结构（PROJECT_SCAFFOLD/）**
```
todo-app/
├── README.md
├── package.json
├── tsconfig.json
├── tsconfig.app.json
├── tsconfig.node.json
├── vite.config.ts
├── tailwind.config.js
├── postcss.config.js
├── index.html
├── .gitignore
├── .eslintrc.cjs
├── src/
│   ├── main.tsx
│   ├── App.tsx
│   ├── index.css
│   ├── types/
│   │   └── index.ts          # todo-core: Task, TaskFilterType
│   ├── storage/
│   │   ├── index.ts          # todo-storage: StorageAdapter, LocalStorageAdapter
│   │   └── __tests__/
│   │       └── storage.test.ts
│   ├── state/
│   │   ├── index.ts          # todo-state: TaskContext, useTasks, useTaskActions
│   │   ├── reducer.ts        # TaskReducer
│   │   └── __tests__/
│   │       └── reducer.test.ts
│   └── components/
│       ├── TaskInput.tsx     # 任务输入表单
│       ├── TaskItem.tsx      # 单个任务项
│       ├── TaskList.tsx      # 任务列表容器
│       ├── TaskFilter.tsx    # 筛选器
│       ├── TaskStats.tsx     # 统计信息
│       └── __tests__/
│           ├── TaskInput.test.tsx
│           └── TaskItem.test.tsx
└── e2e/
    └── todo.spec.ts          # Playwright 端到端测试
```

**关键代码片段**

`src/types/index.ts`
```typescript
export interface Task {
  id: string;
  title: string;
  description: string;
  dueDate: string | null;
  completed: boolean;
  createdAt: string;
  updatedAt: string;
}

export type TaskFilterType = 'all' | 'active' | 'completed';
```

`src/state/reducer.ts`
```typescript
import { Task, TaskFilterType } from '../types';

export interface TaskState {
  tasks: Task[];
  filter: TaskFilterType;
}

export type TaskAction =
  | { type: 'ADD_TASK'; payload: Omit<Task, 'id' | 'createdAt' | 'updatedAt'> }
  | { type: 'TOGGLE_TASK'; payload: { id: string } }
  | { type: 'DELETE_TASK'; payload: { id: string } }
  | { type: 'SET_FILTER'; payload: { filter: TaskFilterType } };

export function taskReducer(state: TaskState, action: TaskAction): TaskState {
  switch (action.type) {
    case 'ADD_TASK': {
      const now = new Date().toISOString();
      const newTask: Task = {
        ...action.payload,
        id: crypto.randomUUID(),
        createdAt: now,
        updatedAt: now,
      };
      return { ...state, tasks: [newTask, ...state.tasks] };
    }
    case 'TOGGLE_TASK':
      return {
        ...state,
        tasks: state.tasks.map(t =>
          t.id === action.payload.id ? { ...t, completed: !t.completed, updatedAt: new Date().toISOString() } : t
        ),
      };
    case 'DELETE_TASK':
      return { ...state, tasks: state.tasks.filter(t => t.id !== action.payload.id) };
    case 'SET_FILTER':
      return { ...state, filter: action.payload.filter };
    default:
      return state;
  }
}
```

`src/components/TaskInput.tsx`
```typescript
import { useState } from 'react';

interface TaskInputProps {
  onSubmit: (task: { title: string; description: string; dueDate: string | null }) => void;
}

export function TaskInput({ onSubmit }: TaskInputProps) {
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [dueDate, setDueDate] = useState('');
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim()) {
      setError('标题不能为空');
      return;
    }
    if (title.length > 100) {
      setError('标题最多 100 字符');
      return;
    }
    onSubmit({ title: title.trim(), description, dueDate: dueDate || null });
    setTitle('');
    setDescription('');
    setDueDate('');
    setError(null);
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-3 p-4 bg-white rounded-lg shadow">
      <div>
        <input
          type="text"
          value={title}
          onChange={e => setTitle(e.target.value)}
          placeholder="输入任务标题..."
          className="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
          aria-label="任务标题"
        />
      </div>
      <div>
        <textarea
          value={description}
          onChange={e => setDescription(e.target.value)}
          placeholder="任务描述（可选）"
          className="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
          rows={2}
          aria-label="任务描述"
        />
      </div>
      <div className="flex gap-3">
        <input
          type="date"
          value={dueDate}
          onChange={e => setDueDate(e.target.value)}
          className="px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
          aria-label="截止日期"
        />
        <button
          type="submit"
          className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 transition"
        >
          添加任务
        </button>
      </div>
      {error && <p className="text-red-500 text-sm">{error}</p>}
    </form>
  );
}
```

### 门控命令
```bash
# 验证项目脚手架
devforge validate --stage=5 --project=.

# 预期输出
[PASS] 项目结构符合架构定义
[PASS] 所有模块依赖关系正确
[PASS] TypeScript 编译通过
[PASS] 单元测试通过（12/12）
[PASS] ESLint 无错误
[INFO] 项目已就绪，可运行：npm run dev

# 启动项目
npm install
npm run dev

# 访问 http://localhost:5173
```

---

## 阶段六（按需）：模块细化

当某个模块需要独立开发或复用时触发。

**输入**：特定模块的 component-spec.xml
**AI 动作**：
1. 细化模块内部组件设计
2. 生成模块专属测试套件
3. 优化模块接口
**产物**：细化后的模块源码 + 模块级文档
**门控**：模块测试覆盖率 >= 90%

---

## 阶段七（按需）：增量迭代

当需要添加新功能时触发（如：任务分类、标签、优先级）。

**输入**：新增需求 + 现有 PRD.md + 现有架构文档
**AI 动作**：
1. 分析变更影响范围
2. 更新 PRD（追加用户故事）
3. 更新架构文档（如有结构变更）
4. 生成增量代码
**产物**：更新的 PRD.md + 增量补丁
**门控**：回归测试全部通过

---

## 阶段八（按需）：架构可视化

当需要生成架构图或文档时触发。

**输入**：architecture.xml + module-architecture.xml
**AI 动作**：
1. 生成 Mermaid/PlantUML 图表
2. 生成依赖关系图
3. 生成组件交互时序图
**产物**：
- `docs/architecture-diagram.md`
- `docs/dependency-graph.md`
- `docs/sequence-diagrams.md`
**门控**：图表与 XML 定义一致性检查

---

## 阶段九（按需）：生产就绪

当项目需要部署上线时触发。

**输入**：完整项目 + 部署目标（Vercel/Netlify/自有服务器）
**AI 动作**：
1. 生成生产环境配置
2. 优化构建输出
3. 配置 CI/CD 流水线
4. 生成部署脚本
5. 安全加固检查
**产物**：
- `.github/workflows/deploy.yml`
- `Dockerfile`（如需要）
- `nginx.conf`（如需要）
- 部署文档
**门控**：
```bash
devforge validate --stage=9
# [PASS] 生产构建成功
# [PASS] 安全扫描通过
# [PASS] 性能预算达标
```

---

## 阶段十（按需）：调试与重构

当遇到 Bug 或需要技术债务清理时触发。

**输入**：问题描述 + 相关代码 + 日志
**AI 动作**：
1. 问题定位与根因分析
2. 生成修复方案
3. 执行重构（如需要）
4. 更新测试用例
**产物**：修复后的代码 + 问题分析报告
**门控**：
```bash
devforge validate --stage=10
# [PASS] 问题复现测试通过
# [PASS] 修复后测试通过
# [PASS] 无回归问题
```

---

## 完整流程图

```
用户输入: "我想做一个 Todo 应用..."
    |
    v
+---+------------+
| 阶段一: PRD    | 输入 -> AI分析 -> PROJECT_META.md -> 验证
| 方法论对齐     |
+---+------------+
    |
    v
+---+------------+
| 阶段二: 敏捷   | PROJECT_META.md -> AI构建 -> PRD.md -> 验证
| PRD 构建       |
+---+------------+
    |
    v
+---+------------+
| 阶段三: 深度   | PRD.md -> AI设计 -> architecture.xml
| 架构设计       | + module-architecture.xml
|                | + component-spec.xml
|                | + INTERFACE_CONTRACT.md -> 验证
+---+------------+
    |
    v
+---+------------+
| 阶段四: LLM    | 架构文档 -> AI模拟 -> VALIDATION_REPORT.md
| 沙盘模拟       | -> 验证
+---+------------+
    |
    v
+---+------------+
| 阶段五: 实施   | 全部文档 -> AI生成 -> PROJECT_SCAFFOLD/
| 脚手架         | -> 验证 -> npm run dev
+---+------------+
    |
    v
+---+------------+
| 阶段六~十      | 按需触发（模块细化 / 增量迭代 /
| （按需阶段）   | 架构可视化 / 生产就绪 / 调试重构）
+----------------+
```

---

## 快速开始命令

```bash
# 1. 创建项目目录
mkdir todo-app && cd todo-app

# 2. 运行 DevForge 完整流程
devforge init --prompt "我想做一个 Todo 应用，可以添加任务、标记完成、设置截止日期。"

# 3. 进入项目并启动
cd PROJECT_SCAFFOLD/todo-app
npm install
npm run dev

# 4. 运行测试
npm test

# 5. 生产构建
npm run build
```

---

## 总结

通过 DevForge SDLC Skill Chain，我们从一句自然语言需求出发，经历了：

1. **需求对齐** — 明确项目边界与技术方向
2. **PRD 构建** — 将模糊需求转化为精确的用户故事与验收标准
3. **架构设计** — 定义系统结构、模块划分与接口契约
4. **沙盘验证** — 在编码前发现潜在风险
5. **代码生成** — 产出完整可运行的项目脚手架
6-10. **按需迭代** — 持续演进与维护

整个流程确保每一步都有明确的输入、AI 动作、产物和门控验证，让 AI 辅助开发从"黑盒猜测"变为"白盒工程"。
