# VerifySlip Promotion: Command Sequence

The commands behind each step of `../SKILL.md`. Re-check every name below
against the repository workflows and `aws ecs describe-services` before relying
on it. Last checked on 2026-10-31.

## Placeholders and names

- `R`: the local checkout of `REPO` (`slip-api` or `slip-system`).
- `TASK`: the open `TASK-VS-NNN` run. `TMP`: a scratch directory outside every repo.
- `OLD_REV` / `NEW_REV`: task-definition revisions recorded in steps 3 and 6.
- Every AWS call: `export AWS_PROFILE=vestearth AWS_REGION=ap-southeast-1`.

| Env | Cluster | Services | Workflow (trigger) | Image tag |
| --- | --- | --- | --- | --- |
| staging | `upslip-staging-ecs` | `slip-api-staging`, `slip-system-staging` | "Deploy STAGING", `deploy.yml` (push to `staging`) | `staging-sha-<7>` |
| prod | `upslip-production-ecs` | `slip-api-production`, `slip-system-production` | "Deploy PRODUCTION", `deploy-production.yml` (push to `prod`) | `production-sha-<7>` |

`<7>` is the first 7 characters of the pushed commit (`cut -c1-7`; not
`rev-parse --short`, which can return more). Log groups are `/ecs/<service>`.
Both workflows run `aws ecs wait services-stable`, which gives up after about
10 minutes, and their concurrency group cancels an in-progress run on a new push.
Staging services roll back automatically through the deployment circuit breaker;
prod services have no circuit breaker (checked 2026-10-31).

## 1. Approval and scope

```bash
git -C "$R" fetch origin --prune
git -C "$R" log --no-merges --format='%h %an %ad %s' --date=short origin/staging..origin/main
git -C "$R" log --no-merges --format='%h %an %ad %s' --date=short origin/prod..origin/staging
# prod must run origin/prod; anything else means an unrecorded deploy or one in flight
echo "want production-sha-$(git -C "$R" rev-parse origin/prod | cut -c1-7)"
td=$(aws ecs describe-services --cluster upslip-production-ecs --services "$REPO-production" \
  --query 'services[0].taskDefinition' --output text)
aws ecs describe-task-definition --task-definition "$td" \
  --query 'taskDefinition.containerDefinitions[0].image' --output text
gh run list -R "SparqLab/$REPO" --workflow "Deploy STAGING" --limit 3
gh run list -R "SparqLab/$REPO" --workflow "Deploy PRODUCTION" --limit 3   # none queued or in progress
```

Prod receives both lists. Every commit in them must belong to the approved work.

## 2. Dry run

`merge-tree --write-tree` prints the tree id on line 1 and exits 1 on a conflict.
`commit-tree` writes an unreferenced commit. Neither command moves a ref. Run the
blocks in this file line by line. When a line prints `STOP`, do not run the rest.

```bash
T1=$(git -C "$R" merge-tree --write-tree origin/staging origin/main) || { echo "STOP: conflict"; echo "$T1"; }
C1=$(git -C "$R" commit-tree "$T1" -p origin/staging -p origin/main -m "dry run: main into staging")
T2=$(git -C "$R" merge-tree --write-tree origin/prod "$C1") || { echo "STOP: conflict"; echo "$T2"; }
git -C "$R" diff --stat origin/staging "$T1"   # only files of the staging..main commits
git -C "$R" diff --stat origin/prod "$T2"      # only files of both scope lists; no ecs/ or .github/ lines
git -C "$R" diff --stat origin/staging "$T2"   # prod-only files show here, so the merge keeps them
```

## 3. Rollback and config

```bash
for e in staging production; do
  aws ecs describe-services --cluster "upslip-$e-ecs" --services "slip-api-$e" "slip-system-$e" \
    --query 'services[].[serviceName,taskDefinition,runningCount,desiredCount]' --output text
done
git -C "$R" diff --name-status origin/prod "$T2" -- migrations/   # any output: step 4 STOP
```

Rollback changes prod, so it needs Earth's go-ahead or an `incident-response`
decision:
`aws ecs update-service --cluster upslip-production-ecs --service "$REPO-production" --task-definition "$REPO-production:$OLD_REV"`.
After a rollback the `prod` branch is ahead of what runs. Record that.

## 4. Migrations

`slip-api` `cmd/main.go` runs `migrations.Run` before it opens the gRPC and HTTP
listeners. The health check (`startPeriod` 60 s, 3 retries every 30 s) replaces a
task that is still migrating after about 150 s. A non-concurrent index build
locks writes the whole time. To ship an index migration: Earth schedules it, the
index is built by hand with `CREATE INDEX CONCURRENTLY` between 01:00 and 05:00
Bangkok, and the migration uses `IF NOT EXISTS` with the same name, so the boot
migration does nothing. `slip-system` has no migrations.

## 5. Staging

