---
name: gitlab-ci
description: View and manage GitLab CI/CD pipelines and jobs using glab. Use this skill when the user wants to check pipeline status, view job logs, retry failed jobs, or manage CI/CD workflows.
---

# GitLab CI/CD Pipelines

Use the `glab` CLI to manage GitLab CI/CD pipelines and jobs.

## Pipeline Operations

### List Pipelines
```bash
# List recent pipelines
glab ci list

# Filter by status
glab ci list --status running
glab ci list --status failed
glab ci list --status success
```

### View Pipeline Status
```bash
# View current branch pipeline
glab ci view

# View a specific pipeline
glab ci view 12345

# View in web browser
glab ci view --web
```

### View Pipeline Details
```bash
# Get detailed pipeline status (interactive)
glab ci status

# View pipeline with job details
glab ci view
```

### Run a Pipeline
```bash
# Trigger a pipeline on current branch
glab ci run

# Trigger with variables
glab ci run --variables "DEPLOY_ENV=staging,DEBUG=true"

# Trigger on a specific branch
glab ci run --branch main
```

### Retry and Cancel
```bash
# Retry a failed pipeline
glab ci retry 12345

# Cancel a running pipeline
glab ci cancel 12345
```

## Job Operations

### View Job Logs
```bash
# View logs for a specific job
glab ci trace <job-id>

# Stream live job output
glab ci trace <job-id>
```

### Retry a Job
```bash
# Retry a specific failed job
glab ci retry <pipeline-id> --job <job-name>
```

### Artifacts
```bash
# Download job artifacts
glab ci artifact <job-id>
```

## CI/CD Configuration

### Lint CI Config
```bash
# Validate .gitlab-ci.yml
glab ci lint

# Lint a specific file
glab ci lint .gitlab-ci.yml
```

## Tips
- Use `glab ci status` for a quick overview of the current pipeline
- Use `glab ci view` for an interactive pipeline view
- When pipelines fail, use `glab ci trace <job-id>` to see the logs
- Use `glab ci lint` to validate CI configuration before pushing
- Combine with `glab mr pipelines <mr-id>` to check MR-specific pipelines
