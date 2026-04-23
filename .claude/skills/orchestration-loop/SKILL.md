---
name: orchestration-loop
description: >
  Runs the research → implement → review loop end-to-end through specialist subagents.
  Use when the user asks to deliver, build, implement, fix, or refactor a feature or bug.
  Do not use for single-file lookups, explanations, or read-only analysis.
---

# Skill: Orchestration Loop

## Trigger

Use when the user asks to:

- "build / implement / deliver [feature]"
- "fix [bug] end-to-end"
- "take this ticket / issue to done"
- "refactor X with tests and review"

Do not use for:

- Read-only questions ("how does X work?").
- Pure research with no code output.
- Running quality gates in isolation — use `quality-gates` skill instead.

## Actions

1. Read the contract in `.github/instructions/orchestration-loop.instructions.md`.
2. Identify the stack from the repo (languages, frameworks, test runner, Makefile targets).
3. Select the specialist trio:
   - Generic → `research-planner` / `implementer` / `code-reviewer`.
   - PHP-heavy → `php-research-planner` / `php-implementer` / `php-code-reviewer`.
   - JS/TS-heavy → `javascript-research-planner` / `javascript-implementer` / `javascript-code-reviewer`.
4. Delegate **Plan**: ask the chosen research planner for a brief (see `.github/agents/research-planner.agent.md` for the format).
5. **Pause** and present the brief to the user. Wait for explicit confirmation — unless the user authorized autonomous execution.
6. Delegate **Implement** to the chosen implementer with the approved brief.
7. Delegate **Review** to the chosen reviewer.
8. If verdict is `CHANGES REQUIRED`, send the review to the implementer and re-run the reviewer. Cap at 3 iterations; after that, stop and escalate to the user.
9. Produce a **final report**: files changed, tests added, gate results, follow-ups, suggested PR title and description.

## Error handling

- Missing planning brief → stop and ask the research planner to produce one.
- Quality gate fails on unrelated code → stop and escalate; do not silently fix unrelated files.
- Diff > ~100 LOC and growing → stop and request a split plan from the research planner.
- Reviewer loop hits 3 iterations without `APPROVED` → stop; present the remaining issues to the user.

## References

- Contract: `.github/instructions/orchestration-loop.instructions.md`
- Orchestrator agent: `.github/agents/orchestrator.agent.md`
- Research planner agent: `.github/agents/research-planner.agent.md`
- Implementer agent: `.github/agents/implementer.agent.md`
- Code reviewer agent: `.github/agents/code-reviewer.agent.md`
