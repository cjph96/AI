---
name: quality-gates
description: >
  Runs lint / format / static analysis / tests / build in deterministic order using Makefile
  targets first, direct commands as fallback. Emits a structured pass/fail report.
  Use when validating PR readiness or after an implementation.
  Do not use for implementing features or designing architecture.
---

# Skill: Quality Gates

## Trigger

Use when the user asks to:

- "run quality checks / gates"
- "is this ready to merge / PR?"
- "check lint / format / types / tests"
- "verify code quality"

Do not use for feature implementation.

## Actions

1. Detect the stack from the repo:
   - PHP: `composer.json`, `phpunit.xml.dist`, `phpstan.neon`, `.php-cs-fixer.*`.
   - JS/TS: `package.json` `scripts`, `tsconfig.json`, `eslint.config.*`, `vitest.config.*` / `jest.config.*`.
2. Prefer Makefile targets — list candidates with `make -n <target>` before running.
3. Execute gates in order, collecting results (do not stop on first failure unless a gate hard-blocks the next):

### Generic order
1. **Format** — `make format` → else `prettier --check` / `php-cs-fixer fix --dry-run`.
2. **Lint** — `make lint` → else `eslint .` / project's linter.
3. **Static analysis / typecheck** — `make typecheck` / `make phpstan` → else `tsc --noEmit` / `phpstan analyse`.
4. **Tests** — `make test` → else `npm test` / `vendor/bin/phpunit`.
5. **Build** — `make build` → else `npm run build` (skip if not applicable).

4. Parse outputs and map findings to `.claude/skills/quality-gates/assets/report-template.md`.
5. Return the report with a clear verdict:
   - `Ready for PR` — all required gates pass.
   - `Changes required` — one or more gates fail.

## Error handling

1. If the gate tool is missing, report the missing dependency and continue with direct fallback only when defined.
2. If output cannot be mapped to `path:line`, use `n/a` and include the raw tool message verbatim.
3. Mark optional gates (e.g. `rector`, `build`) as `SKIPPED` when the repo does not configure them.
4. Do not suggest baseline suppressions as a first option; prefer code fixes.

## References

- Report template: `.claude/skills/quality-gates/assets/report-template.md`
- Code quality policy: `.github/instructions/code-quality.instructions.md`
- Testing policy: `.github/instructions/testing.instructions.md`
