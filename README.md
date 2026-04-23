# AI agent orchestration kit

A portable set of agents, skills, instructions and prompts that give **GitHub Copilot**, **Claude Code** and **OpenCode** a consistent *research → plan → implement → review* workflow.

The repository is the single source of truth. The [`install.sh`](install.sh) script copies a selected subset into any other project.

## Install in another project

Run the one-liner from the target project's root directory:

```sh
curl -fsSL https://raw.githubusercontent.com/cristianperez/AI/main/install.sh | bash
```

The script asks interactively for:

1. **Agents** — GitHub Copilot, Claude Code, OpenCode (multi-select, at least one).
2. **Languages** — PHP, JavaScript/TypeScript.
3. **Frameworks** per selected language (Symfony/Laravel for PHP; Vue/React/Vanilla for JS).
4. **Technologies** — PostgreSQL, Redis, AWS SQS.

Only the files mapped in [`manifest.json`](manifest.json) for the selected combination are copied. Framework add-ons stay optional: for example, selecting `php:symfony` installs Symfony-specific instructions, specialist agents, skills, and slash-command surfaces, while plain `php` does not.

### Requirements

- `bash`
- `curl`
- `jq` (required — the installer aborts with install hints if missing).

### Non-interactive mode

Useful for CI or scripted bootstrapping:

```sh
curl -fsSL https://raw.githubusercontent.com/cristianperez/AI/main/install.sh \
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
| `--repo=OWNER/REPO` | Source repository (default: `cristianperez/AI`, override via `$AI_TOOLS_REPO`) |
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
- Optional Symfony specialist agents for Copilot, Claude, and OpenCode.
- Curated Symfony skills and slash commands for Copilot and Claude.

If Symfony is not selected, none of those framework-specific files are copied.

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
.opencode/   OpenCode adapters (agents, commands)
doc/         Reference notes for Copilot, VS Code, Claude Code, OpenCode
AGENTS.md    Cross-tool baseline (loaded by all three tools)
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

- GitHub Copilot
- GitHub Copilot for VS Code
- Claude Code
- OpenCode
- Cross-tool agent adaptation
