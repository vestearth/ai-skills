#!/usr/bin/env bash
#
# Install (sync) the ai-skills library into a Claude Code skills directory.
#
# Claude Code discovers skills from `<workspace-root>/.claude/skills/` (and the
# per-user `~/.claude/skills/`). This repo ships each skill under `skills/<name>/`
# but Claude never reads that path on its own. Run this script to mirror every
# `skills/<name>/` into the target `.claude/skills/` as an absolute symlink, so
# repo updates (and `git pull`) flow through without re-copying.
#
# It also PRUNES stale mirror entries: any symlink in the target that points into
# this repo's `skills/` but whose source folder no longer exists (e.g. a skill
# that was deleted or renamed) is removed. This is what keeps the mirror from
# drifting when skills are added or removed.
#
# Layouts (which folder is the Claude Code workspace root?):
#   nested (default) - you open the PARENT folder that contains ai-skills/ as the
#                      workspace (the recommended layout, and how this team works).
#                      Target: <parent>/.claude/skills  (parent = dir above
#                      ai-skills, or DIR when you pass `--nested DIR`).
#   standalone       - you open ai-skills ITSELF as the workspace.
#                      Target: ai-skills/.claude/skills.
#   --user           - the per-user library at ~/.claude/skills.
#
# Usage:
#   scripts/install-claude.sh                 # nested: into <parent-of-ai-skills>/.claude/skills
#   scripts/install-claude.sh --nested DIR    # nested: into DIR/.claude/skills
#   scripts/install-claude.sh --standalone    # into ai-skills/.claude/skills
#   scripts/install-claude.sh --user          # into ~/.claude/skills
#
# After syncing, this runs scripts/validate-skills.sh. Note: the validator checks
# the repo source, not the installed mirror. New/removed skills take effect in the
# NEXT Claude Code session (the skill list is loaded at session start).
#
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="$ROOT_DIR/skills"

TARGET_PROJECT="$(dirname "$ROOT_DIR")"

case "${1:-}" in
  --nested)
    if [ -z "${2:-}" ]; then
      echo "error: --nested requires a project-root path" >&2
      exit 2
    fi
    TARGET_PROJECT="$(cd "$2" && pwd)"
    ;;
  --standalone)
    TARGET_PROJECT="$ROOT_DIR"
    ;;
  --user)
    TARGET_PROJECT="$HOME"
    ;;
  "" )
    ;;
  -h|--help)
    grep '^#' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  *)
    echo "error: unknown argument '$1' (use --nested DIR, --standalone, --user, or no args)" >&2
    exit 2
    ;;
esac

if [ ! -d "$SRC_DIR" ]; then
  echo "error: skills source not found: $SRC_DIR" >&2
  exit 1
fi

DEST_DIR="$TARGET_PROJECT/.claude/skills"
mkdir -p "$DEST_DIR"

# Prune stale mirror entries: symlinks pointing into THIS repo's skills/ whose
# source folder is gone. Leave unrelated files/symlinks (other libraries) alone.
pruned=0
for link in "$DEST_DIR"/*; do
  [ -L "$link" ] || continue
  target="$(readlink "$link")"
  case "$target" in
    "$SRC_DIR"/*)
      if [ ! -d "$target" ]; then
        rm -f "$link"
        pruned=$((pruned + 1))
      fi
      ;;
  esac
done

# (Re)link every current skill folder as an absolute symlink.
installed=0
for dir in "$SRC_DIR"/*/; do
  [ -f "$dir/SKILL.md" ] || continue
  name="$(basename "$dir")"
  ln -sfn "${dir%/}" "$DEST_DIR/$name"
  installed=$((installed + 1))
done

echo "Synced $installed skill(s) into ${DEST_DIR} (pruned $pruned stale link(s))."

echo "Validating repo skill sources..."
"$ROOT_DIR/scripts/validate-skills.sh"

echo "Done. New or removed skills take effect in the next Claude Code session."
