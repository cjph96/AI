---
description: Git and branching conventions — trunk-based, atomic commits, PR etiquette.
applyTo: "**/*"
---

# Git Workflow

## Branching

- **Trunk-based**. Short-lived branches off `main` (or the repo's default).
- Branch names:
  - `feat/<id>/<slug>` — new feature.
  - `fix/<id>/<slug>` — bug fix.
  - `chore/<id>/<slug>` — tooling, deps, docs.
  - `refactor/<id>/<slug>` — behavior-preserving change.
  - Omit `<id>/` when no ticket exists.

## Commits

- **Atomic**: one logical change per commit; each commit compiles and passes tests.
- **Conventional commits** format:
  ```
  <type>(<scope>): <short summary>

  <body explaining why, not what>

  Refs: <id>
  ```
  Types: `feat`, `fix`, `chore`, `refactor`, `test`, `docs`, `perf`, `build`, `ci`.
- Imperative mood ("add", not "added").
- First line ≤ 72 chars.
- Reference issue IDs in the body (`Refs: AAA-123`) not only the branch name.

## Pull requests

- Title mirrors the top commit.
- Description sections:
  - **What** — one paragraph.
  - **Why** — user or business rationale.
  - **How** — technical approach + key trade-offs.
  - **Test evidence** — gate results, screenshots for UI.
  - **Rollback** — how to revert safely.
- Target size: ≤ ~100 changed LOC. Split larger changes.
- Self-review before requesting others.

## Forbidden without explicit user confirmation

- `git push --force` (prefer `--force-with-lease` when strictly needed and scoped to your own branch).
- `git reset --hard` on shared branches.
- Amending or rebasing commits already pushed to a shared branch.
- `--no-verify` to bypass hooks.
- Deleting branches / tags that others may be using.

## Merging

- Prefer **squash-and-merge** for feature branches unless the repo policy says otherwise.
- Rebase local branches on `main` before opening a PR.
- Do not merge your own PR without a review — unless the repo explicitly allows it and CI is green.

## Tags & releases

- Semver for libraries (`vMAJOR.MINOR.PATCH`).
- Release notes generated from conventional commits where possible.
