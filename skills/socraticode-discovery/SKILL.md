---
name: socraticode-discovery
description: Use when starting repository-specific work with SocratiCode, codebase search, symbol lookup, graph analysis, or indexed context.
---

# SocratiCode Discovery Skill

Use SocratiCode as a navigation layer, not as the final source of truth.

## Required flow

1. Check index readiness with `codebase_status`.
2. Locate candidate files with `codebase_search`.
3. Inspect specific functions, structs, methods, or interfaces with `codebase_symbol` when available.
4. Use graph tools for dependency, caller/callee, or circular dependency investigation when available.
5. Read the actual repository files before making implementation claims.
6. Verify against tests, build output, CI, logs, or runtime evidence.

## Source of truth

Repository source code, tests, CI, and logs beat:

- indexed context
- summaries
- prior chat history
- generated explanations
- stale documentation

## Output

- Index status
- Queries used
- Candidate files
- Verified files
- Confidence level
- Remaining unknowns

## Anti-patterns

- Treating search snippets as proof
- Answering repo-specific questions from memory
- Skipping actual file reads
- Hiding tool failures
