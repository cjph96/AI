# React Knowledge Notes

This document captures the React-specific baseline expected for modern application work in this repository.

## Core references

- React.dev is the default reference for hooks, rendering mental models, effects, and modern React guidance.
- TanStack Query is the preferred reference for server-state fetching, caching, and invalidation in React apps.
- Zustand is the lightweight global-state reference when local state and context are no longer enough.

## Modern React baseline

- Prefer function components and hooks.
- Keep components focused on one responsibility and push reusable behavior into hooks.
- Distinguish local UI state from server state and global app state; do not solve all three with one abstraction.
- Avoid effect-heavy code. Derive data during render when possible and reserve effects for real synchronization work.

## State posture

### Server state

- Use TanStack Query or the repository's existing query layer for API-backed state.
- Make cache keys explicit and invalidation intentional.

### Local and global state

- Start with component state.
- Lift state only when siblings need to coordinate.
- Introduce Zustand for small or medium shared state when context becomes noisy and the repo does not already standardize on another store.

## Performance posture

- Split large pages into route-level and feature-level chunks.
- Measure before memoizing. Prefer structural fixes before adding `useMemo` or `useCallback` everywhere.
- Learn React concurrency primitives well enough to recognize when `startTransition` or deferred rendering improves responsiveness.

## References

- React: https://react.dev/
- TanStack Query: https://tanstack.com/query/latest
- Zustand: https://github.com/pmndrs/zustand