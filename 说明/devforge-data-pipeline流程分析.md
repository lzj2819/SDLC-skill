# DevForge Data Pipeline 流程深度分析

> 基于 DevForge SDLC Skill Chain v1.4 的 `devforge-data-pipeline/SKILL.md` 及其关联工具规范文档进行系统性分析。
>
> **定位**：数据管道设计与生成 Skill，负责从已批准架构中提取数据需求，生成数据流拓扑、OLAP 维度模型、ETL DAG 和数据质量规则。

---

## 一、定位与核心区别

### 1.1 Skill 定位

`devforge-data-pipeline` 是 DevForge SDLC Skill Chain v1.4 引入的专门负责**数据基础设施**的独立 Skill。它的职责是：**从已批准的 `architecture.xml` 和 `PRD.md` 中提取数据流需求，生成可执行的数据管道配置**——包括数据流拓扑、维度建模 schema、ETL DAG 和数据质量规则。

与其他技能的关系：

| 维度 | `devforge-architecture-design` | `devforge-data-pipeline` |
|------|------------------------------|-------------------------|
| **职责** | 设计系统架构，生成 `architecture.xml` | **设计数据管道，生成 `dataflow.xml` + ETL DAG** |
| **数据视角** | OLTP 数据模型（事务性） | **OLAP 数据模型（分析性）** |
| **输出** | `architecture.xml` 中的 `DataModel`（oltp） | **`dataflow.xml`、`schema-olap.sql`、ETL DAG、数据质量规则** |
| **面向场景** | 通用软件系统 | **数据密集型项目（BI、数据仓库、实时分析）** |
| **是否必经** | 是 | **否（数据项目时触发）** |
| **DIVE 阶段** | Design | **Design（数据基础设施）** |

### 1.2 为什么需要独立的数据管道 Skill

> **设计意图**：
> 1. **专业领域分离**：通用软件架构设计和数据管道设计是两个专业领域。数据管道涉及维度建模、ETL 编排、数据质量等专门知识，独立为 Skill 可以集中处理这些复杂性
> 2. **触发条件差异**：不是所有项目都需要数据管道（如简单的 CRUD 应用）。通过 PRD 标签（`data_pipeline`、`etl`、`streaming`、`batch_processing`）条件触发，避免对非数据项目施加不必要的开销
> 3. **产物差异**：数据管道的产物（`dataflow.xml`、`schema-olap.sql`、Airflow DAG）与通用架构产物（`architecture.xml`、`component-spec.xml`）完全不同
> 4. **v1.4 重构**：v1.3 中数据管道设计是 `extensions/data-pipeline-design`（参考扩展），v1.4 将其提升为核心 Skill，因为数据基础设施的复杂度足以需要完整的 Skill 工作流

### 1.3 与 architecture-design 中 DataModel 的关系

| 维度 | architecture-design 中的 DataModel | devforge-data-pipeline 中的 OLAP Schema |
|------|-----------------------------------|----------------------------------------|
| **用途** | 支撑业务事务（OLTP） | **支撑分析查询（OLAP）** |
| **模型类型** | `modelType="oltp"` | **`modelType="olap-*"`** |
| **存储引擎** | PostgreSQL / MySQL（行式） | **ClickHouse / Snowflake / BigQuery（列式）** |
| **设计原则** | 规范化（3NF），减少冗余 | **维度建模（星型/雪花），反规范化优化查询** |
| **数据更新** | 实时事务（INSERT/UPDATE/DELETE） | **批量加载（ETL），追加为主** |
| **查询模式** | 点查、小范围扫描 | **大范围聚合、多维度分析** |

> **设计意图**：
> - `architecture-design` 中的 `DataModel` 是 OLTP 模型，用于支撑业务系统的日常操作
> - `devforge-data-pipeline` 生成的 `schema-olap.sql` 是 OLAP 模型，用于支撑 BI 报表、数据分析、机器学习特征工程
> - 两者共存：OLTP 是"数据源"，OLAP 是"数据目的地"，ETL DAG 是"数据搬运工"

---

## 二、触发条件与前置检查

### 2.1 触发条件

