# AI Agent Orchestration Kit

This folder contains the **GitHub Copilot (VS Code)** adapters for a portable agent orchestration system. The same agent definitions are mirrored to [`.claude/`](../.claude/) for Claude Code and [`.opencode/`](../.opencode/) for OpenCode.

Top-level rules live in the repo-root [`AGENTS.md`](../AGENTS.md) (consumed by Copilot, Claude and OpenCode) and [`CLAUDE.md`](../CLAUDE.md) (imports AGENTS.md + scoped instruction files for Claude).

## Core pattern: Orchestrator + Specialist Subagents

```
┌──────────────┐   plan    ┌────────────┐   brief    ┌────────────────┐
│  USER/TICKET │──────────▶│ORCHESTRATOR│───────────▶│RESEARCH PLANNER│
└──────────────┘           └────────────┘            └───────┬────────┘
                                 ▲                           │
                                 │ report                    ▼
                          ┌──────┴───────┐            ┌─────────────┐
                          │  Fix loop    │◀───────────│ IMPLEMENTER │
                          │  (until OK)  │            └──────┬──────┘
                          └──────┬───────┘                   │
                                 │                           ▼
                                 │                    ┌─────────────┐
                                 └────────────────────│CODE REVIEWER│
                                                      └─────────────┘
```

1. **Plan** — `research-planner` produces a planning brief.
2. **Implement** — `implementer` writes code + tests following the brief.
3. **Review** — `code-reviewer` (and optionally `test-reviewer`) returns `APPROVED` or `CHANGES REQUIRED`.
4. **Loop** — fixes are routed back to the implementer until review is clean.
5. **Report** — orchestrator summarizes artifacts, tests, quality-gate results.

See [instructions/orchestration-loop.instructions.md](instructions/orchestration-loop.instructions.md) for the canonical contract.

## Layout inside `.github/`

```text
.github/
├── README.md                          # This file
├── copilot-instructions.md            # Repo-wide Copilot rules (always-on)
├── agents/                            # Custom agents (.agent.md, VS Code native)
├── instructions/                      # Path-scoped rules (.instructions.md with applyTo glob)
├── prompts/                           # Slash commands (.prompt.md)
└── skills/                            # Progressive-disclosure SKILL.md playbooks
```

Chat modes (`.chatmode.md`) have been removed: VS Code replaced them with custom agents (`.agent.md`). The orchestrator lives as a custom agent that can be selected from the agents dropdown.

## How GitHub Copilot (VS Code) consumes this

| Artifact | Mechanism |
|----------|-----------|
| `.github/copilot-instructions.md` | Always-on instructions for every chat request in this repo. |
| `AGENTS.md` (repo root) | Always-on instructions (recognised by Copilot when `chat.useAgentsMdFile` is enabled). |
| `.github/instructions/*.instructions.md` | Activated automatically when the file being edited matches the `applyTo` glob. |
| `.github/prompts/*.prompt.md` | Slash commands invocable in chat as `/plan-feature`, `/review-code`, etc. |
| `.github/agents/*.agent.md` | Selectable from the agents dropdown and addressable with `@agent-name` in chat. |
| `.github/skills/<name>/SKILL.md` | Agent skills following the [agentskills.io](https://agentskills.io/) standard. |

## Language coverage

| Stack              | Research              | Implement          | Review              |
|--------------------|-----------------------|--------------------|---------------------|
| **Generic**        | `research-planner`    | `implementer`      | `code-reviewer`     |
| **PHP**            | `php-research-planner`| `php-implementer`  | `php-code-reviewer` |
| **JavaScript/TS**  | `javascript-research-planner` | `javascript-implementer` | `javascript-code-reviewer` |

Prefer the generic agents by default. Escalate to specialized variants only when stack-specific conventions (PHP DDD, React/Vue, TanStack, etc.) are needed.

## Optional framework add-ons

Framework-specific assets are not always installed. They are copied only when the installer selection includes the matching framework.

- `php:symfony` adds Symfony instructions, `symfony-*` specialist agents, curated Symfony skills, and framework-specific slash prompts.
- Base PHP installs continue to expose only the generic PHP assets.

## Design principles

- **Agnostic first** — generic agents/skills cover most workflows; specialists extend, never replace.
- **Progressive disclosure** — `SKILL.md` gives the steps; `references/` carry rules; `assets/` hold templates.
- **Deterministic execution** — prefer `make` / `npm run` / `composer` scripts over ad-hoc commands.
- **Evidence over claims** — every verdict (APPROVED / CHANGES REQUIRED) cites `file:line` proof.
- **No over-engineering** — agents only touch what the user asked for; no gratuitous refactors.
- **Human-in-the-loop by default** — the orchestrator pauses for plan confirmation unless explicitly told to run autonomously.
