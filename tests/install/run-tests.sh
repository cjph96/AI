#!/usr/bin/env bash
# tests/install/run-tests.sh — acceptance tests for install.sh.
#
# No network required: all tests use --source and --manifest pointing at the
# local repository.

set -euo pipefail

REPO_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
INSTALLER="${REPO_ROOT}/install.sh"
MANIFEST="${REPO_ROOT}/manifest.json"

PASS=0
FAIL=0
FAILED_NAMES=""

pass() { printf '  \033[32mPASS\033[0m %s\n' "$1"; PASS=$((PASS+1)); }
fail() { printf '  \033[31mFAIL\033[0m %s — %s\n' "$1" "$2"; FAIL=$((FAIL+1)); FAILED_NAMES="$FAILED_NAMES\n  - $1"; }

mktmp() { mktemp -d 2>/dev/null || mktemp -d -t install-test; }

# -----------------------------------------------------------------------------
# 1. Manifest is valid JSON and every declared path exists.
# -----------------------------------------------------------------------------
test_manifest_valid() {
  local name="manifest is valid JSON"
  if jq empty "$MANIFEST" >/dev/null 2>&1; then pass "$name"; else fail "$name" "invalid JSON"; return; fi

  name="every manifest path exists in the repo"
  local missing=""
  local path
  while IFS= read -r path; do
    [ -z "$path" ] && continue
    [ -f "${REPO_ROOT}/${path}" ] || missing="${missing}\n  ${path}"
  done < <(
    jq -r '
      [
        .base.files[]?,
        (.agents[]?.files[]?),
        (.languages[]?.files_by_agent[]?[]?),
        (.languages[]?.frameworks[]?.files_by_agent[]?[]?),
        (.technologies[]?.files_by_agent[]?[]?)
      ] | .[]
    ' "$MANIFEST"
  )
  if [ -z "$missing" ]; then pass "$name"; else fail "$name" "missing:$missing"; fi
}

# -----------------------------------------------------------------------------
# 2. Non-interactive install copies expected files.
# -----------------------------------------------------------------------------
test_basic_install() {
  local name="non-interactive install copies files (copilot + php)"
  local dest; dest=$(mktmp)
  if bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --agents=copilot --languages=php --non-interactive >/dev/null 2>&1; then
    [ -f "${dest}/.github/agents/orchestrator.agent.md" ] \
      && [ -f "${dest}/.github/instructions/php.instructions.md" ] \
      && [ -f "${dest}/.github/skills/php-foundations/SKILL.md" ] \
      && [ -f "${dest}/.github/prompts/plan-feature.prompt.md" ] \
      && [ -f "${dest}/.github/prompts/implement-feature.prompt.md" ] \
      && [ -f "${dest}/.github/prompts/review-code.prompt.md" ] \
      && [ -f "${dest}/AGENTS.md" ] \
      && [ ! -d "${dest}/.claude" ] \
      && [ ! -d "${dest}/.opencode" ] \
      && pass "$name" || fail "$name" "expected/unexpected files"
  else
    fail "$name" "installer exited non-zero"
  fi
  rm -rf "$dest"
}

# -----------------------------------------------------------------------------
# 3. Language filtering: JS selection must not pull PHP files.
# -----------------------------------------------------------------------------
test_language_filtering() {
  local name="js selection does not include php files"
  local dest; dest=$(mktmp)
  bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --agents=copilot --languages=javascript --non-interactive >/dev/null 2>&1
  if [ -f "${dest}/.github/instructions/javascript.instructions.md" ] \
      && [ -f "${dest}/.github/agents/javascript-research-planner.agent.md" ] \
      && [ -f "${dest}/.github/agents/javascript-implementer.agent.md" ] \
      && [ -f "${dest}/.github/agents/javascript-code-reviewer.agent.md" ] \
      && [ -f "${dest}/.github/skills/javascript-foundations/SKILL.md" ] \
      && [ -f "${dest}/.github/skills/javascript-package-selection/SKILL.md" ] \
      && [ -f "${dest}/.github/skills/javascript-quality-tooling/SKILL.md" ] \
      && [ -f "${dest}/doc/javascript.md" ] \
      && [ -f "${dest}/doc/typescript.md" ] \
      && [ -f "${dest}/doc/javascript-tooling.md" ] \
      && [ -f "${dest}/doc/javascript-architecture.md" ] \
      && [ ! -f "${dest}/.github/skills/javascript-react-foundations/SKILL.md" ] \
      && [ ! -f "${dest}/.github/skills/javascript-vue-foundations/SKILL.md" ] \
      && [ ! -f "${dest}/doc/javascript-react.md" ] \
      && [ ! -f "${dest}/doc/javascript-vue.md" ] \
      && [ ! -f "${dest}/.github/instructions/php.instructions.md" ] \
      && [ ! -f "${dest}/.github/agents/php-research-planner.agent.md" ] \
      && [ ! -f "${dest}/.github/skills/php-foundations/SKILL.md" ]; then
    pass "$name"
  else
    fail "$name" "php files leaked or js files missing"
  fi
  rm -rf "$dest"
}

test_javascript_framework_install_copilot() {
  local name="react framework installs optional copilot assets"
  local dest; dest=$(mktmp)
  if bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --agents=copilot --languages=javascript --frameworks='javascript:react' --non-interactive >/dev/null 2>&1; then
    if [ -f "${dest}/.github/skills/javascript-foundations/SKILL.md" ] \
        && [ -f "${dest}/.github/skills/javascript-package-selection/SKILL.md" ] \
        && [ -f "${dest}/.github/skills/javascript-quality-tooling/SKILL.md" ] \
        && [ -f "${dest}/.github/skills/javascript-react-foundations/SKILL.md" ] \
        && [ -f "${dest}/doc/javascript-react.md" ] \
        && [ ! -f "${dest}/.github/skills/javascript-vue-foundations/SKILL.md" ] \
        && [ ! -f "${dest}/doc/javascript-vue.md" ]; then
      pass "$name"
    else
      fail "$name" "react copilot assets missing"
    fi
  else
    fail "$name" "installer exited non-zero"
  fi
  rm -rf "$dest"
}

