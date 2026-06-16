# Codex Adapter

Add to project AGENTS.md:

## AI Skills

Use reusable guidance from `ai-skills/`.

## Rules

1. Apply only the smallest relevant skill.
2. Do not treat skills as source-code evidence.
3. Source code, tests, CI, logs, production evidence, and user instructions override skill guidance.
4. Prefer domain-specific skills before compatibility skills.
5. After changing this routing snippet, run `scripts/validate-skills.sh` in `ai-skills/`.

Suggested routing:

- Before code/file/dependency/scaffold changes -> minimal-change-review
- Before completion, fix, merge, deploy, or handoff claims -> verification-loop
- Unfamiliar repository area -> search-first
- Large, stale, or tool-derived context -> context-discipline
- Shared code, contracts, schemas, generated code, runtime config, or high-risk paths -> change-impact-analysis
- Project memory, decisions, architecture notes, lessons, or flow maps -> knowledge-query
- Durable knowledge capture after completed work -> knowledge-capture
- Inbox/project note promotion -> knowledge-promote
- Knowledge-base source, freshness, publication, or drift review -> knowledge-source-review
- Bugs -> debugging
- Code review -> code-review
- ClickHouse tables, ingestion, queries, retention, or event storage -> clickhouse-io
- API changes -> api-contract-review
- Dependency changes -> dependency-guard
- Service ownership changes -> microservice-boundary-review
- Deployment -> release-checklist
- Repository discovery -> socraticode-discovery
- Architecture review -> tech-lead-review
- gRPC/protobuf/gateway contract changes -> grpc-contract-review
- RabbitMQ event or async flow changes -> rabbitmq-event-review
- Go service implementation review -> golang-service-review
- Datadog dashboards/monitors/telemetry -> datadog-observability
- Games Labs API changes -> games-labs-api-review
- Seamless provider callbacks/signatures -> seamless-provider-review
- Backend interview evaluation -> backend-interview-review
- Frontend interview evaluation -> frontend-interview-review
- Sprint or backlog planning -> sprint-planning
- Other provider integrations -> vendor-integration
