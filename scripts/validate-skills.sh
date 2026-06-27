#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$ROOT_DIR/skills"

required_sections=(
  "Use When"
  "Do Not Use When"
  "Goal"
  "Required Inputs"
  "Process"
  "Output Format"
  "Anti-patterns"
)

failures=0

fail() {
  printf 'ERROR: %s\n' "$1" >&2
  failures=$((failures + 1))
}

skill_names=()

if [ ! -d "$SKILLS_DIR" ]; then
  fail "missing skills directory: $SKILLS_DIR"
else
  while IFS= read -r skill_dir; do
    skill_name="$(basename "$skill_dir")"
    skill_file="$skill_dir/SKILL.md"
    skill_names+=("$skill_name")

    if [ ! -f "$skill_file" ]; then
      fail "$skill_name: missing SKILL.md"
      continue
    fi

    first_line="$(sed -n '1p' "$skill_file")"
    if [ "$first_line" != "---" ]; then
      fail "$skill_name: frontmatter must start on line 1"
    fi

    frontmatter="$(awk 'NR == 1 { next } /^---$/ { exit } { print }' "$skill_file")"
    declared_name="$(printf '%s\n' "$frontmatter" | awk -F': *' '$1 == "name" { print $2; exit }')"
    description="$(printf '%s\n' "$frontmatter" | awk -F': *' '$1 == "description" { print $2; exit }')"

    if [ -z "$declared_name" ]; then
      fail "$skill_name: missing frontmatter name"
    elif [ "$declared_name" != "$skill_name" ]; then
      fail "$skill_name: frontmatter name '$declared_name' must match folder name"
    fi

    if [ -z "$description" ]; then
      fail "$skill_name: missing frontmatter description"
    fi

    for section in "${required_sections[@]}"; do
      if ! grep -qx "## $section" "$skill_file"; then
        fail "$skill_name: missing section '## $section'"
      fi
    done
  done < <(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d | sort)
fi

for doc in "$ROOT_DIR/VERSION.md" "$ROOT_DIR/README.md"; do
  if [ ! -f "$doc" ]; then
    fail "missing required document: ${doc#$ROOT_DIR/}"
  fi
done

if [ -f "$ROOT_DIR/VERSION.md" ]; then
  for skill_name in "${skill_names[@]}"; do
    if ! grep -q "\`$skill_name\`" "$ROOT_DIR/VERSION.md"; then
      fail "VERSION.md: missing skill '$skill_name'"
    fi
  done

  while IFS= read -r listed_skill; do
    [ -z "$listed_skill" ] && continue
    if [ ! -d "$SKILLS_DIR/$listed_skill" ]; then
      fail "VERSION.md: listed skill '$listed_skill' has no skills/$listed_skill directory"
    fi
  done < <(sed -n 's/.*`\([^`]*\)`.*/\1/p' "$ROOT_DIR/VERSION.md" | grep -v '/' | sort -u)
fi

# Playbook coverage: a games-labs playbook is a routing/product surface, so it must
# be discoverable from every place that routes to it, not just present on disk.
# Forward: every playbooks/games-labs/*.md is referenced in each routing surface.
# Reverse: every playbook path mentioned in a surface resolves to a real file. This
# keeps VERSION.md's "V3 complete" claim and the adapter/skill routing from drifting
# apart.
PLAYBOOKS_DIR="$ROOT_DIR/playbooks/games-labs"
playbook_surfaces=(
  "VERSION.md"
  "README.md"
  "AGENTS.md"
  "examples/games-labs/AGENTS.md"
  "skills/games-labs-api-review/SKILL.md"
)
if [ -d "$PLAYBOOKS_DIR" ]; then
  for surface in "${playbook_surfaces[@]}"; do
    surface_path="$ROOT_DIR/$surface"
    if [ ! -f "$surface_path" ]; then
      fail "missing playbook routing surface: $surface"
      continue
    fi
    while IFS= read -r playbook_file; do
      rel="playbooks/games-labs/$(basename "$playbook_file")"
      if ! grep -qF "$rel" "$surface_path"; then
        fail "$surface: missing playbook reference '$rel'"
      fi
    done < <(find "$PLAYBOOKS_DIR" -mindepth 1 -maxdepth 1 -name '*.md' | sort)

    while IFS= read -r ref; do
      if [ ! -f "$ROOT_DIR/$ref" ]; then
        fail "$surface: broken playbook reference '$ref' (no such file)"
      fi
    done < <(grep -oE 'playbooks/games-labs/[a-z0-9-]+\.md' "$surface_path" | sort -u)
  done
