# GitHub Copilot for VS Code Knowledge Notes

This document summarizes the official Visual Studio Code documentation for GitHub Copilot and highlights the mechanisms that this repository uses directly.

## What VS Code adds on top of GitHub Copilot

The VS Code integration turns Copilot into an editor-native agent platform with:

- Local, background, cloud, and third-party agent sessions.
- A built-in Plan agent.
- Custom instructions and rules.
- Custom agents.
- Skills.
- Prompt files.
- Hooks.
- Diagnostics and customization editors.

This repository maps very closely to that model.

## Agent model in VS Code

The official overview describes agents as autonomous assistants that can:

- Break a goal into steps.
- Edit files.
- Run commands.
- Self-correct.
- Work in tracked sessions.

VS Code also formalizes planning with a dedicated Plan agent. The plan agent can ask clarifying questions, produce structured plans, and store the accepted plan in session memory at `/memories/session/plan.md`.

That strongly matches the orchestrator-first workflow used in this repository.

## Custom instructions

VS Code supports several instruction surfaces:

- `.github/copilot-instructions.md` for always-on repository instructions.
- `AGENTS.md` for always-on multi-agent instructions.
- `*.instructions.md` for file-scoped instructions using `applyTo` globs.
- `CLAUDE.md` for Claude compatibility.
- `.claude/rules/*.md` for Claude-format rules.

Important official details:

- Multiple instruction files are combined.
- No guaranteed order is promised.
- File-based instructions can be activated by path matching or semantic matching of their description.
- Instruction priority is user instructions first, repository instructions second, organization instructions third.
- Settings-based code-generation instructions are deprecated in favor of file-based instructions.

This repository follows the recommended structure by using:

- `.github/copilot-instructions.md` for workspace-wide guidance.
- `.github/instructions/*.instructions.md` for scoped rules.
- `AGENTS.md` for cross-tool, always-on rules.

## Custom agents

VS Code custom agents are Markdown files, typically with the `.agent.md` extension, stored under `.github/agents/` or compatible locations such as `.claude/agents/`.

Important frontmatter fields documented by VS Code include:

- `name`
- `description`
- `argument-hint`
- `tools`
- `agents`
- `model`
- `user-invocable`
- `disable-model-invocation`
- `target`
- `handoffs`
- `hooks`

Important operational details:

- Handoffs are first-class and intended for plan-to-implement and implement-to-review workflows.
- Tool restrictions are a major reason to use custom agents instead of generic chat.
- `.claude/agents/*.md` is supported in Claude-compatible format.
- Old `.chatmode.md` assets should be migrated to `.agent.md`.

This repository uses the officially supported model:

- `.github/agents/*.agent.md` for native VS Code custom agents.
- Thin `.claude/agents/*.md` wrappers so Claude-compatible assets also work in VS Code.

## Skills

VS Code documents skills as the portable customization layer for reusable workflows.

Key differences versus instructions:

- Skills teach capabilities and workflows.
- Instructions teach conventions and rules.
- Skills can include scripts and assets.
- Skills are loaded progressively and on demand.
- Skills can appear as slash commands.

Official skill locations include:

- `.github/skills/`
- `.claude/skills/`
- `.agents/skills/`
- User-level counterparts under `~/.copilot/skills`, `~/.claude/skills`, and `~/.agents/skills`.

This repository uses skills correctly for debugging, research planning, orchestration, quality gates, TDD, and Symfony-specific workflows.

## Hooks

Hooks are a deterministic automation layer, not an advisory instruction layer.

Important official hook facts:

- Workspace hook files live in `.github/hooks/*.json`.
- VS Code also reads `.claude/settings.json` and `.claude/settings.local.json` hook configurations for compatibility.
- Hook lifecycle includes `SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `PreCompact`, `SubagentStart`, `SubagentStop`, and `Stop`.
- Hooks receive JSON input and can return JSON output that blocks, warns, edits input, or injects context.
- Agent-scoped hooks can be placed in custom agent frontmatter.
- Hooks are preview features and should be treated as policy/enforcement tooling.

This repository does not currently ship hook files, which is fine. The important design rule is to keep policy instructions in files and reserve hooks for deterministic enforcement.

## Prompt files

VS Code distinguishes prompts from agents and skills:

- Prompt files are good for one-off reusable prompts.
- Agents are good for persistent personas, tool restrictions, and handoffs.
- Skills are good for portable capabilities and reusable workflows.

This repository uses prompt files in `.github/prompts/` for reusable slash commands such as planning, implementation, review, and Symfony-specific guidance.

## Diagnostics and settings that matter

The official docs mention several settings and diagnostics that are relevant to this repository:

- `chat.useAgentsMdFile`
- `chat.useClaudeMdFile`
- `chat.instructionsFilesLocations`
- `chat.agentFilesLocations`
- `chat.agentSkillsLocations`
- `chat.useNestedAgentsMdFiles`
- `chat.useCustomAgentHooks`
- `chat.useCustomizationsInParentRepositories`

When debugging why a repo customization is not being applied, VS Code recommends using the Chat diagnostics view.

## Repository mapping

This repository aligns well with the official VS Code model:

- `.github/copilot-instructions.md` is the always-on workspace instructions file.
- `.github/instructions/*.instructions.md` are file-scoped rules.
- `.github/agents/*.agent.md` are native custom agents.
- `.github/prompts/*.prompt.md` are slash-command prompt files.
- `.github/skills/*/SKILL.md` are portable skills.
- `AGENTS.md` and `CLAUDE.md` are compatibility layers that VS Code can also consume.

## References

- GitHub Copilot in VS Code overview: https://code.visualstudio.com/docs/copilot/overview
- Planning with agents: https://code.visualstudio.com/docs/copilot/agents/planning
- Use custom instructions in VS Code: https://code.visualstudio.com/docs/copilot/customization/custom-instructions
- Custom agents in VS Code: https://code.visualstudio.com/docs/copilot/customization/custom-agents
- Use Agent Skills in VS Code: https://code.visualstudio.com/docs/copilot/customization/agent-skills
- Agent hooks in VS Code: https://code.visualstudio.com/docs/copilot/customization/hooks