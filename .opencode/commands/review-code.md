---
description: Run a five-axis code review on the current change and return a verdict.
---

Review the change: $ARGUMENTS.

Use the appropriate reviewer for the stack:
- If the diff is clearly PHP-only, invoke @php-code-reviewer.
- If the diff is clearly JS/TS-only, invoke @javascript-code-reviewer.
- Otherwise invoke @code-reviewer.

Constraints:
- Read-only. Do not edit files.
- Cite every issue with `path:line` and a severity (Blocker / Major / Minor / Nit).
- Follow the format defined in `.github/agents/code-reviewer.agent.md`.
- APPROVED only when there are zero blockers and zero majors.

If the diff is mostly tests or touches test infrastructure, also invoke @test-reviewer.