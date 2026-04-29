# Search Integration 参考规范

**版本**: v1.0
**适用范围**: 所有 Skill 的技术验证和决策环节
**最后更新**: 2026-04-29

---

## 1. 目的

本文档定义 DevForge SDLC Skill Chain 中各阶段搜索调用的规范，确保技术验证和决策环节充分利用搜索能力获取最新、可靠的信息，同时避免不必要的搜索开销。

---

## 2. 各阶段搜索调用点

### 2.1 阶段一：PRD（产品需求文档）

| 调用点 | 搜索目的 | 搜索关键词示例 | 优先级 |
|--------|----------|----------------|--------|
| 竞品分析 | 了解同类产品的技术选型、功能特性、市场定位 | `"竞品名称" tech stack`, `"竞品名称" architecture` | 高 |
| 技术可行性 | 验证核心功能的技术实现可行性 | `"功能描述" implementation`, `"技术方案" feasibility` | 高 |
| 行业趋势 | 了解相关技术领域的最新发展趋势 | `"领域" technology trends 2026` | 中 |
| 合规要求 | 确认目标市场的数据合规和隐私要求 | `"地区" data compliance requirements` | 中 |

### 2.2 阶段三：架构设计

| 调用点 | 搜索目的 | 搜索关键词示例 | 优先级 |
|--------|----------|----------------|--------|
| 框架版本 | 确认推荐框架的最新稳定版本 | `"框架名" latest stable version`, `"框架名" release notes` | 高 |
| CVE 安全漏洞 | 检查框架或组件的已知安全漏洞 | `"组件名" CVE`, `"组件名" security vulnerability` | 高 |
| 性能基准 | 获取框架或数据库的性能对比数据 | `"框架A" vs "框架B" performance benchmark` | 中 |
| 架构模式 | 验证所选架构模式的行业实践 | `"架构模式" best practices`, `"架构模式" case study` | 中 |
| 云服务定价 | 对比不同云服务商的定价和特性 | `"AWS" vs "Azure" pricing comparison` | 低 |

### 2.3 阶段五：脚手架搭建

| 调用点 | 搜索目的 | 搜索关键词示例 | 优先级 |
|--------|----------|----------------|--------|
| 依赖最佳实践 | 确认依赖版本和配置的最佳实践 | `"依赖名" best practices`, `"依赖名" recommended version` | 高 |
| Docker 镜像安全 | 验证基础镜像的安全性和大小 | `"镜像名" Docker image security`, `"镜像名" CVE` | 高 |
| 构建工具配置 | 获取构建工具的最新配置建议 | `"工具名" configuration 2026`, `"工具名" optimization` | 中 |
| 开发环境 | 确认本地开发环境的一致性方案 | `"技术栈" dev container setup` | 低 |

### 2.4 sdlc-security-audit（安全审计）

| 调用点 | 搜索目的 | 搜索关键词示例 | 优先级 |
|--------|----------|----------------|--------|
| 依赖 CVE | 检查所有依赖的已知 CVE | `"依赖名" CVE list`, `"依赖名" security advisory` | 高 |
| 漏洞详情 | 获取 CVE 的详细描述和修复方案 | `"CVE-编号" details`, `"CVE-编号" fix` | 高 |
| 安全公告 | 查看官方安全公告和补丁信息 | `"项目名" security advisory`, `"项目名" security patch` | 高 |
| 替代方案 | 查找存在漏洞依赖的安全替代方案 | `"漏洞组件" alternative secure` | 中 |

---

## 3. 搜索结果引用规范

### 3.1 必须包含的字段

每次搜索调用后，结果必须记录以下字段：

| 字段 | 说明 | 示例 |
|------|------|------|
| Query | 实际执行的搜索查询语句 | `"PostgreSQL vs MongoDB performance benchmark 2026"` |
| Source | 信息来源的 URL 或名称 | `https://example.com/benchmark` |
| Date | 搜索执行日期 | `2026-04-29` |
| Summary | 搜索结果的简要摘要（50-200 字） | PostgreSQL 在复杂查询场景下性能优于 MongoDB... |

### 3.2 存入 DECISION_LOG.md

搜索结果作为决策证据，必须存入 `DECISION_LOG.md` 的 `Evidence` 字段。

