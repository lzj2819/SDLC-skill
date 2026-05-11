# Observability Architecture Reference

Reference document for `extensions/observability-engineering/` and `devforge-ops-ready`.

## SLO/SLI Framework

### SLI Types

| SLI Category | Metric Example | Measurement |
|-------------|---------------|-------------|
| Availability | `good_requests / total_requests` | Over 30-day window |
| Latency | `histogram_quantile(0.99, latency_bucket)` | Per-request measurement |
| Error Rate | `error_requests / total_requests` | Per 5-minute window |
| Throughput | `requests_per_second` | Sustained load |

### SLO Target Guidelines

| Service Criticality | Availability | Latency (p99) | Error Rate |
|--------------------|-------------|---------------|-----------|
| Critical | 99.99% | 200ms | 0.01% |
| Standard | 99.9% | 500ms | 0.1% |
| Internal | 99% | 2000ms | 1% |

### Burn Rate Alerting

| Burn Rate Multiplier | Window | Action |
|---------------------|--------|--------|
| 2x | 1 hour | Page immediately |
| 1x | 6 hours | Create ticket |
| 0.5x | 3 days | Weekly review |

## Structured Logging Schema

Required fields for every log entry:
- `timestamp`: ISO-8601 with timezone
- `level`: DEBUG / INFO / WARN / ERROR / FATAL
- `service`: Module identifier
- `trace_id`: Distributed trace correlation ID
- `message`: Human-readable message
- `context`: Key-value pairs of relevant context

## Alert Severity Levels

| Level | Response Time | Channel | Example |
|-------|--------------|---------|---------|
| P1 | 15 minutes | Page + SMS | Service down |
| P2 | 1 hour | Slack/email | Elevated error rate |
| P3 | 1 business day | Ticket | Performance degradation |
