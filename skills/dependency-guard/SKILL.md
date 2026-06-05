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

- No accidental go.work dependency
- No go mod tidy in Dockerfile
- Build uses -mod=readonly
- Dependency versions are intentional
- CI and local build behavior match

For Go services, check:

- GOWORK=off
- GOFLAGS=-mod=readonly
- go build succeeds

For shared libraries, check:

- Version alignment across services
- No local replace directives in production services

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
