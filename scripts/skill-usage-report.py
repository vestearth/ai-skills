#!/usr/bin/env python3
"""Count how agents actually use ai-skills, from their own session transcripts.

Read-only. Stdlib only. Needs bash + jq only for the Claude keyword-row replay.

  scripts/skill-usage-report.py                       # all agents, all time
  scripts/skill-usage-report.py --since 2026-09-30    # after the cadence change
  scripts/skill-usage-report.py --until 2026-09-29    # before it
  scripts/skill-usage-report.py --agent claude --no-replay   # skip the slow keyword replay

--since/--until are inclusive UTC dates (transcript timestamps are UTC; Bangkok
is UTC+7). Compare two windows to see whether a routing change moved anything. Numbers are
counts of what happened, not a quality judgment; a skill call is not evidence the
work was better, and no call is not evidence it was worse.

Known limits (each one bit a real measurement, 2026-09-30):
  * Claude: only main-thread turns count (subagent sidechains are skipped). A turn
    is "hooked" if the routing hook's additionalContext was attached to it.
  * Claude keyword rows are REPLAYED with the current hook against past prompts,
    so they show what today's rows would do, not what the old hook showed.
  * Codex: since ~Aug 2026 tool calls are `custom_tool_call` with an `input`
    field, not `function_call` with `arguments`. Reading only the old form
    reports a false zero. Both are read here.
  * Codex/Cursor sessions are largely runner/subagent sessions whose first prompt
    names skills; they are not comparable to interactive Claude use.
  * Cursor: a SKILL.md path on the assistant side is counted; reads and mentions
    are not separated. Low confidence.
"""
import argparse
import collections
import glob
import json
import os
import re
import subprocess
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
HOOK = os.path.join(ROOT, "adapters/claude/hooks/skill-routing.sh")
SKILL_PATH = re.compile(r"skills/([a-z0-9-]+)/SKILL\.md")
READ_CMD = re.compile(r"\b(cat|sed|head|nl|rg|less|read|readFile)\b")


def ai_skills():
    return {d for d in os.listdir(os.path.join(ROOT, "skills"))
            if os.path.isfile(os.path.join(ROOT, "skills", d, "SKILL.md"))}


def core_intent_skills(known):
    """Skills named in the hook's always-on core block (derived, not hardcoded)."""
    src = open(HOOK, encoding="utf-8").read()
    block = src.split('ctx="[ai-skills routing]', 1)[1].split("[ai-skills rules]", 1)[0]
    return {n for n in re.findall(r"[a-z][a-z0-9-]+", block) if n in known}


def in_window(ts, since, until):
    day = (ts or "")[:10]
    if not day:
        return since is None and until is None
    return (since is None or day >= since) and (until is None or day <= until)


def pct(n, d):
    return "%.1f%%" % (100.0 * n / d) if d else "n/a"


# ---------------------------------------------------------------- Claude

def claude_text(content):
    if isinstance(content, str):
        s = content
    else:
        s = " ".join(x.get("text", "") for x in content
                     if isinstance(x, dict) and x.get("type") == "text")
    return re.sub(r"<system-reminder>.*?</system-reminder>", "", s, flags=re.S).strip()


def claude_turns(base, since, until):
    turns = []
    for f in sorted(glob.glob(os.path.join(base, "*.jsonl"))):
        sid, cur = os.path.basename(f)[:8], None
        for line in open(f, errors="ignore"):
            try:
                o = json.loads(line)
            except ValueError:
                continue
            if o.get("isSidechain"):
                continue
            t = o.get("type")
            if t == "attachment":
                if cur and "[ai-skills routing]" in json.dumps(o["attachment"], ensure_ascii=False):
                    cur["hooked"] = True
            elif t == "user":
                m = o.get("message", {}).get("content")
                if isinstance(m, list) and any(isinstance(x, dict) and x.get("type") == "tool_result" for x in m):
                    continue
                p = claude_text(m)
                if not p:
                    continue
                cur = {"sid": sid, "ts": o.get("timestamp"), "prompt": p, "skills": [], "hooked": False}
                if in_window(cur["ts"], since, until):
                    turns.append(cur)
                else:
                    cur = None
            elif t == "assistant" and cur:
                for x in o.get("message", {}).get("content", []) or []:
                    if isinstance(x, dict) and x.get("type") == "tool_use" and x.get("name") == "Skill":
                        cur["skills"].append(x["input"].get("skill"))
    return turns


def replay_keyword_rows(prompt):
    """Domain rows the CURRENT hook would emit for this prompt (no session_id)."""
    out = subprocess.run(["bash", HOOK], input=json.dumps({"prompt": prompt}),
                         capture_output=True, text=True).stdout
    try:
        ctx = json.loads(out)["hookSpecificOutput"]["additionalContext"]
    except (ValueError, KeyError):
        return []
    parts = ctx.split("domain skill ที่ keyword ตรงกับ prompt นี้:")
    return re.findall(r"^  ([a-z0-9-]+) —", parts[1], flags=re.M) if len(parts) > 1 else []


