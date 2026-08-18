#!/usr/bin/env bash
# PostToolUse (Edit|Write|MultiEdit|NotebookEdit): strip invisible Unicode from
# every text file an agent writes, in place, before it can reach a commit.
#
# Why a hook and not the skill: skills/remove-ai-marks is opt-in and needs the
# operator (or the model) to remember. Zero-width and bidi characters ride into
# source files silently and break diffs, search, and rendering long after the
# session that introduced them, so this lane is unconditional.
#
# It does NOT reimplement Layer A. It shells out to watermarks-remover's own
# clean_text.py, which is context-sensitive about load-bearing invisibles:
# emoji ZWJ glue (👨‍👩‍👧), variation selectors (❤️), complete flag tag
# sequences, script joiners, and same-script fillers are PRESERVED; ZWSP, BOM,
# bidi overrides, soft hyphen, and interlinear annotation are removed. A
# hand-rolled codepoint list in bash would mangle the first group.
#
# --no-normalize-spaces is deliberate: this lane removes invisibles only and
# never rewrites visible-width spaces (NBSP, thin space), because those carry
# real intent in prose, Markdown, and HTML. Run the skill for a full Layer A.
#
# Skipped: test fixtures (deliberate marks under tests/, fixtures/, testdata/),
# binaries (clean_text.py refuses them), and files over MAX_BYTES.
#
# Never blocks: any missing dependency, refusal, or error exits 0 silently. A
# hygiene pass must never cost the operator a tool call.

set -uo pipefail

WM_DIR="${WATERMARKS_REMOVER_DIR:-$HOME/Documents/GitHub/watermarks-remover}"
PY="$WM_DIR/.venv/bin/python"
CLEANER="$WM_DIR/service/scripts/clean_text.py"
MAX_BYTES=2000000

input="$(cat 2>/dev/null)" || exit 0
f="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' 2>/dev/null)" || exit 0

[ -z "$f" ] && exit 0
[ -f "$f" ] || exit 0
[ -x "$PY" ] || exit 0
[ -f "$CLEANER" ] || exit 0

# Fixtures encode marks on purpose; cleaning them breaks the tests that assert on them.
case "/$f/" in
  */tests/*|*/fixtures/*|*/testdata/*) exit 0 ;;
esac

size="$(wc -c < "$f" 2>/dev/null | tr -d ' ')"
[ -z "$size" ] && exit 0
[ "$size" -gt "$MAX_BYTES" ] && exit 0

tmp="$(mktemp -t clean-invisible-unicode)" || exit 0
stats="$(mktemp -t clean-invisible-unicode-stats)" || { rm -f "$tmp"; exit 0; }
trap 'rm -f "$tmp" "$stats"' EXIT

# Non-zero covers binary refusal, unknown encoding, and any internal error.
if ! "$PY" "$CLEANER" "$f" -o "$tmp" --no-normalize-spaces --stats 2>"$stats"; then
  exit 0
fi

if cmp -s "$f" "$tmp"; then
  exit 0
fi

# Preserve the original mode; mv from a mktemp file would install 0600.
cat "$tmp" > "$f" || exit 0

removed="$(jq -c '.removed // {}' < "$stats" 2>/dev/null)" || removed=""
[ -z "$removed" ] && removed="{}"

jq -n --arg file "$f" --argjson removed "$removed" '{
  hookSpecificOutput: {
    hookEventName: "PostToolUse",
    additionalContext: ("clean-invisible-unicode: stripped invisible Unicode from \($file) after the write: \($removed | tojson). The file on disk now differs from what was written — re-read it before quoting exact bytes, and mention the strip if the content is being handed off.")
  }
}' 2>/dev/null || exit 0

exit 0
