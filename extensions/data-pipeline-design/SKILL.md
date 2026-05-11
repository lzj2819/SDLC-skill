---
name: data-pipeline-design
description: Reference-only extension providing data pipeline evaluation dimensions, anti-patterns, and architecture guidance. Loaded by devforge-architecture-design when PRD contains data-pipeline tags. Generation logic is handled by devforge-data-pipeline core skill.
---

# Data Pipeline Design Extension

> **Note**: This extension is reference-only as of v1.4. It provides evaluation dimensions and patterns for architecture-design but does not generate artifacts. Use `devforge-data-pipeline` core skill for dataflow.xml, ETL DAG, and schema generation.

## Overview

This extension augments the generic `devforge-architecture-design` skill with data pipeline-specific evaluation dimensions, anti-patterns, and architecture guidance. Loaded when PRD contains tags like `data_pipeline`, `etl`, `streaming`, `batch_processing`.

## When to Load

- PRD mentions: ETL, data warehouse, streaming, batch jobs, schema evolution, data quality
- Project characteristic tags include: `data_pipeline`, `streaming`, `batch_processing`

## Overlay Rules

### Additional Dimensions

| Dimension | Weight | Description |
|-----------|--------|-------------|
| Schema Evolution | 1.2x | How does the pattern handle changing data schemas over time? |
| Idempotency | 1.1x | Can pipeline steps be safely retried without duplication? |
| Backpressure Handling | 1.0x | Does the pattern gracefully handle upstream overload? |
| Data Lineage | 1.0x | Can the origin and transformations of any data record be traced? |
| Failure Recovery | 1.1x | How does the pattern handle partial failures and resume processing? |

### Mandatory Modules

- `IngestionGateway`: Source adapters, rate limiting, format validation
- `TransformationEngine`: Schema mapping, enrichment, deduplication
- `QualityChecker`: Validation rules, anomaly detection, quarantine
- `SinkRouter`: Destination adapters, batching, retry logic
- `Orchestrator`: Job scheduling, dependency management, failure recovery

## References

- `references/schema-evolution.md` — Schema versioning and migration strategies
- `references/idempotency-patterns.md` — Idempotency keys, deduplication, exactly-once semantics
