# Search Before Create

Use this rule before creating new files, modules, helpers, abstractions, configs, scripts, hooks, workflows, fixtures, DTOs, interfaces, or documentation patterns.

## Required Behavior

1. Search the exact intended name.
2. Search naming variants and related domain terms.
3. Search existing package, folder, and module conventions.
4. Inspect the closest existing implementation.
5. Reuse, configure, extend, or make a small local edit when possible.
6. Create a new artifact only when existing code is missing, unsafe to reuse, or belongs to a different responsibility.
7. Explain why the new artifact is necessary.

## Search Targets

Use the most relevant available tools:

- Repository search or `rg`
- IDE symbol search
- SocratiCode `codebase_search`, `codebase_symbol`, or `codebase_graph_query`
- Existing tests, fixtures, generated files, routes, schemas, protobuf, migrations, workflows, and docs

## Output Evidence

When creating something new, include:

- Searched: exact terms and variants
- Existing candidates: files, symbols, modules, dependencies, or none
- Decision: reuse, extend, reject, or create
- Reason: why the chosen option fits the current ownership boundary

## Anti-patterns

- Creating `Helper`, `Util`, `Common`, or `Manager` abstractions before checking domain ownership.
- Creating duplicate DTOs for the same API shape.
- Creating middleware, hooks, scripts, or workflows without checking current conventions.
- Creating folders just because another structure would look cleaner.
