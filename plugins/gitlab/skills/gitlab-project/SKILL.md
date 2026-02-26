---
name: gitlab-project
description: Manage GitLab project settings, members, variables, and configurations using glab and the API. Use this skill for project administration tasks.
---

# GitLab Project Management

Use the `glab` CLI for project-level administration and the GitLab API.

## API Access

The `glab api` command provides direct access to the GitLab REST API for operations not covered by specific glab subcommands.

### Common API Patterns
```bash
# Get current project details
glab api projects/:id

# List project members
glab api projects/:id/members

# List project variables
glab api projects/:id/variables

# List project webhooks
glab api projects/:id/hooks
```

## Project Variables (CI/CD)

### List Variables
```bash
glab variable list
```

### Set a Variable
```bash
# Set a variable
glab variable set MY_VAR "my-value"

# Set a masked variable
glab variable set SECRET_KEY "s3cret" --masked

# Set a protected variable
glab variable set DEPLOY_KEY "key" --protected

# Set a variable for a specific environment
glab variable set DB_HOST "db.staging.example.com" --scope "staging"
```

### Delete a Variable
```bash
glab variable delete MY_VAR
```

## Labels

### List Labels
```bash
glab label list
```

### Create a Label
```bash
glab label create "priority::high" --color "#FF0000" --description "High priority items"
```

## Schedule Management
```bash
# List pipeline schedules
glab schedule list

# Run a schedule now
glab schedule run <schedule-id>
```

## Advanced API Usage

### GraphQL Queries
```bash
# Run a GraphQL query
glab api graphql -f query='
  query {
    currentUser {
      name
      username
    }
  }
'
```

### Pagination
```bash
# List with pagination
glab api projects/:id/issues --paginate
```

## Tips
- Use `glab api` for any operation not covered by a dedicated subcommand
- CI/CD variables can be scoped to environments with `--scope`
- Always use `--masked` for sensitive values like passwords and tokens
- Use `--protected` for variables that should only be available on protected branches
