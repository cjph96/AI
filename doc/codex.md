# Codex Knowledge Notes

This document summarizes the official Codex documentation that is relevant to this repository.

## Product model

Codex is documented as OpenAI's coding agent for software development across the Codex app, IDE extension, CLI, and cloud surfaces.

The important repository-level point is that Codex combines conversational work with explicit local runtime controls:

- repository guidance through `AGENTS.md`
- project-scoped custom agents through `.codex/agents/*.toml`
- reusable workflows through `.agents/skills/*/SKILL.md`
- deterministic enforcement through `.codex/rules/*.rules` and `.codex/hooks.json`
- local or CI automation through `codex exec`

That makes Codex a strong fit for this repository's "canonical source plus thin adapters" model.

## Repository guidance with `AGENTS.md`

Codex officially reads `AGENTS.md` before doing work.

Important discovery details:

- global guidance lives in `~/.codex/AGENTS.md`
- a temporary global override can live in `~/.codex/AGENTS.override.md`
- project guidance is discovered from the repository root down to the current working directory
- in each directory, Codex checks `AGENTS.override.md` first, then `AGENTS.md`, then any configured fallback names
- files are concatenated in root-to-leaf order, so files closer to the current directory override earlier guidance
- Codex stops once the merged instruction chain reaches `project_doc_max_bytes` (32 KiB by default)

For this repository, that means the committed root `AGENTS.md` is already a native Codex customization surface rather than only a compatibility layer.

## Custom agents and subagents

Codex supports built-in agents and project-scoped custom agents.

Important official details:

- built-in agents include `default`, `worker`, and `explorer`
- Codex only spawns subagents when the user explicitly asks it to do so
- project custom agents live in `.codex/agents/*.toml`
- each custom agent file must define `name`, `description`, and `developer_instructions`
- optional fields include `sandbox_mode`, `model`, `model_reasoning_effort`, `mcp_servers`, and `skills.config`
- parent sandbox and approval settings are inherited by child agents unless explicitly overridden
- concurrent and nested delegation is controlled through `[agents]` settings such as `max_threads` and `max_depth`

This maps cleanly to the repository's orchestrator/planner/implementer/reviewer split. The Codex-native projection should therefore be thin `.toml` wrappers that point back to the canonical `.github/agents/*.agent.md` bodies.

## Skills

Codex documents skills as the reusable workflow layer.

Important official details:

- repository skills are discovered from `.agents/skills` while Codex walks from the current directory up to the repository root
- user skills live in `$HOME/.agents/skills`
- admin skills can live in `/etc/codex/skills`
- a skill is a directory with a `SKILL.md` file and optional `scripts/`, `references/`, `assets/`, and `agents/openai.yaml`
- skill invocation can be explicit or implicit, depending on the skill `description`
- Codex loads skill metadata first and only reads the full `SKILL.md` when it decides to use the skill
- `[[skills.config]]` entries in `config.toml` can disable specific skills without deleting them

This repository already keeps canonical workflow content in `.github/skills/`. To support Codex without forking that content, the correct adaptation is to expose `.agents/skills/*/SKILL.md` wrappers that redirect Codex to the canonical skill body.

## Hooks and rules

Codex has two explicit enforcement surfaces that are distinct from advisory Markdown instructions.

### Hooks

Hooks are experimental and currently disabled on Windows.

Important official details:

- repository hooks live in `.codex/hooks.json`
- user hooks live in `~/.codex/hooks.json`
- hooks require `codex_hooks = true` under `[features]` in `config.toml`
- multiple matching hook files are merged, not replaced
- supported lifecycle events include `SessionStart`, `PreToolUse`, `PermissionRequest`, `PostToolUse`, `UserPromptSubmit`, and `Stop`
- hook handlers receive JSON on `stdin` and can return JSON decisions or additional context on `stdout`

### Rules

Rules are also experimental.

Important official details:

- rules live under `rules/` in Codex config locations, with the user default at `~/.codex/rules/default.rules`
- the rules language is Starlark
- `prefix_rule()` is the core primitive for `allow`, `prompt`, or `forbidden` decisions on command prefixes
- `match` and `not_match` examples act as inline tests when the rule file loads
- `codex execpolicy check` can test how rules apply to a concrete command

For this repository, Codex rules and hooks are the native equivalents of OpenCode permissions and VS Code hooks. They should remain separate from `AGENTS.md` and skills.

## Approvals, sandbox, and security model

Codex's security model combines sandboxing with approval policies.

Important official details:

- local Codex defaults to no network access and write access limited to the active workspace
- `--full-auto` is shorthand for `--sandbox workspace-write --ask-for-approval on-request`
- `--sandbox read-only --ask-for-approval on-request` is the safe read-only browsing mode
- `--ask-for-approval never` disables approval prompts while keeping the chosen sandbox policy in force
- `--dangerously-bypass-approvals-and-sandbox` / `--yolo` removes both protections and is explicitly high risk
- in writable roots, Codex still protects `.git`, `.agents`, and `.codex` as read-only paths
- non-interactive runs fail if they need a new approval they cannot surface

Those protected paths matter directly for this repository because the Codex adapter directories should be treated as committed policy, not as mutable work areas during normal agent execution.

## Non-interactive mode and CI

Codex documents `codex exec` as the non-interactive automation surface.

Important official details:

- `codex exec` streams progress to `stderr` and prints the final message to `stdout`
- the default `codex exec` sandbox is read-only
- `--json` emits a JSON Lines event stream suitable for scripts
- `--output-schema` can force the final message to match a JSON Schema
- `-o` / `--output-last-message` writes the final response to a file
- `CODEX_API_KEY` is the recommended authentication mechanism for CI and is supported specifically for `codex exec`
- `codex exec resume` can continue a previous non-interactive session
- Codex requires a Git repository for command execution unless `--skip-git-repo-check` is explicitly used

This gives the repository a documented Codex-native automation story even though Codex does not document the same reusable command-file surface that OpenCode and Claude expose.

## Repository mapping

This repository should map to the official Codex model in these ways:

- `AGENTS.md` stays the cross-tool baseline and is consumed by Codex directly.
- `.codex/agents/*.toml` should be thin wrappers around the canonical `.github/agents/*.agent.md` files.
- `.agents/skills/*/SKILL.md` should be thin wrappers around the canonical `.github/skills/*/SKILL.md` files.
- `.github/skills/` remains the canonical workflow source, with Codex wrappers used only for discovery.
- `.codex/rules/*.rules` and `.codex/hooks.json` are the right future surfaces for deterministic Codex enforcement if the repository adds it.
- Codex does not document a repository-native Markdown command surface equivalent to `.claude/commands/` or `.opencode/commands/`, so this repository should not invent a fake `.codex/commands/` convention.

## References

- Codex overview: https://developers.openai.com/codex
- Codex quickstart: https://developers.openai.com/codex/quickstart
- Custom instructions with AGENTS.md: https://developers.openai.com/codex/guides/agents-md
- Agent Skills: https://developers.openai.com/codex/skills
- Subagents: https://developers.openai.com/codex/subagents
- Rules: https://developers.openai.com/codex/rules
- Hooks: https://developers.openai.com/codex/hooks
- Agent approvals & security: https://developers.openai.com/codex/agent-approvals-security
- Non-interactive mode: https://developers.openai.com/codex/noninteractive