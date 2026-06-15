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
- Not verified: important checks skipped or unavailable
- Remaining risk: only when meaningful

## Anti-patterns

- Saying "done" after editing but before checking.
- Treating manual inspection as stronger than available automated tests.
- Claiming all tests passed after running only a narrow test.
- Omitting failed or skipped verification.
