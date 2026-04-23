---
description: JavaScript and TypeScript testing conventions — Vitest/Jest, component tests, mocking, e2e.
applyTo: "**/*.{test,spec}.{ts,tsx,js,jsx,mjs,cjs},**/__tests__/**/*.{ts,tsx,js,jsx}"
---

# JavaScript / TypeScript Testing

Assumes Vitest or Jest. Adapt when the repo uses another runner.

## Layers

| Layer | Tooling | Scope |
|-------|---------|-------|
| Unit | Vitest / Jest | Pure functions, hooks, composables, stores |
| Component | Vitest + Testing Library / Vue Test Utils | One component, user-visible behavior |
| Integration | Vitest / Jest + MSW | Module + data layer against mocked HTTP |
| E2E | Playwright / Cypress | User journey through the real app |

## Naming

- `describe('Subject', () => { it('does X when Y', …) })`.
- File name mirrors source: `Foo.ts` → `Foo.test.ts` (collocated) or `__tests__/Foo.test.ts`.
- One top-level `describe` per subject.

## Structure

Arrange / Act / Assert separated by blank lines. Prefer explicit setup in the test body over heavy `beforeEach` when it aids readability (DAMP > DRY in tests).

## Component tests

- Use **Testing Library** / **Vue Test Utils** idioms: query by role, label, text — not by class / test-id unless nothing else fits.
- Assert what the user sees / does, not internal state.
- Fire events through `user-event` (or equivalent) for realistic behavior.
- Avoid snapshot tests as the primary assertion. Snapshots are acceptable for stable, small, intention-revealing outputs.

## Hooks / composables

- Test with the framework's testing hook utility (React Testing Library `renderHook`, Vue `@vue/test-utils` `withSetup`, etc.).
- Mock data-layer providers (QueryClient, Pinia, router) with minimal fakes.

## Mocking

- **Unit tests** mock collaborators; prefer dependency injection so you can pass a fake.
- **HTTP** — mock with **MSW** at the network layer; avoid mocking `fetch` directly.
- **Time** — `vi.useFakeTimers()` / `jest.useFakeTimers()`. Advance explicitly; never `await sleep`.
- **Randomness** — inject or seed; do not assert on random output.
- Do not mock the module under test.

## Async

- `await` the framework's utilities (`findBy…`, `waitFor`) instead of timed waits.
- Assert the final state after async settles; avoid racing with intermediate states.

## Data factories

- Collocate simple factories per test file; extract to `tests/support/factories/` when shared across ≥ 2 files.
- Factory signature: `createFoo(overrides?: Partial<Foo>): Foo` with sensible defaults.

## E2E

- Page-object or fixture pattern for common flows.
- Each test is independent and creates its own data.
- Use the real app wiring; stub only unstable third-party integrations.
- Capture screenshots and traces on failure.

## Coverage

- Cover the happy path and at least one error path per unit of behavior.
- Avoid percent-based gates as the only quality signal; they reward trivial tests.

## Anti-patterns

- `screen.debug()` committed.
- Hard-coded `setTimeout` in assertions.
- Tests that rely on ordering.
- Assertions on component internals (`.state`, private refs).
- Real network calls in unit/component suites.
- Skipped tests without a linked ticket.
