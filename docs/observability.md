# Observability with OpenTelemetry

This action can be configured to send telemetry data to your own Google Cloud project for observability. This allows you to monitor the performance and behavior of the Gemini CLI within your workflows.

## Setup

To set up the necessary Google Cloud resources, you can use the provided script. This script will create a service account, grant it the necessary permissions, and configure Workload Identity Federation.

```bash
./scripts/setup_workload_identity.sh <GCP_PROJECT_ID> <GITHUB_REPO>
```

Replace `<GCP_PROJECT_ID>` with your Google Cloud project ID and `<GITHUB_REPO>` with your GitHub repository in the format `owner/repo`.

The script will output the names and values for the secrets you need to add to your GitHub repository.

### Manual Setup

If you prefer to set up the resources manually, you can follow these steps:

1.  **Create a Google Cloud Service Account for OTLP**
2.  **Grant IAM Permissions to the OTLP Service Account**
3.  **Set Up Workload Identity Federation**
4.  **Allow the OTLP Service Account to be Impersonated**
5.  **Configure OTLP-Specific GitHub Secrets**

For detailed instructions on each of these steps, please refer to the [Google Cloud documentation on Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation).

## Inputs

To enable this feature, you will need to provide the following inputs in your GitHub Actions workflow:

- `OTLP_GCP_WIF_PROVIDER`: The Workload Identity Federation provider for authenticating to Google Cloud.
- `OTLP_GCP_SERVICE_ACCOUNT`: The service account to use for authentication.
- `OTLP_GOOGLE_CLOUD_PROJECT`: The Google Cloud project where you want to send your telemetry data.

When enabled, the action will automatically start an OpenTelemetry collector that forwards traces, metrics, and logs to your specified GCP project. You can then use Google Cloud's operations suite (formerly Stackdriver) to visualize and analyze this data.
