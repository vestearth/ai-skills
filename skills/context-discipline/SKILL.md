---
name: context-discipline
description: Use when repository context is large, stale, tool-derived, or likely to overload the session during implementation, debugging, review, or handoff.
---

# Context Discipline

Gather enough context to act accurately without flooding the session.

## Use When

- Starting work in a large repository or multi-service workspace.
- Using SocratiCode, search indexes, MCP tools, code graph, or generated artifacts as context sources.
- Debugging or reviewing with limited context window.
- The task spans services, APIs, generated code, configs, deployment files, tests, or docs.
- Previous context may be stale, incomplete, or too broad.
- An agent is tempted to read many files before forming a search strategy.

## Do Not Use When

- The user provides all relevant text directly.
- The task is a small edit in one known file.
- The task is purely wording, translation, or explanation.

## Required Rule

Apply `rules/context-discipline/RULE.md` and `rules/evidence-required/RULE.md`.

## Goal

Collect targeted source-of-truth evidence, summarize it, and stop before context gathering becomes noise.

## Required Inputs

- Information need such as route ownership, caller chain, API contract, proto mapping, database behavior, deployment config, or failing test/log source.
- Available discovery tools: repository search, symbol search, graph query, route/proto/schema lookup, test search, or config search.
- Candidate source files or generated artifacts when relevant.

## Process

1. Define the information needed to answer or edit safely.
2. Choose lightweight discovery tools before opening many files.
3. Read the smallest set of files needed to confirm the claim.
4. Track context budget and skip unrelated packages, duplicate docs, stale summaries, and generated files unless needed.
5. Summarize what was found, what is source of truth, what remains unknown, and which files matter.
6. Stop when enough evidence exists to proceed safely.

## Output Format

- Information needed
- Discovery used
- Files inspected
- Source of truth
- Useful context
- Ignored or avoided context
- Remaining gaps

## Anti-patterns

- Loading whole repository trees without a target.
- Treating old summaries or indexed context as final proof.
- Continuing discovery after the decision has enough evidence.
- Editing before summarizing the relevant context.
