---
name: change-impact-analysis
description: Use when changing shared code, contracts, schemas, generated code, service behavior, runtime config, or high-risk production paths.
---

# Change Impact Analysis

Understand who and what a change affects before editing.

## Use When

- Modifying shared packages, helpers, middleware, repositories, service methods, or generated code.
- Changing API request fields, response shape, status values, error codes, pagination, idempotency, or auth behavior.
- Changing protobuf, gRPC services, grpc-gateway mappings, OpenAPI, or generated clients.
- Changing RabbitMQ publishers, consumers, event schemas, routing keys, retries, DLQs, or async workflows.
- Changing database schema, migrations, indexes, query behavior, data compatibility, or rollback behavior.
- Refactoring code used by more than one package, service, route, job, or workflow.
- Removing code that appears unused.
- Changing Docker, CI, deployment, environment variables, or runtime config.
- Touching high-risk domains such as auth, wallet, order, payment, provider callbacks, missions, rewards, or balances.

## Do Not Use When

- Editing isolated documentation.
- Changing comments only.
- Formatting code without behavior changes.
- Making a purely local copy change.
- Updating examples with no runtime effect.

## Required Rule

Apply `rules/minimal-change/RULE.md`, `rules/evidence-required/RULE.md`, and `rules/verify-before-final/RULE.md`.

## Goal

Expose callers, contracts, tests, compatibility risks, and verification needs before a change reaches review or production.

## Required Inputs

- Proposed change or diff.
- Relevant files, symbols, routes, contracts, schemas, migrations, configs, generated artifacts, or workflows.
- Search, graph, test, build, CI, log, or production evidence when available.

## Process

1. State the proposed change.
2. Identify the change surface: file, package, symbol, endpoint, proto, table, event, config, deployment, or client contract.
3. Search exact references and naming variants before editing.
4. Identify direct callers, imports, dependents, generated clients, tests, runtime jobs, and external clients.
5. Build a compatibility matrix of observed input forms and already-working callers, clients, providers, or workflows that share the changed path. Preserve each live row or identify its explicit migration, and turn preserved rows into regression coverage before editing.
6. Classify risk: low, medium, high, or critical.
7. Choose the safest change strategy: minimal edit, additive compatibility, feature flag, compatibility layer, migration rollback, or client/provider coordination.
8. Verify with the strongest practical check. For a deployed shared path, smoke both the originally failing row and at least one previously working sibling before claiming runtime recovery.
9. Report impact, evidence, verification, and remaining uncertainty.

When SocratiCode is available, use `codebase_status`, `codebase_search`, `codebase_symbol`, and `codebase_graph_query` as discovery aids. Confirm important findings against current repository files, tests, build output, CI, or runtime evidence.

## Output Format

- Proposed change
- Impact surface
- References found
- Dependents
- Compatibility matrix and preserved rows
- Risk level and reason
- Safe change strategy
- Verification performed and not performed
- Remaining uncertainty

## Anti-patterns

- Assuming unused code from one failed search.
- Changing public contracts without caller or client review.
- Fixing one caller, input form, or provider without regression coverage for already-working siblings on the same shared path.
- Rewriting unrelated code while assessing impact.
- Treating generated artifacts, indexes, or old summaries as final proof.