fi

# Reference path integrity: a path a SKILL.md points at must resolve to a real
# file, so a skill never routes an agent to a dead link. Root-prefixed refs
# (rules/, playbooks/, scripts/, adapters/, examples/) resolve from the repo root;
# references/ refs resolve from the skill's own directory.
while IFS= read -r skill_file; do
  skill_dir="$(dirname "$skill_file")"
  while IFS= read -r ref; do
    if [ ! -e "$ROOT_DIR/$ref" ]; then
      fail "${skill_file#$ROOT_DIR/}: broken reference '$ref' (no such file under repo root)"
    fi
  done < <(grep -oE '(rules|playbooks|scripts|adapters|examples)/[A-Za-z0-9._/-]+\.(md|sh|ya?ml|mdc)' "$skill_file" | sort -u)

  while IFS= read -r ref; do
    if [ ! -e "$skill_dir/$ref" ]; then
      fail "${skill_file#$ROOT_DIR/}: broken reference '$ref' (no such file in skill references/)"
    fi
  done < <(grep -oE 'references/[A-Za-z0-9._/-]+\.(md|sh)' "$skill_file" | sort -u)
done < <(find "$SKILLS_DIR" -type f -name 'SKILL.md' | sort)

if [ -f "$ROOT_DIR/README.md" ]; then
  for skill_name in "${skill_names[@]}"; do
    if ! grep -q "\`$skill_name\`" "$ROOT_DIR/README.md"; then
      fail "README.md: missing skill '$skill_name'"
    fi
  done
fi

# Root AGENTS.md routes agents to skills, so it must stay in sync with the skill
# set and the Codex/Cursor adapters (which the loop below already enforces).
# Otherwise a new skill silently never reaches the Codex lane via root routing.
if [ -f "$ROOT_DIR/AGENTS.md" ]; then
  for skill_name in "${skill_names[@]}"; do
    if ! grep -q "$skill_name" "$ROOT_DIR/AGENTS.md"; then
      fail "AGENTS.md: missing skill '$skill_name'"
    fi
  done
fi

adapter_docs=(
  "$ROOT_DIR/adapters/codex/AGENTS-snippet.md"
  "$ROOT_DIR/adapters/cursor/rules/ai-skills.mdc"
)

for doc in "${adapter_docs[@]}"; do
  if [ ! -f "$doc" ]; then
    fail "missing adapter document: ${doc#$ROOT_DIR/}"
    continue
  fi

  for skill_name in "${skill_names[@]}"; do
    if ! grep -q "$skill_name" "$doc"; then
      fail "${doc#$ROOT_DIR/}: missing skill '$skill_name'"
    fi
  done
done

# Cursor adapter rules route to `ai-skills/skills/<skill>/SKILL.md` paths, which
# resolve from the parent workspace (the nested/recommended layout this team
# uses). A bad prefix makes every pointer dead but still passes a name-substring
# check, so verify paths explicitly. The standalone `skills/...` form is produced
# only by install-cursor.sh --standalone and must never be committed.
for rule in "$ROOT_DIR"/adapters/cursor/rules/*.mdc; do
  [ -f "$rule" ] || continue
  # Reject the standalone prefix (backtick directly followed by `skills/`).
  if grep -q '`skills/' "$rule"; then
    fail "adapters/cursor/rules/$(basename "$rule"): committed source must use 'ai-skills/skills/...', not standalone 'skills/...' (standalone form is install-cursor.sh --standalone only)"
  fi
  # Each `ai-skills/skills/<name>/SKILL.md` must resolve to skills/<name>/SKILL.md
  # under this repo root (strip the leading ai-skills/ segment).
  while IFS= read -r ref; do
    if [ ! -f "$ROOT_DIR/${ref#ai-skills/}" ]; then
      fail "adapters/cursor/rules/$(basename "$rule"): broken skill path '$ref' (no such file under ai-skills)"
    fi
  done < <(grep -oE 'ai-skills/skills/[a-z0-9-]+/SKILL\.md' "$rule" | sort -u)
done

if [ "$failures" -gt 0 ]; then
  printf '\nSkill validation failed with %d issue(s).\n' "$failures" >&2
  exit 1
fi

printf 'Skill validation passed for %d skill(s).\n' "${#skill_names[@]}"
