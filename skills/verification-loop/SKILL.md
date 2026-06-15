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
6. If verification fails, fix and retry, narrow the claim, or report the blocker.
7. Report what was verified and what was not verified.

## Output Format

- Expected outcome
- Verification performed
- Result: passed, failed, partial, or not run
- Evidence
- Not verified
- Remaining risk

## Anti-patterns

- Saying work is complete without running or inspecting a relevant check.
- Claiming broad test coverage from one targeted test.
- Omitting failed, skipped, or unavailable verification.
- Treating intent, memory, or unrelated passing checks as proof.
