---
name: php-package-selection
description: >
  Selects PHP dependencies with a Composer-first and framework-aware decision process.
  Use when a PHP change needs a new package or when an existing dependency should be
  replaced. Do not use when the package is already mandated or when the task is pure
  implementation with no dependency choice.
---

# Skill: PHP Package Selection

## Trigger

Use when the task asks which PHP package to add, replace, or standardize on.

Do not use when the repository already chose the dependency or when the task is only about code style or tests.

## Actions

1. Inspect `composer.json`, current vendor usage, and the touched module to confirm whether the problem is already solved in-repo.
2. Prefer the narrowest existing option in this order:
   - PHP built-ins or SPL
   - framework-native feature or Symfony component
   - existing project dependency
   - new third-party package
3. For common categories, start the shortlist with the high-signal defaults:
   - HTTP -> Guzzle or Symfony HttpClient
   - dates -> `DateTimeImmutable` or Carbon when the repo already leans that way
   - logs -> Monolog through framework wiring
   - env loading -> framework config first, Dotenv only when needed
4. Vet each candidate for maintenance, PHP-version compatibility, security posture, documentation quality, and PSR interoperability.
5. If the repo is Laravel, compare first-party Laravel options and Spatie before a broader Packagist search.
6. Output one recommendation, one acceptable fallback, and the reason the rejected options lost.

## References

- `.github/instructions/php.instructions.md`
- `doc/php-ecosystem.md`
- `doc/php-laravel.md`