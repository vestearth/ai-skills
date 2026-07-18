# Claude Adapter

Expose `ai-skills` to Claude Code as a skill library.

## Recommended Setup

Run the installer from the `ai-skills/` checkout; do not hand-copy or hand-symlink
skill folders (that is how the mirror drifts when skills are added or removed):

```bash
scripts/install-claude.sh              # nested: into <parent-of-ai-skills>/.claude/skills
scripts/install-claude.sh --nested DIR # into DIR/.claude/skills
scripts/install-claude.sh --standalone # into ai-skills/.claude/skills
scripts/install-claude.sh --user       # into ~/.claude/skills
```

It mirrors every `skills/<name>/` (folder name and `SKILL.md` preserved) as an
absolute symlink, so repo edits and `git pull` flow through. Resulting layout:

```text
<workspace-root>/.claude/skills/
  debugging/          -> ai-skills/skills/debugging/
  code-review/        -> ai-skills/skills/code-review/
  grpc-contract-review/ -> ai-skills/skills/grpc-contract-review/
```

The installer prunes stale mirror entries (symlinks pointing at deleted or renamed
skills), leaves unrelated libraries untouched, then runs `scripts/validate-skills.sh`.
The validator checks source skill metadata, required sections, README/VERSION
coverage, and Codex/Cursor routing coverage — it does not inspect the installed
`.claude/skills` mirror. New or removed skills take effect in the next Claude Code
session. Smoke-test the installer with `scripts/test-install-claude.sh`.

## Subagents

Claude Code subagents (`.claude/agents/<name>.md`) are a Claude-lane wiring artifact
— a lane that activates a task, distinct from ai-dev-office role personas (behavior)
and from skills (task triggers). Their source of truth lives here, under
`adapters/claude/agents/`, and is wired into a workspace by an absolute symlink,
mirroring how `skills/` is mirrored into `.claude/skills/`:

```bash
ln -sfn "$PWD/adapters/claude/agents/<name>.md" "<workspace>/.claude/agents/<name>.md"
```

Subagent bodies reference repo paths relative to the **workspace root** (the dir
Claude Code runs from), so they resolve correctly through the symlink. Keep them
read-only / suggest-only where they touch durable state.

Current subagents:

- `knowledge-capturer` — post-task, read-only; emits a suggest-only
  `runs/<task-id>/knowledge-capture-output.yaml` capture proposal
  (workflow: `ai-dev-office/workflows/knowledge-capture.md`; never writes the vault
  or commits). Codex/Cursor use the lane-neutral runner
  `ai-dev-office/scripts/knowledge-capture.rb` instead.
- `knowledge-librarian` — session-closeout/weekly/on-demand vault-health review; emits a validated
  `ai-dev-office/knowledge-reviews/` audit and defaults to proposal-only. It may
  write only inside a product scope explicitly authorized by the target
  `knowledge-base/AGENTS.md`, with post-write human review and no commit/push.
- `scout` — read-only Haiku explorer for file search, codebase exploration, and
  lookup questions; routed by `skills/model-router`. No Bash by design (the
  read-only guarantee is tool-level); the main model runs git-history queries.
- `worker` — Sonnet implementer for edits whose files and approach are already
  specified; returns BLOCKED instead of interpreting ambiguous requirements;
  routed by `skills/model-router`.
- `reviewer` — main-model read-only review lane for PR/diff/branch review and
  merge-readiness verdicts; routes the diff into `skills/code-review` plus the
  matching domain overlays; may run read-only git and tests via Bash but never
  edits files or git state; routed by `skills/model-router` (completes the
  scout/worker/reviewer triad). No `model:` line — inherits the main session model.
- `auditor` — main-model independent completion audit of handoffs claimed done
  by another agent, session, Codex run, or office runner; a harness around
  `skills/completion-audit` that re-runs claimed checks against the real diff and
  requires re-observed evidence per accepted claim; read-only, never edits files
  or git state. No `model:` line — inherits the main session model.

See `30 ADR/ADR-0006 Claude Subagents Live In ai-skills Adapters` in `knowledge-base`.

## Rules

1. Preserve each `SKILL.md` exactly when installing.
2. Use the smallest relevant skill for the task.
3. Treat skills as guidance, not evidence.
4. Source code, tests, CI, logs, production evidence, and user instructions override skill guidance.
5. Apply `minimal-change-review` before code, file, dependency, scaffold, or workflow changes.
6. Apply `verification-loop` before completion, fix, merge, deploy, or handoff claims.
7. Apply `knowledge-query`, `knowledge-capture`, `knowledge-promote`, or `knowledge-source-review` when working with `knowledge-base/`.
8. Prefer v2 core/domain-specific skills before compatibility skills.
9. Keep this adapter thin; do not duplicate full skill bodies here.

## Compatibility Fallbacks

Use compatibility skills only when no more specific v2 skill applies.

- Use `api-contract-review` for generic API contract work.
- Use `vendor-integration` for generic third-party integration work.

Prefer:

- `games-labs-api-review` before `api-contract-review` for Games Labs API work.
- `grpc-contract-review` before `api-contract-review` for protobuf/gRPC/gateway work.
- `seamless-provider-review` before `vendor-integration` for seamless game provider work.
