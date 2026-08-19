---
name: minimal-change-review
description: Use when an agent is about to modify code, create files, add dependencies, scaffold features, or review whether an implementation is larger than necessary.
---

# Minimal Change Review

Review whether the task can be solved by reusing what already exists before adding new code.

## Use When

- Before implementing a code change or generated handoff.
- Reviewing an implementation that may be overbuilt.
- Deciding whether to add a dependency, helper, abstraction, workflow, or scaffold.
- Converting an external pattern into this repository's own standards.

## Do Not Use When

- The user only asks for factual explanation and no change is being considered.
- A security, data-loss, incident, or production failure workflow is more urgent.

## Required Rule

Apply:

- `rules/minimal-change/RULE.md`
- `rules/reuse-before-build/RULE.md`
- `rules/search-before-create/RULE.md` when creating new artifacts

## Goal

Prevent unnecessary code, dependencies, scaffolding, and abstractions by proving reuse options were checked first.

## Required Inputs

- User request, acceptance criteria, or proposed implementation.
- Relevant repository files, docs, tests, dependency manifests, and existing helpers.
- Diff or planned change when reviewing work already produced.
- Verification evidence when available.

## Process

Answer the minimal-change and reuse chain in order:

1. Define the exact required change.
2. Confirm the behavior or artifact is necessary.
3. Search existing code, docs, tests, configs, and conventions.
4. Check standard library, runtime, platform, or native features.
5. Check existing dependencies.
6. Choose the smallest safe edit or explain why new code is required.

For each answer:

- Cite the repo evidence checked.
- Prefer the first adequate option.
- Stop expanding once the task is satisfied.
- Preserve tests, contracts, security, accessibility, data safety, and compatibility.

## Scope Authority

This review challenges *unreviewed* scope, not scope the operator already
decided. When the operator has given explicit prior approval for the current
plan or diff (a written plan, an approved scope statement, an explicit
go-ahead on the specific change), do not re-litigate or shrink that scope —
apply minimal-change judgment only to implementation choices made *within*
the approved scope. Treat operator approval as binding unless it conflicts
with a hard rule (tests, security, data safety, compatibility); if it does,
surface the conflict instead of silently overriding the approval.

## Evidence Type Check

An `evidence_refs` citation (or any cited command/log) only supports a claim
if its command TYPE matches what the claim asserts. Before accepting a
citation:

- A "reuse options were checked" or "nothing exists" claim needs a search
  command (grep, find, symbol lookup, dependency listing) — a build, test, or
  lint run proves nothing about whether an existing helper was looked for.
- A "verified" or "tests pass" claim needs a test/run command, not a search.
- If the cited record's command does not match the claim it is backing,
  reject it as unsupported and require the correct command be run and cited,
  regardless of whether the reference id itself looks valid.

"Nothing exists to reuse" is the claim that authorizes new code, and it is a
negative claim: it must not exceed the searches actually run. Name the queries,
paths, and manifests checked; one failed grep supports "not found by that
query", not "does not exist". When a canonical evidence ledger exists for the
task, the search or static-check commands can be recorded and cited as
`evidence_refs` with their task id
([../../docs/specs/2026-08-15-evidence-integration.md](../../docs/specs/2026-08-15-evidence-integration.md);
ai-dev-office owns that schema, this repo only consumes it). Where no ledger
exists — the normal case — list the same commands inline. Either way the
justification for new code is the search coverage, never the absence of a
ledger.

## Output Format

- Decision: reuse, small edit, or new code required
- Evidence checked: files, commands, docs, or dependency references (`evidence_refs: ev-NNN (task-id)` when a ledger exists)
- Search coverage: what was searched, when the decision rests on finding nothing
- Minimal change: what should be changed and what should stay untouched
- Verification: tests or checks required before completion

## Anti-patterns

- Starting from a preferred implementation instead of the smallest sufficient path.
- Adding a new abstraction because similar code exists twice.
- Copying an external project wholesale when a local rule is enough.
- Renaming, moving, or reformatting unrelated code.
- Treating "small" as "untested" or "unsafe."
- Justifying new code with "nothing exists" after a single narrow search.
