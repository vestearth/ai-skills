---
name: api-contract-review
description: Use when changing APIs, protobuf contracts, grpc-gateway routes, or frontend/mobile integrations outside Games Labs or when no narrower domain skill applies.
---

# API Contract Review

## Use When

- Reviewing generic API, protobuf, grpc-gateway, frontend, mobile, or client integration changes.
- A more specific domain skill such as `games-labs-api-review` or `grpc-contract-review` does not fully apply.
- Response shape, status, error behavior, or client compatibility may change.

## Do Not Use When

- The API is Games Labs-specific; prefer `games-labs-api-review`.
- The change is primarily protobuf/gRPC/gateway compatibility; prefer `grpc-contract-review`.
- The task is only provider callback behavior; prefer `vendor-integration` or `seamless-provider-review`.

## Goal

Protect existing clients and make integration predictable.

## Required Inputs

- API route, request shape, response shape, and error behavior.
- Relevant protobuf/gateway/docs/client examples when applicable.
- Existing client expectations or rollout constraints when available.

## Process

Check backward compatibility:

- Will existing clients still work?
- Are removed fields avoided?
- Are renamed fields avoided?

Check error handling:

- Are error codes stable?
- Can clients distinguish business errors from system failures?

Check idempotency:

- Is duplicate request behavior defined?
- Are retries safe?

Check response shape:

- Are new fields optional?
- Are defaults documented?

Check mobile and web impact:

- Does UI mapping change?
- Are new statuses required?

Check proto and gateway impact:

- Does protobuf need regeneration?
- Does grpc-gateway mapping change?

## Output Format

- Breaking changes
- Client impact
- Migration plan
- Required testing

## Anti-patterns

- Renaming or removing fields without a client migration plan.
- Relying on message text for client behavior.
- Adding implicit statuses that clients must infer from unrelated fields.
- Updating service code while leaving docs, protobuf, gateway, or examples stale.
