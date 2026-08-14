# Skill Metadata + Evaluation Foundation (v1)

Status: implemented (pilot scope)
Issue: vestearth/ai-skills#3
Date: 2026-08-14

## What this adds

Optional sidecar files per skill, without touching the `SKILL.md` discovery
contract:

```text
skills/<skill>/
  SKILL.md            # unchanged discovery + behavior contract
  metadata.yaml       # ownership, version, lanes, maturity, eval state
  evals/
    cases.yaml        # behavioral eval cases (fixtures, not a runner)
```

Pilot scope (v1): `verification-loop`, `minimal-change-review`,
`search-first`, `completion-audit`. Other skills stay sidecar-free until the
pilot proves value. Do not add sidecars to every skill by default.

## metadata.yaml schema (schema_version: 1)

```yaml
schema_version: 1            # exactly 1
owner: earth                 # accountable maintainer, non-empty
version: 1.0.0               # semver of the skill's guidance contract
supported_lanes:             # non-empty; every lane must have adapters/<lane>/
  - claude
  - codex
  - cursor
maturity: beta               # experimental | beta | stable

evaluation:
  case_file: evals/cases.yaml   # path relative to the skill directory
  last_evaluated: null          # null | YYYY-MM-DD
  status: not_run               # not_run | passing | failing | partial
  pass_rate: null               # null | 0.0..1.0

known_failure_modes: []      # list of dated one-line strings; explicit data,
                             # not prose hidden in unrelated docs
```

Unknown keys are validation errors (typo protection). No other keys are part
of v1; propose schema_version 2 before extending.

### Consistency rules (enforced by the validator)

- `status: not_run` requires `last_evaluated: null` and `pass_rate: null`.
- Any other `status` requires a non-null `last_evaluated` and a numeric
  `pass_rate` in `[0, 1]`.
- `maturity: stable` requires `evaluation.status: passing` — a stable claim
  must be backed by a recorded eval run.
- Every lane in `supported_lanes` must have a corresponding `adapters/<lane>/`
  directory. No lane is "supported" without an adapter surface.
- `metadata.yaml` and `evals/` are paired: metadata requires its `case_file`
  to exist; an `evals/` directory without `metadata.yaml` (or with files not
  referenced by `case_file`) is an orphan and fails validation.

## evals/cases.yaml schema (schema_version: 1)

```yaml
schema_version: 1
skill: verification-loop     # must match the skill folder name
cases:
  - id: vl-001               # unique, ^[a-z0-9-]+$
    dimension: activation_correctness
    scenario: >
      The situation given to the agent (prompt, repo state, prior claims).
    expected: >
      Observable behavior that counts as a pass.
```

`dimension` is one of exactly five v1 dimensions (from the issue):

| dimension | measures |
| --- | --- |
| `activation_correctness` | the skill activates on its trigger situations |
| `instruction_compliance` | the agent follows the skill's process, not a paraphrase |
| `false_completion` | completion/success claims without evidence get caught |
| `evidence_quality` | accepted evidence is real (right layer, right source) |
| `unnecessary_invocation` | the skill does NOT fire where it adds nothing |

Cases are fixtures. v1 deliberately ships no automated runner — evals are
executed by a human or an agent session replaying the scenario against the
skill and judging the observable behavior against `expected`.

## How eval state gets updated

One eval run = replay all cases in `case_file` for that skill.

1. Run every case; record pass/fail per case id in the PR/commit description
   (the per-case log is review evidence, not a tracked artifact in v1).
2. Update the three fields **together in the same commit**:
   - `last_evaluated`: the run date (YYYY-MM-DD)
   - `pass_rate`: passed / total, as a decimal
   - `status`: `passing` (all pass), `failing` (any core case fails),
     `partial` (mixed, with the failures understood and listed)
3. If a case failed for a reason worth remembering, append a dated one-line
   entry to `known_failure_modes` in the same commit.
4. Never update `status`/`pass_rate` without `last_evaluated`, and never
   record a run that did not happen — the validator blocks the first, review
   must catch the second.

`known_failure_modes` entries are append-oriented, dated, one line each,
describing an observed failure of the behavior the skill guards (with the
month it was observed). Remove an entry only when the skill body was changed
to prevent it and a later eval run confirmed the fix.

## Versioning rules

- `version` follows semver per skill: patch = wording/clarity, minor =
  process/scope changes that keep the trigger stable, major = trigger or
  output-contract changes.
- Bump `version` in the same commit as the `SKILL.md` change it describes.
- `schema_version` (both files) changes only via a new spec revision here.

## Maturity ladder

- `experimental` — guidance exists; no eval cases yet.
- `beta` — eval cases defined; may or may not have a recorded run.
- `stable` — latest recorded run is `passing` and at least two lanes are
  supported. This mirrors the Agent Plugin candidate gate in
  vestearth/AI-office-agency#18: plugin packaging should select from
  `maturity: stable` + `status: passing` skills, not from skills that merely
  exist.

## Validation

`scripts/validate-skill-metadata.rb` enforces everything above; it is invoked
from `scripts/validate-skills.sh`, so local runs and the `validate` CI
workflow fail on malformed metadata, broken case references, orphan evals,
enum violations, and inconsistent eval state. Skills without sidecars are
untouched by validation.

## Non-goals (v1)

- No automated eval runner or scoring harness.
- No plugin packaging (that is AI-office-agency#18, gated on this data).
- No canonical-evidence references (`evidence_refs`) — that is ai-skills#4,
  blocked on AI-office-agency#11.
- No mass rollout beyond the four pilot skills.
