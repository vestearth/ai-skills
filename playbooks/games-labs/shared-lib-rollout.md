# Games Labs Shared-lib Rollout Playbook

Use this playbook when checking or planning `shared-lib` adoption across Games Labs repositories.

This playbook is domain-specific. For generic dependency review, use `skills/dependency-guard/SKILL.md`. For protobuf/gRPC contract compatibility, use `skills/grpc-contract-review/SKILL.md`.

## Use When

- A shared type, error helper, protobuf contract, or utility has been added to `shared-lib`.
- A service must bump or verify its `shared-lib` pseudo-version.
- The user asks whether a shared-lib update has landed across repos.
- Local duplicated types or handler messages may need to move back into `shared-lib`.
- Cross-repo behavior depends on generated code, error mapping, or module version alignment.

## Source Of Truth Checklist

Verify:

- `shared-lib` commit and exported API.
- Consumer `go.mod` pseudo-version and `go.sum`.
- Generated protobuf artifacts when contracts changed.
- Imports and call sites in every affected service.
- Tests or build output for each consumer repo.
- Any local `replace` directive, `go.work`, or workspace-only behavior.

The newest pseudo-version is the one with the latest embedded timestamp, not the one that looks largest by hash.

## Process

1. Identify the shared-lib change: exported symbol, protobuf message, error helper, handler message, or utility.
2. List affected repos and classify each one as not applicable, code adopted, version bumped, build verified, or blocked.
3. Compare consumer `go.mod` versions against the required shared-lib commit.
4. Check for local duplicate replacements that should not exist in consumer services.
5. For error handling, verify `MetaError`, `HTTPStatusFromError`, status code mapping, and client-facing error contract together.
6. For protobuf changes, confirm generated code is updated in the owning repo and consumers compile against the new contract.
7. Run focused verification per repo. Avoid one combined command when per-repo failures need separate evidence.
8. Report adoption separately from dependency alignment. A repo can contain code changes while still pointing at an old module version.

## Rollout Output

Include:

- Required shared-lib commit or pseudo-version.
- Repo-by-repo adoption table.
- Code adoption status.
- Dependency version status.
- Build/test evidence.
- Remaining local duplicates or contract drift.
- Next action per blocked repo.

## Anti-patterns

- Treating a code diff as landed before `go.mod` points at the required shared-lib version.
- Comparing pseudo-versions by hash instead of timestamp.
- Keeping handler messages or shared error shapes locally in one service.
- Using `replace ../shared-lib` as proof that CI or production will compile.
- Reporting all repos as aligned from a single failing combined command.
