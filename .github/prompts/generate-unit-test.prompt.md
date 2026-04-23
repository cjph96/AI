---
description: Generate a unit test for a given file following project conventions.
---

Generate a unit test that covers the class / module in file ${input:file}.

Rules:
- Use the project's existing test runner (PHPUnit, Vitest, Jest…) and mirror its conventions.
- Follow `.github/instructions/testing.instructions.md`.
- If the file is PHP, additionally follow `.github/instructions/php-testing.instructions.md`.
- If the file is JS/TS/Vue, additionally follow `.github/instructions/javascript-testing.instructions.md`.
- Place the test file at the conventional location for the project.
- Mock all collaborators; no real I/O, clock, or randomness.
- Cover the happy path and at least one error / boundary path per public behavior.
- Name tests per the convention in the language-specific instruction file.

Return the path of the new test file and a summary of the scenarios it covers.
