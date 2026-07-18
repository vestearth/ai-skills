---
name: k8s-deploy-review
description: Use when adding or changing Kubernetes / k3s manifests, Kustomize overlays, Deployments, Services, probes, resource limits, rollout strategy, image references, ArgoCD Applications, GitOps sync policies, declared image versions, or drift between git and live cluster state.
---

# Kubernetes Deploy Review

## Use When

- Adding or modifying Kubernetes / k3s manifests or Kustomize bases/overlays (`deployment.yaml`, `service.yaml`, `kustomization.yaml`).
- Reviewing resource requests/limits, liveness/readiness/startup probes, replicas, or rollout strategy.
- Changing how a workload references its image (tag vs digest) or how config/secrets are mounted.
- Adding or modifying an ArgoCD `Application`, sync policy, or the git path it tracks, or reviewing whether the deployed version is actually represented in git.
- Diagnosing drift, `OutOfSync`, `selfHeal` fights, an out-of-band `rollout restart` under a GitOps controller, or "the new image did not deploy".
- Confirming a workload can be scheduled, stay healthy, and roll back safely.

## Do Not Use When

- The concern is the image build itself, or the CI/CD pipeline that applies the manifests or pushes the image; prefer `cicd-pipeline-review`.
- The concern is module version alignment across services; prefer `dependency-guard`.
- The task is release readiness and rollback narrative; prefer `release-checklist`.
- The deploy target is AWS ECS (the current Games Labs staging/prod lane — no k8s manifests or GitOps controller involved); prefer `cicd-pipeline-review` + `playbooks/games-labs/ecs-deploy.md`.

## Required Inputs

- The manifests / Kustomize overlay under review and the target cluster (e.g. k3s).
- The image reference strategy (immutable digest/`sha-` tag vs `latest`) and how rollout is triggered.
- Resource expectations, probe endpoints, and replica/availability requirements.
- How secrets and config reach the pod, and whether they are managed in or out of the repo.
- For GitOps: the ArgoCD `Application` spec — `source` (repoURL, path, targetRevision) and `syncPolicy` — plus whether `automated`, `prune`, and `selfHeal` are enabled.
- How new images reach the cluster (does git change, or is rollout triggered imperatively?).

## Goal

Confirm the workload is schedulable, observable, resilient to restarts, and rollback-safe,
that git is the true source of what is running, and that no out-of-band change silently
fights the controller — then surface concrete manifest and drift risks before apply or rollout.

## Process

Check scheduling and resources:

- `resources.requests` and `resources.limits` are set (CPU/memory), so the workload schedules predictably and cannot starve neighbors.
- Replica count matches availability needs; single-replica workloads are flagged for downtime-on-restart.

Check health and rollout:

- `readinessProbe` gates traffic; `livenessProbe` recovers hangs; `startupProbe` covers slow starts where needed.
- Probe endpoints, ports, and thresholds are real and not copy-pasted from another service.
- Rollout strategy (`RollingUpdate` maxUnavailable/maxSurge) preserves availability during deploy.

Check image and rollback safety:

- The workload pins an immutable image (digest or `sha-<short>`), not `latest` — otherwise rollback and "what is running" are undefined.
- A change of image is expressed as a manifest change (auditable) rather than an out-of-band `rollout restart` of a mutable tag.
- `imagePullPolicy` matches the tag strategy.

Check config, secrets, and security:

- Config and secrets are mounted from `ConfigMap`/`Secret`, not hardcoded; no plaintext secret values committed in manifests.
- Secret provisioning is documented (who creates it, rotation), especially if created manually on the cluster.
- `securityContext` runs non-root / read-only root filesystem where viable.

Check Kustomize hygiene:

- Overlays patch the base cleanly; `kustomize build` produces the intended result.
- Namespace, labels, and selectors are consistent and match the Service.
- Environment differences live in overlays, not divergent copies of the base.

Check image-version-in-git (the core GitOps invariant):

- The tracked manifest pins an immutable image (digest or `sha-<short>`), so the running version is visible in git history; a `latest` tag is flagged because the controller sees no manifest diff when a new image is pushed, never syncs it, and the deployed version is undefined.
- New images are promoted by writing the new tag/digest into git (CI commit or image-updater), not by an imperative `rollout restart`.

Check GitOps sync policy and scope:

- `automated`, `prune`, and `selfHeal` match the intended behavior and risk tolerance; `selfHeal: true` coexisting with a manual `rollout restart` path is a contradiction — the controller reverts the manual state.
- `prune: true` cannot remove a resource other systems depend on; out-of-git resources (manually created secrets) are documented as intentionally untracked.
- `repoURL`, `path`, and `targetRevision` point at the intended branch/folder, and the destination namespace/cluster is correct.
- One source of truth: the same workload is not managed by both GitOps and an imperative pipeline step in conflicting ways.
- `ignoreDifferences` on a ConfigMap/Secret `/data` means git is **not** the source for those values — identify the injector (a CI step, image-updater, external controller) and flag it if that injector can be disabled or gated, because the values then silently disappear with nothing to restore them.
- `syncOptions`/`retry` are appropriate (namespace creation, prune ordering, backoff), and sync status/health is monitored so a failed or stuck sync is visible, not silent.

## Output Format

- Deploy and GitOps risks (no limits, missing probes, mutable tag, manual secret, single replica, drift, selfHeal vs imperative restart, prune scope), ranked by severity.
- Specific manifest fields (and ArgoCD `Application` settings) to change and why, including any contradiction between git, the controller, and a pipeline step.
- Rollback assessment: can this version be identified and reverted deterministically?
- Recommended promotion mechanism (write digest/tag to git via CI or image-updater) where relevant.
- Verification steps (`kustomize build`, `kubectl apply --dry-run`, expected probe/rollout behavior; push a build, confirm git changes, confirm the controller syncs the new version).

## Anti-patterns

- Deploying a `latest` tag so rollback and current-version are undefined, or tracking a `latest` tag in git so the controller can never detect a new build.
- Triggering deploys via `rollout restart` of a mutable tag instead of an auditable manifest change — and doing so while `selfHeal` reverts the manual state, so the two fight each other.
- Omitting resource requests/limits and letting the scheduler/neighbors absorb the risk.
- Missing or fake readiness/liveness probes, so unhealthy pods receive traffic.
- Committing plaintext secrets in manifests, or relying on an undocumented manually-created cluster secret.
- Using `ignoreDifferences` on ConfigMap/Secret data without recording who injects those values, so disabling that injector silently drops runtime config the controller will not restore.
- Enabling `prune` without knowing which live resources are intentionally not in git, or leaving sync status unmonitored so a stuck sync goes unnoticed.
- Treating the GitOps controller as installed-and-forgotten while real promotion happens out-of-band.
