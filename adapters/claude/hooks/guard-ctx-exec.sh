#!/usr/bin/env bash
# PreToolUse guard for context-mode's sandbox executors:
#   ctx_execute {language, code}, ctx_execute_file {path, language, code},
#   ctx_batch_execute {commands[].command}
# under either install name (mcp__context-mode__* or
# mcp__plugin_context-mode_context-mode__*).
#
# Why: the Bash guards read .tool_input.command and are matched on Bash only,
# so code run through the sandbox would pass none of them. This hook re-feeds
# that code to the SAME guards instead of re-implementing their policy, and
# adds one rule of its own: verification output stays raw (pilot plan,
# ai-dev-office/docs/context-mode-pilot.md).
#
#   1. Verification commands (tests, builds, lint, validate-yaml, migrations)
#      are blocked here — run them in native Bash so the full log is evidence.
#   2. Shell code (shell language, every batch command) is piped as
#      {tool_input:{command}} through each hook in GUARD_CTX_DELEGATES
#      (colon-separated; default: sibling guard-env-bash.sh). ctx_execute_file's
#      `path` is NOT passed: it is a read, and path-based guards block reads.
#   3. Non-shell code (python, node, ...) cannot be judged by a shell pattern
#      guard, so it fails closed when it names a real .env file or any term in
#      GUARD_CTX_PROTECTED (colon-separated, e.g. Games-Lab-Android).
#
# Fails CLOSED: missing jq, an unparseable payload, or a configured delegate
# that is missing or errors all block. Exit 2 = block, stderr goes to the model.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

block() {
  printf 'BLOCKED by guard-ctx-exec: %s\n' "$1" >&2
  exit 2
}

input="$(cat)"
[ -z "$input" ] && exit 0

command -v jq >/dev/null 2>&1 || block "jq is unavailable, so this sandbox call could not be inspected."
printf '%s' "$input" | jq -e 'type == "object"' >/dev/null 2>&1 \
  || block "the hook payload could not be parsed, so this sandbox call could not be inspected."

tool="$(printf '%s' "$input" | jq -r '.tool_name // ""')"
case "${tool##*__}" in
  ctx_execute|ctx_execute_file|ctx_batch_execute) ;;
  *) exit 0 ;;
esac

# Units of code to judge, NUL-free: one JSON string per line, decoded on read.
# Shell units are tagged "s", non-shell "n".
units="$(printf '%s' "$input" | jq -r '
  .tool_input as $t
  | if ($t.commands | type) == "array" then
      $t.commands[] | "s\t" + ((.command // "") | @json)
    else
      (if (($t.language // "") | ascii_downcase) | IN("shell","bash","sh","zsh")
       then "s" else "n" end) + "\t" + (($t.code // "") | @json)
    end')" || block "the hook payload could not be parsed, so this sandbox call could not be inspected."

# Command position: start of line, after an operator, or opening a string or
# subshell (a quoted command inside python/node code is still a command).
cp='(^|[;&|({`'"'"'"]|&&|\$\()[[:space:]]*([^[:space:];&|]*/)?'
strong="${cp}(go[[:space:]]+(test|build|vet)([[:space:]]|$)|golangci-lint|gofmt[[:space:]]+-l|(npm|pnpm|yarn)[[:space:]]+(run[[:space:]]+)?(test|build|lint|typecheck)([:[:space:]]|$)|npx[[:space:]]+(vitest|jest|playwright|tsc|eslint)|playwright[[:space:]]+test|docker[[:space:]]+((buildx[[:space:]]+)?build|compose[[:space:]]+build)|cargo[[:space:]]+(test|build)|bundle[[:space:]]+exec[[:space:]]+(rspec|rake)|ruby[[:space:]]+[^[:space:]]*(validate-yaml\.rb|tests?/)|[^[:space:]]*validate-yaml\.rb)"
# Ambiguous as words in prose/strings, so judged in shell units only.
weak="${cp}(make|vitest|jest|eslint|tsc|pytest|migrate|goose|atlas)([[:space:]]|$)"
shell_invocation='(^|[;&|(]|[[:space:]])(bash|sh|zsh|eval)([[:space:]]|$)'

verify_msg="verification output must stay raw. Run tests/builds/lint/validate-yaml/migrations in native Bash (no | tail, | grep, or intent filter); if the log is large, write it to a scratchpad file and Read the failing section. Rule: root CLAUDE.md, context-mode pilot."

IFS=':' read -r -a delegates <<< "${GUARD_CTX_DELEGATES:-$DIR/guard-env-bash.sh}"
IFS=':' read -r -a protected <<< "${GUARD_CTX_PROTECTED:-}"

while IFS=$'\t' read -r kind raw; do
  [ -z "$kind" ] && continue
  code="$(printf '%s' "$raw" | jq -r '.')"
  [ -z "$code" ] && continue

  if [ "$kind" = "s" ]; then
    # Quoted args are data (grep 'go test' docs/) unless the code feeds a shell.
    probe="$code"
    if ! printf '%s' "$code" | grep -qE "$shell_invocation"; then
      probe="$(printf '%s' "$code" | sed -E "s/'[^']*'//g; s/\"[^\"]*\"//g")"
    fi
    if printf '%s' "$probe" | grep -qE "$strong" || printf '%s' "$probe" | grep -qE "$weak"; then
      block "$verify_msg"
    fi

    payload="$(jq -n --arg c "$code" '{tool_name:"Bash", tool_input:{command:$c}}')"
    for d in "${delegates[@]}"; do
      [ -z "$d" ] && continue
      [ -x "$d" ] || block "delegate guard $d is missing or not executable, so this sandbox call could not be checked."
      err="$(printf '%s' "$payload" | "$d" 2>&1 >/dev/null)"
      rc=$?
      [ "$rc" -eq 0 ] && continue
      [ "$rc" -eq 2 ] && block "sandbox code was refused by $(basename "$d"):
$err"
      block "delegate guard $(basename "$d") failed (exit $rc), so this sandbox call could not be checked."
    done
  else
    if printf '%s' "$code" | grep -qE "$strong"; then
      block "$verify_msg"
    fi
    if printf '%s' "$code" | grep -oE '\.env(\.[A-Za-z0-9_-]+)?' \
        | grep -vqxE '\.env\.(example|sample|template|dist)'; then
      block "non-shell sandbox code names a .env file. A shell pattern guard cannot judge interpreter code, so this fails closed; read it with a plain shell command if you must."
    fi
    for term in "${protected[@]}"; do
      [ -z "$term" ] && continue
      if printf '%s' "$code" | grep -qF -- "$term"; then
        block "non-shell sandbox code names protected target '$term'. Interpreter code cannot be judged read-only, so this fails closed; use ctx_execute_file (path) or a shell command."
      fi
    done
  fi
done <<< "$units"

exit 0
