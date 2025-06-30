#!/bin/bash

# This script configures Google Cloud Workload Identity Federation for a GitHub repository.

set -e

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <GCP_PROJECT_ID> <GITHUB_REPO>"
    echo "  - GCP_PROJECT_ID: Your Google Cloud project ID."
    echo "  - GITHUB_REPO: Your GitHub repository in the format 'owner/repo'."
    exit 1
fi

export GCP_PROJECT_ID="$1"
export GITHUB_REPO="$2"
export GITHUB_OWNER=$(echo "$GITHUB_REPO" | cut -d'/' -f1)

export WIF_POOL_NAME="github-actions-pool"
export WIF_PROVIDER_NAME="github-provider-${GITHUB_OWNER}"
export SERVICE_ACCOUNT_NAME="gh-sa-${GITHUB_OWNER}"

echo "🚀 Starting Workload Identity Federation setup for project '$GCP_PROJECT_ID' and repo '$GITHUB_REPO'..."

# Step 1: Create Workload Identity Pool
echo
echo "[Step 1/6] 🏊 Creating Workload Identity Pool..."
if ! gcloud iam workload-identity-pools describe "${WIF_POOL_NAME}" \
  --project="${GCP_PROJECT_ID}" \
  --location="global" &> /dev/null; then
    gcloud iam workload-identity-pools create "${WIF_POOL_NAME}" \
      --project="${GCP_PROJECT_ID}" \
      --location="global" \
      --display-name="GitHub Actions Pool"
else
    echo "Workload Identity Pool '${WIF_POOL_NAME}' already exists."
fi

# Step 2: Create Workload Identity Provider
echo
echo "[Step 2/6] 🆔 Creating Workload Identity Provider..."
if ! gcloud iam workload-identity-pools providers describe "${WIF_PROVIDER_NAME}" \
  --project="${GCP_PROJECT_ID}" \
  --location="global" \
  --workload-identity-pool="${WIF_POOL_NAME}" &> /dev/null; then
    gcloud iam workload-identity-pools providers create-oidc "${WIF_PROVIDER_NAME}" \
      --project="${GCP_PROJECT_ID}" \
      --location="global" \
      --workload-identity-pool="${WIF_POOL_NAME}" \
      --display-name="GitHub WIF - ${GITHUB_OWNER}" \
      --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" \
      --attribute-condition="assertion.repository_owner == '${GITHUB_OWNER}'" \
      --issuer-uri="https://token.actions.githubusercontent.com"
else
    echo "Workload Identity Provider '${WIF_PROVIDER_NAME}' already exists. Updating..."
    gcloud iam workload-identity-pools providers update-oidc "${WIF_PROVIDER_NAME}" \
      --project="${GCP_PROJECT_ID}" \
      --location="global" \
      --workload-identity-pool="${WIF_POOL_NAME}" \
      --display-name="GitHub WIF - ${GITHUB_OWNER}" \
      --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" \
      --attribute-condition="assertion.repository_owner == '${GITHUB_OWNER}'"
fi

# Step 3: Create Service Account
echo
echo "[Step 3/6] 👤 Creating Service Account..."
if ! gcloud iam service-accounts describe "${SERVICE_ACCOUNT_NAME}@${GCP_PROJECT_ID}.iam.gserviceaccount.com" \
  --project="${GCP_PROJECT_ID}" &> /dev/null; then
    gcloud iam service-accounts create "${SERVICE_ACCOUNT_NAME}" \
      --project="${GCP_PROJECT_ID}" \
      --display-name="GitHub SA - ${GITHUB_OWNER}"
else
    echo "Service Account '${SERVICE_ACCOUNT_NAME}' already exists."
fi

# Step 4: Grant Service Account Impersonation
echo
echo "[Step 4/6] 🤝 Granting Service Account Impersonation..."

WIF_POOL_ID=$(gcloud iam workload-identity-pools describe "${WIF_POOL_NAME}" \
  --project="${GCP_PROJECT_ID}" \
  --location="global" \
  --format="value(name)")

gcloud iam service-accounts add-iam-policy-binding "${SERVICE_ACCOUNT_NAME}@${GCP_PROJECT_ID}.iam.gserviceaccount.com" \
  --project="${GCP_PROJECT_ID}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/${WIF_POOL_ID}/attribute.repository/${GITHUB_REPO}" --condition=None

# Step 5: Grant Service Account Necessary Roles
echo
echo "[Step 5/6] 🔑 Granting necessary roles to the service account..."
gcloud projects add-iam-policy-binding "${GCP_PROJECT_ID}" \
  --member="serviceAccount:${SERVICE_ACCOUNT_NAME}@${GCP_PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/cloudtrace.agent" --condition=None
gcloud projects add-iam-policy-binding "${GCP_PROJECT_ID}" \
  --member="serviceAccount:${SERVICE_ACCOUNT_NAME}@${GCP_PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/monitoring.metricWriter" --condition=None
gcloud projects add-iam-policy-binding "${GCP_PROJECT_ID}" \
  --member="serviceAccount:${SERVICE_ACCOUNT_NAME}@${GCP_PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/logging.logWriter" --condition=None

# Step 6: Output GitHub Secrets
echo
echo "[Step 6/6] 🤫 Configure the following secrets in your GitHub repository settings:"

WIF_PROVIDER_NAME_FULL=$(gcloud iam workload-identity-pools providers describe "${WIF_PROVIDER_NAME}" \
  --project="${GCP_PROJECT_ID}" \
  --location="global" \
  --workload-identity-pool="${WIF_POOL_NAME}" \
  --format="value(name)")

echo
echo "------------------------------------------------------------------"
echo
echo "🔑 OTLP_GCP_WIF_PROVIDER: ${WIF_PROVIDER_NAME_FULL}"
echo
echo "🤖 OTLP_GCP_SERVICE_ACCOUNT: ${SERVICE_ACCOUNT_NAME}@${GCP_PROJECT_ID}.iam.gserviceaccount.com"
echo
echo "☁️ OTLP_GOOGLE_CLOUD_PROJECT: ${GCP_PROJECT_ID}"
echo
echo "------------------------------------------------------------------"

echo
echo "🎉✨🚀 Setup complete! 🚀✨🎉"