test_javascript_framework_install_copilot_vue() {
  local name="vue framework installs optional copilot assets"
  local dest; dest=$(mktmp)
  if bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --agents=copilot --languages=javascript --frameworks='javascript:vue' --non-interactive >/dev/null 2>&1; then
    if [ -f "${dest}/.github/skills/javascript-foundations/SKILL.md" ] \
        && [ -f "${dest}/.github/skills/javascript-package-selection/SKILL.md" ] \
        && [ -f "${dest}/.github/skills/javascript-quality-tooling/SKILL.md" ] \
        && [ -f "${dest}/.github/skills/javascript-vue-foundations/SKILL.md" ] \
        && [ -f "${dest}/doc/javascript-vue.md" ] \
        && [ ! -f "${dest}/.github/skills/javascript-react-foundations/SKILL.md" ] \
        && [ ! -f "${dest}/doc/javascript-react.md" ]; then
      pass "$name"
    else
      fail "$name" "vue copilot assets missing"
    fi
  else
    fail "$name" "installer exited non-zero"
  fi
  rm -rf "$dest"
}

test_javascript_framework_install_claude() {
  local name="vue framework installs optional claude assets"
  local dest; dest=$(mktmp)
  if bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --agents=claude --languages=javascript --frameworks='javascript:vue' --non-interactive >/dev/null 2>&1; then
    if [ -f "${dest}/.claude/skills/javascript-foundations/SKILL.md" ] \
        && [ -f "${dest}/.claude/skills/javascript-package-selection/SKILL.md" ] \
        && [ -f "${dest}/.claude/skills/javascript-quality-tooling/SKILL.md" ] \
        && [ -f "${dest}/.claude/skills/javascript-vue-foundations/SKILL.md" ] \
        && [ -f "${dest}/doc/javascript-vue.md" ] \
        && [ ! -f "${dest}/.claude/skills/javascript-react-foundations/SKILL.md" ] \
        && [ ! -f "${dest}/doc/javascript-react.md" ] \
        && [ -f "${dest}/.claude/agents/javascript-implementer.md" ]; then
      pass "$name"
    else
      fail "$name" "vue claude assets missing"
    fi
  else
    fail "$name" "installer exited non-zero"
  fi
  rm -rf "$dest"
}

test_javascript_framework_install_claude_react() {
  local name="react framework installs optional claude assets"
  local dest; dest=$(mktmp)
  if bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --agents=claude --languages=javascript --frameworks='javascript:react' --non-interactive >/dev/null 2>&1; then
    if [ -f "${dest}/.claude/skills/javascript-foundations/SKILL.md" ] \
        && [ -f "${dest}/.claude/skills/javascript-package-selection/SKILL.md" ] \
        && [ -f "${dest}/.claude/skills/javascript-quality-tooling/SKILL.md" ] \
        && [ -f "${dest}/.claude/skills/javascript-react-foundations/SKILL.md" ] \
        && [ -f "${dest}/doc/javascript-react.md" ] \
        && [ ! -f "${dest}/.claude/skills/javascript-vue-foundations/SKILL.md" ] \
        && [ ! -f "${dest}/doc/javascript-vue.md" ]; then
      pass "$name"
    else
      fail "$name" "react claude assets missing"
    fi
  else
    fail "$name" "installer exited non-zero"
  fi
  rm -rf "$dest"
}

test_javascript_framework_install_opencode() {
  local name="react framework installs optional opencode assets"
  local dest; dest=$(mktmp)
  if bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --agents=opencode --languages=javascript --frameworks='javascript:react' --non-interactive >/dev/null 2>&1; then
    if [ -f "${dest}/.opencode/agents/javascript-implementer.md" ] \
        && [ -f "${dest}/.claude/skills/javascript-foundations/SKILL.md" ] \
        && [ -f "${dest}/.claude/skills/javascript-package-selection/SKILL.md" ] \
        && [ -f "${dest}/.claude/skills/javascript-quality-tooling/SKILL.md" ] \
        && [ -f "${dest}/.claude/skills/javascript-react-foundations/SKILL.md" ] \
        && [ -f "${dest}/doc/javascript-react.md" ] \
        && [ ! -f "${dest}/.claude/skills/javascript-vue-foundations/SKILL.md" ] \
        && [ ! -f "${dest}/doc/javascript-vue.md" ]; then
      pass "$name"
    else
      fail "$name" "react opencode assets missing"
    fi
  else
    fail "$name" "installer exited non-zero"
  fi
  rm -rf "$dest"
}

test_javascript_framework_install_opencode_vue() {
  local name="vue framework installs optional opencode assets"
  local dest; dest=$(mktmp)
  if bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --agents=opencode --languages=javascript --frameworks='javascript:vue' --non-interactive >/dev/null 2>&1; then
    if [ -f "${dest}/.opencode/agents/javascript-implementer.md" ] \
        && [ -f "${dest}/.claude/skills/javascript-foundations/SKILL.md" ] \
        && [ -f "${dest}/.claude/skills/javascript-package-selection/SKILL.md" ] \
        && [ -f "${dest}/.claude/skills/javascript-quality-tooling/SKILL.md" ] \
        && [ -f "${dest}/.claude/skills/javascript-vue-foundations/SKILL.md" ] \
        && [ -f "${dest}/doc/javascript-vue.md" ] \
        && [ ! -f "${dest}/.claude/skills/javascript-react-foundations/SKILL.md" ] \
        && [ ! -f "${dest}/doc/javascript-react.md" ]; then
      pass "$name"
    else
      fail "$name" "vue opencode assets missing"
    fi
  else
    fail "$name" "installer exited non-zero"
  fi
  rm -rf "$dest"
}

