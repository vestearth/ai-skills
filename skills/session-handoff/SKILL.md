---
name: session-handoff
description: Use when compacting current work into a handoff for another agent, session, reviewer, or future continuation.
---

# Session Handoff

## Use When

- A long session needs a compact continuation note for a fresh agent or future turn.
- Work is moving between agents, reviewers, or execution surfaces.
- The user asks for a handoff, continuation brief, session summary, or next-agent context.
- Important context exists in chat but should be referenced without duplicating durable artifacts.

## Do Not Use When

- The work needs durable project knowledge capture; use `knowledge-capture` or `knowledge-promote`.
- The work is tracked by `ai-dev-office` and the task artifact should be updated instead.
- The user only needs the final answer for the current task.
- The handoff would include secrets, private tokens, or unsupported claims.

## Goal

Produce a compact, source-aware handoff that lets the next agent continue without replaying the whole conversation or duplicating existing artifacts.

## Required Inputs

- Current objective, latest user request, and current status.
- Files, commands, diffs, issues, PRs, task artifacts, or notes that already hold durable context.
- Open questions, blockers, failed checks, and verification evidence.
- Any scope boundaries or user preferences that the next agent must preserve.

## Process

1. Decide the target: temporary handoff, reviewer brief, future continuation, or durable capture candidate.
2. Reference existing artifacts by path or URL instead of copying their contents.
3. Summarize only what the next agent needs: objective, status, decisions, changed files, evidence, and next actions.
4. Separate verified facts from assumptions, TODOs, and blocked items.
5. Redact secrets, credentials, PII, internal tokens, and sensitive payloads.
6. If the content is durable project knowledge, recommend `knowledge-capture` instead of hiding it in a handoff.
7. Keep the handoff short enough to paste into a new session.

## Output Format

- Objective
- Current status
- Decisions and assumptions
- Relevant artifacts
- Verification and evidence
- Next actions
- Risks or blockers

## Anti-patterns

- Duplicating PRDs, plans, ADRs, task files, diffs, or commits instead of linking them.
- Mixing temporary continuation notes with durable knowledge-base capture.
- Omitting failed checks or unresolved questions.
- Including secrets or raw sensitive payloads.
- Writing a polished narrative when the next agent needs operational context.
