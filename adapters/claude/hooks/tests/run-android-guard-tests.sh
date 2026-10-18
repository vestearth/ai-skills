#!/usr/bin/env bash
# Runs the read-only Android guard case table. Cases live in a data file so
# this script's own command line never contains the fixture strings.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="${GUARD_ANDROID_HOOK:-$DIR/../guard-android-write.sh}"
CASES="$DIR/android-guard-cases.txt"
pass=0; fail=0

while IFS=$'\t' read -r exp kind raw; do
  case "$exp" in ''|'#'*) continue ;; esac
  value="$(printf '%b' "$raw")"
  if [ "$kind" = "path" ]; then
    payload="$(jq -n --arg p "$value" '{tool_input:{file_path:$p}}')"
  else
    payload="$(jq -n --arg c "$value" '{tool_input:{command:$c}}')"
  fi
  rc=$(printf '%s' "$payload" | "$HOOK" >/dev/null 2>&1; echo $?)
  if [ "$rc" = "$exp" ]; then
    pass=$((pass+1)); printf 'ok    exp=%s got=%s  %s %s\n' "$exp" "$rc" "$kind" "$value"
  else
    fail=$((fail+1)); printf 'FAIL  exp=%s got=%s  %s %s\n' "$exp" "$rc" "$kind" "$value"
  fi
done < "$CASES"

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
