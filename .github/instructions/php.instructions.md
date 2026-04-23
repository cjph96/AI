---
description: PHP coding standards (PHP 8.x). Applies to all PHP source files. Includes DDD-CQRS conventions that apply only when the repo uses them.
applyTo: "**/*.php"
---

# PHP — Coding Standards

## Language baseline

- PHP 8.1+ minimum. Use modern features where helpful.
- `declare(strict_types=1);` in every PHP file.
- **PSR-12** formatting (enforced via php-cs-fixer).
- **PHPStan** must be clean at the project's level (target level ≥ 8 in greenfield code).

## Naming

- Classes: `PascalCase`. Methods / properties: `camelCase`. Constants: `SCREAMING_SNAKE_CASE`.
- No `I` prefix on interfaces.
- Exceptions: domain noun, no `Exception` suffix (e.g. `ShipmentNotFound`, not `ShipmentNotFoundException`).
- Verb semantics:
  - `get*` — always returns, throws on miss.
  - `find*` — returns `null` on miss.
  - `list*` / `search*` — returns a collection (may be empty).
  - `create*` — persists a new entity.
  - `update*` — mutates an existing entity.
  - `configure*` — idempotent configuration.

## Class design

- `final` by default; remove `final` only when extension is a documented design decision.
- Constructor property promotion; typed properties; `readonly` where appropriate.
- Prefer value objects over primitives (`Money`, `Email`, `Ulid`, etc.).
- DTOs: `public readonly` properties, no behavior.
- Entities: private state, behavior-oriented methods; mutation only through domain methods.
- Value Objects: immutable, validated at construction, equality by value.

## Architecture (when the repo uses DDD-CQRS)

Layering:

```
Domain           → pure, no framework imports
Application      → use-cases, depends on Domain interfaces
Infrastructure   → framework adapters (Doctrine, Symfony HTTP client, etc.)
```

- Domain has no imports from `Symfony\*`, `Doctrine\*`, or I/O libraries.
- Application depends on Domain *interfaces* (repositories, clients), never on Infrastructure.
- Infrastructure implements those interfaces.

CQRS:

- **Commands** — return `void`, mutate exactly one aggregate.
- **Queries** — return a DTO, no mutation.
- **Use-cases / Handlers** — single responsibility; no use-case calls another use-case directly.
- **Listeners** — one action; idempotent.
- **Domain Services** — stateless.

## Identifiers

- Prefer ULIDs over autoincrement IDs for new aggregates (`Symfony\Component\Uid\Ulid` or equivalent).

## Error handling

- Throw domain-specific exceptions.
- No silent `catch`. If you swallow, log with context and re-throw a domain error or a safe alternative.
- Never use `\Exception` as a base throw.
- Boundary (controller / CLI) maps domain exceptions to HTTP / exit codes.

## Dependency injection

- Constructor injection. No `new` for services.
- Services registered via `services.yaml` (Symfony) / provider (Laravel).
- Autowire by default; explicit wiring for ambiguous interfaces.

## Immutability & state

- Avoid static mutable state.
- Prefer pure functions / methods where possible.
- Clock / randomness behind injected abstractions (`ClockInterface`, etc.).

## Prohibited

- `@` error suppression.
- `extract()`, `eval`, `create_function`.
- Dynamic property creation on non-`stdClass` objects.
- Raw SQL via string concatenation — parameterized queries only.
- `var_dump` / `dd` / `error_log` debugging left in production paths.
