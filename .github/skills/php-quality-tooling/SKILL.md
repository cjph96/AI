---
name: php-quality-tooling
description: >
  Runs and structures the modern PHP quality stack around PHPUnit or Pest, PHPStan,
  PHP CS Fixer, and Rector. Use when validating PHP work, modernizing legacy PHP, or
  tightening analysis and test coverage. Do not use for framework-specific behavior
  design or package selection.
---

# Skill: PHP Quality Tooling

## Trigger

Use when the task needs PHP tests, static analysis, formatting, or modernization workflow guidance.

Do not use for dependency-choice tasks or pure architectural planning.

## Actions

1. Detect the active toolchain from `Makefile`, `composer.json`, `phpunit.xml*`, `phpstan.neon*`, `.php-cs-fixer*`, and `rector.php`.
2. Prefer project commands in this order:
   - `make <target>`
   - `composer <script>`
   - direct vendor binary
3. Establish the repository's canonical test runner:
   - PHPUnit when the repo uses PHPUnit only
   - Pest when the repo is Pest-first
   - the dominant local convention when both are present
4. Run or prescribe the stack in order:
   1. PHP CS Fixer or equivalent formatting check
   2. PHPStan on the narrowest impacted scope
   3. PHPUnit or Pest on the touched slice
   4. Rector as an optional dry-run modernization pass when configured
5. Prefer code fixes over suppressions or baselines. Use baselines only as temporary debt markers.
6. Report which tools are configured, which commands are canonical, and what failed or remains missing.

## References

- `.github/instructions/php.instructions.md`
- `.github/instructions/php-testing.instructions.md`
- `.github/instructions/testing.instructions.md`