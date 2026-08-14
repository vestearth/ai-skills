---
name: completion-audit
description: Use when receiving work claimed complete from another agent, subagent, Codex, office handoff, PR, or past session and the claims must be independently audited before acceptance, including short prompts such as "เสร็จจริงไหม", "เช็คงานที่ส่งมา", or "audit handoff นี้".
---

# Completion Audit

Treat a completion report as a set of claims, not evidence. Accept only what you re-observe.

## Use When

- Receiving a handoff, PR, or completion report from another agent, subagent, Codex run, office runner, or a past session.
- Accepting claimed-done work into a task run, review lane, merge, or deployment.
- Deciding whether claimed artifacts (commits, branches, files, tests, deploys) actually exist.
- A completion report looks plausible but nobody has independently observed the work.

## Do Not Use When

- Verifying your own work before claiming completion; use `verification-loop`.
- Reviewing diff quality, design, or production impact regardless of claims; use `code-review`.
- The delivered work is analysis or advice only, with no artifacts or verifiable claims.

## Goal

Catch false completion claims, weakened tests, scope creep, and missing artifacts before claimed-done work is accepted, merged, or handed onward.

## Required Rule

Apply `rules/evidence-required/RULE.md` and `rules/verify-before-final/RULE.md`.

## Required Inputs

- The completion report or handoff: what was done, what was verified, what stayed untouched.
- Access to the actual artifacts: repository, branches, diff, run outputs, logs.
- An executable environment to re-run claimed verifications when practical.

## Process

1. Collect the claims from the report: done, verified, untouched. Audit each claim separately; none inherits trust from another.
2. Establish ground truth independently with `git status`, `git log --all`, and the real diff; check all branches and the reflog before concluding a claimed artifact does not exist.
3. Map each claim to observed evidence and mark it verified, unverified, or contradicted.
4. Re-run every claimed verification (tests, build, lint, scripts) and capture actual output; re-running beats reading code, and both beat reading the report.
5. Audit cited evidence, if any (see Canonical Evidence below): resolve each `ev-NNN` id in the citing task's own ledger, check the recorded command actually covers the claim it is attached to, and check the recorded `repo_sha` against the tree you are auditing.
6. Check claim scope against evidence scope. A broad claim ("all tests pass", "the service is unaffected") backed only by narrower commands is `unverified` or `partial` — never `verified` — unless the claim is narrowed to what the commands covered.
7. Hunt classic frauds in priority order: weakened or deleted assertions, expected values changed to match new behavior, false completion wording, evidence cited for a claim it does not cover, scope creep or unrequested artifacts, unauthorized outward actions (push, deploy, publish), leftover debris.
8. Check spec alignment: the user's request beats the spec, the spec beats tests, tests beat code.
9. Deliver the verdict with evidence first; for REFUTED, name the failed claim, show the contradicting output, and propose the minimal fix.

## Canonical Evidence

A handoff produced inside an ai-dev-office task may cite `ev-NNN` ids in
`evidence_refs`. Contract:
[../../docs/specs/2026-08-15-evidence-integration.md](../../docs/specs/2026-08-15-evidence-integration.md) —
ai-dev-office owns that schema; this repo only consumes it. Audit the citations,
do not inherit them:

- Ids are **task-scoped**. Resolve every id in the citing task's own ledger. An
  id that only exists in some other task is not detectable by any validator —
  this audit is the only control for it.
- The office validator recomputes `artifact_sha256`, so an edited log fails
  upstream; a mismatch you observe is a fabrication signal, not a formatting
  problem.
- `repo_sha` is provenance, not liveness. A valid record can describe a tree
  that no longer exists — for a merge, deploy, or acceptance gate, re-run the
  check against the tree you are auditing and cite the fresh result.
- A cited id is a claim's *support*, not the claim's proof of scope: the
  recorded command must actually cover the claim it is attached to.

**No ledger is the normal case.** Outside ai-dev-office there are no ids to
resolve; audit exactly as before — re-run the claimed verifications and observe
the repository directly. Missing canonical evidence never softens a verdict and
never excuses accepting a claim on the report's narrative.

## Output Format

- Verdict: VERIFIED, VERIFIED WITH CAVEATS, or REFUTED
- Claims table: claim → evidence (`ev-NNN` + task id when cited) → verified / unverified / contradicted
- Evidence audit: ids resolved, unresolved, stale, or covering less than the claim (omit when no ledger exists)
- Fraud findings, or none found
- Evidence: commands run and actual output
- Not audited and remaining risk

## Anti-patterns

- Accepting the report's own checklist as proof that checks ran.
- Reading code to "confirm" a claim that could be re-run.
- Concluding a commit or artifact does not exist after checking only the current branch.
- Auditing only the claims made while ignoring unclaimed changes in the diff.
- Softening a REFUTED verdict because the work looks mostly right.
- Treating a cited `ev-NNN` list as verification instead of resolving each id in the citing task's ledger.
- Accepting a broad claim because narrower evidence beneath it passed.
- Downgrading the audit because the work came from a repo with no evidence ledger.

## Attribution

Verdict model and fraud-hunting order adapted from `fable-judge` in [fable-method](https://github.com/Sahir619/fable-method) (MIT).
