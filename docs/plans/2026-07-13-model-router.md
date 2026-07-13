# Model Router Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Auto model selection for Claude Code — route each task class to the cheapest capable model (scout=Haiku, worker=Sonnet, main=opusplan) to save Max-plan quota.

**Architecture:** Three config-only components: two tiered subagent definitions in `adapters/claude/agents/`, one routing skill in `skills/model-router/`, and a one-line default-model change in `~/.claude/settings.json`. No running code. Spec: `docs/specs/2026-07-13-claude-code-auto-model-router-design.md`.

**Tech Stack:** Claude Code agent/skill markdown, ai-skills validator (`scripts/validate-skills.sh`), installer (`scripts/install-claude.sh`).

## Global Constraints

- All work happens in `/Users/earth/Documents/GitHub/ai-skills` (meta repo — no TASK- run required). The workspace root that consumes the artifacts is `/Users/earth/Documents/GitHub`.
- `scripts/validate-skills.sh` must exit 0 before any commit that touches `skills/`. It requires: frontmatter on line 1, `name` matching the folder, `description` present, and these exact sections: `## Use When`, `## Do Not Use When`, `## Goal`, `## Required Inputs`, `## Process`, `## Output Format`, `## Anti-patterns`. Every skill name must appear backticked in `VERSION.md`.
- Skill wiring goes through `scripts/install-claude.sh` (never hand-symlink skills). Agent wiring is a manual `ln -sfn` per `adapters/claude/README.md`.
- The env var `CLAUDE_CODE_SUBAGENT_MODEL` must NOT be set anywhere (it silently overrides agent `model:` frontmatter).
- New skills/agents take effect in the NEXT Claude Code session, not the current one.

---

### Task 1: `scout` agent definition (Haiku, read-only)

**Files:**
- Create: `adapters/claude/agents/scout.md`

**Interfaces:**
- Produces: an agent named `scout` that Task 3's skill routes exploration work to, and Task 4 symlinks into the workspace.

- [ ] **Step 1: Write the agent file**

Create `adapters/claude/agents/scout.md` with exactly this content:

```markdown
---
name: scout
description: Cheap read-only explorer on Haiku. Use for file search, codebase exploration, read-and-summarize, and lookup questions ("where is X", "what does Y do", "which files touch Z"). Never for edits, judgment calls, or review verdicts.
tools: Read, Grep, Glob
model: haiku
---

You are **scout** — a fast, cheap, read-only explorer. You run on a small model
by design: your job is coverage and retrieval, not judgment.

## Job

Given a lookup or exploration request, find the answer in the repository and
report it with evidence. Typical asks: locate a route/symbol/config, map which
files touch a feature, read a file and summarize what it does, list call sites.

## Rules

1. **Read-only.** You have no edit or shell tools. If the ask requires running
   commands (git history, builds, tests), report that limitation instead of
   guessing — the caller runs those itself.
2. **Evidence per claim.** Every finding cites `path/to/file.go:line`. If you
   did not read it, do not claim it.
3. **No verdicts.** Do not judge code quality, propose fixes, or make review
   calls. Describe what exists; the caller decides.
4. **Say "not found" plainly.** If you cannot find something after searching
   the obvious names and locations, list what you searched and stop. A wrong
   confident answer is worse than a miss.
5. **Stay small.** Return the shortest answer that fully covers the ask —
   findings first, one line each, no essay.

## Output

Findings as a short list: `<file:line> — <one-line what/why it matters>`.
End with `NOT FOUND: <what> (searched: <patterns/dirs>)` for any miss, and
`LIMIT: <what you could not do>` if the ask needed tools you lack.
```

- [ ] **Step 2: Verify frontmatter fields are present**

Run:
```bash
cd /Users/earth/Documents/GitHub/ai-skills
awk 'NR==1{exit ($0=="---")?0:1}' adapters/claude/agents/scout.md && grep -c '^name: scout$\|^model: haiku$\|^tools: Read, Grep, Glob$' adapters/claude/agents/scout.md
```
Expected: no error from `awk` (frontmatter starts line 1) and the grep prints `3`.

- [ ] **Step 3: Commit**

```bash
git add adapters/claude/agents/scout.md
git commit -m "feat(agents): add scout — read-only Haiku explorer for model routing"
```

---

### Task 2: `worker` agent definition (Sonnet, scoped edits)

**Files:**
- Create: `adapters/claude/agents/worker.md`

**Interfaces:**
- Produces: an agent named `worker` that Task 3's skill routes well-specified edit work to, and Task 4 symlinks into the workspace.

- [ ] **Step 1: Write the agent file**

Create `adapters/claude/agents/worker.md` with exactly this content:

