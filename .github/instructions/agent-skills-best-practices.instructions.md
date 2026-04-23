---
description: Standard for authoring and maintaining agent skills in this repository.
applyTo: ".github/skills/**/SKILL.md,.github/skills/**/references/**,.github/skills/**/assets/**"
---

# Agent Skills — Best Practices

## 1. Skill structure

```text
<skill-name>/
├── SKILL.md           # orchestration layer
├── references/        # detailed rules (optional)
└── assets/            # output templates (optional)
```

Rules:

- `SKILL.md` is the entry point.
- Keep `references/` and `assets/` one level deep.
- No README inside a skill — `SKILL.md` is the README.
- No `scripts/` inside skills.

## 2. Frontmatter

Every `SKILL.md` starts with YAML:

```yaml
---
name: <lowercase-kebab-case>   # must match directory name
description: >
  Trigger-oriented one-paragraph summary.
  Include negative triggers ("Do not use for…").
---
```

Keep the description specific to avoid false activations.

## 3. Progressive disclosure

1. `SKILL.md` — high-level numbered steps.
2. `references/*` — dense rules and decision tables.
3. `assets/*` — output templates.

Do not embed large templates or schemas in `SKILL.md`.

## 4. Instruction style

- Numbered steps in strict chronological order.
- Third-person imperative voice.
- Explicit decision branches (`if / else`, skip rules).
- Consistent terminology across files.

## 5. Deterministic execution

- Prefer `make` / `npm run` / `composer` scripts.
- Define explicit fallback commands only when needed.
- Keep fallback rules in `SKILL.md` or `references/`.

## 6. Pathing convention

- Root-relative paths from the consumer repo root.
- When authored in a template repo, use paths that resolve to `.github/...` in consumer repos.
- Skills should note the installed layout when ambiguity is possible.

## 7. Validation workflow

After editing any skill:

1. **Discovery** — list 3 prompts that should trigger the skill and 3 that should not. Refine frontmatter to remove false positives/negatives.
2. **Logic simulation** — mentally execute the steps; flag any that force guesswork.
3. **Edge cases** — ask 3–5 hostile QA questions; add fallbacks.
4. **Structural checks** — `SKILL.md` < 500 lines; required subdirectories exist; paths use `/` and are explicit.

## 8. Anti-patterns

- Vague descriptions (`"react skills"`, `"general helper"`).
- Prose-only skills without deterministic actions.
- Duplicating execution logic across `instructions/` and `skills/`.
- Deeply nested `references/` trees.
- Hidden logic outside `SKILL.md` and `references/`.

## 9. Split of responsibilities

- `instructions/*.instructions.md` — policy and cross-cutting constraints.
- `skills/<name>/SKILL.md` — trigger + execution flow.
- `skills/<name>/references/*` — detailed rules.
- `skills/<name>/assets/*` — reusable templates.
