---
name: grpc-contract-review
description: Use when changing protobuf messages, gRPC services, grpc-gateway mappings, generated artifacts, field numbers, enums, or client/server contract behavior.
---

# gRPC Contract Review

## Use When

- A `.proto` file changes.
- A gRPC request, response, service, method, enum, or status changes.
- grpc-gateway HTTP mappings or generated protobuf artifacts change.
- Mobile, web, backend, or partner clients depend on the contract.
- A public or mobile field is missing, renamed, or shaped differently than expected and the route is served through gRPC/protobuf or grpc-gateway.

## Do Not Use When

- The change is purely internal and does not affect protobuf, gateway, generated code, or client behavior.
- The task is broad API review without gRPC/protobuf impact; use `api-contract-review`.
- The task is Games Labs API-specific; use `games-labs-api-review` first, then this skill for protobuf details.

## Goal

Protect wire compatibility and client rollout safety while keeping protobuf contracts explicit, stable, and reviewable.

## Required Inputs

- Changed `.proto` files and generated artifacts.
- Existing clients, gateways, handlers, and service implementations that use the changed contract.
- Compatibility notes, migration plan, or release order if fields/methods are removed or reinterpreted.
- Build/test output showing protobuf generation and service compilation.

## Process

1. Identify the contract surface: package, service, methods, request/response messages, enums, gateway annotations, and generated files.
2. Check wire compatibility: field numbers are not reused, existing field types are not changed incompatibly, removed fields are reserved, and enum numeric values remain stable.
3. Check semantic compatibility: defaults, optional fields, status meanings, error codes, and idempotency behavior are documented for clients.
4. Check gateway impact: HTTP method, path, body mapping, query fields, response shape, and error translation still match expected clients.
5. Check generated artifacts: generated Go/gateway files are refreshed when required and not manually edited.
6. Check rollout safety: old clients tolerate new server responses, new clients tolerate old server responses during deployment, and breaking changes have versioning or migration steps.
7. Verify with the smallest relevant build/test command and record exact evidence.

## Output Format

- Contract surface reviewed
- Compatibility verdict
- Client and gateway impact
- Breaking changes or migration requirements
- Generated artifact status
- Verification evidence
- Required follow-up

## Anti-patterns

- Reusing deleted field numbers.
- Renaming fields and assuming JSON clients are unaffected.
- Adding enum values without checking client default/fallback behavior.
- Updating generated code by hand.
- Reviewing service code while ignoring the `.proto` source of truth.
- Confirming a public response shape from a service struct or mapper without checking the protobuf message and gateway mapping that clients actually receive.
