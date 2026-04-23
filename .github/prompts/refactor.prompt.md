---
description: Behavior-preserving refactor of a file or module.
---

Refactor the target: ${input:target}.

Constraints:
- **Behavior must not change.** The test suite must be green before and after.
- If tests do not cover the target adequately, add characterization tests first.
- Keep diffs small — prefer a sequence of small refactors over one large change.
- Follow `.github/instructions/code-quality.instructions.md`.
- Do not change public APIs unless the user explicitly asked for it. If a public API change is unavoidable, stop and surface it.

Process:
1. Snapshot the current test suite result.
2. Add missing characterization tests, if any.
3. Apply one refactor at a time (rename, extract, inline, move). Run tests after each.
4. Report the sequence of refactors with one line per step, plus the final diff summary.
