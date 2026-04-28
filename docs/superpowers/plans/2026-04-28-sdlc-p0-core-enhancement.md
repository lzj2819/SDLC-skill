# SDLC-skill P0 核心交付物增强 — 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在现有核心 skill 中集成数据库 Schema 生成、OpenAPI 规范生成、测试覆盖率检查三项能力，补齐"设计→交付物"的断层。

**Architecture:** 通过扩展 `references/xml-schemas.md` 的 `DataModel` 定义增加 DDL 相关属性，在 `sdlc-architecture-design` 工作流中新增两个输出节点（DDL + OpenAPI），在 `sdlc-project-scaffolding` 的 CI 配置中集成覆盖率检查。

**Tech Stack:** Markdown 文档编辑、Mermaid 语法、GitHub Actions YAML、OpenAPI 3.0

---

## 文件变更清单

| 文件 | 操作 | 说明 |
|------|------|------|
| `references/xml-schemas.md` | 修改 | `DataModel` 节点增加 `Relationships` 和 DDL 属性 |
| `sdlc-architecture-design/SKILL.md` | 修改 | 新增第 10 步（DDL 生成）、第 11 步（OpenAPI 生成） |
| `sdlc-project-scaffolding/SKILL.md` | 修改 | CI/CD 第 7 步增加覆盖率 job |
| `docs/sync-rules.md` | 创建 | 文档同步规则（架构变更时同步更新哪些文件） |

---

### Task 1: 扩展 XML Schema — DataModel DDL 属性

**Files:**
- Modify: `references/xml-schemas.md:50-57`

- [ ] **Step 1: 修改 DataModel 定义，增加 DDL 相关属性**

找到 `DataModel` 定义段落，将：

```markdown
### `DataModel`
Defines system-wide data entities.

**DataModel children**:
- `Entity` (1+): Attributes: `id`, `module`
  - `Fields`: Contains `Field` nodes
    - `Field` attributes: `name`, `type`, `nullable` (boolean), `encrypted` (boolean, optional)
  - `CacheStrategy` (optional): Attributes: `type`, `ttl` (seconds)
```

替换为：

```markdown
### `DataModel`
Defines system-wide data entities.

**DataModel attributes**:
- `name` (required): Entity name (used as table/collection name in DDL)
- `ddlType` (optional): DDL target type — one of {table, view, collection}. Default: "table"
- `tableEngine` (optional): Database engine hint (e.g., "InnoDB", "MyISAM"). Only used when `ddlType="table"`

**DataModel children**:
- `Fields` (1): Contains `Field` nodes
  - `Field` attributes:
    - `name` (required): Column/field name
    - `type` (required): Logical type (string, int, long, float, double, boolean, datetime, uuid, text, json)
    - `required` (boolean, default "false"): Maps to NOT NULL when true
    - `nullable` (boolean, default "true"): When false, equivalent to `required="true"` (legacy, prefer `required`)
    - `primaryKey` (boolean, optional): Whether this field is the primary key
    - `length` (integer, optional): Max length for string types (maps to VARCHAR(length))
    - `unique` (boolean, optional): Whether a UNIQUE constraint should be created
    - `index` (boolean, optional): Whether a non-unique index should be created
    - `default` (string, optional): Default value expression (e.g., "CURRENT_TIMESTAMP", "0", "''")
    - `encrypted` (boolean, optional): Whether the field is encrypted at rest
    - `autoIncrement` (boolean, optional): Whether the field auto-increments (typically for primary keys)
  - `Field` children:
    - `Description` (optional): Human-readable field description
- `Relationships` (optional): Explicit foreign key and entity relationships
  - `Relationship` (1+): Attributes:
    - `type` (required): One of {one-to-one, one-to-many, many-to-many}
    - `target` (required): Target `DataModel/@name`
    - `foreignKey` (required): Local field name that references the target
    - `targetField` (optional): Target field name. Default: primary key of target
    - `onDelete` (optional): Referential action — one of {CASCADE, SET_NULL, RESTRICT, NO_ACTION}. Default: "RESTRICT"
    - `onUpdate` (optional): Referential action. Default: "CASCADE"
- `CacheStrategy` (optional): Attributes: `type`, `ttl` (seconds), `indexedFields` (comma-separated field names)
```

- [ ] **Step 2: 在 Cross-Layer Validation Rules 中增加 DDL 规则**

