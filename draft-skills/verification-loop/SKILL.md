# Verification Loop

Use this skill when a task requires confidence before final answer, merge, deploy, or handoff.

The goal is to verify claims with the strongest practical evidence available.

## Use when

- After implementing or modifying code.
- Before claiming a bug is fixed.
- Before saying tests, build, lint, or CI are clean.
- Before handing work to reviewer, QA, mobile, frontend, DevOps, or vendor.
- Before merging, deploying, releasing, or writing rollout notes.
- When debugging a reported issue.
- When reviewing risky changes in APIs, protobuf, database, auth, wallet, provider callbacks, or CI.

## Do not use when

- The task is purely brainstorming.
- The user asks only for wording or translation.
- No factual/system claim is being made.

## Required workflow

### 1. Define expected outcome

State what should be true.

Examples:

- The endpoint returns `claimable` after mission progress reaches the target.
- The service builds with `GOWORK=off`.
- The provider callback rejects invalid signatures.
- The migration is backward compatible.

### 2. Identify verification target

Identify the claim being checked:

- behavior
- contract
- compilation
- test coverage
- dependency safety
- migration safety
- runtime configuration
- documentation accuracy

### 3. Choose strongest practical check

Prefer checks in this order:

1. Automated tests
2. Build/typecheck
3. Lint/static analysis
4. Contract/schema/proto generation check
5. Migration dry run or rollback review
6. Runtime logs/metrics/traces
7. Search-based confirmation
8. Manual inspection

### 4. Run or inspect evidence

Use available tools and repository evidence.

If a command cannot be run, explain why.

### 5. Compare actual vs expected

State whether the evidence confirms the expected outcome.

### 6. Fix, retry, or escalate

If verification fails:

- fix and rerun
- narrow the issue
- document blocker
- avoid claiming completion

### 7. Report final verification

State what was verified and what was not verified.

## Evidence required

For each verification claim, include:

- command/tool/check used
- file/path/symbol when relevant
- result summary
- failed or skipped checks
- remaining risk

## Output format

```text
Verification Loop

Expected outcome:
-

Verification performed:
-

Result:
- Passed / Failed / Partial / Not run

Evidence:
-

Not verified:
-

Remaining risk:
-