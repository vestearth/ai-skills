---
name: microservice-boundary-review
description: Use when changing ownership, service boundaries, gRPC contracts, or event flows.
---

# Microservice Boundary Review

## Use When

- Changing service ownership, service boundaries, gRPC contracts, event flows, or cross-service workflows.
- A feature touches multiple services or shared business rules.
- Data ownership, workflow ownership, or communication style is unclear.

## Do Not Use When

- The change is isolated inside one service and ownership is already clear.
- The task is only API shape review; prefer `api-contract-review` or a domain-specific API skill.
- The task is broad architecture review beyond service boundaries; prefer `tech-lead-review`.

## Goal

Keep data, business rules, and workflows owned by clear services with stable communication boundaries.

## Required Inputs

- Services involved and their current ownership responsibilities.
- Relevant gRPC, API, event, repository, or data access paths.
- Failure, retry, and observability expectations when available.

## Process

Answer ownership questions:

- Which service owns the data?
- Which service owns the business rule?
- Which service owns the workflow?

Should communication use:

- gRPC
- Event messaging
- API Gateway

Check:

- Ownership clarity
- Contract stability
- Failure handling
- Retry behavior
- Observability

Reject:

- Cross-service database access
- Shared mutable state
- Duplicated business logic
- Unclear ownership

## Output Format

- Ownership map
- Impacted services
- Risks
- Recommended boundary

## Anti-patterns

- Letting multiple services own the same business rule.
- Adding cross-service database access for convenience.
- Using events or gRPC without defining retry and failure behavior.
- Treating unclear ownership as an implementation detail.
