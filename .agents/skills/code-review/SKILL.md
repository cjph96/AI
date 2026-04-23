---
name: code-review
description: >
  Runs a five-axis code review (correctness, design, tests, security, readability) and returns
  APPROVED or CHANGES REQUIRED with file:line issues.
  Use before merge or after an implementer reports completion.
  Do not use to generate or modify code.
---

This is a thin Codex compatibility wrapper for the canonical skill at `.github/skills/code-review/SKILL.md`.

When this skill is invoked:

1. Read `.github/skills/code-review/SKILL.md`.
2. Follow the canonical instructions there exactly.
3. Read any referenced files under `.github/skills/code-review/` as directed.
4. Do not invent behavior outside the canonical skill.