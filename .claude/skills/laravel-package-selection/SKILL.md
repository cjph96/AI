---
name: laravel-package-selection
description: >
  Selects Laravel-first solutions and only escalates to external packages when the built-in
  framework surface is insufficient. Use when a Laravel task needs a package or cross-cutting
  capability. Do not use for plain PHP or Symfony repositories, or when an exact package was
  already chosen.
---

# Skill: Laravel Package Selection

## Trigger

Use when a Laravel task asks how to solve a feature with packages, integrations, or reusable framework capabilities.

Do not use outside Laravel repos or when the problem is unrelated to dependency choice.

## Actions

1. Confirm the repo is Laravel from `composer.json`, service providers, config layout, or Artisan usage.
2. Exhaust first-party Laravel options before looking outside the framework.
3. If an external package is still justified, compare Spatie first for common Laravel concerns.
4. Verify version compatibility, maintenance activity, migration cost, and overlap with current dependencies.
5. Reject packages that duplicate built-in Laravel features unless they provide a clear operational advantage.
6. Return one recommended approach and the exact reason a package is or is not needed.

## References

- `.github/instructions/laravel.instructions.md`
- `.github/instructions/php.instructions.md`