1. code-search-before-create

ให้แตกออกมาจาก search-first

ชื่อที่เหมาะกับ:

rules/code-search-before-create.md

ใจความ:

Before creating a new service/helper/interface/DTO/middleware/hook/config:
1. Search the codebase first.
2. Check naming variants.
3. Check existing package/module conventions.
4. Reuse or extend existing implementation if possible.
5. Only create new code when evidence shows no suitable existing code.

เหมาะกับ SocratiCode มาก เพราะสั่งให้ agent ใช้ codebase_search, codebase_symbol, หรือ graph ก่อนเขียนใหม่

เพราะมันควรทำตลอด ก่อนสร้าง:

service
helper
interface
DTO
middleware
config
hook
script

ไม่ใช่เรียกเฉพาะบางครั้ง

# Draf1 

# Search Before Create

Before creating new files, modules, helpers, abstractions, configs, scripts, hooks, workflows, or documentation patterns, agents must search for existing implementation first.

This rule prevents duplicate abstractions and keeps the codebase consistent.

## Applies before creating

- service
- repository
- helper
- utility
- interface
- DTO, request, response, or view model
- middleware
- adapter
- config
- hook
- script
- workflow
- CI job
- test fixture
- documentation template
- generated-code wrapper
- package or module

## Required behavior

1. Search the exact intended name.
2. Search naming variants and related domain terms.
3. Search existing package, folder, and module conventions.
4. Inspect the closest existing implementation.
5. Prefer reuse, extension, or small modification over creating a new abstraction.
6. Create new code only when existing code is missing, unsafe to reuse, or clearly belongs to a different responsibility.
7. Explain why a new artifact is necessary.

## Search targets

Use the most relevant available tools:

- repository search
- grep/ripgrep
- IDE symbol search
- SocratiCode `codebase_search`
- SocratiCode `codebase_symbol`
- SocratiCode `codebase_graph_query`
- existing tests and fixtures
- generated files, routes, protobuf, schemas, or migrations when relevant

## Required evidence

When creating something new, include:

- search terms used
- existing candidates found
- why candidates were reused, extended, or rejected
- why the new artifact is needed

## Avoid

- Creating `Helper`, `Util`, `Common`, or `Manager` abstractions without checking existing domain ownership.
- Creating duplicate DTOs for the same API shape.
- Creating new middleware when existing middleware can be configured or extended.
- Creating new CI scripts without checking current pipeline conventions.
- Creating new folders just because the agent prefers a different structure.

## Output expectation

```text
Search-before-create:
- Searched: "WalletService", "wallet service", "wallet helper"
- Existing candidates: services/wallet, shared-lib/walletpb
- Decision: extend existing service method instead of creating WalletHelper
- Reason: behavior belongs to current wallet domain boundary