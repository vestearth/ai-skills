# AI Skills

Reusable AI working skills for Codex, Cursor, Claude, and other coding agents.

This repository is the reusable thinking layer for AI-assisted development. It should stay separate from project-specific orchestration tools such as `ai-dev-office/`.

- `ai-dev-office/` answers: who should do the work, in what order, with what handoff contract.
- `ai-skills` answers: how the agent should think while debugging, reviewing, integrating, or releasing.

## Why this is separate

`ai-skills` is designed to travel across projects.

Project repositories change. Teams, services, APIs, and deployment targets change. But many working principles should stay reusable: how to debug from evidence, review production risk, protect API contracts, verify dependencies, prepare releases, and use discovery tools without treating them as source-of-truth.

Keeping those principles in a separate repository makes them portable across future work. A project can consume `ai-skills/` through `AGENTS.md`, Cursor rules, Claude skills, or other agent adapters without copying the same guidance into every codebase.

This keeps project repos focused on project-specific rules, while `ai-skills` keeps the reusable operating system for AI-assisted engineering.

## Recommended project layout

```text
project-root/
  AGENTS.md
  .cursor/rules/
  ai-dev-office/      # optional orchestration framework
  ai-skills/          # reusable skill/checklist library
```

## Version

See [VERSION.md](VERSION.md) for the current skill taxonomy, quality/adoption status, and future version themes.

## Core Skill Layers

These are the skills counted toward the v2.0 target in [VERSION.md](VERSION.md).

### Foundation

| Skill | Use when |
| --- | --- |
| `debugging` | Investigating bugs, broken behavior, failed tests, logs, stack traces |
| `code-review` | Reviewing code changes before merge or handoff |
| `dependency-guard` | Changing Go modules, Dockerfiles, CI build rules, or shared-lib versions |
| `release-checklist` | Preparing deployment, production rollout, verification, or rollback notes |

### Architecture

| Skill | Use when |
| --- | --- |
| `tech-lead-review` | Evaluating architecture, ownership, cross-team impact, risk, scalability, or maintainability |
| `microservice-boundary-review` | Changing service ownership, service boundaries, gRPC contracts, or event flows |
| `grpc-contract-review` | Changing protobuf, gRPC services, grpc-gateway mappings, generated artifacts, or wire compatibility |
| `rabbitmq-event-review` | Changing RabbitMQ publishers, consumers, event schemas, routing keys, retries, DLQs, or async service flows |

### Platform

| Skill | Use when |
| --- | --- |
| `socraticode-discovery` | Starting repository-specific discovery with SocratiCode, search, symbol lookup, or graph analysis |
| `golang-service-review` | Reviewing Go service implementation, context propagation, errors, repositories, tests, module hygiene, or production readiness |
| `datadog-observability` | Reviewing metrics, logs, traces, dashboards, monitors, SLOs, tags, or incident visibility |

### Delivery / Infra

The thinking layer for the `devops` agent: GHCR + GitHub Actions + k3s + Kustomize + ArgoCD.

| Skill | Use when |
| --- | --- |
| `container-build-review` | Changing Dockerfiles, multi-stage builds, base images, build secrets, or image reproducibility/hygiene |
| `cicd-pipeline-review` | Changing GitHub Actions / CI/CD workflows, build-push-deploy jobs, action versions, workflow permissions, or pipeline secrets |
| `k8s-deploy-review` | Changing Kubernetes/k3s manifests, Kustomize overlays, probes, resource limits, rollout strategy, or image references |
| `gitops-deploy-review` | Changing ArgoCD Applications, sync policies, declared image versions, or reconciling git-as-source-of-truth against live cluster state |
| `incident-response` | Triage, containment, rollback decision, runbook, and post-incident review during a production incident or degradation |
| `secrets-management` | Provisioning, rotating, scoping secrets/tokens/kubeconfig and keeping plaintext out of git, logs, and image layers |

### Earth

| Skill | Use when |
| --- | --- |
| `games-labs-api-review` | Reviewing Games Labs API, gateway, mobile, missions, wallet, VIP, store, or provider-facing changes |
| `seamless-provider-review` | Reviewing seamless game provider integrations, callbacks, signatures, launch URLs, or round APIs |
| `backend-interview-review` | Evaluating backend interview answers, take-homes, system design, debugging, or production-readiness judgment |
| `frontend-interview-review` | Evaluating frontend interview answers, UI exercises, accessibility, performance, API integration, or product judgment |
| `sprint-planning` | Turning goals, backlog items, incidents, or stakeholder requests into bounded sprint scope and verification plans |

## Compatibility Skills

These remain available for v1 compatibility and broader routing, but they are not counted in the v2.0 core completion total.

| Skill | Use when |
| --- | --- |
| `api-contract-review` | Changing APIs, protobuf contracts, grpc-gateway routes, or frontend/mobile integrations outside a more specific domain skill |
| `vendor-integration` | Integrating third-party APIs, callbacks, provider platforms, or payment/game vendors outside a more specific domain skill |

## Adapter strategy

Adapters should be thin. Do not duplicate full skill text in tool-specific files.

- Codex: reference this repository from project `AGENTS.md`.
- Cursor: use `.mdc` rules that route to the matching `skills/<skill>/SKILL.md`.
- Claude Code: expose each folder under `skills/` as a Claude-compatible skill.

## Quality checks

Run the local validator before release or adapter sync:

```bash
scripts/validate-skills.sh
```

The validator checks skill frontmatter, required contract sections, folder/name alignment, and README/VERSION skill coverage.

## Adoption workflow

1. Add the smallest relevant adapter snippet or rule to the consuming project.
2. Keep project-specific truth in that project's `AGENTS.md`, code, tests, CI, logs, and production evidence.
3. Keep `ai-skills` as reusable guidance; do not copy full skill bodies into adapters.
4. Run `scripts/validate-skills.sh` after changing skill routing or version tables.

## Examples

Use these as starter `AGENTS.md` files when consuming `ai-skills/` from another repository.

- `examples/generic-go-service/AGENTS.md` for a normal Go service repo.
- `examples/games-labs/AGENTS.md` for the Games Labs workspace with `ai-dev-office/`, SocratiCode, gateway/protobuf, RabbitMQ, providers, and shared-lib concerns.

## Playbooks

Playbooks hold domain-specific operating rules that are too specific for generic skills.

- `skills/api-contract-review` describes how to review API contracts in general.
- `playbooks/games-labs/api-review.md` describes Games Labs-specific API expectations such as status values, client UX routing, idempotency, gateway/protobuf alignment, and rollout checks.
- `playbooks/games-labs/mobile-contract-handoff.md` describes how to answer mobile/web contract questions from current API, gateway, protobuf, client, docs, and runtime evidence.
- `playbooks/games-labs/shared-lib-rollout.md` describes how to check shared-lib adoption, pseudo-version alignment, generated contract drift, and cross-repo build evidence.
- `playbooks/games-labs/provider-settlement.md` describes how to review provider settlement across callback acceptance, wallet correctness, round lifecycle, events, and reconciliation.
- `playbooks/games-labs/missions-events.md` describes how to debug mission progress through producer events, RabbitMQ routing, consumers, mission rules, and client-facing status.

## v3 Games Labs Playbooks

The v3 expansion adds production/domain playbooks before broad new skills. These playbooks capture high-reuse Games Labs operating patterns while keeping the generic skill catalog small.

## Source of truth rule

The actual repository files, tests, build output, CI, and production logs always beat AI memory, indexed context, old summaries, or previous task history.

Apparently this needs to be written down because machines learned confidence from humans.