Each step is a PR (`AGENTS.md`, "VerifySlip `slip-*` branch flow"); never push to
`staging` or `prod` directly. Staging takes `main` itself as the head (#103, #105).

```bash
git -C "$R" fetch origin
PR=$(gh pr create -R "SparqLab/$REPO" --base staging --head main \
  --title "deploy(staging): <scope> (TASK-VS-NNN)" --body "<scope, T1, approval>" | grep -oE '[0-9]+$')
gh pr view "$PR" -R "SparqLab/$REPO" --json baseRefName,headRefName,headRefOid,mergeable
HEAD_SHA=$(gh pr view "$PR" -R "SparqLab/$REPO" --json headRefOid -q .headRefOid)
test "$HEAD_SHA" = "$(git -C "$R" rev-parse origin/main)" || echo "STOP: main moved after the dry run"
gh pr merge "$PR" -R "SparqLab/$REPO" --merge --match-head-commit "$HEAD_SHA"
git -C "$R" fetch origin
test "$(git -C "$R" rev-parse 'origin/staging^{tree}')" = "$T1" || echo "STOP: merged tree differs from the dry run"
S7=$(git -C "$R" rev-parse --short=7 origin/staging)
bash references/wait-rollout.sh upslip-staging-ecs "$REPO-staging=staging-sha-$S7" 1500
gh run list -R "SparqLab/$REPO" --workflow "Deploy STAGING" --limit 1 --json headSha,status,conclusion
```

If a tree differs, `origin/*` moved after the dry run: go back to step 1. Boot
check: use `cloudwatch-log-evidence` on `/ecs/$REPO-staging` from the merge until
2 minutes after COMPLETED. The new task reaches its listener, and there are no
ERROR, panic, or fatal lines.

## 6. Prod

Prod takes a `release/TASK-VS-NNN-production` branch cut from `origin/prod` with
staging merged in (#106, #107), so prod-only commits and files stay.

```bash
git -C "$R" fetch origin
B="release/TASK-VS-NNN-production"
W="$TMP/promote-$REPO-prod"
git -C "$R" worktree add -b "$B" "$W" origin/prod
git -C "$W" merge --no-ff -m "Merge branch 'staging' into $B" origin/staging
test "$(git -C "$W" rev-parse 'HEAD^{tree}')" = "$T2" || echo "STOP: tree differs from the dry run"
git -C "$W" push -u origin "$B"
PR=$(gh pr create -R "SparqLab/$REPO" --base prod --head "$B" \
  --title "deploy(prod): <scope> (TASK-VS-NNN)" --body "<scope, T2, approval, rollback revision>" | grep -oE '[0-9]+$')
HEAD_SHA=$(git -C "$W" rev-parse HEAD)
gh pr merge "$PR" -R "SparqLab/$REPO" --merge --match-head-commit "$HEAD_SHA"
git -C "$R" worktree remove "$W"
git -C "$R" fetch origin
test "$(git -C "$R" rev-parse 'origin/prod^{tree}')" = "$T2" || echo "STOP: merged tree differs from the dry run"
P7=$(git -C "$R" rev-parse --short=7 origin/prod)
bash references/wait-rollout.sh upslip-production-ecs "$REPO-production=production-sha-$P7" 1800
```

The workflow builds the new task definition from the latest registered revision
and re-renders its env from the GitHub `production` environment. Prod-only
values such as `POSTGRES_MAX_CONNS=80` exist only in prod's workflow. Several
secrets are plaintext env vars, so compare hashes and never print values:

```bash
envhash() {  # TASK_DEF -> "env|secret NAME <sha256 prefix>" lines
  aws ecs describe-task-definition --task-definition "$1" \
    --query 'taskDefinition.containerDefinitions[0].{e:environment,s:secrets}' --output json |
  ruby -rjson -rdigest -e 'j = JSON.parse(STDIN.read)
    h = ->(v) { Digest::SHA256.hexdigest(v.to_s)[0, 12] }
    (j["e"] || []).sort_by { |x| x["name"] }.each { |x| puts "env #{x["name"]} #{h[x["value"]]}" }
    (j["s"] || []).sort_by { |x| x["name"] }.each { |x| puts "secret #{x["name"]} #{h[x["valueFrom"]]}" }'
}
diff <(envhash "$REPO-production:$OLD_REV") <(envhash "$REPO-production:$NEW_REV") && echo "env and secrets unchanged"
```

## 7. Post-deploy

Use `cloudwatch-log-evidence` on `/ecs/slip-api-production` from the rollout
start to about +12 minutes. Read every page, because one `filter-log-events`
call returns one page.

- `"http request completed"`: request count, status histogram, 5xx count.
- `"level\":\"ERROR\""`: ERROR line count, which must be 0. Use the same filter on
  `/ecs/slip-system-production` when slip-system shipped.

The window proves the new image serves. It does not prove the fix works.
Schedule the measurement of the fix (from the ai-dev-office root):

```bash
ruby scripts/update-check-after.rb "$TASK" set --at <YYYY-MM-DDTHH:MM:SSZ> \
  --what "<query that measures the fix>" --actor pm --reason "promoted to prod <time>Z"
```

## 8. Record

Put the step 6–7 checks in one script. It prints the task definition, image,
and running/desired of each service, plus `main`-in-`prod` ancestry and the
window counts, and exits non-zero on any 5xx. Then, from the ai-dev-office root:

```bash
scripts/record-evidence.sh "$TASK" -- bash "$TMP/prod-promotion-check.sh"   # prints ev-NNN, keeps the exit code
```

Write the history row by hand. Follow `ai-dev-office/docs/CLAUDE.md` for the
role enum and `operator: claude`. Shape of the row:

> Earth approved staging and prod. Promoted REPO main SHA: staging OLD..NEW
> (Deploy STAGING success, REPO-staging:REV, clean boot), then prod OLD..NEW
> (Deploy PRODUCTION success, REPO-production:REV, image production-sha-SHA,
> RUNNING/DESIRED). Env and secrets unchanged from :OLD_REV. WINDOW: N requests,
> 0 5xx, 0 ERROR lines (ev-NNN). Rollback: service back to REPO-production:OLD_REV.

Then run `ruby validate-yaml.rb "$TASK"` and commit the run in ai-dev-office.
