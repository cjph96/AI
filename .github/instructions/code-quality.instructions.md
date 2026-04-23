---
description: Generic code-quality policy applied to every source file regardless of language.
applyTo: "**/*.{ts,tsx,js,jsx,vue,mjs,cjs,php,py,go,rs,java,kt,rb,swift,cs,cpp,c,h,hpp,scala,sh,bash,zsh}"
---

# Code Quality — Generic

These rules apply to all code in the repository.

## Naming

- **Intention-revealing**. A name must answer "what does this do?" without reading the body.
- No abbreviations except well-known domain ones (`id`, `url`, `http`).
- Booleans start with `is`, `has`, `can`, `should`.
- Functions: verbs (`create`, `fetch`, `validate`).
- Classes / types: nouns (`User`, `OrderRepository`).
- Constants: `SCREAMING_SNAKE_CASE`; plain values: language-idiomatic (`camelCase` in JS/PHP, `snake_case` in Python, etc.).
- No `I` prefix on interfaces, no `Exception`/`Error` suffix on domain errors (the domain noun is enough).

## Functions

- Do one thing. If you need "and" to describe the function, split it.
- ≤ 20 lines as a target. Hard limit: a function must fit on one screen.
- ≤ 3 parameters; use a typed object / value object above that.
- Pure where possible; side-effects live at the boundary.
- Return early — minimize nesting.

## Types & contracts

- Make illegal states unrepresentable (use enums, discriminated unions, value objects).
- Validate at boundaries (HTTP / CLI / DB). Trust inside.
- Prefer immutability for values; mutate only with clear ownership.

## Error handling

- Throw / return domain-specific errors — never a generic `Error`/`Exception`.
- No silent `catch`. If you swallow, log with context and a reason.
- Boundary layer translates internal errors to API responses.

## Dependencies

- Depend on abstractions (interfaces) when a seam is needed. Do not over-abstract one-use collaborators.
- No circular dependencies.
- No new runtime dependency without a note in the report (why, alternatives considered, maintenance cost).

## Comments

- Explain **why**, not **what**. The code says what.
- `TODO` must include an issue / ticket reference.
- No commented-out code.

## Size & scope

- Target ≤ ~100 changed LOC per review cycle. Split otherwise.
- Do not refactor unrelated code in a feature PR.
- No "drive-by" fixes without a note in the report.

## Prohibited

- `--no-verify`, `--force`, `@ts-ignore`, `# noqa`, `phpcs:ignore` without a justification comment referencing a ticket.
- Dead code, unused imports, unused variables.
- Copy-pasted blocks — extract or consolidate.
