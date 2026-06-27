---
name: dependency-guard
description: Use when modifying go.mod, Dockerfiles, CI, build pipelines, or shared dependencies.
---

# Dependency Guard

## Use When

- Modifying `go.mod`, `go.sum`, `go.work`, Dockerfiles, CI, build pipelines, or shared dependencies.
- Updating shared modules such as `shared-lib`.
- Reviewing whether local and CI dependency behavior match.

## Do Not Use When

- The change is only application code and does not affect dependency resolution or build inputs.
- A more specific release or service review skill fully covers the requested output.

## Goal

Prevent local-only dependency behavior from hiding CI or production build failures.

## Required Inputs

- Changed dependency files, build files, or CI configuration.
- Relevant module version, replace directive, or workspace configuration.
- Local build/test output and CI output when available.

## Process

1. Identify the changed build inputs — `go.mod`, `go.sum`, `go.work`, Dockerfile, CI config, or a shared-module version bump. `go.mod` and `go.sum` move together: a require/version change in one with no matching change in the other is a red flag — inspect why before trusting it.
2. Check workspace and replace directives — no accidental `go.work` dependency leaking in, and no local `replace` directives in production services.
3. Reproduce the build the way CI does — workspace off, modules read-only — and verify `build` and `test` separately (a green `build` does not prove tests compile or pass):

   ```bash
   GOWORK=off GOFLAGS=-mod=readonly go build ./...
   GOWORK=off GOFLAGS=-mod=readonly go test ./...
   ```

   `-mod=readonly` makes these fail loudly if the build would need to mutate `go.mod`/`go.sum` — which is exactly the behavior CI has, and what a local developer build (with `go.work`) hides.
4. Treat `go mod tidy` as a mutating command, not a verification one. Run it locally when needed, then review the resulting `go.mod`/`go.sum` diff before committing; never run it inside the Dockerfile or build step.
5. Confirm dependency versions are intentional — pinned deliberately, not pulled in by a stray `tidy` or workspace edit.
6. For shared libraries (such as `shared-lib`), check version alignment across the services that consume them.
7. Compare local versus CI build behavior and record the evidence (commands run and their output).

## Output Format

- Dependency impact
- Local vs CI behavior
- Version or replace directive risk
- Required verification
- Recommendation

## Anti-patterns

- Trusting a green local build that used the developer workspace (`go.work`) instead of the CI conditions (`GOWORK=off`, `-mod=readonly`).
- Running `go mod tidy` in the Dockerfile or build step, letting the image mutate the dependency graph.
- Running `go mod tidy` without reviewing the resulting `go.mod`/`go.sum` diff.
- Treating a passing `go build` as proof that tests compile or pass.
- Bumping a shared module without checking version alignment across the services that consume it.
