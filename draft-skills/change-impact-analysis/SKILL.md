ชื่อที่เหมาะ:

skills/change-impact-analysis/SKILL.md

ใจความ:

Before modifying shared code, API contracts, DB schema, proto, service methods, or middleware:
1. Identify direct callers.
2. Identify imports/dependents.
3. Identify tests affected.
4. Identify API / gRPC / frontend/mobile impact.
5. Identify migration or backward compatibility risk.
6. Summarize impact before editing.

อันนี้ผูกกับ SocratiCode graph commands ได้เลย:

codebase_graph_query
codebase_graph_stats
codebase_symbol
codebase_search

นี่คือจุดที่ repo คุณจะ “production-aware” ไม่ใช่แค่ prompt สวย ๆ ให้บอททำท่าคิดลึกเหมือนกำลังประชุมสถาปัตยกรรมจักรวาล

# Draft: Change Impact Analysis

# Change Impact Analysis

Use this skill before changing code that may affect callers, contracts, runtime behavior, shared modules, generated code, database state, deployment safety, or external clients.

The goal is to understand impact before editing, not after the repo is already on fire like a traditional release process.

## Use when

- Modifying shared packages, helpers, middleware, repositories, service methods, or generated code.
- Changing API request fields, response shape, status values, error codes, pagination, idempotency, or auth behavior.
- Changing protobuf, gRPC services, grpc-gateway mappings, OpenAPI, or generated clients.
- Changing RabbitMQ publishers, consumers, event schemas, routing keys, retries, DLQs, or async workflows.
- Changing database schema, migrations, indexes, query behavior, data compatibility, or rollback behavior.
- Refactoring code used by more than one package, service, route, job, or workflow.
- Removing code that appears unused.
- Changing Docker, CI, deployment, environment variables, or runtime config.
- Touching high-risk domains such as auth, wallet, order, payment, provider callbacks, missions, rewards, or user balances.

## Do not use when

- Editing isolated documentation.
- Changing comments only.
- Formatting code without behavior changes.
- Making a purely local copy change.
- Updating examples with no runtime effect.

## Required workflow

### 1. State the proposed change

Describe the intended change in one or two sentences.

### 2. Identify the change surface

List the affected surfaces:

- file/package/module
- symbol/function/type/method
- endpoint/route
- proto/service/message
- database table/migration/query
- event/routing key/queue
- config/env/secret
- Docker/CI/deployment
- frontend/mobile/provider/client contract

### 3. Search before editing

Use targeted search before making changes.

Check:

- exact symbol references
- naming variants
- route/path usage
- proto/gateway usage
- event names and routing keys
- table names and migration history
- tests, fixtures, mocks, generated files
- CI/deployment references
- docs/playbooks when relevant

### 4. Identify dependents

Identify:

- direct callers
- imports/dependents
- generated clients
- frontend/mobile usage
- provider/vendor usage
- tests affected
- runtime jobs/workers
- dashboards, metrics, alerts, or logs when relevant

### 5. Classify risk

Use this risk model:

- Low: isolated local implementation with no public contract change.
- Medium: shared package, service behavior, query behavior, or internal contract change.
- High: public API/gRPC/event contract, DB migration, auth, money, wallet, order, reward, provider callback, or deployment behavior.
- Critical: breaking change, data-loss risk, security risk, financial balance risk, irreversible migration, or production incident path.

### 6. Choose the safest change strategy

Prefer:

- minimal change
- additive compatible change
- feature flag or compatibility layer when needed
- migration with rollback path
- explicit client/provider coordination for contract changes
- tests around affected behavior

Avoid:

- silent breaking changes
- removing fields without compatibility review
- changing error/status semantics without client review
- rewriting unrelated code
- assuming unused code from weak evidence

### 7. Verify

Choose the strongest practical verification:

- targeted unit/integration tests
- build/typecheck/lint
- generated-code check
- migration dry run or rollback review
- API contract/schema comparison
- search-based confirmation
- manual inspection when commands cannot run

### 8. Report result

Report impact, evidence, verification, and remaining uncertainty.

## SocratiCode guidance

When available, use SocratiCode as a discovery layer:

- `codebase_search` for usage and naming variants
- `codebase_symbol` for symbol lookup
- `codebase_graph_query` for imports and dependents
- `codebase_graph_stats` for graph health/context
- `codebase_status` before relying on indexed context

SocratiCode is not the final source of truth. Confirm important findings against current repository files, tests, build output, CI, or runtime evidence.

## Evidence required

For each major impact claim, include at least one of:

- file path
- symbol/function/type/method
- route/proto/event/table/config key
- command/tool/search used
- line range when available
- result summary
- test/build/CI/log evidence when relevant

## Output format

```text
Change Impact Analysis

Proposed change:
-

Impact surface:
-

References found:
-

Dependents:
-

Risk level:
- Low / Medium / High / Critical
- Reason:

Safe change strategy:
-

Verification:
- Performed:
- Not performed:

Remaining uncertainty:
-