```markdown
---
name: worker
description: Sonnet implementer for well-specified edits. Use when the instruction already names the files and the approach - scoped code changes, tests following an existing pattern, mechanical refactors and rename sweeps. Never for work that still needs requirement interpretation.
tools: Read, Grep, Glob, Bash, Write, Edit
model: sonnet
---

You are **worker** — an implementer for edits whose scope is already decided.
You run on Sonnet by design: the thinking happened upstream; your job is clean,
verified execution.

## Job

Execute the edit exactly as specified: the caller tells you which files, what
change, and how to verify. Typical asks: apply a described fix, write tests
mirroring an existing pattern, perform a rename/mechanical sweep, add a field
end-to-end following an example the caller points at.

## Rules

1. **Do not interpret requirements.** If the instruction has a gap — a file it
   does not name, a behavior choice it does not make, two readings that both
   fit — STOP and return the question instead of picking. An escalation is a
   success, not a failure.
2. **Match the surrounding code.** Follow the existing style, naming, comment
   density, and idiom of each file you touch. No refactors beyond the ask, no
   drive-by cleanups, no added abstractions.
3. **Verify before reporting.** Run the check the caller specified (test,
   build, grep for stragglers). If they specified none and a cheap one exists
   (the file's test target, `go build ./...`), run it. Report results verbatim
   — failures included.
4. **Touch only named files** plus files the named change forces (e.g. a
   generated mock). List every file you touched in the report.

## Output

`DONE: <one line per file changed>` + `VERIFIED: <command> -> <result>`, or
`BLOCKED: <the exact question the caller must answer>` with no partial edits
left behind (revert anything half-applied before returning BLOCKED).
```

- [ ] **Step 2: Verify frontmatter fields are present**

Run:
```bash
grep -c '^name: worker$\|^model: sonnet$' adapters/claude/agents/worker.md
```
Expected: prints `2`.

- [ ] **Step 3: Commit**

```bash
git add adapters/claude/agents/worker.md
git commit -m "feat(agents): add worker — Sonnet implementer for well-specified edits"
```

---

### Task 3: `model-router` skill

**Files:**
- Create: `skills/model-router/SKILL.md`
- Modify: `VERSION.md` (V3 skill status table)
- Modify: `README.md` (skill catalog table)

**Interfaces:**
- Consumes: agent names `scout` and `worker` from Tasks 1–2 (referenced by name in the routing table).
- Produces: skill `model-router`, registered so `scripts/validate-skills.sh` exits 0.

- [ ] **Step 1: Create the skill with frontmatter only (failing state)**

```bash
mkdir -p skills/model-router
cat > skills/model-router/SKILL.md <<'EOF'
---
name: model-router
description: Use when starting any task, delegating subtasks, or when task difficulty does not match the running model - routes work to the cheapest capable model (scout=Haiku exploration, worker=Sonnet scoped edits, main model for reasoning) and advises /model and /effort switches to save quota.
---
EOF
```

- [ ] **Step 2: Run the validator to verify it fails**

Run: `scripts/validate-skills.sh`
Expected: FAIL — lines like `model-router: missing section '## Use When'` (7 missing-section errors) plus `VERSION.md: missing skill 'model-router'`.

- [ ] **Step 3: Write the full skill body**

Replace `skills/model-router/SKILL.md` with exactly this content:

```markdown
---
name: model-router
description: Use when starting any task, delegating subtasks, or when task difficulty does not match the running model - routes work to the cheapest capable model (scout=Haiku exploration, worker=Sonnet scoped edits, main model for reasoning) and advises /model and /effort switches to save quota.
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
| Design, debugging without a known cause, code review, contract/impact analysis | main model (do it yourself) | opusplan (Opus plan / Sonnet execute) |
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
```

- [ ] **Step 4: Register the skill in VERSION.md and README.md**

In `VERSION.md`, find the skill status table containing `| \`module-map\` | complete |` and add this row in alphabetical order:

```markdown
| `model-router` | complete |
```

In `README.md`, find the skill catalog table containing the `module-map` row and add this row in alphabetical order:

```markdown
| `model-router` | Routing each task to the cheapest capable model (scout=Haiku, worker=Sonnet, main model for reasoning) plus /model and /effort advisories to save quota |
```

- [ ] **Step 5: Run the validator to verify it passes**

Run: `scripts/validate-skills.sh; echo "exit=$?"`
Expected: no `model-router` errors, `exit=0`.

- [ ] **Step 6: Commit**

```bash
git add skills/model-router/SKILL.md VERSION.md README.md
git commit -m "feat(skills): add model-router — route tasks to cheapest capable model"
```

---

### Task 4: Wire agents + skill into the workspace

**Files:**
- Modify: `adapters/claude/README.md` (Current subagents list)
- Create (outside repo, via symlink): `/Users/earth/Documents/GitHub/.claude/agents/scout.md`, `/Users/earth/Documents/GitHub/.claude/agents/worker.md`, `/Users/earth/Documents/GitHub/.claude/skills/model-router`

**Interfaces:**
- Consumes: `adapters/claude/agents/scout.md`, `adapters/claude/agents/worker.md`, `skills/model-router/` from Tasks 1–3.
- Produces: the artifacts Claude Code actually discovers at next session start.