```markdown
## 决策记录示例

### DEC-001: 数据库选型决策

- **决策内容**: 选用 PostgreSQL 作为主数据库
- **决策日期**: 2026-04-29
- **决策依据**:
  - 项目需要复杂查询和事务支持
  - 团队已有 PostgreSQL 运维经验
- **Evidence**:
  - **搜索 1**:
    - Query: `PostgreSQL vs MongoDB performance benchmark 2026`
    - Source: https://example.com/db-benchmark
    - Date: 2026-04-29
    - Summary: PostgreSQL 在复杂查询和事务处理场景下性能优于 MongoDB，特别是在 JOIN 操作和 ACID 事务方面。MongoDB 在文档存储和高写入吞吐量场景下表现更好。
  - **搜索 2**:
    - Query: `PostgreSQL CVE 2026 security`
    - Source: https://security.example.com/postgresql
    - Date: 2026-04-29
    - Summary: PostgreSQL 15.x 和 16.x 版本在 2026 年无高危 CVE，最新补丁版本修复了 2 个中危漏洞。
- **决策人**: AI Agent / 架构师
- **状态**: 已确认
```

---

## 4. 搜索缓存规则

### 4.1 缓存策略

| 规则 | 说明 |
|------|------|
| 同一查询 24 小时内缓存 | 完全相同的搜索查询在 24 小时内不重复执行，直接使用缓存结果 |
| 结果标注日期 | 所有搜索结果必须标注获取日期 |
| 超过 30 天需重新验证 | 标注日期超过 30 天的搜索结果，在用于决策前必须重新搜索验证 |
| 版本相关查询 7 天缓存 | 涉及软件版本、CVE 等快速变化信息的查询，缓存有效期缩短为 7 天 |

### 4.2 缓存键定义

缓存键由以下部分组成：

```
{Skill名称}:{阶段}:{搜索关键词的哈希值}
```

例如：

```
architecture:framework-version:a1b2c3d4
```

### 4.3 必要搜索清单（必须执行搜索的场景）

| 场景编号 | 场景描述 | 原因 |
|----------|----------|------|
| 1 | 引入新的第三方依赖或框架 | 需验证安全性、维护状态、社区活跃度 |
| 2 | 选择关键技术组件（数据库、消息队列、缓存等） | 需对比性能、可靠性、运维成本 |
| 3 | 安全审计阶段检查依赖漏洞 | 必须获取最新 CVE 信息 |
| 4 | 技术方案涉及不熟悉的领域或新技术 | 需验证技术可行性和最佳实践 |

### 4.4 禁止搜索场景（不应执行搜索的场景）

| 场景编号 | 场景描述 | 原因 |
|----------|----------|------|
| 1 | 项目内部已有明确文档记录的技术选型 | 避免重复搜索，直接使用内部知识 |
| 2 | 纯编码实现细节（如具体函数用法） | 应查阅官方文档或代码库，而非通用搜索 |
| 3 | 已明确冻结技术栈的版本升级决策 | 除非有安全漏洞报告，否则不搜索新版本 |
| 4 | 涉及商业机密或敏感内部信息的查询 | 避免通过公共搜索泄露敏感信息 |

---

## 5. 使用示例

### 场景一：推荐数据库（PostgreSQL vs MongoDB）

**背景**：架构设计阶段需要为新的电商项目选择主数据库。

**搜索执行**：

1. **性能对比搜索**
   - Query: `PostgreSQL vs MongoDB ecommerce performance benchmark 2026`
   - Source: https://benchmark.example.com/pg-vs-mongo
   - Date: 2026-04-29
   - Summary: 在电商场景下，PostgreSQL 在订单事务处理、库存一致性方面表现更优；MongoDB 在商品目录和日志存储方面更灵活。

2. **安全漏洞搜索**
   - Query: `PostgreSQL CVE 2026`, `MongoDB CVE 2026`
   - Source: https://cve.mitre.org/, https://security.example.com
   - Date: 2026-04-29
   - Summary: PostgreSQL 16.4 无高危漏洞；MongoDB 7.0 有 1 个中危 CVE（CVE-2026-XXXX），已发布补丁。

3. **运维成本搜索**
   - Query: `PostgreSQL vs MongoDB operational cost comparison`
   - Source: https://ops.example.com/db-cost-analysis
   - Date: 2026-04-29
   - Summary: PostgreSQL 托管服务（RDS/Cloud SQL）成本略低于 MongoDB Atlas，但差距在 10% 以内。

**决策记录**：

