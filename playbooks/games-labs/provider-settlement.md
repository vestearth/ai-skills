# Games Labs Provider Settlement Playbook

Use this playbook when reviewing, debugging, or planning game provider settlement flows across Games Labs services.

This playbook is domain-specific. For provider callback mechanics, use `skills/vendor-integration/SKILL.md`. For service boundaries, use `skills/microservice-boundary-review/SKILL.md`.

## Use When

- Provider bet, payout, cancel, rollback, round-close, or settlement callbacks affect wallet/order/game state.
- Turnover, mission progress, commission, or reconciliation depends on settled rounds.
- A non-AFB provider needs to join an existing AFB-oriented settlement path.
- Duplicate callbacks, delayed callbacks, or partial settlement creates balance or mission inconsistencies.
- The user asks whether settlement is end-to-end supported rather than merely accepted by an API.

## Source Of Truth Checklist

Verify:

- Provider callback contract, request/response samples, headers, and signature input.
- Provider service handler and idempotency keys.
- Game service round lifecycle and settlement entrypoint.
- Wallet/order transaction writes and rollback behavior.
- Mission or turnover event publication and consumers.
- RabbitMQ routing keys, payloads, retry/DLQ behavior, and logs.
- Reconciliation scripts, dashboards, or manual repair runbooks when available.

## Process

1. Draw the actual flow from provider callback to final business state. Name each service owner and write path.
2. Identify the business key for idempotency: provider transaction id, round id, player id, game code, or settlement id.
3. Check balance impact: debit, credit, cancel, rollback, and duplicate handling must be deterministic.
4. Check round lifecycle: open, active, settled, cancelled, or failed states must not allow double settlement.
5. Check settlement amount semantics. Distinguish bet amount, win amount, net amount, settled amount, turnover amount, and refund amount.
6. Check downstream effects: mission progress, turnover, VIP, rebate, logs, and reports should use the correct settled signal.
7. Check async delivery: event schema, routing, retries, DLQ, and consumer idempotency must match the settlement guarantee.
8. Check reconciliation: failed or delayed provider callbacks need a way to compare provider state against internal state.
9. Produce a verdict that separates callback acceptance, wallet correctness, round lifecycle correctness, and downstream business-flow support.

## Review Output

Include:

- Flow map and affected services.
- Settlement idempotency key.
- Balance and round lifecycle verdict.
- Downstream event and mission/turnover impact.
- Duplicate, retry, rollback, and reconciliation behavior.
- Missing provider evidence.
- Required tests or production verification.

## Anti-patterns

- Treating a provider callback endpoint as proof that settlement is complete.
- Mixing win amount, net amount, turnover amount, and settled amount without naming each one.
- Publishing mission or turnover events before wallet/round settlement is durable.
- Assuming provider callbacks are exactly-once or in order.
- Extending an AFB-specific path to another provider without checking provider-specific transaction semantics.
