---
description: Laravel framework conventions layered on top of the generic PHP rules. Install only when the Laravel framework is selected.
applyTo: "**/*.php,config/**/*.php,routes/**/*.php,resources/views/**/*.blade.php,bootstrap/**/*.php,artisan,composer.json"
---

# Laravel — Framework Conventions

This file extends `.github/instructions/php.instructions.md` for Laravel projects.

## Execution environment

- Detect the established runner before suggesting commands: host PHP, Sail, Docker Compose, Herd, Valet, or DDEV.
- Prefer `php artisan`, `composer`, and the project's own task wrappers.

## Application boundaries

- Keep controllers thin: validate input, authorize, delegate, format the response.
- Business rules belong in actions, services, jobs, domain classes, or model methods with clear ownership.
- Validate external input with Form Requests or explicit validators at the boundary.
- Authorization belongs in policies, gates, middleware, or dedicated use-case checks, not only in Blade or JavaScript.

## Eloquent and persistence

- Keep query construction out of Blade templates and controllers when it starts carrying business rules.
- Use eager loading deliberately to avoid N+1 queries.
- Prefer query scopes, repositories, or dedicated query objects for reusable read patterns.
- Keep transactions explicit when multiple writes must succeed atomically.

## Queues, events, and jobs

- Jobs should be idempotent and serializable.
- Long-running or side-effect-heavy jobs need retries and failure handling configured intentionally.
- Events signal facts; listeners should stay focused and not hide business-critical writes.

## HTTP and presentation

- Use API Resources, DTOs, or explicit response objects when the HTTP contract should not mirror models directly.
- Blade views stay presentation-focused; avoid embedding data access or authorization decisions deep in templates.
- Follow the project's chosen frontend surface (Blade, Livewire, Inertia, API + SPA) instead of mixing patterns ad hoc.

## Security and configuration

- Never read secrets directly from `env()` outside config files.
- Use signed URLs, policies, validation rules, and middleware for boundary security.
- Filesystem, queue, mail, and cache integrations should be configured through Laravel abstractions rather than ad hoc clients in controllers.

## Quality checks

- Prefer the project's `make` targets first.
- Otherwise use the existing runner with Laravel-native checks where applicable:
  - `php artisan about`
  - `php artisan test`
  - `php artisan route:list`
  - `php artisan config:show` or equivalent project checks