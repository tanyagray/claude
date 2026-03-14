---
name: aws-preview-deploy
description: Generate AWS preview deployment infrastructure for a project. Creates CloudFormation templates, GitHub Actions workflows, Dockerfile, and bootstrap IAM resources for per-PR ephemeral environments using App Runner (API) and S3 + CloudFront (static sites).
user-invocable: true
disable-model-invocation: true
allowed-tools: Read, Write, Bash, Glob, Grep, Edit, AskUserQuestion
argument-hint: "[project-name]"
---

# AWS Preview Deployment Generator

Generate a complete AWS preview deployment infrastructure for per-PR ephemeral environments.

## Architecture

Each pull request gets its own isolated environment:
- **API**: AWS App Runner (container from ECR)
- **Static sites**: S3 + CloudFront (with OAC, SPA routing)
- **Docker images**: Amazon ECR (shared repo, per-PR tags)
- **Auth**: GitHub Actions OIDC (no stored AWS credentials)
- **IaC**: CloudFormation (one stack per PR, auto-cleanup on close)

## Input

The user provides a project name as `$ARGUMENTS`. If not provided, infer from `package.json`, `pyproject.toml`, or the git repo name.

Before generating, ask the user:

1. **What is the API runtime?** (e.g., Python/FastAPI, Node/Express, Go, etc.)
2. **What static sites need deploying?** (e.g., web-app, admin-app, docs — or none)
3. **What API keys / secrets does the API need?** (e.g., OPENAI_API_KEY, DATABASE_URL)
4. **What region?** (default: us-west-2)
5. **Does the project use Supabase branching?** (if yes, include Supabase integration jobs)

## Files to Generate

Generate these files relative to the project root:

### 1. `infra/bootstrap/template.yaml`

One-time CloudFormation stack that creates shared resources.

