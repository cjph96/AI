---
description: Generate a unit test for a given file following project conventions.
---

Generate a unit test that covers the class or module in file $ARGUMENTS.

Use the appropriate implementer for the stack:
- If the target file is PHP, invoke @php-implementer.
- If the target file is JS/TS/Vue, invoke @javascript-implementer.
- Otherwise invoke @implementer.

Rules:
- Use the project's existing test runner and mirror its conventions.
- Follow `.github/instructions/testing.instructions.md`.
- If the file is PHP, additionally follow `.github/instructions/php-testing.instructions.md`.
- If the file is JS, TS, or Vue, additionally follow `.github/instructions/javascript-testing.instructions.md`.
- Place the test file at the conventional location for the project.
- Mock all collaborators; no real I/O, clock, or randomness.
- Cover the happy path and at least one error or boundary path per public behavior.
- Name tests per the convention in the language-specific instruction file.

Return the path of the new test file and a summary of the scenarios it covers.