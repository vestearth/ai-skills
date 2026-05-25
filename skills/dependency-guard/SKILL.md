---
name: dependency-guard
description: Use when modifying go.mod, Dockerfiles, CI, build pipelines, or shared dependencies.
---

# Dependency Guard

## Validate

- No accidental go.work dependency
- No go mod tidy in Dockerfile
- Build uses -mod=readonly
- Dependency versions are intentional
- CI and local build behavior match

## Go service checks

- GOWORK=off
- GOFLAGS=-mod=readonly
- go build succeeds

## Shared library checks

- Version alignment across services
- No local replace directives in production services

## Reject if

- Local-only dependency behavior masks CI failures
- Docker build mutates dependency graph
- Dependency source is unclear
