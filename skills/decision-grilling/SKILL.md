---
name: decision-grilling
description: Use when a plan, design, architecture choice, rollout, or implementation approach needs deliberate stress-testing before work begins.
---

# Decision Grilling

## Use When

- The user asks to grill, stress-test, pressure-test, or challenge a plan or design.
- A decision has unclear ownership, dependencies, rollout risk, or acceptance criteria.
- A proposed implementation may hide assumptions that should be resolved before coding.
- A plan needs one-question-at-a-time interrogation instead of a broad review summary.

## Do Not Use When

- The user wants direct implementation and the plan is already decision-complete.
- The question is a normal architecture review; use `tech-lead-review` unless an interview-style loop is requested.
- The answer can be proven entirely from source, tests, logs, or config without asking the user.
- The work is active debugging; use `debugging` first.

## Goal

Turn an uncertain plan into explicit decisions by resolving one material question at a time, using repository evidence whenever it can answer the question.

## Required Inputs

- The plan, design, proposal, or decision being tested.
- Known constraints, success criteria, owners, deadlines, risks, and rollout expectations.
- Relevant repository files, docs, tests, configs, or artifacts when a question is discoverable.

## Process

1. State the decision under test and the current known constraints.
2. Identify the highest-risk unresolved branch: ownership, contract, data, dependency, rollout, verification, or user impact.
3. If the branch can be answered from the repository or existing artifacts, inspect them before asking.
4. Ask exactly one material question at a time and include the recommended answer.
5. Wait for the user's answer before moving to the next question.
6. Record each locked decision and any assumptions that remain.
7. Stop when the plan has clear scope, owners, tradeoffs, acceptance criteria, verification, and rollback or deferral rules.

## Output Format

- Decision under test
- Locked decisions
- Current question
- Recommended answer
- Remaining unresolved branches
- Final decision summary when the grilling loop ends

## Anti-patterns

- Asking several questions at once.
- Asking the user for facts that can be found in the repository.
- Treating interrogation as approval; unresolved risks must remain visible.
- Continuing after the plan is already decision-complete.
- Turning a focused grilling session into a broad design rewrite.
