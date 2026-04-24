---
name: javascript-react-foundations
description: >
  Applies React-specific component, hook, state, and data-fetching defaults after the
  repository is already known to use React. Use when React components, hooks, context,
  routing, or client/server state placement is central to the task. Do not use for
  framework-neutral JS/TS work or Vue-specific changes.
---

# Skill: JavaScript React Foundations

## Trigger

Use when the task is clearly React-specific and the important question is how to shape components, hooks, state, or data fetching.

Do not use for framework-neutral JS/TS decisions, Vue work, or quality-gate-only validation.

## Actions

1. Confirm the repo really uses React or a React meta-framework from `package.json`, routing structure, and component file extensions.
2. Read `doc/javascript-react.md` and `.github/instructions/javascript.instructions.md`.
3. Apply these React defaults unless the repository already standardizes otherwise:
   - function components and hooks
   - typed props without `React.FC` unless the repo already uses it
   - reusable behavior in hooks, not duplicated across components
   - server state through the established query layer before custom local caching
   - local state first, context or store only when scope is genuinely shared
4. Prefer TanStack Query for server state and Zustand only when a lightweight shared client store is justified and the repo does not already use another state layer.
5. Keep effects for synchronization work, not for derived state or avoidable orchestration.
6. If the repo uses Next, Remix, or another React meta-framework, follow its routing, data, and server/client boundaries instead of creating parallel conventions.
7. Return a short framework-specific checklist or decision summary before code is written.

## References

- `.github/instructions/javascript.instructions.md`
- `doc/javascript-react.md`
- `doc/javascript-tooling.md`