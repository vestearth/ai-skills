#!/usr/bin/env bash
# Runs the .env Bash-guard case table. Cases live in a data file so this
# script's own command line never contains the fixture strings.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Test the committed source, not an installed symlink — the mirror is the
# installer's job, and a broken symlink should fail install, not these cases.
HOOK="${GUARD_ENV_BASH_HOOK:-$DIR/../guard-env-bash.sh}"
CASES="$DIR/env-guard-cases.txt"
pass=0; fail=0

while IFS=$'\t' read -r exp raw; do
  [ -z "$exp" ] && continue
  cmd="$(printf '%b' "$raw")"
  rc=$(jq -n --arg c "$cmd" '{tool_input:{command:$c}}' | "$HOOK" >/dev/null 2>&1; echo $?)
  first="$(printf '%s' "$cmd" | head -1)"
  if [ "$rc" = "$exp" ]; then
    pass=$((pass+1)); printf 'ok    exp=%s got=%s  %s\n' "$exp" "$rc" "$first"
  else
    fail=$((fail+1)); printf 'FAIL  exp=%s got=%s  %s\n' "$exp" "$rc" "$first"
  fi
done < "$CASES"

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
