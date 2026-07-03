---
name: mcp-audit
description: Use when sessions feel token-heavy or slow and connected MCP servers should be audited for tool-count overhead, redundancy, and actual usage.
---

# MCP Audit

## Use When

- Sessions start slow, hit context pressure early, or feel token-heavy for their task size.
- Before adding a new MCP server to an already busy configuration.
- The user asks which MCP servers cost the most or which are safe to disable.

## Do Not Use When

- Debugging one server's connection or auth failure; that is troubleshooting, not an audit.
- The configuration has only a couple of small servers and no context pressure.

## Goal

Produce an evidence-based inventory of connected MCP servers with estimated per-request overhead and actual usage, ending in propose-only disable/scope recommendations.

## Required Inputs

- MCP configuration at every active scope (project `.mcp.json`, user settings, plugins).
- Tool counts per server, and whether the client defers tool schemas or loads them all upfront.
- Recent usage: which servers' tools were actually called in this project's sessions.

## Process

1. Inventory every configured server across scopes, with its tool count and where it is registered.
2. Estimate per-request overhead from tool count — roughly hundreds of tokens for a small server to thousands for 30+ tools — and label estimates as heuristics, not measurements. Deferred/lazy-loaded tools cost far less upfront; note which mechanism applies.
3. Check redundancy: tools that overlap built-in capabilities or duplicate another server's.
4. Check usage: servers whose tools have not been called in recent sessions of this project are disable candidates.
5. Recommend per project, not globally: keep frequently used servers with unique capabilities, scope project-specific servers to their project, and propose disabling or filtering the rest.
6. Present the audit and projected savings; change configuration only after the user approves.

## Output Format

- Server inventory: name, scope, tool count, load mechanism (upfront vs deferred)
- Estimated per-request overhead per server, marked as estimates
- Redundancy and usage assessment per server
- Recommendations: keep / scope to project / disable, with rationale
- Projected token savings if recommendations are applied

## Anti-patterns

- Presenting token estimates as measured facts.
- Disabling servers without user approval.
- Keeping a high-overhead server "just in case" with no observed usage.
- Auditing tool counts while ignoring whether the client defers schemas.
- Global recommendations when the problem is one project's configuration.
