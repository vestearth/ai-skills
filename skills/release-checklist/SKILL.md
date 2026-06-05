---
name: release-checklist
description: Use before deployment, rollout, release approval, or production change windows.
---

# Release Checklist

## Use When

- Preparing deployment, rollout, release approval, production change windows, or rollback notes.
- Confirming whether a change is ready to ship.
- Creating smoke tests or post-release verification steps.

## Do Not Use When

- The task is only code review before merge; prefer `code-review`.
- The root cause of a failure is unknown; prefer `debugging`.
- The change is still being designed and lacks release candidates or artifacts.

## Goal

Confirm release readiness, identify production risks, and document rollback and smoke verification.

## Required Inputs

- Release scope, changed services, and artifact or commit references.
- Build, test, CI, config, migration, and secret verification evidence.
- Rollback path and monitoring or smoke test expectations.

## Process

Check pre-release readiness:

- Build passes
- Tests pass
- Config verified
- Secrets verified
- Migration reviewed

Check rollback:

- Rollback plan exists
- Previous version available
- Recovery steps documented

Check monitoring:

- Dashboards available
- Alerts configured
- Error tracking verified

Check smoke tests:

- Authentication
- Core business flow
- External integrations
- Critical API endpoints

## Output Format

- Release readiness
- Risks
- Rollback notes
- Verification results

## Anti-patterns

- Calling a release ready without fresh build, test, or CI evidence.
- Shipping without a rollback path.
- Treating missing dashboards or alerts as post-release cleanup.
- Smoke testing only the happy path while external integrations changed.
