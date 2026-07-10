# Structure Decision Checklist

Answer only the questions that can change the layout. State reasonable
assumptions instead of blocking on low-impact unknowns.

## Runtime And Release

- Is this a library, CLI, API/server, worker, or a combination?
- How many executable processes are required now?
- Which processes deploy and release together?
- Does any Go package need to be imported and supported outside this repository?
- Is an independent module version truly required?

## Boundaries

- What business capabilities exist now?
- Which transports are required: HTTP, gRPC, queue, scheduled job, or CLI?
- Which storage engines and external integrations are required?
- Where will dependency construction, startup, shutdown, and health checks live?
- Which code is a supported public API, and which should be protected by `internal/`?

## Operational Assets

- Are schemas, protobuf/OpenAPI inputs, or generated outputs owned here?
- Are migrations required, and which runtime applies them?
- Which commands do CI and container builds compile?
- Are integration fixtures or platform-specific deployment files required now?

## Growth Pressure

Split a package or add structure only when current evidence shows one or more of:

- unrelated responsibilities change independently;
- ownership or exported API is unclear;
- dependency direction is reversed or an import cycle is forming;
- test setup is materially different;
- another executable needs shared behavior;
- an independently supported public API or release boundary exists.

Do not split for a hypothetical future team, service, datastore, or second
implementation.

## Final Review

- Does every proposed directory own code or an operational artifact now?
- Can every import direction be explained?
- Are `cmd/`, `internal/`, `pkg/`, and module-count decisions explicit?
- Are rejected alternatives and their costs recorded?
- For an existing repository, can the migration happen incrementally while tests stay green?
- Are `go list ./...`, `go test ./...`, `go vet ./...`, and command builds included in verification?
