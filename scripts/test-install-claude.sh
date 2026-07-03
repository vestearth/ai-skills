#!/usr/bin/env bash
#
# Smoke test for scripts/install-claude.sh.
#
# validate-skills.sh checks the repo skill sources, not the installed mirror.
# This test exercises the installer's observable behavior in throwaway dirs:
#   sync   -> every skills/<name>/ with a SKILL.md becomes a resolving symlink
#             in <target>/.claude/skills.
#   prune  -> a stale symlink pointing into this repo's skills/ whose source is
#             gone is removed; unrelated files/symlinks are left untouched.
#   idempotent -> a second run changes nothing and still exits 0.
#
# No network, no mutation of the repo working tree (nested layout only touches
# <target>/.claude/skills).
set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALLER="$ROOT_DIR/scripts/install-claude.sh"
SRC_DIR="$ROOT_DIR/skills"

failures=0
fail() { printf 'FAIL: %s\n' "$1" >&2; failures=$((failures + 1)); }

WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/ai-skills-claude-installer-test.XXXXXX")"
cleanup() { rm -rf "$WORK_DIR"; }
trap cleanup EXIT

if [ ! -f "$INSTALLER" ]; then
  fail "installer not found: $INSTALLER"
fi

skill_count="$(find "$SRC_DIR" -maxdepth 2 -name SKILL.md | wc -l | tr -d ' ')"
if [ "$skill_count" -eq 0 ]; then
  fail "no source skills under $SRC_DIR to install"
fi

target="$WORK_DIR/workspace"
dest="$target/.claude/skills"
mkdir -p "$dest"

# Pre-seed drift the installer must handle:
#   (a) a stale link into THIS repo's skills/ whose source is gone -> must prune.
ln -s "$SRC_DIR/__deleted_skill__" "$dest/stale-skill"
#   (b) an unrelated symlink from another library                 -> must survive.
ln -s "$WORK_DIR" "$dest/other-library"
#   (c) an unrelated regular file                                 -> must survive.
echo "keep me" > "$dest/README-note.txt"

bash "$INSTALLER" --nested "$target" >/dev/null 2>&1 || fail "install exited non-zero"

# --- sync: expected number of resolving skill symlinks ------------------------
installed="$(find "$dest" -maxdepth 1 -type l -lname "$SRC_DIR/*" 2>/dev/null | wc -l | tr -d ' ')"
# BSD find lacks reliable -lname; count by resolving instead for portability.
installed=0
for name in "$SRC_DIR"/*/; do
  [ -f "$name/SKILL.md" ] || continue
  base="$(basename "$name")"
  link="$dest/$base"
  if [ ! -L "$link" ]; then
    fail "sync: $base should be a symlink in the mirror"
  elif [ ! -e "$link" ]; then
    fail "sync: $base symlink does not resolve"
  else
    installed=$((installed + 1))
  fi
done
if [ "$installed" != "$skill_count" ]; then
  fail "sync: expected $skill_count skill links, found $installed resolving in $dest"
fi

# --- prune: the stale in-repo link is gone -----------------------------------
if [ -L "$dest/stale-skill" ]; then
  fail "prune: stale-skill (dangling link into repo skills/) should have been removed"
fi

# --- unrelated entries survive ------------------------------------------------
if [ ! -L "$dest/other-library" ]; then
  fail "prune: other-library (unrelated symlink) should be left untouched"
fi
if [ ! -f "$dest/README-note.txt" ]; then
  fail "prune: README-note.txt (unrelated file) should be left untouched"
fi

# --- idempotent: second run exits 0 and keeps the same link count ------------
bash "$INSTALLER" --nested "$target" >/dev/null 2>&1 || fail "second install exited non-zero"
reinstalled=0
for name in "$SRC_DIR"/*/; do
  [ -f "$name/SKILL.md" ] || continue
  base="$(basename "$name")"
  [ -L "$dest/$base" ] && [ -e "$dest/$base" ] && reinstalled=$((reinstalled + 1))
done
if [ "$reinstalled" != "$skill_count" ]; then
  fail "idempotent: expected $skill_count links after rerun, found $reinstalled"
fi

if [ "$failures" -gt 0 ]; then
  printf '\ninstall-claude.sh smoke test failed with %d issue(s).\n' "$failures" >&2
  exit 1
fi

printf 'install-claude.sh smoke test passed (%s skill(s); sync + prune + idempotent).\n' "$skill_count"
