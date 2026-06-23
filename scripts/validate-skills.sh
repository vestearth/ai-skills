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

if [ -f "$ROOT_DIR/README.md" ]; then
  for skill_name in "${skill_names[@]}"; do
    if ! grep -q "\`$skill_name\`" "$ROOT_DIR/README.md"; then
      fail "README.md: missing skill '$skill_name'"
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

if [ "$failures" -gt 0 ]; then
  printf '\nSkill validation failed with %d issue(s).\n' "$failures" >&2
  exit 1
fi

printf 'Skill validation passed for %d skill(s).\n' "${#skill_names[@]}"
