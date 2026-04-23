---
description: Implement an approved planning brief, write tests, run quality gates.
---

Implement the following using the approved planning brief: ${input:brief}.

Constraints:
- Follow the brief exactly; no scope creep.
- Obey `.github/instructions/code-quality.instructions.md`, `.github/instructions/testing.instructions.md`, `.github/instructions/security.instructions.md`.
- Write tests in the same change.
- Run quality gates `make`-first; fall back to direct commands only when no target exists.
- Target ≤ ~100 changed LOC. Split otherwise.
- Do not self-review. Stop when the implementation is complete and gates are green.

Delegate to:
- `implementer` by default.
- `php-implementer` for PHP-only changes.
- `javascript-implementer` for JS/TS-only changes.

Return the implementation report as defined in the chosen implementer agent.
