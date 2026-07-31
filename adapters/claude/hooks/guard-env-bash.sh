#!/usr/bin/env bash
# PreToolUse (Bash) guard:
# Block shell commands that WRITE to an operator-owned .env file.
# Companion to guard-env-write.sh, which covers the file-edit tools.
# Enforces ai-skills/rules/no-secrets-in-repo/RULE.md at the tool layer.
#
# SCOPE, stated honestly: the shell is Turing-complete and this is pattern
# matching over a command line. It cannot be sound against an agent that is
# actively trying to evade it (arbitrary interpreters, indirection through
# variables, a script file that writes .env from inside). It IS a hard stop for
# accidental and casual writes, which is the realistic failure mode.
#
# Blocks:  redirects (> >> >|), tee, sed -i / perl -i, cp mv rm truncate dd ln
#          install touch chmod chown shred unlink rsync tar unzip, git
#          restore/checkout/clean/rm, find -delete/-exec, inline interpreter
#          one-liners (python -c, perl -e, node -e, ...), and assignment
#          indirection (f=.env ... > "$f").
# Allows:  reads (cat/grep/source/docker --env-file) and every .env template
#          (.env.example / .env.sample / .env.template / .env.dist)
#
# Fails CLOSED: missing jq or unparseable input blocks rather than allows.
#
# Exit 2 = block the tool call and return stderr to the model.

block() {
  printf '%s\n' "$1" >&2
  cat >&2 <<'GUIDANCE'

.env files are operator-owned and must not be written by an agent.
Do this instead:
  1. Add the key to the matching .env.example with an empty or clearly fake placeholder.
  2. Tell the operator the key name and where the real value must be set
     (local .env, CI secret store, cluster Secret, or vault).
  3. Never copy a value from the conversation, a log, or another environment.

Reading a .env is not blocked, but do not echo credential values into output.
Full rule: ai-skills/rules/no-secrets-in-repo/RULE.md
GUIDANCE
  exit 2
}

input="$(cat)"

# Nothing to inspect: no stdin at all means no tool call to judge.
[ -z "$input" ] && exit 0

# Fail closed on a broken toolchain — a security control must not silently
# allow because a dependency vanished.
command -v jq >/dev/null 2>&1 || \
  block "BLOCKED by no-secrets-in-repo: jq is unavailable, so this command could not be inspected."

if ! cmd="$(printf '%s' "$input" | jq -er '.tool_input.command // ""' 2>/dev/null)"; then
  block "BLOCKED by no-secrets-in-repo: the hook payload could not be parsed, so this command could not be inspected."
fi

[ -z "$cmd" ] && exit 0

# --- Normalization --------------------------------------------------------
# Quote removal defeats `.e''nv` and `".env"` splitting a path into tokens that
# no longer look like a .env. All later matching runs on the de-quoted form.
# Heredoc bodies are DATA passed to another program (python3 - <<'PY', jq, sql),
# not shell the caller runs. Prose in them ("never do echo >> .env") otherwise
# blocks documentation edits — that fired on this hook's own write-up. The
# heredoc's opening line is kept, so `cat > .env <<'EOF'` still blocks.
#
# Scrub FIRST, then ask whether the *command* invokes a shell. Testing the raw
# text would let a heredoc body that merely mentions "bash" in prose disable
# scrubbing for itself — that blocked this hook's own commit message.
scrub_heredocs() {
  awk '
    { line = $0
      if (tag != "") {
        probe = line; gsub(/^[ \t]+|[ \t]+$/, "", probe)
        if (probe == tag) tag = ""
        next
      }
      if (match(line, /<<-?[ \t]*['"'"'"]?[A-Za-z_][A-Za-z0-9_]*['"'"'"]?/)) {
        t = substr(line, RSTART, RLENGTH)
        sub(/^<<-?[ \t]*/, "", t); gsub(/['"'"'"]/, "", t)
        tag = t
      }
      print line
    }'
}

