---
description: Laravel testing conventions for Pest or PHPUnit, HTTP endpoints, Eloquent, queues, events, and framework fakes.
applyTo: "**/*Test.php,**/tests/**/*.php"
---

# Laravel Testing

This file extends `.github/instructions/php-testing.instructions.md` for Laravel projects.

## Test layers

- Feature tests cover HTTP endpoints, middleware, policies, validation, and response contracts.
- Unit tests cover pure domain logic and small framework-independent services.
- Integration tests cover persistence, queues, events, notifications, mail, and storage boundaries with Laravel fakes or real test infrastructure as appropriate.

## Conventions

- Match the existing runner: Pest or PHPUnit.
- Prefer factories and state builders over manual fixture arrays.
- Use `RefreshDatabase` or the project's equivalent reset strategy for persistence tests.
- Authenticate via `actingAs()` or guards explicitly; do not bypass auth with hidden globals.

## Framework fakes

- Use `Queue::fake()`, `Bus::fake()`, `Event::fake()`, `Mail::fake()`, `Notification::fake()`, and `Storage::fake()` when the contract is the dispatch or side effect.
- Assert the visible contract, not internal implementation details.
- Avoid over-faking in tests that are meant to exercise real framework wiring.

## HTTP and JSON assertions

- Assert status, validation errors, redirects, session state, and JSON payload shape explicitly.
- Cover both success and failure paths for controllers and APIs.
- Prefer request builders and helper methods when they improve readability, not to hide the behavior under test.

## Anti-patterns

- Reaching into the database directly when an HTTP assertion would prove the behavior better
- Shared seeded state that makes test order matter
- Feature tests that mock the framework internals they are meant to validate
- Skipped tests without a linked issue or deadline