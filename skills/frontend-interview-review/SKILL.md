---
name: frontend-interview-review
description: Use when evaluating frontend engineering interview answers, UI exercises, React/component submissions, product reasoning, accessibility, performance, or API integration judgment.
---

# Frontend Interview Review

## Use When

- Reviewing a frontend candidate's interview answer, take-home, UI exercise, component implementation, or architecture discussion.
- Evaluating product-minded UI engineering judgment.
- Producing structured feedback for frontend role leveling.

## Do Not Use When

- The task is reviewing production frontend code for merge; use `code-review` plus project-specific frontend rules.
- The interview is backend-focused; use `backend-interview-review`.
- The request asks for non-technical hiring decisions outside the evidence.

## Goal

Evaluate frontend capability using evidence across user experience, component design, state/data flow, accessibility, performance, testing, and collaboration.

## Required Inputs

- Candidate prompt or expected role level.
- Candidate answer, code, screenshots, recording, or transcript.
- Product constraints, API contract, browser/device requirements, and time limit.
- Rubric or team expectations if available.

## Process

1. Restate the user problem and expected level before evaluating implementation details.
2. Evaluate UX decomposition: user flow, empty/loading/error states, responsiveness, and clarity of interactions.
3. Evaluate component design: boundaries, state ownership, data fetching, API integration, and maintainability.
4. Evaluate accessibility: semantic HTML, keyboard behavior, focus states, labels, contrast, and screen-reader considerations.
5. Evaluate performance: unnecessary renders, large payloads, blocking work, asset handling, and perceived latency.
6. Evaluate testing and reliability: meaningful unit/integration/e2e coverage, edge cases, and regression strategy.
7. Produce level signal and follow-up questions grounded in concrete evidence.

## Output Format

- Role/level assessed
- UX and product judgment
- Technical strengths with evidence
- Risks or gaps with evidence
- Accessibility/performance notes
- Suggested score or level signal
- Follow-up questions

## Anti-patterns

- Rewarding visual polish while ignoring broken flows or inaccessible UI.
- Judging framework preference instead of engineering judgment.
- Ignoring loading, empty, and error states.
- Treating a screenshot as proof of maintainable implementation.
- Giving generic feedback that cannot be traced to the candidate artifact.
