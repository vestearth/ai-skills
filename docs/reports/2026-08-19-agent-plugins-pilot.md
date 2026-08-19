# Agent Plugins 1.0 Pilot — Evaluation Report

Status: pilot complete, verdict recorded
Issue: vestearth/AI-office-agency#18 ("Pilot Agent Plugins 1.0 packaging for core portable skills")
Related: vestearth/AI-office-agency#3 (Codex/Cursor portability roadmap)
Date: 2026-08-19

## What was built

A real, loadable Agent Plugins 1.0 package under `plugins-pilot/ai-skills-pilot/`:

```text
plugins-pilot/ai-skills-pilot/
  .claude-plugin/
    plugin.json         # plugin manifest
    marketplace.json     # single-plugin dev marketplace manifest
  skills/
    verification-loop/       -> symlink to ../../../skills/verification-loop
    search-first/             -> symlink to ../../../skills/search-first
    minimal-change-review/    -> symlink to ../../../skills/minimal-change-review
```

`scripts/check-plugins-pilot-sync.sh` is the explicit, auditable sync check: it
confirms every packaged skill path is a symlink, resolves to the expected
canonical `skills/<name>` directory, and that the packaged `SKILL.md` is
byte-identical to canonical. Ran clean at time of writing:

```
$ bash scripts/check-plugins-pilot-sync.sh
PASS verification-loop: symlinked to canonical, SKILL.md byte-identical
PASS search-first: symlinked to canonical, SKILL.md byte-identical
PASS minimal-change-review: symlinked to canonical, SKILL.md byte-identical

Pilot sync check passed for 3 skill(s).
```

Canonical `skills/<name>/` remains the single source of truth. Nothing under
`plugins-pilot/` is a copy of skill content — only manifest/index files that
Agent Plugins 1.0 requires and does not exist in canonical form elsewhere.

## Candidate selection

Per the issue's suggested candidates, gated on the repo's own eval results
(`skills/<name>/metadata.yaml`, `evaluation:` block, as of 2026-08-19):

| Skill | status | pass_rate | maturity | Used? |
| --- | --- | --- | --- | --- |
| `verification-loop` | passing | 1.0 | stable | yes |
| `search-first` | passing | 1.0 | stable | yes |
| `minimal-change-review` | **partial → passing** | **0.71 → 1.0** | **beta → stable** | yes, after gap-closing |

`minimal-change-review` did not meet "stable" going in. Repo-wide,
`grep -l "maturity: stable" skills/*/metadata.yaml` returned only
`verification-loop` and `search-first` — no ready-made substitute existed for
a third pilot candidate (Path 2 in the task brief had nothing to fall back
to). Path 1 was taken: close the two documented gaps in
`skills/minimal-change-review/SKILL.md`, re-judge its 7 eval cases, and bump
`metadata.yaml` if all pass.

### Gap-closing edit

Two sections were added to `skills/minimal-change-review/SKILL.md`:

1. **Scope Authority** — instructs the skill not to re-litigate scope the
   operator already explicitly approved (a written plan, an explicit
   go-ahead), applying minimal-change judgment only to implementation choices
   *within* that approved scope, unless the approval conflicts with a hard
   rule (tests, security, data safety, compatibility).
2. **Evidence Type Check** — instructs the skill to check that a cited
   `evidence_refs` command's **type** actually matches the claim it backs
   (e.g. a search command supports a "nothing exists" claim; a build/test/lint
   run does not), and to reject a mismatched citation regardless of whether
   the reference id itself is well-formed.

### Re-judged eval cases (`skills/minimal-change-review/evals/cases.yaml`)

| Case | Dimension | Verdict against updated SKILL.md |
| --- | --- | --- |
| mcr-001 | activation_correctness | pass (unaffected by the edit; already covered by the existing Process section) |
| mcr-002 | instruction_compliance | pass (unaffected) |
| mcr-003 | false_completion | pass (unaffected) |
| mcr-004 | evidence_quality | pass (unaffected; speculative justification already rejected) |
| mcr-006 | evidence_quality | pass (unaffected; narrow-search-supports-narrow-claim already covered) |
| mcr-005 | unnecessary_invocation | **pass** — now explicitly required by "Scope Authority": an operator-approved plan is respected, not shrunk |
| mcr-007 | false_completion | **pass** — now explicitly required by "Evidence Type Check": a build-command citation is rejected as support for a "reuse checked" claim |

