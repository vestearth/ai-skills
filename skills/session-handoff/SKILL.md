---
name: session-handoff
description: Use when compacting current work into a handoff for another agent, session, reviewer, or future continuation — including when a long session is approaching context compaction and critical working state must be snapshotted before and restored after without replaying the conversation.
---

# Session Handoff

Hand off enough state that the next reader — another agent, or your own future self after a compaction — resumes without replaying the conversation.

## Use When

- A long session needs a compact continuation note for a fresh agent or future turn.
- Work is moving between agents, reviewers, or execution surfaces.
- The user asks for a handoff, continuation brief, session summary, or next-agent context.
- Important context exists in chat but should be referenced without duplicating durable artifacts.
- A long session is near its context limit or compaction is about to run, and in-conversation state would otherwise be lost.
- Compaction just happened and working state must be restored before continuing.
- Work is mid-task at a point where losing in-conversation state would force replaying earlier steps.

## Do Not Use When

- The work needs durable project knowledge capture; use `knowledge-capture` or `knowledge-promote`.
- The work is tracked by `ai-dev-office` and the task artifact should be updated instead.
- The user only needs the final answer for the current task.
- The handoff would include secrets, private tokens, or unsupported claims.
- The session is short enough that compaction poses no real loss.

## Goal

Produce a compact, source-aware handoff — to another agent or to your post-compaction future self — that lets work continue from a documented next step without replaying the whole conversation or duplicating existing artifacts.

## Required Inputs

- Current objective, latest user request, and current status.
- Files actively being edited and why each matters.
- Files, commands, diffs, issues, PRs, task artifacts, or notes that already hold durable context.
- Decisions made this session that are not yet written anywhere durable.
- Open questions, blockers, failed checks, unverified assumptions, and verification evidence.
- Any scope boundaries or user preferences that the next reader must preserve.

## Process

1. Decide the target: temporary handoff, reviewer brief, future continuation, durable capture candidate, or pre-compaction snapshot for your own future self.
2. Reference existing artifacts by path or URL instead of copying their contents.
3. Summarize only what the next reader needs: objective, status, decisions, changed files, evidence, and next actions.
4. Separate verified facts from assumptions, TODOs, and blocked items.
5. Redact secrets, credentials, PII, internal tokens, and sensitive payloads.
6. If the content is durable project knowledge, recommend `knowledge-capture` instead of hiding it in a handoff or leaving it only in a snapshot that expires with the session.
7. End with a resume command: one paste-ready instruction or command the next reader can run immediately to continue.
8. Keep the handoff short enough to paste into a new session.

Across a compaction boundary (handoff to future self):

9. Prefer compacting at a task boundary: finish or checkpoint the current step before the snapshot.
10. Write the snapshot to a scratch file or the open task artifact — one-line objective, the few active files with why each matters, session decisions not yet durable, blockers, and the single immediate next step. Keep it small enough to re-read cheaply — a prioritized handful of files, not everything touched.
11. After compaction, re-read the snapshot and the primary active file, then resume from the documented next step instead of trusting memory of pre-compaction context.
12. Reduce future compaction pressure: delegate broad searches to subagents and use ranged reads on large files.

## Output Format

- Objective
- Current status
- Decisions and assumptions
- Relevant artifacts
- Verification and evidence
- Next actions
- Risks or blockers
- Resume command (paste-ready first action)

Compaction snapshot (handoff to future self) — the minimum working state that must survive:

- Objective (one line)
- Active files and why each matters
- Session decisions not yet durable
- Blockers and unverified assumptions
- Immediate next step (resume point)

## Anti-patterns

- Duplicating PRDs, plans, ADRs, task files, diffs, or commits instead of linking them.
- Mixing temporary continuation notes with durable knowledge-base capture, or leaving durable decisions only in a snapshot that expires with the session.
- Omitting failed checks or unresolved questions.
- Including secrets or raw sensitive payloads.
- Writing a polished narrative when the next reader needs operational context.
- Dumping conversation history or full file contents into a snapshot.
- Listing every touched file instead of the few that matter for resuming.
- Trusting memory of pre-compaction context instead of the written snapshot.
- Compacting mid-edit when finishing the step first was cheap.