在 Rule 5 之后新增 Rule 6：

找到文件末尾的 Cross-Layer Validation Rules 部分，在 Rule 5 后面添加：

```markdown
### Rule 6: DDL Schema Validity
- `Field/@type` MUST be one of the supported logical types: string, int, long, float, double, boolean, datetime, uuid, text, json
- `Field/@length` MUST be specified when `type="string"` and a DDL is generated
- `Relationships/Relationship/@target` MUST reference an existing `DataModel/@name`
- `Relationships/Relationship/@foreignKey` MUST reference an existing `Field/@name` within the same `DataModel`
```

- [ ] **Step 3: 更新 Example 章节，展示新属性**

在文件末尾的 Example 章节中，System Level excerpt 后面追加一个 DataModel 示例：

找到：
```markdown
### System Level (excerpt)
```xml
<SystemArchitecture type="microservice" version="1.0.0">
```

在它前面插入：

```markdown
### DataModel Example (with DDL attributes)
```xml
<DataModel name="User" ddlType="table" tableEngine="InnoDB">
  <Fields>
    <Field name="id" type="uuid" required="true" primaryKey="true"/>
    <Field name="email" type="string" length="255" required="true" unique="true" index="true"/>
    <Field name="created_at" type="datetime" required="true" default="CURRENT_TIMESTAMP"/>
    <Field name="profile_id" type="uuid"/>
  </Fields>
  <Relationships>
    <Relationship type="one-to-one" target="Profile" foreignKey="profile_id" onDelete="SET_NULL"/>
  </Relationships>
  <CacheStrategy type="redis" ttl="3600" indexedFields="email"/>
</DataModel>
```
```

- [ ] **Step 4: 验证修改**

读取文件确认修改正确：
```bash
head -n 80 references/xml-schemas.md
```
Expected: 能看到更新后的 `DataModel` 定义，包含 `name`、`ddlType`、`tableEngine` 属性和 `Relationships` 子节点。

- [ ] **Step 5: 提交**

```bash
git add references/xml-schemas.md
git commit -m "feat(xml-schema): add DDL attributes and Relationships to DataModel

- Add DataModel attributes: name, ddlType, tableEngine
- Add Field attributes: primaryKey, length, unique, index, default, autoIncrement
- Add Relationships node with foreign key definitions
- Add Rule 6: DDL Schema Validity
- Add DataModel example with full DDL attributes

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

### Task 2: sdlc-architecture-design 新增第 10 步 — DDL 生成

**Files:**
- Modify: `sdlc-architecture-design/SKILL.md:65-83`

- [ ] **Step 1: 在 XML architecture modeling 之后插入 DDL 生成步骤**

找到 `sdlc-architecture-design/SKILL.md` 中第 5 步（XML architecture modeling）的结束位置。当前第 5 步之后直接是第 6 步（Architecture documentation）。

在 `## Output Specification` 之前的 `6. **Architecture documentation**` 之前，插入新的第 10 步。

具体位置：在以下内容之前插入：

```markdown
6. **Architecture documentation**
   - Write `skill/artifacts/ARCHITECTURE.md` containing:
```

插入内容：

