---
name: rabbitmq-event-review
description: Use when changing RabbitMQ publishers, consumers, exchanges, queues, routing keys, event schemas, retries, dead-letter behavior, or asynchronous cross-service flows.
---

# RabbitMQ Event Review

## Use When

- A service publishes or consumes RabbitMQ events.
- Event payload shape, routing key, exchange, queue, binding, retry, or dead-letter behavior changes.
- A new asynchronous workflow is introduced between services.
- A consumer needs idempotency, ordering, replay, or failure-handling review.
- Games Labs mission, progress, reward, or status behavior depends on RabbitMQ events; pair this with `playbooks/games-labs/missions-events.md`.

## Do Not Use When

- The change is synchronous gRPC or HTTP only; use `api-contract-review`.
- The task is only infrastructure deployment without event behavior; use `release-checklist` or `datadog-observability` as appropriate.
- The event is an implementation detail with no cross-service consumer.

## Goal

Make event-driven behavior safe under retries, duplicates, partial failure, version drift, and consumer rollout.

## Required Inputs

- Publisher and consumer code.
- Event schema or payload examples.
- Exchange, queue, routing key, binding, retry, and DLQ configuration.
- Idempotency key or deduplication behavior.
- Logs, tests, or operational evidence for failure and retry paths.

## Process

1. Map ownership: identify the source service, event owner, consumers, and business rule owner.
2. Review schema stability: added fields are optional, removed/renamed fields are avoided, and consumers can tolerate unknown or missing fields.
3. Review routing: exchange type, routing key, queue binding, tenant/environment separation, and naming are intentional.
4. Review delivery semantics: duplicate messages, out-of-order messages, retry intervals, poison messages, and DLQ handling are defined.
5. Review idempotency: each consumer can safely process retries using a stable event id, transaction id, or business key.
6. Review observability: publish/consume failures, retry counts, DLQ depth, and consumer lag are visible in logs/metrics.
7. Verify with focused tests or documented manual evidence for publisher, consumer, retry, and failure paths.

## Output Format

- Event ownership map
- Publisher and consumer impact
- Schema compatibility verdict
- Retry/idempotency behavior
- DLQ and failure handling
- Observability coverage
- Verification evidence

## Anti-patterns

- Treating RabbitMQ delivery as exactly-once.
- Changing event names or payloads without checking all consumers.
- Publishing business-critical events without stable ids.
- Retrying poison messages forever without DLQ or alerting.
- Using event payloads to share mutable state between services.
