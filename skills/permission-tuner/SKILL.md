---
name: permission-tuner
description: Use when permission prompts repeatedly interrupt work and observed approval/denial patterns should become proposed allow/deny rules for the agent's settings.
---

# Permission Tuner

## Use When

- The same class of permission prompt keeps interrupting routine work.
- Setting up agent permissions for a new project or workspace.
- The user asks to reduce prompts, tune permissions, or review allow/deny rules.

## Do Not Use When

- A prompt appeared once; a single approval is cheaper than a rule.
- The user deliberately denied an operation; a denial is a decision, not noise to tune away.
- The operation is destructive or outward-facing (force-push, deletion, publishing, credential access) — these stay prompted or denied.

## Goal

Propose a minimal, risk-tiered set of allow/deny rules that removes repeated prompts for routine safe operations without weakening guardrails on destructive ones.

## Required Inputs

- Current permission settings (project and user scope) and which file owns each rule.
- The repeated prompts or denials observed, with the exact commands or tools involved.
- The project's workflow: which operations are genuinely routine here.

## Process

1. Read current settings at both project and user scope; note existing allow/deny rules before proposing new ones.
2. Classify the repeated operations by risk tier: read-only (searches, status, listing), mutating-but-recoverable (edits, staging, local installs), and destructive or outward-facing (force-push, deletes, publishing, secrets).
3. Draft allow rules only for the read-only and routine mutating tiers, scoped as narrowly as the repetition allows (specific commands or prefixes, not wildcards).
4. Keep destructive and outward-facing operations prompted or explicitly denied; never propose allowing them wholesale.
5. Prefer project-scope settings; propose user-scope only for patterns that repeat across projects.
6. Present the proposed rules grouped by tier with the prompts each would eliminate, and apply only after the user approves.

## Output Format

- Observed pattern: which prompts repeat and how often
- Proposed rules as settings fragments, grouped by risk tier
- Scope recommendation (project vs user settings) per rule
- What stays prompted or denied, and why
- Estimated prompt reduction

## Anti-patterns

- Applying rules to settings without explicit approval.
- Broad wildcards that allow whole tool families in one rule.
- Allowing destructive operations because they were "approved a few times".
- Tuning user-scope settings for a pattern that only exists in one project.
- Treating a deliberate denial as a false positive to engineer around.
