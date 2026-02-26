---
name: gitlab-issue
description: Create, view, manage, and close GitLab issues using glab. Use this skill when the user wants to work with GitLab issues — creating, listing, commenting, or closing them.
---

# GitLab Issues

Use the `glab` CLI to manage GitLab issues.

## Common Operations

### List Issues
```bash
# List open issues
glab issue list

# Filter issues
glab issue list --assignee @me
glab issue list --label "bug"
glab issue list --milestone "v1.0"
glab issue list --state closed
glab issue list --search "login error"
glab issue list --confidential
```

### Create an Issue
```bash
# Interactive creation
glab issue create

# Create with options
glab issue create --title "Bug: Login fails" --description "Steps to reproduce..."

# Create with labels and assignees
glab issue create --title "Add dark mode" --label "feature,ui" --assignee user1

# Create with milestone
glab issue create --title "Fix auth" --milestone "v2.0"

# Create confidential issue
glab issue create --title "Security: XSS vulnerability" --confidential
```

### View an Issue
```bash
# View issue details
glab issue view 42

# View in web browser
glab issue view 42 --web

# View with comments
glab issue view 42 --comments
```

### Comment on Issues
```bash
# Add a comment
glab issue note 42 --message "I can reproduce this on Linux"
```

### Update Issues
```bash
# Update title
glab issue update 42 --title "Updated title"

# Add labels
glab issue update 42 --label "priority::high,team::backend"

# Assign to someone
glab issue update 42 --assignee user1

# Set milestone
glab issue update 42 --milestone "v2.0"
```

### Close or Reopen
```bash
glab issue close 42
glab issue reopen 42
```

### Create Branch from Issue
```bash
# Create a branch linked to an issue
glab issue create-branch 42

# With a custom branch name
glab issue create-branch 42 --branch "fix/login-issue-42"
```

### Board View
```bash
# View project board
glab issue board view
```

## Tips
- Use `$ARGUMENTS` to reference a specific issue number if provided
- When creating issues, suggest appropriate labels and milestones
- Link related issues using `Relates to #N` or `Closes #N` in descriptions
- Use `--confidential` for security-related issues
