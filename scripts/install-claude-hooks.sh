#!/usr/bin/env bash
#
# Install (sync) the ai-skills Claude-lane PreToolUse hooks into a workspace.
#
# Claude Code runs hooks named in `<workspace-root>/.claude/settings.json`. This
# repo ships the hook scripts under `adapters/claude/hooks/`, which Claude never
# reads on its own. This script mirrors each hook into the target
# `.claude/hooks/` as an absolute symlink, so repo edits and `git pull` flow
# through without re-copying — the same model as install-claude.sh for skills.
#
# It PRUNES stale mirror entries: any symlink in the target pointing into this
# repo's `adapters/claude/hooks/` whose source is gone. Unrelated hooks (other
# libraries, hand-written local hooks) are left alone.
#
# It does NOT edit settings.json. Hook wiring is operator configuration — which
# matchers to enable is a policy choice, and a bash JSON merge is a bad way to
# touch a file the operator hand-maintains. The script prints the snippet to add
# and reports whether each hook is already wired.
#
# Layouts (which folder is the Claude Code workspace root?):
#   nested (default) - you open the PARENT folder that contains ai-skills/ as the
#                      workspace. Target: <parent>/.claude/hooks
#   standalone       - you open ai-skills ITSELF. Target: ai-skills/.claude/hooks
#   --user           - the per-user location ~/.claude/hooks
#
# Usage:
#   scripts/install-claude-hooks.sh                 # nested
#   scripts/install-claude-hooks.sh --nested DIR
#   scripts/install-claude-hooks.sh --standalone
#   scripts/install-claude-hooks.sh --user
#
# Hooks take effect in the NEXT Claude Code session (settings load at start).
#
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="$ROOT_DIR/adapters/claude/hooks"

TARGET_PROJECT="$(dirname "$ROOT_DIR")"

case "${1:-}" in
  --nested)
    if [ -z "${2:-}" ]; then
      echo "error: --nested requires a project-root path" >&2
      exit 2
    fi
    TARGET_PROJECT="$(cd "$2" && pwd)"
    ;;
  --standalone) TARGET_PROJECT="$ROOT_DIR" ;;
  --user)       TARGET_PROJECT="$HOME" ;;
  "" ) ;;
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
  echo "error: hooks source not found: $SRC_DIR" >&2
  exit 1
fi

DEST_DIR="$TARGET_PROJECT/.claude/hooks"
SETTINGS="$TARGET_PROJECT/.claude/settings.json"
mkdir -p "$DEST_DIR"

pruned=0
for link in "$DEST_DIR"/*; do
  [ -L "$link" ] || continue
  target="$(readlink "$link")"
  case "$target" in
    "$SRC_DIR"/*)
      if [ ! -e "$target" ]; then
        rm -f "$link"
        pruned=$((pruned + 1))
      fi
      ;;
  esac
done

installed=0
for hook in "$SRC_DIR"/*.sh; do
  [ -f "$hook" ] || continue
  chmod +x "$hook" 2>/dev/null || true
  ln -sfn "$hook" "$DEST_DIR/$(basename "$hook")"
  installed=$((installed + 1))
done

echo "Synced $installed hook(s) into ${DEST_DIR} (pruned $pruned stale link(s))."

echo "Running hook tests against the committed source..."
for suite in "$SRC_DIR"/tests/*.sh; do
  [ -f "$suite" ] || continue
  "$suite" >/dev/null || {
    echo "error: hook tests failed in $(basename "$suite") — not safe to rely on these hooks" >&2
    exit 1
  }
done
echo "Hook tests passed."

# Report wiring without touching the operator's settings.json.
unwired=0
for hook in "$SRC_DIR"/*.sh; do
  name="$(basename "$hook")"
  if [ -f "$SETTINGS" ] && grep -q "$name" "$SETTINGS"; then
    echo "  wired:   $name"
  else
    echo "  UNWIRED: $name"
    unwired=$((unwired + 1))
  fi
done

if [ "$unwired" -gt 0 ]; then
  cat <<EOF

$unwired hook(s) are installed but not referenced by $SETTINGS.
Add an entry per hook on the event it listens to, for example:

  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit|NotebookEdit",
        "hooks": [{ "type": "command",
                    "command": "$DEST_DIR/guard-env-write.sh",
                    "timeout": 10 }]
      },
      {
        "matcher": "Bash",
        "hooks": [{ "type": "command",
                    "command": "$DEST_DIR/guard-env-bash.sh",
                    "timeout": 10 }]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [{ "type": "command",
                    "command": "$DEST_DIR/skill-routing.sh",
                    "timeout": 5 }]
      }
    ]
  }
EOF
fi

echo "Done. Hooks take effect in the next Claude Code session."
