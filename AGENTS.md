# AGENTS.md

Top-level agent catalog. This file is the canonical cross-tool baseline: an official **rules file for OpenCode, Cursor, and Codex**, an **always-on instructions source for GitHub Copilot**, and a source imported by `CLAUDE.md` for Claude Code.

> Tool-specific adapters live in:
> - [.github/](.github/) — GitHub Copilot (VS Code) native format.
> - [.claude/](.claude/) — Claude Code native format.
> - [.cursor/](.cursor/) — Cursor-native project rules that point to canonical instructions.
> - [.opencode/](.opencode/) — OpenCode native format.
> - [.codex/](.codex/) — Codex native custom agents.
> - [.agents/](.agents/) — Codex-native skill discovery wrappers.
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

When the installer includes `php:laravel`, the workspace gains Laravel-specific framework instructions and testing guidance on top of the base PHP specialists.

### JavaScript / TypeScript specialists

| Agent | Scope |
|-------|-------|
| `javascript-research-planner` | Modern JS/TS, React/Vue, state, routing. |
| `javascript-implementer` | Implements TS/JS following module & component conventions. |
| `javascript-code-reviewer` | TS strictness, component architecture, hooks/composables, accessibility. |

### Python specialists

| Agent | Scope |
|-------|-------|
| `python-research-planner` | Python services, libraries, CLIs, and framework planning briefs. |
| `python-implementer` | Implements Python changes with typing, tooling, and tests. |
| `python-code-reviewer` | Typing, boundary validation, security, and test quality. |

### Go specialists

| Agent | Scope |
|-------|-------|
| `go-research-planner` | Go services, packages, handlers, and CLI planning briefs. |
| `go-implementer` | Implements Go changes with package, error, and test discipline. |
| `go-code-reviewer` | Package design, errors, concurrency, security, and tests. |

Canonical bodies for each agent live in [.github/agents/](.github/agents/). Claude Code and OpenCode wrappers delegate to those bodies via `Read` on session start. Cursor does not currently have a documented equivalent repository file format for custom agents, so its adaptation layer uses `AGENTS.md`, `.cursor/rules/`, and shared skills instead. Codex uses `.codex/agents/` wrappers that read the canonical body rather than duplicating it.

## Canonical workflow

```
Scope → Plan → (PAUSE for user) → Implement → Review → (fix loop) → Report
```

Documented in [.github/instructions/orchestration-loop.instructions.md](.github/instructions/orchestration-loop.instructions.md).

## Skills quick index

Canonical skills in [.github/skills/](.github/skills/), mirrored to [.claude/skills/](.claude/skills/) so Claude Code, OpenCode, and Cursor can discover them through their documented compatibility paths, and projected through [.agents/skills/](.agents/skills/) so Codex can discover them through its native repository path.

For Claude/OpenCode shared resources, keep `.claude/skills/` self-contained: references and assets used by those skills should resolve inside `.claude/skills/`, and `.opencode/skills/` should only be introduced when OpenCode behavior must genuinely diverge from Claude.

| Skill | Purpose |
|-------|---------|
| `orchestration-loop` | Runs the research-implement-review loop end-to-end. |
| `research-planning` | Produces a structured planning brief. |
| `skill-selection` | Chooses the smallest applicable skill or skill sequence before execution. |
| `javascript-foundations` | Applies modern JS/TS defaults for modules, state, and boundary-safe typing. |
| `javascript-package-selection` | Chooses JS/TS ecosystem dependencies with React/Vue/Vite-aware tradeoffs. |
| `javascript-quality-tooling` | Structures lint, typecheck, test, e2e, and build workflows for JS/TS repos. |
| `javascript-react-foundations` | Applies React-specific component, hook, and state defaults after framework detection. |
| `javascript-vue-foundations` | Applies Vue 3, Pinia, and Nuxt-specific component and composable defaults. |
| `php-foundations` | Applies modern PHP 8.x standards, PSR alignment, and Composer-aware structure. |
| `php-package-selection` | Chooses Composer dependencies with framework-aware tradeoffs. |
| `php-quality-tooling` | Structures PHPUnit or Pest, PHPStan, PHP CS Fixer, and Rector workflows. |
| `laravel-package-selection` | Chooses Laravel-first or Spatie-backed solutions before broader package search. |
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
- `laravel.instructions.md`, `laravel-testing.instructions.md` — optional Laravel layer, installed only when `php:laravel` is selected.
- `symfony.instructions.md`, `symfony-testing.instructions.md` — optional Symfony layer, installed only when `php:symfony` is selected.
- `javascript.instructions.md`, `javascript-testing.instructions.md` — TS strict, Vitest/Jest, MSW.
- `python.instructions.md`, `python-testing.instructions.md` — Python typing, module design, pytest conventions.
- `go.instructions.md`, `go-testing.instructions.md` — Go package design, error handling, table-driven tests.

OpenCode loads these via the `instructions` field in [opencode.json](opencode.json). Claude Code loads them via `@`-imports in [CLAUDE.md](CLAUDE.md). GitHub Copilot activates them automatically per the `applyTo` glob. Cursor maps them through thin `.cursor/rules/*.mdc` wrappers that point back to the canonical instruction files. Codex reads this file directly and uses `.codex/agents/` plus `.agents/skills/` as its native projections.

## Language and style

- Code, file names, commit messages, identifiers → English.
- Conversational output to the user → match the user's language.
- No emojis unless the user asks for them.
