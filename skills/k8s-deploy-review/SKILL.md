---
name: k8s-deploy-review
description: Use when adding or changing Kubernetes / k3s manifests, Kustomize overlays, Deployments, Services, probes, resource limits, rollout strategy, or image references.
---

# Kubernetes Deploy Review

## Use When

- Adding or modifying Kubernetes / k3s manifests or Kustomize bases/overlays (`deployment.yaml`, `service.yaml`, `kustomization.yaml`).
- Reviewing resource requests/limits, liveness/readiness/startup probes, replicas, or rollout strategy.
- Changing how a workload references its image (tag vs digest) or how config/secrets are mounted.
- Confirming a workload can be scheduled, stay healthy, and roll back safely.

## Do Not Use When

- The concern is the image build itself; prefer `container-build-review`.
- The concern is the CI/CD pipeline that applies the manifests; prefer `cicd-pipeline-review`.
- The concern is GitOps sync policy/drift in an ArgoCD app; note it and prefer a dedicated GitOps review when available.
- The task is release readiness and rollback narrative; prefer `release-checklist`.

## Required Inputs

- The manifests / Kustomize overlay under review and the target cluster (e.g. k3s).
- The image reference strategy (immutable digest/`sha-` tag vs `latest`) and how rollout is triggered.
- Resource expectations, probe endpoints, and replica/availability requirements.
- How secrets and config reach the pod, and whether they are managed in or out of the repo.

## Goal

Confirm the workload is schedulable, observable, resilient to restarts, and
rollback-safe, and surface concrete manifest risks before apply or rollout.

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

## Output Format

- Deploy risks (no limits, missing probes, mutable tag, manual secret, single replica), ranked by severity.
- Specific manifest fields to change and why.
- Rollback assessment: can this version be identified and reverted deterministically?
- Verification steps (`kustomize build`, `kubectl apply --dry-run`, expected probe/rollout behavior).

## Anti-patterns

- Deploying a `latest` tag so rollback and current-version are undefined.
- Triggering deploys via `rollout restart` of a mutable tag instead of an auditable manifest change.
- Omitting resource requests/limits and letting the scheduler/neighbors absorb the risk.
- Missing or fake readiness/liveness probes, so unhealthy pods receive traffic.
- Committing plaintext secrets in manifests, or relying on an undocumented manually-created cluster secret.
