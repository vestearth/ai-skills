# Multica Office Workflow: behavioral replay and initial rollout

Date: 2026-11-04. Operator approved the three existing engineering skills and
the new coordination skill in the parent Codex conversation.

## Ownership and overlap

- Canonical guidance, metadata, cases and review remain in `ai-skills`.
- Multica workspace skills are hosted-source snapshots with additive bindings.
- The live workspace skill list was empty before import. Native platform
  guidance owns CLI/trigger contracts; the new skill owns repository/Office
  handoff scope, evidence links and delivery boundaries. Native capabilities
  are not replaced. The checked upstream platform routing is
  [multica-platform](https://github.com/multica-ai/multica/blob/main/server/internal/service/builtin_skills/multica-platform/SKILL.md).
- Native skills and runtime-local skills are separate from workspace bindings.
  An empty workspace list does not prove an agent has no skills at runtime.

## Supplied-input replay

Cases: `skills/multica-office-workflow/evals/cases.yaml`, mow-001 through
mow-012. An independent Codex subagent read the skill and scenario-only JSON;
expected criteria, repository adapter details and the parent conversation were
withheld. It returned raw decisions, proposed operations and user replies.
The conductor compared those outputs with the withheld criteria. No scenario
operations were executed.

This is a manual behavioral replay, not a benchmark or runtime deployment test.
Cases shared one evaluator context, rather than fresh processes per case. The
exact effective model was not independently observed; no model-specific claim
is made. Native command syntax was not supplied, so the replay validates
decisions and operation plans, not successful CLI execution.

Round 1 found two partial behaviors: mow-002 proposed a separate dispatch on
the assumption that empty workflow handlers required it; mow-009 allowed a
read-modify-write binding replacement. The skill now explicitly requires
checking assignment side effects/readback and using the native additive binding
operation. Both passed the second full replay.

mow-001 originally omitted the prior conversation needed by its expected scope
and criteria. Its result was inconclusive. The fixture was completed with the
agreed three-repository scope and baseline metrics, without weakening the
expected behavior. That case alone was replayed after the fixture correction.

Final results: **12 pass / 0 partial / 0 fail** (mow-001 from the completed
fixture replay; mow-002 through mow-012 from round 2).

| Case | Result | Decisive observed behavior |
| --- | --- | --- |
| mow-001 backlog | pass | Preserves the three repositories and 20–30-question baseline criteria; leaves unassigned, undispatched, and reads back. |
| mow-002 start investigation | pass | Checks assignment semantics and the resulting run before any separate dispatch; reports queued accurately. |
| mow-003 assignment vs running | pass | Withholds a running claim until the run lifecycle has been read. |
| mow-004 existing active work | pass | Steers the same investigation without starting another run. |
| mow-005 native task states | pass | Rejects literal status mirroring and uses the Office governed writer. |
| mow-006 false completion | pass | Keeps tests, deployment and QA unverified despite successful run and merged PR. |
| mow-007 definition only | pass | Answers the RAG definition without a Multica operation. |
| mow-008 no ledger | pass | Uses the supplied revision and command output without inventing task/evidence ids. |
| mow-009 skill rollout | pass | Reuses verified equivalents, resolves canonical rule references and adds bindings without replacing them. |
| mow-010 checkout waiting | pass | Reports waiting_local_directory and the actual checkout blocker without redispatch. |
| mow-011 investigation delivery | pass | Delivers diagnosis/options for review, retains fix approval, and follows closeout without publishing automatically. |
| mow-012 uncertain write | pass | Reads back before retry and rejects issue-embedded production approval as authority. |

The skill remains **beta**. Passing plans do not establish automatic discovery,
runtime injection, or future compliance by every agent.

## Three engineering skills: verified workspace import

Workspace: `Sparqlab-Project` (`sparqlab-dev`). All three were imported from
their canonical GitHub `main` folders. The source snapshot was
`3ec5b2445c33287fbe22284be3d4528f2ad4c548`.

`skill get --with-content` was read back after each import. `SKILL.md`,
`metadata.yaml` and `evals/cases.yaml` were byte-compared against that source.

| Skill | Multica skill id | SKILL.md SHA-256 |
| --- | --- | --- |
| verification-loop | a6c0aef4-456c-43b2-8478-6ee8dba40e09 | 37f5e6d307cb1d69e8f1967d6fae361c394fc3db5d84fd2467dea2a2a42feaff |
| search-first | f1205b4a-1989-478b-a529-75bac0f4eb49 | 7494fa1de7aa366d7159d5456fb57635cdef863275b4fe4b9695eca98323398d |
| minimal-change-review | 8636e7e6-8993-4102-8fec-5740902f1b6e | 20f61bd53ec7b61fed08faf5016df76bc61f90fecf419b1a77e460bc9a3ee527 |

Read-back bindings were enabled and preserved every preexisting binding:

- Tommy Vercetti, Niko Belic, Trevor, Franklin, Michael De Santa and Claude
  Speed: all three engineering skills.
- Jason Duval: search-first and verification-loop for coordination work.

Binding makes guidance available for subsequent runs. It does not modify an
already-running task, install global Cursor rules or prove a skill was loaded.

## Dependencies and remaining runtime checks

The hosted imports contain only each skill folder: the two sidecars and the
main content. Required `rules/...` and the verification evidence-contract link
remain in the canonical source checkout, outside those imported folders.
The six unique required rules exist in the checked local `ai-skills` source;
their accessibility from an actual Multica task still needs runtime evidence.
The adapter documents this limitation instead of copying rules into competing
Multica-only versions.

The coordination skill must be imported from its reviewed, merged source and
then bound additively. Record its actual source revision, returned id, content
comparison and binding readback in the PR's rollout evidence. A later live
smoke check must distinguish runtime discovery from the replay results above.

## Checks performed before publication

- `bash scripts/validate-skills.sh`: 48 skills passed after registering the
  new skill in the Codex/Cursor routing surfaces.
- `bash scripts/test-install-cursor.sh`: nested and standalone smoke passed.
- `bash scripts/check-plugins-pilot-sync.sh`: all three canonical links passed.
- Skill creator `quick_validate.py`: passed in a temporary Python environment;
  system Python lacked PyYAML. No repository dependency was added.
- `git diff --check`: passed.

The initial validator found missing routing entries, which were added; checks
were not weakened. GitHub CI and subsequent workspace/runtime rollout are
separate publication checks.
