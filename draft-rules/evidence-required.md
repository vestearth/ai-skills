rules/evidence-required.md

อันนี้ควรเป็น global rule มากกว่า skill

ใจความ:

When making claims about the codebase, the agent must provide evidence:
- file path
- symbol/function/type name
- line range if available
- command/tool used
- result summary

ตัวอย่าง claim ที่ต้องมี evidence:

This function is unused.
This endpoint is already implemented.
This service is safe to refactor.
This dependency is not needed.
This bug comes from X.

ห้ามตอบลอย ๆ แบบ:

Looks like this is unused.

เพราะ “looks like” ในปาก AI บางทีก็แปลว่า “ผมเดาอย่างมั่นใจและหวังว่าคุณจะไม่เปิด grep เช็ก”

# Draft 1

# Evidence Required

Agents must not make claims about the codebase without evidence.

This rule applies to implementation, debugging, review, refactoring, release, and handoff work.

## Applies to

Use this rule when making claims such as:

- This function is unused.
- This endpoint is already implemented.
- This service is safe to refactor.
- This dependency is not needed.
- This bug comes from a specific file, function, service, query, config, or deployment setting.
- This change has no affected tests.
- This behavior is already covered.
- This API response shape is safe for clients.
- This migration is backward compatible.

## Required evidence

For each meaningful codebase claim, include at least one concrete evidence item:

- file path
- symbol, function, type, method, route, table, event, config key, or workflow name
- line range when available
- command, tool, or search query used
- result summary
- test, build, CI, log, or production signal when relevant

## Source of truth order

Prefer evidence in this order:

1. Current repository files
2. Tests, build output, lint, typecheck, or CI
3. Runtime logs, metrics, traces, dashboards, or production signals
4. Generated artifacts, schemas, protobuf, OpenAPI, or migration files
5. Indexed/search context such as SocratiCode
6. Previous summaries or chat history

Indexed context and AI memory are discovery aids, not final proof.

## Required behavior

- Search or inspect before making codebase claims.
- Separate verified facts from assumptions.
- State uncertainty when evidence is incomplete.
- Do not present guesses as verified facts.
- Do not say tests, build, lint, or CI passed unless they actually ran.
- Do not claim code is unused only because one search query returned nothing.
- Do not claim compatibility without checking callers, contracts, or migration impact.

## Failure behavior

If evidence cannot be collected, say so clearly.

Use wording like:

> I did not verify this with tests or build output.
> I found no reference from the searched paths, but this is not a full unused-code proof.
> This is an assumption based on the available files, not confirmed runtime behavior.

## Output expectation

When evidence matters, include a short evidence block:

```text
Evidence:
- path/to/file.go: FunctionName
- Search/tool: codebase_search "FunctionName"
- Result: 3 references found, all inside package X
- Verification: go test ./... not run