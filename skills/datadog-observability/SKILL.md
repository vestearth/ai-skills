---
name: datadog-observability
description: Use when reviewing Datadog metrics, logs, traces, dashboards, monitors, SLOs, service tags, incident visibility, or production observability coverage.
---

# Datadog Observability

## Use When

- A change needs production visibility through Datadog or similar telemetry.
- Metrics, logs, traces, dashboards, monitors, alerts, service tags, or SLOs are added or changed.
- A release, incident, or integration needs evidence that failures can be detected and investigated.

## Do Not Use When

- The task is pure application correctness with no observability impact; use the relevant review skill first.
- The monitoring platform is not Datadog and project instructions provide a different tool-specific playbook.
- The question is only about deployment readiness; use `release-checklist` plus this skill if visibility is a risk.

## Goal

Ensure production behavior can be detected, diagnosed, and acted on without creating noisy or misleading alerts.

## Required Inputs

- Changed instrumentation, logging, tracing, dashboard, or monitor configuration.
- Service names, environment tags, resource names, and ownership/team labels.
- Expected symptoms, failure modes, traffic volume, and business impact.
- Existing dashboard/monitor references or screenshots/exported config when available.

## Process

1. Define the user-visible or business symptom the telemetry must reveal.
2. Check metrics: names, tags, cardinality, units, success/error counters, latency distributions, and business event counts.
3. Check logs: structured fields, correlation ids, error context, sampling, and secret/PII safety.
4. Check traces: service/resource names, span boundaries, downstream calls, error tagging, and trace-log correlation.
5. Check dashboards: they answer "is it broken?", "where?", "how bad?", and "since when?" for the owning team.
6. Check monitors: thresholds match impact, alert routing is owned, runbook context exists, and noise is minimized.
7. Verify by linking config, sample log/metric/trace evidence, or a documented gap if the platform cannot be inspected.

## Output Format

- Observability verdict
- Symptoms covered
- Metrics/logs/traces reviewed
- Dashboard and monitor coverage
- Alert noise or blind spots
- Incident investigation path
- Required follow-up

## Anti-patterns

- Adding logs without fields needed to join events.
- Alerting on noisy internal signals instead of user/business impact.
- Creating high-cardinality tags from user ids, request ids, or unbounded strings.
- Shipping a critical path with no failure metric or owner.
- Claiming observability is ready without sample telemetry or config evidence.
