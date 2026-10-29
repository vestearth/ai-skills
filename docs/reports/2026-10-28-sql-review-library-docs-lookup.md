# SQL Review and Library Documentation Lookup Verification

Date: 2026-10-28 (Asia/Bangkok)
Source baseline: `2f4f8f6`; uncommitted implementation on
`feat/sql-review-library-docs-lookup`.
Status: both skills implemented as beta; active-machine rollout and live
Context7 acceptance are separate from the source and fixture checks below.
The 2026-10-29 follow-up at the end records installed-cache, live anonymous
Context7, and real Go/pgx checks that supersede some initial limitations.

## Delivered

- `sql-review`: PostgreSQL/pgx correctness, isolation, binding, migration and
  performance-evidence review, with a PostgreSQL reference and 10 behavioral cases.
- `library-docs-lookup`: provider-independent documentation lookup, requested
  versus served versions, source/date provenance, bounded fallback, and 11 cases.
- README, VERSION, repo AGENTS, Codex/Cursor adapters and Claude hook routes.
- Codex package version `0.2.0`; the package still discovers `./skills/`.
- Existing installer and evaluation formats; no new runtime dependency or runner.

## Static and installer checks

| Check | Observed result | Coverage |
| --- | --- | --- |
| `bash scripts/validate-skills.sh` | 45 skills passed | Required sections, routing/reference coverage and metadata/case schema |
| `bash adapters/claude/hooks/tests/run-skill-routing-tests.sh` before hook edit | 55 passed, 6 failed | New positive routes absent; all existing assertions retained |
| Same routing suite after hook edit | 61 passed, 0 failed | SQL/pgx/PostgreSQL, docs/version/Context7, Thai prompts, negative routing and existing guardrails |
| `bash scripts/test-install-claude.sh` | 45 skills passed | Isolated sync, prune and idempotency |
| `bash scripts/test-install-cursor.sh` | 4 rules passed | Isolated nested and standalone layouts |
| `git diff --check` and manual checks of new files | Passed | Whitespace; no zero-width characters in new skill files |
| Skill Creator `quick_validate.py` | Unavailable: local Python lacks PyYAML | Not reported as passed; repository's Ruby-backed validator above completed |

No existing test case or assertion was removed or weakened. The hook change is
covered by the observed before/after failure. Behavioral fixture expectations
are evaluated separately from schema validation.

## Behavioral replay

Each CLI received the same authored skill/reference text and each case's
`scenario`, with `expected` withheld. Cases were independent. The replay asked
for findings/actions and evidence scope, not self-grading. No SQL, external
lookups, or local source access was needed for these supplied-input runs.
The conductor inspected each answer against `expected`; this is a manual
behavioral evaluation, not an automated quality benchmark.

| Cases | Codex CLI | Claude Code CLI | Cursor Agent CLI |
| --- | --- | --- | --- |
| sql-001 join fan-out | pass | pass | pass |
| sql-002 NULL-sensitive NOT IN | pass | pass | pass |
| sql-003 tenant join | pass | pass | pass |
| sql-004 dynamic ORDER BY injection | pass | pass | pass |
| sql-005 lost update | pass | pass | pass |
| sql-006 concurrent index/runner transaction | pass | pass | pass |
| sql-007 unsupported speedup | pass | pass | pass |
| sql-008 production ANALYZE proposal | pass | pass | pass |
| sql-009 correct keyset query | pass | pass | pass |
| sql-010 ClickHouse exclusion | pass | pass | pass |
| docs-001 exact supplied fixture and provenance | pass after clarification | pass after clarification | pass |
| docs-002 mismatched served version | pass | pass | pass |
| docs-003 unknown served version | pass | pass | pass |
| docs-004 ambiguous library | pass | pass | pass |
| docs-005 no match | pass | pass | pass |
| docs-006 no connection | pass | pass | pass |
| docs-007 exhausted budget/429 | pass | pass | pass |
| docs-008 timeout with independent findings | pass | pass | pass |
| docs-009 sanitized proposed query | pass | pass | pass |
| docs-010 fetched instruction injection | pass | pass | pass |
| docs-011 unrelated local edit | pass | pass | pass |

