---
name: search-first
description: Use when starting implementation, debugging, refactoring, review, repository discovery, or source-location prompts such as "route นี้อยู่ไฟล์ไหน".
---

# Search First

Discover the existing system before changing it.

## Use When

- Starting work in an unfamiliar repository, service, module, package, or generated-code area.
- Implementing behavior that may already exist.
- Debugging behavior without knowing the owning code path.
- Reviewing or refactoring code with unclear callers or dependencies.
- Investigating API routes, protobuf, events, database tables, configs, tests, fixtures, CI, or deployment references.
- Working with shared libraries, provider integrations, or cross-service contracts.
- The user uses short Thai source-location prompts such as "source อยู่ไหน", "ใครเป็น owner", or "route นี้อยู่ไฟล์ไหน" and the owning code path is not already known.

## Do Not Use When

- The task is purely wording or documentation with no system behavior.
- The exact file and symbol are provided and no broader impact is possible.
- The user explicitly asks for a direct explanation without codebase discovery.
- The problem is managing a limited context window — what to load versus deliberately skip — rather than locating a specific thing; prefer `context-discipline`. (search-first = find the thing; context-discipline = budget the window.)

## Required Rule

Apply `rules/context-discipline/RULE.md`, `rules/evidence-required/RULE.md`, and `rules/search-before-create/RULE.md` when creating artifacts.

## Goal

Find existing ownership, patterns, and evidence before implementing, debugging, reviewing, or recommending changes.

## Required Inputs

- User request, symptom, proposed change, or review target.
- Search target such as symbol, route, proto, event, table, config key, package, test, workflow, or fixture.
- Available repository search, symbol search, code graph, source files, tests, docs, or generated artifacts.

## Process

1. Define the search target.
2. Search exact names first.
3. Search naming variants and related domain terms.
4. Inspect the closest source-of-truth files.
5. Summarize what exists, where it lives, what pattern it follows, and what remains unknown.
6. Continue with implementation, debugging, review, or recommendation only after discovery.

When SocratiCode is available, use `codebase_status` before relying on index freshness, then `codebase_search`, `codebase_symbol`, or `codebase_graph_query`. Confirm important findings against current repository files.

## Output Format

- Target
- Searches performed
- Relevant files
- What exists
- Gaps
- Next action

## Anti-patterns

- Creating or changing code before checking whether the pattern already exists.
- Reading broad folders without a search target.
- Treating indexed search as final proof.
- Skipping variants and then claiming nothing exists.
