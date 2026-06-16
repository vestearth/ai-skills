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
6. Summarize relevant knowledge and cite the note paths used.
7. State when the vault is silent or when current source verification is still needed.

## Output Format

- Knowledge checked
- Relevant notes
- What the vault says
- Source-of-truth checks still needed
- Answer or next action

## Anti-patterns

- Answering from memory when the vault likely has a relevant note.
- Treating a note as proof that current code still behaves that way.
- Reading the whole vault instead of targeted notes.
- Creating a new note before searching existing notes.