test_javascript_framework_install_cursor() {
  local name="vue framework installs optional cursor assets"
  local dest; dest=$(mktmp)
  if bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --agents=cursor --languages=javascript --frameworks='javascript:vue' --non-interactive >/dev/null 2>&1; then
    if [ -f "${dest}/.cursor/rules/javascript.mdc" ] \
        && [ -f "${dest}/.cursor/rules/javascript-testing.mdc" ] \
        && [ -f "${dest}/.claude/skills/javascript-foundations/SKILL.md" ] \
        && [ -f "${dest}/.claude/skills/javascript-package-selection/SKILL.md" ] \
        && [ -f "${dest}/.claude/skills/javascript-quality-tooling/SKILL.md" ] \
        && [ -f "${dest}/.claude/skills/javascript-vue-foundations/SKILL.md" ] \
        && [ -f "${dest}/doc/javascript-vue.md" ] \
        && [ ! -f "${dest}/.claude/skills/javascript-react-foundations/SKILL.md" ] \
        && [ ! -f "${dest}/doc/javascript-react.md" ]; then
      pass "$name"
    else
      fail "$name" "vue cursor assets missing"
    fi
  else
    fail "$name" "installer exited non-zero"
  fi
  rm -rf "$dest"
}

test_javascript_framework_install_cursor_react() {
  local name="react framework installs optional cursor assets"
  local dest; dest=$(mktmp)
  if bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --agents=cursor --languages=javascript --frameworks='javascript:react' --non-interactive >/dev/null 2>&1; then
    if [ -f "${dest}/.cursor/rules/javascript.mdc" ] \
        && [ -f "${dest}/.cursor/rules/javascript-testing.mdc" ] \
        && [ -f "${dest}/.claude/skills/javascript-foundations/SKILL.md" ] \
        && [ -f "${dest}/.claude/skills/javascript-package-selection/SKILL.md" ] \
        && [ -f "${dest}/.claude/skills/javascript-quality-tooling/SKILL.md" ] \
        && [ -f "${dest}/.claude/skills/javascript-react-foundations/SKILL.md" ] \
        && [ -f "${dest}/doc/javascript-react.md" ] \
        && [ ! -f "${dest}/.claude/skills/javascript-vue-foundations/SKILL.md" ] \
        && [ ! -f "${dest}/doc/javascript-vue.md" ]; then
      pass "$name"
    else
      fail "$name" "react cursor assets missing"
    fi
  else
    fail "$name" "installer exited non-zero"
  fi
  rm -rf "$dest"
}

test_javascript_framework_install_codex() {
  local name="react framework installs optional codex assets"
  local dest; dest=$(mktmp)
  if bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --agents=codex --languages=javascript --frameworks='javascript:react' --non-interactive >/dev/null 2>&1; then
    if [ -f "${dest}/.github/skills/javascript-foundations/SKILL.md" ] \
        && [ -f "${dest}/.github/skills/javascript-package-selection/SKILL.md" ] \
        && [ -f "${dest}/.github/skills/javascript-quality-tooling/SKILL.md" ] \
        && [ -f "${dest}/.agents/skills/javascript-foundations/SKILL.md" ] \
        && [ -f "${dest}/.agents/skills/javascript-package-selection/SKILL.md" ] \
        && [ -f "${dest}/.agents/skills/javascript-quality-tooling/SKILL.md" ] \
        && [ -f "${dest}/.github/skills/javascript-react-foundations/SKILL.md" ] \
        && [ -f "${dest}/.agents/skills/javascript-react-foundations/SKILL.md" ] \
        && [ -f "${dest}/doc/javascript-react.md" ] \
        && [ ! -f "${dest}/.agents/skills/javascript-vue-foundations/SKILL.md" ] \
        && [ ! -f "${dest}/doc/javascript-vue.md" ]; then
      pass "$name"
    else
      fail "$name" "react codex assets missing"
    fi
  else
    fail "$name" "installer exited non-zero"
  fi
  rm -rf "$dest"
}

test_javascript_framework_install_codex_vue() {
  local name="vue framework installs optional codex assets"
  local dest; dest=$(mktmp)
  if bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --agents=codex --languages=javascript --frameworks='javascript:vue' --non-interactive >/dev/null 2>&1; then
    if [ -f "${dest}/.github/skills/javascript-foundations/SKILL.md" ] \
        && [ -f "${dest}/.github/skills/javascript-package-selection/SKILL.md" ] \
        && [ -f "${dest}/.github/skills/javascript-quality-tooling/SKILL.md" ] \
        && [ -f "${dest}/.agents/skills/javascript-foundations/SKILL.md" ] \
        && [ -f "${dest}/.agents/skills/javascript-package-selection/SKILL.md" ] \
        && [ -f "${dest}/.agents/skills/javascript-quality-tooling/SKILL.md" ] \
        && [ -f "${dest}/.github/skills/javascript-vue-foundations/SKILL.md" ] \
        && [ -f "${dest}/.agents/skills/javascript-vue-foundations/SKILL.md" ] \
        && [ -f "${dest}/doc/javascript-vue.md" ] \
        && [ ! -f "${dest}/.agents/skills/javascript-react-foundations/SKILL.md" ] \
        && [ ! -f "${dest}/doc/javascript-react.md" ]; then
      pass "$name"
    else
      fail "$name" "vue codex assets missing"
    fi
  else
    fail "$name" "installer exited non-zero"
  fi
  rm -rf "$dest"
}

