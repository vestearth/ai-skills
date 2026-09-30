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

# --- guardrail rules routing (rules/ is not skills; Claude got none of it) ---
RULES="minimal-change reuse-before-build search-before-create evidence-required verify-before-final context-discipline"
first="$(run r1 "ช่วยดูโค้ดหน่อย" | ctx)"
for r in $RULES; do
  printf '%s' "$first" | grep -q "ai-skills/rules/$r/RULE.md"
  check "core block routes rules/$r" $?
  [ -f "$DIR/../../../../rules/$r/RULE.md" ]
  check "rules/$r/RULE.md exists in the repo" $?
done
[ -z "$(run r1 "ช่วยดูโค้ดต่อ" | ctx)" ]
check "rules routing is not repeated on later prompts" $?

# In the nested workspace, root AGENTS.md is Codex/Cursor's rule route. Claude
# receives six of those rules from this hook and the other three from CLAUDE.md.
# Check the combined path set so changing either surface cannot silently drift.
WORKSPACE_AGENTS="${WORKSPACE_AGENTS:-$DIR/../../../../../AGENTS.md}"
WORKSPACE_CLAUDE="${WORKSPACE_CLAUDE:-$DIR/../../../../../CLAUDE.md}"
if [ -f "$WORKSPACE_AGENTS" ] && [ -f "$WORKSPACE_CLAUDE" ]; then
  root_rules="$(sed -n '/^### AI Skills Activation$/,/^Task → skill routing:/p' "$WORKSPACE_AGENTS" \
    | grep -oE 'ai-skills/rules/[a-z-]+/RULE\.md' | sort -u)"
  hook_rules="$(sed -n '/^\[ai-skills rules\]/,/^  (no-secrets-in-repo/p' "$HOOK" \
    | grep -oE 'ai-skills/rules/[a-z-]+/RULE\.md')"
  claude_rules="$(grep -oE 'ai-skills/rules/[a-z-]+/RULE\.md' "$WORKSPACE_CLAUDE")"
  routed_rules="$(printf '%s\n%s\n' "$hook_rules" "$claude_rules" | sed '/^$/d' | sort -u)"
  [ -n "$root_rules" ] && [ "$root_rules" = "$routed_rules" ]
  check "root AGENTS.md rules equal Claude hook + CLAUDE.md rules" $?

  # Codex truncates project instructions past project_doc_max_bytes (default
  # 32 KiB) from the END, silently to a reader who skips the CLI warning. The
  # root file was 35,342 bytes and truncated until trimmed 2026-09-30.
  agents_bytes="$(wc -c < "$WORKSPACE_AGENTS" | tr -d ' ')"
  doc_max="${CODEX_PROJECT_DOC_MAX_BYTES:-32768}"
  [ "$agents_bytes" -le "$doc_max" ]
  check "root AGENTS.md fits Codex project-doc limit ($agents_bytes <= $doc_max bytes)" $?
  [ $((doc_max - agents_bytes)) -ge 1024 ] || echo "warn  root AGENTS.md headroom is $((doc_max - agents_bytes)) bytes (<1 KiB): the next addition will be truncated"
else
  echo 'skip  workspace rule parity (AGENTS.md or CLAUDE.md unavailable)'
fi

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
