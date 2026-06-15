# Evidence Required

Use this rule whenever an agent makes a claim about repository behavior, code ownership, safety, risk, test status, compatibility, or root cause.

## Required Behavior

- Inspect source-of-truth evidence before making codebase claims.
- Cite files, symbols, commands, tests, logs, CI, or production signals when the conclusion depends on them.
- Separate verified facts from assumptions.
- State uncertainty when evidence is incomplete.
- Do not say tests, build, lint, typecheck, CI, or deployment passed unless they actually ran.

## Claims That Need Evidence

Examples:

- This function is unused.
- This endpoint is already implemented.
- This service is safe to refactor.
- This dependency is not needed.
- This bug comes from a specific file, function, query, config, service, or deployment.
- This API response shape is safe for clients.
- This migration is backward compatible.

## Source of Truth Order

Prefer evidence in this order:

1. Current repository files
2. Tests, build output, lint, typecheck, or CI
3. Runtime logs, metrics, traces, dashboards, or production signals
4. Generated artifacts, schemas, protobuf, OpenAPI, or migration files
5. Indexed/search context such as SocratiCode
6. Previous summaries or chat history

Indexed context and AI memory are discovery aids, not final proof.

## Output Evidence

Use a compact evidence block when evidence matters:

```text
Evidence:
- File/symbol:
- Search/tool:
- Result:
- Verification:
```

## Anti-patterns

- Saying "looks unused" after one failed search.
- Claiming compatibility without checking callers or contracts.
- Treating generated code, stale index results, or old summaries as final proof.
- Hiding unverified assumptions behind confident wording.
