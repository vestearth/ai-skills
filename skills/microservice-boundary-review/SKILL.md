---
name: microservice-boundary-review
description: Use when changing ownership, service boundaries, gRPC contracts, or event flows.
---

# Microservice Boundary Review

## Questions

- Which service owns the data?
- Which service owns the business rule?
- Which service owns the workflow?

## Communication review

Should communication use:

- gRPC
- Event messaging
- API Gateway

## Check

- Ownership clarity
- Contract stability
- Failure handling
- Retry behavior
- Observability

## Reject

- Cross-service database access
- Shared mutable state
- Duplicated business logic
- Unclear ownership

## Output

- Ownership map
- Impacted services
- Risks
- Recommended boundary
