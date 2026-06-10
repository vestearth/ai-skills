# Games Labs Mobile Contract Handoff Playbook

Use this playbook when answering mobile or web contract questions for Games Labs APIs, especially when the question is whether backend work is required.

This playbook is domain-specific. For generic API compatibility review, use `skills/api-contract-review/SKILL.md`. For broad Games Labs API review, use `skills/games-labs-api-review/SKILL.md`.

## Use When

- A mobile or web handoff needs endpoint, request, response, status, or error details.
- The user asks whether a proposed answer matches the current system.
- A feature may already have partial API support but not full business-flow support.
- UI behavior depends on status values, claim behavior, preview fields, or persisted fields.
- Postman, README, protobuf, gateway, or mobile examples may be stale or incomplete.

## Source Of Truth Checklist

Verify repository evidence before answering:

- Page/composable/client code that consumes the API.
- Service handler, usecase, repository, and protobuf contract.
- `api-gateway` route and generated grpc-gateway behavior when HTTP is involved.
- Existing Postman/docs examples when the user asks about handoff text.
- Runtime, tests, logs, or task artifacts when behavior is disputed.

Treat source code and runtime evidence as stronger than summaries, old handoff notes, or memory.

## Process

1. State the concrete question first: is this asking about API existence, UI wiring, persisted data, or end-to-end business flow?
2. Identify the current contract from `.proto`, gateway mapping, handler, and client usage.
3. Separate preview-only values from persisted API fields. Examples include locally generated previews, `FileReader` values, or frontend-only derived labels.
4. Check whether the backend stores, returns, and validates the field or behavior the client expects.
5. Map client statuses explicitly. Avoid asking mobile/web to infer business state from unrelated fields when the backend can return a stable status.
6. Confirm error behavior: business errors must be distinguishable from system failures, and client UX must not depend on free-text messages.
7. Check rollout compatibility: old clients with new server, new clients with old server, and rollback after partial deployment.
8. Produce a handoff answer that says what works now, what is missing, and which repo owns the missing work.

## Handoff Output

Include:

- Bottom line: backend change required, client-only change, docs-only change, or already supported.
- Endpoint and method.
- Request shape and required fields.
- Response shape and status mapping.
- Error codes and UX meaning.
- Persisted fields versus preview/client-only fields.
- Rollout and backward compatibility notes.
- Required docs, Postman, or protobuf updates.

## Anti-patterns

- Saying "API exists" when the end-to-end business flow is not supported.
- Treating preview-only client data as persisted backend contract.
- Answering from a previous task summary without reading current `.proto`, handler, gateway, and client code.
- Requiring mobile/web to duplicate backend business rules from raw flags.
- Relying on response message text for UX routing.
