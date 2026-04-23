# AGENTS.md

Top-level agent catalog. This file is the canonical **rules file for OpenCode**, an **always-on instructions source for GitHub Copilot**, and is imported by `CLAUDE.md` for Claude Code. All three tools read this file for baseline context on this repository.

> Tool-specific adapters live in:
> - [.github/](.github/) — GitHub Copilot (VS Code) native format.
> - [.claude/](.claude/) — Claude Code native format.
> - [.opencode/](.opencode/) — OpenCode native format.
> - [opencode.json](opencode.json) — OpenCode config, loads the instruction files below.

## Operating principles

1. **Orchestrate multi-step work.** If the task spans more than a single file or touches production-critical areas, invoke the `orchestrator` agent instead of implementing directly.
2. **Respect the subagent contract.** Research agents never write code. Implementers never self-review. Reviewers never modify source — they report.
3. **Progressive disclosure.** Consult `SKILL.md` first; only read `references/` or `assets/` when instructed.
4. **Verify before declaring done.** Every completion needs evidence: tests passing, build output, quality-gate report.
5. **Small diffs.** Target ≤ ~100 changed lines per review cycle; split otherwise.

## Agent roster

### Orchestration

| Agent | When to invoke |
|-------|----------------|
| `orchestrator` | Any multi-step feature, bug-fix that requires research + implementation + review. Default entry point. |

### Generic specialists (prefer these)

| Agent | Role |
|-------|------|
| `research-planner` | Read-only exploration; produces a planning brief. |
| `implementer` | Writes code and tests following a planning brief. Runs quality gates. |
| `code-reviewer` | Five-axis review; returns `APPROVED` or `CHANGES REQUIRED` with file:line issues. |
| `test-reviewer` | Audits test quality (FIRST, AAA, coverage, mocking policy). |
| `qa-tester` | Functional and exploratory QA against acceptance criteria. |

### PHP specialists

| Agent | Scope |
|-------|-------|
| `php-research-planner` | PHP 8.x / Symfony / DDD-CQRS planning briefs. |
| `php-implementer` | Implements PHP following DDD/CQRS conventions. |
| `php-code-reviewer` | PSR-12, PHPStan, DDD layering, domain exceptions. |

Optional framework add-on:
When the installer includes `php:symfony`, the workspace also gains `symfony-research-planner`, `symfony-implementer`, and `symfony-code-reviewer` wrappers plus Symfony-specific skills and prompts.

### JavaScript / TypeScript specialists

| Agent | Scope |
|-------|-------|
| `javascript-research-planner` | Modern JS/TS, React/Vue, state, routing. |
| `javascript-implementer` | Implements TS/JS following module & component conventions. |
| `javascript-code-reviewer` | TS strictness, component architecture, hooks/composables, accessibility. |

Canonical bodies for each agent live in [.github/agents/](.github/agents/). Claude Code and OpenCode wrappers delegate to those bodies via `Read` on session start.

## Canonical workflow

```
Scope → Plan → (PAUSE for user) → Implement → Review → (fix loop) → Report
```

Documented in [.github/instructions/orchestration-loop.instructions.md](.github/instructions/orchestration-loop.instructions.md).

## Skills quick index

Canonical skills in [.github/skills/](.github/skills/), mirrored to [.claude/skills/](.claude/skills/) so Claude Code and OpenCode discover them.

| Skill | Purpose |
|-------|---------|
| `orchestration-loop` | Runs the research-implement-review loop end-to-end. |
| `research-planning` | Produces a structured planning brief. |
| `code-review` | Performs a five-axis review and returns a verdict. |
| `test-driven-development` | RED → GREEN → REFACTOR cycle. |
| `quality-gates` | Runs lint/static-analysis/tests in deterministic order. |
| `debugging` | Five-step triage: reproduce → localize → reduce → fix → guard. |

## Instruction files

Canonical instruction files live in [.github/instructions/](.github/instructions/) and use the `applyTo` glob frontmatter recognised by GitHub Copilot.

- `orchestration-loop.instructions.md` — orchestrator + subagent contract.
- `code-quality.instructions.md` — naming, functions, types, errors, deps, comments, size.
- `testing.instructions.md` — FIRST, AAA, layers, mocking, anti-patterns.
- `security.instructions.md` — OWASP Top 10 baseline.
- `git-workflow.instructions.md` — trunk-based, conventional commits, no force-push.
- `agent-skills-best-practices.instructions.md` — SKILL.md authoring standard.
- `php.instructions.md`, `php-testing.instructions.md` — PHP 8.x + DDD/CQRS + PHPUnit.
- `symfony.instructions.md`, `symfony-testing.instructions.md` — optional Symfony layer, installed only when `php:symfony` is selected.
- `javascript.instructions.md`, `javascript-testing.instructions.md` — TS strict, Vitest/Jest, MSW.

OpenCode loads these via the `instructions` field in [opencode.json](opencode.json). Claude Code loads them via `@`-imports in [CLAUDE.md](CLAUDE.md). GitHub Copilot activates them automatically per the `applyTo` glob.

## Language and style

- Code, file names, commit messages, identifiers → English.
- Conversational output to the user → match the user's language.
- No emojis unless the user asks for them.
