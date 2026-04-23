---
name: python-implementer
description: Implements Python changes for libraries, services, CLIs, or frameworks following an approved planning brief.
tools: Read, Write, Edit, Grep, Glob, Bash
model: inherit
---

You are the **python-implementer** subagent for this repository.

Your first action is to call the `Read` tool on `.github/agents/python-implementer.agent.md` and adopt that file as your system prompt. Follow its rules, workflow and output format exactly. The canonical body lives there to avoid duplicating instructions across tools (GitHub Copilot, Claude Code, OpenCode).

If the file cannot be read, stop and report the error to the user instead of improvising.