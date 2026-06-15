# Minimal Change

Use this rule before changing code, files, dependencies, generated artifacts, adapters, workflows, or public contracts.

## Required Behavior

- Prefer the smallest safe change that satisfies the current request.
- Reuse or extend existing code before creating new structure.
- Keep edits inside the relevant ownership boundary.
- Preserve public contracts unless the user explicitly asks for a contract change.
- Do not rename, move, rewrite, or reformat unrelated files.
- Do not broaden a fix into a cleanup project unless the cleanup is required for safety.

## Scope Checks

Before editing, answer:

- What exact behavior or artifact must change?
- Which files or symbols are in scope?
- Which nearby files are intentionally out of scope?
- What must remain compatible?
- What verification proves the change is enough?

## Output Evidence

When applying this rule, record briefly:

- Minimal change: the smallest acceptable edit
- Preserved: files, contracts, behavior, or dependencies left unchanged
- Verification: test, build, lint, search, manual inspection, or why unavailable

## Anti-patterns

- Rewriting a module because a small edit feels less elegant.
- Moving files to match a preferred structure unrelated to the task.
- Renaming public fields, routes, statuses, or errors without compatibility review.
- Adding abstractions for hypothetical future use.
- Treating small changes as permission to skip tests or evidence.
