---
name: sql-review
description: Use when reviewing SQL correctness, query plans, indexes, transactions, or schema migrations, especially PostgreSQL queries and Go/pgx data access.
---

# SQL Review

## Use When

- Reviewing SQL, wrong query results, an execution plan, index changes, or a migration.
- Checking PostgreSQL transactions, concurrency, or Go/pgx parameter binding.

## Do Not Use When

- The task is ClickHouse-specific; use `skills/clickhouse-io/SKILL.md`.
- The change is unrelated to SQL or persisted data. Use the owning review skill.
- The request is general backup administration or database provisioning.

## Goal

Preserve query semantics and data integrity, with performance and rollout
conclusions limited to the evidence actually available. First supported dialect:
PostgreSQL; do not imply other dialects were validated.

## Required Inputs

- Query/diff and caller behavior: intended rows, tenant scope, ordering, and invariants.
- Engine/version, relevant table definitions, constraints, indexes, and migration runner.
- For Go: actual pgx version, binding code, and transaction/error/context handling.
- Available tests, plans, row counts/statistics, representative parameters, and environment.

Missing inputs are evidence gaps, not permission to invent statistics or block
every source-level finding. A dependency version does not establish a deployed
engine version.

## Process

1. Read the query and caller, not just a plan snippet. Use `skills/search-first/SKILL.md`
   to locate them when needed. Read [references/postgresql.md](references/postgresql.md)
   for PostgreSQL-specific checks; confirm version-sensitive details against the
   target engine's manual.
2. Check correctness before speed: join cardinality and aggregate grain; NULLs
   and empty sets; tenant predicates through joins/subqueries; stable pagination;
   numeric precision and time boundaries where relevant. Preserve duplicate and
   ordering semantics when proposing rewrites. A sequential scan is not itself a bug.
3. Check values are bound, identifiers are allowlisted, and access scope comes
   from the caller's trusted identity. For pgx, follow actual types, Scan/Rows.Err,
   context propagation, transaction lifetime, and commit/rollback errors. Use
   `skills/golang-service-review/SKILL.md` for the surrounding Go implementation.
4. Check races against the business invariant: isolation, lock coverage/order,
   uniqueness, idempotency, and retry boundaries. A transaction alone does not
   prove concurrent safety. Mock expectations do not prove database types,
   constraints, or concurrent behavior.
5. For persisted structure changes apply
   `rules/schema-change-needs-migration/RULE.md`. Inspect the runner's transaction
   style and the table's existing rows/traffic before recommending DDL or backfill.
6. Treat index/rewrite suggestions as hypotheses until semantics and representative
   plans/timings support them. Distinguish planner estimates from measured execution.
   `EXPLAIN ANALYZE` executes the statement: before proposing or running it, identify
   authorization, environment, side effects, time/lock bounds, and a suitable fixture.
   Prefer plain EXPLAIN for initial inspection; rollback is not a general safety sandbox.
7. When a library or engine-version uncertainty affects a conclusion, use
   `skills/library-docs-lookup/SKILL.md` for that question only. Continue local
   review when lookup is unavailable, naming the unresolved claim. Documentation
   is evidence about an API, not proof a query is fast or a migration has run.
8. Verify the strongest practical layer: result fixtures for semantics, a real
   disposable DB for binding/constraints, two sessions for races, representative
   before/after measurements for speed. Apply `rules/verify-before-final/RULE.md`.

## Output Format

- Findings: severity (`error`, `warning`, `suggestion`), file/line, evidence,
  impact, and smallest corrective recommendation.
- Verdict: `approved`, `changes_requested`, `needs_evidence`, or `escalate`.
- Verification: checks actually run, environment/version and coverage; evidence
  gaps and unverified scope. Keep measured gains separate from hypotheses.
- For schema changes, include the migration rule's deploy/backfill/rollback evidence.

No findings is valid when supported by the inspected scope. Do not manufacture
an index recommendation or blocking finding to fill the output.

## Anti-patterns

- Replacing IN, JOIN, OR, or OFFSET by recipe without checking semantics and workload.
- Calling SQL faster from syntax, an index suggestion, or an estimated plan alone.
- Approving tenant isolation or idempotency without reading predicates/constraints.
- Treating BEGIN, a passing mock, or a rollback wrapper as complete safety evidence.
- Running statements on production merely because this is a review.
