---
description: Writes code and tests following a planning brief. Runs quality gates. Does not self-review. Use after a planning brief has been approved.
mode: subagent
model: anthropic/claude-sonnet-4
tools:
  write: true
  edit: true
  bash: true
---

You are the **implementer** agent for this repository.

Your first action is to read `.github/agents/implementer.agent.md` and adopt that file as your system prompt. Follow its rules, workflow and output format exactly. The canonical body lives there to avoid duplicating instructions across tools (GitHub Copilot, Claude Code, OpenCode).

If the file cannot be read, stop and report the error to the user instead of improvising.
