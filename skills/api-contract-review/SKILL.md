---
name: api-contract-review
description: Use when changing APIs, protobuf messages, gRPC services, grpc-gateway mappings, generated artifacts, field numbers, enums, client/server contract behavior, or frontend/mobile integrations.
---

# API Contract Review

## Use When

- Reviewing generic API, protobuf, grpc-gateway, frontend, mobile, or client integration changes.
- A `.proto` file, gRPC request/response/service/method/enum/status, grpc-gateway HTTP mapping, or generated protobuf artifact changes.
- Response shape, status, error behavior, or client compatibility may change.
- A public or mobile field is missing, renamed, or shaped differently than expected, including routes served through gRPC/protobuf or grpc-gateway.
- Mobile, web, backend, or partner clients depend on the contract.

## Do Not Use When

- The API is Games Labs-specific; prefer `games-labs-api-review`.
- The task is only provider callback behavior; prefer `vendor-integration`.
- The change is purely internal and does not affect API response, protobuf, gateway, generated code, or client behavior.

## Goal

Protect existing clients and wire compatibility, and make integration predictable, by keeping API and protobuf contracts explicit, stable, and reviewable.

## Required Inputs

- API route, request shape, response shape, and error behavior.
- Changed `.proto` files, generated artifacts, and grpc-gateway annotations when applicable.
- Existing clients, gateways, handlers, and service implementations that use the contract, plus their expectations and rollout constraints.
- Compatibility notes, migration plan, or release order when fields/methods are removed or reinterpreted.
- Build/test output showing protobuf generation and service compilation when applicable.

## Process

Check backward compatibility:

- Will existing clients still work?
- Are removed and renamed fields avoided, or otherwise reserved and migrated?

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

Check protobuf and gRPC wire compatibility (when the route is served through protobuf/gRPC or grpc-gateway):

- Identify the contract surface: package, service, methods, request/response messages, enums, gateway annotations, and generated files.
- Are field numbers never reused, removed fields reserved, and existing field types not changed incompatibly?
- Do enum numeric values stay stable, and do new enum values account for client default/fallback behavior?
- Are defaults, optional fields, status meanings, error codes, and idempotency documented for clients (semantic compatibility)?

Check grpc-gateway mapping:

- Do HTTP method, path, body mapping, query fields, response shape, and error translation still match expected clients?
- Is the public response shape confirmed against the protobuf message and gateway mapping clients actually receive, not a service struct or mapper?

Check generated artifacts:

- Does protobuf need regeneration?
- Are generated Go/gateway files refreshed when required and never hand-edited?

Check rollout safety:

- Do old clients tolerate new server responses, and new clients tolerate old server responses during deployment?
- Do breaking changes have versioning, migration steps, and a release order?

Verify:

- Run the smallest relevant build/test command showing protobuf generation and service compilation, and record exact evidence.

## Output Format

- Contract surface reviewed
- Breaking changes
- Client and gateway impact
- Compatibility verdict
- Generated artifact status
- Migration plan
- Required testing and verification evidence
- Required follow-up

## Anti-patterns

- Renaming or removing fields without a client migration plan.
- Reusing deleted field numbers.
- Renaming fields and assuming JSON or gateway clients are unaffected.
- Adding enum values without checking client default/fallback behavior.
- Relying on message text for client behavior.
- Adding implicit statuses that clients must infer from unrelated fields.
- Updating generated code by hand.
- Reviewing service code while ignoring the `.proto` source of truth.
- Confirming a public response shape from a service struct or mapper without checking the protobuf message and gateway mapping that clients actually receive.
- Updating service code while leaving docs, protobuf, gateway, or examples stale.
