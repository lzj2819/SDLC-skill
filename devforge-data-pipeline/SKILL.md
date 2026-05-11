---
name: devforge-data-pipeline
description: Use when a project requires data pipeline architecture, ETL DAG generation, dimensional modeling, or data quality framework. Trigger when user says [DATA_PIPELINE] or PRD contains data-pipeline tags.
---

# DevForge Data Pipeline

## Overview

Design and generate complete data pipeline infrastructure from an approved architecture. This skill handles data flow topology modeling, dimensional schema generation, ETL DAG creation, and data quality rule definition. It replaces the generation responsibilities previously in extensions/data-pipeline-design.

## VCMF Checkpoints

| Principle | Checkpoint in this Skill | Inherited from |
|-----------|--------------------------|----------------|
| Design as Contract | Every DataModel must trace back to PRD requirements; pipeline outputs must match PRD data consumers | Inherited from architecture-design |
| Interface as Boundary | ETL interfaces (ingest/transform/sink) must have explicit schemas and error codes | Inherited from architecture-design |
| Reality as Baseline | Generated DAGs must be executable; schemas must validate against target OLAP engines | New |
| State as Responsibility | Data lineage must track ownership from source to consumption | Inherited from architecture-design |
| XML as Authority | `dataflow.xml` is the authoritative source for all pipeline artifacts | New |

## When to Use

- User inputs `[DATA_PIPELINE]`
- PRD contains tags: `data_pipeline`, `etl`, `streaming`, `batch_processing`
- Do NOT use if `architecture.xml` has not been approved

## Precondition Check

See `skill/tools/precondition-checker.md`. Acceptable phases: `architecture_design_completed`, `scaffolding_completed`, `module_design_completed`.
- If phase is earlier than `architecture_design_completed`, stop and instruct the user to complete `devforge-architecture-design` first.
- If `architecture.xml` is missing, stop and instruct the user to complete `devforge-architecture-design` first.

## Language Adaptation

See `skill/tools/language-adaptation.md`.

## Workflow

1. **Data flow topology modeling**
   - Read `PRD.md` and `architecture.xml`
   - Identify data sources, transformations, storage, and consumption points
   - Output `dataflow.xml`:
     ```xml
     <DataFlow>
       <Source id="user-events" type="kafka" format="json"/>
       <Ingestion id="kafka-connect" strategy="cdc"/>
       <Transform id="enrich-user" type="stream" engine="flink"/>
       <Storage id="user-warehouse" type="clickhouse" model="star-schema"/>
       <Consumption id="analytics-dashboard" type="bi-query"/>
     </DataFlow>
     ```

2. **Dimensional modeling schema generation**
   - Identify fact tables, dimension tables, and aggregate tables
   - Generate `schema-olap.sql` supporting ClickHouse / Snowflake / BigQuery dialects
   - Include:
     - Partition strategy (by date)
     - Clustering keys (by query dimensions)
     - Data retention policies (TTL / hot-cold tiering)
   - Generate corresponding `DataModel` entries in `architecture.xml` with `modelType="olap-*"`

3. **ETL DAG generation**
   - Generate Airflow DAGs: `dags/{pipeline_id}.py`
     - Task dependencies and parallel execution
     - Retry policy with exponential backoff
     - Idempotency checks (deduplication keys)
     - Data quality validation tasks
   - Or generate Prefect flows: `prefect-flows/{pipeline_id}.py`
   - Include sensor tasks for upstream data availability

4. **Data quality rules**
   - Output `data-quality-rules.yaml`:
     ```yaml
     rules:
       - table: fact_orders
         checks:
           - row_count_delta: {threshold: 0.9}
           - null_rate: {column: user_id, threshold: 0.01}
           - freshness: {column: created_at, max_age: 1h}
           - pii_scan: {columns: [email, phone], masking: hash}
     ```

5. **Self-validation**
   - Verify `dataflow.xml` has no orphaned nodes (every transform has source and sink)
   - Verify `schema-olap.sql` is syntactically valid for the target dialect
   - Verify ETL DAG has no circular dependencies
   - Verify data quality rules reference columns that exist in the schema

6. **Human Gate**
   - Present summary: "数据管道设计已完成。生成数据流 X 个，事实表 Y 个，维度表 Z 个，ETL DAG W 个。"
   - List available commands:
     ```
     可用命令：
     - [APPROVE] — 标记数据管道阶段完成
     - [PAUSE] — 暂停当前阶段
     - [EDIT {file_path}] — 手动编辑后让 AI 继续
     ```

## State Update

See `skill/tools/state-updater.md`. This skill transitions phase to `data_pipeline_completed`.
