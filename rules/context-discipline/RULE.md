# Context Discipline

Use this rule when gathering repository context for implementation, debugging, review, release, or handoff work.

## Required Behavior

- Define the information needed before opening many files.
- Use targeted search, symbol lookup, graph queries, or route/schema lookup first.
- Read only files that can confirm or refute the current claim.
- Prefer source-of-truth files over summaries.
- Summarize discovered context before editing.
- Stop gathering context once enough evidence exists to proceed safely.

## Avoid Loading

- Unrelated packages or services
- Generated files unless they are the source of truth for the claim
- Duplicate docs and stale summaries
- Entire repository trees without a target
- Broad context dumps that do not change the decision

## Output Evidence

When context matters, record:

- Information needed
- Discovery used
- Files inspected
- Source of truth
- Useful context
- Remaining gaps

## Anti-patterns

- Reading broadly to feel safer while losing the actual task.
- Using indexed context as final proof.
- Editing before summarizing what the relevant files show.
- Continuing discovery after the decision is already supported.
