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
  api-contract-review/ -> ai-skills/skills/api-contract-review/
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
`adapters/claude/agents/`, and is wired from the shared named-agent manifest:

```bash
scripts/install-agents.sh --lane claude --target <workspace>
scripts/install-agents.sh --lane claude --target <workspace> --check
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

## Hooks

Skills, rules, and adapters are all *text an agent may ignore*. Claude Code
hooks are the only lane in this repo that can actually stop a tool call, so the
hook scripts live here as source of truth and are mirrored into a workspace:

```bash
scripts/install-claude-hooks.sh              # nested: into <parent-of-ai-skills>/.claude/hooks
scripts/install-claude-hooks.sh --nested DIR
scripts/install-claude-hooks.sh --standalone
scripts/install-claude-hooks.sh --user
```

It symlinks each `adapters/claude/hooks/*.sh` into the target `.claude/hooks/`,
prunes stale links, runs the hook tests, and reports which hooks are not yet
referenced by `settings.json`. It deliberately **does not edit settings.json** —
which matchers to enable is operator policy, so the script prints the snippet
instead. Smoke-test with `scripts/test-install-claude-hooks.sh`.

Enforcement hooks (both PreToolUse, both `exit 2` to block, enforcing
`rules/no-secrets-in-repo/RULE.md`):

- `guard-env-write.sh` — matcher `Edit|Write|MultiEdit|NotebookEdit`. Blocks
  edits to real `.env` files by basename; templates (`.env.example`, `.sample`,
  `.template`, `.dist`) are allowed.
- `guard-env-bash.sh` — matcher `Bash`. Parses `.tool_input.command`: scrubs
  heredoc bodies (data, not shell — unless the command feeds a shell), tokenizes
  to find a real `.env`, then decides whether a write is aimed at it. Fails
  **closed** if `jq` is missing or the payload is unparseable.
  `tests/run-env-guard-tests.sh` runs its 48-case table.

Hygiene hook (PostToolUse, mutating — never blocks, always `exit 0`):

- `clean-invisible-unicode.sh` — matcher `Edit|Write|MultiEdit|NotebookEdit`.
  Strips invisible Unicode in place from every text file an agent writes, so
  zero-width and bidi characters cannot ride into a commit unnoticed. It does
  **not** reimplement the codepoint policy: it shells out to
  watermarks-remover's own `clean_text.py` (located via
  `WATERMARKS_REMOVER_DIR`, default `$HOME/Documents/GitHub/watermarks-remover`),
  which is context-sensitive about load-bearing invisibles — emoji ZWJ glue,
  variation selectors, complete flag tag sequences, and script joiners survive;
  ZWSP, BOM, bidi overrides, and soft hyphen do not. A hand-rolled list in bash
  would mangle the first group, which is why this hook has no policy of its own.
  Runs with `--no-normalize-spaces`: visible-width spaces (NBSP, thin space)
  carry intent in prose and are left to an explicit `remove-ai-marks` run.
  Skips `tests/`, `fixtures/`, `testdata/` (fixtures encode marks on purpose),
  binaries, and files over 2 MB. Missing runtime, refusal, or any error exits 0
  silently — hygiene must never cost a tool call. Reports what it removed to the
  model via `hookSpecificOutput.additionalContext`, because the file on disk no
  longer matches what the tool wrote. `tests/run-invisible-unicode-tests.sh`
  runs its 12-case table.

Routing hook (UserPromptSubmit, advisory — never blocks, always `exit 0`):

- `skill-routing.sh` — injects, via `hookSpecificOutput.additionalContext`, two
  lanes split by how a skill is actually triggered:
  - **Core block (always shown):** the intent-routed skills (`search-first`,
    `debugging`, `verification-loop`, `code-review`, ...) — the model judges
    applicability itself. Keyword rows for these were measured at 1/14 hits on
    natural Thai phrasing ("ผ่านไหม", "พร้อมขึ้นยัง"), because Thai expresses
    one intent in unbounded surface forms; adding keywords never converges.
  - **Keyword table (cap 6 matches/prompt):** domain skills anchored to stable
    English technical nouns (proto, argocd, clickhouse, ...) — measured 17/17.
    Six borderline skills sit in both lanes deliberately.

  Exists because ai-skills are description-matched only: transcript counts
  showed roughly one skill invocation per session, all of them review-shaped,
  while `search-first`, `debugging`, and `verification-loop` never fired.
  Skips slash commands, which carry their own instructions. Both lanes live
  inline in the script — a new skill gets a table row (domain), a core-block
  line (intent), or neither (operator-invoked; list in the script comment).

**Scope, stated honestly:** pattern matching over a Turing-complete shell cannot
be sound against an agent actively evading it — a script file that writes `.env`
from inside still passes. These hooks are a hard stop for accidental and casual
writes, which is the realistic failure mode; they are not a security boundary,
and they bind the Claude lane only (Codex and Cursor do not read
`.claude/settings.json`). The first version of `guard-env-bash.sh` passed its own
32-case suite while carrying four critical bypasses — change it only with the
case table, and add a case for every bypass found.

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
