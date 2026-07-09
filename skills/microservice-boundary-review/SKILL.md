---
name: microservice-boundary-review
description: Use when deciding ownership or service boundaries involving gRPC contracts, event flows, cross-service workflows, shared business rules, data ownership, or communication style.
---

# Microservice Boundary Review

## Use When

- Changing service ownership, service boundaries, gRPC contracts, event flows, or cross-service workflows.
- A feature touches multiple services or shared business rules.
- Data ownership, workflow ownership, or communication style is unclear.

## Do Not Use When

- The change is isolated inside one service and ownership is already clear.
- The task is only API shape review; prefer `api-contract-review` or a domain-specific API skill.
- The task is protobuf field, gateway mapping, generated artifact, or wire-compatibility detail after the boundary is chosen; use `grpc-contract-review`.
- The task is event schema, routing key, retry, DLQ, idempotency, or consumer rollout detail after the boundary is chosen; use `rabbitmq-event-review`.
- The task is broad architecture review beyond service boundaries; prefer `tech-lead-review`.

## Goal

Keep data, business rules, and workflows owned by clear services with stable communication boundaries.

## Required Inputs

- Services involved and their current ownership responsibilities.
- Relevant gRPC, API, event, repository, or data access paths.
- Failure, retry, and observability expectations when available.

## Process

1. Map ownership — name the owning service for each axis: the data, the business rule, and the workflow (they may be different services). If ownership of any axis is shared or unclear, stop and resolve it before designing the boundary.
2. Choose the communication style by need:
   - The caller needs an immediate, consistent answer → gRPC (synchronous). Defer protobuf message/field and wire-compatibility details to `grpc-contract-review`.
   - The reaction can be eventually consistent or fanned out, and the producer must not block on consumers → event messaging. Defer schema, routing keys, retries, and delivery semantics to `rabbitmq-event-review`.
   - The path is external or client-facing and aggregates/exposes a service → API Gateway.
3. Check boundary health for each cross-service call — ownership clarity, contract stability, failure handling, retry behavior, and observability.
4. Reject boundary violations and require a fix before approval — cross-service database access, shared mutable state, duplicated business logic, or unclear ownership.

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
