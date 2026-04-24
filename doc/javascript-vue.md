# Vue Knowledge Notes

This document captures the Vue-specific baseline expected for modern application work in this repository.

## Core references

- Vue official docs are the default reference for Composition API, reactivity, components, and ecosystem guidance.
- Pinia is the preferred reference for modern shared state in Vue 3.
- Nuxt is the default meta-framework reference when SSR, routing conventions, or full-stack Vue delivery are in scope.

## Modern Vue baseline

- Prefer Vue 3 with the Composition API.
- Use `<script setup>` unless the repository already standardizes on another SFC style.
- Move reusable logic into composables instead of mixins.
- Keep templates declarative and push branching or data transformation into computed values or composables.

## State posture

- Local component state first.
- Promote shared state to Pinia only when multiple features, routes, or persistent sessions need it.
- Keep remote data management separate from UI-only state.

## Nuxt posture

- Reach for Nuxt when the problem needs routing conventions, SSR, static generation, or server endpoints integrated with Vue.
- Prefer Nuxt-native data and routing primitives over parallel custom infrastructure.

## References

- Vue: https://vuejs.org/guide/introduction.html
- Pinia: https://pinia.vuejs.org/
- Nuxt: https://nuxt.com/