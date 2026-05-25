# Codex Adapter

Add to project AGENTS.md:

## AI Skills

Use reusable guidance from `ai-skills/`.

## Rules

1. Apply only the smallest relevant skill.
2. Do not treat skills as source-code evidence.
3. Source code, tests, CI, logs, and user instructions override skill guidance.

Suggested routing:

- Bugs -> debugging
- Code review -> code-review
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
