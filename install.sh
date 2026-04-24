#!/usr/bin/env bash
# install.sh — interactive installer for the AI agent orchestration kit.
#
# Usage (remote):
#   curl -fsSL https://raw.githubusercontent.com/<owner>/<repo>/main/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/<owner>/<repo>/main/install.sh | bash -s -- --help
#
# Usage (local testing):
#   bash install.sh --manifest=./manifest.json --source=. --dest=/tmp/proj
#
# The installer copies a subset of agents, skills, instructions and prompts from
# this repository into the target project based on user-selected options.
# The catalog (selection -> files) is driven by manifest.json.

set -euo pipefail

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------

# Repository coordinates. Override via AI_TOOLS_REPO env var or --repo flag.
DEFAULT_REPO="${AI_TOOLS_REPO:-cjph96/AI}"
DEFAULT_REF="${AI_TOOLS_REF:-main}"

REPO=""
REF=""
DEST=""
SOURCE_URL=""
SOURCE_LOCAL=""
REMOTE_SOURCE_LOCAL=""
REMOTE_SOURCE_ATTEMPTED=0
MANIFEST_OVERRIDE=""
FORCE=0
SKIP_EXISTING=0
DRY_RUN=0
NON_INTERACTIVE=0

SELECTED_AGENTS=""
SELECTED_LANGUAGES=""
SELECTED_FRAMEWORKS=""     # format: "lang:fw1,fw2;lang2:fw3"
SELECTED_TECHNOLOGIES=""

# Colors (disabled if not a TTY).
if [ -t 1 ]; then
  C_RESET=$'\033[0m'; C_BOLD=$'\033[1m'; C_DIM=$'\033[2m'
  C_RED=$'\033[31m'; C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'; C_BLUE=$'\033[34m'
else
  C_RESET=""; C_BOLD=""; C_DIM=""; C_RED=""; C_GREEN=""; C_YELLOW=""; C_BLUE=""
fi

# ---------------------------------------------------------------------------
# Utilities
# ---------------------------------------------------------------------------

log()   { printf '%b\n' "$*"; }
info()  { log "${C_BLUE}==>${C_RESET} $*"; }
warn()  { log "${C_YELLOW}warning:${C_RESET} $*" >&2; }
error() { log "${C_RED}error:${C_RESET} $*" >&2; }
die()   { error "$*"; exit 1; }

download_file() {
  # $1 = URL, $2 = output path
  local url="$1" outpath="$2" attempt
  for attempt in 1 2 3; do
    if curl -fsSL "$url" -o "$outpath"; then
      return 0
    fi
    if [ "$attempt" -lt 3 ]; then
      warn "download failed for $url (attempt $attempt/3); retrying"
    fi
  done
  return 1
}

usage() {
  cat <<'USAGE'
install.sh — install the AI agent orchestration kit into a project

Options:
  --repo=OWNER/REPO         Source repository (default: from $AI_TOOLS_REPO or cjph96/AI)
  --ref=REF                 Git branch or tag (default: main)
  --dest=PATH               Destination project root (default: current directory)
  --manifest=FILE           Use a local manifest.json (skips network download)
  --source=PATH             Use a local source directory instead of downloading
  --agents=a,b,c            Non-interactive: comma-separated agent ids
  --languages=a,b           Non-interactive: comma-separated language ids
  --frameworks=LANG:f1,f2;LANG2:f3
                            Non-interactive: frameworks per language
  --technologies=a,b        Non-interactive: comma-separated technology ids
  --force                   Overwrite existing files without asking
  --skip-existing           Skip files that already exist
  --dry-run                 Show what would be copied, do not write
  --non-interactive         Fail instead of prompting
  -h, --help                Show this help and exit

Environment:
  AI_TOOLS_REPO   overrides --repo default
  AI_TOOLS_REF    overrides --ref default
USAGE
}

parse_args() {
  for arg in "$@"; do
    case "$arg" in
      --repo=*)          REPO="${arg#*=}" ;;
      --ref=*)           REF="${arg#*=}" ;;
      --dest=*)          DEST="${arg#*=}" ;;
      --manifest=*)      MANIFEST_OVERRIDE="${arg#*=}" ;;
      --source=*)        SOURCE_LOCAL="${arg#*=}" ;;
      --agents=*)        SELECTED_AGENTS="${arg#*=}" ;;
      --languages=*)     SELECTED_LANGUAGES="${arg#*=}" ;;
      --frameworks=*)    SELECTED_FRAMEWORKS="${arg#*=}" ;;
      --technologies=*)  SELECTED_TECHNOLOGIES="${arg#*=}" ;;
      --force)           FORCE=1 ;;
      --skip-existing)   SKIP_EXISTING=1 ;;
      --dry-run)         DRY_RUN=1 ;;
      --non-interactive) NON_INTERACTIVE=1 ;;
      -h|--help)         usage; exit 0 ;;
      *) die "unknown argument: $arg (see --help)" ;;
    esac
  done

  REPO="${REPO:-$DEFAULT_REPO}"
  REF="${REF:-$DEFAULT_REF}"
  DEST="${DEST:-$PWD}"

  # Validate REF against a conservative charset (anti-injection in URLs).
  if ! printf '%s' "$REF" | grep -Eq '^[A-Za-z0-9._/-]+$'; then
    die "invalid --ref value: $REF"
  fi
  if ! printf '%s' "$REPO" | grep -Eq '^[A-Za-z0-9._-]+/[A-Za-z0-9._-]+$'; then
    die "invalid --repo value: $REPO (expected OWNER/REPO)"
  fi

  if [ "$FORCE" = "1" ] && [ "$SKIP_EXISTING" = "1" ]; then
    die "--force and --skip-existing are mutually exclusive"
  fi

  SOURCE_URL="https://raw.githubusercontent.com/${REPO}/${REF}"
}

