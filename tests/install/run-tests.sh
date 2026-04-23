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
      && [ ! -f "${dest}/.github/instructions/php.instructions.md" ] \
      && [ ! -f "${dest}/.github/agents/php-research-planner.agent.md" ]; then
    pass "$name"
  else
    fail "$name" "php files leaked or js files missing"
  fi
  rm -rf "$dest"
}

# -----------------------------------------------------------------------------
# 4. Agent filtering: claude selection must not populate .github/.
# -----------------------------------------------------------------------------
test_agent_filtering() {
  local name="claude-only selection does not install copilot files"
  local dest; dest=$(mktmp)
  bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --agents=claude --languages=php --non-interactive >/dev/null 2>&1
  if [ -d "${dest}/.claude/agents" ] \
      && [ -f "${dest}/CLAUDE.md" ] \
      && [ -f "${dest}/.claude/agents/php-implementer.md" ] \
      && [ ! -d "${dest}/.github" ] \
      && [ ! -d "${dest}/.opencode" ]; then
    pass "$name"
  else
    fail "$name" "unexpected tree"
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
# 12. Frameworks selection gating: selecting frameworks does not break when
#     their files_by_agent is empty.
# -----------------------------------------------------------------------------
test_empty_framework_files() {
  local name="framework with empty files_by_agent does not break"
  local dest; dest=$(mktmp)
  if bash "$INSTALLER" --source="$REPO_ROOT" --manifest="$MANIFEST" --dest="$dest" \
      --agents=copilot --languages=php --frameworks='php:symfony' --non-interactive >/dev/null 2>&1; then
    pass "$name"
  else
    fail "$name" "installer errored with empty framework fileset"
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
  test_agent_filtering
  test_skip_existing
  test_force
  test_dry_run
  test_path_traversal
  test_unknown_agent
  test_conflicting_flags
  test_non_interactive_requires_agents
  test_empty_framework_files
  test_invalid_ref

  printf '\nPassed: %d  Failed: %d\n' "$PASS" "$FAIL"
  if [ "$FAIL" -gt 0 ]; then
    printf 'Failed tests:%b\n' "$FAILED_NAMES"
    exit 1
  fi
}

main "$@"
