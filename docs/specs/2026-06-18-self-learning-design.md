# Design — `self-learning` skill (closed-loop)

Date: 2026-06-18
Status: Approved (brainstorming) — pending implementation plan
Base: builds on `superpowers:writing-skills` (TDD) and the `knowledge-*` loop

## Purpose

A closed-loop skill that turns feedback into durable improvements:
**gather feedback → decide → write/edit skill (or route elsewhere)**, while never
applying changes without approval.

## Approach (chosen: A — thin orchestrator)

`self-learning` is a single meta-skill at `ai-skills/skills/self-learning/`. It owns
the loop's *control flow and decision criteria* and delegates the actual work to
existing skills. It does NOT duplicate the bodies of `writing-skills` or the
`knowledge-*` skills (per ai-skills convention: keep thin, no duplication).

| Owns | Delegates to |
|---|---|
| Decision matrix (5 outcomes) | write/edit a skill → `superpowers:writing-skills` (TDD) |
| Propose-only gate (no auto-apply) | route knowledge → `knowledge-capture` / `knowledge-promote` |
| Proposal output format (diff + rationale + evidence) | validate → `scripts/validate-skills.sh` |
| Reuse-pressure threshold before touching a skill | edit a cross-cutting rule → `ai-skills/rules/<name>/RULE.md` |

### Dependency fallback (no superpowers)

`superpowers:writing-skills` is the preferred authoring path but must not be a hard
dependency. If it is unavailable:

```
If superpowers:writing-skills is unavailable:
- use ai-skills/CONTRIBUTING.md
- copy structure from nearest existing skill
- keep patch minimal
- run scripts/validate-skills.sh
- mark as fallback-authored proposal
```

A fallback-authored proposal is still subject to the propose-only gate and the
reuse-pressure gate; it is simply flagged so the reviewer knows TDD pressure-testing
was not applied this round.

## Data flow (4 stages)

1. **GATHER** — collect feedback signals from three sources:
   - on-demand (user invokes / points at a transcript span)
   - knowledge-base (Lessons/ADR notes that carry reuse pressure, via `knowledge-promote`)
   - user correction (points in-session where the user fixed/objected/flagged wrong)
   Each signal records: what happened, evidence, how many times it occurred.
2. **TRIAGE** — run each signal through the Decision Matrix; a signal must pass the
   reuse-pressure gate before it may touch a skill (else it falls to vault or no-op).
3. **ROUTE** — delegate to the target skill (writing-skills / knowledge-* / rules).
   Real work happens here but is NOT committed.
4. **PROPOSE** — assemble one proposal: diff + rationale + evidence + validator result,
   then STOP and await approval (propose-only gate). The user applies/commits.

## Decision Matrix (heart of TRIAGE)

| # | Outcome | Choose when | Delegate to |
|---|---|---|---|
| 1 | Edit existing skill | a skill already covers this area but missed/failed this case | `writing-skills` (add case + close loophole) |
| 2 | Create new skill | pattern recurs ≥2×, no skill covers it, broad enough to reuse | `writing-skills` (baseline→test→write) |
| 3 | Record in knowledge-base | project-specific knowledge/decision, not yet a reusable technique | `knowledge-capture` → (if recurs) `knowledge-promote` |
| 4 | Edit a rule | a cross-cutting mandate across skills (e.g. "never X") | `ai-skills/rules/<name>/RULE.md` |
| 5 | Do nothing | one-off, no reuse pressure, or code/tests/docs already answer it | record the "no-op" rationale in the proposal |

**Reuse-pressure gate (before #1/#2):** borrowed from `Knowledge Base/Promotion Rule.md`
— require recurrence ≥2× or cross-repo/task value; otherwise drop to #3 or #5. This is
the mechanism that prevents skill bloat from one-off events.

**Anti-overlap with `knowledge-promote`:** knowledge-promote decides *whether* a note
should become a skill but only hands off conceptually. self-learning picks up at #3 and
actually authors via `writing-skills` + validates + proposes a diff. #3 is the
join point, not a duplicate.

## Autonomy: propose-only

The loop never edits/commits skills directly. It always emits a proposal (diff +
rationale) and waits for explicit approval. Safest default for a loop that can modify
skills.

## Output format (always a single proposal)

```
## Self-Learning Proposal
- Signals gathered : <n> (with source + occurrence count)
- Triage decisions : per signal → outcome (1-5) + rationale
- Proposed changes : per-file diff (skill / rule / vault)
- Evidence         : transcript / notes / validator result
- Gate             : "awaiting approval — not committed"
```

## Edge / error handling

- No signal passes the gate → proposal reports "all → #5 no-op + rationale" (never force creation).
- `writing-skills` needs a TDD baseline that can't run this round → downgrade to "draft +
  pending pressure-test", do not mark complete.
- `validate-skills.sh` fails → do not propose apply; attach the error to the proposal.
- Multiple signals collide (would edit the same skill differently) → merge into one diff,
  no stacked proposals.

## File layout

```
ai-skills/skills/self-learning/
  SKILL.md            # frontmatter + Use When / Do Not Use When / Goal /
                      # Required Inputs / Process (4 stages) / Decision Matrix /
                      # Output Format / Anti-patterns
  references/
    decision-matrix.md   # the 5-way table + reuse-pressure gate (keeps SKILL.md short)
    pressure-tests.md    # RED/GREEN scenarios used to verify the skill
```

Then wire into the configured agent skill targets — including `.claude/skills` if used,
and the Codex/Cursor adapters where applicable — and update ai-skills
`VERSION.md` / `README.md`.

> Source of truth remains `ai-skills/skills/self-learning/`.
> `.claude/skills` (and any other adapter target) is only an agent-facing mirror, not
> canonical. Wiring one target must not silently drop the others.

## Testing (writing-skills = TDD for skills)

This skill is process documentation; prove it with baseline-fail → write → pass.

1. **RED (baseline):** run a subagent on a real scenario WITHOUT this skill, e.g.
   "the user just fixed something `code-review` should have caught — learn from it."
   Record how the agent fails (rushes to create a new skill / auto-commits / skips the
   reuse-pressure check).
2. **GREEN:** add the skill → the same scenario must produce correct behavior (triage
   first, correct outcome, propose-diff-await-approval, no self-commit).
3. **REFACTOR:** close loopholes (e.g. agent rationalizes "this is obviously fine, skip
   triage") by hardening the skill.
4. **Minimum acceptance** before treating the skill as ready:
   - ≥3 pressure scenarios covering multiple matrix paths (including #5 no-op)
   - propose-only gate never bypassed (no auto-commit observed)
   - `validate-skills.sh` passes for the new skill

## Open follow-ups (out of scope this round)

- `/self-learn` slash command + a `rules/` entry (Approach C) — add later if used often.
- Automatic (non-prompted) triggering — explicitly excluded; this loop is on-demand/manual.
```
