---
name: clickhouse-io
description: Use when designing, reviewing, or debugging ClickHouse tables, ingestion, analytics queries, retention, or high-volume event storage.
---

# ClickHouse IO

Review ClickHouse reads, writes, schemas, retention, and analytics workloads for correctness and scale.

## Use When

- Writing or reviewing ClickHouse queries.
- Designing tables, materialized views, partitions, order keys, TTL, or retention.
- Reviewing batch inserts, ingestion pipelines, deduplication, or late-arriving events.
- Debugging slow analytics queries, high memory usage, large scans, duplicate rows, or missing data.
- Changing log, event, dashboard, or analytics storage.

## Do Not Use When

- The database is not ClickHouse.
- The change is only application code with no ClickHouse query, schema, or ingestion effect.
- A broader incident, release, or deployment workflow is more urgent.

## Goal

Keep ClickHouse workloads efficient, bounded, and compatible with analytical access patterns.

## Required Inputs

- Workload type: append-only events, logs, aggregation, dashboard query, lookup, batch import, or retention cleanup.
- Relevant table DDL, query, ingestion code, materialized view, retention rule, or dashboard.
- Evidence such as `EXPLAIN`, query logs, table size, part count, read rows/bytes, execution time, memory usage, or dashboard impact when available.

## Process

1. Identify the workload.
2. Check table design: engine, partition key, order key, primary key, TTL, codecs, materialized views, and deduplication.
3. Check query pattern: selected columns, filters, partition pruning, order key usage, cardinality, joins, `LIMIT`, time range filters, `FINAL`, and distributed-table behavior.
4. Check ingestion: batch size, insert frequency, idempotency, retry behavior, schema compatibility, and late-arriving events.
5. Identify risks and choose the smallest safe change.
6. Verify with `EXPLAIN`, query logs, table metrics, tests, or manual inspection when commands are unavailable.

## Output Format

- Workload
- Table design
- Query pattern
- Ingestion behavior
- Risks
- Recommended change
- Verification

## Anti-patterns

- Using ClickHouse as an OLTP database.
- Querying large event tables without time filters.
- Using `SELECT *` for dashboards.
- Relying on `FINAL` casually.
- Creating high-cardinality group-bys without scale evidence.
- Changing partition or order keys without migration strategy.
