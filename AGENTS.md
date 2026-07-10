# AI Skills Agent Guide

Use the smallest relevant skill.

This repository is the reusable policy, playbook, review-check, and agent
behavior contract layer. It guides how agents reason and produce outputs; it is
not an orchestrator and not a source of truth.

Before any agent modifies code, creates files, adds dependencies, or scaffolds behavior, apply the relevant minimal-change guardrails.

- `rules/minimal-change/RULE.md`
- `rules/reuse-before-build/RULE.md`
- `rules/search-before-create/RULE.md` when creating new artifacts

For non-trivial changes, new artifacts, dependencies, abstractions, or scaffolding, apply:

- `skills/minimal-change-review/SKILL.md`

Priority:
1. User request
2. Project AGENTS.md
3. Source code, tests, CI, logs
4. ai-skills guidance

Repository-specific claims require source-code verification.

New or revised skills should state use when, do not use when, goal, required
inputs, process, output format, and anti-patterns.

Before final answers, handoffs, merge claims, or fix claims, apply:

- `rules/evidence-required/RULE.md`
- `rules/verify-before-final/RULE.md`
- `skills/verification-loop/SKILL.md` when a workflow is needed

When gathering context in large or unfamiliar repositories, apply:

- `rules/context-discipline/RULE.md`
- `skills/search-first/SKILL.md`
- `skills/context-discipline/SKILL.md` when context budget matters

Recommended skills:
- minimal-change-review
- skill-authoring-review
- decision-grilling
- session-handoff
- deslop
- compact-guard
- permission-tuner
- mcp-audit
- module-map
- verification-loop
- search-first
- context-discipline
- change-impact-analysis
- knowledge-query
- knowledge-capture
- knowledge-promote
- knowledge-source-review
- self-learning
- debugging
- code-review
- clickhouse-io
- api-contract-review
- dependency-guard
- vendor-integration
- microservice-boundary-review
- release-checklist
- socraticode-discovery
- tech-lead-review
- games-labs-api-review
- games-labs-implementation-status
- seamless-provider-review
- grpc-contract-review
- rabbitmq-event-review
- golang-project-structure
- golang-service-review
- datadog-observability
- container-build-review
- cicd-pipeline-review
- k8s-deploy-review
- gitops-deploy-review
- incident-response
- secrets-management
- sprint-planning

Recommended Games Labs playbooks:
- playbooks/games-labs/api-review.md
- playbooks/games-labs/mobile-contract-handoff.md
- playbooks/games-labs/shared-lib-rollout.md
- playbooks/games-labs/provider-settlement.md
- playbooks/games-labs/missions-events.md
- playbooks/games-labs/ecs-deploy.md
