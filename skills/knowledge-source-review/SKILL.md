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
3. Read the note's `freshness` frontmatter state per `Knowledge Base/Provenance And Freshness.md` (`current`, `unknown`, `maybe_stale`, `stale`, `invalid`, `historical`) when present, alongside any in-body `verified YYYY-MM-DD` mentions the vault's stale-date check also ages.
4. Compare important claims against current repository files, tests, CI, logs, or production signals when available. A source the note cites having moved is grounds to mark `maybe_stale` — a suspicion, not a verdict; only an actual re-check that contradicts the claim earns `stale`, and only evidence the claim was wrong when written earns `invalid`.
5. Apply publication policy before sharing outside the local workspace.
6. Move uncertain source, freshness, or publication issues to `Review Queue.md`'s "Needs Freshness Determination" category when the state itself can't be confidently assigned, or the state-specific categories when it already declares `maybe_stale`/`stale`/`invalid`.
7. Never move a note's `freshness` to `current` on this pass unless this review itself constitutes the actual re-check (per `Provenance And Freshness.md`, only a recorded check earns `current`) — record `verified_at` as today's check if so.
8. Run vault link and stale-date checks after edits.

## Output Format

- Note reviewed
- Source coverage
- Freshness status (declared state, evidence for/against it, and whether this review changes it)
- Drift risks
- Publication safety
- Required fixes
- Verification

## Anti-patterns

- Treating a source link as proof that the claim is still current.
- Publishing local or sensitive notes without policy review.
- Leaving stale `verified` claims unqualified.
- Fixing links while ignoring unsupported claims.
- Jumping straight to `stale`/`invalid` because a cited source changed, instead of `maybe_stale` pending an actual re-check.
- Setting `freshness: current` without this review being the check that `verified_at` records.