| 触发方式 | 场景 | 说明 |
|----------|------|------|
| **用户输入 `[DATA_PIPELINE]`** | 架构设计完成后，用户需要数据管道 | 最常见的触发方式 |
| **PRD 标签自动触发** | PRD 包含 `data_pipeline`、`etl`、`streaming`、`batch_processing` 标签 | 自动识别数据密集型项目 |
| **架构更新后重新触发** | `architecture.xml` 中 DataModel 发生变更 | 重新评估数据流拓扑 |

### 2.2 前置条件校验

根据 `skill/tools/precondition-checker.md`：

| 校验项 | 要求 |
|--------|------|
| **Acceptable Phases** | `architecture_design_completed`, `scaffolding_completed`, `module_design_completed` |
| **Minimum Phase** | `architecture_design_completed` |
| **Required Artifact** | `architecture.xml` |

**不满足条件时的行为**：
- 如果阶段早于 `architecture_design_completed` → 停止执行，提示用户先完成 `devforge-architecture-design`
- 如果 `architecture.xml` 不存在 → 停止执行，提示用户先完成系统级架构设计

### 2.3 为什么不要求 scaffolding_completed

> **设计意图**：
> - 数据管道设计主要关注"数据流逻辑"（什么数据、怎么转换、存到哪里），而非"代码工程结构"
> - `architecture.xml` 中已经包含了 DataModel 定义，足以推断数据流需求
> - scaffolding 完成不是数据管道设计的严格前置条件——可以在 scaffolding 前设计数据管道，然后在 scaffolding 时一并生成工程目录
> - 但通常数据管道设计在 scaffolding 之后运行，因为 scaffolding 提供了项目目录结构

---

## 三、输出产物

`devforge-data-pipeline` 生成四类产物：

| 产物 | 路径 | 内容 | 用途 |
|------|------|------|------|
| **数据流拓扑** | `docs/architecture/system/dataflow.xml` | 数据源、摄取、转换、存储、消费的完整拓扑 | 数据管道的权威架构文档 |
| **OLAP 维度模型** | `docs/architecture/system/schema-olap.sql` | 事实表、维度表、聚合表的 DDL | OLAP 数据库建表脚本 |
| **ETL DAG** | `dags/{pipeline_id}.py` | Airflow DAG 或 Prefect Flow | 数据管道执行编排 |
| **数据质量规则** | `data-quality-rules.yaml` | 行数检查、空值率、新鲜度、PII 扫描规则 | 数据质量监控 |

### 3.1 产物总览

```
docs/architecture/system/
├── dataflow.xml           # 数据流权威定义
├── schema-olap.sql        # OLAP 维度模型 DDL
dags/
├── {pipeline_id}.py       # Airflow DAG
prefect-flows/
├── {pipeline_id}.py       # Prefect Flow (可选)
data-quality-rules.yaml    # 数据质量规则
```

---

## 四、完整工作流程

`devforge-data-pipeline` 的工作流程分为 6 个步骤：

```
Step 1: 数据流拓扑建模
    → 读取 PRD.md 和 architecture.xml
    → 识别数据源、转换、存储、消费点
    → 输出 dataflow.xml

Step 2: 维度建模 schema 生成
    → 识别事实表、维度表、聚合表
    → 生成 schema-olap.sql（支持 ClickHouse/Snowflake/BigQuery）
    → 包含分区策略、集群键、数据保留策略

Step 3: ETL DAG 生成
    → 生成 Airflow DAG 或 Prefect Flow
    → 任务依赖、重试策略、幂等性检查、数据质量验证

Step 4: 数据质量规则
    → 生成 data-quality-rules.yaml
    → 行数检查、空值率、新鲜度、PII 扫描

Step 5: 自验证
    → 验证 dataflow.xml 无孤立节点
    → 验证 schema-olap.sql 语法
    → 验证 DAG 无循环依赖
    → 验证数据质量规则引用有效列

Step 6: 人工门控
    → 呈现数据管道摘要，等待用户确认
```

---

### Step 1: 数据流拓扑建模

**输入文件**：
- `PRD.md` — 业务需求，识别数据消费者（如"实时仪表盘"、"用户行为分析"）
- `architecture.xml` — DataModel 定义、模块接口、状态模型

**输出文件**：`docs/architecture/system/dataflow.xml`

**dataflow.xml 结构**：

