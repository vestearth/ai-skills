#!/usr/bin/env bash
#
# Install the ai-skills Cursor adapter rules into a Cursor-readable location.
#
# Cursor only auto-loads `.mdc` rules from `<workspace-root>/.cursor/rules/`.
# This repo ships its rules under `adapters/cursor/rules/`, which Cursor never
# reads on its own. Run this script to place them where Cursor looks, with the
# correct skill-path prefix for the layout you open in Cursor.
#
# Layouts (which folder is the Cursor workspace root?):
#   nested (default) - you open the PARENT folder that contains ai-skills/ as the
#                      Cursor workspace (the recommended project layout, and how
#                      this team works). Committed rules already use
#                      `ai-skills/skills/<skill>/SKILL.md`, which resolves from
#                      the parent, so they are symlinked as-is and track `git pull`.
#                      Target: <parent>/.cursor/rules  (parent = dir above ai-skills,
#                      or DIR when you pass `--nested DIR`).
#   standalone       - you open ai-skills ITSELF as the Cursor workspace. Skill
#                      paths are rewritten to `skills/<skill>/SKILL.md` and copied
#                      into ai-skills/.cursor/rules (copy, not symlink, since the
#                      content differs from the committed nested source).
#
# Usage:
#   scripts/install-cursor.sh                 # nested: into <parent-of-ai-skills>/.cursor/rules
#   scripts/install-cursor.sh --nested DIR    # nested: into DIR/.cursor/rules
#   scripts/install-cursor.sh --standalone    # standalone: into ai-skills/.cursor/rules
#
# Note: this wires the lane. An operator who runs several agents and keeps Cursor
# as the intentionally un-wired "naive" oracle lane (see ADR-0002) should simply
# NOT run this script on their machine.
#
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="$ROOT_DIR/adapters/cursor/rules"

MODE="nested"
TARGET_PROJECT="$(dirname "$ROOT_DIR")"

case "${1:-}" in
  --nested)
    MODE="nested"
    if [ -z "${2:-}" ]; then
      echo "error: --nested requires a project-root path" >&2
      exit 2
    fi
    TARGET_PROJECT="$(cd "$2" && pwd)"
    ;;
  --standalone)
    MODE="standalone"
    TARGET_PROJECT="$ROOT_DIR"
    ;;
  "" )
    ;;
  -h|--help)
    grep '^#' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  *)
    echo "error: unknown argument '$1' (use --nested DIR, --standalone, or no args)" >&2
    exit 2
    ;;
esac

if [ ! -d "$SRC_DIR" ]; then
  echo "error: adapter source not found: $SRC_DIR" >&2
  exit 1
fi

DEST_DIR="$TARGET_PROJECT/.cursor/rules"
mkdir -p "$DEST_DIR"

installed=0
for f in "$SRC_DIR"/*.mdc; do
  base="$(basename "$f")"
  dest="$DEST_DIR/$base"
  if [ "$MODE" = "nested" ]; then
    # Committed rules already use the `ai-skills/skills/...` prefix that resolves
    # from the parent workspace. Symlink so repo updates flow through.
    ln -sfn "$f" "$dest"
  else
    # Standalone: rewrite the backtick-anchored prefix to the workspace-root form.
    sed 's#`ai-skills/skills/#`skills/#g' "$f" > "$dest"
  fi
  installed=$((installed + 1))
done

echo "Installed $installed Cursor rule(s) into ${DEST_DIR} ($MODE layout)."
echo "Open that workspace in Cursor; the ai-skills routing rules load on matching edits."
