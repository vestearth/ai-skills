---
name: knowledge-promote
description: Use when notes in Inbox or project notes may need promotion into ADRs, reusable lessons, concepts, flow maps, or skills.
---

# Knowledge Promote

Promote useful notes only when reuse pressure proves they belong outside raw capture.

## Use When

- Reviewing `Inbox.md`, project notes, review queue items, or weekly review output.
- A pattern, decision, lesson, concept, or flow has appeared more than once.
- A project-specific note may need to become an ADR, lesson, concept, flow map, prompt, or reusable skill.
- The user asks whether something should be promoted.

## Do Not Use When

- The note is a one-off capture with no reuse pressure.
- The note is speculative, unsourced, or stale.
- The content should stay in code, tests, README, issue tracker, or release notes.

## Goal

Move knowledge to the smallest durable home that matches how it will be reused.

Promotion starts after capture gatekeeping. If the item does not pass `Knowledge Base/Promotion Rule.md`'s Capture Gate, skip it or leave it in source/review instead of promoting it.

## Required Inputs

- Candidate note or capture item.
- Evidence of reuse pressure: repeated questions, repeated investigations, operational need, or cross-project value.
- `Knowledge Base/Promotion Rule.md`, `Weekly Review.md`, `Review Queue.md`, and `Source Link Convention.md` when available.

## Process

1. Identify the candidate knowledge and current location.
2. Apply the Capture Gate from `Knowledge Base/Promotion Rule.md`.
3. Check whether it is sourced, fresh, and distinct from existing notes.
4. Confirm reuse pressure.
5. Choose the target: project note, `20 Flows/`, `30 ADR/`, `40 Lessons/`, `50 Concepts/`, prompt library, or `ai-skills/`.
6. Preserve or add `Source:` / `Sources:` and `Related` links.
7. Carry provenance/freshness forward from the source note; apply the Freshness At Promotion routing below.
8. Leave uncertain source, freshness, or human-judgment items in `Review Queue.md`.
9. Run vault checks after note moves or link changes.

## Freshness At Promotion

Follow `Knowledge Base/Promotion Rule.md`'s "Freshness At Promotion" section.
The short version:

- A promoted note that came from an actual recorded check carries that
  provenance forward — do not drop `freshness`/`verified_at`/`task_id`/
  `run_id`/`evidence_refs`/`repo_origin`/`repo_sha`/`confidence` in the move,
  and do not re-date `verified_at` to the promotion date.
- A promoted note with no such check stays `unknown` (block absent or
  `freshness` unset). Promotion is not itself a verification event — never
  set `freshness: current` just because the note is now durable.
- If the freshness case is weak or uncertain — you cannot say whether the
  claim still holds, or a cited source has moved since the note was written
  — route the note to `Review Queue.md`'s "Needs Freshness Determination"
  category instead of promoting it as `current` or dropping it. This is the
  required middle path: neither silently discard useful knowledge nor
  silently promote it as confidently current.
- A source note already marked `stale` or `invalid` is not a promotion
  candidate as-is. Promote the corrected/current understanding instead, and
  leave the stale note in place as history or route it for revalidation.

## Output Format

- Candidate
- Reuse pressure
- Target location
- Freshness carried forward, or routed to Review Queue and why
- Changes made or proposed
- Sources and related links
- Verification

## Anti-patterns

- Promoting notes because they look clean.
- Creating ADRs for non-decisions.
- Promoting raw AI output without human/source review.
- Turning project-specific facts into reusable skills too early.
- Moving unsourced or stale claims into durable sections.
- Dropping an existing provenance/freshness block during the move.
- Marking a promoted note `current` without an actual check behind it.
- Promoting a freshness-uncertain note as confidently current instead of routing it to Review Queue.
