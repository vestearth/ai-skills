---
name: cicd-pipeline-review
description: Use when adding or changing GitHub Actions workflows, CI/CD pipelines, build-push-deploy jobs, action versions, workflow permissions, or pipeline secret handling.
---

# CI/CD Pipeline Review

## Use When

- Adding or modifying a GitHub Actions workflow (`.github/workflows/*.yml`) or other CI/CD pipeline.
- Reviewing a build → push → deploy flow, image tagging, or rollout step.
- Changing workflow `permissions`, secrets, `concurrency`, triggers, or third-party action versions.
- Confirming that a pipeline fails loudly and deploys the artifact it actually built.

## Do Not Use When

- The concern is the Dockerfile/image itself; prefer `container-build-review`.
- The concern is the Kubernetes manifests the pipeline applies; prefer `k8s-deploy-review`.
- The concern is module/version resolution rather than pipeline behavior; prefer `dependency-guard`.
- The task is final release approval and rollback notes; prefer `release-checklist`.

## Required Inputs

- The workflow file(s) under review and their triggers (`push`, `workflow_dispatch`, tags).
- The secrets, registry, and deploy target the pipeline uses.
- How images are tagged (immutable SHA vs `latest`) and how the deploy step selects an image.
- The permissions granted to the workflow token and any long-lived credentials in use.

## Goal

Confirm the pipeline is least-privilege, supply-chain safe, fails loudly, and
deploys the exact artifact it built — and surface concrete pipeline risks before merge.

## Process

Check permissions and credentials:

- `permissions:` is least-privilege (not default broad write); `packages: write` / `contents: read` scoped per job.
- Prefer short-lived OIDC over long-lived PATs / static kubeconfig secrets.
- Secrets are referenced, never echoed or written to logs/artifacts.

Check supply-chain safety:

- Third-party actions are pinned (ideally to a commit SHA), not floating tags.
- `pull_request_target` / untrusted input is not used to run attacker-controlled code with secrets.
- The registry login and push target are the intended ones.

Check build/deploy correctness:

- The deploy step references the immutable artifact (digest or `sha-<short>` tag), not just `latest`.
- A "restart"/rollout step that relies on `latest` is flagged — it cannot pin or roll back a version.
- `continue-on-error` / `|| true` on a deploy step is flagged: a failed deploy must not report success.
- `concurrency` prevents overlapping deploys to the same target; `cancel-in-progress` is intended.
- A workflow that also **seeds runtime config** (applies a ConfigMap/Secret from CI secrets, injects env) is flagged when its trigger is narrowed or disabled (e.g. switched to `workflow_dispatch`): code may still deploy by another path while the config silently stops being applied, so the next pod roll loses it. Confirm another owner injects those values.

Check reproducibility and gating:

- Build/test gates run before push/deploy, and a red gate blocks the deploy job.
- Build parity matches local expectations (e.g. `GOWORK=off`, committed manifests, no `go mod tidy` in CI image build).
- Caching keys are correct and cannot serve stale dependencies.

Check consistency:

- The workflow matches sibling services' patterns (tagging, jobs, naming) or the difference is justified.

## Output Format

- Pipeline risks (privilege, supply-chain, silent-failure, wrong-artifact), ranked by severity.
- Specific workflow lines/steps to change and why.
- Credential model recommendation (OIDC vs PAT/kubeconfig) where relevant.
- Verification steps (dispatch run, expected tags, expected failure behavior).

## Anti-patterns

- Granting broad `write-all` permissions when a job needs one scope.
- Pinning actions to floating tags and trusting them with secrets.
- Deploying `latest` then `rollout restart` so no version is pinned and rollback is impossible.
- `continue-on-error: true` on the deploy step, turning a failed rollout into a green run.
- Long-lived PAT / kubeconfig secrets where OIDC is available.
- Narrowing or disabling a workflow that is the sole injector of runtime ConfigMap/Secret values — code still ships by another path while the config silently disappears on the next pod roll.
