# AI

A portable set of agents, skills, instructions and prompts that give **GitHub Copilot**, **Claude Code**, **OpenCode**, **Cursor**, and **Codex** a consistent *research → plan → implement → review* workflow.

The repository is the single source of truth. The [`install.sh`](install.sh) script copies a selected subset into any other project.

## Core pattern: Orchestrator + Specialist Agents

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

1. **Plan** — a research/planning agent produces a grounded brief.
2. **Implement** — an implementation agent applies the change and adds validation.
3. **Review** — a review agent checks correctness, design, tests, and risks.
4. **Loop** — review feedback is routed back into implementation until the change is clean.
5. **Report** — the outcome is summarized with evidence from tests and quality gates.

This keeps the workflow consistent across tools while preserving each platform's native surfaces.

## Design principles

- **Agnostic first** — the shared workflow is defined once and adapted to each tool.
- **Progressive disclosure** — skills keep the main guidance short and move detail into references when needed.
- **Deterministic execution** — validation should rely on explicit commands and repeatable quality gates.
- **Evidence over claims** — completion is backed by observed test and review results.
- **Human-in-the-loop by default** — planning and implementation remain easy to inspect and approve.

## Shared resource pattern

The documented common resource pattern between Claude Code and OpenCode is deliberately narrow:

- `AGENTS.md` stays the cross-tool baseline, with `CLAUDE.md` importing it for Claude Code.
- `.claude/skills/` is the shared on-demand workflow surface because Claude uses it natively and OpenCode discovers it through its documented Claude-compatibility path.
- Agents and reusable slash commands remain native per tool in `.claude/agents/` plus `.claude/commands/` and `.opencode/agents/` plus `.opencode/commands/`, because OpenCode does not document `.claude/agents/` or `.claude/commands/` compatibility.

## Install in another project

Run the one-liner from the target project's root directory:

```sh
curl -fsSL https://raw.githubusercontent.com/cjph96/AI/refs/heads/main/install.sh | bash
```

The script asks interactively for:

1. **Agents** — GitHub Copilot, Claude Code, OpenCode, Cursor, Codex (multi-select, at least one).
2. **Languages** — PHP, JavaScript/TypeScript, Python, Go.
3. **Frameworks** per selected language (Symfony/Laravel for PHP; Vue/React/Vanilla for JS).
4. **Technologies** — PostgreSQL, Redis, AWS SQS.

Only the files mapped in [`manifest.json`](manifest.json) for the selected combination are copied. Framework add-ons stay optional: for example, selecting `php:symfony` installs Symfony-specific instructions, specialist agents, skills, and slash-command surfaces, while plain `php` does not.

Selecting `php` now also installs the base PHP skills for foundations, package selection, and quality tooling. Selecting `javascript` installs the base JavaScript skills for foundations, package selection, and quality tooling. Selecting `javascript:react` or `javascript:vue` adds the matching framework-specific skills and reference notes on top of that base surface. Selecting `php:laravel` adds a Laravel-first package selection skill on top of the base PHP surface.

## Language coverage

The repository provides a generic orchestration layer plus stack-specific specializations for:

- PHP
- JavaScript / TypeScript
- Python
- Go

Generic agents remain the default. Language-specific variants extend the same workflow when framework or ecosystem rules matter.

### Requirements

- `bash`
- `curl`
- `jq` (required — the installer aborts with install hints if missing).

### Non-interactive mode

Useful for CI or scripted bootstrapping:

```sh
curl -fsSL https://raw.githubusercontent.com/cjph96/AI/refs/heads/main/install.sh \
  | bash -s -- \
      --non-interactive \
      --agents=copilot,claude \
      --languages=php,javascript \
      --frameworks='php:symfony;javascript:vue' \
      --technologies=postgresql,redis \
      --force
```

### Flags

