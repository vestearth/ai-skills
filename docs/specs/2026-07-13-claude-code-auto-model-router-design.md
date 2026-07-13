# Design - `model-router` skill + tiered subagents (Claude Code auto model selection)

Date: 2026-07-13
Status: Approved (brainstorming) - pending implementation plan
Base: uses only official Claude Code mechanisms (subagent `model` frontmatter, `opusplan`, `/model`, `/effort`); wired through the existing ai-skills symlink pipeline

## Purpose

Reduce Max-plan quota burn in interactive Claude Code sessions by automatically running each task class on the cheapest model that can do it well:

- exploration and lookup work on Haiku
- well-scoped mechanical edits on Sonnet
- reasoning-heavy work on the main model (`opusplan`: Opus for plan mode, Sonnet for execution)
- an advisory nudge (`/model`, `/effort`) for the one thing Claude cannot switch itself: the main-loop model

## Constraints (verified against code.claude.com docs, July 2026)

- Claude Code has no built-in per-task auto routing.
- Hooks cannot change the model (they can only observe it). Main-loop model switching is user-driven only (`/model`, `--model`, Agent SDK).
- Subagents CAN choose their model: `.claude/agents/*.md` frontmatter `model:` field (aliases `haiku`/`sonnet`/`opus`/`fable`, full IDs, or `inherit`), overridable per invocation.
- `opusplan` is an official model alias: Opus during plan mode, Sonnet during execution.
- `CLAUDE_CODE_SUBAGENT_MODEL` env var overrides agent frontmatter — must stay unset for this design to work.

## Components

All three components are config/markdown. No running code, nothing to maintain beyond the files.

### 1. Tiered agent definitions (`ai-skills/agents/`, symlinked to `GitHub/.claude/agents/`)

| Agent | `model` | Job | Tools |
| --- | --- | --- | --- |
| `scout` | `haiku` | Find files, grep/explore the codebase, read-and-summarize, lookup questions | Read, Grep, Glob only — no Bash, so the read-only guarantee is enforced at the tool level (trade-off: scout cannot run git-history queries; the main model does those itself) |
| `worker` | `sonnet` | Edits with file/approach already specified, tests following an existing pattern, mechanical refactors/rename sweeps | Full edit set |

Reasoning-heavy work (design, unknown-cause debugging, review, cross-service impact) is never delegated — it stays on the main model.

Source of truth is the `ai-skills` repo (new `agents/` directory), symlinked into `GitHub/.claude/agents/` — mirroring the existing skills convention. ai-skills is a meta repo, so no TASK- run is required.

### 2. `model-router` skill (`ai-skills/skills/model-router/`)

Registered in VERSION.md + README.md and symlinked like every other skill. It carries the routing table and advisory rules below, applied whenever a new task starts or work is about to be delegated.

### 3. Default model change (`~/.claude/settings.json`)

`"model": "claude-opus-4-8"` → `"model": "opusplan"`.

This is the single largest saver: execution tokens (the bulk of any session) drop to Sonnet rates while planning keeps Opus. It is an official, supported alias — no custom mechanism involved.

## Routing table

| Task class | Runs on | Rate paid |
| --- | --- | --- |
| File search, codebase exploration, read-and-summarize, lookup questions | `scout` | Haiku |
| Edits with file/approach specified, tests following a pattern, rename/mechanical sweeps | `worker` | Sonnet |
| Design, debugging without a known cause, code review, contract/impact analysis | main model | opusplan (Opus plan / Sonnet execute) |
| Exceptionally hard: incidents, large migrations, multi-service work | advisory → suggest `/model opus` | Opus |

**Dividing line:** if requirement interpretation is still needed, it does not go to `worker`. Delegate only when the instruction is complete enough that a cheaper model cannot guess wrong.

## Advisory rules (for the main-loop model, which cannot be switched programmatically)

- On receiving a new task, assess its class against the currently running model. On mismatch, suggest a one-line switch with a reason, e.g. "this is purely mechanical — `/model sonnet` is cheaper" or "cross-service debugging — recommend `/model opus`".
- **At most one suggestion per direction per session.** If the user declines, stay silent.
- Covers `/effort` too: a purely mechanical session may get a one-time `/effort medium` suggestion (effort also burns quota).

## Guardrails

- `scout` is read-only at the tool level — even if routing misfires, write work cannot land on Haiku.
- Scout output that feeds an important decision: the main model re-reads the load-bearing spots itself (protects against a Haiku summary being subtly wrong and propagating).
- Games-Labs production code changes remain under the TASK- run policy as usual — the router changes nothing there.
- Document that `CLAUDE_CODE_SUBAGENT_MODEL` must not be set (it silently overrides agent frontmatter models).

## Verification

1. Three sample sessions: pure lookup / scoped edit / hard design task. Confirm delegation actually happens and the right model runs each piece (visible in the transcript/agent list).
2. One week of real use: usage limit should stretch noticeably further.

Success criteria: explore/mechanical work runs on Haiku/Sonnet without being told, and main-task quality does not drop.

## Out of scope (deliberately)

- `cauto` wrapper (classify-then-launch shell function) — possible later addition, not part of this design.
- Agent SDK custom shell — rejected: rebuilding the Claude Code UI is not worth it for a quota goal.
- Any mechanism that pretends to auto-switch the main-loop model — not supported by Claude Code; advisory is the honest ceiling.
