---
name: debugging
description: Use when investigating bugs, failed tests, logs, crashes, incorrect behavior, or short operator prompts such as "พังจากไหน", "อันนี้จากไหน", or "แปลกไหม".
---

# Debugging Skill

## Use When

- Investigating bugs, failed tests, crashes, logs, incorrect behavior, or production symptoms.
- The user uses short Thai debugging/source-tracing prompts such as "พังจากไหน", "อันนี้จากไหน", "ทำไมพัง", or "แปลกไหม" with an error, log, screenshot, route, code snippet, or observed behavior.
- A root cause is unknown or only suspected.
- Code, docs, logs, and observed behavior disagree.

## Do Not Use When

- The task is only a code review with no active failure to investigate.
- The user is asking for sprint planning, release readiness, or architecture review.
- Repository evidence is unavailable and the answer must be framed as an assumption.

## Goal

Identify the root cause from evidence, propose the smallest safe fix, and verify the original symptom is resolved.

## Required Inputs

- User-reported symptom or failing command.
- Relevant source files, tests, logs, stack traces, CI output, or runtime evidence.
- Expected behavior or acceptance criteria when available.

## Process

1. Define the exact symptom.
2. Collect evidence from source, tests, logs, CI, or runtime output.
3. List candidate causes.
4. When the behavior works in one environment and not another, diff that environment's rendered configuration before instrumenting code. A dependency built only when its variable is set turns a missing variable into a normal-looking business error.
5. Eliminate impossible causes with evidence.
6. Identify the root cause.
7. Propose or implement the minimal fix.
8. Verify the fix against the original symptom: the reproduction that failed before must be re-run after, and the "fixed" claim must not cover more than that re-run showed.

## Canonical Evidence

Two checks carry a debugging conclusion: the reproduction of the symptom and
the post-fix re-run of that same reproduction. Inside an ai-dev-office task,
run both through the office evidence wrapper and cite the returned `ev-NNN`
ids (with their task id) beside Evidence and Verification
([../../docs/specs/2026-08-15-evidence-integration.md](../../docs/specs/2026-08-15-evidence-integration.md);
ai-dev-office owns that schema, this repo only consumes it) — the before/after
pair is what turns a root-cause story into a demonstrated one.

Outside such a task there is no ledger, which is the normal case: capture the
same before/after commands and their real output inline. Missing canonical
evidence never permits declaring a root cause or a fix without a reproduction.
A stale record — `repo_sha` is provenance, not liveness — proves nothing about
the current tree; re-run it.

## Output Format

- Symptoms
- Evidence (reproduction command and real output; `evidence_refs: ev-NNN (task-id)` when a ledger exists)
- Candidate causes
- Root cause
- Fix
- Verification: the re-run after the fix, and what it did not cover

## Anti-patterns

- Guessing from memory before inspecting evidence.
- Fixing multiple unrelated issues while debugging one symptom.
- Treating a passing unrelated test as proof.
- Reading the absence of a log line as evidence without first confirming that line can reach the log sink and that the code path actually runs.
- Stopping at a workaround without naming the root cause.
- Declaring the symptom fixed without re-running the reproduction that demonstrated it.
- Generalizing "fixed" beyond the case the re-run actually covered.
