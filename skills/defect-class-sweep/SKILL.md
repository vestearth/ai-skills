---
name: defect-class-sweep
description: Use after finding a defect that could have siblings — an authorization gap, a trusted client field, an unverified callback, a missing config export — to scope the hunt by capability across services rather than by file or repository proximity.
---

# Defect Class Sweep

One defect is a bug. The same defect twice is a class, and a class is scoped by
capability, not by where the file happens to live.

## Use When

- A fix is complete and the same shape could plausibly exist elsewhere.
- The second instance of a defect appears — that is the signal a class exists.
- A prior sweep found instances but was scoped to one repository, package, or handler file.
- An audit is requested for a capability: money paths, authorization, callbacks, identity, config exposure.
- A defect keeps being found by accident, during unrelated work.
- Deciding whether a finding needs its own task or belongs to an existing one.

## Do Not Use When

- Investigating a single failure with no reason to expect siblings; use `debugging`.
- Tracing what one change affects; use `change-impact-analysis` (that reasons outward from a change, this reasons inward from a shape).
- Reviewing a specific diff; use `code-review`.
- Orienting in unfamiliar code with no defect in hand; use `search-first`.

## Required Rule

Apply `rules/evidence-required/RULE.md` and `rules/verify-before-final/RULE.md`.

## Goal

Find every instance of a defect class before the next one is found by accident,
and rank each by who can reach it today.

## Required Inputs

- The confirmed defect, stated as a *shape* rather than a location.
- The capability it sits on (what value or authority it moves).
- Prior findings on the same class, treated as unverified.
- Source access to every service that exercises that capability.

## Process

1. STATE THE SHAPE — write the class as one question that can be asked anywhere,
   independent of file, package, or service. "Does this path trust a field the
   client controls?" travels; "does `store.go` validate `user_id`?" does not.
2. SCOPE BY CAPABILITY — list every service that can exercise the capability, then
   every path within them. Repository boundaries are irrelevant to the hunt; a
   sweep scoped to one repo will miss the sibling next door.
3. INCLUDE THE UNGLAMOROUS SURFACES — admin endpoints, internal muxes, provider
   callbacks, background consumers, and services nobody has touched recently. The
   least-visited service is the most likely to hold the oldest instance.
4. ESTABLISH REACHABILITY PER PATH — transport, whether a gateway actually routes
   it, where identity comes from, and what authorization applies. A route
   registered on a service mux is not necessarily reachable; a middleware present
   in the chain does not necessarily gate the path it sits on.
5. RE-VERIFY PRIOR FINDINGS IN BOTH DIRECTIONS — some are already fixed by
   unrelated work, some were never true, some describe a stale line number. Read
   current source; a findings list ages faster than the code it describes.
6. CONFIRM BY EXECUTION BEFORE RANKING ANYTHING CRITICAL — reading finds
   candidates, executing finds truth. Stop at proof; do not move value.
7. RANK BY WHO CAN REACH IT TODAY — anonymous, any authenticated user, staff only,
   or cluster-internal. This ordering drives sequencing better than severity labels.
8. KEEP THE SWEEP AUDIT-ONLY — each confirmed finding becomes its own task with its
   own regression test. Fixes for one class routinely need different decisions.

## Output Format

- The class, stated as one portable question
- Inventory: every path examined, with transport, reachability evidence, identity
  source, authorization, and verdict
- Findings ranked by who can exploit them today
- Prior findings re-verified, with any that changed in either direction
- What could not be determined, and what access would settle it
- One task per confirmed finding — never one change for the whole sweep

## Anti-patterns

- Scoping the sweep to the repository where the defect was found.
- Reading a neighbouring file and calling the area covered.
- Trusting a prior findings list without re-reading current source.
- Ranking a finding critical from source alone when it could have been executed.
- Bundling every finding into one change, which buries the decisions each needs.
- Treating "no gateway route" as proof a path is unreachable.
- Declaring the class closed while the least-visited service remains unexamined.
