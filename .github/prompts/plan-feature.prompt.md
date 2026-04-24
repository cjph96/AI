---
description: Produce a planning brief for a feature or change before any implementation.
---

Produce a planning brief for: ${input:goal}.

Constraints:
- Read-only. Do not modify any source file.
- Ground every decision in the actual repo. Cite `path:line` for each claim.
- Use the generic planner unless the change is clearly PHP- or JS/TS-specific — then use the matching specialist.
- Follow the format defined in `.github/agents/research-planner.agent.md`.

Delegate to:
- `research-planner` by default.
- `php-research-planner` if the change is PHP-only.
- `javascript-research-planner` if the change is JS/TS-only. When the stack is React or Vue, expect it to apply the matching framework skill.
- `python-research-planner` if the change is Python-only.
- `go-research-planner` if the change is Go-only.

Return the brief and stop. Do not start implementing.