test_python_and_go_install() {
  local name="python and go selections install their native assets"
  local dest; dest=$(mktmp)
  if bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --agents=copilot --languages=python,go --non-interactive >/dev/null 2>&1; then
    if [ -f "${dest}/.github/instructions/python.instructions.md" ] \
        && [ -f "${dest}/.github/agents/python-research-planner.agent.md" ] \
        && [ -f "${dest}/.github/agents/python-implementer.agent.md" ] \
        && [ -f "${dest}/.github/agents/python-code-reviewer.agent.md" ] \
        && [ -f "${dest}/.github/instructions/go.instructions.md" ] \
        && [ -f "${dest}/.github/agents/go-research-planner.agent.md" ] \
        && [ -f "${dest}/.github/agents/go-implementer.agent.md" ] \
        && [ -f "${dest}/.github/agents/go-code-reviewer.agent.md" ] \
        && [ ! -f "${dest}/.github/instructions/php.instructions.md" ]; then
      pass "$name"
    else
      fail "$name" "python or go assets missing"
    fi
  else
    fail "$name" "installer exited non-zero"
  fi
  rm -rf "$dest"
}

# -----------------------------------------------------------------------------
# 4. Agent filtering: claude selection must not populate .github/.
# -----------------------------------------------------------------------------
test_agent_filtering() {
  local name="claude-only selection installs shared canonical assets"
  local dest; dest=$(mktmp)
  bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --agents=claude --languages=php --non-interactive >/dev/null 2>&1
  if [ -d "${dest}/.claude/agents" ] \
      && [ -f "${dest}/CLAUDE.md" ] \
      && [ -f "${dest}/.claude/agents/php-implementer.md" ] \
      && [ -f "${dest}/.claude/commands/fix-issue.md" ] \
      && [ -f "${dest}/.claude/commands/generate-unit-test.md" ] \
      && [ -f "${dest}/.claude/commands/implement-feature.md" ] \
      && [ -f "${dest}/.claude/commands/plan-feature.md" ] \
      && [ -f "${dest}/.claude/commands/refactor.md" ] \
      && [ -f "${dest}/.claude/commands/review-code.md" ] \
      && [ -f "${dest}/.claude/skills/php-foundations/SKILL.md" ] \
      && [ -f "${dest}/.github/agents/php-implementer.agent.md" ] \
      && [ -f "${dest}/.github/instructions/php.instructions.md" ] \
      && [ ! -d "${dest}/.opencode" ]; then
    pass "$name"
  else
    fail "$name" "unexpected tree"
  fi
  rm -rf "$dest"
}

test_javascript_base_install_non_copilot() {
  local name="javascript base install covers non-copilot adapters"
  local claude_dest opencode_dest cursor_dest codex_dest ok
  claude_dest=$(mktmp)
  opencode_dest=$(mktmp)
  cursor_dest=$(mktmp)
  codex_dest=$(mktmp)
  ok=1

  bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$claude_dest" \
      --agents=claude --languages=javascript --non-interactive >/dev/null 2>&1 || ok=0
  bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$opencode_dest" \
      --agents=opencode --languages=javascript --non-interactive >/dev/null 2>&1 || ok=0
  bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$cursor_dest" \
      --agents=cursor --languages=javascript --non-interactive >/dev/null 2>&1 || ok=0
  bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$codex_dest" \
      --agents=codex --languages=javascript --non-interactive >/dev/null 2>&1 || ok=0

  if [ "$ok" = "1" ] \
      && [ -f "${claude_dest}/.claude/agents/javascript-research-planner.md" ] \
      && [ -f "${claude_dest}/.claude/agents/javascript-implementer.md" ] \
      && [ -f "${claude_dest}/.claude/agents/javascript-code-reviewer.md" ] \
      && [ -f "${claude_dest}/.claude/skills/javascript-foundations/SKILL.md" ] \
      && [ -f "${claude_dest}/.claude/skills/javascript-package-selection/SKILL.md" ] \
      && [ -f "${claude_dest}/.claude/skills/javascript-quality-tooling/SKILL.md" ] \
      && [ -f "${claude_dest}/doc/javascript.md" ] \
      && [ -f "${claude_dest}/doc/typescript.md" ] \
      && [ -f "${claude_dest}/doc/javascript-tooling.md" ] \
      && [ -f "${claude_dest}/doc/javascript-architecture.md" ] \
      && [ ! -f "${claude_dest}/.claude/skills/javascript-react-foundations/SKILL.md" ] \
      && [ ! -f "${claude_dest}/.claude/skills/javascript-vue-foundations/SKILL.md" ] \
      && [ ! -f "${claude_dest}/doc/javascript-react.md" ] \
      && [ ! -f "${claude_dest}/doc/javascript-vue.md" ] \
      && [ -f "${opencode_dest}/.opencode/agents/javascript-research-planner.md" ] \
      && [ -f "${opencode_dest}/.opencode/agents/javascript-implementer.md" ] \
      && [ -f "${opencode_dest}/.opencode/agents/javascript-code-reviewer.md" ] \
      && [ -f "${opencode_dest}/.claude/skills/javascript-foundations/SKILL.md" ] \
      && [ -f "${opencode_dest}/.claude/skills/javascript-package-selection/SKILL.md" ] \
      && [ -f "${opencode_dest}/.claude/skills/javascript-quality-tooling/SKILL.md" ] \
      && [ -f "${opencode_dest}/doc/javascript.md" ] \
      && [ -f "${opencode_dest}/doc/typescript.md" ] \
      && [ -f "${opencode_dest}/doc/javascript-tooling.md" ] \
      && [ -f "${opencode_dest}/doc/javascript-architecture.md" ] \
      && [ ! -f "${opencode_dest}/.claude/skills/javascript-react-foundations/SKILL.md" ] \
      && [ ! -f "${opencode_dest}/.claude/skills/javascript-vue-foundations/SKILL.md" ] \
      && [ ! -f "${opencode_dest}/doc/javascript-react.md" ] \
      && [ ! -f "${opencode_dest}/doc/javascript-vue.md" ] \
      && [ -f "${cursor_dest}/.cursor/rules/javascript.mdc" ] \
      && [ -f "${cursor_dest}/.cursor/rules/javascript-testing.mdc" ] \
      && [ -f "${cursor_dest}/.claude/skills/javascript-foundations/SKILL.md" ] \
      && [ -f "${cursor_dest}/.claude/skills/javascript-package-selection/SKILL.md" ] \
      && [ -f "${cursor_dest}/.claude/skills/javascript-quality-tooling/SKILL.md" ] \
      && [ -f "${cursor_dest}/doc/javascript.md" ] \
      && [ -f "${cursor_dest}/doc/typescript.md" ] \
      && [ -f "${cursor_dest}/doc/javascript-tooling.md" ] \
      && [ -f "${cursor_dest}/doc/javascript-architecture.md" ] \
      && [ ! -f "${cursor_dest}/.claude/skills/javascript-react-foundations/SKILL.md" ] \
      && [ ! -f "${cursor_dest}/.claude/skills/javascript-vue-foundations/SKILL.md" ] \
      && [ ! -f "${cursor_dest}/doc/javascript-react.md" ] \
      && [ ! -f "${cursor_dest}/doc/javascript-vue.md" ] \
      && [ -f "${codex_dest}/.codex/agents/javascript-research-planner.toml" ] \
      && [ -f "${codex_dest}/.codex/agents/javascript-implementer.toml" ] \
      && [ -f "${codex_dest}/.codex/agents/javascript-code-reviewer.toml" ] \
      && [ -f "${codex_dest}/.github/skills/javascript-foundations/SKILL.md" ] \
      && [ -f "${codex_dest}/.github/skills/javascript-package-selection/SKILL.md" ] \
      && [ -f "${codex_dest}/.github/skills/javascript-quality-tooling/SKILL.md" ] \
      && [ -f "${codex_dest}/.agents/skills/javascript-foundations/SKILL.md" ] \
      && [ -f "${codex_dest}/.agents/skills/javascript-package-selection/SKILL.md" ] \
      && [ -f "${codex_dest}/.agents/skills/javascript-quality-tooling/SKILL.md" ] \
      && [ -f "${codex_dest}/doc/javascript.md" ] \
      && [ -f "${codex_dest}/doc/typescript.md" ] \
      && [ -f "${codex_dest}/doc/javascript-tooling.md" ] \
      && [ -f "${codex_dest}/doc/javascript-architecture.md" ] \
      && [ ! -f "${codex_dest}/.agents/skills/javascript-react-foundations/SKILL.md" ] \
      && [ ! -f "${codex_dest}/.agents/skills/javascript-vue-foundations/SKILL.md" ] \
      && [ ! -f "${codex_dest}/doc/javascript-react.md" ] \
      && [ ! -f "${codex_dest}/doc/javascript-vue.md" ]; then
    pass "$name"
  else
    fail "$name" "non-copilot javascript assets missing"
  fi

  rm -rf "$claude_dest" "$opencode_dest" "$cursor_dest" "$codex_dest"
}

