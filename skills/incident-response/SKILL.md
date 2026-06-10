---
name: incident-response
description: Use during a production incident, outage, or degradation to triage, contain, decide on rollback, write or follow a runbook, and run the post-incident review.
---

# Incident Response

## Use When

- A production incident, outage, latency spike, error surge, or partial degradation is active or suspected.
- Deciding whether to roll back, fail over, scale, or hold during a live problem.
- Writing or following a runbook for a known failure mode.
- Running a post-incident review after the system has recovered.

## Do Not Use When

- The system is healthy and the task is routine release prep; prefer `release-checklist`.
- The work is reproducing and root-causing a non-urgent bug; prefer `debugging`.
- The task is deciding what telemetry to add ahead of time; prefer `datadog-observability`.

## Required Inputs

- The symptom, when it started, and what changed recently (deploy, config, dependency, traffic).
- Current blast radius: which services, endpoints, users, or regions are affected.
- Available signals (dashboards, alerts, logs, traces) and the last known-good version.
- The rollback/failover options that exist and how fast each one is.

## Goal

Restore service quickly and safely with the smallest safe action, keep
stakeholders informed, and capture enough evidence to prevent recurrence —
without conflating mitigation with root-cause.

## Process

Stabilize first (mitigate before diagnose):

- Establish severity and blast radius; decide if this is a "stop the bleeding now" situation.
- Prefer the fastest safe mitigation: roll back to last known-good, fail over, scale, or disable the offending feature/flag.
- Do not wait for full root cause before mitigating a user-facing outage.

Decide rollback vs forward-fix:

- Roll back when a recent change correlates with onset and a known-good version exists.
- Forward-fix only when rollback is impossible (e.g. irreversible migration) or clearly riskier; state why.
- Confirm the rollback target is real and deployable (immutable artifact, reversible migration).

Contain and verify:

- Apply the mitigation, then verify recovery against the original signal, not assumption.
- Watch for secondary effects (queue backlog, retry storms, downstream saturation) after mitigating.

Communicate:

- Post a clear status (what is affected, what is being done, next update time) to the right channel.
- Keep a timestamped timeline of actions and findings as the incident proceeds.

Runbook:

- If a runbook exists, follow it and note where it was wrong or incomplete.
- If none exists for a recurring failure, capture the steps taken as a draft runbook.

Post-incident:

- Reconstruct the timeline, identify the contributing causes (not a single name-and-blame), and list concrete follow-ups with owners.
- Convert the most painful gaps into monitors, runbook entries, or guardrails.

## Output Format

- Severity and blast radius.
- Mitigation taken (or recommended) and why it is the smallest safe action.
- Rollback vs forward-fix decision with justification.
- Timeline of actions and verification of recovery.
- Follow-up actions and runbook/monitor gaps to close.

## Anti-patterns

- Diagnosing root cause while users are down instead of mitigating first.
- Rolling back to a version that was never actually verified as good.
- Forward-fixing under pressure when a safe rollback existed.
- Declaring recovery from assumption rather than from the signal that fired.
- Closing an incident with no timeline, owners, or guardrail changes, so it recurs.
