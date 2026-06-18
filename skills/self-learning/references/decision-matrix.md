# Decision Matrix

Run each gathered signal through this matrix and pick exactly one outcome.

| # | Outcome | Choose when | Delegate to |
|---|---|---|---|
| 1 | Edit existing skill | a skill already covers this area but missed/failed this case | `superpowers:writing-skills` (add case + close loophole) |
| 2 | Create new skill | pattern recurs >=2x, no skill covers it, broad enough to reuse | `superpowers:writing-skills` (baseline -> test -> write) |
| 3 | Record in knowledge-base | project-specific knowledge/decision, not yet a reusable technique | `knowledge-capture` -> (if recurs) `knowledge-promote` |
| 4 | Edit a rule | a cross-cutting mandate across skills (e.g. "never X") | `rules/<name>/RULE.md` |
| 5 | Do nothing | one-off, no reuse pressure, or code/tests/docs already answer it | record the no-op rationale in the proposal |

## Reuse-pressure gate (before #1 / #2)

A signal may touch a skill only when it recurs >=2x OR has cross-repo/task value
(borrowed from `Knowledge Base/Promotion Rule.md`). Otherwise drop to #3 or #5. This
prevents skill bloat from one-off events.

## Anti-overlap with knowledge-promote

`knowledge-promote` decides *whether* a note should become a skill but hands off only
conceptually. This skill picks up at #3 and actually authors via `writing-skills`,
validates, and proposes a diff. #3 is the join point, not a duplicate.

## Dependency fallback (no superpowers)

If `superpowers:writing-skills` is unavailable:

- use `ai-skills/CONTRIBUTING.md`
- copy structure from nearest existing skill
- keep patch minimal
- run `scripts/validate-skills.sh`
- mark as fallback-authored proposal

A fallback-authored proposal is still subject to the propose-only gate and the
reuse-pressure gate; it is only flagged so the reviewer knows TDD pressure-testing was
not applied this round.
