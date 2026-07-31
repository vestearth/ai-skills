# No Secrets In Repo

Use this rule before writing, editing, or committing any file that could carry a
credential value: `.env` and `.env.*`, config, manifests, workflows, fixtures,
tests, seeds, scripts, docs, or task and handoff artifacts.

This rule governs the agent's own edits. For reviewing how an existing secret is
provisioned, scoped, delivered, or rotated, use `skills/secrets-management/SKILL.md`.

## Required Behavior

- Never write a real credential value into a tracked file.
- Reference secrets by name only: env var name, `secretKeyRef`, CI secret key, or vault path.
- Treat `.env`, `.env.local`, and any other real credential file as read-only. Templates — `.env.example`, `.env.sample`, `.env.template`, `.env.dist` — are not credential files and may be edited freely; they hold placeholders, never values.
- Add new configuration keys to `.env.example` (or the repository's documented template) with an empty or clearly fake placeholder value.
- The read-only bar does not lift because the user asked for a key to be configured. "Set up my env" authorizes editing the template and telling the operator what to set — not writing the real file. Only a direct, specific instruction to change that exact file counts, and even then say plainly that the operator should apply it, because a tool-layer guard may block the write outright.
- When a new secret is needed, name the key, say where the operator must set it, and stop; do not invent, guess, or copy a working value.
- Keep credential values out of committed docs, task artifacts, PR bodies, commit messages, and code comments.
- Report a discovered committed secret to the user as a rotation issue; do not silently delete or rewrite history.

## Values That Count As Secrets

- API keys, tokens, PATs, client secrets, signing keys, webhook secrets
- Database and message-broker DSNs or passwords
- Private keys, certificates, kubeconfig files, service-account JSON
- Session cookies, bearer tokens, and OTPs pasted into the conversation
- Internal hostnames or credentials embedded in URLs

## Placeholder Discipline

- Use obviously fake values in examples and fixtures: `changeme`, `example-token`, `<set-in-ci>`.
- Never paste a value from the conversation, a running environment, a log, or another repository into a tracked file.
- Do not print secret values into terminal output, test output, or debug logs.

## Output Evidence

When this rule applies, record briefly:

- Secret keys added or referenced, by name only
- Where the value must be set: CI secret store, cluster `Secret`, vault, local `.env`
- Files touched, and confirmation that no value was written
- Rotation needed: yes/no, and why

## Anti-patterns

- Editing `.env` "to make the app run" without being asked.
- Copying a real token into a test fixture or example config.
- Committing a value and planning to rotate it later.
- Echoing a credential into CI logs to debug wiring.
- Answering "the secret is already configured" without naming the source of truth.
