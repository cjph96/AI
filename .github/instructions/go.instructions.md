---
description: Go coding standards for services, CLIs, and libraries. Applies to all Go source files.
applyTo: "**/*.go"
---

# Go — Coding Standards

## Language baseline

- Target the version declared in `go.mod`; prefer Go 1.22+ in new projects.
- All code must be `gofmt`-clean.
- Prefer the standard library before adding dependencies.

## Packages and files

- Package names are short, lower-case, and singular when possible.
- Keep one responsibility per package; avoid god packages.
- File names use `snake_case.go` when descriptive names help, otherwise match the project style.

## APIs and interfaces

- Accept interfaces where a seam is needed; return concrete types when possible.
- Define interfaces close to the consumer, not the producer.
- `context.Context` is the first parameter for request-scoped or cancelable operations.
- Avoid boolean flag parameters when an options struct would be clearer.

## Errors

- Return errors, do not panic for expected failures.
- Wrap errors with `%w` when adding context.
- Error messages start lowercase and avoid trailing punctuation.
- Use sentinel errors sparingly; prefer typed errors or `errors.Is` / `errors.As` checks when needed.

## Concurrency

- Launch goroutines only when there is a clear ownership and lifecycle.
- Every goroutine has a shutdown path or bounded lifetime.
- Protect shared state explicitly with channels or synchronization primitives.
- Do not ignore returned errors from goroutines or background workers.

## Data and state

- Prefer zero-value-safe structs where practical.
- Keep struct fields unexported unless part of a public contract.
- Avoid hidden mutation through package globals.

## Project hygiene

- Use `go test`, `go vet`, and the project's linter before claiming completion.
- Keep imports tidy; rely on tooling instead of manual grouping.
- Generated code lives next to its source or under the project convention and should not be edited manually.

## Prohibited without justification

- Panics in request handlers or long-running service paths
- Unbounded goroutine creation
- Swallowing errors with `_ = err`
- Reflection-heavy APIs when simpler typed code is available
- `context.Background()` inside request-scoped code where a caller context exists