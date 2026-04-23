---
description: Diagnose and fix a reported bug with a regression test.
---

Fix the issue: ${input:issue}.

Workflow:
1. Reproduce the bug with a failing test (unit or integration level, whichever is closest to the defect).
2. Localize the root cause — follow `.github/skills/debugging/SKILL.md`.
3. Apply the minimal fix. Do not refactor unrelated code.
4. Confirm the new test passes and that the full suite still passes.
5. Run quality gates.
6. Report:
   - Root cause in one paragraph.
   - The failing test (file + name) as proof of reproduction.
   - Files changed.
   - Gate results.

Delegate to the appropriate implementer (`implementer` / `php-implementer` / `javascript-implementer`). Then request a review.
