---
name: socraticode-discovery
description: Use when SocratiCode is the intended discovery tool, index readiness matters, or codebase search, symbol lookup, graph analysis, or indexed context must be verified against current files.
---

# SocratiCode Discovery Skill

Use SocratiCode as a navigation layer, not as the final source of truth.

## Use When

- The user or project instructions explicitly call for SocratiCode, codebase search, symbol lookup, graph analysis, or indexed context.
- SocratiCode index readiness, capability, routing, or project coverage must be checked.
- You need help locating candidate files, symbols, dependencies, callers, or related code.
- Prior summaries or memory need to be verified against the actual repository.

## Do Not Use When

- The task is fully self-contained and does not depend on repository structure.
- General repository discovery can be handled with direct search and file inspection; use `search-first`.
- SocratiCode is unavailable and direct repository inspection is enough; state the fallback explicitly.
- The user asks for a final code claim without direct file verification.

## Goal

Use indexed discovery to navigate quickly, then verify all repository-specific claims against real files and evidence.

## Required Inputs

- User request or target concept.
- Project path from project instructions, workspace context, or current repository root.
- Relevant files, symbols, tests, build output, CI, logs, or runtime evidence after discovery.

## Process

1. Check index readiness with `codebase_status` using the project path from project instructions, workspace context, or the current repository root.
   - If multiple indexed project paths are plausible, try the most specific path first and record any fallback path used.
   - If MCP is unusable, retry through the configured SocratiCode CLI when available.
   - Only after the configured MCP and CLI paths fail, fall back to direct repository inspection and say so explicitly.
2. When the task is about SocratiCode readiness, capability, or routing, add the smallest read-only baseline:
   - `codebase_health` to verify Docker, Qdrant, Ollama, and embedding model health.
   - `codebase_list_projects` to verify which project paths are actually indexed.
   - `codebase_about` to confirm the exposed tool overview from SocratiCode itself.
3. Locate candidate files with `codebase_search`.
4. Inspect specific functions, structs, methods, or interfaces with `codebase_symbol` when available.
5. Use graph tools for dependency, caller/callee, or circular dependency investigation when available.
6. Read the actual repository files before making implementation claims.
7. Verify against tests, build output, CI, logs, or runtime evidence.

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