test_opencode_skill_install() {
  local name="opencode selection installs self-contained shared skills via claude compatibility"
  local dest; dest=$(mktmp)
  local command
  bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --agents=opencode --languages=php --non-interactive >/dev/null 2>&1
  local commands_ok=1
  for command in fix-issue generate-unit-test implement-feature plan-feature refactor review-code; do
    if [ ! -f "${dest}/.opencode/commands/${command}.md" ]; then
      commands_ok=0
      break
    fi
  done
  if [ -f "${dest}/.opencode/agents/orchestrator.md" ] \
      && [ "$commands_ok" = "1" ] \
      && [ -f "${dest}/.claude/skills/orchestration-loop/SKILL.md" ] \
      && [ -f "${dest}/.claude/skills/php-foundations/SKILL.md" ] \
      && [ -f "${dest}/.claude/skills/code-review/references/verdict-template.md" ] \
      && [ -f "${dest}/.claude/skills/quality-gates/assets/report-template.md" ] \
      && [ -f "${dest}/.claude/skills/research-planning/references/brief-template.md" ] \
      && ! grep -Fq '.github/skills/' "${dest}/.claude/skills/code-review/SKILL.md" \
      && ! grep -Fq '.github/skills/' "${dest}/.claude/skills/quality-gates/SKILL.md" \
      && ! grep -Fq '.github/skills/' "${dest}/.claude/skills/research-planning/SKILL.md" \
      && ! grep -Fq '.github/skills/' "${dest}/.claude/skills/skill-selection/SKILL.md" \
      && [ ! -f "${dest}/.github/skills/quality-gates/assets/report-template.md" ] \
      && [ ! -f "${dest}/CLAUDE.md" ]; then
    pass "$name"
  else
    fail "$name" "expected skill compatibility assets missing"
  fi
  rm -rf "$dest"
}

test_next_steps_follow_selected_agents() {
  local name="next steps only mention selected agents and explain shared skill compatibility"
  local dest output
  dest=$(mktmp)
  output=$(bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --agents=copilot,opencode --languages=php --non-interactive 2>&1)

  if printf '%s' "$output" | grep -Fq 'VS Code + Copilot:' \
      && printf '%s' "$output" | grep -Fq 'OpenCode:' \
      && printf '%s' "$output" | grep -Fq 'does not install Claude Code.' \
      && ! printf '%s' "$output" | grep -Fq 'Claude Code:' \
      && ! printf '%s' "$output" | grep -Fq 'Cursor:' \
      && ! printf '%s' "$output" | grep -Fq 'Codex:'; then
    pass "$name"
  else
    fail "$name" "unexpected post-install output"
  fi

  rm -rf "$dest"
}

