---
name: games-labs-implementation-status
description: Use when answering Games Labs mobile/backend follow-up status questions such as whether a behavior is already implemented, whether code must be fixed before replying, whether QA/staging may be on an old deploy, or what English reply to send back. Trigger on pasted follow-up messages or questions from the Mobile team, QA, Dev, or PM, and on short operator prompts like "what should I reply?", "implemented yet?", "mobile asked this", "ทีม mobile ถามมา", "ต้องแก้ก่อนตอบไหม", or "is this deployed yet?".
---

# Games Labs Implementation Status

## Use When

- A Games Labs follow-up message asks whether backend work is already implemented.
- A question from the Mobile team asks whether backend behavior is already supported, deployed, or safe to reply on.
- The user wants to know whether to reply now, patch code first, or verify deployment first.
- QA, Mobile, PM, or Dev report that the app still shows old behavior and the likely branch is code-versus-deploy.
- The user asks for a short English reply backed by current source, tests, and environment evidence.
- The question is Games Labs-specific and tied to mobile/backend contract behavior.

## Do Not Use When

- The task is broad API design or compatibility review without a follow-up status question; use `skills/games-labs-api-review/SKILL.md`.
- The task is ordinary debugging where the main goal is to fix the bug, not draft a reply; use `skills/debugging/SKILL.md`.
- The project is not Games Labs-specific; use the generic review or release skills instead.
- The task is release approval, incident response, or rollback coordination; use `skills/release-checklist/SKILL.md` or `skills/incident-response/SKILL.md`.

## Goal

Produce a reply-first, evidence-backed answer that clearly separates what is implemented in code, what is verified by tests, and what is actually confirmed in the target environment.

## Required Inputs

- The follow-up message or the operator's short question.
- The relevant endpoint, service path, UI data source, or prior answer being followed up.
- Current repository files that can prove or disprove the behavior.
- Focused test, CI, commit, or deployment evidence when available.
- The target environment if the ask is specifically about QA, staging, or production behavior.

## Process

1. Restate the concrete ask as one of: implemented in code, verified by tests, deployed in environment, or draft the reply.
2. Find the owning source of truth first: endpoint, handler, service, repository, UI field, or deploy lane. Use `skills/search-first/SKILL.md` and `playbooks/games-labs/mobile-contract-handoff.md` when needed.
3. Read the current source files before making any status claim. Do not answer from memory or old handoff text alone.
4. Check the smallest relevant verification evidence: focused test, CI result, or commit history that proves when the behavior changed.
5. If the ask mentions QA, staging, production, or "still seeing the old behavior", inspect deploy/runtime evidence too. Use `playbooks/games-labs/ecs-deploy.md` when the question is really environment state.
6. Classify the outcome into exactly one state:
   - `reply-now` when code already supports the behavior and the reply can be sent immediately.
   - `fix-first` when source shows the behavior is missing or wrong, so replying "already implemented" would be misleading.
   - `check-deploy` when code and tests support the behavior but the target environment is not yet confirmed.
   - `not-enough-evidence` when the available proof is missing or conflicting.
7. Draft the reply first. Keep it short and sendable. If deploy is unverified, explicitly separate "implemented in code" from "running in QA/staging".
8. Append a short evidence note for the operator with the specific file, test, commit, or deploy facts that support the reply.

## Output Format

- Reply draft
- Decision: `reply-now`, `fix-first`, `check-deploy`, or `not-enough-evidence`
- Evidence note
- Next action only if one is required before the reply is trustworthy

## Anti-patterns

- Replying "already implemented" from memory without reading current source.
- Treating code merged on a branch as proof that QA or staging is already running it.
- Giving a long internal analysis block before the sendable reply.
- Mixing implementation status with broad API redesign or unrelated debugging.
- Hiding uncertainty when the real answer is "code looks ready, but deploy is unverified".
