# AGENTS.md — Generic Go Service

This project uses `ai-skills/` as reusable AI engineering guidance.

## Priority

1. User request
2. This project `AGENTS.md`
3. Source code, tests, CI, logs, and production evidence
4. `ai-skills/` guidance

Repository-specific claims require source-code verification.

## Source Of Truth

Source code, tests, CI, logs, and production evidence override AI memory, indexed context, summaries, and skill guidance.

Skills are working guidance, not proof.

## Skill Routing

Use the smallest relevant skill:

- Code/file/dependency/scaffold changes: `ai-skills/skills/minimal-change-review/SKILL.md`
- Completion, fix, merge, deploy, or handoff claims: `ai-skills/skills/verification-loop/SKILL.md`
- Unfamiliar repository area: `ai-skills/skills/search-first/SKILL.md`
- Large, stale, or tool-derived context: `ai-skills/skills/search-first/SKILL.md`
- Shared code, contracts, schemas, generated code, runtime config, or high-risk paths: `ai-skills/skills/change-impact-analysis/SKILL.md`
- Project memory, decisions, architecture notes, lessons, or flow maps: `ai-skills/skills/knowledge-query/SKILL.md`
- Durable knowledge capture after completed work: `ai-skills/skills/knowledge-capture/SKILL.md`
- Inbox/project note promotion: `ai-skills/skills/knowledge-promote/SKILL.md`
- Knowledge-base source, freshness, publication, or drift review: `ai-skills/skills/knowledge-source-review/SKILL.md`
- Bugs, logs, failed tests, crashes: `ai-skills/skills/debugging/SKILL.md`
- Code review or merge readiness: `ai-skills/skills/code-review/SKILL.md`
- ClickHouse tables, ingestion, queries, retention, or event storage: `ai-skills/skills/clickhouse-io/SKILL.md`
- Creating or reorganizing a Go project, module, command, service, worker, or package layout: `ai-skills/skills/golang-project-structure/SKILL.md`
- Go service implementation review: `ai-skills/skills/golang-service-review/SKILL.md`
- gRPC/protobuf/gateway contract changes: `ai-skills/skills/api-contract-review/SKILL.md`
- RabbitMQ events, routing, retries, DLQs: `ai-skills/skills/rabbitmq-event-review/SKILL.md`
- Dependency, Docker, CI, Go modules: `ai-skills/skills/dependency-guard/SKILL.md`
- Datadog metrics, logs, traces, monitors: `ai-skills/skills/datadog-observability/SKILL.md`
- Architecture, ownership, scalability, risk: `ai-skills/skills/tech-lead-review/SKILL.md`
- Service ownership or boundaries: `ai-skills/skills/microservice-boundary-review/SKILL.md`
- Release, deploy, rollback, smoke tests: `ai-skills/skills/release-checklist/SKILL.md`

Compatibility fallback:

- Generic API contract work: `ai-skills/skills/api-contract-review/SKILL.md`
- Generic third-party integration work: `ai-skills/skills/vendor-integration/SKILL.md`

## Discovery

Use repository search, direct file reads, tests, CI, and logs as the final evidence.

If SocratiCode or another index is available, use it only as a navigation layer, then verify against actual repository files.

## Operating Rules

- Apply `ai-skills/rules/minimal-change/RULE.md`, `ai-skills/rules/reuse-before-build/RULE.md`, and `ai-skills/rules/search-before-create/RULE.md` before creating or changing code.
- Apply `ai-skills/rules/evidence-required/RULE.md` and `ai-skills/rules/verify-before-final/RULE.md` before final completion or handoff claims.
- Apply `ai-skills/rules/context-discipline/RULE.md` when gathering context in a large or unfamiliar area.
- Do not approve from summaries alone.
- Do not introduce local-only dependency behavior that CI cannot reproduce.
- Define or update `.proto` before generated code when changing gRPC contracts.
- Treat retries, duplicate requests, and idempotency as production behavior, not edge cases.
- Record exact verification commands and outcomes when reviewing or handing off work.
