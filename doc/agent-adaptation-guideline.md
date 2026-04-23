# Agent Adaptation Guideline

This guideline explains how to reproduce similar agent behaviors across GitHub Copilot, GitHub Copilot for VS Code, Claude Code, and OpenCode without duplicating the canonical intent.

## Core rule

Keep one canonical behavioral source, then expose thin tool-native adapters.

In this repository, the canonical sources are:

- `.github/agents/*.agent.md` for agent behavior.
- `.github/instructions/*.instructions.md` for scoped rules.
- `.github/skills/*/SKILL.md` for portable workflows.
- `AGENTS.md` for cross-tool baseline guidance.

Everything else should be a compatibility layer, a wrapper, or a tool-native projection of those sources.

## Feature mapping by tool

| Capability | GitHub Copilot product | VS Code Copilot | Claude Code | OpenCode |
|---|---|---|---|---|
| Always-on repo guidance | Repository customization and agent profiles | `.github/copilot-instructions.md`, `AGENTS.md`, `CLAUDE.md` compatibility | `CLAUDE.md` | `AGENTS.md`, `CLAUDE.md` fallback |
| Path-scoped rules | Product concept depends on surface | `.instructions.md` with `applyTo` | `.claude/rules/*.md` with `paths` | `instructions` in `opencode.json` plus `AGENTS.md` guidance |
| Native agent files | Agent profiles | `.github/agents/*.agent.md` | `.claude/agents/*.md` | `.opencode/agents/*.md` |
| Reusable workflows | Agent Skills | `.github/skills/` | `.claude/skills/` | `.opencode/skills/`, `.claude/skills/` compatibility |
| Reusable prompt surface | Product-specific | `.github/prompts/*.prompt.md` | `.claude/commands/*.md` | `.opencode/commands/*.md` |
| Deterministic enforcement | Depends on surface | `.github/hooks/*.json` and agent-scoped hooks | `.claude/settings.json` hooks and permissions | `permission` rules and config |
| Learned memory | Copilot Memory | session memory plus product memory depending on surface | `CLAUDE.md` plus auto memory | no equivalent repo-memory layer documented in the same way |

## Adaptation rules

### 1. Canonical agent bodies belong in `.github/agents/`

Why:

- VS Code Copilot natively consumes this folder.
- GitHub Copilot product documentation uses repository-level agent profiles as the portable customization surface.
- Claude and OpenCode can wrap those bodies instead of duplicating them.

Implementation rule:

- Keep `.claude/agents/` and `.opencode/agents/` as thin wrappers that read the canonical body.
- Do not fork behavior in wrappers unless the tool truly requires a different workflow.

### 2. Put broad cross-tool rules in `AGENTS.md`

Why:

- OpenCode reads `AGENTS.md` directly.
- VS Code can read `AGENTS.md` as always-on instructions.
- Claude can import `AGENTS.md` from `CLAUDE.md`.

Implementation rule:

- Keep `AGENTS.md` tool-agnostic.
- Put only rules that should apply to every tool there.

### 3. Use tool-native entrypoints only for what is truly native

Examples:

- Copilot always-on workspace instructions belong in `.github/copilot-instructions.md`.
- Claude-specific entry behavior belongs in `CLAUDE.md`.
- OpenCode configuration belongs in `opencode.json`.

Implementation rule:

- Do not move canonical guidance into these files if it can live in shared assets.
- Use these files to import, enable, or scope shared assets.

### 4. Treat skills as the portability layer for workflows

Why:

- Copilot officially supports the Agent Skills standard.
- Claude uses skills as the recommended on-demand workflow mechanism.
- OpenCode supports `.opencode/skills/` and compatibility with `.claude/skills/` and `.agents/skills/`.

Implementation rule:

- Put multi-step workflows in skills.
- Keep `CLAUDE.md`, `AGENTS.md`, and `.instructions.md` concise.
- Prefer one portable skill over three vendor-specific workflow descriptions.

### 5. Separate advisory guidance from enforcement

Advisory layers:

- `AGENTS.md`
- `CLAUDE.md`
- `.github/copilot-instructions.md`
- `.instructions.md`
- `SKILL.md`

Enforcement layers:

- VS Code hooks
- Claude settings, permissions, and sandboxing
- OpenCode `permission` rules

Implementation rule:

- Put style, process, and intent in Markdown instructions.
- Put hard safety controls in hooks or permission settings.

### 6. Map reusable prompt surfaces by tool, not by file extension

Equivalent concepts:

- Copilot reusable prompt: `.github/prompts/*.prompt.md`
- Claude reusable command: `.claude/commands/*.md`
- OpenCode reusable command: `.opencode/commands/*.md`

Implementation rule:

- The workflow intent can be shared.
- The concrete surface should use the native file type for each tool.

### 7. Preserve plan-first behavior everywhere

Official docs across tools converge on the same pattern:

- Copilot in VS Code has a built-in Plan agent.
- Claude Code recommends Plan Mode for multi-file or uncertain changes.
- OpenCode ships a built-in Plan primary agent.

Implementation rule:

- Keep the orchestrator workflow plan-first.
- Use planning agents or modes before implementation when the task is multi-step.

## Current repository audit

### Verified alignments

- `.github/agents/` is the canonical source for the agent bodies.
- `CLAUDE.md` imports `AGENTS.md`, which matches Claude's official recommendation for repositories that already use `AGENTS.md`.
- `opencode.json` uses the official `instructions` field to load shared repository rules.
- `.opencode/agents/` are thin native wrappers, which matches OpenCode's documented agent format.

### Fixed drift

- OpenCode officially supports skills from `.claude/skills/`, but the installer previously did not copy those shared skill assets for OpenCode-only installs.
- The manifest and installer tests now include the shared `.claude/skills/` assets required for OpenCode skill parity.
- OpenCode officially supports native reusable commands in `.opencode/commands/`, and the repository now mirrors the reusable command surfaces that already existed for Copilot and Claude.

## Current adaptation rule

When a reusable prompt surface exists for Copilot and Claude, prefer adding the OpenCode-native mirror in `.opencode/commands/` rather than forcing users to rely on raw prompt text or tool-specific wrappers.

## Reference set

- GitHub Copilot docs: https://docs.github.com/en/copilot
- GitHub Copilot custom agents: https://docs.github.com/en/copilot/concepts/agents/cloud-agent/about-custom-agents
- GitHub Copilot skills: https://docs.github.com/en/copilot/concepts/agents/about-agent-skills
- VS Code Copilot overview: https://code.visualstudio.com/docs/copilot/overview
- VS Code custom instructions: https://code.visualstudio.com/docs/copilot/customization/custom-instructions
- VS Code custom agents: https://code.visualstudio.com/docs/copilot/customization/custom-agents
- VS Code skills: https://code.visualstudio.com/docs/copilot/customization/agent-skills
- Claude Code overview: https://code.claude.com/docs/en/overview
- Claude memory and CLAUDE.md: https://code.claude.com/docs/en/memory
- Claude settings: https://code.claude.com/docs/en/settings
- OpenCode config: https://opencode.ai/docs/config
- OpenCode rules: https://opencode.ai/docs/rules
- OpenCode agents: https://opencode.ai/docs/agents
- OpenCode commands: https://opencode.ai/docs/commands
- OpenCode skills: https://opencode.ai/docs/skills