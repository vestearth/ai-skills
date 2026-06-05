---
name: vendor-integration
description: Use when integrating third-party APIs, callbacks, provider platforms, or payment/game vendors.
---

# Vendor Integration Review

## Use When

- Integrating or reviewing generic third-party APIs, callbacks, provider platforms, payment vendors, or external systems.
- The integration is not covered by a more specific skill such as `seamless-provider-review`.
- Authentication, signatures, callbacks, retries, or environment mapping affect correctness.

## Do Not Use When

- The integration is a seamless game provider; prefer `seamless-provider-review`.
- The task is only a Games Labs client API contract; prefer `games-labs-api-review`.
- The task is only dependency or release readiness; use the specific skill for that workflow.

## Goal

Verify external integration behavior with concrete vendor evidence and identify missing information before implementation or release.

## Required Inputs

- Sample request
- Sample response
- Headers
- Signature inputs
- Error response examples
- Environment, alias, tenant, or credential mapping when applicable

## Process

Verify:

- Authentication method
- Signature generation
- Callback URL
- Retry behavior
- Idempotency
- Environment mapping
- Platform alias or tenant configuration

Check common failure modes:

- Wrong secret
- Wrong environment
- Wrong alias
- Callback mismatch
- Timestamp mismatch
- Retry duplication

## Output Format

- Integration status
- Risks
- Missing information
- Recommended next step

## Anti-patterns

- Implementing from prose docs without sample requests and responses.
- Skipping duplicate callback or retry behavior.
- Mixing sandbox and production credentials.
- Treating vendor error messages as stable client-facing behavior.
