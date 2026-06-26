---
name: games-labs-api-review
description: Use when reviewing API changes for Games Labs services, mobile integrations, gateway mappings, missions, wallet, VIP, store, provider, or user-facing flows.
---

# Games Labs API Review

Use this skill as the routing front door for Games Labs API review. The deeper, domain-specific operating rules live in `playbooks/games-labs/` — treat the playbooks as the source of truth and this skill as the entry point.

## Playbooks

Read the playbook that matches the change; do not duplicate its content here.

- `playbooks/games-labs/api-review.md` — API conventions: status strategy, error/UX routing, idempotency, gateway/protobuf alignment, rollout.
- `playbooks/games-labs/mobile-contract-handoff.md` — answering mobile/web contract questions and deciding whether backend work is required.
- `playbooks/games-labs/missions-events.md` — debugging mission progress across producer events, RabbitMQ routing, consumers, and client-facing status.
- `playbooks/games-labs/shared-lib-rollout.md` — shared-lib adoption, pseudo-version alignment, and generated-contract drift.
- `playbooks/games-labs/provider-settlement.md` — end-to-end provider settlement (pair with `seamless-provider-review` for callback mechanics).

## Use When

- Reviewing API changes for Games Labs services, mobile integrations, gateway mappings, missions, wallet, VIP, store, provider, or user-facing flows.
- Preparing mobile or web handoff details for a Games Labs API.
- Checking Games Labs-specific status, error, idempotency, protobuf, or gateway behavior.

## Do Not Use When

- The API is not Games Labs-specific; use `api-contract-review`.
- The change is only protobuf compatibility; use `grpc-contract-review` first.
- The task is only a provider callback/signature flow; use `seamless-provider-review`.

## Goal

Protect Games Labs clients and service contracts with clear mobile/web impact, stable statuses, and safe rollout behavior.

## Required Inputs

- Endpoint, method, request shape, response shape, and error behavior.
- Relevant service, gateway, protobuf, Postman/docs, or mobile handoff examples.
- Domain playbook context from `playbooks/games-labs/api-review.md` when the change affects client behavior.

## Process

Review contract impact:

- Is the change backward compatible?
- Does the mobile application need changes?
- Does the web application need changes?

Review error strategy:

- Are business errors distinguishable?
- Are error codes stable?
- Can clients route UX based on status or error code?

Review status strategy:

- Prefer explicit, stable, client-friendly status values over implicit client inference.
- Avoid status values that expose backend implementation names or force mobile/web to duplicate business rules.
- See the Status Strategy section of `playbooks/games-labs/api-review.md` for the canonical guidance and value list.

Review idempotency:

- Is duplicate request behavior defined?
- Are idempotency keys documented?

Review gateway and protobuf impact:

- Does protobuf require updates?
- Does grpc-gateway require updates?
- Are generated artifacts updated?

## Output Format

- Mobile impact
- Web impact
- API impact
- Breaking changes
- Recommended rollout plan

## Anti-patterns

- Asking mobile or web to infer business state from unrelated fields.
- Changing status or error semantics without client handoff notes.
- Updating service behavior while gateway, protobuf, docs, or examples drift.
- Ignoring duplicate request behavior for claim, wallet, mission, or provider flows.
