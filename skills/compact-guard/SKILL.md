---
name: compact-guard
description: Use when a long session is approaching context compaction and critical working state must be snapshotted before and restored after, without replaying the conversation.
---

# Compact Guard

## Use When

- A long session is near its context limit or compaction is about to run.
- Compaction just happened and working state must be restored before continuing.
- Work is mid-task at a point where losing in-conversation state would force replaying earlier steps.

## Do Not Use When

- The work is moving to another agent, session, or reviewer; use `session-handoff`.
- The content is durable project knowledge; use `knowledge-capture`.
- The session is short enough that compaction poses no real loss.

## Goal

Make the minimum working state survive a compaction cycle so the session resumes from its documented next step instead of re-deriving context.

## Required Inputs

- Current objective and immediate next step.
- Files actively being edited and why each matters.
- Decisions made this session that are not yet written anywhere durable.
- Open blockers and unverified assumptions.

## Process

1. Prefer compacting at a task boundary: finish or checkpoint the current step before the snapshot.
2. Write a snapshot note to a scratch file or the open task artifact containing: one-line objective, the few active files with why each matters, session decisions not yet durable, blockers, and the single immediate next step.
3. Keep the snapshot small enough to re-read cheaply — a prioritized handful of files, not everything touched.
4. If any snapshot item is durable project knowledge, move it to `knowledge-capture` or the task artifact instead of leaving it only in the snapshot.
5. After compaction, re-read the snapshot and the primary active file, then resume from the documented next step.
6. Reduce future compaction pressure: delegate broad searches to subagents and use ranged reads on large files.

## Output Format

- Objective (one line)
- Active files and why each matters
- Session decisions not yet durable
- Blockers and unverified assumptions
- Immediate next step (resume point)

## Anti-patterns

- Dumping conversation history or full file contents into the snapshot.
- Leaving durable decisions only in a snapshot that expires with the session.
- Listing every touched file instead of the few that matter for resuming.
- Trusting memory of pre-compaction context instead of the written snapshot.
- Compacting mid-edit when finishing the step first was cheap.
