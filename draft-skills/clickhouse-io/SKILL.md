---
name: clickhouse-io
description: ClickHouse database patterns, query optimization, analytics, and data engineering best practices for high-performance analytical workloads.
---
# ClickHouse IO

Use this skill when designing, reviewing, or debugging ClickHouse reads, writes, schemas, retention, or analytics queries.

## Use when

- Writing ClickHouse queries.
- Designing tables, materialized views, partitions, order keys, TTL, or retention.
- Reviewing batch inserts or ingestion pipelines.
- Debugging slow analytics queries.
- Investigating high memory usage, large scans, duplicate rows, or missing data.
- Changing log/event analytics storage.

## Required workflow

### 1. Identify workload

Classify the workload:

- append-only events
- logs
- analytics aggregation
- dashboard query
- operational lookup
- batch import
- retention cleanup

### 2. Check table design

Review:

- engine
- partition key
- order key
- primary key
- TTL
- compression/codecs
- materialized views
- deduplication strategy

### 3. Check query pattern

Review:

- selected columns
- filters
- partition pruning
- order key usage
- aggregation cardinality
- joins
- LIMIT usage
- time range filters
- FINAL usage
- distributed table behavior

### 4. Check ingestion

Review:

- batch size
- insert frequency
- idempotency/deduplication
- retry behavior
- schema compatibility
- late-arriving events

### 5. Verify

Use available evidence:

- `EXPLAIN`
- query logs
- table size
- part count
- memory usage
- read rows/bytes
- execution time
- dashboard impact

## Avoid

- Using ClickHouse as an OLTP database.
- Querying without time filters on large event tables.
- Using `SELECT *` for dashboards.
- Relying on `FINAL` casually.
- Creating high-cardinality group-bys without checking scale.
- Changing partition/order keys without migration strategy.

## Output format

```text
ClickHouse IO Review

Workload:
-

Table design:
-

Query pattern:
-

Ingestion behavior:
-

Risks:
-

Recommended change:
-

Verification:
-