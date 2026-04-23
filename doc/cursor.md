# Cursor Knowledge Notes

This document summarizes the official Cursor documentation from the perspective of a repository that wants portable, versioned, team-shared behavior.

## Product model

Cursor documents Agent as a coding environment that can search the codebase and the web, edit files, run shell commands, ask follow-up questions, and manage longer tasks with checkpoints and queued messages.

For this repository, the important distinction is that Cursor's durable customization model is centered on repository files rather than on a custom-agent file format.

## The core repository surfaces

### `.cursor/rules/`

Cursor documents Project Rules as version-controlled markdown files stored in `.cursor/rules/`.

Important official details:

- Rules can use either `.md` or `.mdc` extensions.
- `.mdc` adds frontmatter such as `description`, `globs`, and `alwaysApply`.
- Rules can be always-on, applied intelligently, file-scoped through glob patterns, or invoked manually.
- Team Rules, Project Rules, and User Rules are merged with documented precedence.

For this repository, `.cursor/rules/` is the correct native place to project the canonical instruction files that already live in `.github/instructions/`.

### `AGENTS.md`

Cursor officially supports `AGENTS.md` as a simple markdown instruction file in the project root and in nested subdirectories.

That matters because this repository already keeps broad cross-tool guidance in `AGENTS.md`. Cursor can read that file directly without needing a Cursor-specific equivalent of `CLAUDE.md`.

### Skills

Cursor documents Agent Skills as an open, portable standard discovered automatically from these project-level directories:

- `.agents/skills/`
- `.cursor/skills/`

Cursor also documents compatibility loading from:

- `.claude/skills/`
- `.codex/skills/`

That compatibility point is important for this repository. It means the existing `.claude/skills/` mirror can be reused for Cursor without introducing a second duplicated skills tree.

Important official skill details:

- each skill lives in its own directory with a `SKILL.md`
- `SKILL.md` uses YAML frontmatter with `name` and `description`
- optional `scripts/`, `references/`, and `assets/` directories are supported
- skills can auto-apply when relevant or behave like explicit slash commands via `disable-model-invocation: true`

## Rules and commands model

Cursor does not document a repository file format equivalent to GitHub Copilot custom prompts or Claude/OpenCode command directories.

Instead, the official docs point to two patterns:

- use Rules for persistent instruction layers
- use Skills for reusable workflows, including explicit invocation with `/skill-name`

Cursor also ships a documented `/migrate-to-skills` workflow to convert eligible rules and commands into skills.

For this repository, that means reusable workflow content should stay skill-based for Cursor rather than inventing a synthetic `.cursor/commands/` convention.

## Agent capabilities and current gaps

Cursor documents one Agent surface with tools, checkpoints, and queueing. It also documents an Explore subagent in the learning material for codebase exploration.

However, the public docs do not describe a repository-level custom-agent file format equivalent to:

- `.github/agents/*.agent.md`
- `.claude/agents/*.md`
- `.opencode/agents/*.md`

The public docs also do not document a repository-managed memory file equivalent to Claude's `CLAUDE.md` plus auto memory, or a version-controlled MCP configuration surface.

For this repository, the practical implication is:

- keep canonical agent bodies in `.github/agents/`
- use `AGENTS.md` plus `.cursor/rules/` for Cursor's persistent guidance layer
- use shared skills for reusable workflows
- do not invent undocumented Cursor-native agent or memory formats

## Repository mapping

Cursor support in this repository should follow these rules:

- `AGENTS.md` remains the broad, cross-tool baseline.
- `.github/instructions/*.instructions.md` remain canonical policy files.
- `.cursor/rules/*.mdc` stay thin wrappers that point back to the canonical instruction files.
- `.claude/skills/` remains a valid shared skill surface because Cursor loads it for compatibility.
- `.github/prompts/` and `.github/agents/` stay canonical for Copilot and for cross-tool intent, even though Cursor does not currently expose the same native file surfaces.

## References

- Cursor rules: https://cursor.com/en-US/docs/rules
- Cursor Agent Skills: https://cursor.com/en-US/docs/skills
- Cursor Agent overview: https://cursor.com/en-US/docs/agent/overview
- Cursor learning guide, understanding your codebase: https://cursor.com/learn/understanding-your-codebase