| Flag | Description |
|------|-------------|
| `--repo=OWNER/REPO` | Source repository (default: `cjph96/AI`, override via `$AI_TOOLS_REPO`) |
| `--ref=REF` | Branch or tag (default: `main`, override via `$AI_TOOLS_REF`) |
| `--dest=PATH` | Target project root (default: current directory) |
| `--agents=a,b,c` | Non-interactive selection |
| `--languages=a,b` | Non-interactive selection |
| `--frameworks=LANG:f1,f2;LANG2:f3` | Non-interactive selection |
| `--technologies=a,b` | Non-interactive selection |
| `--force` | Overwrite existing files |
| `--skip-existing` | Keep existing files |
| `--dry-run` | Show plan without writing |
| `--non-interactive` | Fail instead of prompting |
| `--manifest=FILE` | Use a local manifest (for testing) |
| `--source=PATH` | Copy from a local directory (for testing) |

### What gets installed

Given a set of choices, the installer unions:

- `base.files` — always copied (`AGENTS.md`).
- `agents[<id>].files` — for every selected agent.
- `languages[<id>].files_by_agent[<agent>]` — language files only for selected agents.
- `languages[<id>].frameworks[<id>].files_by_agent[<agent>]` — same rule, gated by framework choice.
- `technologies[<id>].files_by_agent[<agent>]` — same rule.

Duplicate paths are deduplicated; paths are validated against path-traversal before any write.

### Optional Symfony package

When the installer includes `php:symfony`, it adds an extra framework layer on top of the base PHP assets:

- Symfony-specific instructions for implementation and testing.
- Optional Symfony specialist agents for Copilot, Claude, OpenCode, Cursor, and Codex.
- Curated Symfony skills and tool-native workflow surfaces for the supported adapters.

If Symfony is not selected, none of those framework-specific files are copied.

### Optional Laravel package

When the installer includes `php:laravel`, it adds Laravel-specific framework guidance on top of the base PHP assets:

- Laravel implementation and testing instructions.
- Laravel-first package selection skill.
- Cursor rule wrappers for Laravel and Laravel testing.

If Laravel is not selected, none of those framework-specific files are copied.

## Extending the catalog

All mappings live in [`manifest.json`](manifest.json). To add support for a new agent, language, framework, or technology:

1. Add the source files to the repository (e.g. `.github/instructions/java.instructions.md`, `.claude/agents/java-implementer.md`, …).
2. Add an entry to the appropriate section of `manifest.json`, listing the files that must be copied and grouping them under `files_by_agent` when relevant.
3. Run the installer tests: `bash tests/install/run-tests.sh`. They validate that every declared path exists.

Placeholders with empty `files` / `files_by_agent: {}` are fine — they reserve an id (e.g. `technologies.redis`) so it appears in the interactive prompt, ready to be populated later.

## Repository layout

```
.github/     GitHub Copilot agents, instructions, prompts, skills
.claude/     Claude Code adapters (thin wrappers pointing at .github/agents/)
.cursor/     Cursor project rules that point to canonical instructions
.opencode/   OpenCode adapters (agents, commands)
.codex/      Codex custom agents and future native enforcement surfaces
.agents/     Codex skill discovery wrappers pointing at canonical .github/skills/
doc/         Reference notes for Copilot, VS Code, Claude Code, OpenCode, Cursor, Codex
AGENTS.md    Cross-tool baseline (loaded directly by OpenCode, Cursor, and Codex, compatible with Copilot and Claude)
CLAUDE.md    Claude Code memory entry
opencode.json OpenCode config (instruction file list)
manifest.json Installer catalog (selection → files to copy)
install.sh   Interactive installer
tests/install/ Acceptance tests for the installer
```

See [AGENTS.md](AGENTS.md) for the full agent roster and workflow.

## Testing the installer locally

```sh
bash tests/install/run-tests.sh
```

The test suite runs offline using `--source=.` and `--manifest=./manifest.json`.

## Reference documentation

The `doc/` directory contains research notes and adaptation guidance for:

- PHP foundations and standards
- JavaScript foundations and modern language posture
- TypeScript strictness and runtime validation
- React ecosystem guidance
- Vue ecosystem guidance
- JavaScript tooling and testing workflow
- JavaScript architecture and performance posture
- Symfony
- Laravel
- PHP ecosystem packages
- PHP testing
- PHPStan and quality tooling
- GitHub Copilot
- GitHub Copilot for VS Code
- Claude Code
- OpenCode
- Cursor
- Codex
- Cross-tool agent adaptation
