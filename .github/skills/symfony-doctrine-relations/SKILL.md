---
name: symfony-doctrine-relations
description: >
  Plans Doctrine entity relationships, ownership, cascade rules, and persistence checks
  in Symfony projects. Use when adding or changing OneToOne, OneToMany, ManyToOne, or
  ManyToMany mappings. Do not use for read-only query tuning without mapping changes.
---

# Skill: Symfony Doctrine Relations

## Trigger

Use when entity modeling or relation mapping changes.

## Actions

1. Identify the aggregate boundary and owning side first.
2. Choose the smallest relation type that matches the domain invariant.
3. Decide cascade and orphan-removal behavior explicitly; do not leave it implicit.
4. Keep bidirectional relations only when the read model actually needs them.
5. Plan migration impact and the integration tests needed to prove persistence semantics.
6. Validate ownership, cascade behavior, and loading assumptions with repository or kernel-level tests.

## References

- `.github/instructions/php.instructions.md`
- `.github/instructions/symfony.instructions.md`