- [ ] **Step 1: Sync the skill mirror via the installer (never hand-symlink skills)**

```bash
cd /Users/earth/Documents/GitHub/ai-skills
scripts/install-claude.sh
```
Expected: output reports the mirror synced and the validator passing.

- [ ] **Step 2: Symlink the agents (manual, per adapters/claude/README.md)**

```bash
ln -sfn "$PWD/adapters/claude/agents/scout.md"  /Users/earth/Documents/GitHub/.claude/agents/scout.md
ln -sfn "$PWD/adapters/claude/agents/worker.md" /Users/earth/Documents/GitHub/.claude/agents/worker.md
```

- [ ] **Step 3: Verify all three links resolve**

```bash
readlink /Users/earth/Documents/GitHub/.claude/skills/model-router
test -f /Users/earth/Documents/GitHub/.claude/agents/scout.md && test -f /Users/earth/Documents/GitHub/.claude/agents/worker.md && echo AGENTS-OK
```
Expected: the readlink prints the ai-skills path; then `AGENTS-OK`.

- [ ] **Step 4: Document the new subagents in the adapter README**

In `adapters/claude/README.md`, under `Current subagents:`, after the `knowledge-capturer` bullet, add:

```markdown
- `scout` — read-only Haiku explorer for file search, codebase exploration, and
  lookup questions; routed by `skills/model-router`. No Bash by design (the
  read-only guarantee is tool-level); the main model runs git-history queries.
- `worker` — Sonnet implementer for edits whose files and approach are already
  specified; returns BLOCKED instead of interpreting ambiguous requirements;
  routed by `skills/model-router`.
```

- [ ] **Step 5: Commit**

```bash
git add adapters/claude/README.md
git commit -m "docs(adapters): register scout and worker subagents"
```

---

### Task 5: Switch the default model to opusplan

**Files:**
- Modify: `/Users/earth/.claude/settings.json` (user-global, not in any repo — no commit)

**Interfaces:**
- Consumes: nothing. Produces: main-loop default `opusplan` (Opus in plan mode, Sonnet in execution) for all future sessions.

- [ ] **Step 1: Snapshot the current value**

```bash
grep '"model"' /Users/earth/.claude/settings.json
```
Expected: `"model": "claude-opus-4-8"` (record it — this is the rollback value).

- [ ] **Step 2: Change the value (JSON-safe edit)**

```bash
python3 - <<'EOF'
import json, pathlib
p = pathlib.Path.home() / ".claude" / "settings.json"
s = json.loads(p.read_text())
s["model"] = "opusplan"
p.write_text(json.dumps(s, indent=2) + "\n")
print("model =", s["model"])
EOF
```
Expected: `model = opusplan`.

- [ ] **Step 3: Verify Claude Code accepts it**

Open a NEW `claude` session and run `/model` with no argument.
Expected: the picker shows `opusplan` as the current selection. If Claude Code rejects the settings value, run `/model opusplan` once interactively instead (it persists the same setting) and re-check.

Rollback (if ever needed): set the value back to `claude-opus-4-8` via the same Python one-liner.

---

### Task 6: Functional smoke test (manual, new session)

**Files:** none — observation only. New/changed artifacts load at session start, so this MUST run in a fresh Claude Code session at `/Users/earth/Documents/GitHub`.

**Interfaces:**
- Consumes: everything from Tasks 1–5.
- Produces: go/no-go evidence per the spec's Verification section.

- [ ] **Step 1: Lookup task → expect scout (Haiku)**

Prompt: `หา endpoint ของ check-in campaigns อยู่ไฟล์ไหนใน Missions`
Expected: the transcript shows a delegation to the `scout` agent (Haiku), findings come back as `file:line` bullets, and the main model answers from them.

- [ ] **Step 2: Scoped edit task → expect worker (Sonnet)**

Prompt: a fully specified edit in a scratch/meta repo, e.g. `ใน ai-skills/README.md แก้คำอธิบาย skill model-router ให้ลงท้ายด้วยคำว่า (v1) — ไฟล์เดียว จุดเดียว`
Expected: delegation to `worker` (Sonnet), `DONE`/`VERIFIED` report, no scope creep.

- [ ] **Step 3: Hard design task → expect NO delegation + possible advisory**

Prompt: `ช่วยวิเคราะห์ impact ถ้าจะย้าย reward payout ออกจาก Missions ไปไว้ที่ Order service`
Expected: main model works itself (no scout/worker for the analysis core; scout may gather files first — that is correct routing), and if the session model is below the task class, exactly one `/model opus` advisory line appears.

- [ ] **Step 4: Record the outcome**

If any expectation failed, note which and adjust ONLY the relevant trigger text (skill `description`, or agent `description`) — one change, then re-run that step in another fresh session. After a week of real use, judge the spec's success criteria: explore/mechanical work runs on Haiku/Sonnet unprompted, usage limit stretches further, main-task quality holds.
