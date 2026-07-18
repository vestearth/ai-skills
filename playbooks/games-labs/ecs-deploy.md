# Games Labs ECS Deploy Playbook

Use this playbook when changing or debugging the AWS ECS deploy lane for Games
Labs services: `.github/workflows/staging.yml` / `prod.yml`, `ecs/task-definition.json`,
`ecs/env.names`, `ecs/build-env-json.sh`, or inter-service URL wiring.

This playbook is domain-specific. For generic pipeline review (permissions,
supply chain, fail-loud, artifact identity) and the Dockerfile/image build itself,
use `skills/cicd-pipeline-review/SKILL.md`. The
legacy Contabo/k3s lane is decommissioned (2026-07-03) — `skills/k8s-deploy-review`
(which also covers ArgoCD/GitOps) no longer applies to Games Labs deploys.

## Topology (verify before relying)

Current branch → target routing. This drifts over time; confirm against
`knowledge-base/Knowledge Base/20 Flows/Deploy Topology Map.md` and the
workflow files themselves before asserting.

- `staging` branch → ECS staging (auto, `staging.yml`) — the real-DB QA lane.
- prod → ECS prod (`prod.yml`), same pipeline shape.
- `main` → **nothing** (dev integration branch only; k3s retired 2026-07-03).
- Backoffice FE has no `staging` branch; FE lands on `main`.

## Pipeline Shape

Two jobs, both scoped to the GitHub `staging` environment:

1. `build-push`: buildx (arm64) → ECR `:staging-latest` + `:staging-sha-<short>`,
   GH_PAT as a build secret, GHA cache.
2. `deploy-ecs`: ensure CloudWatch log group → render env into
   `ecs/task-definition.json` via `jq` + `build-env-json.sh` →
   `amazon-ecs-render-task-definition` (injects the `sha-` image) →
   `amazon-ecs-deploy-task-definition` with `wait-for-service-stability: true`.

## Review Checks

Env contract (`ecs/env.names` is the gate):

- A new runtime env var must be BOTH exported in the workflow render step AND
  listed in `ecs/env.names`. `build-env-json.sh` only emits listed names — a
  var missing from `env.names` silently never reaches the container.
- Required secrets keep the fail-loud guard (`::error` + `exit 1`); optional
  vars get explicit defaults in the render step, not silent empties.
- Secrets live in the GitHub **environment** (`staging`), not repo-level —
  adding one to the workflow without adding it to the environment yields an
  empty value, which the guard must catch.

Inter-service wiring:

- Service URLs are **hardcoded Cloud Map FQDNs** in the workflow
  (`<service>.games-labs.local:<port>`), not secrets. Adding a dependency =
  editing the workflow env block; the port must match the target service's
  task definition, and the target must exist in the `games-labs.local`
  namespace.

Artifact identity and rollback:

- The deploy step must reference `:staging-sha-<short>`; `:staging-latest` is
  convenience only and must never be the deployed reference.
- Rollback = deploy the previous task-definition revision (or re-run the
  workflow at the older commit). There is no pin-commit revert and no
  `rollout restart` on this lane.

Fail-loud:

- `wait-for-service-stability: true` stays on — without it a crash-looping
  task reports a green deploy.
- The log-group name in the `jq` render (`/ecs/<service>-staging`) must match
  the ensured log group, or logs vanish while the deploy stays green.

Assets (regression class):

- ECS serves assets via S3 + CloudFront (`S3_PUBLIC_BASE_URL`), NOT the
  gateway `/assets/` path — do not reintroduce gateway `PUBLIC_BASE_URL`
  assumptions from the k3s era.

Consistency:

- Family/service/log-group naming follows `<service>-staging`; new services
  copy a sibling workflow rather than inventing a new shape.
- Credentials are currently long-lived AWS keys; per
  `skills/cicd-pipeline-review`, prefer OIDC when touching this — flag, don't
  silently rewrite.

## Verification

- `gh run watch` the dispatched/pushed run to completion (both jobs green).
- `aws ecs describe-services --cluster <cluster> --services <service>` shows
  the new task definition revision as PRIMARY and steady state.
- Smoke the public path through `api-test-gateway.gameslabs.app` for the
  touched endpoints.

## Review Output

- Env-contract gaps (workflow export vs `env.names` vs GitHub environment).
- Wrong-artifact or silent-failure risks (latest deploys, missing stability
  wait, log-group mismatch).
- Inter-service URL/port mismatches against Cloud Map.
- Rollback plan stated as a task-definition revision, not a restart.
