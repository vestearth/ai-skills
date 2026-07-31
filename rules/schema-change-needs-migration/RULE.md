# Schema Change Needs Migration

Use this rule before changing anything that defines persisted structure: an ORM
model or entity, a struct or class mapped to a table, a `CREATE TABLE` or DDL
file, an index, a constraint, an enum stored in a column, a materialized view,
or a document/collection shape.

The running database does not change because a type changed. Application code and
schema drift apart silently, and the failure surfaces in the next deploy — not in
the diff.

## Required Behavior

- Ship the migration in the same change as the code that depends on it.
- Name the migration in the final answer, by path.
- Follow the repository's existing migration mechanism and numbering; never
  hand-edit a schema by connecting to a database instead of writing a migration.
- Never edit an already-applied migration file to change its meaning. Applied
  migrations are immutable history; correct them with a new migration.
- State the rollback path: a down migration, a compensating migration, or an
  explicit note that the change is forward-only and why.
- Check whether the repository replays every migration on every boot. When it
  does, every statement must be idempotent (`IF NOT EXISTS`, guarded
  `ALTER`, re-runnable backfills) or the next deploy crashes on an old file.
- Treat data backfills as part of the change: a new non-null column, a widened
  enum, or a renamed field needs a stated plan for existing rows.

## Deploy Order And Compatibility

A migration and the code that reads it do not land at the same instant. Before
merging, answer:

- Can the currently-deployed code run against the new schema? (Migration lands first.)
- Can the new code run against the old schema? (Code may land first.)
- If neither, the change is breaking: split it into expand → migrate → contract
  across separate releases, and say so.

Destructive steps — `DROP COLUMN`, `DROP TABLE`, narrowing a type, removing an
enum value — belong in the contract phase, after nothing reads the old shape.

## Repository Contracts Win

The project's own migration contract overrides this rule's defaults: check the
project `AGENTS.md`, `CLAUDE.md`, existing `migrations/` files, and the runner
that applies them. Match the numbering, file naming, and transaction style
already in use rather than introducing a second convention.

## Output Evidence

When this rule applies, record:

- Schema change: table, column, index, constraint, or type
- Migration: file path, and the runner or command that applies it
- Idempotent: yes/no, and why it matters in this repository
- Deploy order: migration first, code first, or expand/contract split
- Backfill: plan for existing rows, or none needed
- Rollback: down migration, compensating migration, or forward-only with reason

## Anti-patterns

- Changing a model or entity and calling it done because the build passes.
- Editing an existing migration file that has already run somewhere.
- Writing a migration that only works on an empty database.
- Adding a non-null column with no default and no backfill.
- Dropping a column in the same release that stops writing to it.
- Applying DDL by hand on staging or production and never committing it.
- Assuming a migration ran because the deploy was green.