```xml
<DataFlow>
  <!-- 数据源 -->
  <Source id="user-events" type="kafka" format="json" schema="UserEvent"/>
  
  <!-- 数据摄取 -->
  <Ingestion id="kafka-connect" strategy="cdc" source="user-events"/>
  
  <!-- 数据转换 -->
  <Transform id="enrich-user" type="stream" engine="flink">
    <Input ref="kafka-connect"/>
    <Output schema="EnrichedUserEvent"/>
  </Transform>
  
  <!-- 数据存储 -->
  <Storage id="user-warehouse" type="clickhouse" model="star-schema">
    <Input ref="enrich-user"/>
    <Tables>
      <FactTable name="fact_user_events"/>
      <DimensionTable name="dim_users"/>
    </Tables>
  </Storage>
  
  <!-- 数据消费 -->
  <Consumption id="analytics-dashboard" type="bi-query" source="user-warehouse"/>
</DataFlow>
```

**节点类型**：

| 节点 | 含义 | XML 映射来源 |
|------|------|-------------|
| `Source` | 数据源（Kafka、DB CDC、API、文件） | PRD 中的数据来源描述 |
| `Ingestion` | 数据摄取策略（CDC、批处理、流式） | `StateModel` 中的数据位置 |
| `Transform` | 数据转换（清洗、富化、聚合） | PRD 中的数据处理需求 |
| `Storage` | 数据存储（数仓、数据湖） | `DataModel` 的 OLAP 变体 |
| `Consumption` | 数据消费（BI、报表、ML） | PRD 中的数据消费者 |

**为什么需要 dataflow.xml**：
> `dataflow.xml` 是数据管道的"architecture.xml"——它是数据流拓扑的权威定义：
> 1. **VCMF 原则**："XML as Authority"——所有管道产物必须能追溯到 `dataflow.xml`
> 2. **可视化**：可以基于 `dataflow.xml` 生成数据流图（类似于 architecture.xml 生成系统架构图）
> 3. **验证**：自验证步骤可以检查 `dataflow.xml` 的完整性和一致性
> 4. **版本控制**：数据流变更纳入版本控制，可追溯数据管道的演进

---

### Step 2: 维度建模 Schema 生成

**输出文件**：`docs/architecture/system/schema-olap.sql`

**为什么使用维度建模**：
> 维度建模（Dimensional Modeling）是 OLAP 领域的标准设计方法，由 Ralph Kimball 提出：
> - **事实表（Fact Table）**：存储可度量的业务事件（如订单、点击、登录），包含外键引用维度表
> - **维度表（Dimension Table）**：存储描述性属性（如用户信息、商品信息、时间），用于分析时的分组和过滤
> - **星型模式（Star Schema）**：事实表位于中心，周围环绕维度表，查询性能最优
> - **雪花模式（Snowflake Schema）**：维度表进一步规范化，节省存储但查询更复杂

**schema-olap.sql 内容**：

```sql
-- 维度表
CREATE TABLE dim_users (
    user_id UInt64,
    email String,
    registration_date Date,
    country String,
    -- 缓慢变化维度 Type 2：记录历史
    valid_from Date,
    valid_to Date,
    is_current UInt8
) ENGINE = MergeTree()
ORDER BY user_id;

-- 事实表
CREATE TABLE fact_orders (
    order_id UInt64,
    user_id UInt64,          -- 外键 → dim_users
    product_id UInt64,       -- 外键 → dim_products
    order_date Date,
    amount Decimal(18, 2),
    quantity UInt32
) ENGINE = MergeTree()
PARTITION BY toYYYYMM(order_date)     -- 按月分区
ORDER BY (order_date, user_id)        -- 集群键
TTL order_date + INTERVAL 2 YEAR;     -- 数据保留策略

-- 聚合表（物化视图）
CREATE MATERIALIZED VIEW mv_daily_revenue
ENGINE = SummingMergeTree()
PARTITION BY toYYYYMM(day)
ORDER BY day
AS SELECT
    toDate(order_date) as day,
    sum(amount) as total_revenue,
    count() as order_count
FROM fact_orders
GROUP BY day;
```

**设计要点**：

