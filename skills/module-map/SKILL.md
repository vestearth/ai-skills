---
name: module-map
description: Use when orienting fast in an unfamiliar code area and the deliverable is a one-screen map of entry points, core modules, data flow, and coupling — not a tour or a review.
---

# Module Map

## Use When

- Entering an unfamiliar service, package, or code area and needing orientation before real work.
- The user says "zoom out", "orient me", or "I don't know this area".
- Onboarding another agent or reviewer to an area they have not touched.

## Do Not Use When

- The task needs a quality or risk judgment; use the domain review skill after orienting.
- The task is a targeted lookup of one symbol or file; search directly.
- The user wants refactoring or architecture proposals; a map describes, it does not prescribe.

## Goal

Deliver a one-screen, evidence-backed map of a code area that a reader can absorb in under a minute and use to start real work.

## Required Inputs

- The area boundary: service, package, directory, or feature to map.
- Read access to the code; searches for entry points and callers.
- The caller's purpose, so the map highlights the relevant happy path.

## Process

1. Fix the area boundary first; a map of "the whole repo" is a smell — narrow it.
2. Find entry points: exported handlers, routes, gRPC methods, consumers, cron jobs — each with its file path.
3. Pick the two to five core modules that do the real work, one role each.
4. Trace the dominant happy path and render it as a short ASCII flow (input → transform → output).
5. List external callers and dependencies that cross the area boundary.
6. Note hidden coupling: shared state, implicit contracts, generated code, or config another area owns.
7. Cut until it fits one screen — every claim carries a file path; drop anything inferred without evidence.

## Output Format

- One-line summary of the area's purpose from the caller's perspective
- Entry points with file paths
- Core modules (2–5) with one-line roles
- Data flow: short ASCII happy path
- External callers and dependencies
- Hidden coupling and gotchas

## Anti-patterns

- Exceeding one screen; a longer map is a tour, not a map.
- Claims without a file path, or structure inferred from naming alone.
- Slipping refactor or architecture advice into the map.
- Exhaustively listing files instead of choosing the core few.
- Re-mapping an area when an existing map or knowledge-base note already covers it.
