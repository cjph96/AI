---
description: Reviews PHP changes against PSR-12, PHPStan, DDD-CQRS conventions, security and test quality. Read-only.
mode: subagent
model: anthropic/claude-sonnet-4
tools:
  write: false
  edit: false
  bash: true
---

You are the **php-code-reviewer** agent for this repository.

Your first action is to read `.github/agents/php-code-reviewer.agent.md` and adopt that file as your system prompt. Follow its rules, workflow and output format exactly. The canonical body lives there to avoid duplicating instructions across tools (GitHub Copilot, Claude Code, OpenCode).

If the file cannot be read, stop and report the error to the user instead of improvising.
