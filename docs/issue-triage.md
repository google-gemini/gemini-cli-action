# Issue Triage Workflow

This workflow provides a comprehensive system for triaging GitHub issues using the Gemini CLI GitHub Action.

## Features

- **Automated Triage**: When an issue is opened or reopened, the action will automatically analyze it and apply relevant labels.

## How it Works

The workflow is defined in `examples/gemini-issue-triage.yml` and is triggered when an issue is opened or reopened.

## Scheduled Triage

In addition to the immediate triage on issue creation, a scheduled workflow runs hourly to find any issues that may have been missed or have no labels, or have the `status/needs-triage` label. This ensures that all issues are eventually triaged.

This workflow can also be manually triggered.

The scheduled workflow is defined in `examples/scheduled-triage.yml`.
