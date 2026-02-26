---
name: bitbucket-issue
description: Create, view, and manage Bitbucket issues using bbt. Use this skill when the user wants to work with Bitbucket issues — listing, creating, or viewing them.
---

# Bitbucket Issues

Use the `bbt` CLI to manage Bitbucket issues. Note: Bitbucket issue tracking must be enabled for the repository in its settings.

## Common Operations

### List Issues
```bash
# List issues in the current repository
bbt issue list

# List issues for a specific repository
bbt issue list -R workspace/repo
```

### View an Issue
```bash
# View issue details by ID
bbt issue view <issue-id>

# View for a specific repository
bbt issue view <issue-id> -R workspace/repo
```

### Create an Issue
```bash
# Interactive creation
bbt issue create

# Create for a specific repository
bbt issue create -R workspace/repo
```

When creating an issue, bbt will prompt for:
- **Title**: A concise description of the problem or request
- **Description**: Full details, steps to reproduce, expected vs actual behaviour
- **Kind**: bug, enhancement, proposal, or task
- **Priority**: trivial, minor, major, critical, or blocker

## Bitbucket REST API (Advanced)

For filtering, updating, or other operations not in bbt:

```bash
# List issues filtered by status (requires BITBUCKET_TOKEN)
curl -s -u "${BITBUCKET_USER}:${BITBUCKET_TOKEN}" \
  "https://api.bitbucket.org/2.0/repositories/{workspace}/{repo}/issues?q=status=\"open\""

# List issues assigned to current user
curl -s -u "${BITBUCKET_USER}:${BITBUCKET_TOKEN}" \
  "https://api.bitbucket.org/2.0/repositories/{workspace}/{repo}/issues?q=assignee.account_id=\"{account_id}\""

# Update issue status (e.g., close it)
curl -s -X PUT -u "${BITBUCKET_USER}:${BITBUCKET_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"status": "resolved"}' \
  "https://api.bitbucket.org/2.0/repositories/{workspace}/{repo}/issues/{id}"

# Add a comment to an issue
curl -s -X POST -u "${BITBUCKET_USER}:${BITBUCKET_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"content": {"raw": "Comment text here"}}' \
  "https://api.bitbucket.org/2.0/repositories/{workspace}/{repo}/issues/{id}/comments"
```

## Tips

- Use `$ARGUMENTS` to reference a specific issue ID if provided by the user
- If Bitbucket issues are disabled for the repo, suggest using Jira integration (common in Atlassian teams) or enabling issues in the repository settings
- Link issues to pull requests by mentioning `#issue-id` in PR descriptions — Bitbucket will automatically create the link
- Issue statuses: `new`, `open`, `resolved`, `on hold`, `invalid`, `duplicate`, `wontfix`, `closed`
