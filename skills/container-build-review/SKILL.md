---
name: container-build-review
description: Use when adding or changing Dockerfiles, multi-stage builds, base images, build args, or container build reproducibility and image hygiene.
---

# Container Build Review

## Use When

- Adding or modifying a `Dockerfile`, `.dockerignore`, or container build step.
- Reviewing multi-stage build structure, base image choice, or final image size.
- A build pulls private modules (e.g. `shared-lib`) and needs secret-safe credential handling.
- Confirming local and CI image builds are reproducible and produce the same artifact.

## Do Not Use When

- The change is only application code with no effect on the build or image.
- The concern is the CI workflow that invokes the build rather than the build itself; prefer `cicd-pipeline-review`.
- The concern is how the image is deployed or scheduled; prefer `k8s-deploy-review`.
- The concern is module version alignment across services; prefer `dependency-guard`.

## Goal

Confirm the container image is reproducible, minimal, secret-safe, and consistent
with the other services, and surface concrete build risks before merge or rollout.

## Required Inputs

- The `Dockerfile` and `.dockerignore` under review, plus the base images they reference.
- How the build is invoked (CI workflow, `make`, local) and what build args/secrets it receives.
- Which private dependencies the build needs and how credentials reach the build (`--mount=type=secret`, build arg, env).
- The build/run user model and the expected final image contents.

## Process

Check build structure:

- Multi-stage build separates compile stage from a minimal runtime stage.
- Final stage is minimal (distroless / slim / scratch where viable), not the full build image.
- Layer order maximizes cache reuse (dependency manifests copied and downloaded before source).
- `.dockerignore` excludes VCS, local env, secrets, and build caches.

Check reproducibility and dependency hygiene:

- Base images are pinned (tag or digest), not floating `latest`.
- `go.work` is not used in service builds; parity builds run with `GOWORK=off`.
- `go mod tidy` is not run inside build stages; manifests are committed before image build.
- The build does not depend on host state outside the build context.

Check secret safety:

- Private-module credentials use BuildKit `--mount=type=secret`, not `ARG`/`ENV` baked into layers.
- No tokens, kubeconfig, or `.env` values are copied into any layer.
- Secrets do not appear in `docker history` of the final image.

Check runtime image hygiene:

- Container runs as a non-root user where possible.
- Only the required binary, certs, and assets are present in the final stage.
- Healthcheck / entrypoint behavior is explicit and matches how the platform runs it.

Check cross-service consistency:

- Base images, build patterns, and stage naming match sibling services.
- A change to one service's pattern is applied consistently or explicitly justified.

## Output Format

- Build risks (reproducibility, secret leak, size, root user), ranked by severity.
- Specific Dockerfile lines to change and why.
- Consistency gaps versus sibling services.
- Verification steps (build command, expected image size/user, secret-leak check).

## Anti-patterns

- Baking private tokens into `ARG`/`ENV` so they persist in image layers.
- Shipping the full build image as the runtime image.
- Floating `latest` base images that make builds non-reproducible.
- Running `go mod tidy` or relying on `go.work` inside the build instead of committing manifests and using `GOWORK=off`.
- Approving a Dockerfile without building it, or only building locally without CI parity.
