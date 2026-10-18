#!/usr/bin/env python3
"""Translate Codex tool-hook input for the existing Claude guard scripts."""

import json
import os
import re
import subprocess
import sys
from pathlib import Path


HOOKS = Path(__file__).resolve().parents[2] / "claude" / "hooks"
WORKSPACE = os.path.realpath("/Users/earth/Documents/GitHub")
GUARDS = {
    "android": HOOKS / "guard-android-write.sh",
    "env_bash": HOOKS / "guard-env-bash.sh",
    "env_write": HOOKS / "guard-env-write.sh",
    "clean": HOOKS / "clean-invisible-unicode.sh",
}
PATCH_PATH = re.compile(r"^\*\*\* (?:Add File|Update File|Delete File|Move to): (.+)$", re.M)


def source_hook(name, tool_input):
    payload = json.dumps({"tool_input": tool_input})
    return subprocess.run([str(GUARDS[name])], input=payload, text=True, capture_output=True)


def paths_for(tool_name, tool_input, cwd):
    if tool_name == "apply_patch":
        patch = tool_input.get("command")
        if not isinstance(patch, str):
            return None
        paths = PATCH_PATH.findall(patch)
    else:
        path = next((tool_input.get(k) for k in ("file_path", "notebook_path", "path")
                     if isinstance(tool_input.get(k), str)), None)
        paths = [path] if path else []
    if not paths:
        return None
    return [os.path.realpath(p if os.path.isabs(p) else os.path.join(cwd, p)) for p in paths]


def evaluate(payload):
    event = payload.get("hook_event_name")
    tool_name = payload.get("tool_name")
    tool_input = payload.get("tool_input")
    if not isinstance(tool_input, dict) or event not in ("PreToolUse", "PostToolUse"):
        print("Codex hook input is missing tool_input or hook_event_name", file=sys.stderr)
        return 2
    if tool_name == "Bash":
        if event == "PostToolUse":
            return 0
        command = tool_input.get("command", tool_input.get("cmd"))
        if not isinstance(command, str):
            print("Codex Bash hook input has no command", file=sys.stderr)
            return 2
        for guard in ("env_bash", "android"):
            result = source_hook(guard, {"command": command})
            if result.returncode:
                sys.stderr.write(result.stderr)
                return 2
        return 0

    cwd = payload.get("cwd") or os.getcwd()
    if not isinstance(cwd, str):
        print("Codex hook input has no valid cwd", file=sys.stderr)
        return 2
    paths = paths_for(tool_name, tool_input, cwd)
    if paths is None:
        if event == "PostToolUse":
            return 0
        print("Codex file hook input has no inspectable path", file=sys.stderr)
        return 2

    notices = []
    for path in paths:
        if event == "PostToolUse" and os.path.commonpath(
                (WORKSPACE, os.path.realpath(path))) != WORKSPACE:
            continue
        android = source_hook("android", {"file_path": path})
        if event == "PreToolUse":
            env = source_hook("env_write", {"file_path": path})
            for result in (android, env):
                if result.returncode:
                    sys.stderr.write(result.stderr)
                    return 2
        elif android.returncode == 0 and source_hook("env_write", {"file_path": path}).returncode == 0:
            clean = source_hook("clean", {"file_path": path})
            if clean.returncode == 0 and clean.stdout:
                try:
                    notice = json.loads(clean.stdout)["hookSpecificOutput"]["additionalContext"]
                    notices.append(notice)
                except (KeyError, TypeError, ValueError):
                    pass
    if notices:
        print(json.dumps({"hookSpecificOutput": {
            "hookEventName": "PostToolUse", "additionalContext": "\n".join(notices)
        }}))
    return 0


if __name__ == "__main__":
    try:
        sys.exit(evaluate(json.load(sys.stdin)))
    except (ValueError, TypeError):
        print("Codex hook input is not valid JSON", file=sys.stderr)
        sys.exit(2)
