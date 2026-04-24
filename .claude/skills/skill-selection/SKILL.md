---
name: skill-selection
description: >
  Selects the right repository skill or skill sequence for a task before implementation.
  Use when the next workflow is unclear, when multiple skills might apply, or when a task
  spans planning, implementation, testing, review, or documentation.
---

# Skill: Skill Selection

## Trigger

Use when:

- the user asks for work but the right starting workflow is unclear
- multiple skills could apply and ordering matters
- the task mixes planning, implementation, verification, review, or documentation

Do not use when:

- the user explicitly named the skill to apply
- the task is a trivial single-file lookup with no workflow choice to make

## Actions

1. Restate the user goal in one sentence.
2. Classify the request:
   - feature / implementation
   - bug / failure
   - review / audit
   - validation / gates
   - documentation / reporting
   - framework-specific Symfony work
3. Map the request to the smallest matching skill set:
   - feature or refactor → `orchestration-loop`
   - bug / unexpected behavior → `debugging` then `test-driven-development` when code changes are needed
   - quality validation only → `quality-gates`
   - PHP standards / structure choice → `php-foundations`
   - PHP package choice → `php-package-selection`
   - PHP testing / analysis / modernization → `php-quality-tooling`
   - JavaScript or TypeScript foundations / structure choice → `javascript-foundations`
   - JavaScript or TypeScript dependency choice → `javascript-package-selection`
   - JavaScript or TypeScript tooling / validation → `javascript-quality-tooling`
   - React component, hook, context, routing, or state architecture → base JS route + `javascript-react-foundations`
   - Vue 3 component, composable, Pinia, or Nuxt architecture → base JS route + `javascript-vue-foundations`
   - Laravel package or feature choice → `laravel-package-selection`
   - review only → `code-review`
   - planning only → `research-planning`
   - Symfony HTTP or persistence changes → add the relevant Symfony skill after the base workflow
4. If more than one skill applies, order them from discovery to execution to validation.
5. Check whether the chosen skills require nearby instruction files or framework detection before editing.
6. State the selected skill or sequence and then execute it.

## Decision table

| Task shape | Skill route |
|------------|-------------|
| Build, implement, deliver, refactor | `orchestration-loop` |
| Fix a failing behavior | `debugging` → `test-driven-development` |
| Plan or scope before coding | `research-planning` |
| PHP foundations or structure | `php-foundations` |
| PHP dependency choice | `php-package-selection` |
| PHP tooling or modernization | `php-quality-tooling` |
| JavaScript / TypeScript foundations or structure | `javascript-foundations` |
| JavaScript / TypeScript dependency choice | `javascript-package-selection` |
| JavaScript / TypeScript tooling or validation | `javascript-quality-tooling` |
| React component or hook architecture | base JS route + `javascript-react-foundations` |
| Vue component or composable architecture | base JS route + `javascript-vue-foundations` |
| Laravel package choice | `laravel-package-selection` |
| Review a diff or PR | `code-review` |
| Run lint, tests, build, or readiness checks | `quality-gates` |
| Symfony API Platform work | base route + `symfony-api-platform-resources` |
| Symfony Doctrine relation changes | base route + `symfony-doctrine-relations` |
| Symfony Messenger work | base route + `symfony-messenger` |
| Symfony voters / authz work | base route + `symfony-voters` |
| Symfony HTTP behavior changes | base route + `symfony-functional-tests` |

## Error handling

- If two routes seem equally valid, choose the narrower one that can still satisfy the request.
- If the task includes code changes plus review, start with the implementation route, not `code-review` alone.
- If no repository skill fits cleanly, fall back to the smallest direct workflow and report the gap in the final note.

## References

- `.claude/skills/orchestration-loop/SKILL.md`
- `.claude/skills/debugging/SKILL.md`
- `.claude/skills/javascript-foundations/SKILL.md`
- `.claude/skills/javascript-package-selection/SKILL.md`
- `.claude/skills/javascript-quality-tooling/SKILL.md`
- `.claude/skills/javascript-react-foundations/SKILL.md`
- `.claude/skills/javascript-vue-foundations/SKILL.md`
- `.claude/skills/php-foundations/SKILL.md`
- `.claude/skills/php-package-selection/SKILL.md`
- `.claude/skills/php-quality-tooling/SKILL.md`
- `.claude/skills/laravel-package-selection/SKILL.md`
- `.claude/skills/research-planning/SKILL.md`
- `.claude/skills/test-driven-development/SKILL.md`
- `.claude/skills/quality-gates/SKILL.md`
- `.claude/skills/code-review/SKILL.md`