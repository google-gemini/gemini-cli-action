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

This action can be used to triage GitHub issues automatically or on a schedule. For a detailed guide on how to set up the issue triage system, please see the [**Issue Triage documentation**](./docs/issue-triage.md).

## Pull Request Review

This action can be used to automatically review pull requests when they are opened, synchronized, or reopened. Additionally, users with `OWNER`, `MEMBER`, or `COLLABORATOR` permissions can trigger a review by commenting `@gemini-cli /review` in a pull request.

For a detailed guide on how to set up the pull request review system, please see the [**Pull Request Review documentation**](./docs/pr-review.md).

## Configuration

This action is configured via inputs in your workflow file. For detailed information on all available inputs, including the `version` input (which supports executing from npm, a branch, or a commit hash), and advanced configuration options using `settings_json`, please see the [**Configuration documentation**](./docs/configuration.md).

## Authentication

This action requires a GitHub token to interact with the GitHub API. You can authenticate in two ways:

1.  **Custom GitHub App (Recommended):** For the most secure and flexible authentication, we recommend creating a custom GitHub App.
2.  **Default `GITHUB_TOKEN`:** For simpler use cases, the action can use the default `GITHUB_TOKEN` provided by the workflow.

For a detailed guide on how to set up authentication, including creating a custom app and the required permissions, please see the [**Authentication documentation**](./docs/github-app.md).

## Observability with OpenTelemetry

This action can be configured to send telemetry data (traces, metrics, and logs) to your own Google Cloud project. This allows you to monitor the performance and behavior of the Gemini CLI within your workflows, providing valuable insights for debugging and optimization.

For detailed instructions on how to set up and configure observability, please see the [Observability documentation](./docs/observability.md).

### Google Cloud Authentication

To use observability features with Google Cloud, you'll need to set up Workload Identity Federation. For detailed setup instructions, see the [Workload Identity Federation documentation](./docs/workload-identity.md).

## Customization

Create a `GEMINI.md` file in the root of your repository to provide project-specific context and instructions to Gemini. This is useful for defining coding conventions, architectural patterns, or other guidelines the model should follow.

## Contributing

Contributions are welcome! Please see our [**Contributing Guide**](./CONTRIBUTING.md) for more details on how to get started.
