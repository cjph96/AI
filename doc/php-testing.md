# PHP Testing Notes

This document captures the testing side of the PHP learning path for this repository.

## Primary tools

- PHPUnit remains the baseline testing standard for PHP projects.
- Pest is a modern, expressive layer on top of PHPUnit and is useful when the repository already chose it.

## Default testing posture

- Follow the repository's existing runner and conventions instead of mixing PHPUnit and Pest styles arbitrarily.
- Cover behavior at the smallest useful layer first.
- Use fast unit tests for domain and service logic.
- Use integration or functional tests for framework wiring, persistence, HTTP behavior, and authorization paths.

## Practical decision rules

1. If the repo already uses PHPUnit only, keep using PHPUnit.
2. If the repo already uses Pest, stay within Pest conventions.
3. If both exist, prefer the dominant style in the touched module.
4. Add at least one failure-path assertion for user-visible or boundary logic.

## What senior-level PHP testing looks like

- Clear test names with behavior and scenario.
- Minimal fixtures and focused setup.
- Explicit assertions on outputs and side effects.
- No hidden reliance on global state.
- Mock only true collaborators, not value objects or trivial data holders.

## Related tooling

- PHPStan finds whole classes of defects before runtime.
- PHP CS Fixer keeps code style deterministic.
- Rector accelerates controlled modernization.

## References

- PHPUnit: https://phpunit.de/
- Pest: https://pestphp.com/