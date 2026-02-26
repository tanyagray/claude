---
name: bitbucket-pipeline
description: View and manage Bitbucket Pipelines (CI/CD) using the Bitbucket REST API. Use this skill when the user wants to check pipeline status, view build logs, trigger pipelines, or manage pipeline configuration.
---

# Bitbucket Pipelines (CI/CD)

Bitbucket Pipelines is Bitbucket Cloud's integrated CI/CD system, configured via `bitbucket-pipelines.yml`. Use the Bitbucket REST API to manage pipelines from the command line.

Set your credentials as environment variables for the examples below:
```bash
export BITBUCKET_USER="your-username"
export BITBUCKET_TOKEN="your-app-password-or-pat"
export BB_WORKSPACE="your-workspace"
export BB_REPO="your-repo"
```

## Pipeline Operations

### List Recent Pipelines
```bash
curl -s -u "${BITBUCKET_USER}:${BITBUCKET_TOKEN}" \
  "https://api.bitbucket.org/2.0/repositories/${BB_WORKSPACE}/${BB_REPO}/pipelines/?sort=-created_on&pagelen=10" \
  | python3 -m json.tool
```

### Get a Specific Pipeline
```bash
curl -s -u "${BITBUCKET_USER}:${BITBUCKET_TOKEN}" \
  "https://api.bitbucket.org/2.0/repositories/${BB_WORKSPACE}/${BB_REPO}/pipelines/{pipeline-uuid}" \
  | python3 -m json.tool
```

### Trigger a Pipeline
```bash
# Trigger on current branch
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
curl -s -X POST -u "${BITBUCKET_USER}:${BITBUCKET_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"target\": {\"ref_type\": \"branch\", \"type\": \"pipeline_ref_target\", \"ref_name\": \"${BRANCH}\"}}" \
  "https://api.bitbucket.org/2.0/repositories/${BB_WORKSPACE}/${BB_REPO}/pipelines/"

# Trigger a specific pipeline step by name
curl -s -X POST -u "${BITBUCKET_USER}:${BITBUCKET_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"target": {"ref_type": "branch", "type": "pipeline_ref_target", "ref_name": "main", "selector": {"type": "custom", "pattern": "my-custom-pipeline"}}}' \
  "https://api.bitbucket.org/2.0/repositories/${BB_WORKSPACE}/${BB_REPO}/pipelines/"
```

### Stop a Running Pipeline
```bash
curl -s -X POST -u "${BITBUCKET_USER}:${BITBUCKET_TOKEN}" \
  "https://api.bitbucket.org/2.0/repositories/${BB_WORKSPACE}/${BB_REPO}/pipelines/{pipeline-uuid}/stopPipeline"
```

## Step and Log Operations

### List Steps in a Pipeline
```bash
curl -s -u "${BITBUCKET_USER}:${BITBUCKET_TOKEN}" \
  "https://api.bitbucket.org/2.0/repositories/${BB_WORKSPACE}/${BB_REPO}/pipelines/{pipeline-uuid}/steps/" \
  | python3 -m json.tool
```

### View Logs for a Step
```bash
curl -s -u "${BITBUCKET_USER}:${BITBUCKET_TOKEN}" \
  "https://api.bitbucket.org/2.0/repositories/${BB_WORKSPACE}/${BB_REPO}/pipelines/{pipeline-uuid}/steps/{step-uuid}/log"
```

## Pipeline Configuration

### Enable Pipelines for a Repository
```bash
curl -s -X PUT -u "${BITBUCKET_USER}:${BITBUCKET_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"enabled": true}' \
  "https://api.bitbucket.org/2.0/repositories/${BB_WORKSPACE}/${BB_REPO}/pipelines_config"
```

### List Pipeline Variables
```bash
curl -s -u "${BITBUCKET_USER}:${BITBUCKET_TOKEN}" \
  "https://api.bitbucket.org/2.0/repositories/${BB_WORKSPACE}/${BB_REPO}/pipelines_config/variables/" \
  | python3 -m json.tool
```

### Add a Pipeline Variable
```bash
# Plain variable
curl -s -X POST -u "${BITBUCKET_USER}:${BITBUCKET_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"key": "MY_VAR", "value": "my-value", "secured": false}' \
  "https://api.bitbucket.org/2.0/repositories/${BB_WORKSPACE}/${BB_REPO}/pipelines_config/variables/"

# Secured (masked) variable
curl -s -X POST -u "${BITBUCKET_USER}:${BITBUCKET_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"key": "SECRET_KEY", "value": "s3cret", "secured": true}' \
  "https://api.bitbucket.org/2.0/repositories/${BB_WORKSPACE}/${BB_REPO}/pipelines_config/variables/"
```

## Deployment Environments

```bash
# List deployment environments
curl -s -u "${BITBUCKET_USER}:${BITBUCKET_TOKEN}" \
  "https://api.bitbucket.org/2.0/repositories/${BB_WORKSPACE}/${BB_REPO}/environments/" \
  | python3 -m json.tool

# List variables for a deployment environment
curl -s -u "${BITBUCKET_USER}:${BITBUCKET_TOKEN}" \
  "https://api.bitbucket.org/2.0/repositories/${BB_WORKSPACE}/${BB_REPO}/deployments_config/environments/{environment-uuid}/variables" \
  | python3 -m json.tool
```

## bitbucket-pipelines.yml Tips

- **Lint your config**: Use the Bitbucket online validator at https://bitbucket.org/{workspace}/{repo}/admin/addon/admin/pipelines/configuration
- **Cache dependencies**: Use `caches:` to speed up builds
- **Parallel steps**: Use `parallel:` to run independent steps concurrently
- **Manual steps**: Use `trigger: manual` for deployment gates
- **Conditions**: Use `condition:` with `changesets` to skip steps when irrelevant files change

## Common Pipeline Statuses

| Status | Meaning |
|--------|---------|
| `PENDING` | Queued, waiting to start |
| `IN_PROGRESS` | Currently running |
| `SUCCESSFUL` | All steps passed |
| `FAILED` | One or more steps failed |
| `ERROR` | Pipeline configuration error |
| `STOPPED` | Manually stopped |
| `PAUSED` | Waiting at a manual step |
