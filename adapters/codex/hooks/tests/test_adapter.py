#!/usr/bin/env python3
"""Run the Claude case tables through the proposed Codex payload adapter."""

import argparse
import importlib.util
import json
import subprocess
import sys
import tempfile
from pathlib import Path


HERE = Path(__file__).resolve().parent
ADAPTER = HERE.parent / "adapter.py"
CASES = HERE.parents[2] / "claude" / "hooks" / "tests"
spec = importlib.util.spec_from_file_location("codex_hook_adapter", ADAPTER)
adapter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(adapter)


def decoded(raw):
    return raw.replace("\\n", "\n").replace("\\\\", "\\")


def run(payload, noop):
    if noop:
        original = adapter.GUARDS.copy()
        adapter.GUARDS.update({key: Path("/usr/bin/true") for key in original})
        try:
            # A no-op guard returns success for every case. Suppress the adapter's
            # expected diagnostic output so the table comparison stays readable.
            return adapter.evaluate(payload)
        finally:
            adapter.GUARDS.update(original)
    result = subprocess.run([sys.executable, str(ADAPTER)], input=json.dumps(payload),
                            text=True, capture_output=True)
    return result.returncode


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--noop", action="store_true")
    args = parser.parse_args()
    passed = failed = 0
    workspace = "/Users/earth/Documents/GitHub"

    for line in (CASES / "android-guard-cases.txt").read_text().splitlines():
        if not line or line.startswith("#"):
            continue
        expected, kind, raw = line.split("\t", 2)
        value = decoded(raw)
        if kind == "path":
            tool_name = "apply_patch"
            tool_input = {"command": f"*** Begin Patch\n*** Update File: {value}\n*** End Patch"}
        else:
            tool_name = "Bash"
            tool_input = {"command": value}
        actual = run({"hook_event_name": "PreToolUse", "tool_name": tool_name,
                      "cwd": workspace, "tool_input": tool_input}, args.noop)
        ok = str(actual) == expected
        passed += ok
        failed += not ok
        print(f'{"ok  " if ok else "FAIL"} android exp={expected} got={actual} {kind} {value}')

    for line in (CASES / "env-guard-cases.txt").read_text().splitlines():
        if not line:
            continue
        expected, raw = line.split("\t", 1)
        value = decoded(raw)
        actual = run({"hook_event_name": "PreToolUse", "tool_name": "Bash",
                      "cwd": workspace, "tool_input": {"command": value}}, args.noop)
        ok = str(actual) == expected
        passed += ok
        failed += not ok
        print(f'{"ok  " if ok else "FAIL"} env exp={expected} got={actual} {value.splitlines()[0]}')

    for expected, path in ((2, ".env"), (2, ".env.local"), (0, ".env.example"),
                           (0, ".env.sample"), (0, ".env.template"), (0, ".env.dist")):
        actual = run({"hook_event_name": "PreToolUse", "tool_name": "apply_patch",
                      "cwd": workspace, "tool_input": {"command":
                      f"*** Begin Patch\n*** Add File: scratch/{path}\n*** End Patch"}}, args.noop)
        ok = actual == expected
        passed += ok
        failed += not ok
        print(f'{"ok  " if ok else "FAIL"} env-path exp={expected} got={actual} {path}')

    android = f"{workspace}/Games-Lab-Android"
    regressions = (
        ("absolute Android patch from home", "apply_patch", "/Users/earth",
         {"command": f"*** Begin Patch\n*** Update File: {android}/app/Main.kt\n*** End Patch"}),
        ("absolute Android Git command from tmp", "Bash", "/tmp",
         {"command": f"git -C {android} push"}),
        ("absolute .env write from tmp", "Bash", "/tmp",
         {"command": f"echo X=1 >> {workspace}/slip-api/.env"}),
    )
    for label, tool_name, cwd, tool_input in regressions:
        actual = run({"hook_event_name": "PreToolUse", "tool_name": tool_name,
                      "cwd": cwd, "tool_input": tool_input}, args.noop)
        ok = actual == 2
        passed += ok
        failed += not ok
        print(f'{"ok  " if ok else "FAIL"} regression exp=2 got={actual} {label}')

    with tempfile.TemporaryDirectory() as directory:
        link = Path(directory) / "android-link"
        link.symlink_to(android, target_is_directory=True)
        actual = run({"hook_event_name": "PreToolUse", "tool_name": "apply_patch",
                      "cwd": workspace, "tool_input": {"command":
                      f"*** Begin Patch\n*** Update File: {link}/app/Main.kt\n*** End Patch"}}, args.noop)
        ok = actual == 2
        passed += ok
        failed += not ok
        print(f'{"ok  " if ok else "FAIL"} regression exp=2 got={actual} symlink into Android')

    original = "hello\u200bworld\n".encode()
    cleaned = b"helloworld\n"
    with tempfile.TemporaryDirectory() as outside_dir, \
         tempfile.TemporaryDirectory(prefix=".codex-hook-post-", dir=workspace) as inside_dir:
        outside = Path(outside_dir) / "note.md"
        inside = Path(inside_dir) / "note.md"
        outside_link = Path(outside_dir) / "inside-link.md"
        inside_link = Path(inside_dir) / "outside-link.md"
        outside_link.symlink_to(inside)
        inside_link.symlink_to(outside)
        post_cases = (
            ("outside file stays byte-identical", outside, outside, workspace, original),
            ("inside file is cleaned from outside cwd", inside, inside, "/tmp", cleaned),
            ("outside symlink into workspace is cleaned", outside_link, inside, "/tmp", cleaned),
            ("inside symlink outside workspace stays byte-identical", inside_link, outside,
             workspace, original),
        )
        for label, target, actual_file, cwd, expected in post_cases:
            actual_file.write_bytes(original)
            actual = run({"hook_event_name": "PostToolUse", "tool_name": "apply_patch",
                          "cwd": cwd, "tool_input": {"command":
                          f"*** Begin Patch\n*** Update File: {target}\n*** End Patch"}}, args.noop)
            ok = actual == 0 and actual_file.read_bytes() == expected
            passed += ok
            failed += not ok
            print(f'{"ok  " if ok else "FAIL"} post-clean exit={actual} '
                  f'bytes={actual_file.read_bytes()!r} {label}')

    print(f"\n{passed} passed, {failed} failed")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
