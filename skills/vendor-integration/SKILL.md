---
name: vendor-integration
description: Use when integrating third-party APIs, callbacks, provider platforms, payment/game vendors, or seamless game provider integrations — balance callbacks, payout flows, launch URLs, signatures, or provider round APIs.
---

# Vendor Integration Review

## Use When

- Integrating or reviewing generic third-party APIs, callbacks, provider platforms, payment vendors, or external systems.
- Integrating or reviewing seamless game provider integrations: balance callbacks, payout flows, launch URLs, signatures, staging aliases, or provider round APIs.
- Authentication, signatures, callbacks, retries, or environment mapping affect correctness.
- A provider callback or launch flow depends on external credentials, aliases, signatures, or retry behavior.
- Provider evidence (sample callbacks, headers, signature examples, error codes) must be compared against local implementation.

## Do Not Use When

- The task is only a Games Labs client API contract; prefer `games-labs-api-review`.
- The task is only dependency or release readiness; prefer `release-checklist` or the specific skill for that workflow.

## Goal

Verify external integration behavior with concrete vendor evidence, and — for seamless game providers — readiness across environment, signatures, launch flow, callbacks, idempotency, and retry handling, identifying missing information before implementation or release.

## Required Inputs

- Sample request and full request body
- Sample response and full response body
- Headers
- Signature inputs
- Provider error codes and error response examples
- Environment name, alias, tenant, or credential mapping when applicable

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

For seamless game providers (e.g. AFB, 1UP, or similar game platform APIs), also check:

Environment:

- Confirm staging vs production base URL.
- Confirm platform alias or tenant ID.
- Confirm the callback URL registered on the provider side.
- Confirm the provider is using the expected environment credentials.

Authentication and signature:

- Confirm required headers.
- Confirm HMAC/hash algorithm.
- Confirm the canonical string or payload used for signing.
- Confirm timestamp/nonce rules if present.
- Compare the locally generated signature with provider examples.

Launch flow:

- Confirm the login or launch API returns a playable URL.
- Confirm token presence and expiry behavior.
- Confirm language/currency/user identity mapping.

Callback flow — review provider callback endpoints such as:

- get balance
- bet/debit
- payout/credit
- adjustment
- round check
- cancel/rollback

Idempotency and retries:

- Confirm transaction ID uniqueness.
- Confirm duplicate callback handling.
- Confirm retry behavior.
- Confirm rollback behavior.

This covers callback mechanics (environment, signatures, launch, callback acceptance, idempotency). If a callback affects wallet balance, round lifecycle, or downstream mission/turnover end-to-end, also read `playbooks/games-labs/provider-settlement.md` — a callback that is accepted is not the same as a round that is correctly settled.

## Output Format

- Integration status
- Backend readiness
- Risks
- Missing information
- Test cases
- Recommended next step

## Anti-patterns

- Implementing from prose docs without sample requests and responses.
- Trusting provider setup without request, response, header, and signature evidence.
- Skipping duplicate callback or retry behavior, or treating duplicate callbacks as rare instead of expected retry behavior.
- Mixing sandbox/staging and production aliases or credentials.
- Treating vendor error messages as stable client-facing behavior.
- Verifying launch URL generation without checking callback balance and payout flows.
