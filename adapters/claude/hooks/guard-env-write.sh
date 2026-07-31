#!/usr/bin/env bash
# PreToolUse (Edit|Write|MultiEdit|NotebookEdit) guard:
# Block agent writes to operator-owned .env files under ~/Documents/GitHub.
# Enforces ai-skills/rules/no-secrets-in-repo/RULE.md at the tool layer.
#
# Blocks:   .env, .env.local, .env.staging, .env.production, ...
# Allows:   .env.example / .env.sample / .env.template / .env.dist (templates)
#
# Scope: file-edit tools only. Bash writes (`echo >> .env`, `sed -i`, `cp`) are
# covered by the companion guard-env-bash.sh on the Bash matcher.
#
# Exit 2 = block the tool call and return stderr to the model.

input="$(cat)"
f="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' 2>/dev/null)"

# No file path -> nothing to check.
[ -z "$f" ] && exit 0

base="$(basename "$f")"

# Templates carry placeholders, not values: always allowed.
case "$base" in
  .env.example|.env.sample|.env.template|.env.dist) exit 0 ;;
esac

case "$base" in
  .env|.env.*)
    cat >&2 <<EOF
BLOCKED by no-secrets-in-repo: ${f} is operator-owned and must not be written by an agent.

Do this instead:
  1. Add the key to the matching .env.example with an empty or clearly fake placeholder.
  2. Tell the operator the key name and where the real value must be set
     (local .env, CI secret store, cluster Secret, or vault).
  3. Never copy a value from the conversation, a log, or another environment.

Full rule: ai-skills/rules/no-secrets-in-repo/RULE.md
If the operator explicitly asked for this exact file to change, say so and ask them to apply it.
EOF
    exit 2
    ;;
esac

exit 0
