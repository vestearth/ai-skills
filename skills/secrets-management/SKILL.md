---
name: secrets-management
description: Use when handling secrets, credentials, tokens, or kubeconfig across repos, CI, and clusters — provisioning, rotation, scoping, and keeping plaintext out of git and image layers.
---

# Secrets Management

## Use When

- Adding, changing, or reviewing how a secret, token, password, API key, or kubeconfig is stored or delivered.
- Wiring CI/CD credentials, registry pull secrets, or cluster `Secret` objects.
- Deciding how an application receives its secrets at runtime.
- Reviewing whether a credential is scoped, rotatable, and free of plaintext exposure.

## Do Not Use When

- The concern is which secrets a release verified, not how they are managed; prefer `release-checklist`.
- The concern is workflow permissions/OIDC mechanics in a pipeline broadly; prefer `cicd-pipeline-review` (use this skill for the credential lifecycle itself).
- The concern is build-time secret mounting in a Dockerfile; prefer `container-build-review`.

## Required Inputs

- The secret(s) in question, where they live (git, CI secret store, cluster, vault), and who creates them.
- How each secret reaches the consumer (env, mounted file, `secretKeyRef`, build mount).
- The credential type and scope (long-lived PAT/kubeconfig vs short-lived OIDC token).
- The rotation story: who rotates, how often, and what breaks on rotation.

## Goal

Confirm no secret is exposed in git, logs, or image layers; that each credential
is least-privilege, attributable, and rotatable; and that provisioning is
documented rather than tribal knowledge.

## Process

Check no plaintext exposure:

- No secret values are committed in git (manifests, configs, `.env`, fixtures) — only references.
- No secret is baked into image layers (`ARG`/`ENV`) or printed to CI logs/artifacts.
- `.gitignore` / `.dockerignore` exclude local secret files.

Check delivery mechanism:

- Apps read secrets from `Secret`/`secretKeyRef` or a vault, not hardcoded values.
- CI reads from the secret store and never echoes; build-time secrets use `--mount=type=secret`.
- Registry pull and cluster access secrets are referenced, not inlined.

Check scope and credential type:

- Each credential is least-privilege (scoped token, narrow RBAC), not a broad master key.
- Prefer short-lived OIDC-issued credentials over long-lived PATs and static kubeconfig where the platform supports it.
- Flag long-lived `KUBECONFIG`/PAT secrets as standing risk and note the OIDC alternative.

Check provisioning and rotation:

- Who creates each secret is documented — especially manually-created cluster secrets that are not in git and not reconciled by GitOps.
- A rotation path exists and is described; rotating a secret does not silently break consumers.
- Consider `Sealed Secrets` / `External Secrets` so secret *references* (not values) can live in git for GitOps-managed clusters.

Check blast radius:

- A leaked credential's reach is bounded; the same secret is not reused across unrelated systems.
- Revocation is possible and fast.

## Output Format

- Exposure findings (plaintext in git/log/layer), ranked by severity — these are urgent.
- Credential scope and type assessment, with OIDC/short-lived recommendations.
- Provisioning and rotation gaps (undocumented manual secrets, no rotation path).
- Concrete remediation steps and verification (grep history for plaintext, confirm references resolve).

## Anti-patterns

- Committing a secret value to git "temporarily" — assume it is compromised and must be rotated.
- Baking tokens into image layers where `docker history` exposes them.
- Long-lived PAT/kubeconfig secrets where OIDC short-lived credentials are available.
- Manually creating cluster secrets with no documented owner or rotation, so nobody can reproduce or rotate them.
- Reusing one broad credential across many systems, maximizing blast radius on leak.
