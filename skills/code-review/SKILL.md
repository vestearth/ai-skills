---
name: code-review
description: Use when reviewing pull requests, implementation diffs, merge readiness, AI handoffs, or short review prompts such as "รีวิวอีกรอบ", "ผ่านไหม", or "approve ได้ไหม".
---

# Code Review Skill

Review production impact before style.

## Use When

- Reviewing pull requests, implementation diffs, merge readiness, or AI handoff work.
- The user asks for a review without requesting implementation.
- The user uses short Thai review prompts such as "รีวิวอีกรอบ", "ดูให้หน่อยว่าผ่านไหม", or "approve ได้ไหม" while a diff, branch, PR, task artifact, or implementation is under review.
- You need to decide whether a change is safe to approve, request changes, or escalate.

## Do Not Use When

- The task is to debug an active failure; prefer `debugging`.
- The user asks to implement known changes rather than review them.
- The review is purely release readiness; prefer `release-checklist`.
- The diff is in a specialized domain — do not rely on this generic review alone; run the matching domain review first (it may run alongside this one): protobuf/gRPC or generated artifacts (`api-contract-review`), RabbitMQ events (`rabbitmq-event-review`), Games Labs APIs (`games-labs-api-review`), Go service implementation (`golang-service-review`), provider callbacks (`vendor-integration`), or deploy/infra manifests (`k8s-deploy-review`).

## Goal

Find correctness, security, contract, data, and production risks before merge or handoff.

## Required Inputs

- User request, task description, or acceptance criteria.
- Actual changed files or diff.
- Tests, build output, CI, logs, or verification evidence when available.

## Process

Review in this order:

1. Correctness
2. Security
3. Contract compatibility
4. Data integrity
5. Performance
6. Observability
7. Maintainability
8. Style and naming

Required checks:

- Read the task or requested change.
- Read the actual changed files.
- Compare implementation against acceptance criteria.
- Check whether the change is within scope.
- Check tests, build output, or CI evidence when available.
- Check that each claim in the PR or handoff description is covered by evidence of at least that scope; a claim broader than the checks that ran is `needs_evidence`, not `approved`.
- Do not approve from summaries alone.

Evidence citations: when the change comes from an ai-dev-office task, its role
output may cite `ev-NNN` ids in `evidence_refs`
([../../docs/specs/2026-08-15-evidence-integration.md](../../docs/specs/2026-08-15-evidence-integration.md);
ai-dev-office owns that schema, this repo only consumes it). Read them as the
author's stated verification, resolved in that task's ledger — ids are
task-scoped, and `repo_sha` is provenance, not proof the record describes this
diff. A citation never replaces reading the changed files. When there is no
ledger (the normal case), review on repo, tests, and CI evidence exactly as
before; its absence is not a reason to withhold or to grant approval.

## Output Format

For each finding, include:

- Severity: `error`, `warning`, or `suggestion`
- Location: file and line if known
- Problem
- Evidence
- Impact
- Recommendation

Then include one verdict:

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
- Approving on a cited evidence list without checking what those commands covered