```yaml
AWSTemplateFormatVersion: "2010-09-09"
Description: >
  Bootstrap resources for {PROJECT_NAME} preview deployments.
  Creates ECR repository and IAM roles. Expects an existing GitHub OIDC provider.

Parameters:
  GitHubOrg:
    Type: String
    Default: {GITHUB_ORG}
    Description: GitHub organization or user name

  GitHubRepo:
    Type: String
    Default: {GITHUB_REPO}
    Description: GitHub repository name

  GitHubOidcProviderArn:
    Type: String
    Description: ARN of the existing GitHub OIDC provider in this account

Resources:
  # --- ECR Repository ---
  EcrRepository:
    Type: AWS::ECR::Repository
    Properties:
      RepositoryName: {PROJECT_NAME}-api
      ImageTagMutability: MUTABLE
      LifecyclePolicy:
        LifecyclePolicyText: |
          {
            "rules": [
              {
                "rulePriority": 1,
                "description": "Delete untagged images older than 7 days",
                "selection": {
                  "tagStatus": "untagged",
                  "countType": "sinceImagePushed",
                  "countUnit": "days",
                  "countNumber": 7
                },
                "action": {
                  "type": "expire"
                }
              }
            ]
          }

  # --- IAM Role for GitHub Actions ---
  GitHubActionsRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: {PROJECT_NAME}-gh-actions
      AssumeRolePolicyDocument:
        Version: "2012-10-17"
        Statement:
          - Effect: Allow
            Principal:
              Federated: !Ref GitHubOidcProviderArn
            Action: sts:AssumeRoleWithWebIdentity
            Condition:
              StringEquals:
                token.actions.githubusercontent.com:aud: sts.amazonaws.com
              StringLike:
                token.actions.githubusercontent.com:sub: !Sub "repo:${GitHubOrg}/${GitHubRepo}:*"
      Policies:
        - PolicyName: PreviewDeployPolicy
          PolicyDocument:
            Version: "2012-10-17"
            Statement:
              # ECR
              - Sid: EcrAuth
                Effect: Allow
                Action: ecr:GetAuthorizationToken
                Resource: "*"
              - Sid: EcrReadWrite
                Effect: Allow
                Action:
                  - ecr:BatchCheckLayerAvailability
                  - ecr:GetDownloadUrlForLayer
                  - ecr:BatchGetImage
                  - ecr:PutImage
                  - ecr:InitiateLayerUpload
                  - ecr:UploadLayerPart
                  - ecr:CompleteLayerUpload
                  - ecr:BatchDeleteImage
                Resource: !GetAtt EcrRepository.Arn

              # App Runner
              - Sid: AppRunner
                Effect: Allow
                Action:
                  - apprunner:CreateService
                  - apprunner:UpdateService
                  - apprunner:DeleteService
                  - apprunner:DescribeService
                  - apprunner:ListServices
                  - apprunner:ListOperations
                  - apprunner:TagResource
                  - apprunner:UntagResource
                  - apprunner:CreateAutoScalingConfiguration
                  - apprunner:DeleteAutoScalingConfiguration
                  - apprunner:DescribeAutoScalingConfiguration
                Resource: "*"

              # S3
              - Sid: S3
                Effect: Allow
                Action:
                  - s3:CreateBucket
                  - s3:DeleteBucket
                  - s3:PutBucketPolicy
                  - s3:GetBucketPolicy
                  - s3:DeleteBucketPolicy
                  - s3:PutBucketWebsite
                  - s3:GetBucketWebsite
                  - s3:DeleteBucketWebsite
                  - s3:PutObject
                  - s3:GetObject
                  - s3:DeleteObject
                  - s3:ListBucket
                  - s3:PutBucketPublicAccessBlock
                  - s3:GetBucketPublicAccessBlock
                  - s3:PutBucketOwnershipControls
                  - s3:GetBucketOwnershipControls
                  - s3:TagResource
                  - s3:PutBucketTagging
                  - s3:GetBucketTagging
                Resource:
                  - "arn:aws:s3:::preview-*"
                  - "arn:aws:s3:::preview-*/*"

              # App Runner service-linked role (first use in account)
              - Sid: ServiceLinkedRole
                Effect: Allow
                Action: iam:CreateServiceLinkedRole
                Resource: "arn:aws:iam::*:role/aws-service-role/apprunner.amazonaws.com/*"
                Condition:
                  StringLike:
                    "iam:AWSServiceName": apprunner.amazonaws.com

              # CloudFront
              - Sid: CloudFront
                Effect: Allow
                Action:
                  - cloudfront:CreateDistribution
                  - cloudfront:UpdateDistribution
                  - cloudfront:DeleteDistribution
                  - cloudfront:GetDistribution
                  - cloudfront:GetDistributionConfig
                  - cloudfront:ListDistributions
                  - cloudfront:CreateInvalidation
                  - cloudfront:GetInvalidation
                  - cloudfront:ListInvalidations
                  - cloudfront:CreateOriginAccessControl
                  - cloudfront:DeleteOriginAccessControl
                  - cloudfront:GetOriginAccessControl
                  - cloudfront:UpdateOriginAccessControl
                  - cloudfront:ListOriginAccessControls
                  - cloudfront:TagResource
                  - cloudfront:UntagResource
                Resource: "*"

              # CloudFormation
              - Sid: CloudFormation
                Effect: Allow
                Action:
                  - cloudformation:CreateStack
                  - cloudformation:UpdateStack
                  - cloudformation:DeleteStack
                  - cloudformation:DescribeStacks
                  - cloudformation:DescribeStackEvents
                  - cloudformation:GetTemplate
                  - cloudformation:GetTemplateSummary
                  - cloudformation:ListStacks
                  - cloudformation:CreateChangeSet
                  - cloudformation:DescribeChangeSet
                  - cloudformation:ExecuteChangeSet
                  - cloudformation:DeleteChangeSet
                Resource: !Sub "arn:aws:cloudformation:*:${AWS::AccountId}:stack/preview-pr-*/*"

              # IAM - pass role to App Runner
              - Sid: PassRole
                Effect: Allow
                Action: iam:PassRole
                Resource: !GetAtt AppRunnerEcrAccessRole.Arn

  # --- IAM Role for App Runner to pull from ECR ---
  AppRunnerEcrAccessRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: {PROJECT_NAME}-apprunner-ecr
      AssumeRolePolicyDocument:
        Version: "2012-10-17"
        Statement:
          - Effect: Allow
            Principal:
              Service: build.apprunner.amazonaws.com
            Action: sts:AssumeRole
      Policies:
        - PolicyName: EcrPullPolicy
          PolicyDocument:
            Version: "2012-10-17"
            Statement:
              - Effect: Allow
                Action: ecr:GetAuthorizationToken
                Resource: "*"
              - Effect: Allow
                Action:
                  - ecr:BatchCheckLayerAvailability
                  - ecr:GetDownloadUrlForLayer
                  - ecr:BatchGetImage
                Resource: !GetAtt EcrRepository.Arn

Outputs:
  EcrRepositoryUri:
    Value: !GetAtt EcrRepository.RepositoryUri
  GitHubActionsRoleArn:
    Value: !GetAtt GitHubActionsRole.Arn
  AppRunnerEcrAccessRoleArn:
    Value: !GetAtt AppRunnerEcrAccessRole.Arn
```

