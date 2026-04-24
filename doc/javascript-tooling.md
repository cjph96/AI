# JavaScript Tooling Notes

This document summarizes the practical tooling baseline expected before shaping a modern JS/TS delivery workflow.

## Core references

- Vite is the default reference for fast local development and bundling in modern browser projects.
- Vitest is the preferred reference for unit, integration, and component tests in Vite-centered repos.
- Playwright is the default E2E testing reference.
- Tailwind CSS is the utility-first styling reference.
- shadcn/ui is the reference for copy-in, accessible React component primitives when the repo accepts that model.

## Tool selection posture

- Prefer the repository's existing toolchain before adding a parallel stack.
- Use Vite for greenfield browser projects unless the framework already chooses the builder.
- Prefer Vitest over Jest in Vite-first projects.
- Prefer Playwright for E2E coverage when cross-browser confidence and traces matter.

## Styling posture

- Tailwind is a good fit when design work benefits from utility composition and a shared token system.
- Do not add Tailwind to a repo that already has an established CSS architecture without a migration reason.
- Use shadcn/ui only when the React codebase is comfortable owning copied component code and customizing it locally.

## References

- Vite: https://vitejs.dev/
- Vitest: https://vitest.dev/
- Playwright: https://playwright.dev/
- Tailwind CSS: https://tailwindcss.com/
- shadcn/ui: https://ui.shadcn.com/