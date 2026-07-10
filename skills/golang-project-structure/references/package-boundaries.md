# Package Boundaries

## Ownership Test

A package should have a nameable responsibility and a reason for its files to
change together. Before creating one, answer:

- What business capability or platform responsibility does it own?
- Who imports it, and why?
- What is its smallest supported exported API?
- Which implementation details must remain private?
- Would moving this code reduce cohesion or create a dependency cycle?

Prefer a cohesive package over a stack of mechanical layers. Split when a
responsibility has a distinct owner, dependency set, test setup, rate of change,
or reusable API—not merely because a file is long.

## Dependency Direction

For applications, keep wiring at the executable boundary:

```text
command/composition root
  -> transports, workers, and operational adapters
  -> application or business capability
  <- persistence and external integrations implement needed boundaries
```

The business capability should not need an HTTP router, gRPC server, SQL driver,
or queue client merely to express its rules. Keep framework types at boundaries
when doing so materially improves testing or reuse; do not introduce translation
layers without that need.

Define a small interface at the consuming side when substitution is required by
tests or multiple implementations. Use a concrete type when one implementation
is sufficient. Avoid provider-owned interfaces that expose every method of an
implementation.

## Visibility

- Keep stable, intentionally supported import APIs outside `internal/`.
- Put implementation packages under `internal/` when code outside the allowed
  parent tree should not import them.
- Export only what another package needs.
- Do not create `pkg/` as a synonym for "Go code"; public packages can live at
  clear top-level import paths.

## Naming And Cycles

Use short names that state ownership. Avoid broad buckets such as `util`,
`common`, `helper`, `model`, or `manager`. Resolve an import cycle by revisiting
ownership and dependency direction, not by moving shared fragments into a new
generic bucket.

## References

Canonical:

- [Organizing a Go module](https://go.dev/doc/modules/layout)
- [Effective Go](https://go.dev/doc/effective_go)
- [Go Code Review Comments](https://go.dev/wiki/CodeReviewComments)

Supplementary; project rules still win:

- [Google Go Style Guide](https://google.github.io/styleguide/go/)
- [Uber Go Style Guide](https://github.com/uber-go/guide)
