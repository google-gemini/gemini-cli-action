# PR Review with Gemini CLI

This document explains how to use the Gemini CLI action to automatically review pull requests with AI-powered code analysis.

## Overview

The PR Review workflow uses Google's Gemini AI to provide comprehensive code reviews for pull requests. It analyzes code quality, security, performance, and maintainability while providing constructive feedback in a structured format.

## Features

- **Automated PR Reviews**: Triggered on PR creation, updates, or manual requests
- **Comprehensive Analysis**: Covers security, performance, reliability, maintainability, and functionality
- **Priority-based Feedback**: Issues categorized by severity (Critical, High, Medium, Low)
- **Positive Highlights**: Acknowledges good practices and well-written code
- **Custom Instructions**: Support for specific review focus areas
- **Structured Output**: Consistent markdown format for easy reading

## Setup

### Prerequisites

1. **GitHub App Token**: Required for authentication
   - Set `APP_ID` and `PRIVATE_KEY` secrets in your repository
2. **Gemini API Key**: Required for AI functionality
   - Set `GEMINI_API_KEY` secret in your repository
3. **Telemetry (Optional)**: For observability
   - Set `OTLP_GCP_WIF_PROVIDER` and `OTLP_GOOGLE_CLOUD_PROJECT` secrets

### Workflow File

Copy the workflow file to `.github/workflows/gemini-pr-review.yml` in your repository. The workflow is already configured and ready to use.

## Usage

### Automatic Reviews

The workflow automatically triggers on:
- **New PRs**: When a pull request is opened
- **PR Updates**: When new commits are pushed to the PR
- **PR Reopening**: When a closed PR is reopened

### Manual Reviews

Trigger a review manually by commenting on a PR:

```
@gemini-cli /review
```

**Required Permissions**: Only users with the following roles can trigger manual reviews:
- Repository Owner
- Repository Member  
- Repository Collaborator

### Custom Review Instructions

You can provide specific focus areas by adding instructions after the trigger:

```
@gemini-cli /review focus on security
@gemini-cli /review check performance and memory usage  
@gemini-cli /review please review error handling
@gemini-cli /review look for breaking changes
```

### Manual Workflow Dispatch

You can also trigger reviews through the GitHub Actions UI:
1. Go to Actions tab in your repository
2. Select "Gemini PR Review" workflow
3. Click "Run workflow"
4. Enter the PR number to review

## Review Output Format

The AI review follows a structured format:

### 📋 Review Summary
Brief 2-3 sentence overview of the PR and overall assessment.

### 🔍 General Feedback  
- Overall code quality observations
- Architectural patterns and decisions
- Positive implementation aspects
- Recurring themes across files

### 🎯 Specific Feedback
Priority-based issues (only shown if issues exist):

**🔴 Critical**: Security vulnerabilities, breaking changes, major bugs that must be fixed before merging

**🟡 High**: Performance problems, design flaws, significant bugs that should be addressed

**🟢 Medium**: Code quality improvements, style issues, minor optimizations, better practices

**🔵 Low**: Nice-to-have improvements, documentation suggestions, minor refactoring

### ✅ Highlights
- Well-implemented features and good practices
- Quality code sections worth acknowledging  
- Improvements from previous versions

## Review Areas

The AI analyzes multiple dimensions of code quality:

- **Security**: Authentication, authorization, input validation, data sanitization
- **Performance**: Algorithms, database queries, caching, resource usage
- **Reliability**: Error handling, logging, testing coverage, edge cases
- **Maintainability**: Code structure, documentation, naming conventions
- **Functionality**: Logic correctness, requirements fulfillment

## Best Practices

### For Repository Maintainers

1. **Set Clear Guidelines**: Establish coding standards and review criteria for your project
2. **Use Custom Instructions**: Provide specific focus areas when requesting reviews
3. **Combine with Human Review**: Use AI reviews as a complement to, not replacement for, human code review
4. **Review AI Feedback**: AI suggestions should be evaluated for relevance and accuracy

### For Contributors

1. **Self-Review First**: Review your own code before requesting AI review
2. **Address Feedback**: Take AI suggestions seriously and address valid points
3. **Ask Questions**: Use custom instructions to get specific guidance on areas of concern
4. **Test Thoroughly**: Ensure your code is tested before requesting review

## Configuration

### Workflow Customization

You can customize the workflow by modifying:

- **Timeout**: Adjust `timeout-minutes` for longer reviews
- **Triggers**: Modify when the workflow runs
- **Permissions**: Adjust who can trigger manual reviews
- **Core Tools**: Add or remove available shell commands

### Review Prompt Customization

The AI prompt can be customized to:
- Focus on specific technologies or frameworks
- Emphasize particular coding standards
- Include project-specific guidelines
- Adjust review depth and focus areas

## Troubleshooting

### Common Issues

**Review not triggering**:
- Check that secrets are properly configured
- Verify the user has required permissions for manual triggers
- Ensure the workflow file is in the correct location

**Authentication errors**:
- Verify `APP_ID` and `PRIVATE_KEY` secrets are correct
- Check that the GitHub App has necessary permissions

**API errors**:
- Confirm `GEMINI_API_KEY` is valid and has sufficient quota
- Check API rate limits and usage

**Missing review output**:
- Check workflow logs for errors
- Verify the PR has actual code changes to review

### Getting Help

1. Check workflow run logs in the Actions tab
2. Review the [main documentation](../README.md)
3. Check the [configuration guide](configuration.md)
4. Open an issue for bugs or feature requests

## Examples

### Basic Review Request
```
@gemini-cli /review
```

### Security-Focused Review
```
@gemini-cli /review focus on security vulnerabilities and authentication
```

### Performance Review
```
@gemini-cli /review check for performance issues and optimization opportunities
```

### Breaking Changes Check
```
@gemini-cli /review look for potential breaking changes and API compatibility
```