test_cursor_install() {
  local name="cursor selection installs native rules and shared skills"
  local dest; dest=$(mktmp)
  if bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --agents=cursor --languages=php --non-interactive >/dev/null 2>&1; then
    if [ -f "${dest}/.cursor/rules/code-quality.mdc" ] \
        && [ -f "${dest}/.cursor/rules/php.mdc" ] \
      && [ -f "${dest}/.claude/skills/php-foundations/SKILL.md" ] \
        && [ -f "${dest}/.github/instructions/code-quality.instructions.md" ] \
        && [ -f "${dest}/.github/agents/orchestrator.agent.md" ] \
        && [ -f "${dest}/.claude/skills/orchestration-loop/SKILL.md" ] \
        && ! grep -Fq '.github/skills/' "${dest}/.claude/skills/skill-selection/SKILL.md" \
        && [ -f "${dest}/AGENTS.md" ] \
        && [ ! -f "${dest}/CLAUDE.md" ] \
        && [ ! -d "${dest}/.opencode" ] \
        && [ ! -d "${dest}/.codex" ] \
        && [ ! -d "${dest}/.agents" ]; then
      pass "$name"
    else
      fail "$name" "cursor assets missing"
    fi
  else
    fail "$name" "installer exited non-zero"
  fi
  rm -rf "$dest"
}

test_codex_install() {
  local name="codex selection installs codex agents and skill wrappers"
  local dest; dest=$(mktmp)
  if bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --agents=codex --languages=php --non-interactive >/dev/null 2>&1; then
    if [ -f "${dest}/.codex/agents/orchestrator.toml" ] \
        && [ -f "${dest}/.codex/agents/php-implementer.toml" ] \
        && [ -f "${dest}/.agents/skills/orchestration-loop/SKILL.md" ] \
      && [ -f "${dest}/.agents/skills/php-foundations/SKILL.md" ] \
        && [ -f "${dest}/.agents/skills/skill-selection/SKILL.md" ] \
        && [ -f "${dest}/.agents/skills/code-review/SKILL.md" ] \
      && [ -f "${dest}/.github/skills/php-foundations/SKILL.md" ] \
        && [ -f "${dest}/.github/skills/orchestration-loop/SKILL.md" ] \
        && [ -f "${dest}/.github/skills/skill-selection/SKILL.md" ] \
        && [ -f "${dest}/.github/instructions/php.instructions.md" ] \
        && [ ! -d "${dest}/.claude" ] \
        && [ ! -d "${dest}/.opencode" ] \
        && [ ! -d "${dest}/.cursor" ] \
        && [ ! -f "${dest}/CLAUDE.md" ]; then
      pass "$name"
    else
      fail "$name" "expected Codex assets missing"
    fi
  else
    fail "$name" "installer exited non-zero"
  fi
  rm -rf "$dest"
}

# -----------------------------------------------------------------------------
# 5. --skip-existing leaves existing files untouched.
# -----------------------------------------------------------------------------
test_skip_existing() {
  local name="--skip-existing preserves existing content"
  local dest; dest=$(mktmp)
  mkdir -p "${dest}/.github/agents"
  echo "CUSTOM" > "${dest}/.github/agents/orchestrator.agent.md"
  bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --agents=copilot --non-interactive --skip-existing >/dev/null 2>&1
  if [ "$(cat "${dest}/.github/agents/orchestrator.agent.md")" = "CUSTOM" ]; then
    pass "$name"
  else
    fail "$name" "file was overwritten"
  fi
  rm -rf "$dest"
}

# -----------------------------------------------------------------------------
# 6. --force overwrites existing files.
# -----------------------------------------------------------------------------
test_force() {
  local name="--force overwrites existing files"
  local dest; dest=$(mktmp)
  mkdir -p "${dest}/.github/agents"
  echo "CUSTOM" > "${dest}/.github/agents/orchestrator.agent.md"
  bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --agents=copilot --non-interactive --force >/dev/null 2>&1
  if [ "$(cat "${dest}/.github/agents/orchestrator.agent.md")" != "CUSTOM" ]; then
    pass "$name"
  else
    fail "$name" "file was not overwritten"
  fi
  rm -rf "$dest"
}

# -----------------------------------------------------------------------------
# 7. --dry-run writes nothing.
# -----------------------------------------------------------------------------
test_dry_run() {
  local name="--dry-run does not write files"
  local dest; dest=$(mktmp)
  bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --agents=copilot --languages=php --non-interactive --dry-run >/dev/null 2>&1
  local count; count=$(find "$dest" -type f | wc -l | tr -d ' ')
  if [ "$count" = "0" ]; then pass "$name"; else fail "$name" "found $count files"; fi
  rm -rf "$dest"
}

# -----------------------------------------------------------------------------
# 8. Path traversal in manifest is rejected.
# -----------------------------------------------------------------------------
test_path_traversal() {
  local name="hostile manifest with ../ is rejected"
  local tmp; tmp=$(mktmp)
  local hostile="${tmp}/manifest.json"
  cat > "$hostile" <<'JSON'
{
  "version": "0.0.0",
  "base": { "files": ["../../etc/passwd"] },
  "agents": { "x": { "label": "X", "files": [] } },
  "languages": {},
  "technologies": {}
}
JSON
  if bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$hostile" --dest="$tmp" \
      --agents=x --non-interactive >/dev/null 2>&1; then
    fail "$name" "installer accepted ../ path"
  else
    pass "$name"
  fi
  rm -rf "$tmp"
}

# -----------------------------------------------------------------------------
# 9. Unknown agent is rejected.
# -----------------------------------------------------------------------------
test_unknown_agent() {
  local name="unknown agent id is rejected"
  local dest; dest=$(mktmp)
  if bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --agents=does-not-exist --non-interactive >/dev/null 2>&1; then
    fail "$name" "unknown agent accepted"
  else
    pass "$name"
  fi
  rm -rf "$dest"
}

# -----------------------------------------------------------------------------
# 10. --force and --skip-existing are mutually exclusive.
# -----------------------------------------------------------------------------
test_conflicting_flags() {
  local name="--force + --skip-existing is rejected"
  local dest; dest=$(mktmp)
  if bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --agents=copilot --non-interactive --force --skip-existing >/dev/null 2>&1; then
    fail "$name" "conflicting flags accepted"
  else
    pass "$name"
  fi
  rm -rf "$dest"
}

