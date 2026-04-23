---
description: Symfony testing conventions for PHPUnit or Pest, functional HTTP tests, Doctrine fixtures, Messenger, and security.
applyTo: "**/*Test.php,**/tests/**/*.php"
---

# Symfony — Testing Conventions

This file extends `.github/instructions/testing.instructions.md` and `.github/instructions/php-testing.instructions.md` for Symfony projects.

## Test framework and runner

- Reuse the project's existing test framework: Pest if already installed, otherwise PHPUnit.
- Run tests through the same environment wrapper the project uses in daily work.
- Do not introduce Pest into a PHPUnit-only project, or vice versa, without explicit request.

## Test layers

- Unit tests: pure domain or application code with mocked collaborators.
- Integration tests: `KernelTestCase` for container wiring, repositories, custom services, and Doctrine behavior.
- Functional tests: `WebTestCase` for HTTP endpoints, controllers, API Platform operations, and security behavior.
- End-to-end browser tests are optional and should not replace functional coverage.

## HTTP and API tests

- Assert on observable HTTP behavior: status code, payload, headers, redirects, side effects.
- For API Platform, cover operation-level security, serialization, filters, pagination, and validation failures.
- Prefer focused fixtures per scenario over broad global test data.

## Doctrine and fixtures

- Use factories or fixtures consistent with the project, such as Zenstruck Foundry when already present.
- Keep fixture setup close to the test; avoid giant shared fixtures that hide intent.
- Verify relation ownership, cascade behavior, and persistence boundaries in integration tests.

## Messenger and async flows

- Test handler behavior directly at the unit or integration layer.
- Cover retry-safe and idempotent behavior for messages with external effects.
- Validate failure handling and transport assumptions when Messenger is part of the change.

## Security tests

- Voter or access-control changes require allow and deny scenarios.
- Cover anonymous, authenticated, and unauthorized actor paths where relevant.
- Validation tests must cover malformed, boundary, and forbidden payloads.

## Good defaults

- Keep `WebTestCase` assertions specific; avoid snapshotting entire HTML or JSON bodies unless stable by design.
- One scenario per test. Name tests after user-visible behavior.
- Use the smallest layer that proves the behavior; do not boot the kernel for pure domain rules.

## Validation commands

- Prefer `make test`, `make phpunit`, or the project's canonical test target.
- When available, use narrow filters before the full suite:
  - `phpunit --filter Functional`
  - `phpunit --filter Api`
  - `phpunit --filter Messenger`
  - `phpunit --filter Voter`
