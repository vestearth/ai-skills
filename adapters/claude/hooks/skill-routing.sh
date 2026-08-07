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
#   1. a 3-line core reminder (always)
#   2. skills whose keywords match THIS prompt (at most MAX_MATCHES)
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
# Deliberately unrouted: model-router (already in the always-on core line);
# knowledge-promote, knowledge-source-review, mcp-audit, permission-tuner,
# self-learning (operator-invoked maintenance skills — keyword rows would be
# noise). Every other skill should have a row; add one when you add a skill.
ROUTES=$(cat <<'TABLE'
search-first~หาไฟล์/route/สัญลักษณ์ ก่อนไล่อ่านเอง~อยู่ไฟล์ไหน|อยู่ตรงไหน|หาโค้ด|หาที่|where is|find the|which file|route ไหน
debugging~bug/พัง/error/test fail — หา root cause ก่อนเสนอ fix~ bug |บั๊ก|พัง|error|crash| fail |failing|แปลก|ไม่ทำงาน|panic| 500 |stack trace
verification-loop~ต้องมีหลักฐานก่อนเคลมว่าเสร็จ/fix แล้ว~verify|พิสูจน์|evidence|ยืนยัน|ทดสอบจริง|จริงไหม|แน่ใจ
completion-audit~งานที่ agent/Codex/handoff อ้างว่าเสร็จ — audit ก่อนรับ~เสร็จจริง|ตรวจงาน|เช็คงาน|audit|handoff|claimed complete|codex ส่ง
code-review~PR/diff/merge readiness~review|รีวิว| pr |pull request|diff|merge|ผ่านไหม|approve
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
release-checklist~deploy/rollout/production readiness + rollback~deploy|release|rollout|ขึ้น prod|production|go live
incident-response~prod incident/outage — triage + containment ก่อน~incident|outage|prod down|ล่ม|ฉุกเฉิน|rollback|urgent
secrets-management~secret/credential/token/.env/kubeconfig~secret|credential|token| env |kubeconfig|api key|รหัสผ่าน
dependency-guard~go.mod, Dockerfile, CI, shared dependency~go mod|go get|dependency|dependencies|bump|upgrade|package json
frontend-ui-review~หน้า/component เทียบ Figma + design system~figma|tailwind|component| ui |หน้าจอ|responsive|frontend|css
vendor-integration~provider callback, payout, launch URL, signature~vendor|callback|seamless|payout|balance| hmac |signature|third party
microservice-boundary-review~ownership / service ไหนควรถือ logic นี้~boundary|ownership|service ไหน|ควรอยู่ service|แยก service
tech-lead-review~architecture, cross-team impact, long-term maintainability~architecture|สถาปัตย|scalab|maintainab|long term|ระยะยาว
decision-grilling~stress-test แผน/design ก่อนลงมือ~ควรใช้|ตัดสินใจ|trade off|เลือกแบบไหน|approach ไหน|ดีกว่ากัน
minimal-change-review~กันงานบานเกินที่ขอ (scaffold/abstraction ที่ไม่ได้สั่ง)~scaffold|refactor|abstraction|เพิ่มไฟล์|สร้างใหม่
deslop~กวาด AI slop ออกจาก diff ก่อน commit/handoff~slop|cleanup|ก่อน commit|tidy|เก็บกวาด
sprint-planning~แปลง goal/backlog เป็น scope + acceptance criteria~sprint|backlog|roadmap|วางแผน|แผนงาน
knowledge-query~งานนี้อาจพึ่งความรู้/ADR/บทเรียนเดิม~เคยทำ|ที่ผ่านมา|prior decision| adr |knowledge base
knowledge-capture~งานที่เพิ่งจบมีบทเรียน/decision ที่ควรบันทึก~knowledge|บันทึกความรู้|lesson|บทเรียน
session-handoff~สรุป state ส่งต่อ session/agent อื่น~handoff|ส่งต่อ|compact|สรุปงาน|สรุป session
skill-authoring-review~แก้/เพิ่ม/ตัด skill ใน ai-skills~ai skills| skill |สกิล
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

ctx="[ai-skills routing]
งานที่แตะโค้ด: search-first ก่อนไล่ไฟล์ | verification-loop ก่อนเคลม \"เสร็จ/fix แล้ว\" | model-router ถ้างานเบากว่าโมเดลที่รันอยู่"

if [ -n "$matches" ]; then
  ctx="${ctx}

ตรงกับ prompt นี้:
${matches}
อ่านก่อนเริ่ม ถ้าเข้าเงื่อนไข ห้ามข้ามเพราะ \"งานเล็ก\" — keyword match เป็นแค่ตัวชี้ ไม่ใช่คำสั่ง"
fi

jq -n --arg c "$ctx" \
  '{hookSpecificOutput: {hookEventName: "UserPromptSubmit", additionalContext: $c}}' \
  2>/dev/null || exit 0

exit 0
