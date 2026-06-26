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

1. Identify the changed build inputs — `go.mod`, `go.sum`, `go.work`, Dockerfile, CI config, or a shared-module version bump.
2. Check workspace and replace directives — no accidental `go.work` dependency leaking in, and no local `replace` directives in production services.
3. Reproduce the build the way CI does — `GOWORK=off`, `GOFLAGS=-mod=readonly`, no `go mod tidy` in the Dockerfile, and confirm `go build` succeeds.
4. Confirm dependency versions are intentional — pinned deliberately, not pulled in by a stray `tidy` or workspace edit.
5. For shared libraries (such as `shared-lib`), check version alignment across the services that consume them.
6. Compare local versus CI build behavior and record the evidence (commands run and their output).

## Output Format

- Dependency impact
- Local vs CI behavior
- Version or replace directive risk
- Required verification
- Recommendation

## Anti-patterns

- Local-only dependency behavior masks CI failures
- Docker build mutates dependency graph
- Dependency source is unclear
