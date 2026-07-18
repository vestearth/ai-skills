---
name: cicd-pipeline-review
description: Use when adding or changing GitHub Actions workflows, CI/CD pipelines, build-push-deploy jobs, action versions, workflow permissions, pipeline secret handling, Dockerfiles, multi-stage builds, base images, build args, container build reproducibility, or image hygiene.
---

# CI/CD Pipeline Review

## Use When

- Adding or modifying a GitHub Actions workflow (`.github/workflows/*.yml`) or other CI/CD pipeline.
- Reviewing a build → push → deploy flow, image tagging, or rollout step.
- Changing workflow `permissions`, secrets, `concurrency`, triggers, or third-party action versions.
- Adding or modifying a `Dockerfile`, `.dockerignore`, or image build step (multi-stage structure, base image choice, build args, final image size).
- A build pulls private modules (e.g. `shared-lib`) and needs secret-safe credential handling.
- Confirming the pipeline fails loudly, deploys the artifact it actually built, and that local and CI image builds are reproducible.
- For Games Labs ECS deploy workflows (`staging.yml`/`prod.yml`, `ecs/task-definition.json`,
  `ecs/env.names`), pair this skill with `playbooks/games-labs/ecs-deploy.md`.

## Do Not Use When

- The concern is the Kubernetes manifests the pipeline applies, or GitOps sync policy/drift in an ArgoCD app; prefer `k8s-deploy-review`.
- The concern is module/version resolution or alignment rather than pipeline/build behavior; prefer `dependency-guard`.
- The change is only application code with no effect on the pipeline, build, or image.
- The task is final release approval and rollback notes; prefer `release-checklist`.

## Required Inputs

- The workflow file(s) under review and their triggers (`push`, `workflow_dispatch`, tags).
- The `Dockerfile` and `.dockerignore` under review, plus the base images they reference.
- The secrets, registry, and deploy target the pipeline uses, and how the build is invoked (CI, `make`, local) with its build args/secrets.
- Which private dependencies the build needs and how credentials reach it (`--mount=type=secret`, build arg, env).
- How images are tagged (immutable SHA vs `latest`) and how the deploy step selects an image.
- The permissions granted to the workflow token, any long-lived credentials in use, and the build/run user model with expected final image contents.

## Goal

Confirm the pipeline is least-privilege, supply-chain safe, fails loudly, and deploys
the exact artifact it built — and that the image itself is reproducible, minimal, and
secret-safe — then surface concrete pipeline and build risks before merge.

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
- Build parity matches local expectations: `GOWORK=off`, committed manifests, no `go mod tidy` in the CI image build.
- Caching keys are correct and cannot serve stale dependencies.

Check the Dockerfile and image structure:

- Multi-stage build separates the compile stage from a minimal runtime stage; the final stage is minimal (distroless / slim / scratch where viable), not the full build image.
- Layer order maximizes cache reuse (dependency manifests copied and downloaded before source).
- `.dockerignore` excludes VCS, local env, secrets, and build caches.
- Base images are pinned (tag or digest), not floating `latest`; the build does not depend on host state outside the build context.

Check image secret safety:

- Private-module credentials (e.g. `shared-lib`) use BuildKit `--mount=type=secret`, not `ARG`/`ENV` baked into layers.
- No tokens, kubeconfig, or `.env` values are copied into any layer; secrets do not appear in `docker history` of the final image.

Check runtime image hygiene:

- Container runs as a non-root user where possible.
- Only the required binary, certs, and assets are present in the final stage.
- Healthcheck / entrypoint behavior is explicit and matches how the platform runs it.

Check consistency:

- The workflow and Dockerfile match sibling services' patterns (tagging, jobs, naming, base images, stage naming) or the difference is justified.

## Output Format

- Pipeline and build risks (privilege, supply-chain, silent-failure, wrong-artifact, reproducibility, secret leak, image size, root user), ranked by severity.
- Specific workflow lines/steps and Dockerfile lines to change and why.
- Credential model recommendation (OIDC vs PAT/kubeconfig) where relevant.
- Consistency gaps versus sibling services.
- Verification steps (dispatch run, expected tags, expected failure behavior; build command, expected image size/user, secret-leak check).

## Anti-patterns

- Granting broad `write-all` permissions when a job needs one scope.
- Pinning actions to floating tags and trusting them with secrets.
- Deploying `latest` then `rollout restart` so no version is pinned and rollback is impossible.
- `continue-on-error: true` on the deploy step, turning a failed rollout into a green run.
- Long-lived PAT / kubeconfig secrets where OIDC is available.
- Narrowing or disabling a workflow that is the sole injector of runtime ConfigMap/Secret values — code still ships by another path while the config silently disappears on the next pod roll.
- Baking private tokens into `ARG`/`ENV` so they persist in image layers.
- Shipping the full build image as the runtime image, or floating `latest` base images that make builds non-reproducible.
- Running `go mod tidy` or relying on `go.work` inside the build instead of committing manifests and using `GOWORK=off`.
- Approving a Dockerfile without building it, or only building locally without CI parity.
