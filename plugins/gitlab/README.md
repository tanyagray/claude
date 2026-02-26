# GitLab Plugin for Claude Code

A Claude Code plugin that provides full GitLab integration using the [glab CLI](https://gitlab.com/gitlab-org/cli).

## Features

- **Automatic glab installation**: Installs the glab CLI on session start if not already available
- **Merge request management**: Create, review, approve, and merge MRs
- **Issue tracking**: Create, list, comment on, and close GitLab issues
- **CI/CD pipeline monitoring**: View pipeline status, check job logs, retry failed jobs
- **Repository operations**: Clone, fork, view project details, manage releases
- **Project administration**: Manage CI/CD variables, labels, schedules, and more
- **GitLab assistant agent**: A specialized agent for complex GitLab workflows

## Installation

### From the marketplace

```
/plugin marketplace add <marketplace-repo>
/plugin install gitlab@gitlab-tools
```

### Local testing

```bash
claude --plugin-dir ./plugins/gitlab
```

## Skills

| Skill | Command | Description |
|-------|---------|-------------|
| Setup | `/gitlab:gitlab-setup` | Install and configure glab |
| Merge Requests | `/gitlab:gitlab-mr` | Work with merge requests |
| Issues | `/gitlab:gitlab-issue` | Manage GitLab issues |
| CI/CD | `/gitlab:gitlab-ci` | Monitor and manage pipelines |
| Repository | `/gitlab:gitlab-repo` | Repository-level operations |
| Project | `/gitlab:gitlab-project` | Project administration |

## Authentication

After glab is installed, authenticate with your GitLab instance:

```bash
# GitLab.com
glab auth login

# Self-hosted GitLab
glab auth login --hostname gitlab.example.com

# Using a token (non-interactive)
glab auth login --token <YOUR_TOKEN>
```

The token needs at minimum the `api` and `write_repository` scopes.

## Environment Variables

| Variable | Description |
|----------|-------------|
| `GITLAB_TOKEN` / `GL_TOKEN` | GitLab personal access token |
| `GITLAB_HOST` / `GL_HOST` | GitLab instance URL (for self-managed) |
| `GLAB_VERSION` | Override the glab version installed by the setup script |

## Hooks

The plugin includes:

- **SessionStart**: Checks if glab is available and attempts automatic installation if missing
- **PreToolUse (Bash)**: Provides guidance when glab commands are being used

## Requirements

- Claude Code v1.0.33 or later
- Internet access (for glab installation and GitLab API calls)
- A GitLab account with a personal access token (for authenticated operations)

## License

MIT
