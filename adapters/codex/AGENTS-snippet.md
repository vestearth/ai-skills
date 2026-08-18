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

## Guardrail Rules

Rules are behavior contracts, not routing targets: they apply whenever their
trigger appears, including when a skill is already in use.

- Before editing code, files, dependencies, or scaffolding -> `ai-skills/rules/minimal-change/RULE.md`
- Before adding code, dependencies, or abstractions -> `ai-skills/rules/reuse-before-build/RULE.md`
- Before creating any new file, helper, config, or fixture -> `ai-skills/rules/search-before-create/RULE.md`
- Before any claim about repository behavior, risk, or root cause -> `ai-skills/rules/evidence-required/RULE.md`
- Before completion, fix, merge, deploy, or handoff claims -> `ai-skills/rules/verify-before-final/RULE.md`
- While gathering repository context -> `ai-skills/rules/context-discipline/RULE.md`
- Before writing or committing any file that could carry a credential, including `.env` and `.env.*` -> `ai-skills/rules/no-secrets-in-repo/RULE.md`
- When fixing a bug or making a failing test, lint, or CI check pass -> `ai-skills/rules/test-integrity/RULE.md`
- Before changing a model, entity, DDL file, index, constraint, or stored enum -> `ai-skills/rules/schema-change-needs-migration/RULE.md`

The last three are prohibitions. They hold even when the user did not mention them
and even when the change is otherwise in scope.

Suggested routing:

- Before code/file/dependency/scaffold changes -> minimal-change-review
- Creating, editing, or pruning ai-skills guidance -> skill-authoring-review
- Stress-testing a plan, design, rollout, or implementation approach -> decision-grilling
- Compacting current work for another agent, session, reviewer, or continuation -> session-handoff
- Hunting siblings of a defect you just fixed, across services -> defect-class-sweep
- Sweeping a finished diff for AI-generated slop before commit or handoff -> deslop
- Snapshotting working state before context compaction -> session-handoff
- Repeated permission prompts that should become allow/deny rules -> permission-tuner
- Auditing MCP servers for token overhead, redundancy, or usage -> mcp-audit
- Orienting in an unfamiliar code area with a one-screen map -> search-first
- Starting a task, delegating a subtask, or task/model mismatch -> model-router
- Before completion, fix, merge, deploy, or handoff claims -> verification-loop
- Receiving work claimed complete from another agent, handoff, or PR -> completion-audit
- Stripping AI provenance marks or metadata from content we own before publishing -> remove-ai-marks
- Unfamiliar repository area -> search-first
- Large, stale, or tool-derived context -> search-first
- Shared code, contracts, schemas, generated code, runtime config, or high-risk paths -> change-impact-analysis
- Project memory, decisions, architecture notes, lessons, or flow maps -> knowledge-query
- Durable knowledge capture after completed work -> knowledge-capture
- Inbox/project note promotion -> knowledge-promote
- Knowledge-base source, freshness, publication, or drift review -> knowledge-source-review
- Turning feedback, corrections, or lessons into a proposed skill/rule/knowledge change -> self-learning
- Recurring weekly work summary or Weekly Review log update -> weekly-report
- Bugs -> debugging
- Code review -> code-review
- Figma-to-code implementation or frontend visual/state/responsive/accessibility review -> frontend-ui-review
- ClickHouse tables, ingestion, queries, retention, or event storage -> clickhouse-io
- API changes -> api-contract-review
- Dependency changes -> dependency-guard
- Service ownership changes -> microservice-boundary-review
- Deployment, rollout, or release readiness -> release-checklist
- CI/CD pipeline or GitHub Actions workflow changes -> cicd-pipeline-review
- Dockerfile, base image, or container build changes -> cicd-pipeline-review
- ArgoCD, GitOps sync, or declared image version changes -> k8s-deploy-review
- Kubernetes / k3s / Kustomize manifest changes -> k8s-deploy-review
- Secrets, credentials, tokens, or kubeconfig handling -> secrets-management
- Production incident, outage, degradation, or rollback decision -> incident-response
- Repository discovery -> socraticode-discovery
- Architecture review -> tech-lead-review
- gRPC/protobuf/gateway contract changes -> api-contract-review
- RabbitMQ event or async flow changes -> rabbitmq-event-review
- Creating or reorganizing a Go project, module, command, service, worker, or package layout -> golang-project-structure
- Go service implementation review -> golang-service-review
- Datadog dashboards/monitors/telemetry -> datadog-observability
- Games Labs API changes -> games-labs-api-review
- Games Labs follow-up status questions such as implemented yet, fix before reply, or deploy confirmed -> games-labs-implementation-status
- Seamless provider callbacks/signatures -> vendor-integration
- Sprint or backlog planning -> sprint-planning
- Other provider integrations -> vendor-integration
