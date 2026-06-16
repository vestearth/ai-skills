---
name: knowledge-source-review
description: Use when reviewing knowledge-base notes for sources, freshness, publication safety, broken links, or drift from current repository evidence.
---

# Knowledge Source Review

Check that durable notes are sourced, fresh enough, safe to share, and not drifting from current evidence.

## Use When

- Reviewing a knowledge-base note before promotion, publication, handoff, or reuse.
- A note makes durable claims about code, architecture, decisions, flows, status, or behavior.
- A note may be stale, unsourced, publication-sensitive, or contradicted by current repository evidence.
- Running weekly review or cleaning `Review Queue.md`.

## Do Not Use When

- The note is a raw private capture item not being promoted or shared.
- The task is only fixing a typo with no claim changes.
- Current source verification is impossible and the note cannot be safely qualified.

## Goal

Keep `knowledge-base/` useful by tying claims to sources, marking uncertainty, and preventing stale or unsafe notes from spreading.

## Required Inputs

- Note path and text.
- Source paths, current repository files, tests, CI, logs, production signals, or other artifacts supporting claims.
- `Knowledge Base/Source Link Convention.md`, `PUBLICATION_POLICY.md`, `Review Queue.md`, and vault validation output when available.

## Process

1. Identify durable claims in the note.
2. Check each meaningful claim has `Source:` or `Sources:` when it needs one.
3. Verify freshness for claims marked with `verified YYYY-MM-DD` or claims likely to drift.
4. Compare important claims against current repository files, tests, CI, logs, or production signals when available.
5. Apply publication policy before sharing outside the local workspace.
6. Move uncertain source, freshness, or publication issues to `Review Queue.md`.
7. Run vault link and stale-date checks after edits.

## Output Format

- Note reviewed
- Source coverage
- Freshness status
- Drift risks
- Publication safety
- Required fixes
- Verification

## Anti-patterns

- Treating a source link as proof that the claim is still current.
- Publishing local or sensitive notes without policy review.
- Leaving stale `verified` claims unqualified.
- Fixing links while ignoring unsupported claims.
