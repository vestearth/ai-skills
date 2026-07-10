---
name: golang-project-structure
description: Use when creating or reorganizing a Go project, module, service, CLI, worker, library, or multi-binary repository; choosing package boundaries, cmd/internal layout, module boundaries, composition roots, dependency direction, or locations for transports, business logic, persistence, integrations, migrations, and generated code.
---

# Golang Project Structure

## Use When

- Starting a greenfield Go project or adding a new executable to one.
- Choosing between a root command, `cmd/`, `internal/`, public packages, one module, or multiple modules.
- Deciding where business capabilities, transports, persistence, integrations, migrations, configuration, and generated code belong.
- Reorganizing packages because ownership is unclear, dependencies point the wrong way, or import cycles are emerging.

## Do Not Use When

- Reviewing an implementation whose structure is already settled; use `golang-service-review`.
- Deciding whether separate deployables should become separate services; use `microservice-boundary-review` or `tech-lead-review` first.
- Changing only `go.mod`, `go.sum`, `go.work`, Docker, or CI behavior; use `dependency-guard`.
- A current project's `AGENTS.md`, ADRs, source, tests, build, or deployment contract already makes the structural decision.

## Goal

Design the smallest Go structure that gives each executable and package clear ownership, keeps dependency direction understandable, and can grow from evidence without speculative folders, modules, interfaces, or layers.

## Required Inputs

- Project archetype: library, CLI, server, worker, server plus worker, or multi-binary application.
- Executables, protocols, storage, integrations, generated code, deployment units, and release boundaries required now.
- Public Go packages, if any, that other repositories must import and support.
- For an existing repository: project instructions, ADRs, tree, `go.mod`, entrypoints, tests, CI, build, and deployment files.
- Constraints or assumptions that materially affect the layout. Ask only when a missing answer would change the design; otherwise state the assumption.

## Process

1. Classify the archetype and read `references/project-archetypes.md`. Separate executable count, deployment topology, release lifecycle, and Go module boundaries; they are not the same decision.
2. Read project evidence before generic guidance. For greenfield work, record requirements and assumptions. For reorganization, inspect the current source, imports, tests, build, CI, and deployment contract before proposing moves.
3. Run `references/structure-decision-checklist.md`. Identify the composition root for each executable and which responsibilities exist now.
4. Choose the module boundary. Default to one repository-root module. Add another module only when an independently versioned or consumed boundary justifies the added release and dependency cost.
5. Design package ownership with `references/package-boundaries.md`. Prefer cohesive business or platform responsibilities, a small exported API, and dependencies that point from entrypoints and adapters toward application behavior.
6. Choose the smallest layout from `references/layout-patterns.md`. Use `cmd/` when it clarifies multiple commands or a server repository, `internal/` for implementation not intended as a supported external API, and neither `pkg/` nor technical layers by default.
7. Add operational assets only when required: migrations, owned API schemas, generated-code configuration, deployment files, test fixtures, or scripts. Do not create empty directories or placeholder abstractions.
8. For an existing project, propose an incremental migration that keeps the build green, avoids a flag-day rewrite, and names import/API compatibility risks.
9. Verify the result with the project's own commands. At minimum when applicable, run `go list ./...`, `go test ./...`, `go vet ./...`, and build every command. Record skipped checks and the reason.

## Output Format

- Project archetype and stated assumptions
- Proposed tree containing only required files and directories
- Responsibility and exported API of each package
- Allowed dependency direction and composition roots
- Decision for `cmd/`, `internal/`, `pkg/`, and module count
- Rejected alternatives with concrete reasons
- Incremental migration plan for an existing repository
- Verification commands and results, or planned commands before code exists

## Anti-patterns

- Calling a large catalogue tree the standard Go layout and copying it wholesale.
- Creating `cmd/`, `internal/`, `pkg/`, `api/`, `configs/`, `scripts/`, or `tests/` without a current responsibility.
- Using vague ownership packages such as `utils`, `common`, `helpers`, `models`, or `manager`.
- Splitting interface and implementation packages mechanically or adding interfaces before a consumer needs substitution.
- Creating multiple modules or `go.work` to simulate architecture boundaries that share one release lifecycle.
- Organizing every project into handler/usecase/repository layers regardless of size or domain cohesion.
- Moving an existing repository to an idealized tree without proving the migration value and compatibility path.
- Treating this generic skill or an external style guide as stronger than the current project's source and contract.
