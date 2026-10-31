---
name: verifyslip-promote
description: Use when promoting VerifySlip (UpSlip) slip-api or slip-system from main to staging or prod, dry-running or verifying that promotion, or answering short prompts such as "ขึ้น prod" or "promote ขึ้น staging" in a slip-* repo.
---

# VerifySlip Promote

## Use When

- Promoting `slip-api` or `slip-system` from `main` to `staging` to `prod`, or
  preparing, dry-running, or verifying that promotion.
- A handoff calls VerifySlip work "merged" or "ready for prod". Merging into `main`
  deploys nothing. Only pushes to `staging` / `prod` run "Deploy STAGING" /
  "Deploy PRODUCTION".

## Do Not Use When

- Games Labs ECS: use `playbooks/games-labs/ecs-deploy.md` (prod is cost-gated).
  Generic readiness: `skills/release-checklist/SKILL.md`. Prod degraded:
  `incident-response`.
- `slip-front-end` (`main`, `staging`, `prod` on one fast-forwarded commit), and
  `slip-admin` / `slip-landing` (PR promotions, no prod-only files or migrations).
  For these, steps 2–4 do not apply; steps 5–7 do.

## Goal

Ship exactly what Earth approved, on merge trees proven by a dry run, keeping
prod-only files, with a recorded rollback revision and evidence that prod serves
the new image without new 5xx or ERROR lines.

## Required Inputs

- Earth's explicit approval in chat for this scope, naming staging and prod. Each
  step goes through a PR (`AGENTS.md`, "VerifySlip `slip-*` branch flow"); a direct
  push to `staging` or `prod` is never the lane, even though `git log` shows some.
  Prod is live (about 1100 verifies/min) and not cost-gated.
- Fetched `origin/{main,staging,prod}` and the running task definitions and images.
- The open `TASK-VS-*` run. PRs into `main` run no CI, so local
  `GOWORK=off go test ./...` and `go build -mod=readonly ./...` evidence is the
  gate. Keep the `slip-contracts` `replace` in `go.mod`.
- AWS profile `vestearth` (`ap-southeast-1`); gh account `Sichol-Earth`.

## Process

Commands: [references/promote.md](references/promote.md). At every **STOP**, report
to Earth and wait; never work around it.

1. **Approval and scope.** STOP without approval for staging and for prod (one does
   not cover the other). Prod gets both `git log --no-merges origin/staging..origin/main`
   and `origin/prod..origin/staging`. STOP on any commit outside the approved work,
   showing Earth commits and authors (watcharapol-spl sometimes merges main to
   staging to prod without a PR). STOP if prod does not run
   `production-sha-<origin/prod short>` or a deploy run is active (a push cancels it).
2. **Dry run.** T1 = `git merge-tree --write-tree origin/staging origin/main`;
   `commit-tree` T1 and merge-tree that commit with `origin/prod` to get T2.
   `diff --stat origin/staging T1` and `origin/prod T2` list only expected files.
   A plain `diff origin/prod origin/main` shows the prod-only files
   (`ecs/task-definition.production.json`, workflow diffs) as deleted; the merge
   keeps them. STOP on any conflict or unexpected file.
3. **Rollback and config.** Record the task definitions of `slip-api-*` and
   `slip-system-*` in `upslip-staging-ecs` and `upslip-production-ecs`; rollback
   points the service back at that revision. List `migrations/` changes in T2.
4. **Migrations.** STOP on any; plan it with Earth. slip-api runs goose before its
   listener and ECS replaces a task not up after ~150 s; a 2m58s index build caused
   12 verify 504s (2026-10-28). Pre-build indexes by hand, 01:00–05:00 Bangkok only.
5. **Staging.** Open a PR `main` → `staging` (as #103, #105), check `gh pr view`
   shows that base and head, and merge it with a merge commit pinned to the head
   (`--match-head-commit`); the merged tree must equal T1. Wait for
   `staging-sha-<short>` with [references/wait-rollout.sh](references/wait-rollout.sh),
   then check the run conclusion and boot logs (clean start, no ERROR or panic).
   Staging proves boot, not behavior. STOP on FAILED, TIMEOUT, or a failed run.
6. **Prod.** In a temporary worktree (never the main checkout), branch
   `release/TASK-VS-NNN-production` from `origin/prod`, merge `origin/staging` (tree
   must equal T2), push the branch, and open a PR into `prod` (as #106, #107); merge
   it pinned to the head. Wait for `production-sha-<short>` with running = desired
   (Auto Scaling sets it). Hash-compare env and secrets of the old and new task
   definitions: only the image may change. STOP on FAILED, TIMEOUT, or a diff.
7. **Post-deploy.** With `cloudwatch-log-evidence`, deploy to about +12 min: request
   count, status histogram, 5xx = 0, ERROR lines = 0; a spike goes to
   `incident-response` with the rollback revision. The fix's effect shows later, so
   set `check_after` with `update-check-after.rb`.
8. **Record.** Run checks through the office wrapper,
   `record-evidence.sh <TASK> -- bash <script>`. Add a history row with both
   `old..new` ranges, task definitions, rollback revision, and `ev-NNN` ids;
   validate and commit the run.

## Output Format

- Approval (Earth's words, time) and per-repo scope with commit authors.
- Dry-run T1/T2 ids, diff summaries, conflicts; old and new task definitions.
- `old..new` ranges, run conclusions, wait-rollout lines, tags, running/desired, env
  and secret hash result, post-deploy counts, `check_after`, `ev-NNN` ids, open STOPs.

## Anti-patterns

- Assuming `main` equals prod, "merged" means deployed, or staging commits are approved.
- Reading a plain prod diff as deletions, or "restoring" prod-only files on `main`.
- Taking a green workflow as a healthy rollout of the right image; its
  `services-stable` wait gives up after about 10 minutes.
- Pushing straight to `staging`/`prod` instead of a PR (2026-10-30/31 promotions did;
  that broke the branch-flow rule), merging in the main checkout, force-pushing, or
  fixing conflicts on `staging`/`prod`.
- Printing task-definition env values: some secrets are plaintext env vars.
