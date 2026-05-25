---
name: tech-lead-review
description: Use when evaluating architecture, implementation plans, cross-team impact, ownership, risk, scalability, or long-term maintainability.
---

# Tech Lead Review

Before discussing implementation details, answer the higher-level questions.

## Ownership

- Who owns this feature?
- Who owns the data?
- Who owns the business rule?

## Dependencies

- Which services depend on this?
- Which teams depend on this?
- Which clients depend on this?

## Risk

- What breaks if this changes?
- What is the rollback plan?
- What is the migration plan?

## Operations

- How will this be monitored?
- How will failures be detected?
- How will incidents be investigated?

## Scalability

- Will traffic growth change the design?
- Is coupling increasing?
- Is ownership becoming unclear?

## Decision Criteria

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

## Output

- Recommendation
- Risks
- Tradeoffs
- Rollback considerations
- Monitoring considerations