scrubbed="$(printf '%s\n' "$cmd" | scrub_heredocs)"

# A command that feeds a shell executes its heredoc body as shell, so for those
# the body must be analyzed after all. Word-aware so `shasum` is not `sh`.
shell_invocation='(^|[|;&(]|[[:space:]])(env[[:space:]]+([A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+)*)?((/usr)?/bin/)?(bash|sh|zsh|ksh|dash)([[:space:]]|$)'

if printf '%s' "$scrubbed" | grep -qE "$shell_invocation"; then
  scrubbed="$cmd"
fi

dequoted="$(printf '%s' "$scrubbed" | tr -d '"'"'")"

# --- Stage A: does any token resolve to a real .env file? ------------------
env_ref=0
while IFS= read -r tok; do
  [ -z "$tok" ] && continue
  base="${tok##*/}"
  case "$base" in
    .env.example|.env.sample|.env.template|.env.dist) continue ;;
    # Literal paths, plus glob forms like `.env*` used by `rm -f .env*`.
    # `.envrc` matches none of these.
    .env|.env.*|.env\**|.env\?*|.env\[*) env_ref=1; break ;;
  esac
done <<EOF
$(printf '%s' "$dequoted" | tr ' \t\n|;&()<>=,:' '\n')
EOF

[ "$env_ref" -eq 0 ] && exit 0

# --- Stage B: is a write aimed at it? -------------------------------------
env_target='[^[:space:]|;&]*\.env(\.[A-Za-z0-9_*?-]+|\*)?'

# `>`, `>>`, and bash's `>|` clobber redirect.
redirect_re=">>?\|?[[:space:]]*${env_target}"
tee_re="(^|[|;&[:space:]])tee([[:space:]]+-[^[:space:]]+)*[[:space:]]+${env_target}"
inplace_re="(sed[[:space:]]+[^|;&]*(-[A-Za-z]*i|--in-place)|perl[[:space:]]+-[A-Za-z]*i)"
verb_re="(^|[[:space:]{(|;&])(cp|mv|rm|truncate|dd|install|ln|touch|chmod|chown|shred|unlink|rsync|tar|unzip|sponge)([[:space:]]|$)"
git_re="git([[:space:]]+-[^[:space:]]+)*[[:space:]]+(restore|checkout|clean|rm)([[:space:]]|$)"
find_re="find[[:space:]].*(-delete|-exec)"
# Inline interpreter one-liners: the write is visible on the command line.
interp_re="(python[0-9.]*|perl|ruby|node|deno|php)[[:space:]]+-[A-Za-z]*[ecrE]([[:space:]]|$)"
# Indirection: f=.env ... > "$f"
assign_re="[A-Za-z_][A-Za-z0-9_]*=[^[:space:];|&]*\.env"
anywrite_re="(>|(^|[[:space:]])tee([[:space:]]|$)|--in-place|-i([[:space:]]|$))"

m() { printf '%s' "$dequoted" | grep -qE "$1"; }

reason=""
if   m "$redirect_re"; then reason="shell redirection (>, >>, or >|) into a .env file"
elif m "$tee_re";      then reason="tee writing to a .env file"
elif m "$inplace_re";  then reason="an in-place edit (sed -i / perl -i) of a .env file"
elif m "$git_re";      then reason="a git command that overwrites or removes a .env file"
elif m "$find_re";     then reason="find -delete/-exec touching a .env file"
elif m "$interp_re";   then reason="an inline interpreter one-liner referencing a .env file"
elif m "$verb_re";     then reason="a destructive file command (cp/mv/rm/rsync/tar/truncate/…) targeting a .env file"
elif m "$assign_re" && m "$anywrite_re"; then
  reason="a write through a variable holding a .env path"
fi

[ -z "$reason" ] && exit 0

block "BLOCKED by no-secrets-in-repo: this command performs ${reason}.

  ${cmd}"
