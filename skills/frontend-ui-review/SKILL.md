---
name: frontend-ui-review
description: Use when implementing or reviewing frontend pages and components against Figma, an existing design system, production UI patterns, responsive requirements, interaction states, or accessibility expectations.
---

# Frontend UI Review

## Use When

- Implementing a Figma frame or design-system component in frontend code.
- Reviewing whether a page matches its approved visual and interaction intent.
- Checking UI consistency, component reuse, responsive behavior, or state coverage.
- The user reports that a rendered page looks wrong, incomplete, generic, or inconsistent.

## Do Not Use When

- The task is pure backend, API, data, or infrastructure work.
- The root cause is an unknown runtime bug; use `debugging` first.
- The task is general code correctness or merge readiness without a UI concern;
  use `code-review`.
- The user asks to create or edit a Figma file; use the applicable Figma skill.
- A project-specific design skill owns creative direction; use it for design
  generation and this skill for implementation fidelity and review.

## Goal

Produce frontend code that follows the approved design intent, reuses the
project's implementation system, covers real UI states, and is verified in the
rendered application without introducing an unrequested visual direction.

## Required Inputs

- The user request and target route, page, component, or rendered preview.
- The exact Figma file/frame/node or other approved design artifact when one is
  part of the task.
- Project design guidance such as `DESIGN.md`, `AGENTS.md`, tokens, theme
  configuration, and existing production components.
- The framework-native component library and current dependency manifest.
- Available lint, typecheck, build, test, browser, screenshot, or accessibility
  checks.

## Process

1. Establish the design evidence order:
   - explicit user or product requirement;
   - exact approved Figma frame/node;
   - existing production components, tokens, and interaction patterns;
   - project design documentation;
   - framework-native component library;
   - external design heuristics or detector suggestions.
2. Read the target implementation and closest existing components before
   creating files, components, tokens, or dependencies.
3. Map the design to code explicitly: layout, hierarchy, spacing, typography,
   color, components, content, interactions, and responsive behavior.
4. Check required states: loading, empty, error, disabled, validation, success,
   focus, hover, and selected states when applicable.
5. Check accessibility basics: semantic structure, labels, keyboard access,
   visible focus, contrast, reduced motion, and usable touch targets.
6. Implement or recommend the smallest change that preserves project patterns.
   If the approved design and production system conflict, surface the conflict
   instead of silently redesigning either side.
7. Verify the rendered result at relevant breakpoints. Use browser inspection,
   screenshots, or visual comparison when available, then run the project's
   focused tests, lint, typecheck, and build in proportion to the change.
8. Record any assumption caused by a missing Figma state or unspecified
   behavior. Infer minimally; ask only when the decision would materially alter
   the product experience.

## Output Format

- Design evidence: artifact, frame/node, project docs, components, and tokens
- Findings or changes: fidelity, state, responsive, accessibility, and reuse
- Verification: rendered checks plus test/lint/typecheck/build evidence
- Assumptions or unresolved design conflicts

## Anti-patterns

- Treating Figma-generated code or an external skill as implementation truth.
- Redesigning the screen, palette, radius, shadow, typography, or motion without
  explicit authority.
- Adding a second component system when the project already has an adequate one.
- Creating a component or token before checking existing production patterns.
- Allowing an anti-slop detector to override intentional brand decisions.
- Claiming visual fidelity from source inspection alone without checking the
  rendered UI when a preview can be run.
