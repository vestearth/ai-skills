---
name: minimal-change-review
description: Use when an agent is about to modify code, create files, add dependencies, scaffold features, or review whether an implementation is larger than necessary.
---

# Minimal Change Review

Review whether the task can be solved by reusing what already exists before adding new code.

## Use When

- Before implementing a code change or generated handoff.
- Reviewing an implementation that may be overbuilt.
- Deciding whether to add a dependency, helper, abstraction, workflow, or scaffold.
- Converting an external pattern into this repository's own standards.

## Do Not Use When

- The user only asks for factual explanation and no change is being considered.
- A security, data-loss, incident, or production failure workflow is more urgent.

## Required Rule

Apply:

- `rules/minimal-change/RULE.md`
- `rules/reuse-before-build/RULE.md`
- `rules/search-before-create/RULE.md` when creating new artifacts

## Goal

Prevent unnecessary code, dependencies, scaffolding, and abstractions by proving reuse options were checked first.

## Required Inputs

- User request, acceptance criteria, or proposed implementation.
- Relevant repository files, docs, tests, dependency manifests, and existing helpers.
- Diff or planned change when reviewing work already produced.
- Verification evidence when available.

## Process

Answer the minimal-change and reuse chain in order:

1. Define the exact required change.
2. Confirm the behavior or artifact is necessary.
3. Search existing code, docs, tests, configs, and conventions.
4. Check standard library, runtime, platform, or native features.
5. Check existing dependencies.
6. Choose the smallest safe edit or explain why new code is required.

For each answer:

- Cite the repo evidence checked.
- Prefer the first adequate option.
- Stop expanding once the task is satisfied.
- Preserve tests, contracts, security, accessibility, data safety, and compatibility.

## Output Format

- Decision: reuse, small edit, or new code required
- Evidence checked: files, commands, docs, or dependency references
- Minimal change: what should be changed and what should stay untouched
- Verification: tests or checks required before completion

## Anti-patterns

- Starting from a preferred implementation instead of the smallest sufficient path.
- Adding a new abstraction because similar code exists twice.
- Copying an external project wholesale when a local rule is enough.
- Renaming, moving, or reformatting unrelated code.
- Treating "small" as "untested" or "unsafe."
