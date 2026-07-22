#!/usr/bin/env bash
# Smoke test for manifest-driven named-agent installation and check mode.
set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALLER="$ROOT_DIR/scripts/install-agents.sh"
MANIFEST="$ROOT_DIR/adapters/agents-manifest.yaml"
MANIFEST_VALIDATOR="$ROOT_DIR/scripts/validate-agent-manifest.rb"
WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/ai-skills-agent-installer-test.XXXXXX")"
TARGET="$WORK_DIR/workspace"
failures=0

cleanup() { rm -rf "$WORK_DIR"; }
trap cleanup EXIT
fail() { printf 'FAIL: %s\n' "$1" >&2; failures=$((failures + 1)); }

mkdir -p "$TARGET/.claude/agents"
ln -s "$ROOT_DIR/adapters/claude/agents/__deleted__.md" "$TARGET/.claude/agents/stale-agent.md"
ln -s "$WORK_DIR" "$TARGET/.claude/agents/other-library.md"

bash "$INSTALLER" --all --target "$TARGET" >/dev/null 2>&1 || fail "all-lane install exited non-zero"

expected_count=0
while IFS=$'\t' read -r source destination; do
  [ -n "$source" ] || continue
  expected_count=$((expected_count + 1))
  link="$TARGET/$destination"
  if [ ! -L "$link" ] || [ ! -e "$link" ]; then
    fail "$destination should be a resolving symlink"
  elif [ "$(readlink "$link")" != "$ROOT_DIR/$source" ]; then
    fail "$destination points to the wrong source"
  fi
done < <(ruby -ryaml -e '
  data = YAML.safe_load(File.read(ARGV[0]), aliases: true) || {}
  Array(data["installations"]).each { |entry| puts [entry["source"], entry["destination"]].join("\t") }
' "$MANIFEST")

[ "$expected_count" -gt 0 ] || fail "manifest has no installations"

ruby -ryaml -e '
  data = YAML.safe_load(File.read(ARGV[0]), aliases: false)
  data["installations"][0]["destination"] = ".claude/agents/../../escape.md"
  File.write(ARGV[1], YAML.dump(data))
' "$MANIFEST" "$WORK_DIR/traversal-manifest.yaml"
if ruby "$MANIFEST_VALIDATOR" "$WORK_DIR/traversal-manifest.yaml" >/dev/null 2>&1; then
  fail "manifest validator accepted a traversal-shaped destination"
fi

ruby -ryaml -e '
  data = YAML.safe_load(File.read(ARGV[0]), aliases: false)
  data["installations"] << data["installations"][0].dup
  File.write(ARGV[1], YAML.dump(data))
' "$MANIFEST" "$WORK_DIR/duplicate-manifest.yaml"
if ruby "$MANIFEST_VALIDATOR" "$WORK_DIR/duplicate-manifest.yaml" >/dev/null 2>&1; then
  fail "manifest validator accepted a duplicate destination"
fi

[ ! -L "$TARGET/.claude/agents/stale-agent.md" ] || fail "stale managed agent was not pruned"
[ -L "$TARGET/.claude/agents/other-library.md" ] || fail "unrelated agent symlink should be preserved"

bash "$INSTALLER" --all --target "$TARGET" --check >/dev/null 2>&1 || fail "check should pass after install"
bash "$INSTALLER" --all --target "$TARGET" >/dev/null 2>&1 || fail "idempotent reinstall exited non-zero"

ln -sfn "$WORK_DIR" "$TARGET/.codex/agents/knowledge-librarian.toml"
if bash "$INSTALLER" --lane codex --target "$TARGET" --check >/dev/null 2>&1; then
  fail "check should fail for a mismatched managed destination"
fi
if bash "$INSTALLER" --lane codex --target "$TARGET" >/dev/null 2>&1; then
  fail "install should not replace an unmanaged symlink collision"
fi
[ "$(readlink "$TARGET/.codex/agents/knowledge-librarian.toml")" = "$WORK_DIR" ] || fail "unmanaged symlink collision was mutated"
ln -sfn "$ROOT_DIR/adapters/codex/agents/__stale__.toml" "$TARGET/.codex/agents/knowledge-librarian.toml"
bash "$INSTALLER" --lane codex --target "$TARGET" >/dev/null 2>&1 || fail "lane reinstall should repair an owned stale symlink"
bash "$INSTALLER" --lane codex --target "$TARGET" --check >/dev/null 2>&1 || fail "lane check should pass after repair"

rm "$TARGET/.claude/agents/auditor.md"
printf 'user-owned agent\n' > "$TARGET/.claude/agents/auditor.md"
if bash "$INSTALLER" --lane claude --target "$TARGET" >/dev/null 2>&1; then
  fail "install should not replace a regular-file collision"
fi
grep -Fqx 'user-owned agent' "$TARGET/.claude/agents/auditor.md" || fail "regular-file collision was mutated"
rm "$TARGET/.claude/agents/auditor.md"
bash "$INSTALLER" --lane claude --target "$TARGET" >/dev/null 2>&1 || fail "lane reinstall should fill a cleared destination"

if [ "$failures" -gt 0 ]; then
  printf '\ninstall-agents.sh smoke test failed with %d issue(s).\n' "$failures" >&2
  exit 1
fi

printf 'install-agents.sh smoke test passed (%d manifest installation(s); install + prune + check + safe repair).\n' "$expected_count"
