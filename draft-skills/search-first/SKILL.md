# Search First

Use this skill before implementing, debugging, refactoring, or reviewing code in an unfamiliar area.

The goal is to discover the existing system before making changes.

## Use when

- Starting work in an unfamiliar repository, service, module, or package.
- Implementing a feature that may already have similar behavior.
- Debugging behavior without knowing the owning code path.
- Reviewing a change that touches unfamiliar code.
- Refactoring code with unclear callers or dependencies.
- Investigating API routes, protobuf, events, database tables, configs, or error codes.
- Working with generated code, shared libraries, provider integrations, or deployment config.

## Do not use when

- The task is purely wording or documentation with no system behavior.
- The exact file and symbol are already provided and no broader impact is possible.
- The user explicitly asks for a direct explanation without codebase discovery.

## Required workflow

### 1. Define the search target

Identify what must be found:

- symbol/function/type/method
- endpoint/route
- proto service/message/RPC
- error code/status value
- config/env key
- table/migration/query
- event/routing key/queue
- package/module/folder
- test/fixture/mock
- CI/deployment reference

### 2. Search exact terms

Search exact names first.

Examples:

- `WalletService`
- `/api/v1/missions/progress`
- `claimable`
- `INSUFFICIENT_BALANCE`
- `MISSION_RESET_TIME`
- `user_wallets`

### 3. Search variants

Search naming variants and related domain terms.

Examples:

- `wallet`, `balance`, `ledger`
- `mission`, `quest`, `task`
- `provider`, `callback`, `seamless`
- `claim`, `reward`, `collect`

### 4. Inspect closest sources

Open the most relevant files instead of reading the whole repository.

Prefer:

- implementation file
- interface/contract
- test file
- route registration
- proto/schema/migration
- caller/importer
- generated mapping only when needed

### 5. Summarize discovered context

Before editing or answering, summarize:

- what exists
- where it lives
- what pattern it follows
- what remains unknown

### 6. Continue with the task

Only after discovery, proceed to implement, review, debug, or recommend.

## SocratiCode guidance

When available, prefer:

- `codebase_status` before relying on index freshness
- `codebase_search` for terms and usage
- `codebase_symbol` for known symbols
- `codebase_graph_query` for imports/dependents
- direct file reads for final confirmation

SocratiCode is a discovery layer, not the final source of truth.

## Evidence required

Include search evidence when the conclusion depends on repository state:

- search terms used
- files inspected
- symbols/routes/contracts found
- gaps or failed searches
- whether index freshness was checked

## Output format

```text
Search First

Target:
-

Searches performed:
-

Relevant files:
-

What exists:
-

Gaps:
-

Next action:
-