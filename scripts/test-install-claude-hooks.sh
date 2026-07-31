#!/usr/bin/env bash
#
# Smoke test for scripts/install-claude-hooks.sh.
#
# The hooks are a security control, so the install path itself is worth testing:
# validate-skills.sh does not look at adapters/claude/hooks, and a hook that is
# mirrored as a dangling symlink fails open in exactly the situation it exists
# for. Asserts the observable behavior in a throwaway directory:
#   - every committed hook is mirrored as an absolute symlink that resolves
#   - the mirrored hook is executable and actually blocks a .env write
#   - stale mirror entries pointing at deleted sources are pruned
#   - unrelated hooks in the target are left alone
#   - an unwired settings.json is reported, not silently edited
#
# No network, no mutation of the repo working tree.
set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALLER="$ROOT_DIR/scripts/install-claude-hooks.sh"
SRC_DIR="$ROOT_DIR/adapters/claude/hooks"

failures=0
fail() { printf 'FAIL: %s\n' "$1" >&2; failures=$((failures + 1)); }

WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/ai-skills-hooks-test.XXXXXX")"
cleanup() { rm -rf "$WORK_DIR"; }
trap cleanup EXIT

hook_count="$(find "$SRC_DIR" -maxdepth 1 -name '*.sh' | wc -l | tr -d ' ')"
[ "$hook_count" -eq 0 ] && fail "no committed hooks under $SRC_DIR to install"

target="$WORK_DIR/project"
dest="$target/.claude/hooks"
mkdir -p "$dest"

# Decoys the installer must not touch / must prune.
printf '#!/bin/sh\nexit 0\n' > "$dest/unrelated-local-hook.sh"
ln -sfn "$SRC_DIR/deleted-hook.sh" "$dest/deleted-hook.sh"

bash "$INSTALLER" --nested "$target" >"$WORK_DIR/out.txt" 2>&1 || fail "install exited non-zero"

installed="$(find "$dest" -maxdepth 1 -name '*.sh' -type l 2>/dev/null | wc -l | tr -d ' ')"
[ "$installed" = "$hook_count" ] || fail "expected $hook_count symlinked hooks, found $installed"

for hook in "$SRC_DIR"/*.sh; do
  name="$(basename "$hook")"
  link="$dest/$name"
  [ -L "$link" ]              || fail "$name: not a symlink"
  [ -e "$link" ]              || fail "$name: symlink does not resolve"
  [ -x "$link" ]              || fail "$name: not executable through the mirror"
  [ "$(readlink "$link")" = "$hook" ] || fail "$name: symlink does not point at the committed source"
done

# Behavior through the mirror, not just its existence.
blocked_json="$WORK_DIR/blocked.json"
jq -n --arg c "$(printf 'echo X %s .env' '>')" '{tool_input:{command:$c}}' > "$blocked_json"
"$dest/guard-env-bash.sh" < "$blocked_json" >/dev/null 2>&1
[ "$?" = "2" ] || fail "guard-env-bash.sh did not block a .env write through the mirror"

allowed_json="$WORK_DIR/allowed.json"
jq -n '{tool_input:{command:"git status --short"}}' > "$allowed_json"
"$dest/guard-env-bash.sh" < "$allowed_json" >/dev/null 2>&1
[ "$?" = "0" ] || fail "guard-env-bash.sh blocked an unrelated command through the mirror"

[ -e "$dest/deleted-hook.sh" ] && fail "stale symlink to a deleted source was not pruned"
[ -f "$dest/unrelated-local-hook.sh" ] || fail "unrelated local hook was removed"

grep -q 'UNWIRED' "$WORK_DIR/out.txt" || fail "missing settings.json wiring is not reported"
[ -f "$target/.claude/settings.json" ] && fail "installer created/edited settings.json (it must not)"

if [ "$failures" -eq 0 ]; then
  echo "install-claude-hooks.sh smoke test passed ($hook_count hook(s), mirror + block behavior + prune)."
  exit 0
fi
echo "install-claude-hooks.sh smoke test FAILED ($failures issue(s))." >&2
exit 1
