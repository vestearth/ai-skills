# AI Skills Version

Current: v3
Target: v3

V2.0 is complete when the four skill layers below are present and documented.
V2.1 is complete when the skill contract is consistent, validation is available, and adapter adoption notes are documented.
V2.2 is complete when the delivery/infra skill layer is present and documented.
V3 is complete when the Games Labs production/domain playbooks are present and routed from adoption docs.

## Version Themes

| Version | Theme |
| --- | --- |
| v1 | Generic reusable engineering skills |
| v2 | Earth working principles and operating style |
| v2.1 | Skill quality, validation, and adapter adoption |
| v2.2 | Delivery / Infra skill layer (container, CI/CD, deploy) |
| v3 | Games Labs production/domain system |
| v4 | Tech Lead OS |

## V2.1 Completion

Current target completion: complete

| Area | Status |
| --- | --- |
| Skill contract consistency | complete |
| Local validation script | complete |
| Adapter adoption notes | complete |
| V3 backlog note | complete |

## V2.2 Completion

Current target completion: complete

| Area | Status |
| --- | --- |
| Container build review | complete |
| CI/CD pipeline review | complete |
| Kubernetes deploy review | complete |
| GitOps deploy review | complete |
| Incident response | complete |
| Secrets management | complete |

## V3 Completion

Current target completion: complete

| Playbook | Status |
| --- | --- |
| playbooks/games-labs/mobile-contract-handoff.md | complete |
| playbooks/games-labs/shared-lib-rollout.md | complete |
| playbooks/games-labs/provider-settlement.md | complete |
| playbooks/games-labs/missions-events.md | complete |

## Operating Guardrails

Reusable baseline guardrails for checking reuse, evidence, verification, context, and impact before building.

- [x] `minimal-change-review`
- [x] `verification-loop`
- [x] `search-first`
- [x] `context-discipline`
- [x] `change-impact-analysis`
- [x] `rules/reuse-before-build/RULE.md`
- [x] `rules/minimal-change/RULE.md`
- [x] `rules/search-before-create/RULE.md`
- [x] `rules/evidence-required/RULE.md`
- [x] `rules/verify-before-final/RULE.md`
- [x] `rules/context-discipline/RULE.md`

## Knowledge Operation Skills

Reusable behaviors for querying, capturing, promoting, and source-reviewing durable knowledge in `knowledge-base/`.

- [x] `knowledge-query`
- [x] `knowledge-capture`
- [x] `knowledge-promote`
- [x] `knowledge-source-review`

## V2.0 Completion

Current target completion: 16 / 16 skills

| Layer | Present | Planned | Status |
| --- | ---: | ---: | --- |
| Foundation Skills | 4 | 0 | complete |
| Architecture Skills | 4 | 0 | complete |
| Platform Skills | 3 | 0 | complete |
| Earth Skills | 5 | 0 | complete |

## Foundation Skills

Reusable baseline engineering behavior for any project.

- [x] `debugging`
- [x] `code-review`
- [x] `dependency-guard`
- [x] `release-checklist`

## Architecture Skills

System design, ownership, and service-boundary judgment.

- [x] `tech-lead-review`
- [x] `microservice-boundary-review`
- [x] `grpc-contract-review`
- [x] `rabbitmq-event-review`

## Platform Skills

Tools, runtime, and service implementation review.

- [x] `socraticode-discovery`
- [x] `golang-service-review`
- [x] `datadog-observability`

## Specialized Skills

Reusable specialized technical skills outside the v2.0 core completion count.

- [x] `clickhouse-io`

## Delivery / Infra Skills

Container, pipeline, and deployment review for the GHCR + GitHub Actions + k3s +
Kustomize + ArgoCD stack. This layer gives the devops agent a thinking layer to
reason with, the way code-review backs the reviewer agent.

Tier 1:

- [x] `container-build-review`
- [x] `cicd-pipeline-review`
- [x] `k8s-deploy-review`

Tier 2:

- [x] `gitops-deploy-review`
- [x] `incident-response`
- [x] `secrets-management`

## Earth Skills

Personal/domain-specific skills for Earth workflows and Games Labs context.

- [x] `games-labs-api-review`
- [x] `seamless-provider-review`
- [x] `backend-interview-review`
- [x] `frontend-interview-review`
- [x] `sprint-planning`

## Compatibility Skills

These skills remain available for v1 compatibility or broader routing.

- `api-contract-review`
- `vendor-integration`

## Rule

Do not mark a skill as present until `skills/<skill-name>/SKILL.md` exists.
Run `scripts/validate-skills.sh` before release or adapter sync.

## V3 Playbooks

V3 expands Games Labs production/domain playbooks without adding broad new skills.

Completed playbooks:

- playbooks/games-labs/mobile-contract-handoff.md
- playbooks/games-labs/shared-lib-rollout.md
- playbooks/games-labs/provider-settlement.md
- playbooks/games-labs/missions-events.md