| 特性 | 说明 | 为什么重要 |
|------|------|-----------|
| **分区策略** | 按日期分区（`PARTITION BY toYYYYMM`） | 大数据场景下，分区裁剪大幅提升查询性能 |
| **集群键** | 按查询维度排序（`ORDER BY`） | 确保常用查询模式的数据局部性 |
| **数据保留** | TTL（Time To Live） | 自动清理过期数据，控制存储成本 |
| **物化视图** | 预聚合常用指标 | 避免每次查询都扫描原始数据 |
| **缓慢变化维度** | Type 2（记录历史版本） | 支持"用户过去属于哪个国家"这类历史分析 |

**OLAP 引擎选择**：

| 引擎 | 适用场景 | 方言特性 |
|------|----------|----------|
| **ClickHouse** | 实时分析、高吞吐、低开销 | 列式存储、MergeTree 引擎、物化视图 |
| **Snowflake** | 云原生、弹性扩展、复杂查询 | 虚拟仓库、零拷贝克隆、时间旅行 |
| **BigQuery** | GCP 生态、Serverless | 分区表、集群列、物化视图 |

> **设计意图**：支持多种 OLAP 引擎，让用户根据技术栈和云环境选择。

---

### Step 3: ETL DAG 生成

**输出文件**：
- `dags/{pipeline_id}.py`（Airflow DAG）
- `prefect-flows/{pipeline_id}.py`（Prefect Flow，可选）

**为什么使用 Airflow / Prefect**：
> ETL（Extract-Transform-Load）是数据管道的核心执行逻辑。Airflow 和 Prefect 是业界最流行的 ETL 编排工具：
> - **Airflow**：功能最丰富、生态最成熟、社区最大
> - **Prefect**：更现代化的设计、更好的类型安全、更简洁的 API
> - DevForge 默认生成 Airflow DAG，因为 Airflow 的兼容性更广

**Airflow DAG 结构**：

```python
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.sensors.external_task import ExternalTaskSensor
from datetime import datetime, timedelta

default_args = {
    'owner': 'data-engineering',
    'depends_on_past': False,
    'email_on_failure': True,
    'email': ['data-alerts@company.com'],
    'retries': 3,
    'retry_delay': timedelta(minutes=5),
    'retry_exponential_backoff': True,  # 指数退避
}

with DAG(
    'user_events_pipeline',
    default_args=default_args,
    description='Process user events from Kafka to ClickHouse',
    schedule_interval='@hourly',
    start_date=datetime(2026, 1, 1),
    catchup=False,
    tags=['data-pipeline', 'user-events'],
) as dag:

    # 1. 等待上游数据可用
    wait_for_data = ExternalTaskSensor(
        task_id='wait_for_upstream',
        external_dag_id='upstream_pipeline',
        external_task_id='load_complete',
        timeout=3600,
    )

    # 2. 数据提取
    extract = PythonOperator(
        task_id='extract_from_kafka',
        python_callable=extract_user_events,
    )

    # 3. 数据转换
    transform = PythonOperator(
        task_id='transform_enrich',
        python_callable=enrich_user_events,
    )

    # 4. 数据质量检查
    quality_check = PythonOperator(
        task_id='data_quality_check',
        python_callable=run_quality_checks,
    )

    # 5. 数据加载
    load = PythonOperator(
        task_id='load_to_clickhouse',
        python_callable=load_to_warehouse,
    )

    # 任务依赖
    wait_for_data >> extract >> transform >> quality_check >> load
```

**设计要点**：

| 特性 | 说明 | 为什么重要 |
|------|------|-----------|
| **任务依赖** | DAG 中的 `>>` 定义执行顺序 | 确保数据按正确顺序处理 |
| **重试策略** | 指数退避（exponential backoff） | 临时故障时自动恢复，避免频繁重试压垮系统 |
| **幂等性检查** | 去重键（deduplication keys） | 防止同一数据被处理多次，确保数据一致性 |
| **数据质量验证** | 在加载前执行质量检查 | 脏数据不入仓，保证数据质量 |
| **传感器任务** | `ExternalTaskSensor` 等待上游 | 确保上游数据就绪后再开始处理 |

---

### Step 4: 数据质量规则

**输出文件**：`data-quality-rules.yaml`