def report_claude(since, until, replay=True):
    base = os.path.expanduser("~/.claude/projects/-Users-earth-Documents-GitHub/")
    known = ai_skills()
    core = core_intent_skills(known)
    turns = claude_turns(base, since, until)
    hooked = [t for t in turns if t["hooked"]]
    print("== Claude  (%d turns, %d hooked, %d sessions with a hook)" %
          (len(turns), len(hooked), len({t["sid"] for t in hooked})))
    if not hooked:
        return
    tn = [t for t in hooked if t["prompt"].lstrip().startswith("<task-notification")]
    print("task-notification turns: %d (%s of hooked), skill calls in them: %d" %
          (len(tn), pct(len(tn), len(hooked)), sum(len(t["skills"]) for t in tn)))

    calls = collections.Counter(s for t in turns for s in t["skills"] if s in known)
    print("ai-skills calls (all turns in window, hooked or not): %d  %s" % (sum(calls.values()), dict(calls.most_common(12))))
    ci = [t for t in hooked if set(t["skills"]) & core]
    print("hooked turns with an intent-routed (core block) skill call: %d of %d (%s)" %
          (len(ci), len(hooked), pct(len(ci), len(hooked))))
    cc = collections.Counter(s for t in hooked for s in t["skills"] if s in core)
    print("  per skill: %s" % dict(cc.most_common()))
    print("  core-block skills never called: %s" % sorted(core - set(cc)))

    by = collections.defaultdict(list)
    for t in hooked:
        if not t["prompt"].lstrip().startswith("<task-notification"):
            by[t["sid"]].append(t)
    bucket = collections.OrderedDict((b, [0, 0]) for b in ("1st", "2-3", "4-10", "11+"))
    for ts in by.values():
        for i, t in enumerate(ts):
            b = "1st" if i == 0 else "2-3" if i < 3 else "4-10" if i < 10 else "11+"
            bucket[b][1] += 1
            bucket[b][0] += bool(set(t["skills"]) & core)
    print("intent-skill call rate by turn position in session: " +
          ", ".join("%s %s (%d/%d)" % (b, pct(n, d), n, d) for b, (n, d) in bucket.items()))

    if not replay:
        return
    hits, used = collections.Counter(), collections.Counter()
    for t in hooked:
        if t["prompt"].startswith("/") or t["prompt"].lstrip().startswith("<task-notification"):
            continue
        for row in replay_keyword_rows(t["prompt"]):
            hits[row] += 1
            used[row] += row in t["skills"]
    print("keyword rows (replayed with current hook): row  hits  called-in-same-turn")
    for row, n in hits.most_common():
        print("  %-34s %4d %4d" % (row, n, used[row]))


# ----------------------------------------------------------------- Codex

def report_codex(since, until):
    known = ai_skills()
    files = (glob.glob(os.path.expanduser("~/.codex/sessions/**/*.jsonl"), recursive=True) +
             glob.glob(os.path.expanduser("~/.codex/archived_sessions/**/*.jsonl"), recursive=True))
    months = collections.defaultdict(lambda: [0, 0])
    per = collections.Counter()
    for f in files:
        reads, start, ntool = set(), None, 0
        for line in open(f, errors="ignore"):
            try:
                o = json.loads(line)
            except ValueError:
                continue
            p = o.get("payload") if isinstance(o.get("payload"), dict) else {}
            if o.get("type") == "session_meta":
                start = o.get("timestamp") or ""
            if o.get("type") != "response_item" or p.get("type") not in ("function_call", "custom_tool_call"):
                continue
            ntool += 1
            a = p.get("arguments") or p.get("input") or ""
            if "SKILL.md" in a and READ_CMD.search(a):
                reads |= {s for s in SKILL_PATH.findall(a) if s in known}
        if ntool < 3 or not in_window(start, since, until):
            continue
        m = (start or "?")[:7]
        months[m][0] += 1
        months[m][1] += bool(reads)
        per.update(reads)
    total = sum(v[0] for v in months.values())
    print("== Codex  (%d substantive sessions, >=3 tool calls)" % total)
    for m in sorted(months):
        print("  %s  sessions %3d  with an ai-skills SKILL.md read %3d (%s)" %
              (m, months[m][0], months[m][1], pct(months[m][1], months[m][0])))
    print("  reads per skill (sessions): %s" % dict(per.most_common(12)))


# ---------------------------------------------------------------- Cursor

def report_cursor(since, until):
    import time
    known = ai_skills()
    files = glob.glob(os.path.expanduser("~/.cursor/projects/*/agent-transcripts/**/*.jsonl"), recursive=True)
    total = with_path = 0
    per = collections.Counter()
    for f in files:
        day = time.strftime("%Y-%m-%d", time.localtime(os.path.getmtime(f)))
        if not in_window(day, since, until):
            continue
        total += 1
        seen = set()
        for line in open(f, errors="ignore"):
            try:
                o = json.loads(line)
            except ValueError:
                continue
            if o.get("role") == "user":
                continue
            c = o.get("message", {}).get("content", [])
            for x in c if isinstance(c, list) else []:
                seen |= {s for s in SKILL_PATH.findall(json.dumps(x, ensure_ascii=False)) if s in known}
        with_path += bool(seen)
        per.update(seen)
    print("== Cursor  (%d transcripts by mtime; assistant-side SKILL.md path, reads not separated from mentions)" % total)
    print("  with a path: %d (%s)  %s" % (with_path, pct(with_path, total), dict(per.most_common(8))))


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--agent", choices=["claude", "codex", "cursor", "all"], default="all")
    ap.add_argument("--since", help="inclusive YYYY-MM-DD")
    ap.add_argument("--until", help="inclusive YYYY-MM-DD")
    ap.add_argument("--no-replay", action="store_true",
                    help="skip replaying the hook's keyword rows (~1 min for ~1000 prompts)")
    a = ap.parse_args()
    if not os.path.isfile(HOOK):
        sys.exit("hook not found: %s" % HOOK)
    print("window: %s .. %s\n" % (a.since or "start", a.until or "now"))
    for name, fn in (("claude", report_claude), ("codex", report_codex), ("cursor", report_cursor)):
        if a.agent in (name, "all"):
            fn(a.since, a.until, **({"replay": not a.no_replay} if name == "claude" else {}))
            print()


if __name__ == "__main__":
    main()
