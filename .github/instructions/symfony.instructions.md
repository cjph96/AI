---
description: Symfony framework conventions layered on top of the generic PHP rules. Install only when the Symfony framework is selected.
applyTo: "**/*.php,config/**/*.yaml,config/**/*.yml,templates/**/*.twig,composer.json"
---

# Symfony — Framework Conventions

This file extends `.github/instructions/php.instructions.md` for Symfony projects.

## Execution environment

- Detect the existing runner before proposing commands: host, Docker Compose, Symfony Docker / FrankenPHP, or DDEV.
- Reuse the project's established command wrapper instead of assuming host execution.
- Prefer `bin/console`, `composer`, and test commands exactly as the project already exposes them.

## Application boundaries

- Keep HTTP controllers thin: map request input, delegate to an application service or handler, map response.
- Validate external input at the boundary with Symfony Validator, Form Types, or API Platform metadata.
- Authorization belongs at the boundary and use-case entry. Prefer voters or security expressions for resource checks.
- Avoid embedding business rules in controllers, commands, subscribers, or Twig templates.

## Dependency injection

- Prefer constructor injection and autowiring.
- Bind interfaces explicitly when multiple implementations exist.
- Use tagged services for strategy selection instead of manual service locators.
- Service decoration is preferred over patching third-party services directly.

## Doctrine

- Persistence logic stays in repositories or infrastructure services, not in controllers.
- Model aggregates and relations deliberately; avoid leaking lazy-loading behavior into application code.
- Keep transaction boundaries explicit in application services when multiple writes must succeed atomically.
- Guard against N+1 queries in read paths; fetch what the use-case needs and no more.

## API Platform

- Prefer DTOs, state providers, and processors when the HTTP contract should not expose entities directly.
- Keep serialization groups small and intentional.
- Put security rules on operations or dedicated voters, not only in UI code.
- Versioning, filters, and pagination should be explicit and documented in the resource metadata.

## Messenger and async flows

- Messages should carry stable, serializable payloads.
- Handlers should be idempotent and safe to retry.
- Configure retries and failure transports deliberately; do not leave failure handling implicit.
- Long-running or side-effect-heavy handlers need observability and safe re-entry semantics.

## Console commands and schedulers

- Console commands orchestrate use-cases; they should not contain domain logic.
- Return explicit exit codes and clear operator-facing output.
- Scheduled or async jobs must be safe to run more than once.

## Security

- Prefer voters for authorization decisions involving domain objects.
- Use rate limiting for public or abuse-prone endpoints.
- Form handling, validators, and API metadata must reject unknown or invalid input early.
- Never rely on Twig or client-side checks for authorization.

## Frontend integration

- Twig components, forms, and templates should stay presentation-focused.
- Avoid passing entities with mutable behavior deep into templates when a view model or DTO is clearer.
- Use Symfony UX or Twig Components according to the existing project style; do not introduce them by default.

## Quality checks

- Prefer the project's `make` targets first.
- Otherwise use the existing runner with these Symfony-native checks when applicable:
  - `composer validate`
  - `bin/console lint:container`
  - `bin/console lint:yaml config`
  - `bin/console lint:twig templates`
  - `phpstan analyse`