**Customization notes:**
- Replace `{PROJECT_NAME}`, `{GITHUB_ORG}`, `{GITHUB_REPO}` with actual values
- If no static sites, remove S3 and CloudFront permissions
- If no App Runner (API), remove App Runner, ServiceLinkedRole, and PassRole permissions

### 2. `infra/bootstrap/README.md`

Document:
- What the bootstrap stack creates
- Prerequisites (AWS CLI, existing OIDC provider)
- Deployment command: `aws cloudformation deploy --stack-name {PROJECT_NAME}-bootstrap --template-file infra/bootstrap/template.yaml --capabilities CAPABILITY_NAMED_IAM --parameter-overrides GitHubOidcProviderArn=arn:aws:iam::ACCOUNT:oidc-provider/token.actions.githubusercontent.com`
- Post-deploy: list GitHub secrets to set (`AWS_ROLE_ARN`, `AWS_APP_RUNNER_ECR_ROLE_ARN`)
- IAM permissions summary table

### 3. `infra/preview/template.yaml`

Per-PR CloudFormation stack. Use the pattern from the bootstrap template above but for ephemeral resources.

**Key patterns:**
- All resource names include `!Ref PrNumber` for isolation
- S3 buckets: `DeletionPolicy: Delete` (ephemeral)
- App Runner: min 1 / max 2, 50 max concurrency (cost-effective for previews)
- CloudFront: `PriceClass_100` (cheapest edge locations)
- S3 bucket policy uses OAC (Origin Access Control), NOT OAI
- CloudFront custom error responses: 403 and 404 → `/index.html` with 200 (SPA routing)
- S3 buckets block ALL public access — CloudFront accesses via OAC

**For each static site, generate this S3 + CloudFront pattern:**

```yaml
  {SiteName}Bucket:
    Type: AWS::S3::Bucket
    DeletionPolicy: Delete
    Properties:
      BucketName: !Sub "preview-{site-slug}-pr-${PrNumber}"
      OwnershipControls:
        Rules:
          - ObjectOwnership: BucketOwnerEnforced
      PublicAccessBlockConfiguration:
        BlockPublicAcls: true
        BlockPublicPolicy: true
        IgnorePublicAcls: true
        RestrictPublicBuckets: true

  {SiteName}BucketPolicy:
    Type: AWS::S3::BucketPolicy
    Properties:
      Bucket: !Ref {SiteName}Bucket
      PolicyDocument:
        Version: "2012-10-17"
        Statement:
          - Sid: AllowCloudFrontOAC
            Effect: Allow
            Principal:
              Service: cloudfront.amazonaws.com
            Action: s3:GetObject
            Resource: !Sub "${{{SiteName}Bucket}.Arn}/*"
            Condition:
              StringEquals:
                "AWS:SourceArn": !Sub "arn:aws:cloudfront::${AWS::AccountId}:distribution/${{{SiteName}Distribution}}"

  {SiteName}Oac:
    Type: AWS::CloudFront::OriginAccessControl
    Properties:
      OriginAccessControlConfig:
        Name: !Sub "preview-{site-slug}-pr-${PrNumber}"
        OriginAccessControlOriginType: s3
        SigningBehavior: always
        SigningProtocol: sigv4

  {SiteName}Distribution:
    Type: AWS::CloudFront::Distribution
    Properties:
      DistributionConfig:
        Enabled: true
        Comment: !Sub "Preview PR-${PrNumber} - {site-name}"
        DefaultRootObject: index.html
        PriceClass: PriceClass_100
        Origins:
          - Id: S3Origin
            DomainName: !GetAtt {SiteName}Bucket.RegionalDomainName
            OriginAccessControlId: !GetAtt {SiteName}Oac.Id
            S3OriginConfig:
              OriginAccessIdentity: ""
        DefaultCacheBehavior:
          TargetOriginId: S3Origin
          ViewerProtocolPolicy: redirect-to-https
          CachePolicyId: 658327ea-f89d-4fab-a63d-7e88639e58f6  # CachingOptimized
          Compress: true
        CustomErrorResponses:
          - ErrorCode: 403
            ResponseCode: 200
            ResponsePagePath: /index.html
            ErrorCachingMinTTL: 0
          - ErrorCode: 404
            ResponseCode: 200
            ResponsePagePath: /index.html
            ErrorCachingMinTTL: 0
```

