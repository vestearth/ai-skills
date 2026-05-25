# Games Labs API Review Playbook

Use this playbook when a Games Labs API change affects mobile, web, provider, missions, wallet, VIP, store, user-facing flows, or `api-gateway`.

This playbook is domain-specific. For generic API review, use `skills/api-contract-review/SKILL.md`.

## Contract Shape

- Keep response fields backward compatible whenever possible.
- Add optional fields instead of renaming or removing existing fields.
- Prefer explicit status fields over implicit client inference.
- Document defaults for new fields.
- Keep list item shapes stable across overview, detail, and claim endpoints.

## Status Strategy

Prefer stable, client-friendly status values.

Common examples:

- `not_started`
- `in_progress`
- `claimable`
- `claimed`
- `inactive`
- `upcoming`
- `expired`

Avoid status values that expose backend implementation names or require mobile/web to duplicate business rules.

## Error Strategy

- Business errors must be distinguishable from system failures.
- Error codes must be stable enough for client UX routing.
- Do not rely on message text for client behavior.
- Include enough context for debugging without leaking secrets or internal-only data.

## Idempotency

- Claim, wallet, payment, mission, reward, and provider callback flows must define duplicate-request behavior.
- Retried requests should either be safe no-ops or return the same business result.
- If idempotency keys are required, document where they come from and how long they are valid.

## Gateway And Protobuf

- Update `.proto` first for contract changes.
- Regenerate protobuf and grpc-gateway artifacts.
- Update `api-gateway` mappings when HTTP behavior changes.
- Keep service, gateway, Postman/docs, and mobile handoff examples aligned.

## Mobile And Web Handoff

Include:

- Endpoint and method
- Request shape
- Response shape
- Status mapping
- Claim/refresh behavior
- Error codes and UX meaning
- Any fields mobile/web should ignore for now

## Rollout Checks

- Can old clients safely call the new endpoint?
- Can new clients tolerate old server responses during rollout?
- Is rollback safe without data migration?
- Are dashboards/logs sufficient to see client-impacting failures?

## Review Output

- Mobile impact
- Web impact
- API/gateway impact
- Breaking changes
- Idempotency behavior
- Required docs or Postman updates
- Recommended rollout plan
