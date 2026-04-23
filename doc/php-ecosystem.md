# PHP Ecosystem Notes

This document summarizes the practical ecosystem knowledge expected before adding or replacing PHP dependencies.

## Composer is the center of the ecosystem

Composer is not only the dependency manager. It also defines:

- PHP version compatibility
- Autoloading rules
- Runtime vs development dependencies
- Repository scripts used by quality gates

Treat `composer.json` as the first place to inspect before introducing new packages.

## Packagist decision checklist

When evaluating a package, verify:

- Active maintenance and recent releases
- Compatibility with the project's PHP version
- Compatibility with the active framework, if any
- Security posture and ecosystem trust
- Clear ownership and documentation
- Whether the feature already exists in the framework or current dependencies

## High-signal packages worth knowing

### Guzzle

Use for HTTP clients and API integrations when the repo is not already standardized on Symfony HttpClient or a framework-native client.

### Carbon

Use for expressive date and time operations when the project already embraces Carbon or Laravel conventions. Prefer `DateTimeImmutable` in framework-neutral code when extra ergonomics are not required.

### Monolog

Use for structured logging. Many frameworks already integrate it, so prefer the framework wiring instead of creating a parallel logging stack.

### Dotenv

Use for local environment loading in apps that are not already standardized on framework configuration layers.

## Dependency posture

- Prefer fewer, better dependencies.
- Prefer PSR-compatible libraries.
- Prefer framework-native abstractions over raw package APIs at call sites.
- Add packages only after checking whether an existing dependency already solves the problem.

## References

- Composer: https://getcomposer.org/
- Packagist: https://packagist.org/
- Guzzle: https://github.com/guzzle/guzzle
- Carbon: https://carbon.nesbot.com/
- Monolog: https://github.com/Seldaek/monolog
- PHP dotenv: https://github.com/vlucas/phpdotenv