check_preflight() {
  command -v curl >/dev/null 2>&1 || die "curl is required but not installed"
  command -v jq   >/dev/null 2>&1 || die "jq is required. Install it: macOS 'brew install jq' / Debian 'sudo apt-get install jq' / Alpine 'apk add jq'"
  command -v tar  >/dev/null 2>&1 || die "tar is required but not installed"
  # bash >= 4 is not strictly required; keep script compatible with macOS 3.2.
  [ -w "$DEST" ] || die "destination not writable: $DEST"
}

# Create a secure temp dir. Cleaned on exit.
TMPDIR_INSTALL=""
cleanup() {
  [ -n "${TMPDIR_INSTALL:-}" ] && [ -d "$TMPDIR_INSTALL" ] && rm -rf "$TMPDIR_INSTALL"
}
trap cleanup EXIT

make_tmpdir() {
  TMPDIR_INSTALL=$(mktemp -d 2>/dev/null || mktemp -d -t ai-installer) || die "cannot create temp dir"
}

# Safe read from /dev/tty so prompts work under 'curl | bash'.
read_tty() {
  # $1 = prompt, $2 = variable name (via eval)
  local prompt="$1"
  local __var="$2"
  local __val=""
  if [ -r /dev/tty ]; then
    printf '%s' "$prompt" > /dev/tty
    IFS= read -r __val < /dev/tty || true
  else
    printf '%s' "$prompt"
    IFS= read -r __val || true
  fi
  eval "$__var=\$__val"
}

# ---------------------------------------------------------------------------
# Manifest loading
# ---------------------------------------------------------------------------

MANIFEST_FILE=""

