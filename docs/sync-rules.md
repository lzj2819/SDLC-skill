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

- [ ] `DataModel` 变更 -> `schema.sql` 已更新
- [ ] `Interface` 变更 -> `openapi.yaml` 已更新
- [ ] `ErrorCodes` 变更 -> 所有相关 XML 已更新
- [ ] 新增模块 -> 模块级 XML 模板已生成
- [ ] 函数签名变更 -> `component-spec.xml` 已更新
