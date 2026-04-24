---
name: javascript-quality-tooling
description: >
  Runs and structures the modern JavaScript and TypeScript quality stack around linting,
  typechecking, unit tests, component tests, e2e, and build validation. Use when
  validating JS/TS work, tightening test coverage, or standardizing the workflow. Do not
  use for architecture design or dependency-choice tasks.
---

# Skill: JavaScript Quality Tooling

## Trigger

Use when the task needs JS/TS tests, typechecking, linting, formatting, or build workflow guidance.

Do not use for package-choice tasks or pure feature planning.

## Actions

1. Detect the active toolchain from `Makefile`, `package.json`, `tsconfig.json`, `eslint.config.*`, `.eslintrc*`, `biome.json*`, `prettier.config.*`, `vite.config.*`, `vitest.config.*`, `jest.config.*`, and `playwright.config.*`.
2. Prefer project commands in this order:
   - `make <target>`
   - package-manager script (`npm`, `pnpm`, `yarn`, or `bun`)
   - direct local binary
3. Establish the canonical workflow for the repo:
   1. formatting or lint check on the touched scope
   2. TypeScript typecheck when TS exists
   3. unit, hook, store, and component tests on the touched slice
   4. integration or mocked-network checks when the change crosses the data layer
   5. Playwright or equivalent e2e only when user-visible behavior changed
   6. build validation on the narrowest impacted target
4. Prefer MSW or the repository's network-mocking layer over direct `fetch` mocks.
5. Prefer fixes over suppressions, disabled rules, or `@ts-ignore`.
6. Report which tools are configured, which commands are canonical, and what failed or remains missing.

## References

- `.github/instructions/javascript.instructions.md`
- `.github/instructions/javascript-testing.instructions.md`
- `.github/instructions/testing.instructions.md`