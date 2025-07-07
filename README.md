# Gemini CLI Action

Automate software development tasks within your GitHub repositories with [Gemini CLI](https://github.com/google-gemini/gemini-cli). 

You can interact with Gemini by mentioning it in pull request comments and issues to perform tasks like code generation, analysis, and modification.

## Features

- **Comment-based Interaction**: Trigger workflows in issue and pull request comments.
- **Automated Issue Management**: Automatically triage issues by applying labels based on issue content.
- **Extensible with Tools**: Leverage Gemini's tool-calling capabilities to interact with other CLIs like the `gh` CLI for powerful automations.
- **Customizable**: Use a `GEMINI.md` file in your repository to provide project-specific instructions and context to Gemini.

## Getting Started

Before using this action, you need to:

1.  **Get a Gemini API Key**: Obtain your API key from [Google AI Studio](https://aistudio.google.com/apikey).
2.  **Add it as a GitHub Secret**: Store your API key as a secret in your repository with the name `GEMINI_API_KEY`. For more information, see the [official GitHub documentation on creating and using encrypted secrets](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions).

## Usage and Examples

To use this action, create a workflow file in your repository (e.g., `.github/workflows/gemini.yml`). 

The best way to get started is to copy one of the pre-built workflows from the [`/examples`](./examples) directory into your project's `.github/workflows` folder and customize it.

See the sections below for specific examples.

## Issue Triage

This action can be used to automatically triage GitHub issues. For a detailed guide on how to set up the issue triage system, please see the [**Issue Triage documentation**](./docs/issue-triage.md).

Example workflows:

- [`gemini-issue-automated-triage.yml`](./examples/gemini-issue-automated-triage.yml): Automatically analyzes and applies appropriate labels to newly opened or reopened issues.
- [`gemini-issue-scheduled-triage.yml`](./examples/gemini-issue-scheduled-triage.yml): A scheduled workflow that triages any issues that were missed by the real-time triage.

## Configuration

This action is configured via inputs in your workflow file. For detailed information on all available inputs, including the `version` input (which supports executing from npm, a branch, or a commit hash), and advanced configuration options using `settings_json`, please see the [**Configuration documentation**](./docs/configuration.md).

## Authentication

This action uses the `gh` CLI to interact with the GitHub API. You'll need to provide it with a token that has the necessary permissions for your use case.

When you create your GitHub App, you must grant it the correct permissions for your intended use cases. The permissions below are required for the provided example workflows to function correctly.

- **Repository permissions:**
  - **Contents**: `Read-only` - Allows the action to check out code and read repository files.
  - **Issues**: `Read & write` - Allows the action to read issue details and then comment on or label them.

**Important**: The permissions above are a baseline for the examples. If you create custom workflows that interact with the GitHub API in other ways (e.g., modifying projects, creating branches, managing deployments), you must update your GitHub App's permissions to grant the necessary access. Always follow the principle of least privilege, granting only the permissions your specific workflow requires.

For more information on creating and using GitHub Apps, see the [documentation](https://docs.github.com/en/apps).

## Observability with OpenTelemetry

This action can be configured to send telemetry data (traces, metrics, and logs) to your own Google Cloud project. This allows you to monitor the performance and behavior of the Gemini CLI within your workflows, providing valuable insights for debugging and optimization.

For detailed instructions on how to set up and configure observability, please see the [Observability documentation](./docs/observability.md).

### Google Cloud Authentication

To use observability features with Google Cloud, you'll need to set up Workload Identity Federation. For detailed setup instructions, see the [Workload Identity Federation documentation](./docs/workload-identity.md).

## Customization

Create a `GEMINI.md` file in the root of your repository to provide project-specific context and instructions to Gemini. This is useful for defining coding conventions, architectural patterns, or other guidelines the model should follow.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request with your improvements.