Latest supplied-input results: SQL 10/10 and documentation 11/11 on each lane
(63 case evaluations). SQL and docs metadata record these passing case replays;
both remain beta. This does not establish live provider behavior or installed
discovery on every operator's machine.

Initial structured Codex/Claude replies omitted some fixture provenance/date.
The docs output contract was clarified to retain evidence in structured answers
and distinguish the current review date from an unknown original retrieval date.
All 11 docs cases were then replayed on all three lanes against the revised
contract. The expectation was clarified to require that distinction, not relaxed.

### Runtime identity and timing

| Lane | Model evidence | Observed replay wall time |
| --- | --- | --- |
| Codex | Requested `gpt-6-sol`, medium; backend accepted, no separately returned model ID | 35.04 s for initial 21; 52.04 s for revised docs 11 |
| Claude | Response `modelUsage`: `claude-sonnet-5-5` | 53.14 s for initial 21; 37.03 s for revised docs 11 |
| Cursor | Default/Auto; response did not expose resolved model | 333.80 s for initial 21; 192.00 s for revised docs 11 |

The first Codex attempt requested `gpt-6.1-sol` and was rejected by this CLI's
ChatGPT-account backend. The retry used `gpt-6-sol` from the local catalog;
the failed attempt is not a replay pass. The initial Cursor invocation required
trust for the authored temporary workspace; the retry used read-only ask mode
with trust limited to that workspace, not a blanket force/permission bypass.

These timings describe synthetic batch replays with different models and
startup contexts. They are not model comparisons or measurements of Context7
latency, token overhead, SQL performance, or productivity savings.

## Executable SQL expectation checks

A disposable `postgres:17-alpine` container reported PostgreSQL `17.11`. It used
synthetic data, ephemeral storage, no network and no published ports. Parent-run
checks observed:

- sql-001: original aggregate 60; intended-grain rewrite 30.
- sql-002: nullable NOT IN returned no rows; correlated NOT EXISTS returned 1.
- sql-003: ID-only join returned two tenants; tenant-qualified join returned one.
- sql-005: two real Read Committed sessions both read 100, committed two debit
  records, and left balance 90, reproducing the lost update.
- sql-006: concurrent index creation inside BEGIN failed with the documented
  transaction-block error.
- sql-009: PostgreSQL PREPARE/EXECUTE preserved bound tenant/keyset parameters
  and returned IDs 2,3. This is not a Go/pgx integration test.
- sql-008 safety premise: ANALYZE executed nextval on a disposable sequence;
  rollback did not reverse its advance. No production DELETE was executed.

The container was stopped and removed. No production data, service repo,
migration or live database was touched. These checks validate selected fixture
expectations; they do not prove arbitrary reviewed SQL or real pgx bindings.

## Fresh-session discovery and rollout

The pilot installed the existing adapters into a temporary workspace only,
with a source-repo link. Its prompt named the SQL/docs tasks, not the skills or
their exact paths. This separates discovery from supplied-content replay.

- Codex: successful command trace read both new SKILL.md files and the PostgreSQL
  reference through the shipped AGENTS adapter. This used source routing, not
  the installed Codex plugin cache.
- Claude: after enabling the `project` setting source for this invocation,
  initialization listed both skills and the stream trace invoked both Skill
  tools. An earlier test disabled all setting sources and therefore excluded
  project skills; it was not counted as a discovery pass.
- Cursor: a separate successful stream trace observed completed reads of both
  new SKILL.md files through the temporary Claude mirror, plus the PostgreSQL
  reference and shared rules. Cursor reported the injected AGENTS/Cursor routes.
  The 127.83 s trace establishes local loading; the shared pilot contains both
  adapters, so it does not isolate Cursor rules as the only discovery mechanism.
  Its broader searches matched eval paths; this discovery run is not used as a
  blind behavioral score. The 63 supplied-input evaluations above used no files.