# -----------------------------------------------------------------------------
# 11. --non-interactive with no --agents fails.
# -----------------------------------------------------------------------------
test_non_interactive_requires_agents() {
  local name="--non-interactive without --agents fails"
  local dest; dest=$(mktmp)
  if bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --non-interactive >/dev/null 2>&1; then
    fail "$name" "should have required --agents"
  else
    pass "$name"
  fi
  rm -rf "$dest"
}

# -----------------------------------------------------------------------------
# 12b. Default remote repo matches the canonical origin when --repo is omitted.
# -----------------------------------------------------------------------------
test_default_repo_download_source() {
  local name="default repo downloads manifest from canonical origin"
  local tmp dest fake_bin curl_log
  tmp=$(mktmp)
  dest=$(mktmp)
  fake_bin="${tmp}/bin"
  curl_log="${tmp}/curl-url.txt"
  mkdir -p "$fake_bin"

  cat > "${fake_bin}/curl" <<EOF
#!/usr/bin/env bash
set -euo pipefail

out=""
url=""
while [ "\$#" -gt 0 ]; do
  case "\$1" in
    -o)
      out="\$2"
      shift 2
      ;;
    http://*|https://*)
      url="\$1"
      shift
      ;;
    *)
      shift
      ;;
  esac
done

if [ "\${url##*/}" = "manifest.json" ]; then
  printf '%s' "\$url" > "$curl_log"
fi

if [ -n "\$out" ]; then
  cat > "\$out" <<'JSON'
{
  "version": "0.0.0",
  "base": { "files": ["AGENTS.md"] },
  "agents": {
    "x": { "label": "X", "files": [] }
  },
  "languages": {},
  "technologies": {}
}
JSON
fi
EOF
  chmod +x "${fake_bin}/curl"

  if PATH="${fake_bin}:$PATH" bash "$INSTALLER" --dest="$dest" --agents=x --non-interactive >/dev/null 2>&1 \
      && [ "$(cat "$curl_log")" = "https://raw.githubusercontent.com/cjph96/AI/main/manifest.json" ]; then
    pass "$name"
  else
    fail "$name" "unexpected manifest source: $(cat "$curl_log" 2>/dev/null || echo '<missing>')"
  fi

  rm -rf "$tmp" "$dest"
}

# -----------------------------------------------------------------------------
# 12. Symfony framework selection installs only the Symfony-specific assets.
# -----------------------------------------------------------------------------
test_symfony_framework_install_copilot() {
  local name="symfony framework installs optional copilot assets"
  local dest; dest=$(mktmp)
  if bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --agents=copilot --languages=php --frameworks='php:symfony' --non-interactive >/dev/null 2>&1; then
    if [ -f "${dest}/.github/instructions/symfony.instructions.md" ] \
        && [ -f "${dest}/.github/agents/symfony-implementer.agent.md" ] \
        && [ -f "${dest}/.github/skills/symfony-functional-tests/SKILL.md" ] \
        && [ -f "${dest}/.github/prompts/symfony-check.prompt.md" ]; then
      pass "$name"
    else
      fail "$name" "symfony copilot assets missing"
    fi
  else
    fail "$name" "installer exited non-zero"
  fi
  rm -rf "$dest"
}

test_symfony_framework_install_claude() {
  local name="symfony framework installs optional claude assets"
  local dest; dest=$(mktmp)
  if bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --agents=claude --languages=php --frameworks='php:symfony' --non-interactive >/dev/null 2>&1; then
    if [ -f "${dest}/.claude/agents/symfony-implementer.md" ] \
        && [ -f "${dest}/.github/agents/symfony-implementer.agent.md" ] \
        && [ -f "${dest}/.claude/skills/symfony-functional-tests/SKILL.md" ] \
        && [ -f "${dest}/.claude/commands/symfony-check.md" ] \
        && grep -Fq -- "- Symfony — @.github/instructions/symfony.instructions.md" "${dest}/CLAUDE.md" \
        && grep -Fq -- "- Symfony testing — @.github/instructions/symfony-testing.instructions.md" "${dest}/CLAUDE.md"; then
      pass "$name"
    else
      fail "$name" "symfony claude assets missing"
    fi
  else
    fail "$name" "installer exited non-zero"
  fi
  rm -rf "$dest"
}

test_symfony_framework_install_opencode() {
  local name="symfony framework installs optional opencode assets"
  local dest; dest=$(mktmp)
  local command
  if bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --agents=opencode --languages=php --frameworks='php:symfony' --non-interactive >/dev/null 2>&1; then
    local commands_ok=1
    for command in symfony-functional-tests symfony-doctrine-relations symfony-api-resources symfony-messenger symfony-voters symfony-check; do
      if [ ! -f "${dest}/.opencode/commands/${command}.md" ]; then
        commands_ok=0
        break
      fi
    done
    if [ -f "${dest}/.opencode/agents/symfony-implementer.md" ] \
        && [ "$commands_ok" = "1" ] \
        && [ -f "${dest}/.github/agents/symfony-implementer.agent.md" ] \
        && [ -f "${dest}/.github/instructions/symfony.instructions.md" ] \
        && [ -f "${dest}/.claude/skills/symfony-functional-tests/SKILL.md" ] \
        && jq -e '.instructions | index(".github/instructions/symfony.instructions.md")' "${dest}/opencode.json" >/dev/null 2>&1 \
        && jq -e '.instructions | index(".github/instructions/symfony-testing.instructions.md")' "${dest}/opencode.json" >/dev/null 2>&1; then
      pass "$name"
    else
      fail "$name" "symfony opencode assets missing"
    fi
  else
    fail "$name" "installer exited non-zero"
  fi
  rm -rf "$dest"
}

