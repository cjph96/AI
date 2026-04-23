---
description: Canonical contract for the orchestrator + subagent loop. Applies to orchestrator and all agents that participate in the loop.
applyTo: "**/*.agent.md,**/*.chatmode.md"
---

# Orchestration Loop

The orchestrator-subagent pattern used across this repo.

## Roles

| Role | Writes code? | Edits files? | Output |
|------|--------------|--------------|--------|
| Orchestrator | No | No | Delegation + final report |
| Research planner | No | No | Planning brief (Markdown) |
| Implementer | Yes | Yes | Code + tests + quality-gate report |
| Code reviewer | No | No | `APPROVED` / `CHANGES REQUIRED` with file:line issues |
| Test reviewer | No | No | Test-quality verdict |
| QA tester | No | No | Pass/fail per scenario with evidence |

## Canonical loop

```
1. Scope       (orchestrator)
2. Plan        (research-planner)  ──► brief
3. Confirm     (user, unless autonomous mode)
4. Implement   (implementer)       ──► diff + gate report
5. Review      (code-reviewer)     ──► verdict
6. If CHANGES REQUIRED → back to Implementer with the review; re-review.
   Loop hard-cap: 3 iterations, then escalate to the user.
7. Report      (orchestrator)
```

## Delegation format

Every delegation message must contain:

1. **Context** — goal, constraints, relevant files.
2. **Task** — a single imperative instruction.
3. **Expected output shape** — brief / diff summary / verdict.

## Verdict format (reviewers)

- **APPROVED** requires zero blockers and zero majors.
- **CHANGES REQUIRED** otherwise.
- Severity order: Blocker > Major > Minor > Nit.

## Stop conditions

Any agent must stop and surface the situation to the orchestrator when:

- A required instruction file is missing.
- The diff exceeds ~100 LOC without a clear split plan.
- A quality gate fails for reasons outside the planned scope.
- The implementation would need a change not in the brief.

## Language

- Code, file names, commits, identifiers → **English**.
- Conversational replies to the user → match the user's language.
- Reports and briefs → **English** unless the user specified otherwise.
