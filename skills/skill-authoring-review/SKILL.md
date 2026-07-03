---
name: skill-authoring-review
description: Use when creating, editing, reviewing, or pruning ai-skills guidance, skill frontmatter, skill routing, or reusable agent behavior contracts.
---

# Skill Authoring Review

## Use When

- Creating a new skill or revising an existing `SKILL.md`.
- Reviewing skill frontmatter, routing text, or adapter discovery wording.
- Deciding whether guidance belongs in a skill, a rule, a playbook, a knowledge note, or nowhere.
- Pruning skill text that may be duplicated, stale, too broad, or too obvious to change agent behavior.

## Do Not Use When

- The task is normal implementation, debugging, release, or code review; use the domain skill first.
- The guidance is project-specific and belongs in the target repository's `AGENTS.md`, docs, or tests.
- The request is only to capture durable project knowledge; use `knowledge-capture` or `knowledge-promote`.

## Goal

Keep skills predictable, discoverable, concise, and useful without turning the repository into a bureaucracy of overlapping process documents.

## Required Inputs

- The proposed skill, rule, playbook, or routing change.
- Existing `skills/`, `rules/`, `playbooks/`, `README.md`, `VERSION.md`, `AGENTS.md`, and adapter surfaces that may overlap.
- The user request or recurring signal that justifies the guidance.
- Validator output from `scripts/validate-skills.sh` when files are changed.

## Process

1. Check need: confirm the behavior is reusable across tasks or repositories, not a one-off note.
2. Search first: look for existing skills, rules, playbooks, and adapters that already cover the behavior.
3. Pick the smallest home: edit an existing skill when it can own the case; create a new skill only for a distinct trigger.
4. Shape frontmatter: make the description a trigger, not a workflow summary; include concrete situations and avoid duplicate branches.
5. Shape the body: keep required sections complete, put only action-changing guidance in the skill, and avoid repeating project policy.
6. Check completion criteria: every process step should have an observable stopping point or output.
7. Prune: remove no-op advice, stale context, repeated meaning, and speculative future branches.
8. Verify: run `scripts/validate-skills.sh` after skill, routing, or version-table changes.

## Output Format

- Recommendation: create, edit, move to rule/playbook/knowledge, or do nothing
- Trigger fit: why this skill should or should not be discoverable
- Overlap check: existing skills/rules/playbooks reviewed
- Required edits: smallest files or sections to change
- Verification: validator/manual checks run or required

## Anti-patterns

- Creating a new skill because an idea is interesting rather than repeatedly useful.
- Writing descriptions that summarize the workflow and let agents skip the skill body.
- Adding aliases or near-duplicates instead of one clear trigger.
- Copying external skill text wholesale instead of adapting it to this repository's contract.
- Putting project facts in reusable skills and then treating them as source-of-truth evidence.
