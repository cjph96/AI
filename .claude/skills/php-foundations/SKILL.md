---
name: php-foundations
description: >
  Applies modern PHP 8.x foundations before planning or implementing framework-neutral PHP
  changes. Use when a task needs PSR-4 layout, Composer autoload alignment, typing, and
  version-aware language choices. Do not use for Symfony- or Laravel-specific workflows or
  for tooling-only validation.
---

# Skill: PHP Foundations

## Trigger

Use when the task asks to add, refactor, or review PHP code and the important question is the base shape of the solution.

Do not use for Symfony-specific execution details, Laravel package choice, or quality-gate-only requests.

## Actions

1. Read `.github/instructions/php.instructions.md`, `.github/instructions/code-quality.instructions.md`, and `.github/instructions/security.instructions.md`.
2. Detect from `composer.json`:
   - minimum PHP version
   - PSR-4 autoload roots
   - active framework or absence of one
3. Confirm the code shape matches modern PHP defaults:
   - `declare(strict_types=1);` for new files
   - explicit parameter and return types
   - final classes unless extension is required
   - immutable value objects where invariants matter
   - framework code kept at boundaries when architecture requires it
4. Check that class namespace, file path, and Composer autoload mapping agree before creating or moving files.
5. If the repo is Symfony-heavy, hand off to the relevant Symfony skill after the base decisions are made.
6. If the repo is Laravel-heavy and the task is dependency-driven, hand off to `laravel-package-selection`.
7. Return a short implementation checklist or decision summary before code is written.

## References

- `.github/instructions/php.instructions.md`
- `.github/instructions/code-quality.instructions.md`
- `.github/instructions/security.instructions.md`