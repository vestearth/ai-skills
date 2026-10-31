---
name: cloudwatch-log-evidence
description: Use when AWS CloudWatch Logs must become evidence, such as post-deploy checks, whether something happened or stopped happening, before/after deploy comparisons, joining one request across services by request_id, or counting errors and 5xx in a window.
---

# CloudWatch Log Evidence

## Use When

- A claim rests on CloudWatch Logs: a post-deploy check, "did X happen / stop happening",
  or before vs after a deploy; counting errors, 5xx, or one message in a window.
- Following one request across services (e.g. slip-api to slip-system) by `request_id`.

## Do Not Use When

- Production is degraded now; `incident-response` leads, this skill proves recovery.
- Designing logs, metrics, monitors, or dashboards ahead of time; use `datadog-observability`.
- The root cause is unknown and logs are one input among many; lead with `debugging`.
- Release go/no-go; use `release-checklist`, which may cite this skill's output.
- The logs are not in CloudWatch (Datadog, kubectl, local files).

## Goal

Log evidence that is complete (every page), reproducible (fixed windows, a saved
script), and honest (a filter proven against the deployed code, a zero proven not
to be silence), with the script's exit code as the verdict.

## Required Inputs

- The claim as a countable test, e.g. "0 ERROR lines and 0 5xx on path P after the deploy".
- The log group and log format of each service involved.
- Deploy anchor (ECS task definition `registeredAt`, deployment `createdAt`, or the
  workflow run) and the image's source commit, readable to find the exact log messages.

## Process

1. Access: set `AWS_PROFILE=vestearth AWS_REGION=ap-southeast-1` (workspace fact) in every
   shell, script, and subagent, or pass `--profile`/`--region`. `NoCredentials` means the
   profile was not applied, not that access is missing; run `aws configure list-profiles`
   before saying otherwise. Never put credentials or tokens in evidence.
2. API: Logs Insights `StartQuery` is denied for `vestearth` on `/ecs/slip-api-production`
   (AccessDeniedException, 2026-10). Use `filter-log-events --no-paginate` and loop on
   `nextToken` until it is absent ([references/cwf.sh](references/cwf.sh)), so `pages=N`
   is in the evidence. One call returns one page; the CLI's own paging applies `--query`
   per page. Real reads here took 23 to 106 pages; one page silently undercounts.
3. Windows: fixed UTC start and end (ms epoch for the API, both bounds inclusive),
   never "now". Place before and after windows around the deploy anchor, of equal
   length where traffic allows. Report each in UTC and Bangkok time (ICT, UTC+7).
4. Filter: patterns are case-sensitive and exact-phrase. Grep the source at the image
   commit for every message that could carry the claim and pick a phrase they all
   contain (every slip-api daily-digest error contains lowercase `daily digest`).
   Confirm the path logs at that level and reaches the sink, and count a success or
   traffic line in the same window. A zero with no traffic is silence, not a pass.
5. Parse: slip-api logs JSON (`level`, `msg`, `status`, `duration_ms`, `request_id`,
   `path`, `error_message`); the event `message` is a string, so parse it twice.
   slip-system logs Go `log.Printf` text with `key=value` and `request_id="..."`;
   use a regex. Count lines that fail to parse instead of dropping them.
6. Join across services or lines on `request_id`. Report matched and unmatched counts
   and list the unmatched ids; 10,502 of 10,503 matched once, which isolated one silent
   case. A timestamp-only match is weaker; say so. Worked example:
   [references/join-by-request-id.md](references/join-by-request-id.md).
7. Summarize each window with the same filter: n, status histogram, 5xx count,
   p50/p95/max `duration_ms`, ERROR count. Exit non-zero when the claim fails.
8. Shell: a `bash` script file with arrays (zsh does not word-split `$VAR`); macOS has
   bash 3.2 and Ruby 2.6 (no `filter_map`, no `tally`). Work in the session scratchpad,
   not a product repo; it lives under `/private/tmp`, which macOS purges after 3 days,
   so the durable copy is the recorded evidence (step 9), never the scratch file.
9. Record: inside an ai-dev-office TASK, run `record-evidence.sh <TASK-ID> --type command
   -- bash <script>` (the wrapper in `ai-dev-office/scripts/`) and cite the returned
   `ev-NNN` with its task id. Outside a task, paste the command and its real output.

## Output Format

- Verdict: `PASS`, `FAIL`, or `PARTIAL` with the gap named, and the script's exit code.
- Source: log group, exact filter, windows in UTC and ICT, deploy anchor (task
  definition revision and `registeredAt`, or run id), image commit.
- Completeness: `pages=N events=M` for every read.
- Filter proof: the source grep at the image commit, and the success/traffic count.
- Before vs after, same filter: n, status histogram, 5xx, p50/p95/max `duration_ms`, ERROR.
- Join: key, matched, unmatched, the unmatched ids; "timestamp-only" when that is all.
- Evidence: `ev-NNN` with task id, or the command and its raw output.
- Not covered: services, windows, or messages the reads did not reach.

## Anti-patterns

- A count from one page, `head -1`, or `--query 'length(events)'`.
- Reporting "no access" after `NoCredentials` or one denied API.
- "No errors" from a filter never checked against the deployed source, or a silent window.
- Relative windows ("last 2 hours") in a check someone must re-run.
- Before/after read with different filters or unequal windows, unstated.
- Calling a timestamp-only correlation a join, or dropping the unmatched remainder.
- Paraphrasing a log line as proof.
