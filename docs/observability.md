# Observability with OpenTelemetry

This action can be configured to send telemetry data (traces, metrics, and logs) to your own Google Cloud project. This allows you to monitor the performance and behavior of the Gemini CLI within your workflows, providing valuable insights for debugging and optimization.

## Inputs

To enable this feature, you will need to provide the following inputs in your GitHub Actions workflow:

-   `OTLP_GCP_WIF_PROVIDER`: The full resource name of the Workload Identity Provider.
-   `OTLP_GCP_SERVICE_ACCOUNT`: The email address of the service account.
-   `OTLP_GOOGLE_CLOUD_PROJECT`: The Google Cloud project where you want to send your telemetry data.

When enabled, the action will automatically start an OpenTelemetry collector that forwards traces, metrics, and logs to your specified GCP project. You can then use Google Cloud's operations suite (formerly Stackdriver) to visualize and analyze this data.

## Setup: Obtaining Input Values

The recommended way to configure your Google Cloud project and get the values for the inputs above is to use the provided setup script. This script automates the creation of all necessary resources, including a dedicated service account and a Workload Identity Federation provider, ensuring a secure, keyless authentication mechanism.

### Automated Setup (Recommended)

Run the following command from the root of this repository. The script is idempotent, meaning it is safe to run multiple times. It will create new resources on the first run and simply update them on subsequent runs.

```bash
./scripts/setup_workload_identity.sh <GCP_PROJECT_ID> <GITHUB_REPO>
```

-   `<GCP_PROJECT_ID>`: Your Google Cloud project ID.
-   `<GITHUB_REPO>`: Your GitHub repository in the format `owner/repo`.

After the script completes, it will output the names and values for the three inputs listed above. You must add these to your GitHub repository's secrets to complete the setup.

#### Multi-Organization and Multi-Repository Support

The script is designed to support multiple GitHub organizations and repositories securely:

-   **Provider per Organization**: It creates a unique Workload Identity Provider for each GitHub organization (e.g., `github-provider-<my-org`>).
-   **Service Account per Organization**: It creates a unique, dedicated Service Account for each organization (e.g., `gh-sa-<my-org>`).
-   **Permissions per Repository**: It grants permissions on a per-repository basis.

To add another repository, simply re-run the script with the new repository's information.

### Manual Setup

If you prefer to set up the resources manually, follow these steps. These commands mirror the logic in the automated script. After completing these steps, you will have the necessary values for the `OTLP_GCP_WIF_PROVIDER`, `OTLP_GCP_SERVICE_ACCOUNT`, and `OTLP_GOOGLE_CLOUD_PROJECT` inputs.

1.  **Define Variables:**

    ```bash
    export GCP_PROJECT_ID="your-gcp-project-id"
    export GITHUB_REPO="owner/repo"
    export GITHUB_OWNER=$(echo "$GITHUB_REPO" | cut -d'/' -f1)
    export WIF_POOL_NAME="github-actions-pool"
    export WIF_PROVIDER_NAME="github-provider-${GITHUB_OWNER}"
    export SERVICE_ACCOUNT_NAME="gh-sa-${GITHUB_OWNER}"
    ```

2.  **Create Workload Identity Pool:**

    ```bash
    gcloud iam workload-identity-pools create "${WIF_POOL_NAME}" \
      --project="${GCP_PROJECT_ID}" \
      --location="global" \
      --display-name="GitHub Actions Pool"
    ```

3.  **Create Workload Identity Provider:**

    ```bash
    gcloud iam workload-identity-pools providers create-oidc "${WIF_PROVIDER_NAME}" \
      --project="${GCP_PROJECT_ID}" \
      --location="global" \
      --workload-identity-pool="${WIF_POOL_NAME}" \
      --display-name="GitHub WIF - ${GITHUB_OWNER}" \
      --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" \
      --attribute-condition="assertion.repository_owner == '${GITHUB_OWNER}'" \
      --issuer-uri="https://token.actions.githubusercontent.com"
    ```

4.  **Create Service Account:**

    ```bash
    gcloud iam service-accounts create "${SERVICE_ACCOUNT_NAME}" \
      --project="${GCP_PROJECT_ID}" \
      --display-name="GitHub SA - ${GITHUB_OWNER}"
    ```

5.  **Grant Service Account Impersonation:**

    ```bash
    WIF_POOL_ID=$(gcloud iam workload-identity-pools describe "${WIF_POOL_NAME}" --project="${GCP_PROJECT_ID}" --location="global" --format="value(name)")
    gcloud iam service-accounts add-iam-policy-binding "${SERVICE_ACCOUNT_NAME}@${GCP_PROJECT_ID}.iam.gserviceaccount.com" \
      --project="${GCP_PROJECT_ID}" \
      --role="roles/iam.workloadIdentityUser" \
      --member="principalSet://iam.googleapis.com/${WIF_POOL_ID}/attribute.repository/${GITHUB_REPO}"
    ```

6.  **Grant Necessary Roles to Service Account:**

    ```bash
    gcloud projects add-iam-policy-binding "${GCP_PROJECT_ID}" \
      --member="serviceAccount:${SERVICE_ACCOUNT_NAME}@${GCP_PROJECT_ID}.iam.gserviceaccount.com" \
      --role="roles/cloudtrace.agent"
    gcloud projects add-iam-policy-binding "${GCP_PROJECT_ID}" \
      --member="serviceAccount:${SERVICE_ACCOUNT_NAME}@${GCP_PROJECT_ID}.iam.gserviceaccount.com" \
      --role="roles/monitoring.metricWriter"
    gcloud projects add-iam-policy-binding "${GCP_PROJECT_ID}" \
      --member="serviceAccount:${SERVICE_ACCOUNT_NAME}@${GCP_PROJECT_ID}.iam.gserviceaccount.com" \
      --role="roles/logging.logWriter"
    ```
