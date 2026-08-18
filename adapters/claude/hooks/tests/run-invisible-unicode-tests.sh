#!/usr/bin/env bash
# Tests for clean-invisible-unicode.sh (PostToolUse auto-strip lane).
#
# The hook mutates files an agent just wrote, so the cases that matter most are
# the ones where it must do NOTHING: emoji, fixtures, binaries, visible spaces.

set -uo pipefail

HOOK="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/clean-invisible-unicode.sh"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

pass=0
fail=0

run_hook() {
  printf '{"tool_input":{"file_path":"%s"}}' "$1" | bash "$HOOK" >/dev/null 2>&1
}

check() { # name expected actual
  if [ "$2" = "$3" ]; then
    pass=$((pass + 1))
    printf 'ok   %s\n' "$1"
  else
    fail=$((fail + 1))
    printf 'FAIL %s\n  expected: %s\n  actual:   %s\n' "$1" "$2" "$3"
  fi
}

# 1. zero-width space is stripped
f="$WORK/note.md"
printf 'hello\xe2\x80\x8bworld\n' > "$f"
run_hook "$f"
check "strips U+200B" "helloworld" "$(cat "$f")"

# 2. BOM is stripped
f="$WORK/bom.txt"
printf '\xef\xbb\xbfhello\n' > "$f"
run_hook "$f"
check "strips U+FEFF" "hello" "$(cat "$f")"

# 3. emoji ZWJ glue, VS16, and flag tag sequences survive
f="$WORK/emoji.md"
before='family 👨‍👩‍👧 heart ❤️ flag 🏴󠁧󠁢󠁳󠁣󠁴󠁿'
printf '%s\n' "$before" > "$f"
run_hook "$f"
check "preserves emoji glue and flag tags" "$before" "$(cat "$f")"

# 4. visible-width spaces are left alone (--no-normalize-spaces)
f="$WORK/nbsp.md"
before="$(printf '10\xc2\xa0km')"
printf '%s\n' "$before" > "$f"
run_hook "$f"
check "preserves NBSP" "$before" "$(cat "$f")"

# 5. Thai text with no marks is untouched
f="$WORK/thai.md"
printf 'สวัสดีครับ\n' > "$f"
run_hook "$f"
check "leaves clean Thai unchanged" "สวัสดีครับ" "$(cat "$f")"

# 6-8. fixture paths keep their deliberate marks
for dir in tests fixtures testdata; do
  mkdir -p "$WORK/$dir"
  f="$WORK/$dir/sample.txt"
  printf 'a\xe2\x80\x8bb\n' > "$f"
  run_hook "$f"
  check "skips $dir/" "$(printf 'a\xe2\x80\x8bb')" "$(cat "$f")"
done

# 9. binaries are refused, not mangled
f="$WORK/blob.png"
printf '\x89PNG\r\n\x1a\n\x00\x00\x00\x0dIHDR\x00\x00' > "$f"
sum_before="$(cksum < "$f")"
run_hook "$f"
check "leaves binary untouched" "$sum_before" "$(cksum < "$f")"

# 10. file mode survives the rewrite
f="$WORK/script.sh"
printf '#!/bin/sh\necho a\xe2\x80\x8bb\n' > "$f"
chmod 755 "$f"
run_hook "$f"
check "preserves file mode" "755" "$(stat -f '%OLp' "$f" 2>/dev/null || stat -c '%a' "$f")"

# 11. missing path is a silent no-op
printf '{"tool_input":{}}' | bash "$HOOK" >/dev/null 2>&1
check "no file_path exits 0" "0" "$?"

# 12. a missing cleaner never blocks
printf '{"tool_input":{"file_path":"%s"}}' "$WORK/note.md" \
  | WATERMARKS_REMOVER_DIR="$WORK/nope" bash "$HOOK" >/dev/null 2>&1
check "missing cleaner exits 0" "0" "$?"

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
