---
name: code-review
description: >
  Runs a five-axis code review (correctness, design, tests, security, readability) and returns
  APPROVED or CHANGES REQUIRED with file:line issues.
  Use before merge or after an implementer reports completion.
  Do not use to generate or modify code.
---

# Skill: Code Review

## Trigger

Use when the user asks to:

- "review this change / PR / diff"
- "is this ready to merge?"
- "check this code against our standards"

Do not use to write fixes or refactors.

## Actions

1. Read the applicable instruction files:
   - `.github/instructions/code-quality.instructions.md`.
   - `.github/instructions/testing.instructions.md`.
   - `.github/instructions/security.instructions.md`.
   - Any stack-specific file (`php*.instructions.md`, `javascript*.instructions.md`) whose `applyTo` matches the diff.
2. Scope the diff — list files grouped by layer/module.
3. Apply the **five-axis** checklist:
   1. Correctness — edge cases, error paths, concurrency, contracts.
   2. Design — layering, coupling, naming, dependency direction.
   3. Tests — presence, layer, assertions, mocking policy.
   4. Security — OWASP Top 10, secrets, authz, input validation.
   5. Readability — intention-revealing names, dead code, comment quality.
4. Classify each issue as Blocker / Major / Minor / Nit and cite `path:line`.
5. Emit the verdict using `references/verdict-template.md`.

## Verdict rules

- **APPROVED** only when zero blockers and zero majors.
- **CHANGES REQUIRED** otherwise.
- Post-merge improvements go under "Follow-ups", not blockers.

## References

- Verdict template: `.github/skills/code-review/references/verdict-template.md`
- Code reviewer agent: `.github/agents/code-reviewer.agent.md`
