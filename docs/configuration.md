# Configuring the Gemini CLI Action

You can customize the behavior of the Gemini CLI Action by using the available inputs in your GitHub workflow file. For advanced use cases, you can provide a JSON object to the `settings_json` input to control the underlying Gemini CLI.

## Action Inputs

### `prompt`

-   **Type:** `string`
-   **Optional:** `true`
-   **Default:** `'You are a helpful assistant.'`

A specific, multi-line prompt to guide Gemini's behavior. This is where you define the persona, workflow, and instructions for the model.

### `GEMINI_API_KEY`

-   **Type:** `string`
-   **Required:** `true`

Your Gemini API key. It is strongly recommended that you store this as a [GitHub secret](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions) in your repository.

### `version`

-   **Type:** `string`
-   **Optional:** `true`
-   **Default:** `latest`

The version of `@google/gemini-cli` to execute. Can be a specific version from npm (e.g., '0.1.0', 'latest'), a branch name (e.g., 'main'), or a commit hash.

**Using a specific version from npm:**

```yaml
- name: Run a specific version of Gemini CLI
  uses: google-gemini/gemini-cli-action@main
  with:
    version: '0.1.0'
    # ... other inputs
```

**Using the latest version from npm:**

```yaml
- name: Run the latest version of Gemini CLI
  uses: google-gemini/gemini-cli-action@main
  with:
    version: 'latest'
    # ... other inputs
```

**Using the main branch:**

This is useful for testing the latest, unreleased features.

```yaml
- name: Run Gemini CLI from the main branch
  uses: google-gemini/gemini-cli-action@main
  with:
    version: 'main'
    # ... other inputs
```

**Using a specific commit hash:**

This is useful for pinning the action to a specific commit for stability and reproducibility.

```yaml
- name: Run Gemini CLI from a specific commit
  uses: google-gemini/gemini-cli-action@main
  with:
    version: 'd8d78d73f9638d11ba8b6ba184b49d4dc7caa8f4'
    # ... other inputs
```

### `settings_json`

-   **Type:** `string` (JSON)
-   **Optional:** `true`

A JSON string that will be written to a `.gemini/settings.json` file in the workspace. This allows you to configure the Gemini CLI's behavior. For a complete list of available settings, refer to the [official Gemini CLI configuration documentation](https://github.com/google-gemini/gemini-cli/blob/main/docs/cli/configuration.md).

**Allowlisting Tools**

In automated workflows, it is crucial to allowlist the tools that the Gemini model can access. The `coreTools` setting allows you to define a specific list of tools that are permitted.

This example demonstrates how to allow only the `ReadFileTool` and a specific, safe `ShellTool` command, while implicitly denying all others.

```yaml
- name: Run Gemini with Restricted Tools
  uses: google-gemini/gemini-cli-action@main
  with:
    GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}
    prompt: "Read the package.json file and list its dependencies."
    settings_json: |
      {
        "coreTools": [
          "ReadFileTool",
          "ShellTool(cat package.json)"
        ]
      }
```

By using `coreTools`, you create a safe execution environment where the model can only perform the tasks you have explicitly allowed.

### Telemetry Inputs

For information on configuring observability and telemetry, please see the [Observability documentation](./observability.md).
