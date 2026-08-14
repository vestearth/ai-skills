# Canonical Evidence Integration for Verification Skills

Status: implemented
Issue: vestearth/ai-skills#4 (consumes AI-office-agency#11)
Date: 2026-08-15

## Ownership

**ai-dev-office owns the evidence schema. This repository only consumes it.**

The canonical contract lives in `ai-dev-office/docs/evidence-contract.md`, with a
documentation-only mirror in `ai-dev-office/schemas/evidence.schema.yaml`; the
runtime rules are hardcoded in `ai-dev-office/validate-yaml.rb`. ai-skills does
not define, extend, fork, or re-specify that grammar. If a field is missing for
a skill's purpose, change it upstream first and then update this page — never
invent a second evidence schema here.

## What the upstream contract provides

- A per-task ledger `runs/<task-id>/evidence.yaml` plus captured logs at
  `runs/<task-id>/evidence/<ev-id>.log`.
- A producer wrapper (the office's `record-evidence.sh`, invoked as
  `<TASK_ID> [--type command|test|build|static_check|artifact] -- <command>`)
  which **runs the command for real**, captures stdout+stderr, records the exit
  code and repository provenance, hashes the log, appends the record, and exits
  with the command's own exit code. A failing check still fails the caller: the
  failure is recorded, not swallowed.
- Per-record provenance: `repo` (local git toplevel — operator-specific),
  `repo_origin` (portable `owner/repo` identity — **the field downstream
  consumers should read**), `repo_sha`, `working_tree_dirty`, `executed_at`,
  `artifact_path`, `artifact_sha256`.
- Integrity by recomputation: the office validator recomputes
  `artifact_sha256` on every run, so a fabricated record or an edited log fails
  validation instead of being taken on trust.
- An **optional** `evidence_refs` list on role outputs, at the top level and/or
  per entry in `claims[]`.

Evidence exists because an agent invoked the wrapper. Post-hoc re-execution of
recorded commands is separate upstream work and is not assumed here.

## The `ev-NNN` id grammar, and what it does not guarantee

`ev-` followed by a zero-padded sequence of at least three digits (`ev-001`,
`ev-002`, … `ev-1000`). Ids are allocated by the wrapper and stable once
written.

Ids are **task-scoped, not globally unique**. Two consequences that every skill
in this repo must respect:

1. An id only means something together with its task id. A dangling id fails
   upstream validation, but citing an id that merely happens to also exist in
   *another* task is **not detectable** by any validator — reviewers and
   auditors are the only control for that.
2. `repo_sha` is **provenance, not liveness**. The office validator does not
   compare it against current HEAD by default (re-validating a finished task
   months later must not start failing); `EVIDENCE_STRICT_SHA=1` opts into a
   strict staleness failure. So a cited record can be perfectly valid and still
   describe a tree that no longer exists.

## How a skill cites `evidence_refs`

When the work runs inside an ai-dev-office task, verification commands are run
through the office wrapper and the returned ids are cited in the role output:

```yaml
evidence_refs: [ev-001]
claims:
  - claim: "the unit suite passes on this branch"
    evidence_refs: [ev-001, ev-002]
```

Skill output formats in this repo carry the same information in their own
`Evidence` section: name the ids next to the inline result, e.g.

```text
Evidence:
- Command: go test ./internal/wallet/...
- Result: ok, 41 tests
- evidence_refs: ev-004 (TASK-EAR-123)
```

Always pair an id with its task id. Never cite an id alone as if it were a
global handle, and never cite an id you did not see in that task's ledger.

## Fallback behavior (the tier ladder)

Canonical evidence is a **strengthener, never a precondition**. Most repos have
no `runs/<task>/evidence.yaml` at all, and the verification skills must stay
fully usable there. Classify the situation into one tier and say which tier
applies:

| Tier | Situation | Required behavior |
| --- | --- | --- |
| **Available** | Ledger exists and cited ids cover the claim | Cite `evidence_refs` alongside the inline command + result. |
| **Absent** | No ledger for this work (the normal case outside ai-dev-office) | Fall back to the existing prose-evidence discipline **unchanged**: run the strongest practical check now, quote the real command and output inline. |
| **Partial** | Ledger exists but the cited evidence covers only part of the claim | Report `partial`; cite what is covered and list the uncovered part under "Not verified", or narrow the claim to the covered scope. |
| **Stale** | Cited record's `repo_sha` is not the tree under audit | Treat as not-yet-verified for a merge/deploy/handoff gate; re-run now and cite the fresh result. The old id may be cited only as history, labelled stale. |
| **Unreproducible** | Record cannot be re-run: environment gone, log/artifact missing, or recomputed hash mismatches | Treat the claim as unverified and say why the re-run failed. A hash mismatch is a fabrication signal, not a formatting problem. |

**Absence of canonical evidence degrades to prose evidence, never to "no
verification."** No skill may skip a check, accept a claim on narrative, or
soften a verdict because a ledger was unavailable.

## Preserved principles (not weakened by this integration)

- **Agent narrative is not evidence.** A report, checklist, summary, or
  `evidence_refs` list written into prose is a claim about evidence, not the
  evidence itself.
- **Current repo, tests, CI, runtime signals, and generated artifacts outrank
  memory and indexed context.** An evidence record is a durable record *of* one
  of those checks; it does not outrank re-running the check. The ordering in
  `rules/evidence-required/RULE.md` is unchanged.
- A cited id is worth exactly the command it recorded — no more.

## Broad claim vs narrow evidence

A claim must not exceed the coverage of the checks actually run. Before
reporting, restate the claim and the coverage of each cited check (which
package, suite, environment, or path it touched). If the claim covers anything
no cited command executed, do exactly one of:

1. narrow the claim to the covered scope,
2. run the check that closes the gap and cite it, or
3. report the result as `partial` and list the uncovered scope under
   "Not verified".

"All tests pass" is supported only by a command that ran all tests; a
single-package or single-test invocation supports only that package or test.
Evidence from different tasks or runs may not be summed to justify one broad
claim — ids are task-scoped, and coverage does not compose across trees.

## Validation boundary in this repo

`scripts/validate-skills.sh` and `scripts/validate-skill-metadata.rb` deliberately
do **not** attempt to resolve `ev-NNN` ids: the ledgers live in a different
repository and under task directories this repo cannot see. Resolution,
dangling-id detection, and hash recomputation are the office validator's job.
ai-skills validates only what it owns — skill structure and the sidecar
contract from `docs/specs/2026-08-14-skill-metadata-evals-design.md`.

The one exception is the **id spelling**, which is a stable, machine-checkable
part of the upstream grammar and is entirely local to this repo's own text:
`scripts/validate-skills.sh` scans `skills/**/*.md`, `rules/**/*.md`, and
`docs/specs/*.md` and fails on an evidence id that is not `ev-` plus at least
three digits. `ev-NNN` and `ev-id` are the documented placeholders and are
allowed literally. This catches under-padded or mis-punctuated ids in guidance
an agent would otherwise copy; it asserts nothing about whether any id exists.
(The check is self-applying, so this page cannot spell a counter-example out.)

## Scope of the change

Updated surfaces only: `skills/verification-loop`, `skills/completion-audit`,
`skills/code-review`, `skills/minimal-change-review`, `skills/debugging`,
`rules/evidence-required`, `rules/verify-before-final`. Other skills are
unchanged; there is no repo-wide migration.
