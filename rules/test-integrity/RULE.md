# Test Integrity

Use this rule when fixing a bug, changing behavior, or making a failing test,
build, lint, or CI check pass.

The test suite is a contract about behavior, not an obstacle. A check may only
turn green because the code got correct, or because the expectation was wrong
and the change is explained.

## Required Behavior

### Bug fixes carry a regression test

- Reproduce the bug first, as a test that fails for the reported reason.
- Confirm the new test fails before the fix and passes after it.
- Place the test at the level that actually covers the defect: unit, table, integration, or contract.
- Assert the specific broken behavior, not just that the code runs.
- When a regression test is genuinely impractical — untestable integration seam, missing harness, external dependency — say so explicitly, name the blocker, and state the manual verification used instead. Silence is not an option.

### Never weaken a check to reach green

- Do not delete, rename-away, skip, comment out, or mark pending an existing test to make a run pass.
- Do not loosen assertions, widen tolerances, remove cases, or bend expected values to match new output.
- Do not narrow a test's input set, drop a table case, or reduce a loop bound so a failure stops appearing.
- Do not disable lint rules, type checks, or CI steps in place of fixing the cause.

### When a test really is wrong

A test may be changed or removed only when the expectation itself is wrong or
the covered behavior was intentionally retired. In that case:

- State which expectation was wrong and why the old one no longer describes correct behavior.
- Point to the requirement, contract, or user instruction that authorizes the new behavior.
- Keep the coverage: move it, rewrite it, or explain why the case is now unreachable.
- Flag it in the final answer and in the handoff; never fold it silently into an unrelated diff.

## Output Evidence

When this rule applies, record briefly:

- Regression test: file and test name, or the named blocker if none
- Failing before / passing after: the command and result for both states
- Tests changed or removed: which, and the authorizing requirement
- Coverage preserved: where the behavior is still asserted

## Anti-patterns

- Fixing the symptom and adding no test, then claiming the bug cannot recur.
- Writing the test after the fix without ever seeing it fail.
- Adding a test that passes against both the broken and fixed code.
- `t.Skip`, `.skip`, `xit`, `@Disabled`, or a deleted assertion appearing in a bug-fix diff.
- Changing an expected value to the observed output without checking which one is correct.
- Reporting a green run that only passed because a check was removed.
