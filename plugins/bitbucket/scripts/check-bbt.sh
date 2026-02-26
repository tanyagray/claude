#!/usr/bin/env bash
set -euo pipefail

# check-bbt.sh — Check if bbt is installed and optionally authenticated.
# Used by the SessionStart hook to ensure bbt is available.
# Outputs JSON status for the hook system.

# Extend PATH to include common install locations
export PATH="${HOME}/.local/bin:${HOME}/go/bin:${HOME}/.cargo/bin:/usr/local/bin:$PATH"

check_installed() {
  if command -v bbt &>/dev/null; then
    return 0
  fi
  return 1
}

check_authenticated() {
  # bbt auth status returns 0 if authenticated
  if bbt auth status &>/dev/null 2>&1; then
    return 0
  fi
  return 1
}

main() {
  local installed=false
  local authenticated=false
  local version="none"
  local bbt_path="none"

  if check_installed; then
    installed=true
    version="$(bbt --version 2>/dev/null | head -1 || echo 'unknown')"
    bbt_path="$(command -v bbt)"
  fi

  if [ "$installed" = true ] && check_authenticated; then
    authenticated=true
  fi

  # Output JSON for hook consumption
  cat <<EOJSON
{
  "installed": ${installed},
  "authenticated": ${authenticated},
  "version": "${version}",
  "path": "${bbt_path}"
}
EOJSON

  if [ "$installed" = false ]; then
    exit 1
  fi
}

main "$@"
