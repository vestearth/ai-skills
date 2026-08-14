# Evidence Required

Use this rule whenever an agent makes a claim about repository behavior, code ownership, safety, risk, test status, compatibility, or root cause.

## Required Behavior

- Inspect source-of-truth evidence before making codebase claims.
- Cite files, symbols, commands, tests, logs, CI, or production signals when the conclusion depends on them.
- Separate verified facts from assumptions.
- State uncertainty when evidence is incomplete.
- Do not say tests, build, lint, typecheck, CI, or deployment passed unless they actually ran.

## Claims That Need Evidence

Examples:

- This function is unused.
- This endpoint is already implemented.
- This service is safe to refactor.
- This dependency is not needed.
- This bug comes from a specific file, function, query, config, service, or deployment.
- This API response shape is safe for clients.
- This migration is backward compatible.

## Source of Truth Order

Prefer evidence in this order:

1. Current repository files
2. Tests, build output, lint, typecheck, or CI
3. Runtime logs, metrics, traces, dashboards, or production signals
4. Generated artifacts, schemas, protobuf, OpenAPI, or migration files
5. Indexed/search context such as SocratiCode
6. Previous summaries or chat history

Indexed context and AI memory are discovery aids, not final proof.

Agent narrative is never evidence. A summary, checklist, handoff report, or
list of evidence ids is a claim *about* evidence; the evidence is the command
that ran and the output it produced.

## Canonical Execution Evidence

When work runs inside an ai-dev-office task, verification commands may be
recorded in that task's canonical evidence ledger and cited by `ev-NNN` id.
See [../../docs/specs/2026-08-15-evidence-integration.md](../../docs/specs/2026-08-15-evidence-integration.md)
for the full contract; ai-dev-office owns that schema and this repo only
consumes it.

- Cite ids as `evidence_refs`, always paired with their task id. Ids are
  task-scoped, not globally unique.
- A recorded id does **not** outrank the Source of Truth Order above. It is a
  durable record *of* a layer 1-4 check, not a higher authority than re-running
  that check.
- `repo_sha` on a record is provenance, not liveness. A valid record can
  describe a tree that no longer exists.
- **No ledger is the normal case.** Outside ai-dev-office, fall back to the
  evidence block below unchanged — absence of canonical evidence degrades to
  prose evidence, never to "no verification".

## Output Evidence

Use a compact evidence block when evidence matters:

```text
Evidence:
- File/symbol:
- Search/tool:
- Result:
- Verification:
- evidence_refs: <ev-NNN (task-id), or omit when no ledger exists>
```

## Anti-patterns

- Saying "looks unused" after one failed search.
- Claiming compatibility without checking callers or contracts.
- Treating generated code, stale index results, or old summaries as final proof.
- Hiding unverified assumptions behind confident wording.
- Citing an `ev-NNN` id without its task id, or citing one that was never seen
  in that task's ledger.
- Treating a cited evidence id as proof stronger than the current repository,
  test run, or runtime signal it was supposed to record.
