---
name: humanizer
description: Use when asked to make prose read less AI-written or more like a person wrote it (humanize, de-AI, เกลาภาษา, ลดสำนวน AI) for a draft, reply, README, PR body, doc, or post in English or Thai, keeping every fact, number, path, and technical term unchanged.
---

# Humanizer

Local wrapper around the upstream Humanizer pattern catalog
([blader/humanizer](https://github.com/blader/humanizer) 4.0.0, MIT). The catalog is kept
unmodified in [references/upstream-SKILL.md](references/upstream-SKILL.md). This file adds
the workspace contract: when to run it, what must never change, and Thai patterns the
upstream list does not cover. Where the two disagree, this file wins.

## Use When

- The user asks to humanize, de-AI, or naturalize text: "humanize this", "เกลาภาษา",
  "ทำให้อ่านเป็นธรรมชาติ", "ลดความเป็น AI", "อ่านแล้วเหมือน AI เขียน".
- A publishing task (README, docs page, PR body, release note, article, social post)
  explicitly asks for a humanized final text.
- The user wants a draft reviewed for AI writing tells without a rewrite
  ("ตรงไหนดูเป็น AI บ้าง").

## Do Not Use When

- Ordinary chat replies, status updates, or answers nobody asked to rewrite. This skill
  runs on demand, never on every response.
- The content is code, a code diff, or scaffolding; use `deslop`.
- The job is invisible Unicode, C2PA/EXIF/XMP, or generator metadata; use
  `remove-ai-marks` (run it after this skill when both apply before publishing).
- The text is evidence that must stay verbatim: logs, command output, quoted messages,
  error text, contracts, legal or policy wording, test assertions.
- The goal is to pass an AI detector. Never promise or imply that the result will.

## Goal

Return text that reads as if the writer wrote it for one reader, with every claim,
number, name, identifier, and caveat from the source intact.

## Required Inputs

- The text, or a file path (file mode changes prose only).
- The kind of text and its reader: thread reply, README, technical doc, post, essay.
  Infer it from context when it is obvious.
- The language. For Thai, also apply the Thai patterns below.
- An optional writing sample. A sample overrides catalog defaults (upstream "Voice").

## Process

1. Pick the mode from upstream "What to return": pasted, file, or embedded, plus
   review-only when no rewrite is wanted. Stop point: mode and language are named.
2. Read [references/upstream-SKILL.md](references/upstream-SKILL.md) in full before the
   first edit in a session. Stop point: §1 to §26 and "When not to act" have been read,
   not skimmed by heading.
3. Lock the invariants before rewriting: every number, date, amount, version, ID, error
   code, path, URL, command, API, field, function, product, or repository name, quoted
   string, citation, and verification caveat ("not tested", "ยังไม่ได้ตรวจ", "partial").
   Stop point: the invariant list exists (keep it to yourself unless asked).
4. Run upstream "How to work" steps 1 to 4 with these overrides:
   - Upstream step 2 allows adding a specific detail "you know to be true". Here, add a
     detail only when it appears in the source, the conversation, or evidence verified
     in this session. Otherwise write the simpler sentence or ask.
   - §8 dashes: in Thai, replace a dash with a space break or a rewrite, not an English
     comma.
   - §9 and §25: never cut a verification caveat, scope limit, or "not done" statement.
     Those change what the reader does next.
   - Leave inline code, code blocks, commands, paths, URLs, and YAML untouched in every
     mode, not only in file mode.
5. Check the final text against the invariant list. Every item must appear unchanged;
   translating a technical term counts as a change. Stop point: zero missing or altered
   invariants, or each change is reported to the user.
6. Return the result in the Output Format below.

### Thai patterns (local overlay)

Apply these alongside the upstream catalog. As upstream does for §1 to §5, one sighting
of T1 to T3 justifies an edit; T4 to T6 are weak alone and need company.

- T1. Title Case English common nouns inside a Thai sentence: "ปรับ Workflow ให้เข้ากับ
  Architecture", "เป็น Single Source of Truth", "รักษา Technical Terms". Lowercase the
  generic loanword or use the Thai word the writer uses. Keep real names (products,
  repositories, APIs, commands) exactly as written. Extends §20.
- T2. Staged labels and run-ups: "ข้อสรุป:", "ข้อควรเข้าใจคือ", "มีจุดสำคัญอย่างหนึ่งคือ",
  "สิ่งที่น่าสนใจคือ", "กล่าวโดยสรุป", "โดยสรุปแล้ว". State the point instead. Extends §2
  and §4.
- T3. Thai not-X-but-Y: "ไม่ใช่แค่...แต่ยัง...", "ไม่ใช่...แต่เป็น...", "ไม่ได้...แต่...".
  Apply the §1 test.
- T4. Stacked connectors: consecutive sentences opening with "นอกจากนี้", "อย่างไรก็ตาม",
  "ทั้งนี้", "ดังนั้น", or chained "ซึ่ง". Join the sentences or drop the connector.
- T5. Translationese: "ทำการ", "มีการ", "ได้รับการ", passive "ถูก" for neutral events,
  stacked "การ/ความ" nouns. Use the verb: "ทำการติดตั้ง" becomes "ติดตั้ง".
- T6. Inflation words: "ยกระดับ", "ขับเคลื่อน", "อย่างมีประสิทธิภาพ", "ครอบคลุม",
  "ตอบโจทย์", "เป็นสิ่งสำคัญอย่างยิ่ง", "ในยุคปัจจุบัน". Keep the fact and drop the dressing.
  Extends §12 and §13.

Polite particles (ครับ, ค่ะ, นะ) follow the writer's sample or the existing text. Do not
add or strip them as a fix.

## Output Format

- Pasted mode: the final rewrite, then a short list of the tells fixed (quoted, with
  §N or TN) and any tell left on purpose, with the reason. The draft from upstream
  step 2 stays internal; show it only when the user asks. This overrides upstream
  "Pasted text (default)", which returns the draft as well.
- Review-only: each tell quoted with its id (§N or TN); no rewrite.
- File mode: write only the final prose to the file, then report the sections reviewed,
  any not covered (a partial pass is reported as partial), and that invariants were
  checked.
- Embedded mode: the final text only.
- In every mode, name any invariant that had to change and why.

## Anti-patterns

- Running the skill on every reply or on text nobody asked to change.
- Adding facts, specifics, or color the source does not support to make text sound human.
- Translating, respelling, or "naturalizing" API names, field names, commands, paths, or
  error codes.
- Cutting verification caveats or "not tested" lines because they read as hedging.
- Editing `references/upstream-SKILL.md` to add local rules. Local rules go in this file;
  the reference stays byte-identical to the pinned upstream commit.
- Claiming the output will pass an AI detector.

## Upstream

- Source: `blader/humanizer` at commit `b48c832f0f809c1b5658edbb838c2521b72f2413`
  (release 4.0.0, 2026-11-10).
- License: MIT. The copyright and permission notice is in
  [references/LICENSE-humanizer](references/LICENSE-humanizer); keep it next to the
  reference file.
- To update: replace both reference files from the new commit, update the SHA and
  version here, check that the § numbers cited above still name the same patterns, then
  run `scripts/validate-skills.sh`.
