---
name: orchestration-loop
description: >
  Runs the research → implement → review loop end-to-end through specialist subagents.
  Use when the user asks to deliver, build, implement, fix, or refactor a feature or bug.
  Do not use for single-file lookups, explanations, or read-only analysis.
---

This is a thin Codex compatibility wrapper for the canonical skill at `.github/skills/orchestration-loop/SKILL.md`.

When this skill is invoked:

1. Read `.github/skills/orchestration-loop/SKILL.md`.
2. Follow the canonical instructions there exactly.
3. Read any referenced files under `.github/skills/orchestration-loop/` as directed.
4. Do not invent behavior outside the canonical skill.