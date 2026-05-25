---
name: code-review
description: Use for pull request reviews, implementation reviews, merge readiness checks, or AI handoff reviews.
---

# Code Review Skill

Review production impact before style.

## Review order

1. Correctness
2. Security
3. Contract compatibility
4. Data integrity
5. Performance
6. Observability
7. Maintainability
8. Style and naming

## Required checks

- Read the task or requested change.
- Read the actual changed files.
- Compare implementation against acceptance criteria.
- Check whether the change is within scope.
- Check tests, build output, or CI evidence when available.
- Do not approve from summaries alone.

## Finding format

For each finding, include:

- Severity: `error`, `warning`, or `suggestion`
- Location: file and line if known
- Problem
- Evidence
- Impact
- Recommendation

## Verdicts

- `approved`: no blocking issue and verification is acceptable
- `changes_requested`: correctness, security, contract, or production risk exists
- `needs_evidence`: implementation may be correct but proof is missing
- `escalate`: scope, ownership, or architecture is unclear

## Anti-patterns

- Focusing on formatting while ignoring broken behavior
- Approving without reading code
- Inventing issues from memory
- Rewriting implementation during review
- Treating generated code as automatically correct