```markdown
6. **Database Schema (DDL) Generation**
   - Read `architecture.xml` and extract all `DataModel` nodes
   - For each `DataModel`, generate SQL DDL:
     - `CREATE TABLE {DataModel/@name}` (when `ddlType="table"`)
     - Map `Field/@type` to SQL types:
       - string + length → VARCHAR(length)
       - string without length → TEXT
       - int → INT
       - long → BIGINT
       - float → FLOAT
       - double → DOUBLE
       - boolean → BOOLEAN (or TINYINT(1) for MySQL)
       - datetime → TIMESTAMP or DATETIME
       - uuid → CHAR(36) or UUID (PostgreSQL)
       - text → TEXT
       - json → JSON
     - `required="true"` or `nullable="false"` → NOT NULL
     - `primaryKey="true"` → PRIMARY KEY
     - `unique="true"` → UNIQUE constraint
     - `index="true"` → CREATE INDEX
     - `default` → DEFAULT {value}
     - `autoIncrement="true"` → AUTO_INCREMENT (MySQL) or SERIAL (PostgreSQL)
   - Generate `ALTER TABLE` for foreign keys from `Relationships/Relationship`:
     - `ALTER TABLE {source} ADD CONSTRAINT ... FOREIGN KEY ({foreignKey}) REFERENCES {target}({targetField}) ON DELETE {onDelete} ON UPDATE {onUpdate}`
   - Output `skill/artifacts/schema.sql`
   - Generate `skill/artifacts/ERD.md` using Mermaid `erDiagram` syntax:
     - Each `DataModel` → an entity
     - Each `Relationship` → a relationship line (1:1, 1:N, N:M)

7. **OpenAPI Specification Generation**
   - Read `INTERFACE_CONTRACT.md` and `architecture.xml`
   - Convert interface definitions to OpenAPI 3.0 format:
     - `openapi: 3.0.0` header with project name and version from STATE.md
     - `paths`: Each interface method → `/{module}/{endpoint}/{method}`
     - `requestBody`: Input schema with `$ref` to `#/components/schemas/{InputSchemaName}`
     - `responses/200`: Output schema with `$ref`
     - `responses/{code}`: Error codes from `ErrorCodes/Error`
     - `components/schemas`: Reuse `DataModel` definitions; define request/response DTOs for non-DataModel schemas
   - Output `skill/artifacts/openapi.yaml`
   - Ensure schema names are consistent between `openapi.yaml` and `schema.sql`
```

注意：插入后，原来的第 6-9 步自动顺延为第 8-11 步。

- [ ] **Step 2: 更新 Workflow 步骤编号**

由于插入了两个新步骤，原第 6-9 步需要重新编号为 8-11。

找到原第 6 步：
```markdown
6. **Architecture documentation**
```
改为：
```markdown
8. **Architecture documentation**
```

找到原第 7 步：
```markdown
7. **Decision Log update**
```
改为：
```markdown
9. **Decision Log update**
```

找到原第 8 步：
```markdown
8. **State update**
```
改为：
```markdown
10. **State update**
```

找到原第 9 步：
```markdown
9. **Human gate**
```
改为：
```markdown
11. **Human gate**
```

- [ ] **Step 3: 更新 Output Specification**

在 Output Specification 部分增加新输出物：

找到：
```markdown
## Output Specification

- `skill/artifacts/ARCHITECTURE.md`
- `skill/artifacts/INTERFACE_CONTRACT.md`
- `skill/artifacts/architecture.xml` (strict schema)
```

替换为：

```markdown
## Output Specification

- `skill/artifacts/ARCHITECTURE.md`
- `skill/artifacts/INTERFACE_CONTRACT.md`
- `skill/artifacts/architecture.xml` (strict schema)
- `skill/artifacts/schema.sql` (auto-generated from DataModel)
- `skill/artifacts/ERD.md` (Mermaid ER diagram)
- `skill/artifacts/openapi.yaml` (OpenAPI 3.0 spec)
```

- [ ] **Step 4: 验证修改**

读取文件确认步骤编号正确：
```bash
grep -n "^[0-9]\+\." sdlc-architecture-design/SKILL.md | head -20
```
Expected: 步骤从 1 到 11，包含新增的 DDL 和 OpenAPI 步骤。

- [ ] **Step 5: 提交**

```bash
git add sdlc-architecture-design/SKILL.md
git commit -m "feat(architecture-design): add DDL and OpenAPI generation steps

- Add Step 6: Database Schema (DDL) Generation from DataModel
- Add Step 7: OpenAPI 3.0 Specification Generation from Interface Contract
- Re-number subsequent steps (8-11)
- Update Output Specification with schema.sql, ERD.md, openapi.yaml

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

### Task 3: sdlc-project-scaffolding 新增覆盖率 CI Job

**Files:**
- Modify: `sdlc-project-scaffolding/SKILL.md:84-86`

- [ ] **Step 1: 在 CI/CD 第 7 步中增加覆盖率检查**

找到 `sdlc-project-scaffolding/SKILL.md` 第 7 步（CI/CD pipeline）的现有描述：

```markdown
7. **CI/CD pipeline**:
   - Generate CI config (e.g., `.github/workflows/ci.yml` or `.gitlab-ci.yml`)
   - Must include: dependency install, lint, mock test execution, real test execution (with `continue-on-error` or skip logic so missing API keys do not fail the build)
```

替换为：