7/7 → pass_rate 1.0. `metadata.yaml` was updated: `version: 1.1.0 → 1.2.0`,
`maturity: beta → stable`, `evaluation.status: partial → passing`,
`evaluation.pass_rate: 0.71 → 1.0`, `last_evaluated: 2026-08-19`, plus two new
`known_failure_modes` entries recording the fixed gaps (dated, marked
`fixed 2026-08-19`) alongside the pre-existing unrelated entry. No
`known_failure_modes` entry was fabricated — both new entries describe the
exact gap named in the task brief and the section that now closes it, not a
freshly reproduced runtime failure.

This is a judgment-based re-evaluation (case text against the new instruction
text), not a re-run of a live agent transcript — the same method the eval
harness itself already uses for `evaluation.status`/`pass_rate` in this repo
(there is no automated grader script found in `scripts/`).

Canonical `SKILL.md` content for `verification-loop` and `search-first` was
**not** touched. `minimal-change-review/SKILL.md` was touched only for this
one intentional gap-closing edit, as the task brief explicitly permitted.

## Instruction fidelity: packaged vs. canonical

Because `plugins-pilot/ai-skills-pilot/skills/<name>` are symlinks (not
copies) to `skills/<name>`, the packaged and canonical `SKILL.md` files are
**the same inode** — `diff` confirms byte-identical content for all three
pilot skills, trivially and permanently (there is no drift window to audit
for identity; the audit is about the symlink itself staying intact, which
`check-plugins-pilot-sync.sh` verifies).

One nuance worth recording: `minimal-change-review/SKILL.md` contains an
explicit relative markdown link,
`[../../docs/specs/2026-08-15-evidence-integration.md]`. Filesystem symlink
semantics resolve a relative link inside a symlinked file against the link's
**real** (canonical) directory, not the location of the symlink that was
followed to reach it — so this link keeps resolving correctly regardless of
where in a workspace the pilot plugin's symlink lives. This only holds for a
genuine symlink; it would silently break under a **copy**-based packaging
strategy, which is one concrete reason the symlink approach was chosen over
generating flattened copies.

## What would differ operationally (not simulated — reasoned from real installed-plugin evidence)

This repo cannot run a live Codex/Cursor session, so the comparison below is
built from (a) how this repo's adapters already work
(`adapters/claude/README.md`, `.codex-plugin/plugin.json`,
`adapters/cursor/rules/*.mdc`) and (b) inspecting **real installed** Claude
plugins already present in this environment's cache
(`~/.claude/plugins/cache/claude-plugins-official/superpowers/6.3.0/` and
`~/.claude/plugins/cache/socraticode/socraticode/1.9.0/`), not from
speculation about the spec.

### How Codex and Cursor actually consume ai-skills today

- **Codex**: `.codex-plugin/plugin.json` at repo root sets `"skills":
  "./skills/"` — Codex reads skill files directly from the canonical
  directory. No packaging or copy step exists in this lane at all.
- **Cursor**: `adapters/cursor/rules/ai-skills.mdc` is a single small routing
  rule file that tells Cursor, in prose, to open
  `ai-skills/skills/<name>/SKILL.md` on demand from disk. Again: direct path
  reference, no packaging.
- **Claude (existing, pre-pilot)**: `adapters/claude/README.md` documents
  `scripts/install-claude.sh`, which mirrors every `skills/<name>/` into
  `.claude/skills/` as **absolute symlinks**. This is the same symlink
  strategy the pilot uses, just installer-driven instead of manifest-driven,
  and it predates this issue.

