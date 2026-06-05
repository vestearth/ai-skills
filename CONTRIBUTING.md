# Contributing

This repository is a reusable skill library. Keep skills small, consistent, and easy for AI agents to apply without loading unnecessary context.

## Skill Contract

Every skill must include:

- YAML frontmatter with `name` and `description`
- `Use When`
- `Do Not Use When`
- `Goal`
- `Required Inputs`
- `Process`
- `Output Format`
- `Anti-patterns`

## Frontmatter

Use concise metadata because agents see it before loading the full skill.

```yaml
---
name: skill-name
description: Use when the task involves specific trigger conditions, domains, tools, or review types.
---
```

## Required Sections

### Use When

List the situations that should trigger the skill.

### Do Not Use When

List cases where another skill is better or where repository/project instructions should decide.

### Goal

State the outcome the skill is optimizing for.

### Required Inputs

List the minimum evidence the agent should inspect before giving advice or changing files.

Examples:
- User request or task description
- Relevant source files
- Tests, CI, logs, or runtime output
- API docs, provider docs, or production evidence when applicable

### Process

Give the smallest useful workflow. Prefer ordered checks over long explanation.

### Output Format

Define what the agent should return or produce.

### Anti-patterns

Name the mistakes the skill is meant to prevent.

## Source of Truth

Skills are guidance, not evidence.

Repository source code, tests, CI, logs, production evidence, and explicit user instructions override skill guidance.

## Validation

Run the local validator before release, adapter sync, or skill taxonomy changes:

```bash
scripts/validate-skills.sh
```

The validator checks frontmatter, required sections, skill folder names, and README/VERSION skill coverage.

## Style

- Keep `SKILL.md` concise.
- Do not duplicate full project policies inside a skill.
- Put detailed references in `references/` only when needed.
- Do not mark a skill as complete in [VERSION.md](VERSION.md) until `skills/<skill-name>/SKILL.md` exists.
- Prefer specific skills over broad compatibility skills.
- Keep adapters thin and verify them with `scripts/validate-skills.sh` after routing changes.

## Compatibility

When a new domain-specific skill overlaps with an older broad skill, route the specific skill first and keep the broad skill as fallback compatibility.

Examples:
- Use `games-labs-api-review` before `api-contract-review` for Games Labs API work.
- Use `seamless-provider-review` before `vendor-integration` for seamless game provider callbacks, signatures, launch URLs, or round APIs.
