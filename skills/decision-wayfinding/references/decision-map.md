# Decision Map And Checkpoint Format

The smallest representation that survives a session boundary and a human can
review. Keep it in one file (Markdown with a YAML block, or plain YAML) next to
the work it shapes, or in whatever document or tracker the team already
reviews. The format is the contract; the storage backend is not.

## Map

```yaml
destination:
  outcome: "Architecture is decision-complete and ready for an implementation spec"
  done_when:
    - "Every decision on the V1 path is resolved or explicitly deferred"
    - "No fog item blocks a V1 decision"
  v1_boundary: "What is in and out of V1, in one or two lines"

nodes:
  - id: D1                       # D decision / R research / I investigation / P prototype
    type: decision
    title: "Where does the integration boundary live?"
    status: resolved             # open | claimed | blocked | resolved | deferred | invalidated
    depends_on: []
    outcome: "In a dedicated adapter package behind one interface"
    evidence: ["path/to/source.go", "R1"]
    resolved_at: 2026-09-26

  - id: R1
    type: research
    title: "Confirm upstream rate limits and timeout behavior"
    status: open
    depends_on: []

  - id: D2
    type: decision
    title: "Choose retry semantics"
    status: blocked
    depends_on: [R1]

fog:
  - item: "failover across multiple upstreams"
    why_not_a_node: "No evidence yet that more than one upstream is needed"

deferred:
  - id: D7
    reason: "Out of V1 boundary; revisit after launch data"
```

### Status rules

- `open`: can be worked once its dependencies are resolved.
- `claimed`: an active path (this session, another session, a parallel agent) owns it. Record who.
- `blocked`: at least one `depends_on` entry is not `resolved`.
- `resolved`: has an `outcome` and `evidence`. A resolution without evidence stays `open`.
- `deferred`: deliberately out of scope for the destination, with a reason.
- `invalidated`: a later finding broke an assumption it rested on. Replace it with rebuilt nodes; do not reopen it silently.

**Frontier** = nodes that are `open`, whose every `depends_on` is `resolved`, and that are not `claimed`.

## Checkpoint

Write one when a checkpoint signal fires, and at the end of every working
session. It must let a fresh session continue from the frontier without reading
the old conversation.

```yaml
checkpoint:
  written_at: 2026-09-26
  map: "path/or/link/to/the/map"
  destination: "one-line outcome"
  resolved:
    - "D1: adapter package behind one interface (evidence: path/to/source.go)"
  findings_to_keep:
    - "R1: upstream allows 10 req/s per key; 429 carries Retry-After (source: vendor docs URL)"
  frontier: [R2, I1]
  blocked:
    - "D2 waits on R1"
  fog: ["failover across multiple upstreams"]
  next_action: "Work R2 via external research; then D2 via decision-grilling"
```

Keep only what the next session needs. Tool output, dead ends that taught
nothing, and superseded reasoning stay out.
