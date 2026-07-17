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
5. Hunt classic frauds in priority order: weakened or deleted assertions, expected values changed to match new behavior, false completion wording, scope creep or unrequested artifacts, unauthorized outward actions (push, deploy, publish), leftover debris.
6. Check spec alignment: the user's request beats the spec, the spec beats tests, tests beat code.
7. Deliver the verdict with evidence first; for REFUTED, name the failed claim, show the contradicting output, and propose the minimal fix.

## Output Format

- Verdict: VERIFIED, VERIFIED WITH CAVEATS, or REFUTED
- Claims table: claim → evidence → verified / unverified / contradicted
- Fraud findings, or none found
- Evidence: commands run and actual output
- Not audited and remaining risk

## Anti-patterns

- Accepting the report's own checklist as proof that checks ran.
- Reading code to "confirm" a claim that could be re-run.
- Concluding a commit or artifact does not exist after checking only the current branch.
- Auditing only the claims made while ignoring unclaimed changes in the diff.
- Softening a REFUTED verdict because the work looks mostly right.

## Attribution

Verdict model and fraud-hunting order adapted from `fable-judge` in [fable-method](https://github.com/Sahir619/fable-method) (MIT).
