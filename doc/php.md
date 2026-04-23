# PHP Knowledge Notes

This document captures the baseline knowledge expected for modern PHP work in this repository.

## Core references

- PHP: The Right Way is the default reference for everyday PHP practices, project layout, dependency management, and security-minded coding.
- PHP-FIG PSRs define the interoperability baseline. The minimum set to internalize is PSR-1, PSR-4, and PSR-12.
- PHPWatch is the change radar for PHP 8.x features, deprecations, and migration notes.

## Modern PHP baseline

Treat these as the default posture for new or refactored PHP code:

- Target PHP 8.x features intentionally: union types, enums, attributes, constructor promotion, readonly properties, first-class callables, and improved type-system ergonomics.
- Prefer explicit types on parameters, returns, and promoted properties.
- Use `declare(strict_types=1);` in new PHP source files.
- Prefer immutable value objects for validated concepts.
- Prefer final classes unless extension is a real requirement.
- Throw domain-specific exceptions instead of generic `\Exception`.
- Keep framework code at the boundaries when the repo follows DDD or hexagonal layering.

## Standards that matter most

### PSR-1 and PSR-12

- Keep one class per file.
- Use consistent visibility, imports, spacing, and control-structure formatting.
- Favor intention-revealing names over short names.

### PSR-4

- Namespace and directory layout must align with Composer autoload mappings.
- New modules should fit the existing autoload roots before introducing new ones.
- Refactors that move classes must update namespaces and Composer config together.

## Composer mindset

- `composer.json` is the source of truth for PHP version support, autoloading, scripts, and package constraints.
- Prefer repository scripts or Makefile targets over ad hoc commands.
- Audit dependency additions for maintenance, security, and framework fit before adding them.

## Version awareness

- Check PHPWatch when a change relies on a recently added language feature.
- Match language features to the minimum PHP version declared in `composer.json`.
- Prefer changes that reduce upgrade friction instead of relying on deprecated behavior.

## Practical learning path

1. Internalize Composer, namespaces, autoloading, and PSR-12 formatting.
2. Get comfortable with PHP 8.x typing and immutability patterns.
3. Learn package vetting and ecosystem tradeoffs.
4. Add testing, static analysis, and automated refactoring to daily workflow.
5. Then specialize into Symfony, Laravel, or framework-neutral service design.

## References

- PHP: The Right Way: https://phptherightway.com/
- PHP-FIG PSRs: https://www.php-fig.org/psr/
- PHPWatch: https://php.watch/