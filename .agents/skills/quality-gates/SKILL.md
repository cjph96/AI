---
name: quality-gates
description: >
  Runs lint / format / static analysis / tests / build in deterministic order using Makefile
  targets first, direct commands as fallback. Emits a structured pass/fail report.
  Use when validating PR readiness or after an implementation.
  Do not use for implementing features or designing architecture.
---

This is a thin Codex compatibility wrapper for the canonical skill at `.github/skills/quality-gates/SKILL.md`.

When this skill is invoked:

1. Read `.github/skills/quality-gates/SKILL.md`.
2. Follow the canonical instructions there exactly.
3. Read any referenced files under `.github/skills/quality-gates/` as directed.
4. Do not invent behavior outside the canonical skill.