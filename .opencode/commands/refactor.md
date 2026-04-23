---
description: Behavior-preserving refactor of a file or module.
---

Refactor the target: $ARGUMENTS.

Use the appropriate implementer for the stack:
- If the target is clearly PHP-only, invoke @php-implementer.
- If the target is clearly JS/TS-only, invoke @javascript-implementer.
- Otherwise invoke @implementer.

Constraints:
- Behavior must not change. The test suite must be green before and after.
- If tests do not cover the target adequately, add characterization tests first.
- Keep diffs small. Prefer a sequence of small refactors over one large change.
- Follow `.github/instructions/code-quality.instructions.md`.
- Do not change public APIs unless explicitly requested. If a public API change is unavoidable, stop and surface it.

Process:
1. Snapshot the current test suite result.
2. Add missing characterization tests, if any.
3. Apply one refactor at a time and run tests after each.
4. Report the sequence of refactors with one line per step, plus the final diff summary.