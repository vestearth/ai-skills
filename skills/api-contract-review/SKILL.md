---
name: api-contract-review
description: Use when changing APIs, protobuf contracts, grpc-gateway routes, or frontend/mobile integrations.
---

# API Contract Review

## Goals

Protect existing clients and make integration predictable.

## Check

### Backward compatibility

- Will existing clients still work?
- Are removed fields avoided?
- Are renamed fields avoided?

### Error handling

- Are error codes stable?
- Can clients distinguish business errors from system failures?

### Idempotency

- Is duplicate request behavior defined?
- Are retries safe?

### Response shape

- Are new fields optional?
- Are defaults documented?

### Mobile and web impact

- Does UI mapping change?
- Are new statuses required?

### Proto and gateway impact

- Does protobuf need regeneration?
- Does grpc-gateway mapping change?

## Output

- Breaking changes
- Client impact
- Migration plan
- Required testing
