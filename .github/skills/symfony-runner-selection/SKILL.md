---
name: symfony-runner-selection
description: >
  Selects the correct runner for Symfony commands in host, Docker Compose, Symfony Docker,
  or DDEV environments. Use when commands, tests, or console tasks must run in a Symfony repo.
  Do not use for pure code review or non-Symfony projects.
---

# Skill: Symfony Runner Selection

## Trigger

Use when the task needs `bin/console`, `composer`, lint, or test commands in a Symfony project.

## Actions

1. Detect the environment in this order:
   - `.ddev/` directory -> DDEV.
   - `compose.yaml` or `docker-compose.yml` with `frankenphp` or `caddy` service -> Symfony Docker.
   - any compose file -> Docker Compose.
   - otherwise host.
2. Derive the project's canonical command prefix.
3. Emit four commands:
   - runner prefix
   - console command
   - composer command
   - test command
4. Reuse the detected form consistently for the rest of the task.

## Output

Return the selected runner and the exact command forms to use.

## References

- `.github/instructions/symfony.instructions.md`
