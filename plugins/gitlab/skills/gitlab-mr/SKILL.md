---
name: gitlab-mr
description: Create, review, manage, and merge GitLab merge requests using glab. Use this skill when the user wants to work with MRs — creating, listing, reviewing, approving, or merging them.
---

# GitLab Merge Requests

Use the `glab` CLI to manage GitLab merge requests (MRs).

## Common Operations

### List Merge Requests
```bash
# List open MRs in the current project
glab mr list

# List MRs with filters
glab mr list --state merged
glab mr list --assignee @me
glab mr list --reviewer @me
glab mr list --label "bug,priority::high"
glab mr list --milestone "v1.0"
```

### Create a Merge Request
```bash
# Interactive creation
glab mr create

# Create with options
glab mr create --title "Add feature X" --description "Implements feature X" --target-branch main

# Create from current branch with auto-fill from commits
glab mr create --fill

# Create as draft
glab mr create --draft --title "WIP: Feature Y"

# Create with assignees and reviewers
glab mr create --title "Fix bug" --assignee user1,user2 --reviewer reviewer1
```

### View a Merge Request
```bash
# View MR details
glab mr view 123

# View in web browser
glab mr view 123 --web

# View the MR for the current branch
glab mr view
```

### Review and Approve
```bash
# Approve an MR
glab mr approve 123

# Revoke approval
glab mr approve 123 --revoke

# Add a note/comment
glab mr note 123 --message "Looks good, but please fix the typo on line 42"
```

### Merge
```bash
# Merge an MR
glab mr merge 123

# Merge with squash
glab mr merge 123 --squash

# Merge when pipeline succeeds
glab mr merge 123 --when-pipeline-succeeds

# Delete source branch after merge
glab mr merge 123 --remove-source-branch
```

### Update a Merge Request
```bash
# Update title
glab mr update 123 --title "New title"

# Add labels
glab mr update 123 --label "reviewed,ready"

# Change assignees
glab mr update 123 --assignee user1,user2

# Mark as ready (un-draft)
glab mr update 123 --ready
```

### Check MR Status
```bash
# View MR diff
glab mr diff 123

# Check MR CI/pipeline status
glab mr pipelines 123

# List MR commits
glab mr commits 123
```

### Close or Reopen
```bash
glab mr close 123
glab mr reopen 123
```

## Tips
- Use `$ARGUMENTS` to reference a specific MR number if the user provides one
- When creating MRs, suggest `--fill` to auto-populate from commit messages
- Always check `glab mr list` first to understand the current state
- For code review workflows, combine `glab mr diff` with `glab mr note`
