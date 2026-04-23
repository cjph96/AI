---
description: Diagnose and fix a reported bug with a regression test.
---

Fix the issue: $ARGUMENTS.

Use the appropriate implementer for the stack:
- If the issue is clearly PHP-only, invoke @php-implementer.
- If the issue is clearly JS/TS-only, invoke @javascript-implementer.
- Otherwise invoke @implementer.

Workflow:
1. Reproduce the bug with a failing test (unit or integration level, whichever is closest to the defect).
2. Localize the root cause and apply the minimal fix. Do not refactor unrelated code.
3. Confirm the new test passes and that the full suite still passes.
4. Run quality gates.
5. Report:
   - Root cause in one paragraph.
   - The failing test (file + name) as proof of reproduction.
   - Files changed.
   - Gate results.

After implementation, request a review from the matching reviewer (@php-code-reviewer, @javascript-code-reviewer, or @code-reviewer). If the change is mostly tests, also request @test-reviewer.