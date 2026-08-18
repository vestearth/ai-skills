---
name: weekly-report
description: Use when producing the recurring weekly work summary for the team — building it from git history and task-run state across every repo, appending it to the knowledge-base Weekly Review log, and emitting the paste-ready update. Trigger on "สรุปงานสัปดาห์นี้", "weekly update", "report ส่งทีม", "อัพเดท Weekly Review", or a named date range covering roughly one week.
---

# Weekly Report

Turn one week of real repository and task-run activity into two artifacts: a
sourced vault entry and a paste-ready team update.

## Use When

- The recurring weekly work summary is due, or the user asks for "สรุปงานสัปดาห์นี้" / "weekly update".
- The user asks to update `knowledge-base/Knowledge Base/Weekly Review.md`.
- The user asks for a report to send to the team, PM, or stakeholders covering a week of work.
- A partial-week or mid-week checkpoint snapshot is requested.

## Do Not Use When

- The question is about a single task, PR, or run; answer it directly.
- The user wants durable knowledge captured rather than a period summary; use `knowledge-capture`.
- The user wants work handed to another agent or session; use `session-handoff`.
- The claim to check is "is this done"; use `completion-audit`.

## Goal

A report that a teammate can act on: every claim traceable to a commit, run
artifact, or explicit gap, with last week's open items resolved rather than
silently dropped.

## Required Inputs

- The date window. Default is last Saturday through today unless the user names another range; confirm the weekday before assuming.
- Git history across every repository under the workspace root. The root itself is not a repo — iterate the subdirectories.
- `ai-dev-office/runs/*/status.yaml` for phase/state of every run touched in the window.
- The previous entry in `knowledge-base/Knowledge Base/Weekly Review.md` — its In Progress and On Hold lists are mandatory inputs, not optional context.
- Any teammate-supplied update list, when one exists.

## Process

1. Fix the window. Confirm today's weekday, resolve the start date, and state the range in both artifacts.
2. Collect commits across all repos in the window, including merge commits and all branches — work often lands on a branch before its PR merges.
3. Collect run state for every `TASK-` id in the window. Run titles do not live in `status.yaml` or `meta.yaml`; derive the subject from the commit messages that carry the id.
4. Re-check last week's carry-over. For every In Progress and On Hold item in the previous entry, resolve it to closed, still open, or unchanged this week. An item that vanishes without a verdict is a reporting defect.
5. Group by theme, not by repository. A vertical slice across `shared-lib → service → gateway → backoffice` is one item, not four.
6. Separate own work from teammates' work, and label teammate items by repository or product surface.
7. Cross-check teammate items against their update list when one exists. When none exists, say the section was derived from commits alone.
8. Distinguish merged from verified from deployed. "Merged" is not "closed"; runs sitting in review are In Progress, not Done.
9. Write the vault entry into `Weekly Review.md` under a `### YYYY-MM-DD` heading, matching the surrounding entries' sections, and end it with a `Sources:` list.
10. Emit the paste-ready update as a separate chat message in the send format below — never tell the user to extract it from the vault file.
11. Run a publication check before handing over the sendable version: flag unrevoked credentials, live vulnerabilities, and anything else that changes who may read it.

## Output Format

Two artifacts, both produced every time.

**Vault entry** — appended to `Weekly Review.md`:

- `### YYYY-MM-DD` heading
- Header line: audience, date range, run count (done vs touched), repo count
- `In Progress ⭕️` / `Done ✅ (my work)` / `Done ✅ (team)` / `On Hold ⏸️`
- `Pattern:` — one paragraph on what the week actually was, not a restatement of the list
- `Sources:` — git ranges, run artifact paths, teammate lists

**Paste-ready update** — emitted in chat:

- `Weekly Update — <team>` and `Date: DD/MM/YYYY`
- Same four sections, flat bullets, bold category prefixes
- Task-run ids, run phases, file paths, and the `Sources` block stripped out
- Headline items first; the rest ordered by consequence, not chronology

## Anti-patterns

- Reporting from memory, an index line, or a prior summary instead of the actual git and run history for the window.
- Dropping a carry-over item because nothing happened to it this week — "no movement" is the report.
- Listing every commit; a report is a set of outcomes, not a changelog.
- Presenting merged code as verified, or a green build as a deployed behavior.
- Shipping the vault entry and the sendable update as one document with the run ids and sources left in.
- Attributing teammate work from commit subjects alone without saying that is where it came from.
