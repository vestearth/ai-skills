# Claude Adapter

Expose `ai-skills` to Claude Code as a skill library.

## Recommended Setup

Copy or symlink each skill folder under `skills/` into Claude's skills directory while preserving the folder name and `SKILL.md`.

Example layout:

```text
~/.claude/skills/
  debugging/
    SKILL.md
  code-review/
    SKILL.md
  grpc-contract-review/
    SKILL.md
```

## Rules

1. Preserve each `SKILL.md` exactly when installing.
2. Use the smallest relevant skill for the task.
3. Treat skills as guidance, not evidence.
4. Source code, tests, CI, logs, production evidence, and user instructions override skill guidance.
5. Prefer v2 core/domain-specific skills before compatibility skills.

## Compatibility Fallbacks

Use compatibility skills only when no more specific v2 skill applies.

- Use `api-contract-review` for generic API contract work.
- Use `vendor-integration` for generic third-party integration work.

Prefer:

- `games-labs-api-review` before `api-contract-review` for Games Labs API work.
- `grpc-contract-review` before `api-contract-review` for protobuf/gRPC/gateway work.
- `seamless-provider-review` before `vendor-integration` for seamless game provider work.
