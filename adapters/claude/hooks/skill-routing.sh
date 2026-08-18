#!/usr/bin/env bash
# UserPromptSubmit hook: surface the ai-skills routing table to the model.
#
# Why this exists: ai-skills are description-matched only, and transcripts show
# they fire ~1x per session — the review-shaped ones win, while search-first /
# debugging / verification-loop never trigger. superpowers gets invoked because
# a SessionStart hook injects its dispatcher every session. This does the same
# for ai-skills, but per-prompt and scoped.
#
# Emits two parts via hookSpecificOutput.additionalContext:
#   1. a core block (always) — intent-routed skills the model must weigh itself,
#      because Thai intent phrasing defeats keyword matching (measured 1/14 hits
#      vs 17/17 for English domain nouns; see adapters/claude/README.md)
#   2. domain skills whose keywords match THIS prompt (at most MAX_MATCHES)
#
# Never blocks. Any failure exits 0 silently — a routing nudge must never cost
# the operator a turn.
#
# Matching: the prompt is lowercased and every non-alphanumeric byte becomes a
# space, so the haystack is space-delimited and space-wrapped. Patterns use
# explicit leading/trailing spaces for word matches (" ui ") instead of \b,
# which is not portable across BSD and GNU grep.
# Note this also means "go.mod" is matched as "go mod" and ".env" as " env ".

set -uo pipefail

MAX_MATCHES=6

input="$(cat 2>/dev/null)" || exit 0
prompt="$(printf '%s' "$input" | jq -r '.prompt // empty' 2>/dev/null)" || exit 0
[ -z "$prompt" ] && exit 0

