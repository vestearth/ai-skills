# Games Labs Missions Events Playbook

Use this playbook when mission progress, milestones, daily missions, or reward state depends on service events.

This playbook is domain-specific. For generic RabbitMQ review, use `skills/rabbitmq-event-review/SKILL.md`. For API handoff behavior, use `playbooks/games-labs/mobile-contract-handoff.md`.

## Use When

- Daily mission progress, force-complete behavior, reward claiming, or milestone status is wrong or unclear.
- A service publishes player activity, settlement, wallet, order, or gameplay events consumed by Missions.
- `player.activity.v1` or another event schema changes.
- A Postman collection, README, or mobile handoff must describe mission status and restore behavior.
- Progress is missing and the root cause could be producer, broker, consumer, schema, or business rule mismatch.

## Source Of Truth Checklist

Verify:

- Missions protobuf/API contract and status values.
- Mission creation/config rules and mission type aliases.
- Publisher event schema, routing key, and payload fields.
- Consumer handler, filtering rules, idempotency, and progress update code.
- RabbitMQ deploy configuration and secret references.
- Runtime logs, DLQ/consumer errors, or task artifacts for the affected player/mission.
- Postman/docs examples when the handoff is user-facing.

## Process

1. Define the symptom: no progress, wrong amount, wrong status, duplicate progress, claim blocked, or restore data mismatch.
2. Identify the expected mission rule: event type, mission type, required amount, status transition, and reward condition.
3. Trace the event path: producer code, exchange/routing key, payload, broker configuration, consumer binding, handler, and database update.
4. Check schema compatibility. The producer and consumer must agree on event name, version, player id, amount, currency, game/provider identifiers, and timestamp semantics.
5. Check idempotency. Retries or duplicate events must not double-count unless the mission rule explicitly allows it.
6. Check status mapping. Client-facing statuses should be stable and not require mobile/web to infer hidden backend state.
7. Check restore and quote behavior. Restore responses should match the current mission state and should not invent progress from client-local values.
8. Check force-complete behavior separately from normal event progress. It must be auditable and should not hide broken event delivery.
9. Report whether the failure is publisher-side, broker/deploy, consumer-side, mission config, API/status handoff, or unknown due to missing evidence.

## Debug Output

Include:

- Symptom and affected mission/player scope.
- Expected event and mission rule.
- Producer evidence.
- Broker/routing evidence.
- Consumer and database evidence.
- Status/restore/handoff impact.
- Root cause or remaining unknowns.
- Verification command, log query, or test needed next.

## Anti-patterns

- Debugging Missions from API response shape only while ignoring event delivery.
- Treating force-complete as proof that normal event progress works.
- Updating a publisher event without checking all Missions consumers.
- Counting retries twice because no stable event id or business key is used.
- Letting mobile infer mission status from raw progress fields when the backend can return a status.
