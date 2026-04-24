# JavaScript Architecture Notes

This document captures the architecture and performance concepts that matter once the basics of JS/TS delivery are already in place.

## Core references

- SOLID in TypeScript is the architecture reference for translating object and boundary principles into TS code.
- Web Vitals is the performance reference for user-centric frontend metrics.
- Micro Frontends is the reference for splitting very large frontend systems into independently delivered slices.

## Architecture posture

- Separate transport, state orchestration, rendering, and domain logic.
- Treat server state, client state, and derived view state as different concerns.
- Prefer feature-oriented module boundaries over generic `utils` growth.
- Introduce cross-application decomposition only when team scale, delivery independence, or deployment boundaries justify the operational cost.

## Performance posture

- Measure user-centric metrics, not only bundle size.
- Use Core Web Vitals to guide performance priorities.
- Optimize loading strategy, rendering waterfalls, and interaction responsiveness before chasing micro-optimizations.
- Keep caching, prefetching, and lazy loading explicit.

## References

- SOLID in TypeScript: https://github.com/sergiomontoro/solid-typescript
- Web Vitals: https://web.dev/vitals/
- Micro Frontends: https://micro-frontends.org/