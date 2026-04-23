---
name: symfony-api-platform-resources
description: >
  Shapes API Platform resources, operations, DTOs, providers, processors, filters, and
  serialization rules in Symfony projects. Use when building or changing API resources.
  Do not use for non-API Symfony changes.
---

# Skill: Symfony API Platform Resources

## Trigger

Use when an API Platform resource or operation is being created or changed.

## Actions

1. Decide whether the API contract should expose an entity directly or a DTO resource.
2. Define operations, input and output shapes, filters, pagination, and versioning intentionally.
3. Prefer providers and processors when HTTP behavior should stay decoupled from persistence models.
4. Keep serialization groups minimal and operation-specific.
5. Put authorization on operations or dedicated voters.
6. Cover success, validation failure, serialization, and authorization behavior with focused tests.

## References

- `.github/instructions/symfony.instructions.md`
- `.github/instructions/symfony-testing.instructions.md`
