---
description: Python coding standards for applications, CLIs, and libraries. Applies to all Python source files.
applyTo: "**/*.py"
---

# Python — Coding Standards

## Language baseline

- Python 3.11+ minimum in new projects; match the existing project version when lower.
- Prefer standard library features before adding dependencies.
- Type annotations on public functions, methods, and module-level constants.
- Use `pathlib.Path`, `enum.Enum`, `dataclasses`, and `typing` idioms instead of bespoke helpers.

## Naming

- Modules, packages, functions, and variables use `snake_case`.
- Classes, exceptions, and dataclasses use `PascalCase`.
- Constants use `SCREAMING_SNAKE_CASE`.
- Booleans start with `is_`, `has_`, `can_`, or `should_` when that improves clarity.

## Modules and functions

- Keep modules focused; split files when they grow beyond one coherent responsibility.
- Prefer pure functions for domain logic and keep I/O at the boundary.
- Avoid functions with more than 3 positional parameters; use a dataclass, TypedDict, or settings object when needed.
- No mutable default arguments.
- Prefer early returns over nested branches.

## Typing and data modeling

- Use precise types (`Sequence[str]`, `Mapping[str, Any]`, `datetime`, `UUID`) instead of broad `list` / `dict` when intent matters.
- Validate external data at boundaries with the project's chosen schema system (Pydantic, attrs, dataclasses + manual validation, etc.).
- Prefer immutable value types (`frozen=True`) where mutation is not required.

## Errors and logging

- Raise semantic exceptions; avoid bare `Exception` for domain failures.
- No bare `except:` and no silent `except Exception:`.
- Use the project's logging abstraction; do not leave `print()` debugging in production paths.
- Preserve traceback context with `raise ... from exc` when translating errors.

## Async and resources

- Use `async` only when the stack already uses async I/O or concurrency benefits are clear.
- `async` call paths stay end-to-end async; do not block them with sync network or filesystem calls when avoidable.
- Use context managers for files, transactions, and network/session lifecycles.

## Project hygiene

- Prefer `pyproject.toml` as the canonical tool configuration file.
- Keep imports grouped: standard library, third-party, local.
- Follow the project's formatter and linter (`ruff`, `black`, `isort`, etc.) rather than hand-formatting.

## Prohibited without justification

- `from module import *`
- Mutable module-level state for request or session data
- Hidden side effects during import time
- `eval`, `exec`, `pickle` on untrusted input
- `subprocess` with shell interpolation of user input