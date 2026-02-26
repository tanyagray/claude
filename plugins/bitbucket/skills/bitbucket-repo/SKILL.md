---
name: bitbucket-repo
description: Manage Bitbucket repositories, view project details, and handle repository settings using bbt and the Bitbucket REST API. Use this skill for repository-level operations like listing, viewing, and cloning repos.
---

# Bitbucket Repository Management

Use the `bbt` CLI and Bitbucket REST API to manage Bitbucket repositories.

## Common Operations

### List Repositories
```bash
# List repositories in the current workspace
bbt repo list

# List repositories for a specific workspace
bbt repo list -R workspace
```

### View Repository Info
```bash
# View current repository details
bbt repo view

# View a specific repository
bbt repo view -R workspace/repo
```

## Cloning Repositories

bbt does not provide a `clone` subcommand — use standard git with HTTPS or SSH:

```bash
# Clone via HTTPS
git clone https://bitbucket.org/workspace/repo.git

# Clone via SSH
git clone git@bitbucket.org:workspace/repo.git

# Clone to a specific directory
git clone git@bitbucket.org:workspace/repo.git ./my-directory
```

## Bitbucket REST API (Advanced)

### Repository Information
```bash
# Get repository details
curl -s -u "${BITBUCKET_USER}:${BITBUCKET_TOKEN}" \
  "https://api.bitbucket.org/2.0/repositories/{workspace}/{repo}"

# List branches
curl -s -u "${BITBUCKET_USER}:${BITBUCKET_TOKEN}" \
  "https://api.bitbucket.org/2.0/repositories/{workspace}/{repo}/refs/branches"

# List tags
curl -s -u "${BITBUCKET_USER}:${BITBUCKET_TOKEN}" \
  "https://api.bitbucket.org/2.0/repositories/{workspace}/{repo}/refs/tags"
```

### Branch Restrictions (Branch Permissions)
```bash
# List branch restrictions
curl -s -u "${BITBUCKET_USER}:${BITBUCKET_TOKEN}" \
  "https://api.bitbucket.org/2.0/repositories/{workspace}/{repo}/branch-restrictions"
```

### Repository Variables (for Pipelines)
```bash
# List repository variables
curl -s -u "${BITBUCKET_USER}:${BITBUCKET_TOKEN}" \
  "https://api.bitbucket.org/2.0/repositories/{workspace}/{repo}/pipelines_config/variables/"

# Create a repository variable
curl -s -X POST -u "${BITBUCKET_USER}:${BITBUCKET_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"key": "MY_VAR", "value": "my-value", "secured": false}' \
  "https://api.bitbucket.org/2.0/repositories/{workspace}/{repo}/pipelines_config/variables/"

# Create a secured (masked) variable
curl -s -X POST -u "${BITBUCKET_USER}:${BITBUCKET_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"key": "SECRET_KEY", "value": "s3cret", "secured": true}' \
  "https://api.bitbucket.org/2.0/repositories/{workspace}/{repo}/pipelines_config/variables/"
```

### Webhooks
```bash
# List webhooks
curl -s -u "${BITBUCKET_USER}:${BITBUCKET_TOKEN}" \
  "https://api.bitbucket.org/2.0/repositories/{workspace}/{repo}/hooks"
```

### SSH Keys (Deploy Keys)
```bash
# List deploy keys
curl -s -u "${BITBUCKET_USER}:${BITBUCKET_TOKEN}" \
  "https://api.bitbucket.org/2.0/repositories/{workspace}/{repo}/deploy-keys"

# Add a deploy key
curl -s -X POST -u "${BITBUCKET_USER}:${BITBUCKET_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"label": "CI Deploy Key", "key": "ssh-rsa AAAA..."}' \
  "https://api.bitbucket.org/2.0/repositories/{workspace}/{repo}/deploy-keys"
```

## Tips

- Set `BITBUCKET_USER` and `BITBUCKET_TOKEN` (app password or PAT) as environment variables for API calls
- Use `bbt repo view` to quickly check repository info without curl
- For workspace-level operations (team settings, user management), use the Bitbucket Cloud UI or workspace API endpoints
