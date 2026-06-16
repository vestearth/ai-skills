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
7. Leave uncertain source, freshness, or human-judgment items in `Review Queue.md`.
8. Run vault checks after note moves or link changes.

## Output Format

- Candidate
- Reuse pressure
- Target location
- Changes made or proposed
- Sources and related links
- Verification

## Anti-patterns

- Promoting notes because they look clean.
- Creating ADRs for non-decisions.
- Promoting raw AI output without human/source review.
- Turning project-specific facts into reusable skills too early.
- Moving unsourced or stale claims into durable sections.
