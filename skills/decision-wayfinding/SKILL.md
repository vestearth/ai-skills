---
name: decision-wayfinding
description: Use when a problem is large or foggy enough that the destination or route is unclear, several dependent decisions need research, spikes, or repository investigation first, and resolving them will likely span more than one session.
---

# Decision Wayfinding

## Use When

- The destination is unclear: nobody can yet state what "decided" looks like, or the goal hides several separable decisions.
- The route is unclear: some decisions depend on others, or on research, a spike, or investigation that has not happened yet.
- There are known unknowns that cannot be phrased as a concrete question without guessing ("fog").
- The work will plausibly outlive one session or one useful context window, so state has to survive a handoff.
- A decision-grilling session keeps surfacing new unresolved branches instead of converging.

## Do Not Use When

- Scope and solution are already clear; plan or implement directly.
- A few material decisions remain and each can be answered interactively in one session; use `decision-grilling`.
- The question is a single architecture review; use `tech-lead-review`.
- The work is active debugging of a failure; use `debugging`.
- The map is decision-complete and the next step is task breakdown or implementation; hand off (see Process step 8) instead of continuing to shape.

## Goal

Manage uncertainty as a persistent map, not a conversation: define the destination, resolve decisions in dependency order, keep fog explicit until evidence makes it concrete, and stop with an implementation-ready spec. Wayfinding decides what to decide; it never becomes implementation.

`decision-grilling` resolves uncertainty through focused dialogue. `decision-wayfinding` owns the map and progression, and routes individual frontier nodes to `decision-grilling` and other specialist skills.

## Required Inputs

- The problem statement and any stated constraints, owners, and deadlines.
- An existing decision map or checkpoint, if this continues earlier work (read it before anything else).
- A durable place to keep the map that humans can review: a file in the target repository, a document, or an issue tracker. The format is in `references/decision-map.md`; no particular backend is required.
- Repository, knowledge-base, and runtime evidence relevant to the frontier.

## Process

1. **Route first.** Classify the request before building anything:
   - scope and solution clear -> direct planning or implementation; stop here.
   - few material decisions, answerable in one session -> `decision-grilling`; stop here.
   - destination or route unclear, multiple unknowns, research required, or multi-session -> continue.
   This is guidance, not a gate: say which path you chose and why, and let the user override it.
2. **Define the destination.** Write one outcome sentence and its done criteria: what must be decided, and the boundary of V1. Confirm it with the user before mapping, since every node is judged against it.
3. **Build the map.** Create nodes of type `decision`, `research`, `investigation`, or `prototype`, each with a status and `depends_on`. Only create a node when you can phrase it without assuming its answer. Park everything else in fog. Persist the map before working any node.
4. **Select the frontier.** A node is on the frontier when it is open, all its dependencies are resolved, and no other active path has claimed it. Work one material frontier node at a time. Run nodes in parallel only when they share no dependency and no unresolved assumption.
5. **Resolve each node with the right tool, not a reimplementation:**
   - `decision` -> `decision-grilling`, one question at a time, recommending an answer.
   - `investigation` -> `search-first` and direct source reading; `knowledge-query` for prior decisions; `change-impact-analysis` or `microservice-boundary-review` when the question is blast radius or ownership.
   - `research` -> external docs or vendor material, with sources recorded.
   - `prototype` -> a throwaway spike outside production paths, deleted or clearly marked non-production when done.
   - architecture judgment across the map -> `tech-lead-review`.
   Record the outcome, the evidence, and the date on the node, then persist the map.
6. **Re-route when evidence moves.** After each resolution, check which nodes and fog items it affects. If it invalidates an assumption behind other nodes, mark them `invalidated` and rebuild that branch instead of executing the original plan. Promote fog that is now phrasable into nodes; drop fog that no longer matters; keep the rest explicitly deferred.
7. **Checkpoint on signals, not a percentage.** Write a checkpoint (format in `references/decision-map.md`) and recommend a fresh session when you notice any of:
   - re-looking-up facts already established;
   - conflicting assumptions in your own reasoning;
   - repeated summaries with little new progress;
   - tool or log history outweighing the current frontier;
   - several unrelated branches active at once;
   - the map no longer fitting cleanly in working context.
   A new session starts from the checkpoint and the map, not a transcript replay. Use `session-handoff` for the handoff message itself.
8. **Stop and hand off when decision-complete.** The map is complete when every node on the path to the destination is `resolved` or explicitly `deferred` with a reason, and no fog item blocks a V1 decision. Produce an implementation-ready spec (decisions with rationale and evidence, V1 scope and exclusions, open risks, deferred items) and hand it to PM or task planning. Do not start the implementation.

## Output Format

While shaping:
- Route chosen and why
- Destination and done criteria
- Map summary: resolved / frontier / blocked / invalidated counts, plus the fog list
- Current frontier node and the specialist skill it is routed to
- Where the map and latest checkpoint are persisted
- Next recommended action

When decision-complete:
- Implementation-ready spec: destination, locked decisions with rationale and evidence, V1 scope and exclusions, deferred items with reasons, open risks
- Handoff target (PM / task planning) and what they need to do next

## Anti-patterns

- Editing production code, migrations, deployment config, or other implementation artifacts because shaping went well. Shaping outputs are research, source inspection, non-production spikes, design notes, decision records, map updates, and checkpoints.
- Turning fog into tickets because tickets are easy to create; that encodes assumptions as facts.
- Executing the original plan after research invalidated its assumptions.
- Keeping the map only in the conversation, so it dies with the session.
- Reimplementing grilling, search, or review inline instead of routing the node to that skill.
- Running Wayfinding on small, clear work, or on a handful of decisions `decision-grilling` could close in one sitting.
- Promoting every finding into the knowledge base; map state is problem state. Only verified, reusable findings go through `knowledge-capture`.
- Using a fixed context percentage as the checkpoint trigger.
