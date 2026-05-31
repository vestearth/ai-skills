# Context Discipline

Use this skill when an agent must gather enough context to work accurately without overloading the session.

The goal is to collect targeted evidence, not dump the whole repository into the model.

## Use when

- Starting work in a large repository or multi-service workspace.
- Using SocratiCode, search indexes, MCP tools, or code graph as context sources.
- Debugging or reviewing with limited context window.
- The task spans multiple services, APIs, generated code, configs, or deployment files.
- Previous context may be stale, incomplete, or too broad.
- The agent is tempted to read many files before forming a search strategy.

## Do not use when

- The user provides all relevant text directly.
- The task is a small edit in one known file.
- The task is purely wording, translation, or explanation.

## Required workflow

### 1. Define the information need

State what context is needed to answer or edit safely.

Examples:

- route ownership
- caller chain
- API contract
- proto mapping
- database table behavior
- deployment config
- failing test/log source

### 2. Choose discovery tools first

Prefer lightweight discovery before opening many files:

- repository search
- symbol search
- SocratiCode search
- graph query
- route/proto/schema lookup
- test name search
- config key search

### 3. Read only relevant files

Open the smallest set of files needed to confirm the claim.

Prefer source-of-truth files over summaries.

### 4. Track context budget

Avoid reading:

- unrelated packages
- generated files unless needed
- duplicate docs
- old summaries
- broad folder dumps
- entire repo trees without a target

### 5. Summarize context

Before editing or answering, summarize:

- what was found
- what is source of truth
- what is still unknown
- what files matter

### 6. Stop when enough evidence exists

Do not keep gathering context just because more files exist.

## SocratiCode guidance

Use SocratiCode for discovery, not final proof.

Recommended order:

1. `codebase_status`
2. `codebase_search`
3. `codebase_symbol`
4. `codebase_graph_query`
5. direct file reads for confirmation

## Output format

```text
Context Discipline

Information needed:
-

Discovery used:
-

Files inspected:
-

Source of truth:
-

Useful context:
-

Ignored/avoided context:
-

Remaining gaps:
-