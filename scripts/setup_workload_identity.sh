#!/bin/bash

# This script configures Google Cloud Workload Identity Federation for a GitHub repository.

set -e

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <GCP_PROJECT_ID> <GITHUB_REPO>"
    echo "  - GCP_PROJECT_ID: Your Google Cloud project ID."
    echo "  - GITHUB_REPO: Your GitHub repository in the format 'owner/repo'."
    exit 1
fi

export OTLP_PROJECT_ID="$1"
export GITHUB_REPO="$2"

export OTLP_SERVICE_ACCOUNT_NAME="github-otlp-telemetry"
export OTLP_POOL_NAME="github-actions-pool"

echo "🚀 Starting Workload Identity Federation setup for project '$OTLP_PROJECT_ID' and repo '$GITHUB_REPO'..."

# Step 1: Create a Google Cloud Service Account for OTLP
echo "
[Step 1/5] 👤 Checking for service account '${OTLP_SERVICE_ACCOUNT_NAME}'..."
if ! gcloud iam service-accounts describe ${OTLP_SERVICE_ACCOUNT_NAME}@${OTLP_PROJECT_ID}.iam.gserviceaccount.com --project=${OTLP_PROJECT_ID} &> /dev/null; then
    echo "Service account not found, creating..."
    gcloud iam service-accounts create ${OTLP_SERVICE_ACCOUNT_NAME} \
      --project=${OTLP_PROJECT_ID} \
      --display-name="GitHub Actions OTLP Telemetry"
else
    echo "Service account already exists."
fi

# Step 2: Grant IAM Permissions to the OTLP Service Account
echo "
[Step 2/5] 🔑 Granting IAM permissions to the service account..."
gcloud projects add-iam-policy-binding ${OTLP_PROJECT_ID} \
  --member="serviceAccount:${OTLP_SERVICE_ACCOUNT_NAME}@${OTLP_PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/cloudtrace.agent" --condition=None
gcloud projects add-iam-policy-binding ${OTLP_PROJECT_ID} \
  --member="serviceAccount:${OTLP_SERVICE_ACCOUNT_NAME}@${OTLP_PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/monitoring.metricWriter" --condition=None
gcloud projects add-iam-policy-binding ${OTLP_PROJECT_ID} \
  --member="serviceAccount:${OTLP_SERVICE_ACCOUNT_NAME}@${OTLP_PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/logging.logWriter" --condition=None

# Step 3: Set Up Workload Identity Federation
echo "
[Step 3/5] 🔗 Setting up Workload Identity Federation..."

if ! gcloud iam workload-identity-pools describe ${OTLP_POOL_NAME} --project=${OTLP_PROJECT_ID} --location="global" &> /dev/null; then
    echo "Creating Workload Identity Pool '${OTLP_POOL_NAME}'..."
    gcloud iam workload-identity-pools create ${OTLP_POOL_NAME} \
      --project=${OTLP_PROJECT_ID} \
      --location="global" \
      --display-name="GitHub Actions Pool"
else
    echo "Workload Identity Pool '${OTLP_POOL_NAME}' already exists."
fi

export OTLP_POOL_ID=$(gcloud iam workload-identity-pools describe ${OTLP_POOL_NAME} \
  --project=${OTLP_PROJECT_ID} \
  --location="global" \
  --format="value(name)")

if ! gcloud iam workload-identity-pools providers describe "github-provider" --project=${OTLP_PROJECT_ID} --location="global" --workload-identity-pool=${OTLP_POOL_NAME} &> /dev/null; then
    echo "Creating Workload Identity Provider 'github-provider'..."
    gcloud iam workload-identity-pools providers create-oidc "github-provider" \
      --project=${OTLP_PROJECT_ID} \
      --location="global" \
      --workload-identity-pool=${OTLP_POOL_NAME} \
      --display-name="GitHub Provider" \
      --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
      --issuer-uri="https://token.actions.githubusercontent.com"
else
    echo "Workload Identity Provider 'github-provider' already exists."
fi

# Step 4: Allow the OTLP Service Account to be Impersonated
echo "
[Step 4/5] 🤝 Allowing the service account to be impersonated..."
gcloud iam service-accounts add-iam-policy-binding "${OTLP_SERVICE_ACCOUNT_NAME}@${OTLP_PROJECT_ID}.iam.gserviceaccount.com" \
  --project=${OTLP_PROJECT_ID} \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/${OTLP_POOL_ID}/attribute.repository/${GITHUB_REPO}" --condition=None

# Step 5: Configure OTLP-Specific GitHub Secrets
echo "
[Step 5/5] 🤫 Please configure the following secrets in your ${GITHUB_REPO} GitHub repository's settings:"

OTLP_GCP_SA_EMAIL="${OTLP_SERVICE_ACCOUNT_NAME}@${OTLP_PROJECT_ID}.iam.gserviceaccount.com"
OTLP_GCP_WIF_PROVIDER=$(gcloud iam workload-identity-pools providers describe "github-provider" \
  --project=${OTLP_PROJECT_ID} \
  --location="global" \
  --workload-identity-pool=${OTLP_POOL_NAME} \
  --format="value(name)")

echo "
  OTLP_GCP_SERVICE_ACCOUNT: ${OTLP_GCP_SA_EMAIL}"
echo "  OTLP_GCP_WIF_PROVIDER: ${OTLP_GCP_WIF_PROVIDER}"
echo "  OTLP_GOOGLE_CLOUD_PROJECT: ${OTLP_PROJECT_ID}"

echo "
🎉✨🚀 Setup complete! 🚀✨🎉"