load_manifest() {
  if [ -n "$MANIFEST_OVERRIDE" ]; then
    [ -f "$MANIFEST_OVERRIDE" ] || die "manifest not found: $MANIFEST_OVERRIDE"
    MANIFEST_FILE="$MANIFEST_OVERRIDE"
    info "using local manifest: $MANIFEST_FILE"
  elif [ -n "$SOURCE_LOCAL" ]; then
    [ -f "${SOURCE_LOCAL}/manifest.json" ] || die "manifest not found in --source: ${SOURCE_LOCAL}/manifest.json"
    MANIFEST_FILE="${SOURCE_LOCAL}/manifest.json"
    info "using local manifest: $MANIFEST_FILE"
  else
    MANIFEST_FILE="${TMPDIR_INSTALL}/manifest.json"
    info "downloading manifest from ${SOURCE_URL}/manifest.json"
    download_file "${SOURCE_URL}/manifest.json" "$MANIFEST_FILE" \
      || die "failed to download manifest from ${SOURCE_URL}/manifest.json"
  fi

  jq empty "$MANIFEST_FILE" >/dev/null 2>&1 || die "manifest is not valid JSON: $MANIFEST_FILE"
}

prepare_remote_source() {
  local archive_url archive_file extract_dir
  [ -n "$SOURCE_LOCAL" ] && return 1
  [ -n "$REMOTE_SOURCE_LOCAL" ] && return 0
  [ "$REMOTE_SOURCE_ATTEMPTED" = "1" ] && return 1

  REMOTE_SOURCE_ATTEMPTED=1
  archive_url="https://codeload.github.com/${REPO}/tar.gz/${REF}"
  archive_file="${TMPDIR_INSTALL}/source.tar.gz"
  extract_dir="${TMPDIR_INSTALL}/source"

  info "downloading source archive from ${archive_url}"
  if ! download_file "$archive_url" "$archive_file"; then
    warn "failed to download source archive; falling back to per-file downloads"
    return 1
  fi

  mkdir -p "$extract_dir"
  tar -xzf "$archive_file" -C "$extract_dir" >/dev/null 2>&1 || {
    warn "failed to extract source archive; falling back to per-file downloads"
    return 1
  }

  REMOTE_SOURCE_LOCAL=$(find "$extract_dir" -mindepth 1 -maxdepth 1 -type d | head -n 1)
  [ -n "$REMOTE_SOURCE_LOCAL" ] || {
    warn "source archive did not contain an expected root directory; falling back to per-file downloads"
    return 1
  }

  return 0
}

# Helpers that query the manifest via jq.
manifest_list_agents()       { jq -r '.agents | keys[]'            "$MANIFEST_FILE"; }
manifest_list_languages()    { jq -r '.languages | keys[]'         "$MANIFEST_FILE"; }
manifest_list_frameworks()   { jq -r --arg l "$1" '.languages[$l].frameworks | keys[]' "$MANIFEST_FILE"; }
manifest_list_technologies() { jq -r '.technologies | keys[]'      "$MANIFEST_FILE"; }

manifest_label() {
  # $1 = section, $2 = id, optional $3 = sublangid for frameworks
  local section="$1" id="$2" sub="${3:-}"
  if [ "$section" = "framework" ]; then
    jq -r --arg l "$sub" --arg f "$id" '.languages[$l].frameworks[$f].label // $f' "$MANIFEST_FILE"
  else
    jq -r --arg id "$id" ".${section}[\$id].label // \$id" "$MANIFEST_FILE"
  fi
}

# ---------------------------------------------------------------------------
# Interactive selection
# ---------------------------------------------------------------------------

