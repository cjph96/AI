# Symfony Knowledge Notes

This document summarizes the Symfony-specific material that is most relevant to this repository's PHP surface.

## Why Symfony matters here

Symfony is the robustness-first PHP framework in the curated learning path. It also exposes many standalone components that can be reused outside full-stack Symfony projects.

## Primary references

- Official Symfony documentation is the first stop for configuration, HTTP flow, DI, Messenger, Security, and testing.
- Symfony Components documentation matters even in non-Symfony repos because many packages and frameworks reuse the same components.

## What to learn first

1. Service container and autowiring.
2. HttpFoundation and routing.
3. Configuration and environment handling.
4. Doctrine integration and persistence boundaries.
5. Security, voters, and authentication flow.
6. Messenger and async workflows.

## Component mindset

- Prefer existing Symfony components before introducing a new third-party dependency for common concerns.
- Components such as HttpClient, Serializer, Console, Validator, Finder, and Process often cover the need with less ecosystem risk.
- In mixed stacks, component reuse is frequently a better choice than framework-specific packages.

## Mapping to repository skills

The repository already exposes focused Symfony skills for common architecture slices:

- `symfony-runner-selection`
- `symfony-functional-tests`
- `symfony-doctrine-relations`
- `symfony-api-platform-resources`
- `symfony-messenger`
- `symfony-voters`

Use those for execution details. Use the PHP base skills for framework-neutral package, standards, or tooling decisions.

## References

- Symfony docs: https://symfony.com/doc/current/index.html
- Symfony components: https://symfony.com/components