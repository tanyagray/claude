---
name: gitlab-repo
description: Manage GitLab repositories, view project details, and handle repository settings using glab. Use this skill for repository-level operations like cloning, forking, viewing project info, and managing releases.
---

# GitLab Repository Management

Use the `glab` CLI to manage GitLab repositories and projects.

## Repository Operations

### Clone a Repository
```bash
# Clone by project path
glab repo clone group/project

# Clone to a specific directory
glab repo clone group/project ./my-directory
```

### Fork a Repository
```bash
# Fork the current project
glab repo fork

# Fork a specific project
glab repo fork group/project

# Fork and clone
glab repo fork group/project --clone
```

### View Repository Info
```bash
# View current project details
glab repo view

# View in web browser
glab repo view --web

# View a specific project
glab repo view group/project
```

### Search for Projects
```bash
# Search GitLab projects
glab repo search --search "kubernetes"

# Search within a group
glab repo search --search "api" --group my-group
```

## Release Management

### List Releases
```bash
glab release list
```

### Create a Release
```bash
# Create a release
glab release create v1.0.0

# Create with notes
glab release create v1.0.0 --notes "Release notes here"

# Create with asset links
glab release create v1.0.0 --assets-links '[{"name":"binary","url":"https://..."}]'
```

### View a Release
```bash
glab release view v1.0.0
```

## SSH Key Management

### List SSH Keys
```bash
glab ssh-key list
```

### Add an SSH Key
```bash
glab ssh-key add --title "My key" --key "$(cat ~/.ssh/id_rsa.pub)"
```

## Snippets

### Create a Snippet
```bash
# Create from a file
glab snippet create --title "Config example" --filename config.yml

# Create with visibility
glab snippet create --title "Script" --filename script.sh --visibility public
```

### List Snippets
```bash
glab snippet list
```

## Tips
- Use `glab repo view` to quickly check project information
- When working with forks, `glab repo fork` automatically sets up remotes
- Use releases for proper version management with `glab release create`
- Check available API endpoints with `glab api --help` for advanced operations
