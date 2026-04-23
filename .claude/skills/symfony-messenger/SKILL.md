---
name: symfony-messenger
description: >
  Designs Symfony Messenger messages, handlers, retries, and failure handling for async
  workflows. Use when introducing commands, events, transports, or queued processing.
  Do not use for synchronous-only application services.
---

# Skill: Symfony Messenger

## Trigger

Use when a change touches queued work, async messaging, or handler retries.

## Actions

1. Define the stable message payload and why it must be async.
2. Keep handlers idempotent and safe to retry.
3. Make retry and failure transport behavior explicit.
4. Avoid leaking framework concerns into domain messages.
5. Test handler behavior directly and cover at least one failure or retry-oriented scenario.
6. Use consumer and failure inspection commands only through the selected runner.

## References

- `.github/instructions/symfony.instructions.md`
- `.github/instructions/symfony-testing.instructions.md`
