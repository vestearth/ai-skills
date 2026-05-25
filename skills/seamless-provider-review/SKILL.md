---
name: seamless-provider-review
description: Use when reviewing seamless game provider integrations, balance callbacks, payout flows, launch URLs, signatures, staging aliases, or provider round APIs.
---

# Seamless Provider Review

Use this skill for provider integrations such as AFB, 1UP, or similar game platform APIs.

## Core checks

### Environment

- Confirm staging vs production base URL.
- Confirm platform alias or tenant ID.
- Confirm callback URL registered on provider side.
- Confirm provider is using the expected environment credentials.

### Authentication and signature

- Confirm required headers.
- Confirm HMAC/hash algorithm.
- Confirm canonical string or payload used for signing.
- Confirm timestamp/nonce rules if present.
- Compare the locally generated signature with provider examples.

### Launch flow

- Confirm login or launch API returns a playable URL.
- Confirm token presence and expiry behavior.
- Confirm language/currency/user identity mapping.

### Callback flow

Review callback endpoints such as:

- get balance
- bet/debit
- payout/credit
- adjustment
- round check
- cancel/rollback

### Idempotency and retries

- Confirm transaction ID uniqueness.
- Confirm duplicate callback handling.
- Confirm retry behavior.
- Confirm rollback behavior.

## Required evidence

- Full request body
- Full response body
- Headers
- Signature input
- Provider error code
- Environment name

## Output

- Integration status
- Missing provider information
- Backend readiness
- Risk list
- Test cases
- Next action
