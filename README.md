# AI Skills

Reusable AI working skills for Codex, Cursor, Claude, and other coding agents.

This repository is the reusable thinking layer for AI-assisted development. It should stay separate from project-specific orchestration tools such as `ai-dev-office/`.

- `ai-dev-office/` answers: who should do the work, in what order, with what handoff contract.
- `ai-skills` answers: how the agent should think while debugging, reviewing, integrating, or releasing.
- `knowledge-base/` answers: what durable project knowledge, decisions, flow maps, and reviewed notes exist.

## Why this is separate

`ai-skills` is designed to travel across projects.

Project repositories change. Teams, services, APIs, and deployment targets change. But many working principles should stay reusable: how to debug from evidence, review production risk, protect API contracts, verify dependencies, prepare releases, and use discovery tools without treating them as source-of-truth.

Keeping those principles in a separate repository makes them portable across future work. A project can consume `ai-skills/` through `AGENTS.md`, Cursor rules, Claude skills, or other agent adapters without copying the same guidance into every codebase.

This keeps project repos focused on project-specific rules, while `ai-skills` keeps the reusable operating system for AI-assisted engineering.

## Evidence-first role

`ai-skills` is the policy, reusable playbook, review-check, and agent behavior
contract layer. It is not an orchestrator and not a source of truth. Skills guide
how agents reason, review, debug, plan, and produce outputs for work such as
`api-contract-review`, `tech-lead-review`, `dependency-guard`, `debugging`,
`sprint-planning`, `rabbitmq-event-review`, and `golang-service-review`.

Each skill should define:

- use when
- do not use when
- goal
- required inputs
- process
- output format
- anti-patterns

Current repository files, tests, CI, logs, runtime config, current contracts, and
actual runtime behavior still decide what is true.

## Relationship to knowledge-base

`knowledge-base/` is the durable project memory: decisions, flow maps, project notes, templates, and reviewed engineering knowledge.

`ai-skills/` is the reusable agent behavior layer: rules and skills for how agents should search, verify, review, debug, and change systems.

Use `knowledge-base/` for project context and long-lived notes, but do not treat it as stronger evidence than current repository files, tests, CI, logs, or production signals.

## Knowledge Operations

These skills connect the reusable behavior layer to the durable memory layer.

| Skill | Use when |
| --- | --- |
| `knowledge-query` | A task may depend on durable project memory, prior decisions, architecture notes, lessons, flow maps, or knowledge-base context |
| `knowledge-capture` | Completed work reveals durable decisions, lessons, project understanding, flows, or reusable knowledge that should be captured |
| `knowledge-promote` | Inbox or project notes may need promotion into ADRs, reusable lessons, concepts, flow maps, or skills |
| `knowledge-source-review` | Reviewing notes for sources, freshness, publication safety, broken links, or drift from current repository evidence |
| `self-learning` | Propose-only loop: gather feedback, triage to one of five outcomes, delegate, and propose a change for approval |

## Tech Lead OS Bridge / Productivity Layer

These skills improve session quality and skill-library hygiene without declaring
the full v4 Tech Lead OS complete.

| Skill | Use when |
| --- | --- |
| `skill-authoring-review` | Creating, editing, reviewing, or pruning ai-skills guidance, frontmatter, routing, or behavior contracts |
| `decision-grilling` | Stress-testing a plan, design, architecture choice, rollout, or implementation approach before work begins |
| `session-handoff` | Compacting current work into a handoff for another agent, session, reviewer, or future continuation |
| `deslop` | Sweeping a finished diff or branch for AI-generated slop before commit, review, or handoff |
| `compact-guard` | Snapshotting critical working state before context compaction and restoring it after |
| `permission-tuner` | Turning repeated permission prompts into proposed risk-tiered allow/deny rules |
| `mcp-audit` | Auditing connected MCP servers for tool-count overhead, redundancy, and actual usage |
| `module-map` | Orienting fast in an unfamiliar code area with a one-screen map of entry points, modules, flow, and coupling |
| `model-router` | Routing each task to the cheapest capable model (scout=Haiku, worker=Sonnet, main model for reasoning) plus /model and /effort advisories to save quota |

## Recommended project layout

```text
project-root/
  AGENTS.md
  .cursor/rules/
  ai-dev-office/      # optional orchestration framework
  knowledge-base/     # optional durable project memory
  ai-skills/          # reusable skill/checklist library
```

## Version

See [VERSION.md](VERSION.md) for the current skill taxonomy, quality/adoption status, and future version themes.

## Core Skill Layers

These are the skills counted toward the v2.0 target in [VERSION.md](VERSION.md).

## Guardrail Rules

These apply before choosing a larger implementation path.

| Skill or rule | Use when |
| --- | --- |
| `minimal-change-review` | Before modifying code, creating files, adding dependencies, scaffolding features, or checking for overbuilt implementations |
| `verification-loop` | Before final answers, fix claims, merge/deploy readiness, release notes, or handoff claims |
| `search-first` | Starting implementation, debugging, refactoring, review, or repository discovery in an unfamiliar area |
| `context-discipline` | Repository context is large, stale, tool-derived, or likely to overload the session |
| `change-impact-analysis` | Changing shared code, contracts, schemas, generated code, service behavior, runtime config, or high-risk production paths |
| `rules/reuse-before-build/RULE.md` | Checking need, existing code, standard library, platform/native features, existing dependencies, then smallest new code |
| `rules/minimal-change/RULE.md` | Keeping edits scoped to the smallest safe change |
| `rules/search-before-create/RULE.md` | Searching before creating files, helpers, DTOs, configs, hooks, scripts, workflows, fixtures, or templates |
| `rules/evidence-required/RULE.md` | Requiring source, command, test, CI, log, or runtime evidence for codebase claims |
| `rules/verify-before-final/RULE.md` | Requiring relevant verification before completion, fix, merge, deploy, or handoff claims |
| `rules/context-discipline/RULE.md` | Gathering targeted context without dumping broad repository state |

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

