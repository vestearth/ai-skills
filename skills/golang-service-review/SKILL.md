---
name: golang-service-review
description: Use when reviewing Go service implementation quality, handlers, workers, consumers, background jobs, repositories, migrations, context propagation, errors, tests, module hygiene, or production readiness.
---

# Golang Service Review

## Use When

- A Go service handler, use case, repository, client, migration, worker, or integration changes.
- A Go worker, consumer, scheduler, background job, or async processing path changes.
- The review needs Go-specific checks for context, errors, concurrency, dependencies, tests, or module hygiene.
- Production readiness depends on build behavior, configuration, logging, or service boundaries.

## Do Not Use When

- The task is primarily protobuf/gRPC compatibility; use `grpc-contract-review`.
- The task is mainly dependency policy, Docker, CI, or shared module alignment; use `dependency-guard`.
- The task is an active bug or production symptom with unknown root cause; start with `debugging`.
- The task is architecture ownership rather than implementation quality; use `tech-lead-review`.

## Goal

Review Go service changes for correctness, maintainability, operational safety, and predictable CI/runtime behavior.

## Required Inputs

- Changed Go files and related tests.
- Relevant service boundaries, interfaces, repositories, migrations, and configs.
- `go.mod`, `go.sum`, Dockerfile, or CI snippets when dependency/build behavior is touched.
- Build/test output or a clear reason verification could not be run.

## Process

1. Trace the request path: handler/consumer entrypoint, validation, business logic, data access, outbound calls, and response/error mapping.
2. Check context behavior: request context is propagated, timeouts/cancellation are respected, and background work is intentional.
3. Check errors and logging: errors are wrapped with useful context, mapped correctly at boundaries, and logged once at the right layer.
4. Check data integrity: transactions, locking, idempotency, migrations, and rollback behavior match the business rule.
5. Check dependencies: no accidental `replace`, `go.work`, mutable Docker dependency graph, or hidden local-only behavior.
6. Check tests: table tests or focused integration tests cover success, business errors, system errors, and regression risk.
7. Verify with the smallest relevant `go test` or build command and record exact output.

## Output Format

- Implementation verdict
- Request/data flow reviewed
- Correctness and data-integrity risks
- Error/logging observations
- Dependency/build risks
- Test and verification evidence
- Required follow-up

## Anti-patterns

- Approving from handler code without reading repository or service-layer effects.
- Ignoring context cancellation around database or network calls.
- Swallowing errors or logging secrets.
- Adding local dependency behavior that CI cannot reproduce.
- Treating passing compilation as proof of business correctness.
