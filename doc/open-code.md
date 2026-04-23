# OpenCode Knowledge Notes

This document summarizes the official OpenCode documentation that is relevant to this repository.

## Product model

OpenCode is documented as an open source AI coding agent available through terminal, desktop, IDE, and web surfaces. Its model is configuration-first and repository-friendly.

The most important idea for this repository is that OpenCode can combine:

- `AGENTS.md` rules
- `opencode.json` configuration
- `.opencode/agents/` native agents
- `.opencode/commands/` command surfaces
- `.opencode/skills/` skills
- compatibility with selected Claude-style assets

## Configuration model

OpenCode merges configuration from multiple layers instead of replacing it.

Official precedence order:

- remote organization defaults from `.well-known/opencode`
- global config in `~/.config/opencode/opencode.json`
- `OPENCODE_CONFIG`
- project `opencode.json`
- `.opencode/` directories
- `OPENCODE_CONFIG_CONTENT`

Important consequences:

- project config is a strong repository-level integration point
- config is merged, not replaced
- repository-local directories are first-class customization surfaces
- `instructions` is a dedicated config field rather than a side effect of file placement

This repository uses `opencode.json` to load shared instruction files from `.github/instructions/`.

## Rules and instruction loading

OpenCode documents `AGENTS.md` as the main project rules file.

Important official details:

- project rules live in `AGENTS.md` at the project root
- global rules can live in `~/.config/opencode/AGENTS.md`
- Claude compatibility exists: `CLAUDE.md` is used if `AGENTS.md` is absent
- additional instruction files can be loaded explicitly through the `instructions` array in `opencode.json`
- custom instructions can also be remote URLs

For a portable repository, the clean pattern is:

- keep cross-tool baseline in `AGENTS.md`
- use `opencode.json` to load the same shared instruction files that Copilot and Claude use

This repository follows that model.

## Agents

OpenCode distinguishes between:

- primary agents
- subagents

Built-in primary agents include `Build` and `Plan`. Built-in subagents include `General` and `Explore`.

Important official agent facts:

- agents can be defined in JSON or Markdown
- project agent files live in `.opencode/agents/`
- agent frontmatter can define description, mode, model, prompt, tools, permission, task permission, steps, temperature, and visibility
- `Plan` is intentionally restricted and suitable for analysis without mutation
- primary agents can invoke subagents and users can invoke subagents directly

This repository uses native OpenCode wrappers in `.opencode/agents/` that read the canonical `.github/agents/*.agent.md` bodies.

## Commands

OpenCode supports reusable command surfaces through `.opencode/commands/*.md` or the `command` section in `opencode.json`.

Important command details:

- commands are invoked as `/name`
- the file body is the prompt template
- commands can reference files with `@`
- commands can inject shell output with `!command`
- commands can take `$ARGUMENTS`, `$1`, `$2`, and similar placeholders
- commands can optionally run through a named agent or a subtask

That makes OpenCode commands the closest native equivalent to Copilot prompt files and Claude custom commands.

## Skills

OpenCode supports the Agent Skills model and can discover skills from several locations:

- `.opencode/skills/<name>/SKILL.md`
- `.claude/skills/<name>/SKILL.md`
- `.agents/skills/<name>/SKILL.md`
- global versions of the same directories

Important official facts:

- names must be strict lowercase-hyphen identifiers
- skills are loaded through the native `skill` tool
- skills can be allowed, denied, or gated through permission rules
- OpenCode supports Claude compatibility for skill directories

This repository now uses that compatibility explicitly for installed OpenCode projects by shipping the shared `.claude/skills/` assets that OpenCode knows how to discover.

## Permissions

OpenCode has a more explicit permission model than the committed Markdown instructions.

Important official details:

- permissions resolve to `allow`, `ask`, or `deny`
- most defaults are permissive
- `external_directory` and `doom_loop` are explicit safety controls
- permissions can be global or agent-specific
- bash permissions support wildcard matching on commands
- task permissions can control which subagents an agent may invoke

That means OpenCode distinguishes clearly between advisory guidance in `AGENTS.md` and enforced behavior in `permission` rules.

## Repository mapping

This repository aligns with OpenCode's official model in these ways:

- `AGENTS.md` is the cross-tool baseline and is valid for OpenCode directly.
- `opencode.json` loads shared instruction files from `.github/instructions/`.
- `.opencode/agents/` contains native wrappers for the orchestrator and specialists.
- `.opencode/commands/` provides native reusable command surfaces parallel to Copilot prompt files and Claude commands.
- shared skills are available to OpenCode through the officially supported `.claude/skills/` compatibility path.

## References

- OpenCode overview: https://opencode.ai/docs/
- OpenCode configuration: https://opencode.ai/docs/config
- OpenCode rules: https://opencode.ai/docs/rules
- OpenCode agents: https://opencode.ai/docs/agents
- OpenCode commands: https://opencode.ai/docs/commands
- OpenCode permissions: https://opencode.ai/docs/permissions
- OpenCode skills: https://opencode.ai/docs/skills