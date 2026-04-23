# GitHub Copilot Knowledge Notes

This document summarizes the official GitHub Copilot product documentation from the perspective of this repository.

## Product scope

GitHub Copilot is no longer only an inline code completion product. The official documentation now treats it as a broader AI coding platform that spans:

- Chat and code generation.
- Coding agents and cloud agents.
- Code review.
- CLI usage.
- Repository-level customization.
- Shared skills and memory.
- Model selection and policy control.

For this repository, the important point is that GitHub Copilot has a product-level customization model that is broader than any single editor integration.

## Concepts that matter to this repository

### Custom agents

GitHub documents custom agents as specialized variants of Copilot that are defined in Markdown agent profile files. The key ideas are:

- Agents are defined once and reused across tasks.
- Agent profiles can declare prompt, tools, and MCP servers.
- Repository-level agents live under `.github/agents/`.
- Organization or enterprise agents can be distributed from a `.github-private` repository.
- The same agent profile can be surfaced in GitHub.com, IDEs, and Copilot CLI, although some properties can behave differently depending on the environment.

That matches this repository's design choice to keep canonical agent bodies in `.github/agents/` and treat other tool folders as wrappers or adapters.

### Agent skills

GitHub positions skills as portable folders of instructions, scripts, and resources that can be loaded only when relevant. The important consequences are:

- Skills are not editor-only customization.
- Skills use the Agent Skills open standard.
- Project skills can live in `.github/skills`, `.claude/skills`, or `.agents/skills`.
- Personal skills can live in the corresponding home-directory locations.
- Skills are intended for reusable workflows, not always-on policy.

This is why this repository keeps the workflow playbooks as `SKILL.md` assets instead of duplicating the same multi-step instructions inside every agent.

### Agentic memory

GitHub documents agentic memory as repository-scoped knowledge learned by Copilot from prior work. The important constraints are:

- Memory is repository-scoped, not user-scoped.
- It is created and validated with citations.
- It is currently used by Copilot cloud agent, Copilot code review, and Copilot CLI.
- It reduces repeated prompting but does not replace explicit instructions.
- Memories expire automatically and are revalidated against the current branch.

For this repository, the practical rule is simple: persistent repository conventions must still be versioned in instruction files. Memory is an optimization layer, not the source of truth.

### Auto model selection

GitHub Copilot officially supports automatic model selection across chat, cloud agents, CLI, and third-party agents. The main implications are:

- Model choice can vary by plan, policy, and system health.
- Administrators can restrict available models.
- Auto mode reduces manual model-picking overhead.
- Model selection is a runtime concern, not a repository-format concern.

This repository should therefore avoid encoding behavior that depends on one specific model unless a tool explicitly requires it.

## Recommended repository patterns

Based on the official product docs, the repository patterns below are the right ones:

- Keep canonical agent definitions in `.github/agents/`.
- Keep reusable workflows in skills, not in always-on instructions.
- Keep rules and policy in committed instruction files, not in memory.
- Treat model selection as configurable runtime behavior.
- Keep wrappers thin so the canonical behavior is maintained in one place.

## What this repository already aligns with

- Canonical agent bodies are stored in `.github/agents/`.
- Workflow knowledge is stored in `.github/skills/`.
- Cross-tool conventions are stored in `AGENTS.md` and imported or mirrored as needed.
- Tool-specific adapters are kept separate from the canonical behavior.

## References

- GitHub Copilot docs overview: https://docs.github.com/en/copilot
- What is GitHub Copilot: https://docs.github.com/copilot/get-started/what-is-github-copilot
- About custom agents: https://docs.github.com/en/copilot/concepts/agents/cloud-agent/about-custom-agents
- About agent skills: https://docs.github.com/en/copilot/concepts/agents/about-agent-skills
- About agentic memory for GitHub Copilot: https://docs.github.com/en/copilot/concepts/agents/copilot-memory
- About Copilot auto model selection: https://docs.github.com/en/copilot/concepts/auto-model-selection