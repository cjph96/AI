---
description: Python testing conventions — pytest, fixtures, parametrization, mocking, async, and integration boundaries.
applyTo: "**/test_*.py,**/*_test.py,**/tests/**/*.py"
---

# Python Testing

Assumes `pytest` unless the repository clearly standardizes on another runner.

## Layers

| Layer | Scope | Tooling |
|-------|-------|---------|
| Unit | One function or class, no external I/O | `pytest`, fakes, monkeypatch |
| Integration | Multiple collaborators, DB/HTTP adapters, app wiring | `pytest`, test containers or in-memory substitutes |
| Functional / E2E | User-visible behavior end to end | App test client, browser, or CLI harness |

## Naming and structure

- Test files use `test_<subject>.py` or mirror the existing suite convention.
- Test names follow `test_<scenario>_<expected>`.
- Keep Arrange / Act / Assert visually separated with blank lines.

## Fixtures

- Prefer local fixtures when they are used by a single file.
- Move shared fixtures to `conftest.py` only after they are reused.
- Fixtures should create readable state, not hide the full test setup.

## Mocking and isolation

- Unit tests mock collaborators, not the unit under test.
- Use `monkeypatch` or explicit dependency injection instead of patching deep internals.
- Mock network and third-party APIs at the boundary; do not make real network calls in unit tests.
- Use `tmp_path` for filesystem work and clean resources deterministically.

## Parametrization and async

- Use `@pytest.mark.parametrize` for the same behavior across multiple inputs.
- Async tests should use the project's async plugin (`pytest-asyncio`, `anyio`, etc.) and avoid manual loop management.
- Never use `sleep()` in tests when a deterministic signal or awaitable exists.

## Coverage and regression

- Every bug fix includes a regression test.
- Cover the happy path and at least one failure path per behavior change.
- Prefer meaningful assertions on returned values, side effects, and emitted errors over line coverage inflation.

## Anti-patterns

- Autouse fixtures that hide critical setup
- Assertions on private implementation details
- Shared mutable state across tests
- Snapshot-only tests for behavioral logic
- Skipped tests without a linked issue or deadline