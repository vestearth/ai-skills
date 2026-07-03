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
- Creating, editing, or pruning ai-skills guidance -> skill-authoring-review
- Stress-testing a plan, design, rollout, or implementation approach -> decision-grilling
- Compacting current work for another agent, session, reviewer, or continuation -> session-handoff
- Sweeping a finished diff for AI-generated slop before commit or handoff -> deslop
- Snapshotting working state before context compaction -> compact-guard
- Repeated permission prompts that should become allow/deny rules -> permission-tuner
- Auditing MCP servers for token overhead, redundancy, or usage -> mcp-audit
- Orienting in an unfamiliar code area with a one-screen map -> module-map
- Before completion, fix, merge, deploy, or handoff claims -> verification-loop
- Unfamiliar repository area -> search-first
- Large, stale, or tool-derived context -> context-discipline
- Shared code, contracts, schemas, generated code, runtime config, or high-risk paths -> change-impact-analysis
- Project memory, decisions, architecture notes, lessons, or flow maps -> knowledge-query
- Durable knowledge capture after completed work -> knowledge-capture
- Inbox/project note promotion -> knowledge-promote
- Knowledge-base source, freshness, publication, or drift review -> knowledge-source-review
- Turning feedback, corrections, or lessons into a proposed skill/rule/knowledge change -> self-learning
- Bugs -> debugging
- Code review -> code-review
- ClickHouse tables, ingestion, queries, retention, or event storage -> clickhouse-io
- API changes -> api-contract-review
- Dependency changes -> dependency-guard
- Service ownership changes -> microservice-boundary-review
- Deployment, rollout, or release readiness -> release-checklist
- CI/CD pipeline or GitHub Actions workflow changes -> cicd-pipeline-review
- Dockerfile, base image, or container build changes -> container-build-review
- ArgoCD, GitOps sync, or declared image version changes -> gitops-deploy-review
- Kubernetes / k3s / Kustomize manifest changes -> k8s-deploy-review
- Secrets, credentials, tokens, or kubeconfig handling -> secrets-management
- Production incident, outage, degradation, or rollback decision -> incident-response
- Repository discovery -> socraticode-discovery
- Architecture review -> tech-lead-review
- gRPC/protobuf/gateway contract changes -> grpc-contract-review
- RabbitMQ event or async flow changes -> rabbitmq-event-review
- Go service implementation review -> golang-service-review
- Datadog dashboards/monitors/telemetry -> datadog-observability
- Games Labs API changes -> games-labs-api-review
- Seamless provider callbacks/signatures -> seamless-provider-review
- Sprint or backlog planning -> sprint-planning
- Other provider integrations -> vendor-integration
