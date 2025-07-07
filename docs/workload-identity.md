# Direct Workload Identity Federation Setup for GitHub Actions

This guide covers setting up Google Cloud **Direct Workload Identity Federation** for GitHub repositories using the `scripts/setup_workload_identity.sh` script.

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [GitHub Configuration](#github-configuration)
- [Troubleshooting](#troubleshooting)
- [Advanced Configuration](#advanced-configuration)
- [Security Best Practices](#security-best-practices)


## Overview

**Direct Workload Identity Federation** is Google Cloud's preferred method for GitHub Actions authentication. It provides:

- **No intermediate service accounts** - Direct authentication to GCP resources
- **Enhanced security** - No long-lived credentials or keys
- **Simplified setup** - Fewer components to manage
- **Built-in observability** - Automatic logging, monitoring, and tracing permissions

### How it Works

```
GitHub Actions → OIDC Token → Workload Identity Pool → Direct GCP Resource Access
```

### Automatic Permissions

The script automatically grants these essential permissions:
- **`roles/logging.logWriter`** - Write logs to Cloud Logging
- **`roles/monitoring.metricWriter`** - Write metrics to Cloud Monitoring
- **`roles/cloudtrace.agent`** - Send traces to Cloud Trace

## Quick Start

```bash
# Basic setup for any repository
./scripts/setup_workload_identity.sh --repo OWNER/REPO

# Example
./scripts/setup_workload_identity.sh --repo google/my-project
```

## Prerequisites

### Required Tools
- **Google Cloud Project** with billing enabled
- **gcloud CLI** installed and authenticated (`gcloud auth login`)
- **Bash shell** (any version)

### Required IAM Permissions
Your user account needs these permissions in the target GCP project:
- `resourcemanager.projects.setIamPolicy`
- `iam.workloadIdentityPools.create`
- `iam.workloadIdentityPools.update`
- `serviceusage.services.enable`

## Usage

### Command Line Options

| Option | Description | Example |
|--------|-------------|---------|
| `--repo OWNER/REPO` | **Required**: GitHub repository | `--repo google/my-repo` |
| `--project PROJECT_ID` | GCP project ID (auto-detected if not provided) | `--project my-gcp-project` |
| `--pool-name NAME` | Custom pool name (default: `github`) | `--pool-name my-pool` |
| `--help` | Show help message | |

### Examples

```bash
# Basic setup with auto-detected project
./scripts/setup_workload_identity.sh --repo google/my-repo

# With specific project
./scripts/setup_workload_identity.sh --repo google/my-repo --project my-gcp-project

# Custom pool name
./scripts/setup_workload_identity.sh --repo google/my-repo --pool-name my-custom-pool
```

### What the Script Does

1. **Enables required APIs**: IAM, STS, Logging, Monitoring, Tracing
2. **Creates Workload Identity Pool**: Shared resource (named `github` by default)
3. **Creates Workload Identity Provider**: Unique per repository
4. **Grants permissions**: Automatic observability permissions
5. **Outputs configuration**: GitHub secrets and workflow example

## GitHub Configuration

After running the script, add these **2 secrets** to your repository:

Go to: `https://github.com/OWNER/REPO/settings/secrets/actions`

| Secret Name | Description |
|-------------|-------------|
| `OTLP_GCP_WIF_PROVIDER` | Workload Identity Provider resource name |
| `OTLP_GOOGLE_CLOUD_PROJECT` | Your Google Cloud project ID |

## Troubleshooting

### Common Issues

#### 🔸 "Token exchange failed"
**Causes:**
- Repository name mismatch (case-sensitive!)
- Missing `id-token: write` permission
- Wrong `WIF_PROVIDER` secret value

**Solutions:**
1. Verify exact repository name: `git remote get-url origin`
2. Check workflow has required permissions block
3. Verify the `OTLP_GCP_WIF_PROVIDER` secret value

#### 🔸 "Permission denied on GCP resources"
**Causes:**
- Resource doesn't support `principalSet` identities
- Missing specific resource permissions

**Solutions:**
1. Check if the GCP service supports Direct WIF
2. Grant additional permissions (see [Advanced Configuration](#advanced-configuration))

#### 🔸 "Token lifetime exceeded (10 minutes)"
**Causes:**
- Normal behavior - Direct WIF tokens expire after 10 minutes

**Solutions:**
1. For long-running operations, break into smaller steps
2. For services requiring longer tokens, consider Service Account WIF instead

#### 🔸 "Display name too long" error
**Cause:**
- Provider display name exceeds 32 characters

**Solution:**
- Script automatically uses short display names (already fixed)

### Debugging Commands

```bash
# View current permissions
gcloud projects get-iam-policy PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:principalSet://iam.googleapis.com/POOL_ID/attribute.repository/REPO" \
  --format="table(bindings.role)"

# View Workload Identity Pool
gcloud iam workload-identity-pools describe github \
  --project=PROJECT_ID \
  --location=global

# View Workload Identity Provider
gcloud iam workload-identity-pools providers describe PROVIDER_NAME \
  --project=PROJECT_ID \
  --location=global \
  --workload-identity-pool=github
```

## Direct WIF Limitations

**Important considerations:**
- **10-minute token lifetime** - Tokens automatically expire
- **Limited service support** - Not all GCP services support `principalSet` identities
- **No OAuth tokens** - Cannot generate OAuth 2.0 access tokens or ID tokens
- **Read-only by default** - Additional permissions must be explicitly granted

## Security Best Practices

### 1. Repository Restriction
The script automatically restricts access to your specific repository owner:
```
assertion.repository_owner == 'YOUR_ORG'
```

### 2. Principle of Least Privilege
- Start with automatic permissions (observability only)
- Add specific permissions as needed
- Regularly review and audit permissions

### 3. Environment Separation
- Use different projects for dev/staging/prod
- Set up separate Workload Identity Pools per environment
- Implement different permission levels per environment

### 4. Monitoring and Auditing
- Use Cloud Logging to monitor authentication events
- Set up alerts for unusual authentication patterns
- Regular permission audits

## Additional Resources

- [Google Cloud Direct Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation)
- [google-github-actions/auth Documentation](https://github.com/google-github-actions/auth)
- [GitHub OIDC Documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