test_symfony_framework_install_cursor() {
  local name="symfony framework installs optional cursor assets"
  local dest; dest=$(mktmp)
  if bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --agents=cursor --languages=php --frameworks='php:symfony' --non-interactive >/dev/null 2>&1; then
    if [ -f "${dest}/.cursor/rules/symfony.mdc" ] \
        && [ -f "${dest}/.cursor/rules/symfony-testing.mdc" ] \
        && [ -f "${dest}/.github/instructions/symfony.instructions.md" ] \
        && [ -f "${dest}/.github/agents/symfony-implementer.agent.md" ] \
        && [ -f "${dest}/.claude/skills/symfony-functional-tests/SKILL.md" ]; then
      pass "$name"
    else
      fail "$name" "symfony cursor assets missing"
    fi
  else
    fail "$name" "installer exited non-zero"
  fi
  rm -rf "$dest"
}

test_symfony_framework_install_codex() {
  local name="symfony framework installs optional codex assets"
  local dest; dest=$(mktmp)
  if bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --agents=codex --languages=php --frameworks='php:symfony' --non-interactive >/dev/null 2>&1; then
    if [ -f "${dest}/.codex/agents/symfony-implementer.toml" ] \
        && [ -f "${dest}/.agents/skills/symfony-functional-tests/SKILL.md" ] \
        && [ -f "${dest}/.agents/skills/symfony-runner-selection/SKILL.md" ] \
        && [ -f "${dest}/.github/skills/symfony-functional-tests/SKILL.md" ] \
        && [ -f "${dest}/.github/instructions/symfony.instructions.md" ] \
        && [ ! -d "${dest}/.claude" ] \
        && [ ! -d "${dest}/.opencode" ] \
        && [ ! -d "${dest}/.cursor" ]; then
      pass "$name"
    else
      fail "$name" "symfony codex assets missing"
    fi
  else
    fail "$name" "installer exited non-zero"
  fi
  rm -rf "$dest"
}

test_php_without_framework_excludes_symfony_assets() {
  local name="php without symfony excludes framework-specific assets"
  local dest; dest=$(mktmp)
  if bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --agents=copilot --languages=php --non-interactive >/dev/null 2>&1; then
    if [ ! -f "${dest}/.github/instructions/symfony.instructions.md" ] \
        && [ ! -f "${dest}/.github/agents/symfony-implementer.agent.md" ] \
        && [ ! -f "${dest}/.github/skills/symfony-functional-tests/SKILL.md" ] \
        && [ ! -f "${dest}/.github/prompts/symfony-check.prompt.md" ]; then
      pass "$name"
    else
      fail "$name" "symfony assets leaked without framework selection"
    fi
  else
    fail "$name" "installer exited non-zero"
  fi
  rm -rf "$dest"
}

test_laravel_framework_install_cursor() {
  local name="laravel framework installs optional cursor assets"
  local dest; dest=$(mktmp)
  if bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --agents=cursor --languages=php --frameworks='php:laravel' --non-interactive >/dev/null 2>&1; then
    if [ -f "${dest}/.github/instructions/laravel.instructions.md" ] \
        && [ -f "${dest}/.github/instructions/laravel-testing.instructions.md" ] \
        && [ -f "${dest}/.claude/skills/laravel-package-selection/SKILL.md" ] \
        && [ -f "${dest}/.cursor/rules/laravel.mdc" ] \
        && [ -f "${dest}/.cursor/rules/laravel-testing.mdc" ] \
        && [ ! -f "${dest}/.github/instructions/symfony.instructions.md" ]; then
      pass "$name"
    else
      fail "$name" "laravel cursor assets missing"
    fi
  else
    fail "$name" "installer exited non-zero"
  fi
  rm -rf "$dest"
}

test_framework_requires_selected_language() {
  local name="framework selection requires parent language"
  local dest; dest=$(mktmp)
  if bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --agents=claude --frameworks='php:symfony' --non-interactive >/dev/null 2>&1; then
    fail "$name" "framework accepted without parent language"
  else
    pass "$name"
  fi
  rm -rf "$dest"
}

# -----------------------------------------------------------------------------
# 13. Invalid --ref is rejected.
# -----------------------------------------------------------------------------
test_invalid_ref() {
  local name="invalid --ref is rejected"
  local dest; dest=$(mktmp)
  if bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --agents=copilot --non-interactive --ref='evil;rm -rf /' >/dev/null 2>&1; then
    fail "$name" "accepted unsafe ref"
  else
    pass "$name"
  fi
  rm -rf "$dest"
}

# -----------------------------------------------------------------------------
main() {
  printf '\n\033[1mRunning installer acceptance tests\033[0m\n\n'
  test_manifest_valid
  test_basic_install
  test_language_filtering
  test_javascript_framework_install_copilot
  test_javascript_framework_install_copilot_vue
  test_javascript_framework_install_claude
  test_javascript_framework_install_claude_react
  test_javascript_framework_install_opencode
  test_javascript_framework_install_opencode_vue
  test_javascript_framework_install_cursor
  test_javascript_framework_install_cursor_react
  test_javascript_framework_install_codex
  test_javascript_framework_install_codex_vue
  test_python_and_go_install
  test_agent_filtering
  test_javascript_base_install_non_copilot
  test_opencode_skill_install
  test_next_steps_follow_selected_agents
  test_cursor_install
  test_codex_install
  test_skip_existing
  test_force
  test_dry_run
  test_path_traversal
  test_unknown_agent
  test_conflicting_flags
  test_non_interactive_requires_agents
  test_default_repo_download_source
  test_symfony_framework_install_copilot
  test_symfony_framework_install_claude
  test_symfony_framework_install_opencode
  test_symfony_framework_install_cursor
  test_symfony_framework_install_codex
  test_php_without_framework_excludes_symfony_assets
  test_laravel_framework_install_cursor
  test_framework_requires_selected_language
  test_invalid_ref

  printf '\nPassed: %d  Failed: %d\n' "$PASS" "$FAIL"
  if [ "$FAIL" -gt 0 ]; then
    printf 'Failed tests:%b\n' "$FAILED_NAMES"
    exit 1
  fi
}

main "$@"
