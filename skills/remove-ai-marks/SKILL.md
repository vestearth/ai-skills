---
name: remove-ai-marks
description: Use when stripping AI provenance from content we own — invisible Unicode or zero-width characters in text, and C2PA/Content Credentials, EXIF/XMP, or generator metadata on images, PDF, DOCX, SVG, HTML, and Markdown — including inspect-only requests such as "what marks does this file carry" before publishing or handoff.
---

# Remove AI Marks

Thin client over the local `watermarks-remover` HTTP service. This skill contains no
cleaning code and never edits bytes itself — every strip goes through the service so
the result comes back with a report that can be quoted.

## Use When

- AI-drafted text is going into a repo, CMS, or document and invisible Unicode (zero-width, bidi, tag chars, exotic spaces) must go before it breaks diffs, search, or rendering.
- An image, PDF, DOCX, SVG, HTML, or Markdown file we own carries C2PA/Content Credentials, EXIF/XMP, or `generator` metadata that should not ship.
- The operator wants to know what provenance marks a file carries before deciding anything.
- A publish or handoff step needs a written record of what was removed.

## Do Not Use When

- The content is not ours to alter — client deliverable under a disclosure obligation, third-party asset, or a file being kept as evidence. Flag and stop.
- The aim is to certify content as human-written, or to defeat an academic, contractual, or legal disclosure requirement. This skill cleans; it never certifies.
- Only code formatting is wanted — a formatter (`prettier`, `gofmt`, `black`) is the smaller tool; run it first, then Layer A if invisible characters remain.
- The target is a real `.env` or credential store; see `rules/no-secrets-in-repo/RULE.md`.

## Goal

Remove the provenance marks the service can verifiably strip, and report what was and
was not removed — without overstating the result.

## Required Inputs

- The target file(s) or pasted text, and who owns the content.
- A reachable service: `WATERMARKS_SERVICE_URL`, default `http://127.0.0.1:8765`.
- `GET /capabilities` output — it decides which claims are honest.
- Output destination; default `*.cleaned.*`, in-place only when the operator asks.

## Process

1. Confirm ownership and intent. If the content is not ours, or the ask is to certify
   human authorship, stop here and say so.
2. Health-check the service: `curl -sf "$WM/health"`. If it is unreachable, tell the
   operator how to start it and stop — never fall back to cleaning bytes by hand.
3. Read `GET /capabilities`. Only promise what it reports present. On this workspace
   `c2patool` is absent, so C2PA manifest *inspection* is unavailable while metadata
   stripping still works; `exiftool` and `qpdf` are present, so PDF strip is real.
4. Inspect before cleaning: `POST /inspect` with `{"file": "<base64>", "name": "<name>"}`.
   Summarize suspicious codepoints and AI/C2PA flags with the confidence label the
   report gives (`confirmed` / `probable` / `informational` / `likely_false_positive`).
5. Clean: `POST /clean` with the same shape. Decode the returned `cleaned` base64 to the
   output path yourself. Keep a known extension in `name` — unknown formats are refused
   (400) rather than mangled, and pasted text needs a `.txt` or `.md` name.
6. For natural-language prose, offer Layer B (statistical-mark reduction by rewriting
   with a model other than the suspected origin), state it is best-effort, and only run
   it on request. The service holds no rewrite model.
7. Re-inspect the output when residual risk matters, and compare against step 4.
8. Report per Output Format. Never claim "undetectable" or "proves human-written".

## Output Format

- What was verifiably removed: counts and actions quoted from the service `report`
- What was inspected but deliberately left (non-AI metadata, kept by request)
- Capabilities that were missing and what that leaves unverified
- Output path(s) written
- Residual risk in one line: out of scope are pixel/audio/video watermarks, C2PA soft
  binding, and secret-key detectors — a vendor tool may still detect after this strip

## Anti-patterns

- Cleaning bytes locally when the service is down, instead of reporting it.
- Promising pixel removal, SynthID scoring, or vendor detection without checking `/capabilities` first.
- Reporting "clean" from a partial run — a partial directory audit is inconclusive, not clean.
- Overwriting the source in place when the operator did not ask.
- Running `/clean` on a file the operator has not confirmed we own.
- Presenting Layer B rewriting as verified removal rather than best-effort.

## Relationship to the automatic lane

`adapters/claude/hooks/clean-invisible-unicode.sh` already strips invisible
Unicode from every text file the Claude lane writes, using the same cleaner.
So do not re-run Layer A on a file only because an agent wrote it — that is
covered. This skill is for what the hook deliberately leaves alone: files that
arrived from elsewhere, fixture paths, binaries and documents (C2PA / EXIF /
XMP), visible-width space normalization, and any inspect-or-report request.

## Local install

Service, runtime, and optional-tool status for this workspace are recorded in
`knowledge-base` under `60 Plugin and References` → *Plugin and References Index* →
`watermarks-remover`. Upstream source, the full rewrite-prompt set, and the deep
reference material (mark classes, vendor notes, removal matrix, ethics) live in the
clone at `watermarks-remover/skills/remove-ai-marks/`.

```bash
WM="${WATERMARKS_SERVICE_URL:-http://127.0.0.1:8765}"
curl -sf "$WM/health" || (cd /Users/earth/Documents/GitHub/watermarks-remover \
  && PATH="$PWD/.venv/bin:/opt/homebrew/bin:$PATH" make serve)
```
