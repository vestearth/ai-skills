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

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