# Slash commands carry their own instructions; a second routing table is noise.
case "$prompt" in /*) exit 0 ;; esac

# lowercase -> punctuation to space -> collapse runs -> wrap in spaces
hay=" $(printf '%s' "$prompt" \
  | tr '[:upper:]' '[:lower:]' \
  | tr -c '[:alnum:]\200-\377' ' ' \
  | tr -s ' ') "

# skill ~ one-line hint ~ extended regex matched against $hay
#
# This table holds DOMAIN skills only — ones anchored to stable technical nouns
# the operator always types in English (proto, argocd, clickhouse, ...).
# Intent-routed skills live in the always-on core block below instead: Thai
# intent phrasing has unbounded surface forms, so keyword rows for them never
# converge. Do not add core-block skills back here (except the six borderline
# ones noted below, which keep their rows as a bonus signal on top of core).
#
# Deliberately absent everywhere: knowledge-capture, knowledge-promote,
# knowledge-source-review, session-handoff, mcp-audit, permission-tuner,
# self-learning — operator-invoked / work-phase skills, not prompt-keyed.
# Every other new skill gets either a table row or a core-block line.
ROUTES=$(cat <<'TABLE'
api-contract-review~proto/gRPC/gateway mapping/field number~proto|grpc|gateway|openapi|swagger|endpoint|field number|contract
games-labs-api-review~Games Labs service + mobile-facing API~mission|wallet| vip |store|redemption|coupon|provider|backoffice|games labs|gameslabs
games-labs-implementation-status~คำถาม follow-up จาก mobile/QA/PM — เช็คโค้ดก่อนตอบ~ทีม mobile|mobile team|ตอบยังไง|ตอบอะไร|implemented yet|qa ถาม|ถามมา
change-impact-analysis~shared code/contract/schema/config ที่กระทบหลาย service~shared lib|impact|กระทบ|breaking|migration|schema
golang-service-review~handler/worker/consumer/repo/context ใน Go~handler|worker|consumer|repository|goroutine|context| golang | go service
golang-project-structure~วาง package/cmd/internal layout~โครงสร้าง|project structure|package layout| cmd | internal
rabbitmq-event-review~publisher/consumer/exchange/routing key/DLQ~rabbitmq|amqp|exchange|queue|routing key|publish|dead letter
clickhouse-io~ClickHouse table/ingestion/retention/analytics query~clickhouse
k8s-deploy-review~k8s/k3s manifest, ArgoCD, probes, image ref~kubernetes| k8s | k3s |kustomize|argocd|manifest|helm
cicd-pipeline-review~GitHub Actions, Dockerfile, build-push job~github actions|workflow|dockerfile|build push|pipeline| ci cd
secrets-management~secret/credential/token/.env/kubeconfig~secret|credential|token| env |kubeconfig|api key|รหัสผ่าน
dependency-guard~go.mod, Dockerfile, CI, shared dependency~go mod|go get|dependency|dependencies|bump|upgrade|package json
frontend-ui-review~หน้า/component เทียบ Figma + design system~figma|tailwind|component| ui |หน้าจอ|responsive|frontend|css
vendor-integration~provider callback, payout, launch URL, signature~vendor|callback|seamless|payout|balance| hmac |signature|third party
microservice-boundary-review~ownership / service ไหนควรถือ logic นี้~boundary|ownership|service ไหน|ควรอยู่ service|แยก service
tech-lead-review~architecture, cross-team impact, long-term maintainability~architecture|สถาปัตย|scalab|maintainab|long term|ระยะยาว
decision-grilling~stress-test แผน/design ก่อนลงมือ~ควรใช้|ตัดสินใจ|trade off|เลือกแบบไหน|approach ไหน|ดีกว่ากัน
deslop~กวาด AI slop ออกจาก diff ก่อน commit/handoff~slop|cleanup|ก่อน commit|tidy|เก็บกวาด
sprint-planning~แปลง goal/backlog เป็น scope + acceptance criteria~sprint|backlog|roadmap|วางแผน|แผนงาน
knowledge-query~งานนี้อาจพึ่งความรู้/ADR/บทเรียนเดิม~เคยทำ|ที่ผ่านมา|prior decision| adr |knowledge base
skill-authoring-review~แก้/เพิ่ม/ตัด skill ใน ai-skills~ai skills| skill |สกิล
weekly-report~สรุปงานรายสัปดาห์ + อัพเดท Weekly Review~weekly update|weekly review|สรุปงาน|สัปดาห์นี้|อาทิตย์นี้
socraticode-discovery~SocratiCode search/symbol/graph + ความสดของ index~socraticode|codebase search|semantic search|index
datadog-observability~metric/log/trace/dashboard/monitor/SLO~datadog|metric|dashboard|monitor| slo |observab
TABLE
)

matches=""
count=0
while IFS='~' read -r skill hint regex; do
  [ -z "${skill:-}" ] && continue
  [ "$count" -ge "$MAX_MATCHES" ] && break
  if printf '%s' "$hay" | grep -Eqi -- "$regex" 2>/dev/null; then
    matches="${matches}  ${skill} — ${hint}"$'\n'
    count=$((count + 1))
  fi
done <<< "$ROUTES"

# Intent-routed skills: always shown, the model judges applicability itself.
# Thai intent phrasing defeats grep (measured), so these never rely on keywords.
ctx="[ai-skills routing] — ประเมินเองว่า prompt นี้เข้าข้อไหน แล้วเรียก skill นั้นก่อนเริ่ม:
  search-first ก่อนไล่หาไฟล์ · debugging ก่อนเสนอ fix · verification-loop ก่อนเคลมว่าเสร็จ
  code-review เมื่อถูกขอให้ดู diff/PR · completion-audit เมื่อรับงานที่คนอื่นบอกว่าเสร็จ
  release-checklist ก่อน deploy · incident-response ถ้าของจริงล่ม · model-router ถ้างานเบากว่าโมเดล
  minimal-change-review ถ้าจะเพิ่มไฟล์/scaffold/abstraction · deslop ก่อน commit/handoff
  golang-project-structure วาง package/layout · decision-grilling ก่อนเลือก approach
  knowledge-query ถ้าอาจมีบทเรียน/ADR เดิม · microservice-boundary-review ใครควร own logic/data
  games-labs-implementation-status ตอบคำถาม follow-up จาก mobile/QA/PM"

if [ -n "$matches" ]; then
  ctx="${ctx}

domain skill ที่ keyword ตรงกับ prompt นี้:
${matches}
อ่านก่อนเริ่ม ถ้าเข้าเงื่อนไข ห้ามข้ามเพราะ \"งานเล็ก\" — keyword match เป็นแค่ตัวชี้ ไม่ใช่คำสั่ง"
fi

jq -n --arg c "$ctx" \
  '{hookSpecificOutput: {hookEventName: "UserPromptSubmit", additionalContext: $c}}' \
  2>/dev/null || exit 0

exit 0
