---
description: Implement an approved planning brief, write tests, and run quality gates.
---

Implement the following using the approved planning brief: $ARGUMENTS.

Use the appropriate implementer for the stack:
- If the change is clearly PHP-only, invoke @php-implementer.
- If the change is clearly JS/TS-only, invoke @javascript-implementer and expect React/Vue work to use the matching framework skill.
- If the change is clearly Python-only, invoke @python-implementer.
- If the change is clearly Go-only, invoke @go-implementer.
- Otherwise invoke @implementer.

Constraints:
- Follow the brief exactly; no scope creep.
- Obey `.github/instructions/code-quality.instructions.md`, `.github/instructions/testing.instructions.md`, and `.github/instructions/security.instructions.md`.
- Write tests in the same change.
- Run quality gates make-first, falling back to direct commands only when no target exists.
- Target about 100 changed LOC. Split otherwise.
- Do not self-review. Stop when the implementation is complete and gates are green.

Return the implementation report as defined in the chosen implementer agent.