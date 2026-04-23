---
description: Go testing conventions — table-driven tests, subtests, helpers, and integration boundaries.
applyTo: "**/*_test.go"
---

# Go Testing

## Layers

| Layer | Scope | Tooling |
|-------|-------|---------|
| Unit | One function, method, or small package slice | `testing`, fakes, table-driven cases |
| Integration | Real package wiring, DB/HTTP adapters, CLI flows | `testing`, `httptest`, test containers |
| End-to-end | User-visible service or command behavior | Full binary, server, or browser harness |

## Style

- Prefer table-driven tests for the same behavior across multiple inputs.
- Use subtests with `t.Run` for clear case names.
- Extract common setup into helpers marked with `t.Helper()`.
- Keep assertions close to the behavior under test.

## Isolation

- Use `t.TempDir()` for filesystem state.
- Use `httptest` for HTTP servers and clients.
- Avoid real network calls in unit tests.
- Do not share mutable global state across tests.

## Parallelism

- Use `t.Parallel()` only when the test data and environment are isolated.
- Avoid parallelizing tests that mutate process-wide state, environment variables, or temporary shared resources.

## Coverage and regressions

- Every bug fix adds a regression test.
- Cover success and error paths for new behavior.
- Prefer focused behavioral assertions over opaque golden-file churn unless text output stability is the real contract.

## Anti-patterns

- Assertions spread across unrelated branches in one test
- Silent helper failures without `t.Fatalf` / `require`-style handling
- Timing-based tests that rely on sleeps instead of signals or contexts
- Large shared fixtures that hide the test contract