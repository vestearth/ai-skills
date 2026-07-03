---
name: gitops-deploy-review
description: Use when adding or changing ArgoCD Applications, GitOps sync policies, declared image versions, or reconciling git-as-source-of-truth against live cluster state.
---

# GitOps Deploy Review

## Use When

- Adding or modifying an ArgoCD `Application`, sync policy, or the git path it tracks.
- Reviewing whether the deployed version is actually represented in git.
- A workload is updated out-of-band (e.g. `kubectl rollout restart`) while a GitOps controller also manages it.
- Diagnosing drift, `OutOfSync`, `selfHeal` fights, or "the new image did not deploy".

## Do Not Use When

- The cluster is not managed by a GitOps controller; prefer `k8s-deploy-review`.
- The concern is the manifest's own correctness (probes, limits); prefer `k8s-deploy-review`.
- The concern is the CI workflow that pushes the image; prefer `cicd-pipeline-review`.
- The task is release readiness/rollback narrative; prefer `release-checklist`.
- The deploy target is AWS ECS (the current Games Labs staging/prod lane — no GitOps controller involved); prefer `cicd-pipeline-review` + `playbooks/games-labs/ecs-deploy.md`.

## Required Inputs

- The ArgoCD `Application` spec: `source` (repoURL, path, targetRevision) and `syncPolicy`.
- How the tracked manifests reference the image (immutable digest/`sha-` tag vs `latest`).
- How new images reach the cluster (does git change, or is rollout triggered imperatively?).
- Whether `automated`, `prune`, and `selfHeal` are enabled and what they are expected to do.

## Goal

Confirm git is the true source of what is running, that the controller can detect
and apply new versions, and that no out-of-band change silently fights the
controller — then surface concrete drift risks.

## Process

Check image-version-in-git (the core GitOps invariant):

- The tracked manifest pins an immutable image (digest or `sha-<short>`), so the running version is visible in git history.
- A `latest` tag is flagged: the controller sees no manifest diff when a new image is pushed, so it never syncs the new build, and the deployed version is undefined.
- New images are promoted by writing the new tag/digest into git (CI commit or image-updater), not by an imperative `rollout restart`.

Check sync policy intent:

- `automated`, `prune`, and `selfHeal` settings match the intended behavior and risk tolerance.
- `selfHeal: true` is reconciled with any manual/imperative change path — manual edits will be reverted, so flag `rollout restart` coexisting with selfHeal as a contradiction.
- `prune: true` cannot remove a resource that other systems depend on; out-of-git resources (manually created secrets) are documented as intentionally untracked.
- `syncOptions` and `retry` are appropriate (namespace creation, prune ordering, backoff).

Check source and scope:

- `repoURL`, `path`, and `targetRevision` point at the intended branch/folder.
- The app's destination namespace/cluster is correct.
- One source of truth: the same workload is not managed by both GitOps and an imperative pipeline step in conflicting ways.
- `ignoreDifferences` on a ConfigMap/Secret `/data` means git is **not** the source for those values — identify the injector (a CI step, image-updater, external controller). Flag it if that injector can be disabled or gated, because the values then silently disappear with nothing to restore them.

Check observability of sync:

- Sync status / health is monitored; a failed or stuck sync is visible, not silent.

## Output Format

- GitOps risks (mutable image tag, drift, selfHeal vs imperative restart, prune scope), ranked by severity.
- The specific contradiction(s) between git, the controller, and any pipeline step.
- Recommended promotion mechanism (write digest/tag to git via CI or image-updater).
- Verification steps (push a build, confirm git changes, confirm controller syncs the new version).

## Anti-patterns

- Tracking a `latest` image tag in git so the controller can never detect a new build and the running version is undefined.
- Triggering deploys with `kubectl rollout restart` while `selfHeal` reverts manual state — the two fight each other.
- Treating the GitOps controller as installed-and-forgotten while real promotion happens out-of-band.
- Using `ignoreDifferences` on ConfigMap/Secret data without recording who injects those values, so disabling that injector silently drops runtime config the controller will not restore.
- Enabling `prune` without knowing which live resources are intentionally not in git.
- No monitoring on sync status, so a stuck or failed sync goes unnoticed.
