---
name: verification-loop
description: Use when work needs evidence before final answer, merge, deploy, release, handoff, or claims that a bug is fixed.
---

# Verification Loop

Verify claims with the strongest practical evidence available before reporting completion.

## Use When

- After implementing or modifying code.
- Before claiming a bug is fixed.
- Before saying tests, build, lint, typecheck, CI, or deployment are clean.
- Before handing work to reviewer, QA, mobile, frontend, DevOps, or vendor.
- Before merging, deploying, releasing, or writing rollout notes.
- When debugging a reported issue.
- When reviewing risky changes in APIs, protobuf, database, auth, wallet, provider callbacks, CI, or deployment.

## Do Not Use When

- The task is purely brainstorming.
- The user asks only for wording, translation, or explanation.
- No factual, behavioral, system, or completion claim is being made.
- Auditing a completion report produced by another agent or session; use `completion-audit`.

## Required Rule

Apply `rules/verify-before-final/RULE.md` and `rules/evidence-required/RULE.md`.

## Goal

Prevent false completion claims by comparing expected outcomes against concrete evidence.

## Required Inputs

- Expected outcome or acceptance criteria.
- Relevant changed files, contracts, tests, logs, CI output, or runtime evidence.
- Available verification commands or manual inspection target.

## Process

1. Define what should be true.
2. Identify the claim being checked: behavior, contract, compilation, dependency safety, migration safety, runtime config, or documentation accuracy.
3. Choose the strongest practical check: test, build/typecheck, lint, contract/schema/proto generation, migration dry run, runtime evidence, search confirmation, or manual inspection.
4. Run or inspect the evidence.
5. Compare actual result with expected outcome.
6. Compare the claim's scope against what the checks actually covered. The claim must not exceed the packages, suites, environments, or code paths the executed commands reached — narrow the claim, run the check that closes the gap, or report `partial` with the uncovered scope named.
7. If verification fails, fix and retry, narrow the claim, or report the blocker.
8. Report what was verified and what was not verified.

## Canonical Evidence

Inside an ai-dev-office task, run verification commands through the office
evidence wrapper and cite the returned `ev-NNN` ids as `evidence_refs`, always
paired with their task id (ids are task-scoped, not globally unique). Contract:
[../../docs/specs/2026-08-15-evidence-integration.md](../../docs/specs/2026-08-15-evidence-integration.md) —
ai-dev-office owns that schema; this repo only consumes it.

Canonical evidence is a strengthener, never a precondition:

- **Absent** (no ledger — the normal case outside ai-dev-office): run the
  strongest practical check now and quote the real command and output. Absence
  degrades to prose evidence, **never to "no verification"**.
- **Partial**: result is `partial`; cite what is covered, name what is not.
- **Stale** (`repo_sha` is not the tree in front of you — it is provenance, not
  liveness): re-run before any merge, deploy, or handoff claim.
- **Unreproducible** (cannot re-run, or the recomputed hash mismatches): the
  claim is unverified; say why.

A cited id is a record of a check, not a substitute for the current repository,
test run, or runtime signal — and never a substitute for having run anything.

## Output Format

- Expected outcome
- Verification performed
- Result: passed, failed, partial, or not run
- Evidence (commands and real output; `evidence_refs: ev-NNN (task-id)` when a ledger exists)
- Coverage: what the executed checks actually spanned
- Not verified
- Remaining risk

## Anti-patterns

- Saying work is complete without running or inspecting a relevant check.
- Claiming broad test coverage from one targeted test.
- Omitting failed, skipped, or unavailable verification.
- Treating intent, memory, or unrelated passing checks as proof.
- Accepting a mock or stub as proof of behavior only the real dependency can exhibit.
- Skipping verification because no canonical evidence ledger exists.
- Citing an evidence id as if it were a check you ran, or letting a cited id cover more than the command it recorded.
- Summing evidence from separate tasks, branches, or runs to support one broad claim.