The active Codex `0.1.1` cache was inspected and contains neither new skill.
Source package `0.2.0` prepares refresh, but no active cache/config was changed.
Active Claude/Cursor installation and open chats were also left unchanged.

## Not verified / release limits at initial verification (2026-10-28)

- No Context7 tool was exposed in this session. Live resolve/query/version
  fallback, authentication and rate limiting were not exercised; error and
  response cases above are explicitly supplied fixtures.
- No live with/without-Context7 time/token comparison; usage telemetry from
  model runs does not isolate documentation-provider overhead.
- No claim of active-machine rollout, cached package refresh, live database
  optimization, or Go/pgx integration acceptance.
- No commit, push, PR, release tag or deployment was performed.

Rollback of source guidance is the normal task-commit revert after publication.
Any later authorized installed-package rollout needs its own restore/removal
verification; reverting source alone cannot revert an installed cache.

## Reviewed content fingerprints

SHA-256, before metadata/report-only edits:

```text
b0c7037f5b5c3f6c9e7e9e660491a81f1dfcdcefa9ca45cf7ed6bd3efaa1caf3  skills/sql-review/SKILL.md
24209a15ebb99086a13a955814459cbc90eb98dcdde04a907f7e356e491c8793  skills/sql-review/evals/cases.yaml
ac0c79ecaa7e1e64362a3386f8d2a132c2d75e2d81d3507050f215145533cae1  skills/library-docs-lookup/SKILL.md
134b872c61bffb50a50b15c62ebfc4e8a6000aa0c58af89f3796b5dd6d5f1937  skills/library-docs-lookup/evals/cases.yaml
```

## Follow-up verification — 2026-10-29

### Installed Codex package

- `codex plugin list --json --marketplace local-workspace-plugins` reports
  `ai-skills` version `0.2.0`, installed and enabled.
- All four files of each new skill (entrypoint, reference, metadata and cases)
  match the source hashes: eight files checked, no mismatches.
- A fresh read-only Codex session, outside the source repository, selected and
  successfully read both SKILL.md files plus the PostgreSQL reference from the
  installed `0.2.0` cache. Its prompt supplied tasks, not skill names or paths.
- The response identified join fan-out (60 versus 30) and rejected an exact
  version claim for requested v5.7.6 versus served v5.11.0. Elapsed: 31.71 s.
- This closes the earlier Codex-cache freshness gap. No installation/config
  was changed by this test, and it does not establish active Claude/Cursor rollout.

### Live Context7 REST API

These were actual HTTPS requests with no API key, account connection, cookies,
private code or production data. The public question concerned transaction
cleanup in pgx. No credential was searched for or provisioned.

| Request | HTTP | Observed result | Elapsed |
| --- | --- | --- | --- |
| Search `pgx` | 200 | `/jackc/pgx`; listed versions v5.8.0, v5.9.0, v5.10.0, v5.11.0 | 1.96 s |
| Context `/jackc/pgx/v5.11.0` | 200 | Snippet source URLs name v5.11.0; no top-level version object | 2.72 s |
| Context `/jackc/pgx/v5.7.6` | 200 | Requested v5.7.6, served v5.11.0, provider status `unverified` | 1.57 s |

The final response contained this public metadata:

```json
{"libraryId":"/jackc/pgx/v5.11.0","requested":"v5.7.6","served":"v5.11.0","status":"unverified"}
```

Our coverage classification is **mismatched**, not exact. The provider's
`unverified` label is not substituted for the skill's coverage vocabulary.
The old version was not silently assumed from the request or HTTP status.

