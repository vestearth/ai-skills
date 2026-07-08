---
name: seamless-provider-review
description: Use when reviewing seamless game provider integrations, balance callbacks, payout flows, launch URLs, signatures, staging aliases, provider sample callbacks, error codes, or provider round APIs.
---

# Seamless Provider Review

Use this skill for provider integrations such as AFB, 1UP, or similar game platform APIs.

This skill covers callback *mechanics* (environment, signatures, launch, callback acceptance, idempotency). If the callback affects wallet balance, round lifecycle, or downstream mission/turnover end-to-end, also read `playbooks/games-labs/provider-settlement.md` — a callback that is accepted is not the same as a round that is correctly settled.

## Use When

- Reviewing seamless game provider integrations, balance callbacks, payout flows, launch URLs, signatures, staging aliases, or provider round APIs.
- A provider callback or launch flow depends on external credentials, aliases, signatures, or retry behavior.
- Provider evidence must be compared against local implementation.
- A provider sends sample callbacks, headers, signature examples, or error codes that need to be matched against backend behavior.

## Do Not Use When

- The integration is not a seamless game provider; use `vendor-integration`.
- The task is only Games Labs client API behavior; use `games-labs-api-review`.
- The task is only release readiness; use `release-checklist`.

## Goal

Verify provider integration readiness across environment, signatures, launch flow, callbacks, idempotency, and retry handling.

## Required Inputs

- Full request body
- Full response body
- Headers
- Signature input
- Provider error code
- Environment name

## Process

Check environment:

- Confirm staging vs production base URL.
- Confirm platform alias or tenant ID.
- Confirm callback URL registered on provider side.
- Confirm provider is using the expected environment credentials.

Check authentication and signature:

- Confirm required headers.
- Confirm HMAC/hash algorithm.
- Confirm canonical string or payload used for signing.
- Confirm timestamp/nonce rules if present.
- Compare the locally generated signature with provider examples.

Check launch flow:

- Confirm login or launch API returns a playable URL.
- Confirm token presence and expiry behavior.
- Confirm language/currency/user identity mapping.

Check callback flow:

Review callback endpoints such as:

- get balance
- bet/debit
- payout/credit
- adjustment
- round check
- cancel/rollback

Check idempotency and retries:

- Confirm transaction ID uniqueness.
- Confirm duplicate callback handling.
- Confirm retry behavior.
- Confirm rollback behavior.

## Output Format

- Integration status
- Missing provider information
- Backend readiness
- Risk list
- Test cases
- Next action

## Anti-patterns

- Trusting provider setup without request, response, header, and signature evidence.
- Mixing staging and production aliases or credentials.
- Treating duplicate callbacks as rare instead of expected retry behavior.
- Verifying launch URL generation without checking callback balance and payout flows.
