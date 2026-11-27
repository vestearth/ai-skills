# session-handoff durable work and Multica decision write-back: behavioral replay

Date: 2026-11-27.

Cases:
- `skills/session-handoff/evals/cases.yaml`: sh-001 to sh-005 (new; the skill had no cases before)
- `skills/multica-office-workflow/evals/cases.yaml`: mow-017 (new)

## Why

The AI Office roadmap reassessment of 2026-11-27 found two lane-change failures
in Oct–Nov transcripts:
- TASK-VS-004 (2026-10-31): an uncommitted git worktree under `/private/tmp`
  was deleted by macOS, and the slip-system half had to be rewritten.
- TASK-VS-069 (2026-11-10/11): decisions made in a local session had to be
  relayed to the Multica squad by hand, twice.

Both were proposed as skill rules. Each needed a failing baseline first.

## Method

Same as `2026-11-01-ops-evidence-skills-replay.md`:
- Each CLI got the skill's `SKILL.md` and one case's `scenario`. `expected` was withheld.
- Every case ran as a separate process in an empty directory, so no repository context loaded.
- The prompt asked what the agent would do, what it would write or post, the
  commands it would run (it ran none) and the evidence it would cite. It did
  not ask the agent to grade itself.

| Lane | Invocation | Model |
| --- | --- | --- |
| Claude | `claude -p --model claude-sonnet-5-5 --max-turns 1`, tools disallowed, prompt on stdin | `claude-sonnet-5-5` |
| Codex | `codex exec -m gpt-6.2-astra -s read-only --skip-git-repo-check` | `gpt-6.2-astra` |
| Cursor | `cursor-agent -p --trust --mode ask --output-format text` | default |

The conductor judged each answer against `expected` and quoted the decisive
line. This is a manual behavioral evaluation, not an automated benchmark.

## Baseline: skill text on main `83b6e6a`

| Case | Claude | Codex | Cursor |
| --- | --- | --- | --- |
| mow-017 decision made outside Multica | pass | pass | pass |
| sh-001 uncommitted worktree under /private/tmp | pass | pass | **fail** |
| sh-002 task already tracked and pushed | pass | pass | pass |

- **mow-017:** all three lanes updated the SPAR-69 description or posted the
  decisions before starting the squad. The existing text already covers this,
  so `multica-office-workflow` is unchanged and mow-017 stays as a regression case.
- **sh-001 Cursor:** it named the risk ("can disappear before tomorrow") but
  its next actions said to leave the slip-system changes uncommitted, which is
  the TASK-VS-004 failure. Claude committed a WIP checkpoint; Codex archived the
  files outside `/private/tmp`.

## Change

`session-handoff` Process step 2 (new): before handing over, run `git status`
in every repository and worktree touched; commit and push to the task branch,
or move the work out of temporary directories and name who commits it and when.
Noting the risk is not enough. One matching anti-pattern line. Later steps were
renumbered.

## Round 2: revised text

| Case | Claude | Codex | Cursor |
| --- | --- | --- | --- |
| sh-001 uncommitted worktree under /private/tmp | pass | pass | pass |
| sh-002 task already tracked and pushed | pass | pass | pass |

- **sh-001:** all three lanes commit and push before writing the handoff, and
  name moving the worktree out of `/tmp` as the fallback if the push fails.
- **sh-002:** all three still update the task artifact instead of writing a
  separate handoff; the new step adds only a `git status` check that the tree
  is clean.

The validator requires all five dimensions, so three coverage cases were added
and replayed:

| Case | Claude | Codex | Cursor |
| --- | --- | --- | --- |
| sh-003 pre-compaction snapshot | pass | pass | pass |
| sh-004 "all tests pass" with a failed run | pass | pass | pass |
| sh-005 artifacts by reference, token redacted | pass | pass | pass |

Round 2 also showed a side effect. On sh-003, the round-2 wording ("commit and
push uncommitted work") made Cursor commit and push a checkpoint during its own
compaction, with no lane change and no request to push.

## Round 3: final text

Step 2 was scoped to a handoff to another agent or session, and committing
became conditional: "Commit and push uncommitted work to the task branch if you
may commit; otherwise ask, or move the work out of temporary directories and
name who commits it and when."

| Case | Claude | Codex | Cursor |
| --- | --- | --- | --- |
| sh-001 uncommitted worktree under /private/tmp | pass | pass | pass |
| sh-003 pre-compaction snapshot | pass | pass | pass |

- **sh-001:** Claude commits and pushes, or asks if the commit is not covered.
  Codex pushes a checkpoint, with a move to `~/Worktrees` and a named owner as
  the fallback. Cursor does not commit without an explicit ask, moves the
  worktree out of `/private/tmp`, and names who commits.
- **sh-003:** no lane pushes during its own compaction. Each writes the
  snapshot and re-reads it after compaction; Cursor commits only "if this
  session is allowed to commit".

sh-004 and sh-005 ran while the text changed from round 2 to round 3. The change
touches only step 2, which those cases do not exercise.

## Result

- `session-handoff`: one Process step and one anti-pattern line; metadata and 5 cases added. All 21 runs on revised text (rounds 2 and 3) met their expected answer; the round-2 side effect above is why round 3 exists. sh-002 ran on round-2 text only; the round-3 change narrows step 2 and cannot make it stricter for that case.
- `multica-office-workflow`: no text change. mow-017 passed on all three lanes and stays as a regression case.
