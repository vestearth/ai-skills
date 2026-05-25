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

## Output

- Recommendation
- Risks
- Tradeoffs
- Rollback considerations
- Monitoring considerations
