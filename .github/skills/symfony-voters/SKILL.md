---
name: symfony-voters
description: >
  Implements and validates Symfony voters and resource authorization paths.
  Use when access depends on the current actor and domain object state.
  Do not use for simple role checks that do not need object-level authorization.
---

# Skill: Symfony Voters

## Trigger

Use when authorization depends on the actor, subject, or resource state.

## Actions

1. Identify the resource, actor, and decision points.
2. Prefer a voter when access depends on domain state, not only static roles.
3. Keep the voter narrow and delegate complex business rules to domain or application services.
4. Cover allow, deny, and unauthenticated scenarios where relevant.
5. Verify that controller, API operation, or template usage applies the decision consistently.

## References

- `.github/instructions/symfony.instructions.md`
- `.github/instructions/security.instructions.md`