```markdown
7. **CI/CD pipeline**:
   - Generate CI config (e.g., `.github/workflows/ci.yml` or `.gitlab-ci.yml`)
   - Must include: dependency install, lint, mock test execution, real test execution (with `continue-on-error` or skip logic so missing API keys do not fail the build)
   - **Coverage check job**: After test execution, run coverage analysis with minimum threshold:
     - Python: `pytest --cov=src --cov-report=xml --cov-report=term --cov-fail-under=80`
     - Node.js: `jest --coverage --coverageThreshold='{"global":{"lines":80}}'`
     - Java: `mvn jacoco:check` with `minimum` line ratio 0.80
     - Go: `go test -coverprofile=coverage.out ./...` + `go tool cover -func=coverage.out` with threshold check
     - Upload coverage report as artifact (e.g., `coverage.xml`, `coverage/`, `target/site/jacoco/`)
     - CI MUST fail if coverage is below the threshold
```

- [ ] **Step 2: 验证修改**

读取文件确认 CI/CD 步骤包含覆盖率：
```bash
grep -A 10 "Coverage check job" sdlc-project-scaffolding/SKILL.md
```
Expected: 能看到覆盖率检查的多种语言配置和阈值要求。

- [ ] **Step 3: 提交**

```bash
git add sdlc-project-scaffolding/SKILL.md
git commit -m "feat(scaffolding): add coverage check to CI/CD pipeline

- Add coverage check job with 80% threshold
- Support Python (pytest-cov), Node.js (jest), Java (jacoco), Go
- CI fails if coverage is below threshold
- Upload coverage report as artifact

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

### Task 4: 创建文档同步规则文件

**Files:**
- Create: `docs/sync-rules.md`

- [ ] **Step 1: 创建 sync-rules.md**

创建文件 `docs/sync-rules.md`，内容：

```markdown
# 文档同步规则

本文档定义当代码或架构发生变更时，哪些相关文档必须同步更新。

## 架构层变更同步规则

| 变更类型 | 影响文件 | 同步操作 |
|----------|----------|----------|
| `DataModel` 字段新增/修改/删除 | `schema.sql` | 重新生成 DDL |
| `DataModel` 字段新增/修改/删除 | `ERD.md` | 更新实体关系图 |
| `DataModel` 字段新增/修改/删除 | `openapi.yaml` | 更新 components/schemas |
| `Relationships` 新增/修改/删除 | `schema.sql` | 更新外键约束 |
| `Relationships` 新增/修改/删除 | `ERD.md` | 更新关系线 |
| `Module/Interface/Input` 或 `Output` 变更 | `INTERFACE_CONTRACT.md` | 更新接口定义 |
| `Module/Interface/Input` 或 `Output` 变更 | `openapi.yaml` | 更新 paths 和 schemas |
| `ErrorCodes` 新增/修改/删除 | `openapi.yaml` | 更新 responses |
| `ErrorCodes` 新增/修改/删除 | 所有相关 `component-spec.xml` | 更新 ErrorHandling 节点 |
| 新增 `Module` | `architecture.xml` | 追加 Module 节点 |
| 新增 `Module` | `module-architecture.xml` 模板 | 生成新模块模板 |
| 新增 `Component` | `module-architecture.xml` | 追加 Component 节点 |
| 新增 `Component` | `component-spec.xml` | 生成组件规格模板 |
| `ComponentSpec/Functions/Function/Signature` 变更 | 对应源代码文件 | 更新函数签名 |
| `ComponentSpec/Metadata/FilePath` 变更 | 源代码文件 | 移动或重命名文件 |

## 代码层变更同步规则

| 变更类型 | 影响文件 | 同步操作 |
|----------|----------|----------|
| 函数签名变更 | 对应 `component-spec.xml` | 更新 Signature 节点 |
| 新增错误处理分支 | 对应 `component-spec.xml` | 追加 Error 节点 |
| 新增外部依赖 | 对应 `component-spec.xml` | 追加 Dependency 节点 |
| 修改数据库表结构 | `schema.sql` | 更新 DDL（添加 migration） |
| 新增 API 端点 | `openapi.yaml` | 追加 path 定义 |
| 修改业务状态流转 | `architecture.xml` StateModel | 更新 State 生命周期 |

## CI 自动检查

以下同步规则由 CI 自动验证：

