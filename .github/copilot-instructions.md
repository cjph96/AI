# GitHub Copilot — Repository Instructions

These instructions are always loaded by GitHub Copilot (VS Code and github.com) for every chat request in this repository. They give Copilot the baseline context needed to help with planning, implementation, review and QA in this codebase.

Keep this file ≤ 2 pages and task-agnostic. Language-, framework- or path-specific rules live in [`.github/instructions/*.instructions.md`](instructions/) and are auto-applied by `applyTo` globs.

## What this repository is

A **multi-tool agent orchestration kit**. It defines a consistent research → plan → implement → review → report workflow that works across **GitHub Copilot (VS Code)**, **Claude Code**, **OpenCode**, and **Cursor**. There is no application code in this repo — only agent definitions, instructions, prompts and skills.

Top-level entry point for humans: [README.md](../README.md). Top-level entry point for agents: [AGENTS.md](../AGENTS.md).

## How work is done here

1. For any task that touches more than one file or requires planning, invoke the `orchestrator` custom agent (see [.github/agents/orchestrator.agent.md](agents/orchestrator.agent.md)). The orchestrator delegates to specialists and pauses for user approval before code is written.
2. Research is read-only. Implementers never self-review. Reviewers never modify source.
3. Each review cycle targets ≤ ~100 changed LOC. Split larger changes.
4. Completion requires evidence: quality gates green, tests passing, build output clean.

## Canonical layout Copilot should assume

```
.github/
  agents/       — custom agents (.agent.md, VS Code native format)
  instructions/ — path-scoped rules (.instructions.md with applyTo globs)
  prompts/      — slash commands (.prompt.md)
  skills/       — reusable SKILL.md playbooks with progressive disclosure
  copilot-instructions.md — this file
.claude/        — Claude Code adapters (same content, Claude format)
.cursor/        — Cursor-native rules that point to canonical instructions
.opencode/      — OpenCode adapters (same content, OpenCode format)
AGENTS.md       — cross-tool rules (also consumed by Copilot, OpenCode, and Cursor)
CLAUDE.md       — Claude memory entry (imports AGENTS.md + instructions)
opencode.json   — OpenCode config (declares instruction file paths)
```

## Conventions Copilot must follow

- **Custom agents** live in `.github/agents/*.agent.md`. YAML frontmatter uses `name`, `description`, `argument-hint`, `target: vscode`, `tools`, `agents`, `handoffs`, `disable-model-invocation`.
- **Instruction files** live in `.github/instructions/*.instructions.md`. Frontmatter requires `description` and `applyTo` (glob). Keep bodies focused on one topic.
- **Prompt files** live in `.github/prompts/*.prompt.md`. Frontmatter requires `description`. Invoked with `/<name>` in chat.
- **Skills** live in `.github/skills/<name>/SKILL.md` and follow the [agentskills.io](https://agentskills.io/) progressive-disclosure standard: a ≤ 500-line `SKILL.md`, optional `references/` and `assets/`.
- **Branch names**: `feat/<id>/<slug>`, `fix/<id>/<slug>`, `chore/<id>/<slug>`, `refactor/<id>/<slug>`.
- **Commits**: Conventional Commits (`feat(scope): …`). Atomic; each commit compiles and passes tests.
- **No destructive actions** (`git push --force`, `git reset --hard` on shared branches, `--no-verify`) without explicit user confirmation.
- **Code, identifiers, file names, commits** in English. Conversational output to the user matches the user's language.
- **No emojis** unless the user asks.

## Quality gates

When validating changes, Copilot should:

1. Prefer Makefile targets (`make lint`, `make test`, `make quality`) if a `Makefile` exists.
2. Otherwise fall back to the stack's canonical commands (`npm run lint|test|build`, `composer run-script …`, etc.).
3. Report gate status as a structured pass/fail list. See [.github/skills/quality-gates/SKILL.md](skills/quality-gates/SKILL.md).

## When unsure

Read the relevant `.github/instructions/*.instructions.md` file whose `applyTo` glob matches the files you are editing. If multiple agents or skills apply, pick the generic one first and only use a language-specific variant (`php-*`, `javascript-*`) when the codebase clearly requires stack-specific conventions.

Trust these instructions. Search the repo only if information here is incomplete or appears wrong.