```markdown
## DEC-002: 电商项目数据库选型

- **决策内容**: 选用 PostgreSQL 16 作为主数据库，MongoDB 作为商品目录辅助存储
- **决策日期**: 2026-04-29
- **决策依据**:
  - 电商核心交易需要强事务支持
  - PostgreSQL 在性能基准测试中满足吞吐量要求
  - 团队已有 PostgreSQL 运维经验
- **Evidence**:
  - [搜索记录 1-3 如上]
- **决策人**: AI Agent / 架构师
- **状态**: 已确认
```

### 场景二：依赖安全检查（lodash CVE）

**背景**：安全审计阶段发现项目依赖 lodash 4.17.20，需要检查是否存在已知漏洞。

**搜索执行**：

1. **CVE 搜索**
   - Query: `lodash 4.17.20 CVE security vulnerability`
   - Source: https://cve.mitre.org/cgi-bin/cvekey.cgi?keyword=lodash
   - Date: 2026-04-29
   - Summary: lodash 4.17.20 存在以下已知漏洞：
     - CVE-2021-23337: 命令注入漏洞（高危）
     - CVE-2020-8203: Prototype Pollution（高危）
     - CVE-2019-10744: Prototype Pollution（严重）

2. **修复方案搜索**
   - Query: `lodash CVE-2021-23337 fix upgrade version`
   - Source: https://github.com/lodash/lodash/wiki/Changelog
   - Date: 2026-04-29
   - Summary: lodash 4.17.21 修复了上述所有漏洞，建议升级至该版本或最新版 4.17.21+。

3. **替代方案搜索**（如升级不可行）
   - Query: `lodash alternative lightweight utility library 2026`
   - Source: https://npmtrends.com/lodash-vs-ramda-vs-underscore
   - Date: 2026-04-29
   - Summary: 若需替换，可考虑原生 ES2024+ 方法（推荐）或 radash（更轻量）。

**决策记录**：

```markdown
## SEC-001: lodash 依赖安全修复

- **决策内容**: 将 lodash 从 4.17.20 升级至 4.17.21
- **决策日期**: 2026-04-29
- **决策依据**:
  - lodash 4.17.20 存在 3 个已知高危/严重 CVE
  - 4.17.21 版本已修复所有已知漏洞
  - 升级成本低于替换成本
- **Evidence**:
  - **搜索 1**:
    - Query: `lodash 4.17.20 CVE security vulnerability`
    - Source: https://cve.mitre.org/
    - Date: 2026-04-29
    - Summary: lodash 4.17.20 存在 CVE-2021-23337、CVE-2020-8203、CVE-2019-10744 三个高危漏洞。
  - **搜索 2**:
    - Query: `lodash CVE-2021-23337 fix upgrade version`
    - Source: https://github.com/lodash/lodash/wiki/Changelog
    - Date: 2026-04-29
    - Summary: lodash 4.17.21 修复了上述所有漏洞，建议升级。
- **决策人**: AI Agent / 安全审计
- **状态**: 待执行（需创建升级任务）
- **后续行动**: 创建 PR 升级 lodash 至 4.17.21，运行回归测试
```

---

## 6. 搜索质量检查清单

在执行搜索前，确认以下事项：

- [ ] 搜索目的是否明确？
- [ ] 是否已检查缓存中是否存在相同查询？
- [ ] 搜索关键词是否足够具体？
- [ ] 是否属于必要搜索场景？
- [ ] 搜索结果是否来自可信来源？
- [ ] 是否记录了完整的 Evidence 信息？
- [ ] 搜索结果日期是否在有效期内？

---

## 7. 附录

### 7.1 可信来源白名单

| 类别 | 推荐来源 |
|------|----------|
| 安全漏洞 | CVE (cve.mitre.org), NVD (nvd.nist.gov), Snyk, GitHub Security Advisories |
| 性能基准 | TechEmpower Framework Benchmarks, 官方基准测试文档 |
| 框架文档 | 官方文档、GitHub Release Notes、官方博客 |
| 云服务 | AWS/Azure/GCP 官方文档和定价页面 |
| 依赖信息 | npm registry, PyPI, Maven Central, 官方仓库 |

### 7.2 版本历史

| 版本 | 日期 | 变更内容 |
|------|------|----------|
| v1.0 | 2026-04-29 | 初始版本，定义搜索调用点、引用规范、缓存规则和使用示例 |
