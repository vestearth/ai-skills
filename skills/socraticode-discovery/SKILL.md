---
name: socraticode-discovery
description: Use when starting repository-specific work with SocratiCode, codebase search, symbol lookup, graph analysis, or indexed context.
---

# SocratiCode Discovery Skill

Use SocratiCode as a navigation layer, not as the final source of truth.

## Use When

- Starting repository-specific work with SocratiCode, codebase search, symbol lookup, graph analysis, or indexed context.
- You need help locating candidate files, symbols, dependencies, callers, or related code.
- Prior summaries or memory need to be verified against the actual repository.

## Do Not Use When

- The task is fully self-contained and does not depend on repository structure.
- SocratiCode is unavailable and direct repository inspection is enough; state the fallback explicitly.
- The user asks for a final code claim without direct file verification.

## Goal

Use indexed discovery to navigate quickly, then verify all repository-specific claims against real files and evidence.

## Required Inputs

- User request or target concept.
- Primary project path and fallback project path.
- Relevant files, symbols, tests, build output, CI, logs, or runtime evidence after discovery.

## Process

1. Check index readiness with `codebase_status` using primary `projectPath: "d:\\llm"`.
   - If the call fails, hangs, times out, or is disconnected, retry with `projectPath: "/Users/earth/Documents/GitHub"` (local Docker SocratiCode on this machine — Qdrant + Ollama via `npx -y socraticode`).
   - If MCP is unusable, retry via local `npx -y socraticode` with the same projectPath order.
   - Only after both paths fail on MCP and CLI, fall back to direct repository inspection and say so explicitly.
2. Locate candidate files with `codebase_search`.
3. Inspect specific functions, structs, methods, or interfaces with `codebase_symbol` when available.
4. Use graph tools for dependency, caller/callee, or circular dependency investigation when available.
5. Read the actual repository files before making implementation claims.
6. Verify against tests, build output, CI, logs, or runtime evidence.

Source of truth:

Repository source code, tests, CI, and logs beat:

- indexed context
- summaries
- prior chat history
- generated explanations
- stale documentation

## Output Format

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
