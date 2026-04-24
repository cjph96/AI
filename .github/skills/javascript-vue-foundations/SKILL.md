---
name: javascript-vue-foundations
description: >
  Applies Vue-specific component, composable, store, and meta-framework defaults after the
  repository is already known to use Vue. Use when Vue 3 components, composables, Pinia,
  or Nuxt boundaries are central to the task. Do not use for framework-neutral JS/TS work
  or React-specific changes.
---

# Skill: JavaScript Vue Foundations

## Trigger

Use when the task is clearly Vue-specific and the important question is how to shape components, composables, state, or Nuxt integration.

Do not use for framework-neutral JS/TS decisions, React work, or quality-gate-only validation.

## Actions

1. Confirm the repo really uses Vue or Nuxt from `package.json`, app structure, and SFC files.
2. Read `doc/javascript-vue.md` and `.github/instructions/javascript.instructions.md`.
3. Apply these Vue defaults unless the repository already standardizes otherwise:
   - Vue 3 Composition API
   - `<script setup>` for new SFCs
   - reusable behavior in composables instead of mixins
   - computed values and composables for derivation instead of template-heavy logic
   - local component state first, Pinia only when scope is genuinely shared
4. Prefer Pinia for shared state and Nuxt-native primitives when the repo uses Nuxt.
5. Keep remote data concerns separate from UI-only state and avoid pushing transport logic directly into templates.
6. If Nuxt is present, follow its routing, data-loading, and server/client boundaries instead of building a parallel app shell.
7. Return a short framework-specific checklist or decision summary before code is written.

## References

- `.github/instructions/javascript.instructions.md`
- `doc/javascript-vue.md`
- `doc/javascript-tooling.md`