**为什么需要独立的数据质量规则文件**：
> 数据质量是数据管道的"生命线"——如果数据不正确，基于数据的决策就是错误的。独立的数据质量规则文件：
> 1. **集中管理**：所有质量规则在一个文件中，便于审查和维护
> 2. **版本控制**：规则变更纳入 Git，可追溯数据质量策略的演进
> 3. **自动化执行**：ETL DAG 可以读取此文件，自动执行质量检查

**规则类型**：

| 规则 | 描述 | 示例 | 失败时的行为 |
|------|------|------|-------------|
| **row_count_delta** | 行数变化率检查 | 新数据行数不应低于上次的 90% | 告警或阻断管道 |
| **null_rate** | 空值率检查 | `user_id` 空值率不应超过 1% | 告警 |
| **freshness** | 数据新鲜度检查 | `created_at` 不应超过 1 小时 | 告警 |
| **pii_scan** | PII 扫描 | `email`、`phone` 应加密或脱敏 | 告警并自动脱敏 |
| **schema_change** | Schema 变更检测 | 表结构不应意外变更 | 告警 |
| **uniqueness** | 唯一性检查 | `order_id` 不应重复 | 告警或去重 |

**示例规则文件**：

```yaml
rules:
  - table: fact_orders
    checks:
      - row_count_delta:
          threshold: 0.9
          comparison: previous_run
      - null_rate:
          column: user_id
          threshold: 0.01
      - null_rate:
          column: order_date
          threshold: 0.0
      - freshness:
          column: created_at
          max_age: 1h
      - pii_scan:
          columns: [email, phone]
          masking: hash
      - uniqueness:
          column: order_id

  - table: dim_users
    checks:
      - row_count_delta:
          threshold: 0.5
          comparison: previous_run
      - null_rate:
          column: user_id
          threshold: 0.0
      - pii_scan:
          columns: [email]
          masking: hash
```

---

### Step 5: 自验证

**验证项**：

| 检查项 | 验证内容 | 失败时的行为 |
|--------|----------|-------------|
| **dataflow.xml 完整性** | 每个 Transform 有 Source 和 Sink | 标记错误，指出孤立节点 |
| **schema-olap.sql 语法** | SQL 语法符合目标 OLAP 引擎方言 | 标记错误，指出语法问题 |
| **DAG 无循环依赖** | ETL 任务依赖图中无环 | 标记错误，指出循环路径 |
| **数据质量列有效性** | `data-quality-rules.yaml` 中的列名存在于 schema | 标记错误，指出无效列 |

**为什么这些验证很重要**：
> 数据管道的错误通常在运行时才暴露（如 SQL 语法错误导致 ETL 失败、列名错误导致质量检查异常）。自验证在生成阶段就发现这些问题，避免在运行时才发现。

---

### Step 6: 人工门控

**呈现内容**：
- 数据管道摘要："数据管道设计已完成。生成数据流 X 个，事实表 Y 个，维度表 Z 个，ETL DAG W 个。"

**可用命令**：

| 命令 | 行为 |
|------|------|
| `[APPROVE]` | 标记数据管道阶段完成，转换 phase 到 `data_pipeline_completed` |
| `[PAUSE]` | 暂停当前阶段 |
| `[EDIT {file_path}]` | 手动编辑文件后让 AI 继续 |

---

## 五、调用工具汇总

| 工具 | 用途 | 调用时机 |
|------|------|----------|
| `Read` | 读取 `PRD.md` | Step 1 |
| `Read` | 读取 `architecture.xml` | Step 1 |
| `Read` | 读取现有 `dataflow.xml`（增量更新时） | Step 1 |
| `Write` | 写入 `dataflow.xml` | Step 1 |
| `Write` | 写入 `schema-olap.sql` | Step 2 |
| `Write` | 写入 `dags/{pipeline_id}.py` | Step 3 |
| `Write` | 写入 `data-quality-rules.yaml` | Step 4 |
| `Bash` | SQL 语法验证（目标 OLAP 引擎） | Step 5 |
| `Grep` | 验证列名存在于 schema | Step 5 |
| `Grep` | 检查 dataflow.xml 无孤立节点 | Step 5 |

---

## 六、生成产物清单

