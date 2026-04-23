---
name: test-driven-development
description: >
  Drives implementation through a strict RED → GREEN → REFACTOR cycle.
  Use when implementing non-trivial logic or fixing any bug.
  Do not use for trivial wiring (DTO definitions, config files, constant updates).
---

# Skill: Test-Driven Development

## Trigger

Use when:

- Implementing business logic, algorithms, or domain rules.
- Fixing a bug — always start by reproducing it with a failing test.
- Adding a new public API.

Do not use for:

- Pure config / wiring.
- Generated code.
- One-line typo or copy fixes (still run tests, but TDD is overkill).

## Process

### RED — write a failing test
1. Decide the next **smallest** behavior to add.
2. Write a single test that asserts that behavior.
3. Run the test. **It must fail.** If it passes without the code change, the test is wrong — fix it.

### GREEN — make it pass
4. Write the **minimum** code required to make the test pass.
5. Resist adding behavior the test does not require.
6. Run all tests. All must pass.

### REFACTOR — improve the code
7. With all tests green, clean up the code: rename, extract, inline.
8. Run tests after each refactor.
9. Do not add new behavior in this phase.

### Commit
10. Commit after a green REFACTOR (atomic, one behavior).

## Anti-rationalizations

| Excuse | Counter |
|--------|---------|
| "I'll add tests after, the logic is simple." | Then the test is simple too — write it first. |
| "It's hard to test." | That is a design smell. The pain predicts future maintenance cost. |
| "The test mirrors the code." | Assert on observable behavior, not implementation. |
| "I need to ship fast." | TDD is faster over a day, not over a minute. |

## Red flags

- A test that passes the moment it is written without running the fail step.
- A test asserting `true === true` or trivial types.
- More setup than assertions.
- Mocking the type under test.
- Several new behaviors in one test.

## References

- Testing policy: `.github/instructions/testing.instructions.md`
- PHP specifics: `.github/instructions/php-testing.instructions.md`
- JS/TS specifics: `.github/instructions/javascript-testing.instructions.md`