**App Runner pattern:**

```yaml
  ApiAutoScalingConfig:
    Type: AWS::AppRunner::AutoScalingConfiguration
    Properties:
      AutoScalingConfigurationName: !Sub "preview-pr-${PrNumber}"
      MaxConcurrency: 50
      MinSize: 1
      MaxSize: 2

  ApiService:
    Type: AWS::AppRunner::Service
    Properties:
      ServiceName: !Sub "preview-pr-${PrNumber}"
      SourceConfiguration:
        AuthenticationConfiguration:
          AccessRoleArn: !Ref AppRunnerEcrRoleArn
        AutoDeploymentsEnabled: false
        ImageRepository:
          ImageIdentifier: !Ref EcrImageUri
          ImageRepositoryType: ECR
          ImageConfiguration:
            Port: "{API_PORT}"
            RuntimeEnvironmentVariables:
              # Add project-specific env vars here
              - Name: PORT
                Value: "{API_PORT}"
      InstanceConfiguration:
        Cpu: "1024"
        Memory: "2048"
      AutoScalingConfigurationArn: !GetAtt ApiAutoScalingConfig.AutoScalingConfigurationArn
      HealthCheckConfiguration:
        Protocol: HTTP
        Path: /health
        Interval: 10
        Timeout: 5
        HealthyThreshold: 1
        UnhealthyThreshold: 5
```

### 4. `infra/preview/Dockerfile`

Generate a minimal Dockerfile appropriate for the API runtime. Examples:

**Python (uv/FastAPI):**
```dockerfile
FROM python:3.13-slim
WORKDIR /app
RUN pip install --no-cache-dir uv
COPY web-api/pyproject.toml web-api/uv.lock web-api/.python-version ./
RUN uv sync --no-dev --frozen
COPY web-api/ .
EXPOSE 8000
CMD ["uv", "run", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**Node.js:**
```dockerfile
FROM node:20-slim
WORKDIR /app
COPY api/package.json api/package-lock.json ./
RUN npm ci --production
COPY api/ .
EXPOSE 3000
CMD ["node", "src/index.js"]
```

**Important:** The Dockerfile is built from the repo root with `-f infra/preview/Dockerfile .` so COPY paths are relative to root.

### 5. `.github/workflows/preview-deploy.yml`

Triggered on `pull_request: [opened, synchronize, reopened]`.

**Job structure:**

```
Job 1: build-api-image (parallel)
  - OIDC auth → ECR login → docker build + push
  - Tag: pr-{PR_NUMBER}
  - Output: image_uri

Job 2 (optional): supabase-credentials (parallel, only if Supabase branching)
  - Wait for Supabase preview branch
  - Get branch credentials via Management API
  - Double base64-encode keys to pass between jobs (GitHub masks single-encoded secrets)

Job 3: deploy-infra (needs Job 1 + optional Job 2)
  - Clean up ROLLBACK_COMPLETE / ROLLBACK_IN_PROGRESS / DELETE_FAILED stacks
  - cloudformation deploy with preview/template.yaml
  - Get stack outputs (URLs, bucket names, distribution IDs)

Job 4: deploy-static-sites (needs Job 3)
  - npm ci && npm run build for each static site
  - Set VITE_API_URL from stack output
  - aws s3 sync to each bucket
  - CloudFront cache invalidation
  - Post/update PR comment with preview URLs
