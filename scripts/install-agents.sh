#!/usr/bin/env bash
# Install or check named-agent adapters declared in adapters/agents-manifest.yaml.
# This script owns only symlinks that point into this repo's adapters/*/agents/
# tree; unrelated workspace agents are preserved.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="$ROOT_DIR/adapters/agents-manifest.yaml"
MANIFEST_VALIDATOR="$ROOT_DIR/scripts/validate-agent-manifest.rb"
TARGET_PROJECT="$(dirname "$ROOT_DIR")"
LANE=""
CHECK_ONLY=false

usage() {
  cat <<'EOF'
Usage:
  scripts/install-agents.sh --lane claude|codex|cursor [--target DIR] [--check]
  scripts/install-agents.sh --all [--target DIR] [--check]
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --lane)
      [ "$#" -ge 2 ] || { echo "error: --lane requires a value" >&2; exit 2; }
      LANE="$2"
      shift 2
      ;;
    --all)
      LANE="all"
      shift
      ;;
    --target)
      [ "$#" -ge 2 ] || { echo "error: --target requires a directory" >&2; exit 2; }
      TARGET_PROJECT="$(cd "$2" && pwd)"
      shift 2
      ;;
    --check)
      CHECK_ONLY=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown argument '$1'" >&2
      usage >&2
      exit 2
      ;;
  esac
done

case "$LANE" in
  claude|codex|cursor|all) ;;
  "") echo "error: choose --lane claude|codex|cursor or --all" >&2; exit 2 ;;
  *) echo "error: unsupported lane '$LANE'" >&2; exit 2 ;;
esac

[ -f "$MANIFEST" ] || { echo "error: agent manifest not found: $MANIFEST" >&2; exit 1; }
command -v ruby >/dev/null 2>&1 || { echo "error: ruby is required to read $MANIFEST" >&2; exit 1; }

manifest_rows() {
  ruby "$MANIFEST_VALIDATOR" "$MANIFEST" "$LANE"
}

rows="$(manifest_rows)"
[ -n "$rows" ] || { echo "error: no named agents declared for lane '$LANE'" >&2; exit 1; }

expected_destinations=""
installed=0
failures=0

while IFS=$'\t' read -r agent lane source destination; do
  [ -n "$agent" ] || continue
  case "$lane:$source:$destination" in
    claude:adapters/claude/agents/*.md:.claude/agents/*.md|codex:adapters/codex/agents/*.toml:.codex/agents/*.toml|cursor:adapters/cursor/agents/*.md:.cursor/agents/*.md) ;;
    *) echo "error: invalid lane/source/destination for $agent" >&2; failures=$((failures + 1)); continue ;;
  esac

  source_path="$ROOT_DIR/$source"
  destination_path="$TARGET_PROJECT/$destination"
  if [ ! -f "$source_path" ]; then
    echo "error: source adapter missing for $lane/$agent: $source" >&2
    failures=$((failures + 1))
    continue
  fi

  expected_destinations="${expected_destinations}${destination}"$'\n'
  if [ "$CHECK_ONLY" = true ]; then
    if [ ! -L "$destination_path" ]; then
      echo "missing: $destination" >&2
      failures=$((failures + 1))
    elif [ "$(readlink "$destination_path")" != "$source_path" ]; then
      echo "mismatch: $destination does not point to $source" >&2
      failures=$((failures + 1))
    else
      installed=$((installed + 1))
    fi
  else
    if [ -e "$destination_path" ] || [ -L "$destination_path" ]; then
      if [ -L "$destination_path" ]; then
        existing_target="$(readlink "$destination_path")"
        if [ "$existing_target" = "$source_path" ]; then
          installed=$((installed + 1))
          continue
        fi
        case "$existing_target" in
          "$ROOT_DIR"/adapters/*/agents/*) ;;
          *)
            echo "collision: $destination is an unmanaged symlink; remove it explicitly before installing" >&2
            failures=$((failures + 1))
            continue
            ;;
        esac
      else
        echo "collision: $destination already exists and is not a managed symlink" >&2
        failures=$((failures + 1))
        continue
      fi
    fi
    mkdir -p "$(dirname "$destination_path")"
    ln -sfn "$source_path" "$destination_path"
    installed=$((installed + 1))
  fi
done <<< "$rows"

is_expected_destination() {
  candidate="$1"
  while IFS= read -r expected; do
    [ "$candidate" = "$expected" ] && return 0
  done <<< "$expected_destinations"
  return 1
}

for lane_name in claude codex cursor; do
  [ "$LANE" = "all" ] || [ "$LANE" = "$lane_name" ] || continue
  agent_dir="$TARGET_PROJECT/.$lane_name/agents"
  [ -d "$agent_dir" ] || continue
  for link in "$agent_dir"/*; do
    [ -L "$link" ] || continue
    link_target="$(readlink "$link")"
    case "$link_target" in
      "$ROOT_DIR"/adapters/*/agents/*)
        relative_destination=".${lane_name}/agents/$(basename "$link")"
        if ! is_expected_destination "$relative_destination"; then
          if [ "$CHECK_ONLY" = true ]; then
            echo "stale: $relative_destination" >&2
            failures=$((failures + 1))
          else
            rm -f "$link"
          fi
        fi
        ;;
    esac
  done
done

if [ "$failures" -gt 0 ]; then
  echo "Named-agent operation failed with $failures issue(s)." >&2
  exit 1
fi

if [ "$CHECK_ONLY" = true ]; then
  echo "Named-agent check passed for $installed installation(s) in $TARGET_PROJECT."
else
  echo "Installed $installed named-agent adapter(s) into $TARGET_PROJECT."
fi
