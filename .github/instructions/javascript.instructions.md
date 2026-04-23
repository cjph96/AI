---
description: JavaScript and TypeScript coding standards (Node and browser). Applies to all JS/TS source files and Vue/JSX templates.
applyTo: "**/*.{ts,tsx,js,jsx,mjs,cjs,vue}"
---

# JavaScript / TypeScript — Coding Standards

## Language baseline

- **TypeScript strict mode** when TS is used (`"strict": true`).
- ES modules; no CommonJS in new code unless the target runtime requires it.
- Avoid `any`. Prefer `unknown` + narrowing at the boundary.
- No `// @ts-ignore` / `// @ts-expect-error` without a justification comment and ticket.
- No `var`. Use `const` by default; `let` only when reassignment is necessary.

## Module organization

- Named exports. Use `default` only when a framework requires it (Next.js pages, some React routers, some Vue SFC tooling).
- No deep relative imports (`../../../`). Use tsconfig `paths` / Vite aliases.
- Barrel files (`index.ts`) only when they carry a curated public API — not as blanket re-exports.

## Naming

- Files:
  - Components: `PascalCase.tsx` / `PascalCase.vue`.
  - Hooks: `useThing.ts`.
  - Composables (Vue): `useThing.ts`.
  - Stores (Pinia / Zustand): `useThingStore.ts` / `thingStore.ts` — match the repo convention.
  - Utilities: `kebab-case.ts` or `camelCase.ts` — match the repo convention.
- Types / interfaces: `PascalCase`. No `I` prefix.
- React hooks must start with `use`.
- Event handlers: `onXxx` for props, `handleXxx` for in-component callbacks.

## Functions & components

- Pure when possible; side-effects in effects / hooks / services.
- Components: single responsibility. Split when JSX exceeds ~150 lines or when unrelated state coexists.
- Props: typed interface / type alias. No `React.FC` unless the project already uses it.
- Avoid inline object / array literals in hot-render props when referential equality matters — memoize.

## State management

- Local state first. Lift only when two siblings need it.
- Global state requires a justification (cross-route, cross-tab, auth, theming, etc.).
- Data fetching goes through the project's data layer (TanStack Query, SWR, RTK Query, Apollo, Pinia actions). Do not scatter raw `fetch`/`axios` in components when a layer exists.
- Cache invalidation is explicit, not magical.

## Error handling

- Throw subclasses of `Error` with semantic names (no `Error` suffix on domain errors).
- Promise chains: never leave `.catch` empty. Convert expected errors into typed results when that fits the project (e.g. `Result<T, E>` pattern).
- Boundary components / global handlers convert unknown errors to user-safe messages.

## Accessibility (for UI code)

- Semantic HTML first; `div` only for layout.
- Form inputs have labels (`<label for>` or `aria-label`).
- Interactive elements are keyboard-reachable and focusable.
- No color-only state signalling.
- Respect reduced motion preferences for animations.

## Performance

- Lazy-load routes and heavy modules.
- Tree-shakeable exports (no side-effectful top-level code in shared libs).
- Avoid `useEffect` for derived state — compute inline or use `useMemo` when measurable.
- Virtualize long lists (> ~200 items).

## Security

- No `dangerouslySetInnerHTML` / `v-html` without sanitization and a comment explaining why.
- `rel="noopener noreferrer"` on `target="_blank"`.
- Never persist secrets in `localStorage`/`sessionStorage` without a documented rationale.
- Validate inputs at API boundaries with a schema (zod, yup, valibot, class-validator, etc.).

## Prohibited without justification

- `any`, `unknown` as a return type, `Function`, `Object` as types.
- `@ts-ignore`, `@ts-nocheck`.
- `console.log` left in production code (use a logger abstraction).
- `eval`, `new Function`, dynamic `import` for user-controlled paths.
- Mutating function parameters or imports.
