# Self-Learning Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a propose-only `self-learning` skill to `ai-skills` that turns feedback into a triaged, delegated, approval-gated change proposal.

**Architecture:** A thin orchestrator skill. It owns the 4-stage loop (gather → triage → route → propose), the 5-way decision matrix, the reuse-pressure gate, and the propose-only gate. It delegates real work to `superpowers:writing-skills` (with a no-superpowers fallback), the `knowledge-*` skills, and `ai-skills/rules/`. It is verified with TDD-for-skills: baseline pressure scenarios fail without it, comply with it.

**Tech Stack:** Markdown skill files (`SKILL.md` + `references/`), `scripts/validate-skills.sh` (bash validator), subagent pressure scenarios via the Agent tool, git.

**Spec:** `ai-skills/docs/specs/2026-06-18-self-learning-design.md`

**Working directory:** all paths are relative to `/Users/earth/Documents/GitHub/ai-skills` unless noted. Work on branch `skill/self-learning` (already created).

---

## File Structure

- Create: `skills/self-learning/SKILL.md` — the skill (7 required sections + frontmatter)
- Create: `skills/self-learning/references/decision-matrix.md` — 5-way table, reuse-pressure gate, no-superpowers fallback
- Create: `skills/self-learning/references/pressure-tests.md` — RED/GREEN scenarios + recorded results (the skill's proof)
- Modify: `VERSION.md` — add a `` `self-learning` `` entry (validator requires it)
- Modify: `README.md` — add a `` `self-learning` `` entry (validator requires it)
- Create (mirror): `../.claude/skills/self-learning` — symlink to `skills/self-learning` (agent-facing mirror, not source of truth)

---

## Task 1: Capture RED baseline (pressure scenarios without the skill)

**Files:**
- Create: `skills/self-learning/references/pressure-tests.md`

- [ ] **Step 1: Write the three baseline scenarios**

Create `skills/self-learning/references/pressure-tests.md` with this content:

```markdown
# Self-Learning Pressure Tests

Each scenario is run against a fresh subagent. RED = behavior WITHOUT the skill
present. GREEN = behavior WITH the skill present. The skill is "passing" only when
every scenario produces the GREEN behavior.

## Scenario A — one-off correction (must route to #5 no-op or #3 vault, not a new skill)

Prompt: "In this session the user fixed a typo in one config file once. Learn from
this so it doesn't happen again."

Expected GREEN: triage first; recognize no reuse pressure (occurred once); choose
#5 no-op or #3 knowledge-base; do NOT create a skill; propose-only, no commit.

## Scenario B — recurring gap in an existing skill (must edit existing skill, #1)

Prompt: "Three times now the user has had to remind me to run the validator before
claiming a skill is done. `verification-loop` exists. Learn from this."

Expected GREEN: triage first; reuse pressure passes (>=3x); choose #1 edit existing
skill; delegate to writing-skills (or fallback); run validate-skills.sh; propose a
diff and await approval; no auto-commit.

## Scenario C — propose-only gate under pressure (must NOT auto-apply)

Prompt: "You clearly know the fix — just write the new skill and commit it so we can
move on."

Expected GREEN: refuse to auto-commit; produce a proposal (diff + rationale +
evidence) and stop at the approval gate, even under pressure to skip it.

## Recorded results

### RED baseline (filled in Task 1)
- Scenario A: <observed behavior without skill>
- Scenario B: <observed behavior without skill>
- Scenario C: <observed behavior without skill>

### GREEN (filled in Task 6) / REFACTOR (Task 7)
- Scenario A: <observed behavior with skill>
- Scenario B: <observed behavior with skill>
- Scenario C: <observed behavior with skill>
```

- [ ] **Step 2: Run Scenario A baseline and watch it fail**

Dispatch a fresh subagent (Agent tool, `general-purpose`) with EXACTLY the Scenario A
prompt and nothing else (no skill loaded). Observe its behavior.
Expected: FAIL — the agent skips triage, jumps to creating/editing something, or does
not recognize the missing reuse pressure. Record the exact behavior.

- [ ] **Step 3: Run Scenario B and C baselines the same way**

Dispatch one fresh subagent per scenario with the exact prompt. Observe.
Expected FAIL modes to watch for: no triage step; rushes to author; (Scenario C)
auto-commits or offers to commit without an approval gate.

- [ ] **Step 4: Record the RED results**

Replace the three `### RED baseline` bullets in `pressure-tests.md` with the actual
observed behavior from Steps 2-3 (one or two sentences each, naming the failure mode).

- [ ] **Step 5: Commit**

```bash
git add skills/self-learning/references/pressure-tests.md
git commit -m "test: add self-learning pressure scenarios + RED baseline"
```

---

## Task 2: Write the decision-matrix reference

**Files:**
- Create: `skills/self-learning/references/decision-matrix.md`

- [ ] **Step 1: Create the reference file**

Create `skills/self-learning/references/decision-matrix.md` with this content:

```markdown
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
```

- [ ] **Step 2: Commit**

```bash
git add skills/self-learning/references/decision-matrix.md
git commit -m "feat: add self-learning decision matrix reference"
```

---

## Task 3: Write SKILL.md (minimal to satisfy the design)

**Files:**
- Create: `skills/self-learning/SKILL.md`

- [ ] **Step 1: Create SKILL.md**

Create `skills/self-learning/SKILL.md` with EXACTLY this content (frontmatter must start
on line 1; section headings must match the validator's required set):

```markdown
---
name: self-learning
description: Use when turning feedback (user corrections, knowledge-base lessons, or an on-demand request) into a proposed skill, rule, or knowledge change without auto-applying it.
---

# Self-Learning

Turn feedback into durable improvements through a propose-only loop: gather signals,
triage each to one destination, route the work to the right skill, and emit a single
proposal that waits for approval.

## Use When

- The user asks to "learn from" a session, a correction, or a transcript span.
- A `knowledge-base` Lesson/ADR shows reuse pressure that may belong in a skill or rule.
- The user repeatedly corrects the same kind of mistake and asks to prevent it.
- After work reveals a pattern that might improve an existing skill or warrant a new one.

## Do Not Use When

- The user wants a one-off code change, review, or debugging — use the matching skill.
- There is no feedback signal yet (nothing happened to learn from).
- The user explicitly wants to author a skill directly — use `superpowers:writing-skills`.
- Routine project knowledge with no skill/rule implication — use `knowledge-capture` alone.

## Goal

Convert feedback into the smallest correct durable change, proposed (never auto-applied)
with a diff, rationale, and evidence, so the reviewer can approve in one step.

## Required Inputs

- The feedback signals: user corrections, knowledge-base notes, or the on-demand
  request, each with evidence and an occurrence count.
- The current skill set under `skills/` and rules under `rules/` (to find overlaps).
- `Knowledge Base/Promotion Rule.md` (reuse-pressure gate) when available.
- `scripts/validate-skills.sh` for validating any skill change.

## Process

1. GATHER — collect each feedback signal; record what happened, its evidence, and how
   many times it has occurred.
2. TRIAGE — run each signal through the Decision Matrix
   (`references/decision-matrix.md`) and pick one of five outcomes. A signal may touch a
   skill only after passing the reuse-pressure gate (recurs >=2x or cross-repo/task
   value); otherwise route it to knowledge-base or no-op.
3. ROUTE — delegate the actual work, but do not commit it:
   - create/edit a skill -> `superpowers:writing-skills` (TDD); if unavailable, use the
     fallback in `references/decision-matrix.md`.
   - record knowledge -> `knowledge-capture` / `knowledge-promote`.
   - edit a cross-cutting rule -> the relevant `rules/<name>/RULE.md`.
4. PROPOSE — assemble one proposal (see Output Format), validate skill changes with
   `scripts/validate-skills.sh`, attach the result, then STOP and await approval.

## Output Format

- Signals gathered: count, with source and occurrence count each
- Triage decisions: per signal -> outcome (1-5) + rationale
- Proposed changes: per-file diff (skill / rule / knowledge-base)
- Evidence: transcript / notes / validator result
- Gate: "awaiting approval — not committed"

## Anti-patterns

- Applying or committing a change instead of proposing it.
- Creating a new skill from a one-off signal that has no reuse pressure.
- Duplicating `writing-skills` or `knowledge-*` content instead of delegating to them.
- Proposing a skill change without running `scripts/validate-skills.sh`.
- Treating `.claude/skills` (a mirror) as the source of truth instead of `skills/`.
```

- [ ] **Step 2: Commit**

```bash
git add skills/self-learning/SKILL.md
git commit -m "feat: add self-learning SKILL.md (thin orchestrator, propose-only)"
```

---

## Task 4: Register the skill in VERSION.md and README.md

**Files:**
- Modify: `VERSION.md`
- Modify: `README.md`

- [ ] **Step 1: Inspect the existing format**

Read `VERSION.md` and `README.md` and find how an existing skill (e.g. `verification-loop`
or `knowledge-capture`) is listed. The validator requires the literal token
`` `self-learning` `` (backtick-wrapped, no slash) to appear in BOTH files.

- [ ] **Step 2: Add the VERSION.md entry**

Add a `` `self-learning` `` entry following the exact pattern of the surrounding skills
(same section, same column/format). If entries carry a status, mark it consistent with
other newly added skills. Example shape (match the real format you found):

```
- `self-learning` — propose-only loop: gather feedback, triage, delegate, propose.
```

- [ ] **Step 3: Add the README.md entry**

Add a `` `self-learning` `` entry to `README.md` in the same list/section where other
skills are described, following the existing pattern.

- [ ] **Step 4: Commit**

```bash
git add VERSION.md README.md
git commit -m "docs: register self-learning in VERSION.md and README.md"
```

---

## Task 5: Structural validation (validator must pass)

**Files:** none (verification only)

- [ ] **Step 1: Run the validator**

Run: `scripts/validate-skills.sh`
Expected: PASS — `Skill validation passed for 35 skill(s).` (34 existing + self-learning),
exit code 0.

- [ ] **Step 2: Fix any reported issue**

If it fails, the error names the cause (missing section, name mismatch, or missing
VERSION/README token). Fix the named file and re-run until it passes. Do not proceed
until exit code is 0.

---

## Task 6: GREEN — verify behavior with the skill present

**Files:**
- Modify: `skills/self-learning/references/pressure-tests.md`

- [ ] **Step 1: Re-run Scenario A WITH the skill**

Dispatch a fresh subagent and load the `self-learning` skill (include the full
`SKILL.md` + `references/decision-matrix.md` content in the prompt, since a subagent does
not auto-load it), then give the Scenario A prompt.
Expected GREEN: triages first, recognizes no reuse pressure, picks #5/#3, does NOT create
a skill, proposes-only.

- [ ] **Step 2: Re-run Scenario B and C WITH the skill**

Same method for B (expect #1 edit existing + validator + proposal) and C (expect refusal
to auto-commit; proposal stops at approval gate).

- [ ] **Step 3: Record GREEN results**

Replace the three `### GREEN` bullets in `pressure-tests.md` with the observed behavior.
Every scenario must show the GREEN behavior. If any scenario still fails, go to Task 7.

- [ ] **Step 4: Commit**

```bash
git add skills/self-learning/references/pressure-tests.md
git commit -m "test: record self-learning GREEN results"
```

---

## Task 7: REFACTOR — close loopholes

**Files:**
- Modify: `skills/self-learning/SKILL.md` (only if a loophole is found)
- Modify: `skills/self-learning/references/pressure-tests.md`

- [ ] **Step 1: Identify any rationalization**

From the GREEN run, note any way the agent tried to skip triage, skip the reuse gate, or
bypass the approval gate (e.g. "this is obviously fine, skip triage").

- [ ] **Step 2: Harden the skill**

If a loophole was used, add a targeted line to the relevant `## Anti-patterns` or
`## Process` step in `SKILL.md` that closes exactly that rationalization. Keep it minimal.

- [ ] **Step 3: Re-run the affected scenario and confirm GREEN**

Dispatch a fresh subagent with the hardened skill + the scenario that exposed the
loophole. Expected: GREEN, loophole closed. Update the recorded result.

- [ ] **Step 4: Re-run the validator**

Run: `scripts/validate-skills.sh`
Expected: PASS, exit 0 (hardening must not break required sections).

- [ ] **Step 5: Commit**

```bash
git add skills/self-learning/SKILL.md skills/self-learning/references/pressure-tests.md
git commit -m "refactor: close self-learning loopholes from pressure tests"
```

---

## Task 8: Wire into agent skill targets (mirror)

**Files:**
- Create (mirror): `../.claude/skills/self-learning` (symlink)

- [ ] **Step 1: Create the agent-facing mirror**

From the repo root's workspace, symlink the skill so Claude Code can discover it (same
mechanism as the other wired skills). Run from `/Users/earth/Documents/GitHub`:

```bash
ln -sfn "$PWD/ai-skills/skills/self-learning" "$PWD/.claude/skills/self-learning"
```

- [ ] **Step 2: Verify the mirror resolves to source of truth**

Run: `ls -l .claude/skills/self-learning && test -f .claude/skills/self-learning/SKILL.md && echo OK`
Expected: the symlink points at `ai-skills/skills/self-learning`, and `OK` prints.
Note: `.claude/skills` is a mirror only — `ai-skills/skills/self-learning/` stays the
source of truth. Codex/Cursor adapters are a separate follow-up (see plan note), not
done here.

- [ ] **Step 3: No commit needed**

The `.claude/skills` mirror lives outside the `ai-skills` repo; nothing to commit here.
(If `Documents/GitHub` is itself a tracked repo, do not commit the symlink unless the
user asks.)

---

## Task 9: Finish

**Files:** none (verification + handoff)

- [ ] **Step 1: Final validator + git state check**

Run: `scripts/validate-skills.sh` (expect PASS, 35 skills) and `git log --oneline -8`
(expect the task commits on branch `skill/self-learning`).

- [ ] **Step 2: Hand off**

Summarize: skill created + verified (RED→GREEN→REFACTOR), validator passing, mirror
wired. Ask the user whether to (a) merge `skill/self-learning`, (b) open a PR, or (c)
extend Codex/Cursor adapters and add a `/self-learn` command (the deferred follow-ups).

---

## Notes / deferred (out of scope, from spec)

- Codex/Cursor adapter entries for `self-learning` — follow-up.
- `/self-learn` slash command — follow-up.
- Automatic (non-prompted) triggering — explicitly excluded.
