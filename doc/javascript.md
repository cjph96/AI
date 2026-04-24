# JavaScript Knowledge Notes

This document captures the baseline knowledge expected for modern JavaScript work in this repository.

## Core references

- JavaScript.info is the default reference for language fundamentals, browser APIs, async flows, modules, and modern platform features.
- Clean Code JavaScript is the naming and function-shaping reference when readability or maintainability is the question.
- Airbnb JavaScript Style Guide is the consistency baseline for everyday code style decisions.
- Patterns.dev is the design-pattern and rendering-strategy reference for modern frontend applications.

## Modern JavaScript baseline

Treat these as the default posture for new or refactored JavaScript code:

- Prefer ES modules, `const`, and explicit imports over dynamic or implicit patterns.
- Keep data validation at the boundary instead of trusting API responses or user input.
- Prefer pure functions and small modules; push side effects to dedicated adapters or framework lifecycle boundaries.
- Model async flows explicitly with `async` / `await`, cancellation, and clear error paths.
- Keep naming intention-revealing; avoid boolean flags that hide multiple behaviors in a single function.

## Standards that matter most

### Language fluency

- Be comfortable with closures, prototype inheritance, iterators, generators, and the event loop.
- Understand value vs reference semantics to avoid accidental mutation.
- Know when to use objects, maps, sets, arrays, and records based on access patterns.

### Clean code habits

- Functions should usually do one thing and explain themselves through names.
- Prefer guard clauses over deep nesting.
- Separate domain logic from rendering or transport glue.

## Practical learning path

1. Internalize the language core: scope, closures, modules, async control flow, and object composition.
2. Adopt clean-code habits for naming, function shape, and error handling.
3. Learn common architectural patterns for state, rendering, data fetching, and performance.
4. Then specialize into TypeScript, React, Vue, or framework-specific delivery.

## References

- JavaScript.info: https://javascript.info/
- Clean Code JavaScript: https://github.com/ryanmcdermott/clean-code-javascript
- Airbnb JavaScript Style Guide: https://github.com/airbnb/javascript
- Patterns.dev: https://www.patterns.dev/