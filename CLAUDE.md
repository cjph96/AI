@AGENTS.md

## Claude Code — workspace entry

This file is loaded by Claude Code at session start. It imports the shared cross-tool rules from [AGENTS.md](AGENTS.md), then layers Claude-specific guidance below.

### Canonical locations

- **Custom subagents** → [.claude/agents/](.claude/agents/). Each subagent is a thin wrapper whose first action is to `Read` the canonical system prompt from `.github/agents/<name>.agent.md` and act as that persona.
- **Skills** → [.claude/skills/](.claude/skills/) (mirror of [.github/skills/](.github/skills/) using the standard `SKILL.md` format). Each skill is a directory with `SKILL.md` + optional `references/` and `assets/`.
- **Commands** → [.claude/commands/](.claude/commands/). Slash commands that mirror the GitHub Copilot prompts in `.github/prompts/`.
- **Rules** — project-wide rules live in this file via imports. Path-scoped rules live in [.claude/rules/](.claude/rules/) when needed. Baseline instruction files live in [.github/instructions/](.github/instructions/) and are imported below.

### Imported instruction files

The following path-scoped rules apply when you work with matching files. Claude loads them via these imports; the Copilot `applyTo` glob in each file header still documents the intended scope.

- Code quality (all source files) — @.github/instructions/code-quality.instructions.md
- Testing (all test files) — @.github/instructions/testing.instructions.md
- Security baseline (all source files) — @.github/instructions/security.instructions.md
- Git workflow — @.github/instructions/git-workflow.instructions.md
- Orchestration loop contract — @.github/instructions/orchestration-loop.instructions.md
- Skill authoring standard — @.github/instructions/agent-skills-best-practices.instructions.md

Language and framework rules are loaded when the matching files are present in the installed selection:

- PHP — @.github/instructions/php.instructions.md
- PHP testing — @.github/instructions/php-testing.instructions.md
- Laravel — @.github/instructions/laravel.instructions.md
- Laravel testing — @.github/instructions/laravel-testing.instructions.md
- JavaScript / TypeScript — @.github/instructions/javascript.instructions.md
- JavaScript / TypeScript testing — @.github/instructions/javascript-testing.instructions.md
- Python — @.github/instructions/python.instructions.md
- Python testing — @.github/instructions/python-testing.instructions.md
- Go — @.github/instructions/go.instructions.md
- Go testing — @.github/instructions/go-testing.instructions.md

### How to invoke subagents

- Type `@` and pick a subagent from the typeahead, or use natural language ("use the code-reviewer subagent to review these changes").
- The `orchestrator` subagent is the default entry point for any multi-step task. Start a session with `claude --agent orchestrator` if you want the whole conversation to run as the orchestrator.
- Subagents in `.claude/agents/` have restricted tool lists per their frontmatter. Research/review subagents are read-only (no `Edit`, no `Write`); implementers get full write access.

### Quality-gate discipline

When Claude is asked whether a change is complete, run the gates via the `quality-gates` skill (or `/quality-gates` equivalent). Prefer the project's `Makefile` targets; fall back to stack-native commands. Never report success based on inference — only on observed output.
