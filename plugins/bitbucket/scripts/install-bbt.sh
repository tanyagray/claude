#!/usr/bin/env bash
set -euo pipefail

# install-bbt.sh — Installs the bbt Bitbucket CLI.
# Supports macOS (Homebrew), Arch Linux (AUR), and any system with Go.
# See: https://codeberg.org/romaintb/bbt

already_installed() {
  if command -v bbt &>/dev/null; then
    echo "bbt is already installed: $(bbt --version 2>/dev/null || echo 'unknown version')"
    return 0
  fi
  return 1
}

install_via_homebrew() {
  if command -v brew &>/dev/null; then
    echo "Installing bbt via Homebrew..."
    brew tap romaintb/bbt https://codeberg.org/romaintb/homebrew-bbt.git
    brew install bbt
    return $?
  fi
  return 1
}

install_via_aur() {
  # Arch Linux — try yay or paru
  if command -v yay &>/dev/null; then
    echo "Installing bbt via yay (AUR)..."
    yay -S --noconfirm bbt
    return $?
  fi

  if command -v paru &>/dev/null; then
    echo "Installing bbt via paru (AUR)..."
    paru -S --noconfirm bbt
    return $?
  fi

  return 1
}

install_via_go() {
  if command -v go &>/dev/null; then
    echo "Installing bbt via go install..."
    go install codeberg.org/romaintb/bbt@latest
    local install_dir
    install_dir="$(go env GOPATH)/bin"

    # Ensure GOPATH/bin is in PATH
    if [[ ":$PATH:" != *":${install_dir}:"* ]]; then
      export PATH="${install_dir}:$PATH"
      echo "Added ${install_dir} to PATH for this session."
      echo "Add the following to your shell profile for persistence:"
      echo "  export PATH=\"${install_dir}:\$PATH\""
    fi
    return $?
  fi
  return 1
}

main() {
  if already_installed; then
    exit 0
  fi

  echo "Installing bbt Bitbucket CLI..."

  # Try methods in order of preference
  if install_via_homebrew; then
    echo "bbt installed successfully via Homebrew."
  elif install_via_aur; then
    echo "bbt installed successfully via AUR."
  elif install_via_go; then
    echo "bbt installed successfully via go install."
  else
    echo "ERROR: Could not install bbt. Please install it manually:" >&2
    echo "  Homebrew: brew tap romaintb/bbt https://codeberg.org/romaintb/homebrew-bbt.git && brew install bbt" >&2
    echo "  AUR:      yay -S bbt" >&2
    echo "  Go:       go install codeberg.org/romaintb/bbt@latest" >&2
    echo "  See:      https://codeberg.org/romaintb/bbt" >&2
    exit 1
  fi

  # Verify installation
  if command -v bbt &>/dev/null; then
    echo "Verification: $(bbt --version)"
  else
    echo "WARNING: bbt was installed but is not in PATH." >&2
    echo "You may need to restart your shell or add the install directory to PATH." >&2
  fi
}

main "$@"
