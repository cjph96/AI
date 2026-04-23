# PHPStan Knowledge Notes

This document summarizes how PHPStan should be approached in a modern PHP workflow.

## Why PHPStan matters

PHPStan shifts defect detection left by finding type and API misuse without executing the code. In practice, it is one of the highest leverage tools for moving from "working PHP" to "maintainable PHP".

## Core posture

- Treat PHPStan as part of normal development, not as a one-off audit.
- Prefer fixing type issues over suppressing them.
- Increase strictness deliberately and only after the current level is green.
- Keep baselines temporary and review them during cleanup work.

## Workflow

1. Detect the configured level and custom rules.
2. Run PHPStan on the smallest impacted scope first.
3. Fix signature, nullability, generics, and collection-shape issues at the source.
4. Re-run tests after significant type or signature changes.
5. Only then consider Rector or wider modernization.

## Common upgrade wins

- Replace untyped arrays with shaped arrays or DTOs.
- Narrow `mixed` and nullable flows.
- Add return types and property types.
- Remove dead branches exposed by impossible types.

## Related tools

- PHP CS Fixer complements formatting, not typing.
- Rector can automate many upgrades once PHPStan exposes the weak spots.
- PHPUnit or Pest verifies runtime behavior after static fixes.

## References

- PHPStan: https://phpstan.org/
- PHP CS Fixer: https://cs.symfony.com/
- Rector: https://getrector.com/