---
description: Produce a planning brief for a feature or change before any implementation.
---

Produce a planning brief for: $ARGUMENTS.

Use the appropriate planner for the stack:
- If the change is clearly PHP-only, invoke @php-research-planner.
- If the change is clearly JS/TS-only, invoke @javascript-research-planner and expect React/Vue work to use the matching framework skill.
- If the change is clearly Python-only, invoke @python-research-planner.
- If the change is clearly Go-only, invoke @go-research-planner.
- Otherwise invoke @research-planner.

Constraints:
- Read-only. Do not modify any source file.
- Ground every decision in the actual repo. Cite `path:line` for each claim.
- Use the generic planner unless the change is clearly PHP- or JS/TS-specific, then use the matching specialist.
- Follow the format defined in `.github/agents/research-planner.agent.md`.

Return the brief and stop. Do not start implementing.