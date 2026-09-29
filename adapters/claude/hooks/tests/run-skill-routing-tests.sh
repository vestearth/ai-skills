#!/usr/bin/env bash
# Runs the skill-routing domain-row case table. Each case says whether the
# domain keyword table must (match) or must not (nomatch) surface a skill for a
# prompt. Only the "domain skill ที่ keyword ตรง" section is inspected: the core
# block names skills on every prompt by design.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="${SKILL_ROUTING_HOOK:-$DIR/../skill-routing.sh}"
CASES="$DIR/skill-routing-cases.txt"
pass=0; fail=0

domain_section() {
  jq -r '.hookSpecificOutput.additionalContext // empty' 2>/dev/null \
    | sed -n '/^domain skill ที่ keyword/,$p'
}

while IFS=$'\t' read -r exp skill prompt; do
  [ -z "$exp" ] && continue
  section="$(jq -n --arg p "$prompt" '{prompt:$p}' | "$HOOK" | domain_section)"
  if printf '%s\n' "$section" | grep -q "^  $skill — "; then got=match; else got=nomatch; fi
  if [ "$got" = "$exp" ]; then
    pass=$((pass+1)); printf 'ok    exp=%s got=%s  %s | %s\n' "$exp" "$got" "$skill" "$prompt"
  else
    fail=$((fail+1)); printf 'FAIL  exp=%s got=%s  %s | %s\n' "$exp" "$got" "$skill" "$prompt"
  fi
done < "$CASES"

# Slash commands carry their own instructions: the hook must stay silent.
out="$(jq -n '{prompt:"/loop 5m check"}' | "$HOOK")"
if [ -z "$out" ]; then
  pass=$((pass+1)); echo 'ok    slash command emits nothing'
else
  fail=$((fail+1)); echo 'FAIL  slash command emitted output'
fi

# --- once-per-session core block, task-notification skip ---------------------
STATE_DIR="$(mktemp -d)"; export SKILL_ROUTING_STATE_DIR="$STATE_DIR"
trap 'rm -rf "$STATE_DIR"' EXIT
run() { jq -n --arg p "$2" --arg s "$1" '{prompt:$p, session_id:$s}' | "$HOOK"; }
ctx() { jq -r '.hookSpecificOutput.additionalContext // empty' 2>/dev/null; }
check() { # name, condition-exit-code
  if [ "$2" -eq 0 ]; then pass=$((pass+1)); echo "ok    $1"; else fail=$((fail+1)); echo "FAIL  $1"; fi
}

run s1 "ช่วยดูโค้ดหน่อย" | ctx | grep -q 'search-first ก่อนไล่หาไฟล์'
check "first prompt of a session carries the core block" $?

second="$(run s1 "ช่วยดูโค้ดต่อ" | ctx)"
[ -z "$second" ]
check "later prompt without keyword emits nothing" $?

third="$(run s1 "เช็ค dockerfile ให้หน่อย" | ctx)"
printf '%s' "$third" | grep -q '^  cicd-pipeline-review — ' && ! printf '%s' "$third" | grep -q 'search-first ก่อนไล่หาไฟล์'
check "later prompt with keyword emits domain row without core block" $?

run s2 "ช่วยดูโค้ดหน่อย" | ctx | grep -q 'search-first ก่อนไล่หาไฟล์'
check "a different session gets its own core block" $?

n=0; for i in $(seq 1 19); do out="$(run s3 "คุยเรื่องทั่วไป $i" | ctx)"; case "$out" in *"search-first ก่อนไล่หาไฟล์"*) n=$((n+1));; esac; done
[ "$n" -eq 1 ]
check "core block appears once in the first 19 prompts" $?
[ -z "$(run s3 "คุยเรื่องทั่วไป 20" | ctx)" ]
check "20th prompt stays quiet" $?
run s3 "คุยเรื่องทั่วไป 21" | ctx | grep -q 'search-first ก่อนไล่หาไฟล์'
check "21st prompt repeats the core block" $?

[ -n "$(jq -n '{prompt:"ช่วยดูโค้ดหน่อย"}' | "$HOOK" | ctx)" ]
check "no session_id falls back to core block every prompt" $?

out="$(run s4 '<task-notification> <task-id>a1</task-id> context workflow endpoint' )"
[ -z "$out" ]
check "task-notification emits nothing" $?
run s4 "ช่วยดูโค้ดหน่อย" | ctx | grep -q 'search-first ก่อนไล่หาไฟล์'
check "task-notification does not consume the session's first-prompt core block" $?

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
