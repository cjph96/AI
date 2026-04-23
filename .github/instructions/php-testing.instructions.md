---
description: PHP testing conventions — PHPUnit layers, naming, mocking, helpers, factories.
applyTo: "**/*Test.php,**/tests/**/*.php"
---

# PHP Testing

Assumes PHPUnit. Adapt helper names to the repo's convention when it differs.

## Test layers

| Suite | Scope | Mocking |
|-------|-------|---------|
| `unit` | One class | Mock all collaborators |
| `integration` | Class + real dependencies (DB / filesystem via fakes / containers) | Mock only external services |
| `functional` | HTTP / CLI end-to-end | No internal mocks; may stub external HTTP |

Configure in `phpunit.xml.dist` with `<testsuite>` elements when the repo does not already do so.

## Naming

- Test class: `ClassUnderTestTest` placed under `tests/<Suite>/<Namespace>/`.
- Test method: `should<Result>(On|Given)<Scenario>`.
  - `shouldReturnOrderGivenExistingId`.
  - `shouldThrowOrderNotFoundOnMissingId`.
- Use `#[Test]` attribute (PHP 8) or `/** @test */` annotation consistent with the repo.

## Structure

Arrange / Act / Assert separated by blank lines. Prefer `self::assert…` or the repo's preferred style consistently.

## Mocking policy

- PHPUnit `createMock` / `createStub` for collaborators. Prophecy only if the codebase already uses it.
- Mock variable name: append `Mock` (e.g. `$repositoryMock`).
- Type-hint as intersection: `private Repository&MockObject $repositoryMock;`.
- Assert behavior (state), not implementation (call counts), unless the contract *is* the call.

### Helper method convention

For shared setup extract helpers:

- `given{Type}({args})` — stubbing helper. Example: `givenRepositoryReturnsOrder($order)`.
- `expect{Expectation}({args})` — verification helper. Example: `expectPublishesOrderCreated()`.

### Multiple invocations on the same mock

Use a sequential invocation helper (see `skills/` area) rather than repeated `->method('x')` chains that silently overwrite.

## Test data

- Prefer **TestDataFactory** classes over inline construction when:
  - The object has ≥ 3 params, OR
  - It has required value-object parameters, OR
  - The same object is used in ≥ 2 tests.
- Factory location: mirror the production path, inserting `Support/` after the context. Example:
  - Prod: `src/App/Booking/Domain/Order.php`.
  - Factory: `tests/App/Booking/Support/Domain/OrderFactory.php`.
- Factory API:
  - `create(…)` — returns a valid instance with sensible defaults.
  - `filled()` — only when optional params exist; returns a fully populated instance.

## Fixtures

- Integration / functional tests use DB fixtures from a small set of factories, not SQL dumps, whenever possible.
- Reset state between tests (transactional rollback or recreate schema).

## Assertions

- `assertSame` over `assertEquals` when type matters.
- Exception assertions: `$this->expectException(Specific::class);` (never catch `\Throwable` to assert).
- Time: inject a fake clock; never `sleep` in tests.

## Anti-patterns

- Tests depending on each other's order.
- `@group skip` / `markTestSkipped` without a ticket.
- Asserting on the text of error messages (assert on exception class + optional code).
- Real HTTP / DB / clock in unit suites.