The indexed snippet URL used an `_autodocs` path that the web fetch could not
retrieve; that failure was not treated as proof the upstream file does not
exist. The API claim was corroborated through the official versioned pkg.go.dev
pages for [v5.7.6](https://pkg.go.dev/github.com/jackc/pgx/v5@v5.7.6#Conn.Begin)
and [v5.11.0](https://pkg.go.dev/github.com/jackc/pgx/v5@v5.11.0#Conn.Begin).
Thus the official-docs fallback closed this specific API question even though
the Context7 result was not exact for v5.7.6.

### Live Context7 MCP endpoint

The separate public PostgreSQL question used anonymous Streamable HTTP requests
to the documented endpoint, without permanently registering a server:

- Initialize: HTTP 200, protocol `2025-03-26`, server Context7 `4.4.3` (1.13 s).
- Tools/list: HTTP 200; `resolve-library-id` and `query-docs` exposed with
  read-only/non-destructive annotations (1.08 s).
- Resolve PostgreSQL: HTTP 200 with `/websites/postgresql` and an available
  version 17 (2.32 s).
- Query `/websites/postgresql/17`: HTTP 200 with PostgreSQL 17 source URLs for
  EXPLAIN execution behavior (1.79 s).

One resolution and one documentation call were used for this question; the pgx
REST question used one resolution and two documentation calls. Both stayed
inside the skill's lookup budget. Tool annotations were treated as metadata,
not as authorization or evidence of SQL execution safety.

The retrieved PostgreSQL response also included generated wording implying that
a rollback wrapper avoids all side effects. That broad statement is not accepted
as a safety guarantee: the source review must still account for locks, load,
sequence/external effects, and execution authorization. This illustrates why
retrieved examples remain reference data rather than review instructions.

These observations establish anonymous lookup at test time, not authenticated
account access, quota limits, 429 handling, or permanent ChatGPT/agent integration.
The ChatGPT plugin catalog still reported Context7 as not installed.

### Real Go/pgx integration

`TestRealPGXBindingAndTransactionCleanup` passed in a temporary Go module using
Go `1.25.6`, cached `github.com/jackc/pgx/v5 v5.7.1`, and disposable PostgreSQL
`17.11`. `GOWORK=off`, `GOPROXY=off`, and `GOTOOLCHAIN=local` were used; no module
dependency was added to this repository.

The test verified actual driver/server behavior:

- Numeric text `12.34`, integer-array filtering, and a synthetic hostile text
  value survive binding without being interpolated as SQL.
- Canceling the context passed to Begin leaves the transaction open; a later
  command using a live context still succeeds.
- Explicit rollback removes the pending insert and restores idle transaction
  status.
- A command with an already canceled context fails; rollback with a fresh
  bounded context restores idle state.

The test function passed in 0.06 s; the full Go command completed in 4.24 s.
The fixture database had ephemeral storage and a loopback-only ephemeral port;
the container was stopped/removed afterward. This covers pgx v5.7.1, not the
v5.7.6 documentation fixture, arbitrary bindings, pool release, or production.

### Remaining boundaries

- Single-request timings above are observations, not a latency distribution,
  controlled model/token-overhead comparison, or productivity benchmark.
- Live authentication, rate-limit/error injection, active Claude/Cursor setup,
  permanent Context7 configuration, publication and production remain unverified.
- One supplementary Codex review of a live fetched response failed before
  producing an answer because the selected model was at capacity; it is not
  counted as a passing review.
- The same fetched-response scenario was then reviewed with the installed-cache
  contract supplied to Claude (`claude-sonnet-5-5`, 26.54 s). It correctly refused
  approval of the unbounded production diagnostic and distinguished PostgreSQL
  17 documentation from an unverified deployed engine. However, the answer also
  asserted that the rolled-back DELETE leaves dead tuples/bloat. This extra
  claim was unsupported and is not accepted as a passing detail.
- A separate disposable PostgreSQL 17 fixture with `pgstattuple` measured
  1,000 live / 0 dead tuples before DELETE and 1,000 live / 0 dead tuples after
  DELETE/ROLLBACK; all 1,000 rows remained visible. This disproves the universal
  dead-tuple assertion, not the remaining lock/load/side-effect concerns.
  The supplementary model review is **partial**, not an additional passing
  evaluation. The database container was stopped and removed.
- No skill body, case expectation, or test assertion was changed in this follow-up.
  The SQL metadata records this observed failure mode; its passing evaluation
  fields still describe the dated 10-case baseline, not the supplementary case.
  The eight-file cache equality check above preceded this metadata-only note;
  the runtime skill bodies, references and fixtures remain unchanged.
