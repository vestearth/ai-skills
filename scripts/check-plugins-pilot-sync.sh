#!/usr/bin/env bash
#
# Auditable sync check for plugins-pilot/ai-skills-pilot (issue #18).
#
# The pilot plugin does not copy skill content. Each packaged skill under
# plugins-pilot/ai-skills-pilot/skills/<name> is a symlink to the canonical
# skills/<name> directory, so canonical skills/<name>/ stays the single source
# of truth (per the issue's "Out of scope: Replacing ai-skills as source of
# truth before the pilot proves value").
#
# This script is the explicit, auditable proof of that: for every skill listed
# below it confirms (a) the packaged path is a symlink, not a real directory or
# file, (b) the symlink resolves to the expected canonical skills/<name>
# directory, and (c) SKILL.md read through the symlink is byte-identical to the
# canonical SKILL.md. Run it after any change to plugins-pilot/ or to a pilot
# skill's canonical files.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

pilot_dir="plugins-pilot/ai-skills-pilot/skills"
skills=(verification-loop search-first minimal-change-review)

fail=0

for name in "${skills[@]}"; do
  packaged="$pilot_dir/$name"
  canonical="skills/$name"

  if [[ ! -L "$packaged" ]]; then
    echo "FAIL $name: $packaged is not a symlink"
    fail=1
    continue
  fi

  resolved="$(cd "$packaged" 2>/dev/null && pwd -P || true)"
  expected="$(cd "$canonical" && pwd -P)"

  if [[ "$resolved" != "$expected" ]]; then
    echo "FAIL $name: symlink resolves to '$resolved', expected '$expected'"
    fail=1
    continue
  fi

  if ! diff -q "$packaged/SKILL.md" "$canonical/SKILL.md" >/dev/null 2>&1; then
    echo "FAIL $name: SKILL.md content differs from canonical"
    fail=1
    continue
  fi

  echo "PASS $name: symlinked to canonical, SKILL.md byte-identical"
done

if [[ "$fail" -ne 0 ]]; then
  echo
  echo "Pilot sync check FAILED."
  exit 1
fi

echo
echo "Pilot sync check passed for ${#skills[@]} skill(s)."
