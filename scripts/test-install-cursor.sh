#!/usr/bin/env bash
#
# Smoke test for scripts/install-cursor.sh.
#
# The Cursor adapter is a real usage surface, and validate-skills.sh only checks
# the committed `.mdc` rules — not what the installer actually produces. This test
# exercises both layouts in throwaway directories and asserts the observable
# behavior:
#   nested      -> symlinks the committed rules into <target>/.cursor/rules
#                  (prefix unchanged: `ai-skills/skills/...`).
#   standalone  -> copies rules with the prefix rewritten to `skills/...`.
#
# No network, no mutation of the repo working tree.
set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALLER="$ROOT_DIR/scripts/install-cursor.sh"
SRC_DIR="$ROOT_DIR/adapters/cursor/rules"

failures=0
fail() { printf 'FAIL: %s\n' "$1" >&2; failures=$((failures + 1)); }

WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/ai-skills-installer-test.XXXXXX")"
cleanup() { rm -rf "$WORK_DIR"; }
trap cleanup EXIT

if [ ! -x "$INSTALLER" ] && [ ! -f "$INSTALLER" ]; then
  fail "installer not found: $INSTALLER"
fi

rule_count="$(find "$SRC_DIR" -maxdepth 1 -name '*.mdc' | wc -l | tr -d ' ')"
if [ "$rule_count" -eq 0 ]; then
  fail "no committed .mdc rules under $SRC_DIR to install"
fi

# --- Case 1: nested layout -> symlinks into <target>/.cursor/rules -------------
nested_target="$WORK_DIR/nested-project"
mkdir -p "$nested_target"
bash "$INSTALLER" --nested "$nested_target" >/dev/null 2>&1 || fail "nested install exited non-zero"

nested_dest="$nested_target/.cursor/rules"
nested_installed="$(find "$nested_dest" -maxdepth 1 -name '*.mdc' 2>/dev/null | wc -l | tr -d ' ')"
if [ "$nested_installed" != "$rule_count" ]; then
  fail "nested: expected $rule_count rules, found $nested_installed in $nested_dest"
fi
for f in "$nested_dest"/*.mdc; do
  [ -e "$f" ] || continue
  if [ ! -L "$f" ]; then
    fail "nested: $(basename "$f") should be a symlink"
  elif [ ! -e "$f" ]; then
    fail "nested: $(basename "$f") symlink target does not resolve"
  fi
  if ! grep -q 'ai-skills/skills/' "$f"; then
    fail "nested: $(basename "$f") lost the 'ai-skills/skills/' prefix"
  fi
done

# --- Case 2: standalone layout -> copies with rewritten prefix ------------------
# install-cursor.sh --standalone targets its own repo root, so run it from a copy
# to keep the real working tree clean.
fake_repo="$WORK_DIR/fake-repo"
mkdir -p "$fake_repo/scripts" "$fake_repo/adapters/cursor"
cp "$INSTALLER" "$fake_repo/scripts/install-cursor.sh"
cp -R "$SRC_DIR" "$fake_repo/adapters/cursor/rules"
bash "$fake_repo/scripts/install-cursor.sh" --standalone >/dev/null 2>&1 || fail "standalone install exited non-zero"

standalone_dest="$fake_repo/.cursor/rules"
standalone_installed="$(find "$standalone_dest" -maxdepth 1 -name '*.mdc' 2>/dev/null | wc -l | tr -d ' ')"
if [ "$standalone_installed" != "$rule_count" ]; then
  fail "standalone: expected $rule_count rules, found $standalone_installed in $standalone_dest"
fi
for f in "$standalone_dest"/*.mdc; do
  [ -e "$f" ] || continue
  if [ -L "$f" ]; then
    fail "standalone: $(basename "$f") should be a regular file copy, not a symlink"
  fi
  if grep -q 'ai-skills/skills/' "$f"; then
    fail "standalone: $(basename "$f") still has the nested 'ai-skills/skills/' prefix (rewrite failed)"
  fi
  if ! grep -q '`skills/' "$f"; then
    fail "standalone: $(basename "$f") missing rewritten '\`skills/' prefix"
  fi
done

if [ "$failures" -gt 0 ]; then
  printf '\ninstall-cursor.sh smoke test failed with %d issue(s).\n' "$failures" >&2
  exit 1
fi

printf 'install-cursor.sh smoke test passed (%s rule(s), nested + standalone).\n' "$rule_count"
