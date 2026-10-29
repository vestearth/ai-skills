# PostgreSQL Review Checks

Use only the sections relevant to the reviewed query. The PostgreSQL 17 links
below are a reference baseline, not an assertion about the target's engine.
Select that engine's versioned manual; for pgx use its actual module version.

## Query semantics

- Write down the result grain before joining. Two one-to-many joins can multiply
  rows and inflate SUM/COUNT. Aggregate at the intended grain or use an existence
  check where appropriate; DISTINCT is not a universal fix.
- NOT IN with a nullable subquery can yield unknown rather than true. Check the
  intended treatment of NULL on both sides before proposing NOT EXISTS.
- A predicate on the nullable side of LEFT JOIN in WHERE can remove unmatched
  rows. Check whether the intended filter belongs in ON or after the join.
- Trace tenant keys through every access. A tenant filter on one table does not
  constrain a join on a key that is unique only within each tenant.
- Require a total ordering for repeatable pagination (a unique tie-breaker), and
  matching ordering/direction for a keyset cursor. Check timezone and inclusive
  boundaries, decimal scale, and empty SUM versus zero against caller semantics.

Sources: [joins](https://www.postgresql.org/docs/17/queries-table-expressions.html),
[subquery NULL behavior](https://www.postgresql.org/docs/17/functions-subquery.html),
[ordering and LIMIT](https://www.postgresql.org/docs/17/queries-limit.html).

## Transactions and pgx

- Read Committed is not a serial execution guarantee. Check competing operations
  with two sessions: a read/check/write may need atomic conditional DML, locks,
  uniqueness, or a stronger isolation/retry design depending on the invariant.
- A uniqueness constraint can enforce idempotency only for the correct business
  key; handle conflict outcomes without duplicating dependent effects.
- Bind values through pgx arguments; SQL identifiers cannot be supplied as value
  parameters. Check dynamic identifiers against a fixed allowed set.
- Check commit failures and explicit transaction cleanup. pgx Begin's context
  does not automatically roll back a transaction after context cancellation.
  Inspect lifecycle and pool release; do not infer cleanup from defer alone.
- Test actual parameter/array/numeric types and constraints against PostgreSQL;
  a mock can validate call shape without validating server behavior.

Sources: [isolation](https://www.postgresql.org/docs/17/transaction-iso.html),
[explicit locking](https://www.postgresql.org/docs/17/explicit-locking.html),
[pgx API](https://pkg.go.dev/github.com/jackc/pgx/v5) (choose the pinned release).

## DDL and measured performance

- Apply `rules/schema-change-needs-migration/RULE.md`; inspect existing data,
  deployment compatibility and the runner, not only standalone DDL syntax.
- CREATE INDEX CONCURRENTLY cannot run inside a transaction block. Assess its
  trade-offs and failure cleanup rather than prescribing it for every index.
- Consider lock acquisition, table rewrites, backfill batches, existing invalid
  rows, and validation steps before adding constraints to populated tables.
- EXPLAIN costs/rows are estimates. ANALYZE executes statements and adds
  instrumentation overhead; even SELECT can call functions with side effects.
  Rollback does not undo all effects (for example sequence advances or external
  effects). Review on disposable synthetic data when execution is necessary.
- Compare equivalent results before speed; control parameters, data distribution,
  statistics and cache conditions. State what the measurements do not represent.

Sources: [index creation](https://www.postgresql.org/docs/17/sql-createindex.html),
[ALTER TABLE](https://www.postgresql.org/docs/17/sql-altertable.html),
[EXPLAIN](https://www.postgresql.org/docs/17/sql-explain.html),
[sequence behavior](https://www.postgresql.org/docs/17/functions-sequence.html).