| 产物文件 | 路径 | 用途 | 更新模式 |
|----------|------|------|----------|
| `dataflow.xml` | `docs/architecture/system/` | 数据流权威定义 | Merge-update |
| `schema-olap.sql` | `docs/architecture/system/` | OLAP 维度模型 DDL | Overlay |
| `dags/{pipeline_id}.py` | `dags/` | Airflow DAG | Overlay |
| `prefect-flows/{pipeline_id}.py` | `prefect-flows/` | Prefect Flow（可选） | Overlay |
| `data-quality-rules.yaml` | 项目根目录 | 数据质量规则 | Merge-update |
| `STATE.md` | `docs/architecture/system/` | phase → `data_pipeline_completed` | Selective update |

---

## 七、VCMF 检查点

| VCMF 原则 | 检查点 | 说明 |
|-----------|--------|------|
| **Design as Contract** | 每个 DataModel 必须追溯到 PRD 需求；管道输出必须匹配 PRD 数据消费者 | 数据管道服务业务需求 |
| **Interface as Boundary** | ETL 接口（摄取/转换/存储）必须有明确的 schema 和错误码 | 数据契约在管道层可见 |
| **Reality as Baseline** | 生成的 DAG 必须可执行；schema 必须能在目标 OLAP 引擎上验证 | 不是"纸上设计"，是可运行代码 |
| **State as Responsibility** | 数据血缘必须追踪从数据源到消费的完整路径 | 知道数据从哪里来、到哪里去 |
| **XML as Authority** | `dataflow.xml` 是所有管道产物的权威来源 | 与 `architecture.xml` 平行的数据流权威 |

---

## 八、流程设计原理（Why Designed This Way）

### 8.1 为什么是可选而非必经

| 对比 | 必经（如 architecture-design） | 可选（如 data-pipeline） |
|------|------------------------------|-------------------------|
| **适用场景** | 所有项目 | 数据密集型项目 |
| **执行成本** | 必须承担 | 按需执行 |
| **核心价值** | 系统架构 | **数据基础设施** |

> **设计意图**：
> - 简单的 CRUD 应用不需要数据管道（没有 ETL、没有 OLAP）
> - 但 BI 报表、用户行为分析、实时仪表盘、机器学习特征工程等项目需要完整的数据管道
> - 通过 PRD 标签自动识别数据需求，避免对非数据项目施加不必要的复杂度

### 8.2 为什么使用维度建模

> **设计意图**：
> - OLTP 的规范化模型（3NF）适合事务处理，但不适合分析查询（过多的 JOIN 导致性能差）
> - 维度建模（星型/雪花模式）是 OLAP 领域的标准实践，由 Ralph Kimball 推广
> - 事实表 + 维度表的结构天然支持"按维度分组、对指标聚合"的分析查询模式
> - 物化视图（预聚合）进一步提升常用查询的性能

### 8.3 为什么生成 Airflow DAG 而非手写 SQL 脚本

> **设计意图**：
> - 手写 SQL 脚本难以管理依赖、重试、调度
> - Airflow DAG 提供了：
>   - **调度管理**：按 cron 表达式自动触发
>   - **依赖管理**：任务间的执行顺序
>   - **监控**：任务成功/失败状态、执行历史
>   - **重试**：失败时自动重试
>   - **回填**：历史数据补跑
> - Prefect 是 Airflow 的现代化替代，提供更简洁的 API

### 8.4 为什么 dataflow.xml 是权威来源

> **设计意图**：
> - 与 `architecture.xml` 类似，`dataflow.xml` 是数据管道的"单一真相源"
> - 所有其他产物（schema、DAG、质量规则）都可以从 `dataflow.xml` 推导
> - 如果数据流发生变化（新增数据源、修改转换逻辑），只需更新 `dataflow.xml`，其他产物可以重新生成
> - 这体现了 VCMF 的 "XML as Authority" 原则在数据领域的应用

### 8.5 为什么数据质量规则独立为 YAML 文件

> **设计意图**：
> - 数据质量规则需要独立于 ETL 代码，因为：
>   - 规则经常调整（阈值变化、新增检查），而 ETL 逻辑相对稳定
>   - 非技术人员（数据分析师、产品经理）可以参与规则定义
>   - 规则可以跨多个 ETL 管道复用
> - YAML 格式人类可读，便于审查和版本控制

---

## 九、常见误区与 Red Flags

### 9.1 与 architecture-design 的边界误区

