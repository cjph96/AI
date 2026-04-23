---
description: Run Symfony-oriented quality checks with the correct runner.
---

Use `.github/skills/symfony-runner-selection/SKILL.md` to pick the correct execution environment, then follow `.github/skills/quality-gates/SKILL.md` for: ${input:goal}.

Prioritize Symfony-native checks when configured by the repo, such as `composer validate`, `bin/console lint:container`, `bin/console lint:yaml config`, and `bin/console lint:twig templates`.
