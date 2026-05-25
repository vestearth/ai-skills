---
name: vendor-integration
description: Use when integrating third-party APIs, callbacks, provider platforms, or payment/game vendors.
---

# Vendor Integration Review

## Verify

- Authentication method
- Signature generation
- Callback URL
- Retry behavior
- Idempotency
- Environment mapping
- Platform alias or tenant configuration

## Required evidence

- Sample request
- Sample response
- Headers
- Signature inputs
- Error response examples

## Common failure modes

- Wrong secret
- Wrong environment
- Wrong alias
- Callback mismatch
- Timestamp mismatch
- Retry duplication

## Output

- Integration status
- Risks
- Missing information
- Recommended next step
