# GitLab Tools — Claude Code Marketplace

A Claude Code plugin marketplace providing GitLab integration tools.

## Overview

This marketplace offers plugins that integrate GitLab functionality into Claude Code sessions, powered by the [glab CLI](https://gitlab.com/gitlab-org/cli).

## Available Plugins

### gitlab

Full GitLab integration for Claude Code. Automatically installs the glab CLI and provides skills for:

- **Merge Requests** — Create, review, approve, and merge MRs
- **Issues** — Create, manage, and close GitLab issues
- **CI/CD Pipelines** — Monitor pipelines, view logs, retry jobs
- **Repository Management** — Clone, fork, releases, project info
- **Project Administration** — Variables, labels, schedules, API access

## Quick Start

### Add this marketplace

```
/plugin marketplace add <this-repo-url>
```

### Install the GitLab plugin

```
/plugin install gitlab@gitlab-tools
```

### Authenticate with GitLab

```bash
glab auth login
```

### Start using it

```
/gitlab:gitlab-mr
/gitlab:gitlab-issue
/gitlab:gitlab-ci
```

Or just ask Claude to help with any GitLab task — the GitLab assistant agent will activate automatically.

## Marketplace Structure

```
.claude-plugin/
  marketplace.json          # Marketplace catalog
plugins/
  gitlab/
    .claude-plugin/
      plugin.json           # Plugin manifest
    skills/                 # GitLab skills
      gitlab-setup/         # Install & configure glab
      gitlab-mr/            # Merge request operations
      gitlab-issue/         # Issue management
      gitlab-ci/            # CI/CD pipelines
      gitlab-repo/          # Repository operations
      gitlab-project/       # Project administration
    agents/                 # Specialized agents
      gitlab-assistant.md   # GitLab workflow assistant
    hooks/                  # Event hooks
      hooks.json            # SessionStart + PreToolUse hooks
    scripts/                # Utility scripts
      install-glab.sh       # glab installer
      check-glab.sh         # glab availability checker
```

## Contributing

1. Fork this repository
2. Create a feature branch
3. Make your changes
4. Test locally: `claude --plugin-dir ./plugins/gitlab`
5. Submit a merge request

## License

MIT
