---
name: self-learning
description: Use when turning feedback (user corrections, knowledge-base lessons, or an on-demand request) into a proposed skill, rule, or knowledge change without auto-applying it.
---

# Self-Learning

Turn feedback into durable improvements through a propose-only loop: gather signals,
triage each to one destination, route the work to the right skill, and emit a single
proposal that waits for approval.

## Use When

- The user asks to "learn from" a session, a correction, or a transcript span.
- A `knowledge-base` Lesson/ADR shows reuse pressure that may belong in a skill or rule.
- The user repeatedly corrects the same kind of mistake and asks to prevent it.
- After work reveals a pattern that might improve an existing skill or warrant a new one.

## Do Not Use When

- The user wants a one-off code change, review, or debugging — use the matching skill.
- There is no feedback signal yet (nothing happened to learn from).
- The user explicitly wants to author a skill directly — use `superpowers:writing-skills`.
- Routine project knowledge with no skill/rule implication — use `knowledge-capture` alone.

## Goal

Convert feedback into the smallest correct durable change, proposed (never auto-applied)
with a diff, rationale, and evidence, so the reviewer can approve in one step. The value
is a consistent, structured proposal — not ad hoc reasoning.

## Required Inputs

- The feedback signals: user corrections, knowledge-base notes, or the on-demand
  request, each with evidence and an occurrence count.
- The current skill set under `skills/` and rules under `rules/` (to find overlaps).
- `Knowledge Base/Promotion Rule.md` (reuse-pressure gate) when available.
- `scripts/validate-skills.sh` for validating any skill change.

## Process

1. GATHER — collect each feedback signal; record what happened, its evidence, and how
   many times it has occurred.
2. TRIAGE — run each signal through the Decision Matrix
   (`references/decision-matrix.md`) and pick one of five outcomes. A signal may touch a
   skill only after passing the reuse-pressure gate (recurs >=2x or cross-repo/task
   value); otherwise route it to knowledge-base or no-op.
3. ROUTE — delegate the actual work, but do not commit it:
   - create/edit a skill -> `superpowers:writing-skills` (TDD); if unavailable, use the
     fallback in `references/decision-matrix.md`.
   - record knowledge -> `knowledge-capture` / `knowledge-promote`.
   - edit a cross-cutting rule -> the relevant `rules/<name>/RULE.md`.
4. PROPOSE — assemble one proposal (see Output Format), validate skill changes with
   `scripts/validate-skills.sh`, attach the result, then STOP and await approval.

## Output Format

- Signals gathered: count, with source and occurrence count each
- Triage decisions: per signal -> outcome (1-5) + rationale
- Proposed changes: per-file diff (skill / rule / knowledge-base)
- Evidence: transcript / notes / validator result
- Gate: "awaiting approval — not committed"

## Anti-patterns

- Applying or committing a change instead of proposing it.
- Creating a new skill from a one-off signal that has no reuse pressure.
- Duplicating `writing-skills` or `knowledge-*` content instead of delegating to them.
- Proposing a skill change without running `scripts/validate-skills.sh`.
- Adding unrequested scope to a proposal beyond the triaged signal.
- Treating `.claude/skills` (a mirror) as the source of truth instead of `skills/`.
