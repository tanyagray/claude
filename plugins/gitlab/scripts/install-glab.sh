#!/usr/bin/env bash
set -euo pipefail

# install-glab.sh — Installs the glab GitLab CLI.
# Supports Linux (amd64/arm64) and macOS (amd64/arm64).
# Falls back to go install if a prebuilt binary is unavailable.

GLAB_VERSION="${GLAB_VERSION:-3.22.0}"

already_installed() {
  if command -v glab &>/dev/null; then
    echo "glab is already installed: $(glab version 2>/dev/null || echo 'unknown version')"
    return 0
  fi
  return 1
}

detect_platform() {
  OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
  ARCH="$(uname -m)"

  case "$OS" in
    linux)  OS="Linux" ;;
    darwin) OS="macOS" ;;
    *)
      echo "Unsupported OS: $OS" >&2
      return 1
      ;;
  esac

  case "$ARCH" in
    x86_64|amd64)  ARCH="x86_64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *)
      echo "Unsupported architecture: $ARCH" >&2
      return 1
      ;;
  esac
}

install_via_package_manager() {
  # Try Homebrew first (macOS and Linux)
  if command -v brew &>/dev/null; then
    echo "Installing glab via Homebrew..."
    brew install glab
    return $?
  fi

  # Try apt (Debian/Ubuntu)
  if command -v apt-get &>/dev/null; then
    echo "Installing glab via apt..."
    if [ -f /etc/apt/sources.list.d/gitlab-cli.list ]; then
      sudo apt-get update -qq && sudo apt-get install -y glab
    else
      # Add the GitLab repository
      curl -fsSL "https://gitlab.com/gitlab-org/cli/-/raw/main/scripts/install.sh" | sudo sh
    fi
    return $?
  fi

  # Try dnf/yum (Fedora/RHEL)
  if command -v dnf &>/dev/null; then
    echo "Installing glab via dnf..."
    sudo dnf install -y glab
    return $?
  fi

  return 1
}

install_via_binary() {
  detect_platform || return 1

  local ext="tar.gz"
  if [ "$OS" = "Linux" ]; then
    ext="tar.gz"
  fi

  local url="https://gitlab.com/gitlab-org/cli/-/releases/v${GLAB_VERSION}/downloads/glab_${GLAB_VERSION}_${OS}_${ARCH}.${ext}"
  local tmpdir
  tmpdir="$(mktemp -d)"

  echo "Downloading glab v${GLAB_VERSION} for ${OS}/${ARCH}..."
  if curl -fsSL "$url" -o "${tmpdir}/glab.tar.gz"; then
    tar -xzf "${tmpdir}/glab.tar.gz" -C "$tmpdir"

    # Find the glab binary in the extracted files
    local glab_bin
    glab_bin="$(find "$tmpdir" -name glab -type f | head -1)"

    if [ -z "$glab_bin" ]; then
      echo "Could not find glab binary in archive" >&2
      rm -rf "$tmpdir"
      return 1
    fi

    chmod +x "$glab_bin"

    # Install to user-local bin or /usr/local/bin
    local install_dir="${HOME}/.local/bin"
    mkdir -p "$install_dir"
    mv "$glab_bin" "${install_dir}/glab"

    # Ensure the install dir is in PATH
    if [[ ":$PATH:" != *":${install_dir}:"* ]]; then
      export PATH="${install_dir}:$PATH"
      echo "Added ${install_dir} to PATH for this session."
      echo "Add the following to your shell profile for persistence:"
      echo "  export PATH=\"${install_dir}:\$PATH\""
    fi

    rm -rf "$tmpdir"
    echo "glab v${GLAB_VERSION} installed to ${install_dir}/glab"
    return 0
  else
    rm -rf "$tmpdir"
    echo "Failed to download glab binary" >&2
    return 1
  fi
}

install_via_go() {
  if command -v go &>/dev/null; then
    echo "Installing glab via go install..."
    go install gitlab.com/gitlab-org/cli/cmd/glab@v${GLAB_VERSION}
    return $?
  fi
  return 1
}

main() {
  if already_installed; then
    exit 0
  fi

  echo "Installing glab GitLab CLI v${GLAB_VERSION}..."

  # Try methods in order of preference
  if install_via_binary; then
    echo "glab installed successfully via binary download."
  elif install_via_package_manager; then
    echo "glab installed successfully via package manager."
  elif install_via_go; then
    echo "glab installed successfully via go install."
  else
    echo "ERROR: Could not install glab. Please install it manually:" >&2
    echo "  See: https://gitlab.com/gitlab-org/cli#installation" >&2
    exit 1
  fi

  # Verify installation
  if command -v glab &>/dev/null; then
    echo "Verification: $(glab version)"
  else
    echo "WARNING: glab was installed but is not in PATH." >&2
    echo "You may need to restart your shell or add the install directory to PATH." >&2
  fi
}

main "$@"
