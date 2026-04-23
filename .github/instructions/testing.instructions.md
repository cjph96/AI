---
description: Generic testing policy — structure, naming, isolation, layers.
applyTo: "**/*.{test,spec}.{ts,tsx,js,jsx,mjs,cjs},**/tests/**/*,**/Test*.php,**/*Test.php"
---

# Testing — Generic

## Philosophy

- Tests are executable specifications. They document behavior.
- Every bug fix starts with a failing test.
- Prefer **TDD** (Red → Green → Refactor) for non-trivial logic.

## FIRST principles

- **Fast** — unit tests run in milliseconds.
- **Independent** — order must not matter.
- **Repeatable** — no reliance on clock, network, random without a seed.
- **Self-validating** — pass/fail without human inspection.
- **Timely** — written with (or before) the code.

## Structure: Arrange / Act / Assert

Use blank lines or comments to separate the three phases. Keep test bodies readable over clever.

## Naming

Choose the pattern the project already uses, otherwise:

- JS/TS (Vitest / Jest): `describe('Subject')` + `it('does X when Y')`.
- PHP (PHPUnit): `should<Result>(On|Given)<Scenario>` or `test_<scenario>_<result>`.
- Python (pytest): `test_<scenario>_<expected>`.

## Layers

| Layer | Purpose | Scope | External I/O |
|-------|---------|-------|---------------|
| Unit | Pure logic, behavior of one class/function | Single unit, mock collaborators | None |
| Integration | Collaborating units, adapters, DB/HTTP clients against fakes | Multiple classes, real wiring | Fakes / test containers |
| Functional / E2E | User-visible behavior end-to-end | Full app | Real or high-fidelity fakes |

Distribute ~80% unit / 15% integration / 5% e2e (the "test pyramid"). Adjust to the risk profile.

## Mocking policy

- Unit tests mock everything that is not the unit under test.
- Integration tests mock only the outside world (HTTP, third-party SDKs). Use in-memory DBs or test containers for persistence.
- E2E tests do not mock — they may stub unstable third parties.
- Never mock the type under test.
- Assert on observable behavior, not mock internals, unless the contract is the call itself.

## Anti-patterns

- Tests that pass when the code is deleted.
- `sleep()` / hard-coded waits.
- Shared mutable fixtures across tests.
- Assertions on private state.
- "Mega tests" asserting many unrelated behaviors.
- Disabling / skipping tests without a ticket and a deadline.

## Evidence of done

An implementer cannot claim "done" without:

- Test suite green.
- Coverage of the happy path and the error path for the new behavior.
- Reproduction test for any fixed bug (fails before, passes after).