**Finding:** none of the three existing lanes package or copy skill content.
All three read live from `skills/<name>/` (Codex, Cursor) or symlink into it
(Claude's existing installer). This is the baseline the pilot is compared
against — not "no distribution mechanism", but "a distribution mechanism that
already keeps zero-copy sync for free."

### What a real Claude Agent Plugin install looks like once distributed

Inspecting the two plugins already installed in this environment
(`superpowers@claude-plugins-official`, `socraticode@socraticode`) shows the
actual mechanics of the Agent Plugins 1.0 distribution model:

- `~/.claude/plugins/marketplaces/<marketplace>/` holds the marketplace
  registration.
- `~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/` holds a
  **version-pinned, physically copied** snapshot of the plugin's files —
  confirmed directly: `skills/writing-skills/SKILL.md` inside the cache is a
  regular file (`-rw-r--r--`), not a symlink back to any source checkout.
  Multiple versions can coexist side by side (`6.0.3`, `6.2.0`, `6.3.0` were
  all present for `superpowers`).
- This matches an independent, already-recorded observation in this
  workspace's own memory: SocratiCode's plugin lane keeps the
  `.mcp.json.disabled` file in **two separate physical locations** — the
  source checkout and the `1.9.0` cache copy — specifically because they are
  not auto-linked and must be kept in sync by hand.

**Consequence for versioning/update ergonomics:** a marketplace-distributed
Agent Plugin is a **pinned snapshot that goes stale until an explicit
`claude plugin update` (or equivalent) is run**, whereas the pilot's own
symlink packaging (and the existing `install-claude.sh` installer) stay live
against canonical automatically. If `ai-skills-pilot` were ever published to
a real marketplace and installed that way (rather than loaded from a local
dev path), it would trade the zero-copy sync property away — this is a real
regression versus the status quo, not a neutral trade-off, and it is the
single most consequential operational finding of this pilot.

### Portability across Codex/Cursor

Agent Plugins 1.0 (`.claude-plugin/plugin.json` + `marketplace.json`) is a
**Claude Code–specific mechanism**. It is not read by Codex or Cursor. The
superpowers cache confirms the actual pattern the ecosystem uses for
multi-tool portability: the same plugin repo ships **parallel, per-tool
manifest files at its root** — `.claude-plugin/`, `.codex-plugin/`,
`.cursor-plugin/`, `.kimi-plugin/`, `.devin-plugin/`, `.hermes-plugin/`,
`.opencode/` were all present simultaneously in the installed `superpowers`
plugin, each a thin manifest pointing at the same shared `skills/` directory.

That is structurally identical to what `ai-skills` already does with
`.codex-plugin/plugin.json` (Codex) and `adapters/cursor/rules/*.mdc`
(Cursor) — this repo already follows the same "one shared skills/ directory,
one thin manifest per tool" pattern the wider ecosystem converged on. Adding
`.claude-plugin/` (or, as piloted, `plugins-pilot/.../claude-plugin/`) is
**one more per-tool manifest in that same family**, not a cross-tool
portability layer by itself. It does not reduce the number of per-lane
manifests this repo maintains; it adds one.

### Dependency declaration

`plugin.json` has no field for declaring a skill's dependency on
`rules/<name>/RULE.md` files that a `SKILL.md` references by relative path
(e.g. `minimal-change-review`'s `Required Rule` section names three files
under `rules/`). Packaging a skill via a plugin manifest does not change how
those references are resolved or declared — they remain prose citations an
agent must follow, exactly as they are for Codex and Cursor today. The plugin
manifest format does not add or improve dependency declaration for this
repo's skill/rule relationship; it is silent on it.

### Installation / sync complexity

- **Before the pilot:** one installer (`install-claude.sh`) for Claude, one
  static manifest (`.codex-plugin/plugin.json`) for Codex, one static rule
  file for Cursor. Three files/mechanisms total, all pointing at
  `skills/`.
- **After the pilot:** a fourth mechanism (`plugins-pilot/ai-skills-pilot/`)
  was added, for a subset of skills, plus a new script
  (`scripts/check-plugins-pilot-sync.sh`) to audit it. Net complexity went
  up, not down, for the three skills in the pilot — and by design, since it
  is explicitly framed as a pilot rather than a replacement.

### Compatibility with current adapters/templates

No conflict was found. `scripts/validate-skills.sh` (42/42 skills pass) and
`ruby scripts/validate-skill-metadata.rb` (no output = pass) both ran clean
after the pilot was added, and neither scans `plugins-pilot/` — `SKILLS_DIR`
in `validate-skills.sh` is hardcoded to `skills/`, and the evidence-id scanner
only walks `skills/`, `rules/`, and `docs/specs/`. `.codex-plugin/plugin.json`
and `adapters/cursor/rules/*.mdc` are unmodified and untouched by anything in
this pilot.

### Does plugin packaging reduce duplication, or add an abstraction layer?

**Adds an abstraction layer.** The symlink strategy avoided *content*
duplication (zero copies of `SKILL.md` exist), but the pilot still introduces
a new manifest format, a new directory tree, and a new sync-verification
script that did not previously need to exist for these three skills. Nothing
about Codex's or Cursor's consumption of `skills/` changed or could change as
a result of this pilot — they were never plugin-aware and Agent Plugins 1.0
gives them nothing. The only lane that gains anything is Claude Code's
marketplace-install UX (discoverability via `/plugin marketplace add`,
shareability as a URL) — and that gain comes with the version-pinning
regression described above the moment it is actually distributed through a
marketplace rather than loaded from a local dev path.

## Rollback path

Zero effect on canonical skills by construction — nothing under
`plugins-pilot/` is referenced by any script, adapter, or doc outside this
report and the pilot directory itself. To roll back completely:

1. Delete `plugins-pilot/` (the whole directory — manifest, marketplace file,
   and the three symlinks; canonical `skills/verification-loop/`,
   `skills/search-first/`, `skills/minimal-change-review/` are untouched by
   this deletion since they are the symlink *targets*, not the symlinks).
2. Delete `scripts/check-plugins-pilot-sync.sh`.
3. Delete this file, `docs/reports/2026-08-19-agent-plugins-pilot.md`.
4. Leave `skills/minimal-change-review/SKILL.md` and its `metadata.yaml`
   as they are — that edit stands on its own merits (it closed two real
   instruction gaps and is independently useful to every lane that already
   reads `skills/minimal-change-review/` directly); it is not part of the
   pilot's footprint and rolling back the pilot does not require reverting
   it. If a reviewer wants that edit reverted too, `git revert` the specific
   commit that made it — it is a separate, identifiable commit from the
   plugin-packaging commits.
5. Confirm rollback: `git grep -n "plugins-pilot"` across the repo should
   return no hits outside history; `bash scripts/validate-skills.sh` and
   `ruby scripts/validate-skill-metadata.rb` should still pass unchanged
   (they never depended on `plugins-pilot/`).

No other doc, script, adapter, `VERSION.md`, or `README.md` entry references
`plugins-pilot/` — confirmed by `git grep -n "plugins-pilot"` returning only
files inside `plugins-pilot/` itself, `scripts/check-plugins-pilot-sync.sh`,
and this report at the time of writing.

## Adoption criteria for expanding beyond the pilot

Expansion beyond these three skills should only happen if **all** of the
following hold, checked against real evidence (not restated intent):

1. **A real marketplace-install round trip has been tested**, at least once,
   with `claude plugin marketplace add` / `claude plugin install` against
   this repo (or a fork), and the resulting cached copy has been diffed
   against canonical to confirm content matched at install time. This pilot
   did not do this (no marketplace was actually registered/installed) —
   it is the top blocking gap for adoption.
2. **An update-propagation story is chosen and tested**, given the pinned-copy
   cache behavior found above: either (a) an automated re-publish/version-bump
   step is wired into `scripts/` so a canonical skill edit lands in the
   plugin's next version without manual authoring, or (b) the team explicitly
   accepts manual re-sync and documents the cadence. Adoption should not
   proceed on the unstated assumption that plugin installs stay live.
3. **Only `maturity: stable`, `evaluation.status: passing` skills are
   eligible** at expansion time — same bar used for this pilot's candidate
   selection. A skill dropping out of `stable` should be pulled from the
   packaged set, not left stale in a plugin manifest.
4. **The four validators keep passing with the larger set**:
   `scripts/validate-skills.sh`, `ruby scripts/validate-skill-metadata.rb`,
   `bash scripts/check-plugins-pilot-sync.sh` (or its successor), and a
   manual `git grep` sweep confirming no adapter/doc/script outside the
   plugin directory started depending on it.
5. **A second, independent lane demonstrates real benefit**, not just Claude.
   Since Agent Plugins 1.0 does not read across to Codex/Cursor (see above),
   expansion should not be justified as "portability" — only as
   Claude-marketplace distribution UX. If that specific UX benefit (discovery,
   one-command install/share for Claude Code users) is not something the team
   actually wants to offer, expansion is not justified regardless of pilot
   mechanics.

## Outcome

**Partially adopt.**

Evidence summary:

- The pilot proved the packaging **mechanically works**: a genuine
  `.claude-plugin/plugin.json` + `marketplace.json` + symlinked `skills/`
  tree was built, verified loadable-shaped (matches the real structure of
  two already-installed Claude plugins in this environment), instruction
  content is provably byte-identical to canonical via a real diff, and a
  repeatable sync-check script exists.
- It did **not** prove the two things the issue's own evaluation checklist
  most needed: real portability to Codex/Cursor (Agent Plugins 1.0 is
  Claude-only, confirmed by inspecting how the ecosystem's own multi-tool
  plugins actually achieve portability — parallel manifests, not one shared
  format) and safe update ergonomics under a real marketplace install (this
  pilot never registered a marketplace or ran an install; the cache evidence
  strongly suggests a pinned-copy regression versus the zero-copy symlink
  installer this repo already has for Claude).
- Net complexity for the three piloted skills went up (one more
  manifest/mechanism, one more sync script), and that is acceptable **only**
  as a pilot, per the issue's explicit scope.

Recommendation: keep the pilot artifact in place (do not roll back yet), but
do not expand it to more skills or promote it to a documented installation
path in `README.md`/`adapters/` until adoption criteria #1 and #2 above are
satisfied with real evidence — specifically, an actual marketplace
install/update round trip. Reject the framing of Agent Plugins 1.0 as a
Codex/Cursor portability solution; it is, at best, a Claude Code
distribution/discoverability improvement layered on top of a source of truth
that already works fine without it.
