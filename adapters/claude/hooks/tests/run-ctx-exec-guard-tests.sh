#!/usr/bin/env bash
# Runs the context-mode sandbox guard case table. Payloads live in a data file
# so this script's own command line never contains the fixture strings.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="${GUARD_CTX_EXEC_HOOK:-$DIR/../guard-ctx-exec.sh}"
CASES="$DIR/ctx-exec-guard-cases.txt"

ANDROID="${GUARD_ANDROID_HOOK:-$DIR/../guard-android-write.sh}"
export GUARD_CTX_DELEGATES="$DIR/../guard-env-bash.sh"
skip_android=0
if [ -x "$ANDROID" ]; then
  GUARD_CTX_DELEGATES="$GUARD_CTX_DELEGATES:$ANDROID"
  export GUARD_CTX_PROTECTED="Games-Lab-Android"
else
  skip_android=1
  echo "note: $ANDROID not found — skipping Games-Lab-Android cases"
fi

pass=0; fail=0; skipped=0
while IFS=$'\t' read -r exp payload; do
  case "$exp" in ''|'#'*) continue ;; esac
  if [ "$skip_android" -eq 1 ] && printf '%s' "$payload" | grep -q 'Games-Lab-Android'; then
    skipped=$((skipped+1)); continue
  fi
  rc=$(printf '%s' "$payload" | "$HOOK" >/dev/null 2>&1; echo $?)
  short="$(printf '%s' "$payload" | cut -c1-110)"
  if [ "$rc" = "$exp" ]; then
    pass=$((pass+1)); printf 'ok    exp=%s got=%s  %s\n' "$exp" "$rc" "$short"
  else
    fail=$((fail+1)); printf 'FAIL  exp=%s got=%s  %s\n' "$exp" "$rc" "$short"
  fi
done < "$CASES"

printf '\n%d passed, %d failed, %d skipped\n' "$pass" "$fail" "$skipped"
[ "$fail" -eq 0 ]
