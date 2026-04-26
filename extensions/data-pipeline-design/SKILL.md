---
name: data-pipeline-design
description: Domain extension for data pipeline and ETL system architecture. Use when the project involves data ingestion, transformation, streaming, batch processing, or schema evolution. Dynamically loaded by sdlc-architecture-design when PRD contains data-pipeline characteristic tags.
---

# Data Pipeline Design Extension

## Overview

This extension augments the generic `sdlc-architecture-design` skill with data pipeline-specific evaluation dimensions, anti-patterns, and architecture guidance. Loaded when PRD contains tags like `data_pipeline`, `etl`, `streaming`, `batch_processing`.

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

### Interface Additions

| Interface | Input | Output | Error Codes |
|-----------|-------|--------|-------------|
| `ingest_record` | `RawRecord` | `ValidatedRecord` | 400 (invalid format), 409 (duplicate), 429 (source rate limit) |
| `transform_batch` | `RecordBatch` | `TransformedBatch` | 422 (schema mismatch), 500 (transformation error) |
| `check_quality` | `Record` | `QualityReport` | 400 (rule violation), 422 (unsupported rule) |

## References

- `references/schema-evolution.md` — Schema versioning and migration strategies
- `references/idempotency-patterns.md` — Idempotency keys, deduplication, exactly-once semantics
