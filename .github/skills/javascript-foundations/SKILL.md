---
name: javascript-foundations
description: >
  Applies modern JavaScript and TypeScript foundations before planning or implementing
  framework-neutral JS/TS changes. Use when a task needs module boundaries, runtime-safe
  typing, state placement, or framework-aware defaults. Do not use for package-choice-only
  tasks or for lint/test execution in isolation.
---

# Skill: JavaScript Foundations

## Trigger

Use when the task asks to add, refactor, or review JS/TS code and the important question is the base shape of the solution.

Do not use for framework-specific package choice or quality-gate-only requests.

## Actions

1. Read `.github/instructions/javascript.instructions.md`, `.github/instructions/code-quality.instructions.md`, and `.github/instructions/security.instructions.md`.
2. Detect from `package.json`, `tsconfig.json`, and framework config files:
   - runtime and module format
   - active framework or absence of one
   - whether TypeScript is present and how strict it is
3. If the detected framework is React, add `javascript-react-foundations` to the active skill sequence. If it is Vue, add `javascript-vue-foundations`.
4. Confirm the code shape matches modern JS/TS defaults:
   - ES modules in new code
   - TypeScript strictness preserved when TS exists
   - `unknown` at boundaries, narrowed quickly
   - side effects isolated to framework hooks, adapters, or services
   - local state first, shared state only with a clear reason
5. Check that file names, path aliases, exports, hooks, composables, and store conventions match the repository before creating or moving files.
6. If the task becomes dependency-driven, hand off to `javascript-package-selection`.
7. If the task becomes tooling- or validation-driven, hand off to `javascript-quality-tooling`.
8. Return a short implementation checklist or decision summary before code is written.

## References

- `.github/instructions/javascript.instructions.md`
- `.github/instructions/code-quality.instructions.md`
- `.github/instructions/security.instructions.md`
- `doc/javascript.md`
- `doc/typescript.md`
- `.github/skills/javascript-react-foundations/SKILL.md`
- `.github/skills/javascript-vue-foundations/SKILL.md`