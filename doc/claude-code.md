# Claude Code Knowledge Notes

This document summarizes the official Claude Code documentation from the perspective of a repository that wants portable, versioned, team-shared behavior.

## Product model

Claude Code is documented as an agentic coding environment that can read code, edit files, run commands, use tools, and operate across terminal, IDE, desktop, and web surfaces.

The official docs emphasize that all of those surfaces share the same underlying Claude Code engine, so the durable repository artifacts matter more than the individual UI.

## The core repository surfaces

### `CLAUDE.md`

Claude Code reads `CLAUDE.md` files at session start as persistent instructions. The official guidance is:

- Keep `CLAUDE.md` concise.
- Put broad rules there, not occasional workflows.
- Use it for build commands, coding conventions, architecture, and non-obvious workflow rules.
- Prefer skills or path-scoped rules for content that should not be loaded every session.

Claude explicitly documents that it does not read `AGENTS.md` directly. If a repository uses `AGENTS.md` for other tools, the recommended pattern is to create a `CLAUDE.md` that imports `AGENTS.md`.

That is exactly what this repository does.

### `.claude/rules/`

Claude documents `.claude/rules/` as the structured rule directory for larger repositories.

Important details:

- Rules are Markdown files.
- Rules can be unconditional or path-scoped.
- Path-scoped rules use YAML `paths` globs.
- User-level and project-level rules both exist.
- Rules reduce context noise compared with putting everything into one big `CLAUDE.md`.

This repository currently imports its shared instruction files from `.github/instructions/` through `CLAUDE.md` instead of duplicating them into `.claude/rules/`. That is valid and keeps one canonical instruction source.

### `.claude/agents/`

Claude Code supports custom subagents in `.claude/agents/`.

Important operational details:

- Subagents have their own prompts and tool restrictions.
- Claude can delegate to them automatically when descriptions are good enough.
- Users can also invoke them explicitly with `/agents` or by naming them.
- Tool access should be minimal and role-specific.

This repository uses `.claude/agents/` as thin wrappers that first read the canonical `.github/agents/*.agent.md` body.

### `.claude/skills/`

Claude recommends skills for reusable workflows and domain knowledge that should load on demand.

This repository correctly uses skills for:

- research planning
- orchestration
- debugging
- code review
- quality gates
- TDD
- Symfony-specific workflows

Because OpenCode documents `.claude/skills/` compatibility, this directory is also the repository's standard shared workflow surface between Claude Code and OpenCode.

The official docs do not establish the same shared pattern for `.claude/agents/` or `.claude/commands/` in OpenCode, so those remain Claude-native adapters rather than common cross-tool resources.

## Memory model

Claude documents two complementary memory systems:

- `CLAUDE.md`, which humans write.
- auto memory, which Claude writes for itself.

Important official memory details:

- `CLAUDE.md` is instructions and context.
- auto memory stores learned patterns and discoveries.
- auto memory is machine-local.
- auto memory is stored under `~/.claude/projects/<project>/memory/`.
- `CLAUDE.md` is loaded every session; `MEMORY.md` only partially loads at startup.
- subagents can maintain their own memory.

For this repository, the main rule is the same as with Copilot: committed files remain the source of truth. Auto memory is helpful, but it is not the canonical policy layer.

## Settings, scopes, and precedence

Claude Code has a strong settings model with explicit scopes:

- managed
- user
- project
- local

Important official settings facts:

- shared project settings live in `.claude/settings.json`.
- personal project overrides live in `.claude/settings.local.json`.
- higher-precedence settings can override lower-precedence ones.
- arrays merge rather than replace in many settings.
- permissions, hooks, environment variables, plugins, MCP servers, and sandboxing are configured through settings.

This matters because Claude differentiates between:

- guidance in `CLAUDE.md`
- enforcement in settings, permissions, sandboxing, and hooks

That distinction is important when adapting repository behavior across tools.

## Workflow primitives

### Plan Mode

Claude officially recommends exploring first, then planning, then implementing.

Plan Mode is the read-only planning surface and is appropriate when:

- the change is multi-file
- the codebase is unfamiliar
- the task is large enough to benefit from clarification

This repository's orchestrator workflow mirrors that recommendation.

### Subagents

Claude recommends subagents for focused investigation and isolated specialist work. That aligns directly with the repository's orchestrator, planner, implementer, reviewer, and QA roles.

### Verification

Claude's official best-practices guide is explicit: provide tests, screenshots, or clear success criteria so Claude can verify its own work. This repository's quality-gate and testing rules align with that guidance.

### Session management and worktrees

Claude documents strong support for:

- resuming sessions
- naming sessions
- worktree isolation
- parallel sessions

Those capabilities explain why this repository keeps behaviors in durable files instead of expecting long-lived chat context to carry everything.

## Repository mapping

This repository aligns well with the official Claude guidance:

- `CLAUDE.md` imports `AGENTS.md` rather than duplicating cross-tool rules.
- `.claude/agents/` contains thin wrappers, not duplicated system prompts.
- `.claude/skills/` mirrors reusable workflows and acts as the shared skill surface for Claude Code and OpenCode.
- `.claude/commands/` mirrors reusable prompt surfaces for Claude.
- shared policy remains versioned in `.github/instructions/` and imported into Claude's entrypoint.

## References

- Claude Code overview: https://code.claude.com/docs/en/overview
- How Claude remembers your project: https://code.claude.com/docs/en/memory
- Common workflows: https://code.claude.com/docs/en/common-workflows
- Best practices: https://code.claude.com/docs/en/best-practices
- Claude Code settings: https://code.claude.com/docs/en/settings
- Enterprise deployment overview: https://code.claude.com/docs/en/third-party-integrations