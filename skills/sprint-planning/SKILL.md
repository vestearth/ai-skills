---
name: sprint-planning
description: Use when turning goals, backlog items, roadmap themes, incidents, or stakeholder requests into bounded sprint scope with acceptance criteria, dependencies, risks, and verification plans.
---

# Sprint Planning

## Use When

- Planning a sprint, iteration, milestone, or focused delivery window.
- Turning rough goals into scoped tasks with acceptance criteria.
- Sequencing work across dependencies, reviewers, releases, or cross-team handoffs.
- Deciding what to include, defer, split, or escalate.
- Turning PM or stakeholder requests into bounded task batches, agent-ready work items, or sprint handoff scope while leaving orchestration mechanics to the project tool.

## Do Not Use When

- The task is technical architecture review; use `tech-lead-review`.
- The task is a single implementation review; use the relevant code/release skill.
- The team is asking for long-term product strategy rather than sprint execution.

## Goal

Create a sprint plan that is small enough to finish, clear enough to execute, and honest about dependencies, risk, and verification.

## Required Inputs

- Sprint goal or stakeholder request.
- Candidate backlog items, incidents, bugs, or roadmap themes.
- Known capacity, deadlines, owners, dependencies, and blocked work.
- Definition of done, release constraints, or verification requirements.

## Process

1. Define the sprint goal in one sentence and reject work that does not support it.
2. Convert each candidate item into outcome, owner, acceptance criteria, evidence needed, and likely size.
3. Sequence dependencies: unblockers first, shared contracts before downstream work, verification before release.
4. Control WIP: split oversized work, defer unclear work, and keep risky investigation separate from implementation.
5. Identify risks: missing requirements, cross-team dependencies, environment gaps, migrations, and release windows.
6. Define verification: tests, demos, review evidence, monitoring, rollout checks, and who signs off.
7. Produce a plan with committed scope, stretch scope, deferred scope, and explicit carryover rules.

## Output Format

- Sprint goal
- Committed scope
- Stretch scope
- Deferred scope
- Dependencies and blockers
- Risks and mitigations
- Verification and acceptance criteria
- Review/release plan

## Anti-patterns

- Filling capacity with work that does not support the sprint goal.
- Mixing investigation and delivery without an explicit decision point.
- Accepting vague tasks without testable acceptance criteria.
- Ignoring blocked dependencies until the end of the sprint.
- Treating carryover as harmless instead of a planning signal.
