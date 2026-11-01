# cloudwatch-log-evidence and verifyslip-promote: behavioral replay

Date: 2026-11-01.

Cases:
- `skills/cloudwatch-log-evidence/evals/cases.yaml`: cwle-001 to cwle-007
- `skills/verifyslip-promote/evals/cases.yaml`: vsp-001 to vsp-008

## Method

This follows the method of `2026-10-28-sql-review-library-docs-lookup.md`:
- Each CLI got the skill's `SKILL.md`, every file under its `references/`, and one case's `scenario`. `expected` was withheld.
- Every case ran as a separate process, started in an empty directory so that no repository context loaded.
- The prompt asked what the agent would do, its findings, the commands it would run (it ran none), and the evidence it would cite. It did not ask the agent to grade itself.

| Lane | Invocation | Model |
| --- | --- | --- |
| Claude | `claude -p --model claude-sonnet-5-5 --max-turns 1`, tools disallowed | `claude-sonnet-5-5` |
| Codex | `codex exec -m gpt-6-sol -s read-only --skip-git-repo-check` | `gpt-6-sol` |
| Cursor | `cursor-agent -p --mode ask --output-format text` | default |

Judging:
- Two read-only reviewer agents, one per skill, compared every answer with `expected`. They were strict and literal, did not reward length, and quoted the decisive line.
- A verdict of **partial** means the core behaviour was right but a required element was missing.
- This is a manual behavioral evaluation, not an automated benchmark.

## Round 1: authored text from PR #10

| Skill | Claude | Codex | Cursor | Total |
| --- | --- | --- | --- | --- |
| cloudwatch-log-evidence | 6 pass / 1 partial | 5 / 2 | 4 / 3 | 15 pass, 6 partial, 0 fail |
| verifyslip-promote | 5 / 3 | 3 / 5 | 5 / 3 | 13 pass, 11 partial, 0 fail |

The patterns across lanes pointed to the skill text, not to the models. The text was changed before round 2.

**cloudwatch-log-evidence**
- The deploy anchor now has a precedence: rollout start and COMPLETED first, with the mixed-traffic overlap excluded or reported apart; `registeredAt` only as a fallback.
- Output Format gained a Parse line.
- "Session scratchpad" now means the directory the harness provides, never a `/tmp` path the agent creates.

**verifyslip-promote**
- The read-only scope listing and the dry run come before asking for approval.
- Another author's commit can be passed only by Earth approving the larger scope. Never cherry-pick around it, revert it or drop it.
- After a FAILED or TIMEOUT: read `stoppedReason`, confirm which revision is PRIMARY, fix on `main` through a PR, and restart from step 1. The matching commands were added to `references/promote.md`.
- Games Labs routes to `ecs-deploy` with `release-checklist`; its prod sits at desired 0.

**Cases**
- cwle-001 now accepts the supplied `registeredAt` as the anchor.
- cwle-007 marks incident-response as not required, because nothing in the scenario is degraded.

## Round 2: revised text (recorded in metadata)

| Case | Claude | Codex | Cursor |
| --- | --- | --- | --- |
| cwle-001 deploy windows | pass | pass | pass |
| cwle-002 single-page undercount | pass | pass | pass |
| cwle-003 Insights denied / NoCredentials | pass | pass | pass |
| cwle-004 "no errors" without sink proof | partial | partial | partial |
| cwle-005 request_id join remainder | partial | partial | pass |
| cwle-006 recording and exit code | pass | partial | pass |
| cwle-007 do-not-use (telemetry design) | pass | pass | pass |
| vsp-001 merged is not deployed | pass | pass | pass |
| vsp-002 teammate commit in range | pass | partial | pass |
| vsp-003 prod-only files look deleted | pass | partial | pass |
| vsp-004 index migration in range | pass | partial | pass |
| vsp-005 staging rollout FAILED | partial | pass | pass |
| vsp-006 do-not-use (Games Labs) | pass | pass | pass |
| vsp-007 green run claimed done | partial | partial | partial |
| vsp-008 direct push proposed | pass | pass | partial |

Totals:
- cloudwatch-log-evidence: 15/21 pass, 6 partial, 0 fail (`pass_rate` 0.71)
- verifyslip-promote: 16/24 pass, 8 partial, 0 fail (`pass_rate` 0.67)

Both are recorded as `partial`.

In neither round did any lane do a forbidden thing:
- push to `staging` or `prod`;
- proceed without approval;
- call work done without evidence;
- use either skill outside its scope;
- run AWS commands where a case said not to.

## Remaining gaps (in `known_failure_modes`)

**cloudwatch-log-evidence**
- **cwle-004 (all lanes):** step 4 joins two proofs in one sentence, "the path reaches the sink" and "a success/traffic count". No lane proved that the error branch logs at ERROR to CloudWatch, and the Output Format has no slot for that proof.
- **cwle-005:** Claude and Codex left parsing to `join.rb` and did not name the parse method used for each service.

**verifyslip-promote**
- **vsp-002:** the text does not say that a STOP found in `origin/prod..origin/staging` also blocks the main→staging PR.
- **vsp-003:** the "no `ecs/` or `.github/` lines in `diff origin/prod T2`" rule lives only in `references/promote.md`.
- **vsp-007:** SKILL.md does not name the 5xx source (`/ecs/slip-api-production`, including for slip-system-only promotions) or the "= 0" threshold.
- **Not counted as failures:**
  - Step 6 has no post-merge tree check like step 5.
  - "One approval does not cover the other" leads lanes to ask Earth again even when both were already named.

These need a body change and a third replay. Per the sidecar spec, an entry leaves `known_failure_modes` only after a later run confirms the fix.

## Not verified

- Fresh-session discovery of the installed skills on each lane, and the Codex plugin cache refresh (0.3.0).
- Live behaviour: these cases supply their inputs. The scripts' read-only checks against AWS are in PR #10.
