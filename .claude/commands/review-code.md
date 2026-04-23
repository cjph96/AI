---
description: Run a five-axis code review on the current change and return a verdict.
---

Review the change: ${input:target}.

Constraints:
- Read-only. Do not edit files.
- Cite every issue with `path:line` and a severity (Blocker / Major / Minor / Nit).
- Follow the format defined in `.github/agents/code-reviewer.agent.md`.
- APPROVED only when there are zero blockers and zero majors.

Delegate to:
- `code-reviewer` by default.
- `php-code-reviewer` for PHP-only diffs.
- `javascript-code-reviewer` for JS/TS-only diffs.
- Add `test-reviewer` when the diff is mostly tests or touches test infrastructure.
