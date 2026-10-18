#!/usr/bin/env bash
# PreToolUse guard: block agent writes under Games-Lab-Android/.
# Workspace-specific policy (the repo name is hard-coded), versioned here so it
# is tested and mirrored like the other hooks. Policy: workspace AGENTS.md
# "Read-Only Reference Repositories".
#
# Matchers: Edit|Write|MultiEdit|NotebookEdit, and Bash.
# Exit 2 = block the tool call and return stderr to the model.

set -euo pipefail

input="$(cat)"

path="$(printf '%s' "$input" | jq -r '
  .tool_input.file_path
  // .tool_input.notebook_path
  // .tool_input.path
  // empty
' 2>/dev/null || true)"

cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"

is_android_path() {
  local p="${1//\\//}"
  case "$p" in
    */Games-Lab-Android|*/Games-Lab-Android/*|Games-Lab-Android|Games-Lab-Android/*)
      return 0
      ;;
  esac
  return 1
}

block() {
  cat >&2 <<EOF
BLOCKED: Games-Lab-Android is a read-only reference repository.

Do not create, edit, delete, commit, push, or patch files there.
Read, search, and compare client workflows against backend/gateway instead.
If Android code must change, hand it to the human Android lane.

Canonical policy: AGENTS.md (Read-Only Reference Repositories).
EOF
  exit 2
}

if [ -n "$path" ] && is_android_path "$path"; then
  block
fi

if [ -n "$cmd" ] && printf '%s' "$cmd" | grep -q 'Games-Lab-Android'; then
  if printf '%s' "$cmd" | grep -Eqi \
    'git[[:space:]].*\b(add|commit|push|checkout|reset|rebase|merge|cherry-pick|stash|clean|rm|mv)\b|sed[[:space:]]+-[[:alnum:]]*i|[[:space:]]tee[[:space:]]|rm[[:space:]]+|mv[[:space:]]+|cp[[:space:]]+|mkdir[[:space:]]+|chmod[[:space:]]+|>(>|&)?|patch[[:space:]]|apply[[:space:]]|gradlew|gradle[[:space:]]'; then
    block
  fi
fi

exit 0
