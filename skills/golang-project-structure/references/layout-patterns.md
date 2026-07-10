# Layout Patterns

Use these as comparison points, not templates. Omit every directory that has no
current responsibility.

## Small Library

```text
.
├── go.mod
├── widget.go
└── widget_test.go
```

Keep the supported API at the module root. Add subpackages only for cohesive,
independently understandable APIs.

## Simple Command

```text
.
├── go.mod
├── main.go
├── run.go
└── run_test.go
```

`cmd/` is not required for one small command. Move supporting behavior into
packages only when a real boundary appears.

## Single Server

```text
.
├── cmd/
│   └── api/
│       └── main.go
├── internal/
│   ├── app/
│   │   └── app.go
│   ├── order/
│   │   ├── service.go
│   │   └── service_test.go
│   ├── httpapi/
│   │   └── routes.go
│   └── postgres/
│       └── orders.go
├── migrations/
├── go.mod
└── go.sum
```

Use `app` only when lifecycle and dependency wiring need a home beyond
`cmd/api/main.go`. Name capability and adapter packages after what they own; do
not create every shown package before its code exists.

## Server Plus Worker

```text
.
├── cmd/
│   ├── api/
│   │   └── main.go
│   └── worker/
│       └── main.go
├── internal/
│   ├── order/
│   ├── httpapi/
│   ├── queueworker/
│   └── platform/
│       └── database/
├── go.mod
└── go.sum
```

Keep both commands in one module when they share a release lifecycle. Split a
runtime or module only after ownership, deployment, dependency, and release
requirements justify the cost.

## Optional Assets

Add these only when the project owns and uses them:

- `migrations/` for database migrations;
- `api/` or `proto/` for source schemas, following the generator's contract;
- generated packages at the tool-configured path, never hand-edited;
- `testdata/` beside the package that owns fixtures;
- deployment, Docker, or CI files required by the target platform.

Do not add a top-level `tests/` by default. Go unit tests normally live beside
the package they test; use a separate integration test area only when its setup
and execution boundary require one.
