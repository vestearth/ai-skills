---
name: deslop
description: Use when sweeping a finished diff or branch for AI-generated slop — redundant comments, defensive wrappers, premature abstractions, or unrequested scaffolding — before commit, review, or handoff.
---

# Deslop

## Use When

- A change is functionally complete and the diff should be cleaned before commit or review.
- Reviewing output produced by a subagent or another AI lane (Codex, Cursor) before accepting it.
- A diff feels larger or more complex than the request required.
- The user asks to remove slop, boilerplate, over-engineering, or unrequested additions.

## Do Not Use When

- The change is still in design or mid-implementation; use `minimal-change-review` to scope it instead.
- The goal is finding bugs or merge readiness; use `code-review`.
- The "defensive" code sits at a real trust boundary (user input, external API, cross-service payloads).
- The repository's established style genuinely requires the pattern in question.

## Goal

Remove AI-generated noise from a finished diff with surgical, behavior-preserving edits, so the committed change is no larger than the request required.

## Required Inputs

- The full diff against the base branch or ref.
- The original request or task scope the change was meant to satisfy.
- The project's test, build, or lint commands for verification.

## Process

1. Generate the complete diff against the base so every added line is visible.
2. Scan added lines for slop patterns:
   - Comments that restate what the code already says.
   - try/catch, nil/undefined checks, or fallbacks on trusted internal paths.
   - Type casts or assertions added only to silence the type checker.
   - Single-use helpers, interfaces, or abstractions with one caller.
   - Deep nesting where an early return is the local idiom.
   - Backwards-compatibility shims no caller needs.
   - Files, features, config, or scaffolding beyond the requested scope.
   - Comment or documentation churn on lines the change did not otherwise touch.
3. For each candidate, confirm removal is behavior-preserving and the code is truly unused before deleting; keep anything with a caller or a boundary justification.
4. Apply surgical edits that remove only the slop; do not restyle or refactor surviving code.
5. Re-run the project's tests, build, or lint to confirm behavior is unchanged.
6. Report what was removed with locations and evidence; flag anything suspicious but kept.

## Output Format

- Slop inventory: pattern, file:line, and why it qualifies
- Edits applied and lines removed
- Items kept deliberately, with the boundary or caller that justifies them
- Verification evidence (test/build/lint output)
- One-to-three sentence summary of the cleanup

## Anti-patterns

- Restyling or refactoring code beyond removing slop.
- Removing validation or error handling at genuine trust boundaries.
- Fixing unrelated bugs inside the same sweep instead of flagging them.
- Adding an abstraction to "clean up" three similar lines — three similar lines beat a premature abstraction.
- Claiming the sweep is behavior-preserving without running verification.
