---
name: bitbucket-setup
description: Install and configure the bbt Bitbucket CLI tool. Use this skill when the user needs to set up bbt, authenticate with Bitbucket Cloud, or troubleshoot bbt installation issues.
---

# Bitbucket CLI (bbt) Setup

Help the user install and configure the `bbt` Bitbucket CLI tool.

## Installation

1. First check if bbt is already installed:
   ```bash
   bbt --version
   ```

2. If not installed, run the install script:
   ```bash
   ${CLAUDE_PLUGIN_ROOT}/scripts/install-bbt.sh
   ```

3. If the script is not available, install manually based on the platform:
   - **macOS / Linux (Homebrew)**:
     ```bash
     brew tap romaintb/bbt https://codeberg.org/romaintb/homebrew-bbt.git
     brew install bbt
     ```
   - **Arch Linux (AUR)**:
     ```bash
     yay -S bbt
     ```
   - **Go** (any platform with Go installed):
     ```bash
     go install codeberg.org/romaintb/bbt@latest
     ```
     Then ensure `$(go env GOPATH)/bin` is in your `PATH`.

## Authentication

After installation, help the user authenticate with Bitbucket Cloud:

1. **Interactive login**:
   ```bash
   bbt auth login
   ```
   This will prompt for your Bitbucket workspace and an app password or personal access token (PAT).

2. **Verify authentication**:
   ```bash
   bbt auth status
   ```

## Generating a Bitbucket App Password

To create an app password for authentication:
1. Go to **Bitbucket Cloud → Personal Settings → App passwords**
2. Click **Create app password**
3. Grant these permissions: Repositories (Read/Write), Pull requests (Read/Write), Issues (Read/Write), Pipelines (Read/Write)
4. Copy the generated password — it will only be shown once

## Configuration

bbt stores its configuration in `~/.config/bbt/config.yaml`. When inside a git repository with a Bitbucket remote, bbt auto-detects the workspace and repository — no need to specify `-R workspace/repo` for most commands.

## Troubleshooting

- If `bbt` is not found after Go install, ensure `$(go env GOPATH)/bin` is in your PATH:
  ```bash
  export PATH="$(go env GOPATH)/bin:$PATH"
  ```
- For Homebrew on Linux, ensure Homebrew itself is installed first: https://brew.sh
- Check authentication issues with `bbt auth status`
