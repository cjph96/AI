---
name: javascript-package-selection
description: >
  Selects JavaScript and TypeScript dependencies with a framework-first, runtime-aware
  decision process. Use when a JS/TS task needs a new package, state library, schema
  validator, test tool, or frontend platform choice. Do not use when the dependency is
  already mandated or when the task is pure implementation with no selection tradeoff.
---

# Skill: JavaScript Package Selection

## Trigger

Use when the task needs a package or ecosystem choice in JavaScript, TypeScript, React, Vue, or Vite-centered projects.

Do not use when the repository already standardizes the dependency or when the task is only about running existing tools.

## Actions

1. Detect the current ecosystem from `package.json`, lockfiles, and framework config:
   - package manager
   - framework and meta-framework
   - existing state, data, testing, and styling libraries
2. If the detected framework is React, add `javascript-react-foundations` to the active skill sequence. If it is Vue, add `javascript-vue-foundations`.
3. Prefer what the repository already uses before adding anything new.
4. Apply these decision defaults unless the repo already standardizes otherwise:
   - runtime schema validation → `zod`
   - React server state and caching → `@tanstack/react-query`
   - React lightweight shared client state → `zustand`
   - Vue shared state → `pinia`
   - Vue meta-framework for SSR or convention-heavy delivery → `nuxt`
   - greenfield browser build tool → `vite`
   - Vite-native unit and integration tests → `vitest`
   - end-to-end browser tests → `playwright`
   - utility-first styling → `tailwindcss`
   - copy-in React UI primitives → `shadcn/ui` only when the team is comfortable owning the copied code
5. Reject additions that duplicate an existing capability or fight the active framework.
6. Summarize the recommendation with one primary choice, one fallback, and the main tradeoff.

## References

- `doc/typescript.md`
- `doc/javascript.md`
- `doc/javascript-tooling.md`
- `doc/javascript-architecture.md`
- `.claude/skills/javascript-react-foundations/SKILL.md`
- `.claude/skills/javascript-vue-foundations/SKILL.md`