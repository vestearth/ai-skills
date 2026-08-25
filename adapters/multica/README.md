# Multica Adapter

Use Multica as a distribution and runtime layer. The canonical behavior,
metadata, evaluations, and review history remain in this repository under
`skills/<name>/`.

Multica workspace skills are imported snapshots, not a second authoring
surface. Do not edit their `SKILL.md` content in Multica. Make a reviewed
change here first, merge it, then refresh the imported workspace skill.

## Initial candidates

Only these stable, passing skills are approved for the first adapter pass:

- `verification-loop`
- `search-first`
- `minimal-change-review`

Their current `metadata.yaml` files are the eligibility source of truth. Do
not add another skill merely because it is available in another runtime.

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

## Deliberate non-goals

- No Multica-specific fork of any canonical skill.
- No automatic import, refresh, binding, or overwrite from this repository.
- No expansion beyond the three initial candidates without repeating the
  duplicate check and confirming stable, passing metadata.
- No assumption that a runtime-local skill copy stays synchronized with the
  Multica workspace copy.