# Multi-select: prints labels numbered, reads comma-separated indices, echoes
# the resulting space-separated ids to stdout.
multi_select() {
  local title="$1"; shift
  local ids=("$@")
  local i=1
  printf '\n%b%s%b\n' "$C_BOLD" "$title" "$C_RESET" > /dev/tty
  for id in "${ids[@]}"; do
    local label
    label=$(jq -r --arg id "$id" --arg path "$MULTI_SELECT_PATH" \
      'getpath($path | split("."))[$id].label // $id' "$MANIFEST_FILE")
    printf '  %2d) %s %s(%s)%s\n' "$i" "$label" "$C_DIM" "$id" "$C_RESET" > /dev/tty
    i=$((i+1))
  done
  printf '  %s\n' "(comma-separated numbers, empty = none)" > /dev/tty
  local input=""
  read_tty "> " input
  # Parse: "1,3" -> ids by index.
  local out=""
  local IFS_BAK=$IFS
  IFS=', '
  for num in $input; do
    [ -z "$num" ] && continue
    case "$num" in
      ''|*[!0-9]*) warn "ignoring non-numeric token: $num"; continue ;;
    esac
    if [ "$num" -ge 1 ] && [ "$num" -le ${#ids[@]} ]; then
      out="$out ${ids[$((num-1))]}"
    else
      warn "ignoring out-of-range: $num"
    fi
  done
  IFS=$IFS_BAK
  echo "$out" | xargs -n1 2>/dev/null | sort -u | tr '\n' ' '
}

interactive_select() {
  local agents_ids languages_ids
  agents_ids=($(manifest_list_agents))
  languages_ids=($(manifest_list_languages))

  MULTI_SELECT_PATH="agents"
  SELECTED_AGENTS=$(multi_select "Select agents (at least one):" "${agents_ids[@]}")
  [ -z "${SELECTED_AGENTS// /}" ] && die "at least one agent must be selected"

  MULTI_SELECT_PATH="languages"
  SELECTED_LANGUAGES=$(multi_select "Select languages used in the project:" "${languages_ids[@]}")

  # Frameworks per language.
  SELECTED_FRAMEWORKS=""
  for lang in $SELECTED_LANGUAGES; do
    local fw_ids
    fw_ids=($(manifest_list_frameworks "$lang"))
    [ ${#fw_ids[@]} -eq 0 ] && continue
    MULTI_SELECT_PATH="languages.${lang}.frameworks"
    local label
    label=$(manifest_label languages "$lang")
    local chosen
    chosen=$(multi_select "Frameworks for ${label}:" "${fw_ids[@]}")
    if [ -n "${chosen// /}" ]; then
      local csv
      csv=$(echo "$chosen" | xargs | tr ' ' ',')
      [ -n "$SELECTED_FRAMEWORKS" ] && SELECTED_FRAMEWORKS="$SELECTED_FRAMEWORKS;"
      SELECTED_FRAMEWORKS="${SELECTED_FRAMEWORKS}${lang}:${csv}"
    fi
  done

  local tech_ids
  tech_ids=($(manifest_list_technologies))
  if [ ${#tech_ids[@]} -gt 0 ]; then
    MULTI_SELECT_PATH="technologies"
    SELECTED_TECHNOLOGIES=$(multi_select "Select technologies:" "${tech_ids[@]}")
  fi
}

# Validate that every provided id exists in the manifest.
validate_selection() {
  local id
  for id in $SELECTED_AGENTS; do
    jq -e --arg id "$id" '.agents[$id]' "$MANIFEST_FILE" >/dev/null \
      || die "unknown agent: $id"
  done
  for id in $SELECTED_LANGUAGES; do
    jq -e --arg id "$id" '.languages[$id]' "$MANIFEST_FILE" >/dev/null \
      || die "unknown language: $id"
  done
  for id in $SELECTED_TECHNOLOGIES; do
    jq -e --arg id "$id" '.technologies[$id]' "$MANIFEST_FILE" >/dev/null \
      || die "unknown technology: $id"
  done

  # Frameworks format check + existence.
  local entry lang fws fw
  local IFS_BAK=$IFS
  IFS=';'
  for entry in $SELECTED_FRAMEWORKS; do
    [ -z "$entry" ] && continue
    lang="${entry%%:*}"
    fws="${entry#*:}"
    jq -e --arg id "$lang" '.languages[$id]' "$MANIFEST_FILE" >/dev/null \
      || die "frameworks refer to unknown language: $lang"
    case " $SELECTED_LANGUAGES " in
      *" $lang "*) ;;
      *) die "frameworks refer to unselected language: $lang" ;;
    esac
    local oldIFS=$IFS; IFS=','
    for fw in $fws; do
      jq -e --arg l "$lang" --arg f "$fw" '.languages[$l].frameworks[$f]' "$MANIFEST_FILE" >/dev/null \
        || die "unknown framework '$fw' for language '$lang'"
    done
    IFS=$oldIFS
  done
  IFS=$IFS_BAK

  if [ -z "$(printf '%s' "$SELECTED_AGENTS" | tr -d ' ')" ]; then
    die "at least one agent must be selected"
  fi
}

# ---------------------------------------------------------------------------
# Fileset resolution
# ---------------------------------------------------------------------------

# Emit the deduplicated list of repo-relative paths to copy, one per line.
resolve_fileset() {
  {
    jq -r '.base.files[]?' "$MANIFEST_FILE"

    local id
    for id in $SELECTED_AGENTS; do
      jq -r --arg id "$id" '.agents[$id].files[]?' "$MANIFEST_FILE"
    done

    local lang agent
    for lang in $SELECTED_LANGUAGES; do
      for agent in $SELECTED_AGENTS; do
        jq -r --arg l "$lang" --arg a "$agent" \
          '.languages[$l].files_by_agent[$a][]? // empty' "$MANIFEST_FILE"
      done
    done

    # Frameworks.
    local entry fws fw
    local IFS_BAK=$IFS
    IFS=';'
    for entry in $SELECTED_FRAMEWORKS; do
      [ -z "$entry" ] && continue
      lang="${entry%%:*}"
      fws="${entry#*:}"
      local oldIFS=$IFS; IFS=','
      for fw in $fws; do
        for agent in $SELECTED_AGENTS; do
          jq -r --arg l "$lang" --arg f "$fw" --arg a "$agent" \
            '.languages[$l].frameworks[$f].files_by_agent[$a][]? // empty' "$MANIFEST_FILE"
        done
      done
      IFS=$oldIFS
    done
    IFS=$IFS_BAK

    local tech
    for tech in $SELECTED_TECHNOLOGIES; do
      for agent in $SELECTED_AGENTS; do
        jq -r --arg t "$tech" --arg a "$agent" \
          '.technologies[$t].files_by_agent[$a][]? // empty' "$MANIFEST_FILE"
      done
    done
  } | awk 'NF' | sort -u
}

# Reject paths that escape the destination (anti path-traversal).
is_safe_path() {
  local p="$1"
  case "$p" in
    /*|*..*|*$'\n'*|*$'\r'*) return 1 ;;
  esac
  # Must match safe chars only.
  printf '%s' "$p" | grep -Eq '^[A-Za-z0-9._/ -]+$'
}

# ---------------------------------------------------------------------------
# Copy / download
# ---------------------------------------------------------------------------

fetch_file() {
  # $1 = repo-relative path, $2 = absolute destination path
  local relpath="$1" outpath="$2"
  mkdir -p "$(dirname "$outpath")"
  if [ -n "$SOURCE_LOCAL" ]; then
    cp "${SOURCE_LOCAL}/${relpath}" "$outpath"
  elif [ -n "$REMOTE_SOURCE_LOCAL" ] || prepare_remote_source; then
    cp "${REMOTE_SOURCE_LOCAL}/${relpath}" "$outpath"
  else
    download_file "${SOURCE_URL}/${relpath}" "$outpath" \
      || return 1
  fi
}

# Conflict policy for a single file. Echoes one of: overwrite|skip.
conflict_decision() {
  local destfile="$1"
  if [ ! -e "$destfile" ]; then
    echo "overwrite"
    return
  fi
  if [ "$FORCE" = "1" ]; then
    echo "overwrite"
    return
  fi
  if [ "$SKIP_EXISTING" = "1" ]; then
    echo "skip"
    return
  fi
  # Already resolved globally in pre-check; default safe.
  echo "skip"
}

install_files() {
  local files="$1"
  local staging="${TMPDIR_INSTALL}/staging"
  mkdir -p "$staging"

  local count=0 skipped=0 overwritten=0 added=0
  local file
  while IFS= read -r file; do
    [ -z "$file" ] && continue
    count=$((count+1))
    if ! is_safe_path "$file"; then
      die "unsafe path in manifest or fileset: $file"
    fi

    local destfile="${DEST}/${file}"
    local decision
    decision=$(conflict_decision "$destfile")
    local existed=0
    [ -e "$destfile" ] && existed=1

    if [ "$decision" = "skip" ] && [ "$existed" = "1" ]; then
      log "  ${C_DIM}skip     ${C_RESET} $file (exists)"
      skipped=$((skipped+1))
      continue
    fi

    if [ "$DRY_RUN" = "1" ]; then
      if [ "$existed" = "1" ]; then
        log "  ${C_YELLOW}would ow${C_RESET} $file"
      else
        log "  ${C_GREEN}would ad${C_RESET} $file"
      fi
      continue
    fi

    local stagefile="${staging}/${file}"
    if ! fetch_file "$file" "$stagefile"; then
      die "failed to fetch $file"
    fi

    mkdir -p "$(dirname "$destfile")"
    mv "$stagefile" "$destfile"
    if [ "$existed" = "1" ]; then
      log "  ${C_YELLOW}update  ${C_RESET} $file"
      overwritten=$((overwritten+1))
    else
      log "  ${C_GREEN}add     ${C_RESET} $file"
      added=$((added+1))
    fi
  done <<EOF
$files
EOF

  log ""
  if [ "$DRY_RUN" = "1" ]; then
    log "${C_BOLD}Dry run:${C_RESET} $count files would be processed."
  else
    log "${C_BOLD}Done:${C_RESET} $added added, $overwritten updated, $skipped skipped (total $count)."
  fi
}

# ---------------------------------------------------------------------------
# Conflict pre-check (prompt once globally when interactive).
# ---------------------------------------------------------------------------

pre_check_conflicts() {
  local files="$1"
  local conflicts=0
  local file
  while IFS= read -r file; do
    [ -z "$file" ] && continue
    [ -e "${DEST}/${file}" ] && conflicts=$((conflicts+1))
  done <<EOF
$files
EOF

  if [ "$conflicts" -eq 0 ]; then return 0; fi
  info "$conflicts file(s) already exist in the destination."

  if [ "$FORCE" = "1" ] || [ "$SKIP_EXISTING" = "1" ]; then
    return 0
  fi

  if [ "$NON_INTERACTIVE" = "1" ]; then
    die "conflicts detected; pass --force or --skip-existing in non-interactive mode"
  fi

  local choice=""
  read_tty "Overwrite existing files? [o]verwrite / [s]kip / [c]ancel: " choice
  case "$choice" in
    o|O|overwrite) FORCE=1 ;;
    s|S|skip)      SKIP_EXISTING=1 ;;
    *)             die "cancelled by user" ;;
  esac
}

confirm_plan() {
  [ "$NON_INTERACTIVE" = "1" ] && return 0
  local answer=""
  read_tty "Proceed with installation? [y/N]: " answer
  case "$answer" in
    y|Y|yes|YES) return 0 ;;
    *) die "cancelled by user" ;;
  esac
}

has_selected_agent() {
  local wanted="$1"
  local agent
  for agent in $SELECTED_AGENTS; do
    [ "$agent" = "$wanted" ] && return 0
  done
  return 1
}

uses_claude_skill_compat() {
  has_selected_agent opencode && return 0
  has_selected_agent cursor && return 0
  return 1
}

has_selected_framework() {
  local wanted_lang="$1" wanted_fw="$2"
  local entry lang fws fw
  local IFS_BAK=$IFS
  IFS=';'
  for entry in $SELECTED_FRAMEWORKS; do
    [ -z "$entry" ] && continue
    lang="${entry%%:*}"
    fws="${entry#*:}"
    [ "$lang" != "$wanted_lang" ] && continue
    local oldIFS=$IFS; IFS=','
    for fw in $fws; do
      if [ "$fw" = "$wanted_fw" ]; then
        IFS=$oldIFS
        IFS=$IFS_BAK
        return 0
      fi
    done
    IFS=$oldIFS
  done
  IFS=$IFS_BAK
  return 1
}

append_claude_import() {
  local line="$1" file="$2"
  grep -Fqx "$line" "$file" && return 0
  printf '\n%s\n' "$line" >> "$file"
}

apply_optional_framework_refs() {
  [ "$DRY_RUN" = "1" ] && return 0

  if has_selected_framework php symfony; then
    if has_selected_agent claude && [ -f "${DEST}/CLAUDE.md" ]; then
      append_claude_import "- Symfony — @.github/instructions/symfony.instructions.md" "${DEST}/CLAUDE.md"
      append_claude_import "- Symfony testing — @.github/instructions/symfony-testing.instructions.md" "${DEST}/CLAUDE.md"
    fi

    if has_selected_agent opencode && [ -f "${DEST}/opencode.json" ]; then
      local tmpfile="${TMPDIR_INSTALL}/opencode.json"
      jq '.instructions += [
          ".github/instructions/symfony.instructions.md",
          ".github/instructions/symfony-testing.instructions.md"
        ] | .instructions |= unique' \
        "${DEST}/opencode.json" > "$tmpfile"
      mv "$tmpfile" "${DEST}/opencode.json"
    fi
  fi
}

print_summary() {
  local files_count="$1"
  log ""
  log "${C_BOLD}Installation plan${C_RESET}"
  log "  repo:          $REPO@$REF"
  log "  destination:   $DEST"
  log "  agents:        ${SELECTED_AGENTS:-(none)}"
  log "  languages:     ${SELECTED_LANGUAGES:-(none)}"
  log "  frameworks:    ${SELECTED_FRAMEWORKS:-(none)}"
  log "  technologies:  ${SELECTED_TECHNOLOGIES:-(none)}"
  if ! has_selected_agent claude && uses_claude_skill_compat; then
    log "  note:          Some selected adapters reuse .claude/skills as compatibility assets; this does not install Claude Code."
  fi
  log "  files:         $files_count"
  log "  mode:          $([ "$DRY_RUN" = "1" ] && echo "dry-run" || echo "apply")"
  log ""
}

print_next_steps() {
  log "Next steps:"
  if has_selected_agent copilot; then
    log "  - VS Code + Copilot: open $DEST and use ${C_BOLD}@orchestrator${C_RESET} in chat."
  fi
  if has_selected_agent claude; then
    log "  - Claude Code:       ${C_BOLD}cd $DEST && claude --agent orchestrator${C_RESET}"
  fi
  if has_selected_agent opencode; then
    log "  - OpenCode:          ${C_BOLD}cd $DEST && opencode${C_RESET}"
  fi
  if has_selected_agent cursor; then
    log "  - Cursor:            open $DEST in Cursor and use the project rules from .cursor/rules."
  fi
  if has_selected_agent codex; then
    log "  - Codex:             ${C_BOLD}cd $DEST && codex${C_RESET}"
  fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {
  parse_args "$@"
  check_preflight
  make_tmpdir
  load_manifest

  # If nothing was passed and non-interactive requested, fail.
  if [ -z "$SELECTED_AGENTS" ] && [ "$NON_INTERACTIVE" = "1" ]; then
    die "non-interactive mode requires at least --agents=..."
  fi

  if [ -z "$SELECTED_AGENTS" ]; then
    interactive_select
  fi

  # Normalise: turn CSV into space-separated.
  SELECTED_AGENTS=$(echo "$SELECTED_AGENTS" | tr ',' ' ' | xargs)
  SELECTED_LANGUAGES=$(echo "$SELECTED_LANGUAGES" | tr ',' ' ' | xargs)
  SELECTED_TECHNOLOGIES=$(echo "$SELECTED_TECHNOLOGIES" | tr ',' ' ' | xargs)

  validate_selection

  local fileset
  fileset=$(resolve_fileset)
  local fc
  fc=$(printf '%s\n' "$fileset" | awk 'NF' | wc -l | tr -d ' ')

  print_summary "$fc"

  if [ "$fc" = "0" ]; then
    die "resolved fileset is empty"
  fi

  pre_check_conflicts "$fileset"
  confirm_plan
  install_files "$fileset"
  apply_optional_framework_refs

  log ""
  log "${C_GREEN}${C_BOLD}AI tools installed.${C_RESET}"
  print_next_steps
}

main "$@"
