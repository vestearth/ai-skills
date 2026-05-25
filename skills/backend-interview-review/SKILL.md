---
name: backend-interview-review
description: Use when evaluating backend engineering interview answers, take-home submissions, system design responses, debugging exercises, or production-readiness judgment.
---

# Backend Interview Review

## Use When

- Reviewing a backend candidate's interview answer, code exercise, take-home, or system design response.
- Comparing candidate performance against a backend role expectation.
- Producing structured feedback that separates evidence from impression.

## Do Not Use When

- The task is reviewing production code for merge; use `code-review` or `golang-service-review`.
- The interview is frontend-specific; use `frontend-interview-review`.
- The request asks for hiring policy or compensation decisions outside technical evaluation.

## Goal

Evaluate backend capability using concrete evidence across correctness, systems thinking, production judgment, and communication.

## Required Inputs

- Candidate prompt or role level.
- Candidate answer, code, architecture diagram, or transcript.
- Evaluation rubric if one exists.
- Constraints such as time limit, allowed tools, and expected seniority.

## Process

1. Restate the task and expected level before judging the answer.
2. Evaluate correctness: requirements coverage, edge cases, data modeling, API behavior, and failure handling.
3. Evaluate backend fundamentals: concurrency, transactions, idempotency, consistency, security, performance, and dependency boundaries.
4. Evaluate production thinking: observability, deployment, rollback, migrations, incident handling, and operational tradeoffs.
5. Evaluate testing/debugging: meaningful tests, reproducibility, root-cause method, and ability to reduce uncertainty.
6. Evaluate communication: assumptions stated, tradeoffs explained, scope controlled, and questions asked when requirements are ambiguous.
7. Produce a verdict tied to evidence, not personality or style preference.

## Output Format

- Role/level assessed
- Strengths with evidence
- Risks or gaps with evidence
- Suggested score or level signal
- Follow-up questions
- Hiring recommendation boundaries

## Anti-patterns

- Penalizing unfamiliar syntax more than broken system reasoning.
- Giving generic feedback without quotes, code references, or transcript evidence.
- Treating confidence as competence.
- Ignoring role level and time constraints.
- Making a hire/no-hire call from one weak signal.
