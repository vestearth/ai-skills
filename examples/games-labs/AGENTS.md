# AGENTS.md — Games Labs Project

This project uses `ai-skills/` for reusable AI engineering guidance and `ai-dev-office/` for optional workflow orchestration.

## Priority

1. User request
2. This project `AGENTS.md`
3. Source code, tests, CI, logs, production evidence, and provider evidence
4. `ai-skills/` guidance
5. Historical notes, summaries, or indexed context

Repository-specific claims require source-code verification.

## Source Of Truth

Repository source code is the source of truth.

SocratiCode is a navigation layer.

When SocratiCode output and repository files conflict, repository files win. After using SocratiCode for discovery, read the relevant files directly before making implementation claims.

## Recommended Layout

```text
project-root/
  AGENTS.md
  .cursor/rules/
  ai-dev-office/
  knowledge-base/
  ai-skills/
```

## Skill Routing

Use the smallest relevant skill:

- Code/file/dependency/scaffold changes: `ai-skills/skills/minimal-change-review/SKILL.md`
- Completion, fix, merge, deploy, or handoff claims: `ai-skills/skills/verification-loop/SKILL.md`
- Unfamiliar repository area: `ai-skills/skills/search-first/SKILL.md`
- Large, stale, or tool-derived context: `ai-skills/skills/context-discipline/SKILL.md`
- Shared code, contracts, schemas, generated code, runtime config, or high-risk paths: `ai-skills/skills/change-impact-analysis/SKILL.md`
- Project memory, decisions, architecture notes, lessons, or flow maps: `ai-skills/skills/knowledge-query/SKILL.md`
- Durable knowledge capture after completed work: `ai-skills/skills/knowledge-capture/SKILL.md`
- Inbox/project note promotion: `ai-skills/skills/knowledge-promote/SKILL.md`
- Knowledge-base source, freshness, publication, or drift review: `ai-skills/skills/knowledge-source-review/SKILL.md`
- Bugs, logs, failed tests, crashes: `ai-skills/skills/debugging/SKILL.md`
- Code review or merge readiness: `ai-skills/skills/code-review/SKILL.md`
- ClickHouse tables, ingestion, queries, retention, or event storage: `ai-skills/skills/clickhouse-io/SKILL.md`
- Games Labs API, gateway, mobile, missions, wallet, VIP, store, provider-facing flows: `ai-skills/skills/games-labs-api-review/SKILL.md`
- Games Labs API domain rules: `ai-skills/playbooks/games-labs/api-review.md`
- Mobile/web contract handoff, persisted-vs-preview fields, status mapping, and "does backend need work?" questions: `ai-skills/playbooks/games-labs/mobile-contract-handoff.md`
- Shared-lib rollout, pseudo-version alignment, generated contract drift, handler message ownership, or cross-repo adoption status: `ai-skills/playbooks/games-labs/shared-lib-rollout.md`
- Provider settlement, round lifecycle, settled amount, turnover, duplicate callbacks, or reconciliation: `ai-skills/playbooks/games-labs/provider-settlement.md`
- Missions event progress, `player.activity.v1`, daily mission status, force-complete, RabbitMQ routing, or restore/quote handoff: `ai-skills/playbooks/games-labs/missions-events.md`
- Seamless provider callbacks, signatures, launch URLs, balance, payout, rounds: `ai-skills/skills/seamless-provider-review/SKILL.md`
- gRPC/protobuf/gateway contract changes: `ai-skills/skills/grpc-contract-review/SKILL.md`
- RabbitMQ events, routing, retries, DLQs: `ai-skills/skills/rabbitmq-event-review/SKILL.md`
- Go service implementation review: `ai-skills/skills/golang-service-review/SKILL.md`
- Dependency, Docker, CI, shared-lib, Go modules: `ai-skills/skills/dependency-guard/SKILL.md`
- Datadog metrics, logs, traces, monitors: `ai-skills/skills/datadog-observability/SKILL.md`
- Architecture, ownership, scalability, cross-team risk: `ai-skills/skills/tech-lead-review/SKILL.md`
- Service ownership or microservice boundaries: `ai-skills/skills/microservice-boundary-review/SKILL.md`
- Release, deploy, rollback, smoke tests: `ai-skills/skills/release-checklist/SKILL.md`
- Sprint or backlog planning: `ai-skills/skills/sprint-planning/SKILL.md`

Compatibility fallback:

- Generic API contract work outside Games Labs-specific rules: `ai-skills/skills/api-contract-review/SKILL.md`
- Generic third-party integration outside seamless provider rules: `ai-skills/skills/vendor-integration/SKILL.md`

## Games Labs Rules

- Apply `ai-skills/rules/minimal-change/RULE.md`, `ai-skills/rules/reuse-before-build/RULE.md`, and `ai-skills/rules/search-before-create/RULE.md` before creating or changing code.
- Apply `ai-skills/rules/evidence-required/RULE.md` and `ai-skills/rules/verify-before-final/RULE.md` before final completion or handoff claims.
- Apply `ai-skills/rules/context-discipline/RULE.md` when gathering context in a large or unfamiliar area.
- Internal service-to-service communication should use gRPC.
- External HTTP access should go through `api-gateway`.
- Asynchronous or event-driven communication should use RabbitMQ.
- Each service owns its own data and schema.
- Services must not access another service's database directly.
- Contract changes should update `.proto`, generated code, gateway mappings, docs/examples, and affected clients together.
- Shared cross-service types or utilities belong in `shared-lib`; do not create local duplicate replacement types in consumer services.

## AI Dev Office

Use `ai-dev-office/` when work needs multi-agent tracking, role handoff, review loops, or durable task artifacts.

Use `ai-skills/` even when not using `ai-dev-office/`; skills define how to think, while office orchestration defines who does what next.
