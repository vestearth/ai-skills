# Reuse Before Build

Use this guardrail before an agent changes code, scaffolds files, adds dependencies, creates abstractions, or introduces new workflows.

Apply `rules/minimal-change/RULE.md` and `rules/search-before-create/RULE.md` when the task involves edits or new artifacts.

## Decision Order

Check in order and stop at the first option that solves the task:

1. Need it?
2. Existing code?
3. Standard library?
4. Platform or native feature?
5. Existing dependency?
6. Smallest new code?

## Required Checks

- Confirm the requested behavior is necessary for the current task.
- Search the repository for existing behavior, helpers, config, docs, tests, and conventions.
- Search exact names and naming variants before creating new artifacts.
- Prefer standard library or runtime capabilities over new utilities.
- Prefer framework, platform, shell, database, browser, or OS-native features over custom code.
- Prefer already-installed dependencies over new dependencies.
- Add only the smallest code that satisfies the verified need.
- Preserve existing public contracts unless a contract change is explicitly requested and impact-reviewed.
- Keep security, data safety, accessibility, compatibility, and tests intact.

## Output Evidence

When applying this rule, record the decision briefly:

- Need: yes/no and why
- Reuse found: file, API, dependency, or none
- New code: smallest acceptable change
- Verification: test, build, lint, manual check, or why unavailable

## Anti-patterns

- Creating a new helper before searching for one.
- Adding a dependency for behavior already available in the platform or repository.
- Refactoring unrelated code to make the new idea feel cleaner.
- Building a general framework for a one-off need.
- Treating minimal code as permission to skip safety or verification.
