# Data Quality Framework Reference

Reference document for `devforge-data-pipeline` skill.

## Data Quality Rule Types

| Rule Type | Description | Example |
|-----------|-------------|---------|
| `row_count_delta` | Row count change within threshold | New run has > 90% of previous rows |
| `null_rate` | NULL percentage below threshold | `user_id` NULL rate < 1% |
| `freshness` | Data age within threshold | `created_at` within 1 hour |
| `uniqueness` | Field values are unique | `order_id` has no duplicates |
| `range_check` | Values within expected range | `age` between 0 and 150 |
| `pii_scan` | Detect and mask PII fields | Hash `email` and `phone` |
| `schema_drift` | Schema matches expected structure | No unexpected columns added |

## Dimensional Modeling Patterns

### Star Schema
- One central fact table surrounded by dimension tables
- Fact table: measures + foreign keys to dimensions
- Dimension tables: descriptive attributes

### Fact Table Types
| Type | Grain | Example |
|------|-------|---------|
| Transaction | One row per transaction | `fact_orders` |
| Periodic Snapshot | One row per period | `fact_daily_inventory` |
| Accumulating Snapshot | One row per process | `fact_order_fulfillment` |

## OLAP Database-Specific Features

| Database | Partition Strategy | Clustering | Best For |
|----------|-------------------|------------|----------|
| ClickHouse | MergeTree by date | ORDER BY tuple | Real-time analytics |
| Snowflake | Automatic micro-partitions | Clustering keys | Data warehouse |
| BigQuery | Partition by date/integer | Clustering columns | Petabyte scale |
