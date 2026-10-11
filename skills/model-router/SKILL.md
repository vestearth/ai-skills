---
name: model-router
description: Use when choosing model or effort for a new task or subtask, before review or audit delegation, or when task complexity does not match the running model in Claude Code, Codex, or Cursor.
---

# Model Router

## Use When

- Starting a task in Claude Code, Codex, or Cursor with guidance supplied.
- Considering permitted delegation, especially a review or completion audit.
- Task complexity visibly does not match the running model's capabilities.

## Do Not Use When

- Routine per-turn reclassification of work already routed.
- Overriding a user-pinned model or changing runtime configuration.
- Inside a subagent: routing belongs to the conductor; inherited verification
  guidance still applies.

## Goal

Recommend the lightest model and effort that can meet the task's quality bar,
using one shared policy with runner-specific mappings. Complexity informs the
recommendation; risk informs verification and review. This skill does not
change the parent model, defaults, or authorization/completion gates.

## Required Inputs

- Task, acceptance criteria, scope, execution role, and unresolved questions.
- Runner, actual parent model when observable, and any user-pinned choice.
- Available models/efforts and relevant runtime configuration or restrictions.
  Do not infer the active model from a saved default or from an Auto label.
- Office-provided risk/gates when present; otherwise source-backed risk signals
  and the target repository's verification and authorization requirements.

## Process

1. Classify **complexity**, independently of risk:
   - `quick`: lookup, read-and-summarize, or mechanical edits with no unresolved
     behavior decision.
   - `build`: bounded implementation or ordinary review with a clear target
     and approach.
   - `deep`: design, contract/impact analysis, unknown root cause, or decisions
     requiring reconciliation of conflicting evidence.
2. Establish **risk provenance** and preserve the applicable checks:
   - With Office context, consume its computed `low`/`medium`/`high` risk and
     existing gates. Do not run a competing classifier or deflate that result.
   - Without Office context, assess signals such as auth, money, migrations,
     production, data loss, and shared contracts from the request/source. Label
     this as a Router assessment, not an Office classification; do not write
     `risk_level` or task state.
   - `critical` may describe impact; it is not a new Office review-risk enum.
     Office sensitivity `critical` and review risk `high` are different terms.
     A small, clear Wallet/Auth fix can remain `build` with high-risk checks.
     A difficult high-impact decision may need `deep`; the path alone does not
     mandate the strongest implementation model. Routing never weakens checks,
     target-repo/task requirements, or human authorization gates.
3. Apply the runner mapping below as a recommendation, not a model switch.
   Prefer the current available catalog over a stale name/effort in this table.

| Complexity | Claude Code | Codex | Cursor |
| --- | --- | --- | --- |
| `quick` | Haiku; existing `scout` only when delegation is appropriate | `gpt-6-luna`, `low` | Current model/Auto; advise an available lighter model only if useful |
| `build` | Sonnet, `medium` when supported; existing `worker` for resolved instructions | `gpt-6.1-sol`, `medium` | Current model/Auto if capable of meeting the quality bar |
| `deep` | Opus, `high` when supported | `gpt-6.1-sol`, `high`; advise `xhigh` when needed | Advise an available reasoning model through per-task context |

   - **Claude:** use supported aliases rather than fixed version numbers.
     `opusplan` uses Opus in plan mode and Sonnet in execution; it does not
     guarantee an inherited reviewer runs on Opus. For a session-only change,
     advise the picker and its session-only confirmation (normally `s`) after
     checking the installed version/keybinding, or launch flags `--model` and
     `--effort`. Effort-picker `s` requires v2.1.257 or later. Interactive
     `Enter`, `/model <name>`, and `/effort <level>` can save defaults: never
     present them as session-only. Do not execute a switch, write settings, or
     set global overrides. See [model configuration](https://code.claude.com/docs/en/model-config).
   - **Codex:** for a highly ambiguous investigation or a demonstrated Sol
     capability gap, advise `gpt-6-astra`, `xhigh`. If Sol 6.1 is unavailable
     but Sol 6 supports the requested effort, recommend `gpt-6-sol` instead.
     If no suitable option is available, retain the current model and report
     the limitation; do not claim a switch. Do not default to `max`, `ultra`,
     or Fast. Use existing explorer/worker roles only when permitted. This
     skill does not change the separately installed Auto sidecar's policy.
   - **Cursor oracle mode:** pass only the relevant guidance inline per task;
     do not install persistent rules, skills, or agents. Mentioning Cursor in
     frontmatter does not wire or load the skill. Check guidance use only in
     that supplied context, not automatic skill discovery. `inherit` means
     the parent's model, not a separate Auto selection. Do not assume Codex
     model IDs or effort controls are supported by the Cursor account. See
     [Cursor subagents](https://cursor.com/docs/subagents).
4. Apply the **delegation and review preflight**:
   - Work solo by default. Delegate only with authorization and a bounded,
     useful subtask; do not create agents or a mandatory multi-agent pipeline.
     Resolve requirements/approach before assigning worker edits.
   - Before delegating Review/Audit, resolve the expected effective model from
     the parent, agent configuration, overrides, runtime version, restrictions,
     and fallbacks. `inherit` does not upgrade it; an omitted `model` field is
     not proof of a particular model. Check suitability for the complexity of
     the judgment and required verification, not just the agent's name. See
     [Claude subagents](https://code.claude.com/docs/en/sub-agents).
   - If unsuitable or unconfirmed, advise a session-only parent change or a
     supported review path. Do not silently override models or accept the
     verdict as approval evidence until this check holds; source/test evidence
     gathering may continue. A pinned model does not waive this requirement.
   - Review diff/source/tests before the implementer's rationale. The
     conductor inspects the actual diff and actual check output before sign-off;
     a subagent's "done" is a claim. Re-read load-bearing source behind scout
     summaries. Keep sign-off with the conductor.
5. Stay quiet on an adequate route and respect user-pinned choices. On a real
   mismatch, offer at most one short advisory per direction per session. Do
   not repeat a declined/ignored suggestion or recommend downgrading mid-task.
   Escalate only for new complexity/uncertainty or a demonstrated capability
   gap after a reasoned attempt; distinguish an environment failure first.

## Output Format

Normal routing is silent. For a mismatch, give one advisory with a reason and
state that the active model was not changed.

When explicitly asked for routing, report complexity, risk and its provenance,
recommended model/effort, and any availability or review-preflight limitation.
Separate recommendation, skill discovery, and actual model execution: only
claim execution on a model when runtime evidence confirms it. Loading this
skill or a successful installation command is not evidence of a model switch.

## Anti-patterns

- Equating a risky path with deep complexity or always choosing the top model.
- Inventing Office risk output, adding a `critical` review-risk enum, or
  reducing verification/authorization to fit a cheaper model.
- Treating an agent name, `inherit`, or omitted configuration as a capability
  guarantee; delegating judgment to a lookup/mechanical lane to save quota.
- Assigning unresolved requirements to a worker or trusting summaries instead
  of the actual diff, source, and check output.
- Silently switching models, persisting defaults/global overrides, or repeating
  declined advice.
- Setting `CLAUDE_CODE_SUBAGENT_MODEL` in Claude Code — it silently overrides
  every agent's `model:` frontmatter and breaks the scout/worker tiering.
- Claiming Cursor auto-discovery, model execution, or quota savings from skill
  text, installation exit codes, or recommendations alone.
