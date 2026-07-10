# Project Archetypes

Classify the project before choosing directories. A process, deployment unit,
release unit, module, and package are different boundaries.

| Archetype | Current need | Smallest useful starting point |
| --- | --- | --- |
| Library | One importable API | One root package and one root `go.mod` |
| Simple CLI | One command with little supporting code | Root `package main`; split only when responsibilities emerge |
| Larger CLI | One command with internal supporting packages | One command plus `internal/`; `cmd/` is optional |
| Server | One self-contained deployable | `cmd/<server>/` plus private packages under `internal/` |
| Worker | One queue, scheduler, or batch process | Treat it as a command; add only the packages its work requires |
| Server plus worker | Multiple commands sharing business behavior and one release | `cmd/<server>/`, `cmd/<worker>/`, and shared `internal/` packages in one module |
| Multi-binary application | Several related commands | One directory per command; use `cmd/` when it makes the command set clearer |
| Public packages plus commands | Supported import API and installable commands | Public packages at stable paths, commands under `cmd/`, private code under `internal/` |

## Module Boundary

Prefer one module at the repository root. A repository typically contains one
module, and a module is the set of packages released together. Consider another
module only when at least one of these is true:

- it has an independent version and release lifecycle;
- external consumers need a deliberately supported package boundary;
- dependency isolation is real and operationally maintained;
- repository tooling and CI can verify each module without hidden workspace state.

Multiple executables do not imply multiple modules. Multiple deployments do not
automatically imply multiple modules. Do not use `go.work` as a production
dependency or as a substitute for an explicit module contract.

## Canonical References

- [Organizing a Go module](https://go.dev/doc/modules/layout)
- [How to Write Go Code](https://go.dev/doc/code)
