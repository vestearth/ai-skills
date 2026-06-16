---
name: knowledge-capture
description: Use after work reveals durable decisions, lessons, project understanding, flows, or reusable knowledge that should be captured in knowledge-base.
---

# Knowledge Capture

Extract durable knowledge from completed work into a note or patch for `knowledge-base/`.

## Use When

- A task produces a decision, lesson, project understanding, flow map, or reusable pattern worth remembering.
- A repeated question or investigation should become easier next time.
- A handoff, incident, review, implementation, or debugging session creates knowledge beyond the immediate code change.
- The user asks to capture, remember, document, or add something to the knowledge base.

## Do Not Use When

- The result is temporary, speculative, or not useful after the current task.
- The information belongs only in code comments, tests, README, release notes, or issue tracker.
- Sources are unavailable and the note would become an unsupported durable claim.

## Goal

Capture only useful durable knowledge with links, sources, and the right write target.

## Required Inputs

- Task outcome or summary.
- Source files, commands, logs, decisions, review comments, or artifacts that support the note.
- `knowledge-base/AGENTS.md`, `Knowledge Base/How To Use This Vault.md`, `Knowledge Base/Source Link Convention.md`, and relevant templates when available.

## Process

1. Decide whether the knowledge is durable enough to capture.
2. Search existing notes first.
3. Prefer updating an existing note when the concept already exists.
4. Choose the write target: `Inbox.md` for raw capture, `10 Projects/` for project knowledge, `20 Flows/` for flow maps, `30 ADR/` for decisions, `40 Lessons/` for reusable lessons, or `50 Concepts/` for concepts.
5. Add `Related` links to nearby notes.
6. Add `Source:` or `Sources:` for durable claims.
7. Keep uncertain freshness, source, or publication issues in `Review Queue.md`.
8. Run vault link checks when notes are edited.

## Output Format

- Capture decision: capture, update existing note, or skip
- Target note
- Sources
- Related links
- Note text or patch summary
- Verification

## Anti-patterns

- Capturing everything just because work happened.
- Creating a new note when an existing note should be updated.
- Promoting raw capture directly into reusable knowledge without reuse pressure.
- Recording claims without sources.
