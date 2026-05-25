---
name: games-labs-api-review
description: Use when reviewing API changes for Games Labs services, mobile integrations, gateway mappings, missions, wallet, VIP, store, provider, or user-facing flows.
---

# Games Labs API Review

## Contract review

- Is the change backward compatible?
- Does the mobile application need changes?
- Does the web application need changes?

## Error strategy

- Are business errors distinguishable?
- Are error codes stable?
- Can clients route UX based on status or error code?

## Status strategy

Prefer explicit status values where appropriate.

Examples:

- not_started
- in_progress
- claimable
- claimed
- inactive
- upcoming
- expired

## Idempotency

- Is duplicate request behavior defined?
- Are idempotency keys documented?

## Gateway and protobuf

- Does protobuf require updates?
- Does grpc-gateway require updates?
- Are generated artifacts updated?

## Output

- Mobile impact
- Web impact
- API impact
- Breaking changes
- Recommended rollout plan
