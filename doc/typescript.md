# TypeScript Knowledge Notes

This document summarizes the practical TypeScript knowledge expected before building or reviewing scalable JS/TS systems.

## Core references

- Total TypeScript is the default reference for advanced type-system behavior and hard-to-read compiler errors.
- TypeScript Deep Dive is the long-form reference for compiler mechanics, declaration files, generics, and advanced patterns.
- Zod is the default reference for runtime schema validation aligned with static types.

## Strict TypeScript baseline

Treat these as defaults whenever the repository uses TypeScript:

- Prefer `strict` mode and preserve it during refactors.
- Avoid `any`; use `unknown` at boundaries and narrow it immediately.
- Model domain states with discriminated unions instead of boolean combinations.
- Prefer explicit return types on exported functions and public methods.
- Use type aliases and interfaces intentionally; do not create both for the same concept without a reason.

## Runtime safety posture

- Static types do not validate runtime input.
- Parse external data at the boundary with a schema library such as Zod.
- Derive types from schemas when it reduces drift between validation and application logic.
- Reject unknown fields for request payloads unless the product explicitly requires pass-through behavior.

## Advanced topics worth mastering

- Conditional types, mapped types, template-literal types, and variance basics.
- Generic constraints that preserve inference instead of forcing call sites to annotate everything.
- Module augmentation and declaration files when integrating third-party libraries.
- Utility types as composition tools, not as a replacement for domain-specific names.

## Practical learning path

1. Start with strictness, unions, narrowing, generics, and utility types.
2. Add schema validation and type-safe API boundaries.
3. Learn advanced type composition only after the simple model stops scaling.
4. Treat readability as a constraint; the cleverest type is not automatically the best type.

## References

- Total TypeScript Concepts: https://www.totaltypescript.com/concepts
- TypeScript Deep Dive: https://basarat.gitbook.io/typescript/
- Zod: https://zod.dev/