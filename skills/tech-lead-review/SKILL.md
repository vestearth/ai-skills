---
name: tech-lead-review
description: Use when evaluating architecture, implementation plans, cross-team impact, ownership, risk, scalability, or long-term maintainability.
---

# Tech Lead Review

Before discussing implementation details, answer the higher-level questions.

## Use When

- Evaluating architecture, implementation plans, cross-team impact, ownership, risk, scalability, or long-term maintainability.
- A change may affect multiple services, clients, teams, contracts, or operational responsibilities.
- You need to decide whether to keep implementation simple, escalate design, or investigate first.

## Do Not Use When

- The task is only an active bug with unknown root cause; prefer `debugging`.
- The task is only service-boundary ownership; prefer `microservice-boundary-review`.
- The task is only merge readiness; prefer `code-review`.

## Goal

Choose the right level of design rigor by clarifying ownership, dependencies, risks, operations, scalability, and decision criteria.

## Required Inputs

- Feature, plan, incident, or change description.
- Affected services, clients, teams, contracts, data, or workflows.
- Known risks, rollout needs, monitoring, rollback, and migration constraints when available.

## Process

Review ownership:

- Who owns this feature?
- Who owns the data?
- Who owns the business rule?

Review dependencies:

- Which services depend on this?
- Which teams depend on this?
- Which clients depend on this?

Review risk:

- What breaks if this changes?
- What is the rollback plan?
- What is the migration plan?

Review operations:

- How will this be monitored?
- How will failures be detected?
- How will incidents be investigated?

Review scalability:

- Will traffic growth change the design?
- Is coupling increasing?
- Is ownership becoming unclear?

Prefer simple implementation when:

- Ownership is clear.
- The blast radius is low.
- Rollback is easy.
- Data migration is not required.
- Existing monitoring already covers the failure modes.
- API, mobile, web, provider, and event contracts do not change.

Escalate design when:

- Multiple services own the same concept.
- Rollback requires data migration or manual repair.
- Monitoring is missing for the new failure modes.
- Mobile, web, provider, API, gRPC, or event contracts change.
- The change introduces cross-service write paths or shared mutable state.
- The team cannot name the owner of the data, business rule, and workflow.

Choose investigation first when:

- The root cause is still unknown.
- Contract behavior differs between docs, code, and production logs.
- The team is relying on memory or summaries instead of repository evidence.

## Output Format

- Recommendation
- Risks
- Tradeoffs
- Rollback considerations
- Monitoring considerations

## Anti-patterns

- Treating unclear ownership as a detail to resolve during implementation.
- Choosing a complex design when rollback is easy and blast radius is low.
- Ignoring monitoring gaps for new failure modes.
- Approving cross-service write paths without naming owners and rollback behavior.
