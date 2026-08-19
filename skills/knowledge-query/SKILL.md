---
name: knowledge-query
description: Use when a task may depend on durable project memory, prior decisions, architecture notes, lessons, flow maps, or knowledge-base context.
---

# Knowledge Query

Search durable knowledge before answering or changing work that may depend on prior project understanding.

## Use When

- The task asks about project memory, decisions, architecture, lessons, concepts, flows, or previous rationale.
- Starting work where `knowledge-base/` may contain relevant project notes.
- Answering "why", "what did we decide", "how does this flow work", or "what have we learned" questions.
- Preparing implementation, review, planning, or handoff that may depend on durable notes.

## Do Not Use When

- The user asks for a direct code inspection and no durable memory is relevant.
- Current repository files, tests, CI, logs, or production evidence are required and the vault would only be secondary context.
- The task is a quick wording edit with no project-memory dependency.

## Goal

Use `knowledge-base/` as navigation and memory while keeping current source-of-truth evidence higher priority.

## Required Inputs

- User question or task.
- Available `knowledge-base/AGENTS.md`, `Knowledge Base/Home.md`, MOCs, project notes, flow maps, ADRs, lessons, concepts, or review queue entries.
- Current repo files, tests, CI, logs, or production signals when the answer makes system claims.

## Process

1. Identify whether the task depends on durable memory.
2. Search existing notes before answering or creating new notes.
3. Prefer `Knowledge Base/Home.md`, `Knowledge Base/00 MOCs/`, relevant `10 Projects/`, and `20 Flows/` entries as navigation.
4. Read only the notes needed for the question.
5. Treat vault notes as context, not stronger evidence than current source files, tests, CI, logs, or production signals.
6. Classify every note used by its `freshness` field (`Knowledge Base/Provenance And Freshness.md`) before citing it. No block means `unknown`.
7. Group results by freshness bucket — do not flatten them (see Freshness In Results below).
8. Summarize relevant knowledge and cite the note paths used.
9. State when the vault is silent or when current source verification is still needed.

## Freshness In Results

The vault's canonical freshness vocabulary is `current`, `unknown`,
`maybe_stale`, `stale`, `invalid`, `historical`
(`Knowledge Base/Provenance And Freshness.md`). Query results must surface
that status prominently, not bury it in prose, and must never present
`stale` or `historical` material as current source-of-truth without saying
so.

Group cited notes into the buckets a reader should see, mirroring
`current.md` at query time. Skip a bucket header when nothing lands in it —
do not print an empty section:

```text
CURRENT
- <note>: <claim>, verified <date>

REVALIDATE / STALE
- <note>: <claim> — <maybe_stale: source moved, unchecked | stale: confirmed changed since <date>>

HISTORICAL
- <note>: <claim> — frozen design/incident context, not a claim about current behavior
```

Bucket mapping (mirrors `knowledge-base/scripts/check_provenance.py`'s
`query_bucket`):

| `freshness` | Bucket |
|---|---|
| `current` | CURRENT |
| `maybe_stale`, `stale`, `unknown` | REVALIDATE / STALE |
| `historical` | HISTORICAL |
| `invalid` | excluded — do not cite as an answer; note separately that a conflicting claim exists and was rejected |

`unknown` (no provenance block, which is most of the vault) is not an error
and not automatically suspect — it just cannot be shown as `current`. State
it as unverified rather than omitting the qualification.

When two or more notes describe different generations of the same claim, do
**not** synthesize them into one merged answer presented as current truth.
Show each generation in its own bucket, in the reader's own words if useful,
but never collapse "used to work this way" and "works this way now" into a
single unqualified statement.

## Output Format

- Knowledge checked
- Relevant notes, grouped CURRENT / REVALIDATE-STALE / HISTORICAL per the mapping above
- What the vault says (per bucket — never merged across buckets)
- Source-of-truth checks still needed
- Answer or next action

## Anti-patterns

- Answering from memory when the vault likely has a relevant note.
- Treating a note as proof that current code still behaves that way.
- Reading the whole vault instead of targeted notes.
- Creating a new note before searching existing notes.
- Presenting a `stale` or `historical` note as current without qualification.
- Merging conflicting generations of a claim into one synthesized "current" answer.
- Treating `unknown` as equivalent to `current` because most notes lack a provenance block.
