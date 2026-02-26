---
name: gitlab-setup
description: Install and configure the glab GitLab CLI tool. Use this skill when the user needs to set up glab, authenticate with GitLab, or troubleshoot glab installation issues.
---

# GitLab CLI (glab) Setup

Help the user install and configure the `glab` GitLab CLI tool.

## Installation

1. First check if glab is already installed:
   ```bash
   glab version
   ```

2. If not installed, run the install script:
   ```bash
   ${CLAUDE_PLUGIN_ROOT}/scripts/install-glab.sh
   ```

3. If the script is not available, install manually based on the platform:
   - **Linux (binary)**: Download from https://gitlab.com/gitlab-org/cli/-/releases
   - **macOS (Homebrew)**: `brew install glab`
   - **Go**: `go install gitlab.com/gitlab-org/cli/cmd/glab@latest`

## Authentication

After installation, help the user authenticate:

1. **Interactive login** (for personal use):
   ```bash
   glab auth login
   ```
   This will prompt for the GitLab instance URL and an authentication token.

2. **Token-based login** (for CI or automation):
   ```bash
   glab auth login --hostname gitlab.com --token <YOUR_TOKEN>
   ```

3. **Self-hosted GitLab**:
   ```bash
   glab auth login --hostname gitlab.example.com
   ```

4. **Verify authentication**:
   ```bash
   glab auth status
   ```

## Configuration

Common configuration commands:
- Set default remote: `glab config set remote_alias origin`
- Set default browser: `glab config set browser "firefox"`
- Set preferred editor: `glab config set editor "vim"`
- View all settings: `glab config list`

## Troubleshooting

- If `glab` is not found after install, ensure `~/.local/bin` is in your PATH
- For permission errors, try running with appropriate privileges
- For SSL errors with self-hosted GitLab, check: `glab config set skip_tls_verify true --host gitlab.example.com`
