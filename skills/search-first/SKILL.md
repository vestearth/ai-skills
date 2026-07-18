---
name: search-first
description: Use when starting implementation, debugging, refactoring, review, or repository discovery; for source-location prompts such as "route นี้อยู่ไฟล์ไหน"; when repository context is large, stale, or tool-derived and could overload the session; or when orienting in unfamiliar code and the deliverable is a one-screen module map of entry points, core modules, data flow, and coupling.
---

# Search First

Locate and understand the existing system — within a deliberate context budget — before changing it.

## Use When

- Starting work in an unfamiliar repository, service, module, package, or generated-code area.
- Implementing behavior that may already exist.
- Debugging behavior without knowing the owning code path.
- Reviewing or refactoring code with unclear callers or dependencies.
- Investigating API routes, protobuf, events, database tables, configs, tests, fixtures, CI, or deployment references.
- Working with shared libraries, provider integrations, or cross-service contracts.
- The user uses short Thai source-location prompts such as "source อยู่ไหน", "ใครเป็น owner", or "route นี้อยู่ไฟล์ไหน" and the owning code path is not already known.
- Repository context is large, stale, or tool-derived (SocratiCode, search indexes, MCP tools, code graph, generated artifacts) and could overload the session — budget what to load versus deliberately skip.
- Orienting in an unfamiliar area before real work, or onboarding another agent or reviewer: the user says "zoom out", "orient me", or "I don't know this area" and wants a one-screen module map.

## Do Not Use When

- The task is purely wording, translation, documentation, or explanation with no system behavior.
- The exact file and symbol are provided, the user supplies all relevant text, and no broader impact is possible.
- The user explicitly asks for a direct explanation without codebase discovery.
- The task needs a quality or risk judgment; use the domain review skill after orienting.
- The user wants refactoring or architecture proposals; a map describes, it does not prescribe.

## Required Rule

Apply `rules/context-discipline/RULE.md` (the authoritative principle for budgeting repository context), `rules/evidence-required/RULE.md`, and `rules/search-before-create/RULE.md` when creating artifacts.

## Goal

Find existing ownership, patterns, and source-of-truth evidence before implementing, debugging, reviewing, or recommending changes — collecting targeted context, summarizing it, and stopping before gathering becomes noise.

## Required Inputs

- User request, symptom, proposed change, or review target.
- Search target or information need: symbol, route, proto, event, table, config key, package, test, workflow, fixture, caller chain, API contract, proto mapping, database behavior, deployment config, or failing test/log source.
- Available discovery: repository search, symbol search, code graph, route/proto/schema lookup, source files, tests, docs, or generated artifacts.
- For a module map: the area boundary (service, package, directory, or feature) and the caller's purpose, so the map highlights the relevant happy path.

## Process

1. Define the search target or information need before opening many files.
2. Choose lightweight discovery — search exact names first, then naming variants and related domain terms — before reading broadly.
3. Read only the smallest set of source-of-truth files that can confirm or refute the claim.
4. Track the context budget: skip unrelated packages, duplicate docs, stale summaries, and generated files unless they are the source of truth for the claim.
5. Summarize what exists, where it lives, what pattern it follows, which files are source of truth, and what remains unknown.
6. Stop when enough evidence exists; continue with implementation, debugging, review, or recommendation only after discovery.

When SocratiCode is available, use `codebase_status` before relying on index freshness, then `codebase_search`, `codebase_symbol`, or `codebase_graph_query`. Confirm important findings against current repository files; treat indexed context as a lead, not proof.

Module-map mode — when the deliverable is orientation, produce the map after discovery:

1. Fix the area boundary first; a map of "the whole repo" is a smell — narrow it.
2. Find entry points: exported handlers, routes, gRPC methods, consumers, cron jobs — each with its file path.
3. Pick the two to five core modules that do the real work, one role each.
4. Trace the dominant happy path and render it as a short ASCII flow (input → transform → output).
5. List external callers and dependencies that cross the area boundary.
6. Note hidden coupling: shared state, implicit contracts, generated code, or config another area owns.
7. Cut until it fits one screen — every claim carries a file path; drop anything inferred without evidence.

## Output Format

Default discovery output:

- Target or information need
- Searches performed / discovery used
- Relevant files inspected and which are source of truth
- What exists
- Useful context, and context deliberately ignored or avoided
- Gaps
- Next action

Module-map output (one screen):

- One-line summary of the area's purpose from the caller's perspective
- Entry points with file paths
- Core modules (2–5) with one-line roles
- Data flow: short ASCII happy path
- External callers and dependencies
- Hidden coupling and gotchas

## Anti-patterns

- Creating or changing code before checking whether the pattern already exists.
- Reading broad folders or whole repository trees without a search target.
- Treating indexed search or old summaries as final proof.
- Skipping variants and then claiming nothing exists.
- Continuing discovery after the decision already has enough evidence, or editing before summarizing the relevant context.
- For a map: exceeding one screen, claims without a file path or structure inferred from naming, slipping in refactor or architecture advice, exhaustively listing files, or re-mapping an area an existing map or knowledge-base note already covers.
