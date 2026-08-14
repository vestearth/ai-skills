# Verify Before Final

Use this rule before claiming work is done, fixed, safe to merge, ready to deploy, or ready for handoff.

## Required Behavior

Before a final answer, run or inspect at least one relevant verification check:

- Test
- Build
- Lint
- Typecheck
- Contract, schema, proto, or generated-code check
- Migration dry run or rollback review
- Runtime log, metric, trace, or CI check
- Search confirmation
- Manual inspection

Choose the strongest practical check for the claim being made.

## Claim Scope Must Not Exceed Evidence

Before reporting, restate the claim and the coverage of each check you ran or
cited: which package, suite, environment, or code path it actually touched. If
the claim covers anything no executed check reached, do exactly one of:

1. narrow the claim to the covered scope,
2. run the check that closes the gap, or
3. report `partial` and list the uncovered scope under "Not verified".

"All tests pass" is supported only by a command that ran all tests; a
single-package or single-test invocation supports only that package or test.
Evidence from different tasks, branches, or runs may not be summed to justify
one broad claim.

## Canonical Evidence and Fallback

When work runs inside an ai-dev-office task, checks may be recorded in that
task's canonical evidence ledger and cited by `ev-NNN` id (contract:
[../../docs/specs/2026-08-15-evidence-integration.md](../../docs/specs/2026-08-15-evidence-integration.md)).
Canonical evidence is a strengthener, never a precondition. State which tier
applies:

- **Available** — cited ids cover the claim: cite `evidence_refs` beside the
  inline command and result.
- **Absent** — no ledger exists (the normal case): run the strongest practical
  check now and quote the real output. Absence of canonical evidence degrades
  to the prose-evidence discipline above, **never to "no verification"**.
- **Partial** — cited evidence covers only part of the claim: report `partial`
  and apply the claim-scope rule above.
- **Stale** — the record's `repo_sha` is not the tree in front of you
  (`repo_sha` is provenance, not liveness): re-run the check before any merge,
  deploy, or handoff gate; cite the old id only as history, labelled stale.
- **Unreproducible** — the record cannot be re-run or its recomputed hash
  mismatches: treat the claim as unverified and say why. A hash mismatch is a
  fabrication signal, not a formatting problem.

## Failure Behavior

If verification fails:

- Fix and rerun when the fix is in scope.
- Narrow the claim when only partial evidence exists.
- Report the blocker when verification cannot run.
- Do not claim completion from intention, memory, or unrelated passing checks.

## Output Evidence

In the final answer or handoff, include:

- Verified: command, tool, file, or check used
- Result: passed, failed, partial, or not run
- Coverage: what the check actually spanned, when the claim is broader than one command
- evidence_refs: `ev-NNN` ids with their task id, when a canonical ledger exists
- Not verified: important checks skipped or unavailable
- Remaining risk: only when meaningful

## Anti-patterns

- Saying "done" after editing but before checking.
- Treating manual inspection as stronger than available automated tests.
- Claiming all tests passed after running only a narrow test.
- Omitting failed or skipped verification.
- Skipping verification because no canonical evidence ledger was available.
- Presenting a cited or recorded evidence id as if it were a check you ran, or
  as covering more than the command it recorded.
