---
name: research-planning
description: >
  Produces a structured planning brief for a feature or change, grounded in the actual codebase.
  Use before any implementation to align on scope, impacted files, new files, tests and open questions.
  Do not use for implementation or review tasks.
---

# Skill: Research Planning

## Trigger

Use when the user asks to:

- "plan / scope / design [feature]"
- "what would it take to add X?"
- "produce a brief for Y"

Do not use when the user wants code written or a review performed.

## Actions

1. Restate the goal in one sentence. List acceptance criteria.
2. Detect the stack: languages, frameworks, test runner, Makefile / package scripts.
3. Identify applicable instruction files (`.github/instructions/*.instructions.md` whose `applyTo` matches the likely impacted paths).
4. Search the repo for similar features and reusable abstractions (cite `path:line`).
5. List impacted existing files (path + change + reason).
6. List new files to create (path + purpose + pattern to follow).
7. Plan tests: layer (unit/integration/e2e), files, scenarios.
8. Propose an **implementation order** that keeps each step ≤ ~100 LOC.
9. List **open questions** — never invent answers.
10. Emit the brief in Markdown following the format in `references/brief-template.md`.

## References

- Brief template: `.github/skills/research-planning/references/brief-template.md`
- Research planner agent: `.github/agents/research-planner.agent.md`
