# Multica Adapter

Use Multica as a distribution and runtime layer. The canonical behavior,
metadata, evaluations, and review history remain in this repository under
`skills/<name>/`.

Multica workspace skills are imported snapshots, not a second authoring
surface. Do not edit their `SKILL.md` content in Multica. Make a reviewed
change here first, merge it, then refresh the imported workspace skill.

## Engineering candidates

These stable, passing engineering skills are approved for the adapter:

- `verification-loop`
- `search-first`
- `minimal-change-review`

Their current `metadata.yaml` files are the eligibility source of truth. Do
not add another skill merely because it is available in another runtime.

## Coordination pilot

The operator approved `multica-office-workflow` on 2026-11-04, alongside the
three engineering skills above. It is an explicitly scoped **beta** pilot:
supplied-input behavioral replay, workspace import, agent binding, and actual
runtime use are separate checks. Do not label it stable from installation alone.
Its source remains `skills/multica-office-workflow/`, with the same reviewed
merge and hosted-source import/refresh contract as the engineering skills.

This skill owns the engineering handoff between Multica and repository/Office
records. Native Multica platform skills own CLI and trigger semantics. The
coordination skill does not replace those native skills or duplicate the
engineering review procedures.

Bind by responsibility: builders use all three engineering candidates;
investigators/reviewers use search and verification (plus minimal-change when
editing); coordinators use search, verification and the coordination pilot.
Workers may also use the coordination pilot for receiving/reporting Office
handoffs. Use additive bindings and preserve unrelated skills.

## Required duplicate check

Before importing a candidate, inspect the Multica workspace's skills and its
built-in skill scope:

```bash
MULTICA=multica
# If the desktop app did not put the CLI on PATH, set MULTICA to its bundled
# executable, for example /Applications/Multica.app/Contents/Resources/app.asar.unpacked/resources/bin/multica.
PROFILE=desktop-api.multica.ai
WORKSPACE_ID=<workspace-id>

"$MULTICA" --profile "$PROFILE" --workspace-id "$WORKSPACE_ID" skill list --output json
```

Do not import when a workspace skill already has the same purpose. Resolve the
ownership first:

| Existing capability | Decision |
| --- | --- |
| Same engineering workflow and materially equivalent guidance | Use the existing Multica skill; do not create a duplicate. |
| Multica platform operation (`multica-*` built-in) | Keep it native; it is complementary, not a replacement for an engineering skill. |
| Partial overlap | Keep the native platform skill and import only the distinct canonical engineering workflow. |

Multica's built-in `multica-*` skills are platform-operation instructions and
are delivered separately from workspace-bound skills. They do not make
`verification-loop`, `search-first`, or `minimal-change-review` redundant.

## Import and refresh

Import only after the duplicate check has been recorded and a user with the
right Multica workspace authority has approved the persistent workspace change.
Use the canonical GitHub path, not a copied local folder:

```bash
SOURCE=https://github.com/vestearth/ai-skills/tree/main/skills

"$MULTICA" --profile "$PROFILE" --workspace-id "$WORKSPACE_ID" \
  skill import --url "$SOURCE/verification-loop" --output json
```

Repeat one import per approved skill. Record the returned Multica skill ID and
the canonical commit used for the import. Bind it with `multica agent skills
add`, never `set`, so existing agent assignments are preserved.

After a canonical skill change is merged, refresh the corresponding Multica
skill, then inspect it and its agent bindings before treating the runtime copy
as current:

```bash
"$MULTICA" --profile "$PROFILE" --workspace-id "$WORKSPACE_ID" \
  skill refresh <multica-skill-id> --output json
"$MULTICA" --profile "$PROFILE" --workspace-id "$WORKSPACE_ID" \
  skill get <multica-skill-id> --output json
"$MULTICA" --profile "$PROFILE" --workspace-id "$WORKSPACE_ID" \
  agent skills list <agent-id> --output json
```

The snapshot is current only after the refresh result and imported `SKILL.md`
match the intended canonical commit. A successful import or binding does not
prove refresh propagation.

Paths such as `rules/...` in an engineering skill are relative to the canonical
`ai-skills` repository, not the task's temporary skill directory. Resolve them
from the target project's instructions and accessible source checkout. A hosted
folder import does not promise to bundle files outside that folder: inspect the
imported files and report unavailable dependencies rather than claiming the
skill is self-contained. Preserve canonical content instead of making an edited
Multica-only fork to hide a missing reference.

## Deliberate non-goals

- No Multica-specific fork of any canonical skill.
- No automatic import, refresh, binding, or overwrite from this repository.
- No expansion beyond the three engineering candidates and the explicitly
  approved coordination pilot without a duplicate check and approval. Additional
  engineering candidates require stable, passing metadata.
- No assumption that a runtime-local skill copy stays synchronized with the
  Multica workspace copy.
