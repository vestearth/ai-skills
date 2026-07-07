# Design - `games-labs-implementation-status` skill

Date: 2026-07-07
Status: Approved (brainstorming) - pending implementation plan
Base: builds on `games-labs-api-review`, `verification-loop`, `search-first`, and Games Labs deploy evidence

## Purpose

Answer recurring Games Labs mobile/backend follow-up questions such as:

- "implemented yet?"
- "do we need a code fix before replying?"
- "is QA seeing old behavior because deployment is stale?"
- "what should I reply in English?"

The skill is for follow-up status checks, not for broad API redesign or normal code review.

## Approach (chosen: thin, reply-first specialist)

Create a new shared skill at `ai-skills/skills/games-labs-implementation-status/`.

It owns a narrow workflow:

1. classify the ask
2. inspect source evidence
3. inspect verification evidence
4. inspect deploy/runtime evidence when relevant
5. decide the reply posture
6. draft the reply first

It should stay thin and reuse existing skills/playbooks instead of duplicating them.

| Owns | Reuses |
| --- | --- |
| Follow-up status classification | `games-labs-api-review` for contract-safe reasoning |
| Reply-first output contract | `search-first` for targeted discovery |
| Decision states for "reply now vs fix first vs verify deploy" | `verification-loop` for claim discipline |
| Evidence checklist for code/test/deploy | Games Labs playbooks such as `mobile-contract-handoff` and `ecs-deploy` |

## Why A New Skill Instead Of Extending The Existing Playbook

This pattern is now a distinct trigger, not just a sub-step of API review:

- The input is often a pasted follow-up message from QA, Dev, or Mobile.
- The desired output is usually a sendable reply, not a review memo.
- The user also asks short meta-questions like "ตอบว่าอะไรดี", "implemented ยัง", and "ต้องแก้ก่อนตอบไหม".
- The workflow must explicitly separate:
  - implemented in code
  - verified by tests
  - deployed in the target environment

That trigger is narrow enough to justify a dedicated skill without overloading `games-labs-api-review`.

## Trigger Shape

The frontmatter description should trigger on both:

- external follow-up text from QA, Dev, Mobile, PM, or reviewers
- short operator prompts such as:
  - "what should I reply?"
  - "implemented yet?"
  - "do we need to fix code first?"
  - "is this deployed yet?"

Scope is Games Labs-specific mobile/backend follow-up only.

## Decision Model

The skill must force one of four explicit outcomes:

1. `reply-now`
   - code already supports the asked behavior
   - evidence is sufficient to answer
   - deployment may still need separate confirmation, but no code change is needed before replying
2. `fix-first`
   - current source disproves the requested behavior or shows missing implementation
   - do not draft a misleading "already implemented" reply
3. `check-deploy`
   - code and tests support the behavior, but the environment state is not yet verified
   - reply must separate "implemented in code" from "running in QA/staging"
4. `not-enough-evidence`
   - available evidence is insufficient or conflicting
   - reply must stay conditional and avoid false certainty

These four outcomes are the heart of the skill.

## Evidence Order

The skill must check evidence in this order:

1. current repository source
2. focused tests or CI evidence that proves the path
3. commit/PR history when useful to explain when the behavior changed
4. deploy/runtime evidence for the target environment when the ask is environment-specific
5. old summaries or memory only as navigation aids

It must never answer a repo-specific status question from memory alone.

## Workflow

1. Restate the concrete question.
   - Is this asking about code status, test proof, deployment state, or the exact English reply?
2. Find the owning endpoint, service path, or UI data source.
3. Read the source files that prove or disprove the behavior.
4. Run or inspect the smallest relevant verification.
5. If the ask mentions QA, staging, production, or "still seeing the issue", inspect deploy/runtime evidence when feasible.
6. Classify the result into one of the four decision states.
7. Draft the reply first.
8. Append a short internal evidence note for the operator.

## Output Contract

Default output is `reply-first, evidence-backed`.

The skill should produce:

1. **Reply draft**
   - short English message the user can send immediately
   - cautious wording when deploy is unverified
2. **Decision**
   - one of: `reply-now`, `fix-first`, `check-deploy`, `not-enough-evidence`
3. **Evidence note**
   - endpoint/file/test/deploy facts that justify the reply
4. **Next action**
   - only when needed, such as "confirm QA build version" or "patch code before replying"

## Boundaries

Do not use this skill for:

- broad API design or compatibility review with no follow-up status question
- normal bug debugging where the user wants a fix more than a response draft
- non-Games Labs projects
- generic release approval or production incident handling

Route those cases to the existing domain skill instead.

## File Layout

```text
ai-skills/skills/games-labs-implementation-status/
  SKILL.md
```

Start with SKILL.md only. Add `references/` later only if repeated cases show that the
core file is getting too large or needs reusable examples.

## Validation

Minimum acceptance before calling the skill ready:

- `scripts/validate-skills.sh` passes
- frontmatter clearly distinguishes this skill from `games-labs-api-review`
- the process explicitly separates "implemented in code" from "deployed in QA/staging"
- the output contract leads with a sendable reply, not an internal analysis block

## First Iteration Examples

The initial version should work well for questions like:

- "Just following up on this. May I know if aligning with DB will be implemented?"
- "QA still sees the old status. Is this already deployed?"
- "Can I tell Mobile this is already supported?"
- "Do we need to patch backend first, or can I reply now?"
