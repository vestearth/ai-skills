---
name: model-router
description: Use when starting any task, delegating subtasks, or when task difficulty does not match the running model - routes work to the cheapest capable model (scout=Haiku exploration, worker=Sonnet scoped edits, reviewer=main-model review lane, auditor=completion audit, main model for reasoning) and advises /model and /effort switches to save quota.
---

# Model Router

## Use When

- Starting any new task in a Claude Code session.
- About to delegate a subtask to a subagent.
- The task class visibly does not match the model currently running (too cheap
  for the model, or too hard for it).

## Do Not Use When

- Mid-task on work already routed — do not re-route or second-guess per turn.
- The user explicitly pinned a model for this session; respect it silently.
- Inside a subagent — routing is the main loop's job.

## Goal

Every piece of work runs on the cheapest model that can do it well, without
the user micromanaging model choice: exploration on Haiku, scoped edits on
Sonnet, reasoning on the main model, and a one-line advisory when only the
user can make the switch.

## Required Inputs

- The task or subtask about to run.
- The currently running model (visible in session env info).
- Whether the instruction is complete (files + approach decided) or still
  needs requirement interpretation.

## Process

1. Classify the task and route it:

| Task class | Route to | Rate paid |
| --- | --- | --- |
| File search, codebase exploration, read-and-summarize, lookup questions | `scout` subagent | Haiku |
| Edits with files/approach already specified, tests following an existing pattern, rename/mechanical sweeps | `worker` subagent | Sonnet |
| Design, debugging without a known cause, contract/impact analysis | main model (do it yourself) | opusplan (Opus plan / Sonnet execute) |
| Code review of a PR/diff/branch and merge verdicts; independent audit of a claimed-done handoff | `reviewer` / `auditor` subagent (fresh context) | opusplan (inherits main model) |
| Exceptionally hard: incidents, large migrations, multi-service work | advisory: suggest `/model opus` | Opus |

2. Apply the dividing line before delegating to `worker`: if requirement
   interpretation is still needed, it is NOT worker work — resolve the
   ambiguity on the main model first, then delegate the now-complete
   instruction (or just do it yourself).
3. Treat `scout` output that feeds an important decision as a lead, not a
   fact: re-read the load-bearing files yourself before deciding.
4. Advisory (main-loop model only — you cannot switch it programmatically):
   on mismatch between task class and running model, suggest a switch in ONE
   line with a reason, e.g. "this session is purely mechanical — `/model
   sonnet` is cheaper" or "cross-service debugging — recommend `/model opus`".
   At most one suggestion per direction per session; if the user declines or
   ignores it, stay silent. A purely mechanical session may also get a single
   `/effort medium` suggestion.
5. Production-code policy is unchanged by routing: Games Labs code edits still
   require an open TASK- run regardless of which model executes them.

## Output Format

Routing is silent — no announcements for normal delegation; the delegation
itself (Agent tool call to `scout`/`worker`) is the output. The only
user-visible output this skill produces is the advisory line, at most one per
direction per session.

## Anti-patterns

- Delegating to `worker` while the instruction still has an open question —
  the cheaper model will guess, and guesses on production code are expensive.
- Sending review verdicts, design, or root-cause debugging to `scout` or
  `worker` to save quota — wrong-tier output costs more to fix than it saves.
- Nagging: repeating a declined `/model` or `/effort` suggestion.
- Trusting a `scout` summary verbatim for a load-bearing decision.
- Setting `CLAUDE_CODE_SUBAGENT_MODEL` — it silently overrides every agent's
  `model:` frontmatter and breaks the tiering.
