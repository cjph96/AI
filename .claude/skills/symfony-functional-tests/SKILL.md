---
name: symfony-functional-tests
description: >
  Designs and implements Symfony functional tests with WebTestCase for controllers,
  HTTP endpoints, API Platform operations, and security flows. Use when user-visible
  HTTP behavior changes. Do not use for pure domain logic or config-only changes.
---

# Skill: Symfony Functional Tests

## Trigger

Use when routes, controllers, API Platform operations, auth, validation, or serialization behavior changes.

## Actions

1. Confirm the behavior at the HTTP boundary: request, actor, response, and side effects.
2. Prefer `WebTestCase` and the smallest fixture setup that proves the scenario.
3. Cover at least one success case and one failure case.
4. Assert status code, payload shape, key headers, and business-visible side effects.
5. If security is involved, cover anonymous, allowed, and denied paths as applicable.
6. Run the narrowest relevant functional suite before widening scope.

## References

- `.github/instructions/symfony-testing.instructions.md`
- `.github/instructions/security.instructions.md`
