---
name: bitbucket-pr
description: Create, view, manage, and merge Bitbucket pull requests using bbt. Use this skill when the user wants to work with pull requests — creating, listing, reviewing, or merging them.
---

# Bitbucket Pull Requests

Use the `bbt` CLI to manage Bitbucket pull requests.

## Common Operations

### List Pull Requests
```bash
# List open pull requests in the current repository
bbt pr list

# List pull requests for a specific repository
bbt pr list -R workspace/repo
```

### View a Pull Request
```bash
# View pull request details by ID
bbt pr view <pr-id>

# View for a specific repository
bbt pr view <pr-id> -R workspace/repo
```

### Create a Pull Request
```bash
# Interactive creation
bbt pr create

# Create for a specific repository
bbt pr create -R workspace/repo
```

When creating a PR, bbt will prompt for:
- **Title**: A concise description of the change
- **Description**: Detailed explanation, linked issues, testing notes
- **Source branch**: The branch containing your changes
- **Destination branch**: Usually `main` or `develop`
- **Reviewers**: Bitbucket usernames to request review from

### Merge a Pull Request
```bash
# Merge a pull request by ID
bbt pr merge <pr-id>

# Merge for a specific repository
bbt pr merge <pr-id> -R workspace/repo
```

## Workflow Tips

- Use `$ARGUMENTS` to reference a specific PR ID if the user provides one
- Always run `bbt pr list` first to understand open PRs and their IDs
- When creating PRs, suggest a clear title and description that explains *why* the change is needed
- After merging, remind the user to delete the source branch if no longer needed

## Pull Request Best Practices

- **Title format**: Use imperative mood — "Add feature X", "Fix bug Y", "Update dependency Z"
- **Description**: Include what changed, why, and how to test it
- **Reviewers**: Tag appropriate team members based on the code changed
- **Small PRs**: Encourage keeping PRs focused and small for faster review cycles

## Bitbucket REST API (Advanced)

For operations not yet in bbt, use the Bitbucket REST API directly:

```bash
# List PR comments (requires BITBUCKET_TOKEN env var)
curl -s -u "${BITBUCKET_USER}:${BITBUCKET_TOKEN}" \
  "https://api.bitbucket.org/2.0/repositories/{workspace}/{repo}/pullrequests/{id}/comments"

# Approve a PR
curl -s -X POST -u "${BITBUCKET_USER}:${BITBUCKET_TOKEN}" \
  "https://api.bitbucket.org/2.0/repositories/{workspace}/{repo}/pullrequests/{id}/approve"

# Decline a PR
curl -s -X POST -u "${BITBUCKET_USER}:${BITBUCKET_TOKEN}" \
  "https://api.bitbucket.org/2.0/repositories/{workspace}/{repo}/pullrequests/{id}/decline"
```