```

**Critical patterns to include:**

1. **ROLLBACK cleanup before deploy:**
```yaml
- name: Clean up failed stack if needed
  run: |
    STACK_NAME="preview-pr-${{ github.event.pull_request.number }}"
    STATUS=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" \
      --query "Stacks[0].StackStatus" --output text 2>/dev/null || echo "DOES_NOT_EXIST")
    if [ "$STATUS" = "ROLLBACK_IN_PROGRESS" ]; then
      echo "Waiting for rollback to complete..."
      aws cloudformation wait stack-rollback-complete --stack-name "$STACK_NAME"
      STATUS="ROLLBACK_COMPLETE"
    fi
    if [ "$STATUS" = "ROLLBACK_COMPLETE" ] || [ "$STATUS" = "DELETE_FAILED" ]; then
      echo "Deleting failed stack..."
      aws cloudformation delete-stack --stack-name "$STACK_NAME"
      aws cloudformation wait stack-delete-complete --stack-name "$STACK_NAME"
    fi
```

2. **PR comment with preview URLs:**
```yaml
- name: Comment on PR
  uses: actions/github-script@v7
  with:
    script: |
      const body = [
        '### Preview Environment Ready',
        '',
        '| Service | URL |',
        '|---------|-----|',
        `| API | ${{ needs.deploy-infra.outputs.api_url }} |`,
        // Add rows for each static site
      ].join('\n');

      const { data: comments } = await github.rest.issues.listComments({
        owner: context.repo.owner,
        repo: context.repo.repo,
        issue_number: context.issue.number,
      });

      const botComment = comments.find(c =>
        c.user.type === 'Bot' && c.body.includes('### Preview Environment Ready')
      );

      if (botComment) {
        await github.rest.issues.updateComment({
          owner: context.repo.owner,
          repo: context.repo.repo,
          comment_id: botComment.id,
          body,
        });
      } else {
        await github.rest.issues.createComment({
          owner: context.repo.owner,
          repo: context.repo.repo,
          issue_number: context.issue.number,
          body,
        });
      }
```

3. **Supabase double base64 encoding (if applicable):**
```yaml
# Encoding (in supabase-credentials job):
echo "anon_key_b64=$(echo -n "$ANON_KEY" | base64 -w0 | base64 -w0)" >> "$GITHUB_OUTPUT"

# Decoding (in downstream job):
ANON_KEY=$(echo -n "${{ needs.supabase-credentials.outputs.anon_key_b64 }}" | base64 -d | base64 -d)
```

### 6. `.github/workflows/preview-destroy.yml`

Triggered on `pull_request: [closed]`.

**Must perform cleanup in this order:**
1. Check if stack exists (skip if not)
2. Empty S3 buckets (required before CloudFormation can delete them)
3. Disable CloudFront distributions (required before deletion)
4. Wait for CloudFront to finish deploying disabled state
5. Delete CloudFormation stack
6. Delete ECR image tag

```yaml
- name: Empty S3 buckets
  run: |
    for BUCKET in "preview-{site}-pr-$PR_NUMBER"; do
      if aws s3api head-bucket --bucket "$BUCKET" 2>/dev/null; then
        aws s3 rm "s3://$BUCKET" --recursive
      fi
    done

- name: Disable CloudFront distributions
  run: |
    # Get distribution IDs from stack outputs
    DIST_ID=$(aws cloudformation describe-stacks ...)
    CONFIG=$(aws cloudfront get-distribution-config --id "$DIST_ID")
    ETAG=$(echo "$CONFIG" | jq -r '.ETag')
    echo "$CONFIG" | jq '.DistributionConfig.Enabled = false' | jq '.DistributionConfig' > /tmp/dist-config.json
    aws cloudfront update-distribution --id "$DIST_ID" --if-match "$ETAG" --distribution-config file:///tmp/dist-config.json
    aws cloudfront wait distribution-deployed --id "$DIST_ID"

- name: Delete stack
  run: |
    aws cloudformation delete-stack --stack-name "preview-pr-$PR_NUMBER"
    aws cloudformation wait stack-delete-complete --stack-name "preview-pr-$PR_NUMBER"

- name: Delete ECR image
  run: |
    aws ecr batch-delete-image \
      --repository-name {PROJECT_NAME}-api \
      --image-ids imageTag="pr-$PR_NUMBER" || true
```

## Procedure

1. Ask the user the questions listed in the Input section
2. Detect the GitHub org/repo from `git remote -v`
3. Detect the API runtime from existing project files
4. Generate all files with correct values substituted
5. Print a summary of:
   - Generated files
   - GitHub secrets to configure (`AWS_ROLE_ARN`, `AWS_APP_RUNNER_ECR_ROLE_ARN`, plus any API keys)
   - Bootstrap deployment command
   - How to test (open a PR)