### Specialized

| Skill | Use when |
| --- | --- |
| `golang-project-structure` | Creating or reorganizing a Go project, choosing package/module boundaries, executable layout, dependency direction, or locations for application and operational code |
| `frontend-ui-review` | Implementing or reviewing frontend pages and components against Figma, project design systems, responsive requirements, interaction states, or accessibility expectations |
| `clickhouse-io` | Designing, reviewing, or debugging ClickHouse tables, ingestion, analytics queries, retention, or event storage |

### Delivery / Infra

The thinking layer for the `devops` agent: GitHub Actions + ECR/ECS (current Games Labs lane — see `playbooks/games-labs/ecs-deploy.md`), plus GHCR + k3s + Kustomize + ArgoCD (legacy lane, kept for reuse).

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
| `games-labs-implementation-status` | Answering Games Labs follow-up status questions such as implemented yet, fix before reply, deploy confirmed, or what reply to send |
| `seamless-provider-review` | Reviewing seamless game provider integrations, callbacks, signatures, launch URLs, or round APIs |
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

### Cursor setup

Cursor only auto-loads `.mdc` rules from `<workspace-root>/.cursor/rules/` — it
does **not** read `adapters/cursor/rules/` on its own. Use the installer so the
rules land in the right place with the correct skill-path prefix for the folder
you open as the Cursor workspace. Do not hand-copy the `.mdc` files.

```bash
# Default — you open the PARENT folder that contains ai-skills/ as the Cursor
# workspace (the recommended layout). Symlinks rules into <parent>/.cursor/rules,
# keeping the committed `ai-skills/skills/...` prefix that resolves from there:
scripts/install-cursor.sh
# or target an explicit parent:
scripts/install-cursor.sh --nested /path/to/project-root

# You open ai-skills ITSELF as the Cursor workspace: rewrites the prefix to
# `skills/...` and copies into ai-skills/.cursor/rules:
scripts/install-cursor.sh --standalone
```

Which folder is your workspace? In Cursor, the top item in the file explorer is
the workspace root. If it's the parent containing `ai-skills/`, use the default;
if it's `ai-skills` itself, use `--standalone`.

Rules use `globs` + `alwaysApply: false`, so they attach when you edit a
matching file (e.g. `*.proto`, `go.mod`), not on every prompt. After install,
edit a matching file and confirm the rule appears in Cursor's active context.

An operator who runs several agents and keeps Cursor as an intentionally
un-wired oracle lane (see knowledge-base ADR-0002) should simply not run this.

### Claude Code setup

Claude Code discovers skills from `<workspace-root>/.claude/skills/` (and the
per-user `~/.claude/skills/`), but never reads this repo's `skills/` on its own.
Use the installer to mirror every skill folder there as an absolute symlink, so
repo edits and `git pull` flow through without re-copying. Do not hand-symlink
folder by folder — that is how the mirror drifts when skills are added or removed.

```bash
# Default — you open the PARENT folder that contains ai-skills/ as the Claude
# Code workspace (the recommended layout). Symlinks into <parent>/.claude/skills:
scripts/install-claude.sh
# or target an explicit parent / the user library:
scripts/install-claude.sh --nested /path/to/project-root
scripts/install-claude.sh --standalone   # into ai-skills/.claude/skills
scripts/install-claude.sh --user         # into ~/.claude/skills
```

The installer also prunes stale mirror entries (symlinks pointing at deleted or
renamed skills), leaves unrelated libraries untouched, and runs the validator.
New or removed skills take effect in the next Claude Code session.

## Quality checks

Run the local validator before release or adapter sync:

```bash
scripts/validate-skills.sh
```

The validator checks skill frontmatter, required contract sections, folder/name
alignment, skill coverage across README / VERSION / root `AGENTS.md` / Codex /
Cursor adapters, Games Labs playbook coverage across every routing surface, and
that the paths a `SKILL.md` points at resolve to real files.

Smoke-test the installers with:

```bash
scripts/test-install-cursor.sh   # Cursor: nested + standalone layouts
scripts/test-install-claude.sh   # Claude: sync + prune + idempotent
```

Both run in CI on pushes to `main` and on pull requests via
`.github/workflows/validate.yml`.

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
- `playbooks/games-labs/ecs-deploy.md` describes the AWS ECS deploy lane: staging/prod workflows, the `ecs/env.names` env contract, Cloud Map service URLs, fail-loud deploy checks, and rollback by task-definition revision.

## v3 Games Labs Playbooks

The v3 expansion adds production/domain playbooks before broad new skills. These playbooks capture high-reuse Games Labs operating patterns while keeping the generic skill catalog small.

Each playbook is described under [Playbooks](#playbooks) above; completion status is tracked in [VERSION.md](VERSION.md) (V3 Completion). This section intentionally keeps no second list, so description and status never drift apart.

## Source of truth rule

The actual repository files, tests, build output, CI, and production logs always beat AI memory, indexed context, old summaries, or previous task history.

Apparently this needs to be written down because machines learned confidence from humans.