| 误区 | 正确做法 |
|------|----------|
| 在 architecture-design 阶段就生成 OLAP schema | architecture-design 只生成 OLTP DataModel，OLAP schema 在 data-pipeline 阶段生成 |
| 认为 dataflow.xml 可以替代 architecture.xml | `dataflow.xml` 只描述数据流，`architecture.xml` 描述完整系统架构，两者互补 |
| 修改 architecture.xml DataModel 后不重新运行 data-pipeline | DataModel 变更可能影响数据流拓扑，应重新运行以同步 |

### 9.2 通用误区

| 误区 | 正确做法 |
|------|----------|
| 忽略数据质量规则 | 数据质量是数据管道的生命线，不可省略 |
| 使用 OLTP 数据库做 OLAP 查询 | OLTP 数据库（如 MySQL）不适合大规模分析查询，应使用专门的 OLAP 引擎 |
| 忽略数据保留策略 | 大数据场景下，无 TTL 会导致存储成本失控 |
| 不验证 schema 语法 | 应在生成后验证 SQL 语法，避免运行时错误 |
| 认为数据管道只做一次 | 业务需求变化后，数据管道可能需要调整（新增数据源、修改转换逻辑） |

### 9.3 SKILL.md 中的 Red Flags

SKILL.md 明确定义了以下红线：

| Red Flag | 说明 |
|----------|------|
| **Do NOT use if `architecture.xml` has not been approved** | 未批准的架构上无法推断数据流需求 |

---

## 十、总结

`devforge-data-pipeline` 是 DevForge SDLC Skill Chain v1.4 引入的**数据基础设施设计引擎**，负责从已批准架构中提取数据需求，生成完整的数据管道配置。

### 核心价值

1. **数据流权威定义**：`dataflow.xml` 是数据管道的"architecture.xml"，所有管道产物追溯到此
2. **OLAP 维度建模**：使用标准的星型/雪花模式，支持高性能分析查询
3. **ETL 自动化**：生成可执行的 Airflow DAG，包含重试、幂等性、数据质量检查
4. **数据质量保障**：独立的 YAML 规则文件，支持行数检查、空值率、新鲜度、PII 扫描
5. **多引擎支持**：ClickHouse、Snowflake、BigQuery 等主流 OLAP 引擎
6. **VCMF 一致性**：遵循 "XML as Authority" 原则，数据血缘可追溯

### 适用场景

| 场景 | 推荐操作 |
|------|----------|
| BI 报表和数据仪表盘 | 触发 `[DATA_PIPELINE]`，生成完整的 ETL 管道 |
| 用户行为分析 | 生成事件流处理管道（Kafka → Flink → ClickHouse） |
| 实时监控系统 | 生成流式 ETL（低延迟数据摄取和转换） |
| 机器学习特征工程 | 生成特征计算管道（数据仓库 → 特征存储） |
| 数据仓库建设 | 生成完整的维度模型 + ETL + 质量规则 |
| 已有数据管道需要调整 | 重新触发，更新 dataflow.xml 和相关产物 |

### 与其他技能的协作

```
requirement-analysis (PRD 包含 data_pipeline 标签)
    ↓
architecture-design (生成 OLTP DataModel)
    ↓
[DATA_PIPELINE] → devforge-data-pipeline
    → 生成 dataflow.xml
    → 生成 schema-olap.sql
    → 生成 ETL DAG
    → 生成数据质量规则
    ↓
project-scaffolding (包含数据管道目录结构)
    ↓
module-design (实现数据管道代码)
    ↓
test-execution (执行数据管道测试)
    ↓
ops-ready (部署数据管道到生产环境)
```

### v1.4 设计演进

- **v1.3**：`extensions/data-pipeline-design` 是参考扩展，只提供设计指导，不生成可执行产物
- **v1.4**：提升为核心 Skill，生成完整的可执行产物（`dataflow.xml`、`schema-olap.sql`、Airflow DAG、数据质量规则）
- **设计趋势**：从"数据管道设计参考"演进为"数据管道工程自动化"，与 DevForge 的其他 Skill 保持一致的"设计 → 生成 → 验证"工作流

---

*分析基于 DevForge SDLC Skill Chain v1.4（2026-05-11）及 devforge-data-pipeline v1.4*