- `architecture-check` job 运行 `scripts/xml-sync.py --verify-only`：
  - 验证所有 `ModuleDetail/@ref` 和 `ComponentDetail/@ref` 指向存在的文件
  - 验证 `component-spec.xml` 的函数签名与源代码一致
  - 验证 `openapi.yaml` 的 schema 与 `DataModel` 一致

## 手动审查清单

提交 PR 前，请确认：

- [ ] `DataModel` 变更 → `schema.sql` 已更新
- [ ] `Interface` 变更 → `openapi.yaml` 已更新
- [ ] `ErrorCodes` 变更 → 所有相关 XML 已更新
- [ ] 新增模块 → 模块级 XML 模板已生成
- [ ] 函数签名变更 → `component-spec.xml` 已更新
```

- [ ] **Step 2: 提交**

```bash
git add docs/sync-rules.md
git commit -m "docs: add document synchronization rules

- Define sync rules for architecture changes (DataModel, Interface, ErrorCodes)
- Define sync rules for code changes (signatures, dependencies, endpoints)
- Document CI auto-check coverage
- Add manual review checklist

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```

---

### Task 5: 验证所有修改的一致性

- [ ] **Step 1: 验证 xml-schemas.md 与 sdlc-architecture-design 的一致性**

确认 `sdlc-architecture-design` 中引用的属性名称与 `xml-schemas.md` 定义一致：

检查清单：
- `DataModel/@name` ✓
- `DataModel/@ddlType` ✓
- `DataModel/@tableEngine` ✓
- `Field/@primaryKey` ✓
- `Field/@length` ✓
- `Field/@unique` ✓
- `Field/@index` ✓
- `Field/@default` ✓
- `Field/@autoIncrement` ✓
- `Relationships/Relationship/@type` ✓
- `Relationships/Relationship/@target` ✓
- `Relationships/Relationship/@foreignKey` ✓
- `Relationships/Relationship/@onDelete` ✓
- `Relationships/Relationship/@onUpdate` ✓

- [ ] **Step 2: 验证 sdlc-project-scaffolding 覆盖率配置完整**

确认覆盖率 job 的描述包含所有必要元素：
- 多种语言支持 ✓
- 80% 阈值 ✓
- 上传 artifact ✓
- CI 失败机制 ✓

- [ ] **Step 3: 最终提交**

```bash
git log --oneline -5
```
Expected: 能看到 4 个提交，按 Task 1-4 的顺序。

---

## Spec 覆盖度检查

| Spec 要求 | 实现任务 | 状态 |
|-----------|----------|------|
| DataModel → SQL DDL 生成 | Task 1 + Task 2 Step 1 | ✅ |
| DataModel → ERD (Mermaid) 生成 | Task 1 + Task 2 Step 1 | ✅ |
| Interface Contract → OpenAPI 生成 | Task 2 Step 1 | ✅ |
| CI/CD 覆盖率检查 (80% 阈值) | Task 3 | ✅ |
| 文档同步规则 | Task 4 | ✅ |
| XML Schema 扩展 (Relationships, DDL 属性) | Task 1 | ✅ |
| 类型映射表 (string→VARCHAR 等) | Task 2 Step 1 | ✅ |
| 外键约束生成 (ALTER TABLE) | Task 2 Step 1 | ✅ |
| 多语言覆盖率支持 (Python/Node/Java/Go) | Task 3 Step 1 | ✅ |
| CI 自动检查 (xml-sync.py) | Task 4 | ✅ |

---

## 执行后验证

完成所有任务后，运行以下检查确认 P0 完成：

```bash
# 1. 确认所有文件已修改/创建
git diff --name-only HEAD~4
# Expected: references/xml-schemas.md, sdlc-architecture-design/SKILL.md, sdlc-project-scaffolding/SKILL.md, docs/sync-rules.md

# 2. 确认 xml-schemas.md 包含 Relationships
grep -n "Relationships" references/xml-schemas.md

# 3. 确认 architecture-design 包含 DDL 和 OpenAPI 步骤
grep -n "Database Schema" sdlc-architecture-design/SKILL.md
grep -n "OpenAPI" sdlc-architecture-design/SKILL.md

# 4. 确认 scaffolding 包含覆盖率
grep -n "Coverage check job" sdlc-project-scaffolding/SKILL.md

# 5. 确认 sync-rules.md 存在
ls docs/sync-rules.md
```
