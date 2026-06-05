---
name: debugging
description: Use for bugs, failed tests, logs, crashes, incorrect behavior.
---

# Debugging Skill

## Use When

- Investigating bugs, failed tests, crashes, logs, incorrect behavior, or production symptoms.
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
4. Eliminate impossible causes with evidence.
5. Identify the root cause.
6. Propose or implement the minimal fix.
7. Verify the fix against the original symptom.

## Output Format

- Symptoms
- Evidence
- Candidate causes
- Root cause
- Fix
- Verification

## Anti-patterns

- Guessing from memory before inspecting evidence.
- Fixing multiple unrelated issues while debugging one symptom.
- Treating a passing unrelated test as proof.
- Stopping at a workaround without naming the root cause.
