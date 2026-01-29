# Setup Guide

This guide explains how to set up the AI Agent Automation pipeline in your Azure DevOps project.

## Prerequisites

- Azure DevOps project with Pipelines enabled
- GitHub Enterprise repository
- Access to create service connections and pipeline variables
- Teams channel for notifications (optional)

## Step 1: Create Access Tokens

### Azure DevOps PAT

1. Go to Azure DevOps → User Settings → Personal Access Tokens
2. Create a new token with these scopes:
   - **Work Items**: Read & Write
   - **Code**: Read & Write (if repo is in Azure DevOps)
3. Copy the token securely

### GitHub Enterprise Token

1. Go to GitHub Enterprise → Settings → Developer Settings → Personal Access Tokens
2. Create a new token with these scopes:
   - `repo` (full control)
   - `read:org`
3. Copy the token securely

## Step 2: Configure Pipeline Variables

In Azure DevOps, go to Pipelines → Library → Variable Groups.

Create a variable group named `ai-agent-config` with these variables:

| Variable | Type | Value |
|----------|------|-------|
| `COPILOT_GITHUB_TOKEN` | Secret | GitHub Copilot token (for AI model access) |
| `GHE_TOKEN` | Secret | GitHub Enterprise token (for repo access) |
| `GH_HOST` | Plain | GHE hostname (e.g., `github.mycompany.com`) |
| `TEAMS_WEBHOOK_URL` | Secret | Teams incoming webhook URL (optional) |

> **Note:** The env variable must be named exactly `COPILOT_GITHUB_TOKEN` - OpenCode has special handling for this name.

**Note:** Pipeline uses `$(System.AccessToken)` for Azure DevOps API calls, so no separate PAT is needed.

## Step 3: Create the Pipeline

1. Go to Pipelines → New Pipeline
2. Select your repository
3. Choose "Existing Azure Pipelines YAML file"
4. Select `pipelines/ai-agent.yml`
5. Save (don't run yet)

## Step 4: Create Incoming Webhook Service Connection

The pipeline needs an incoming webhook to receive events from service hooks.

1. Go to **Project Settings** → **Service connections**
2. Click **New service connection**
3. Search for and select **Incoming Webhook**
4. Configure:
   - **Webhook Name**: `ai-agent-trigger`
   - **Secret**: Leave blank or generate one
   - **Service connection name**: `ai-agent-trigger`
5. Click **Save**

Note the webhook URL - you'll need it for the service hook.

## Step 5: Set Up Service Hooks (Trigger)

Create two service hooks to trigger on relevant tag changes:

### Service Hook 1: ai-ready tag

1. Go to **Project Settings** → **Service hooks**
2. Click **+ Create subscription**
3. Select **Web Hooks** as the service → **Next**
4. Configure trigger:
   - **Trigger**: Work item updated
   - **Area path**: (optional)
   - **Tag**: `ai-ready`
5. Click **Next**
6. Configure action:
   - **URL**: `https://dev.azure.com/{org}/_apis/public/distributedtask/webhooks/ai-agent-trigger?api-version=6.0-preview`
   - **HTTP headers**: `Content-Type: application/json`
7. Click **Finish**

### Service Hook 2: ai-approved tag

Repeat the steps above, but with:
- **Tag**: `ai-approved`
- Same URL as above

### Service Hook 3: Comment Commands (Optional)

Enable AI commands via work item comments using `@ai` mentions.

1. Go to **Project Settings** → **Service hooks**
2. Click **+ Create subscription**
3. Select **Web Hooks** as the service → **Next**
4. Configure trigger:
   - **Trigger**: Work item commented on
   - **Area path**: (optional)
5. Click **Next**
6. Configure action:
   - **URL**: `https://dev.azure.com/{org}/_apis/public/distributedtask/webhooks/ai-agent-trigger?api-version=6.0-preview`
   - **HTTP headers**: `Content-Type: application/json`
7. Click **Finish**

**Usage:** Add `@ai` followed by your command in any work item comment:
- `@ai please research this issue`
- `@ai suggest test cases`
- `@ai explain this error`

### Webhook URL Format

```
https://dev.azure.com/{org}/_apis/public/distributedtask/webhooks/{webhook-name}?api-version=6.0-preview
```

**Note:** The URL is at organization level (no project in path).

### Webhook Payload

The service hook sends a JSON payload with this structure:
```json
{
  "eventType": "workitem.updated",
  "resource": {
    "id": 123,
    "fields": {
      "System.Tags": "ai-ready",
      "System.Title": "..."
    }
  }
}
```

The pipeline extracts:
- Work Item ID from `resource.id`
- Tags from `resource.fields['System.Tags']`

### How it works

When a work item is updated:
1. Service hook sends the update to the incoming webhook
2. Pipeline triggers automatically
3. Pipeline checks tags to determine action:
   - `ai-ready` (without `ai-working`) → Run analysis
   - `ai-approved` (without `ai-working`) → Run implementation
   - Other → Skip (no action)

### Manual Trigger

You can still run the pipeline manually for testing, but the webhook payload won't be available.

## Step 6: Configure Teams Webhook (Optional)

To receive error notifications in Teams:

1. In Teams, go to the target channel
2. Click ••• → Connectors (or Workflows)
3. Add "Incoming Webhook"
4. Name it "AI Agent Notifications"
5. Copy the webhook URL
6. Add it to your pipeline variables as `TEAMS_WEBHOOK_URL`

## Step 7: Test the Setup

1. Create a test work item (Bug or User Story)
2. Add clear description and acceptance criteria
3. Add the tag `ai-ready`
4. Verify the pipeline triggers
5. Check that analysis appears as a comment on the work item

## Usage Flow

```
1. Developer creates/selects work item
         ↓
2. Developer adds tag: ai-ready
         ↓
3. Pipeline triggers automatically
         ↓
4. AI analyzes and posts proposal as comment
         ↓
5. Developer reviews analysis
         ↓
6. Developer adds tag: ai-approved
         ↓
7. Pipeline triggers again (implement mode)
         ↓
8. AI implements and creates PR
         ↓
9. Developer reviews and merges PR
```

## Tags Reference

| Tag | Purpose | Added By |
|-----|---------|----------|
| `ai-ready` | Triggers analysis | Developer |
| `ai-working` | Indicates processing | Pipeline |
| `ai-approved` | Triggers implementation | Developer |
| `ai-failed` | Indicates error | Pipeline |

## OpenCode Model Configuration

### Model Provider Format

OpenCode uses the format `provider/model-id` in `opencode.json`:

```json
{
  "model": "provider/model-id"
}
```

### Available Providers

| Provider | Env Variable | Example Model |
|----------|--------------|---------------|
| `openrouter` | `OPENROUTER_API_KEY` | `openrouter/openai/gpt-5.1-codex-max` |
| `openai` | `OPENAI_API_KEY` | `openai/gpt-5.1-codex-max` |
| `anthropic` | `ANTHROPIC_API_KEY` | `anthropic/claude-sonnet-4` |
| `azure` | `AZURE_OPENAI_API_KEY` | `azure/gpt-4o` |
| `groq` | `GROQ_API_KEY` | `groq/llama-3.3-70b` |

### GitHub Copilot in CI/CD

OpenCode supports GitHub Copilot in CI/CD via the `COPILOT_GITHUB_TOKEN` environment variable.

**Important:** The environment variable must be named exactly `COPILOT_GITHUB_TOKEN` - OpenCode has special handling for this specific name. Using `GITHUB_TOKEN` will not work.

```yaml
docker run --rm \
  -e COPILOT_GITHUB_TOKEN \
  ...
  ghcr.io/anomalyco/opencode run "$PROMPT"
env:
  COPILOT_GITHUB_TOKEN: $(COPILOT_GITHUB_TOKEN)
```

No model specification is needed in `opencode.json` - OpenCode will automatically use the appropriate Copilot model.

## Troubleshooting

### Pipeline doesn't trigger

- Verify service hook is configured correctly
- Check that the tag filter matches exactly (`ai-ready`)
- Ensure PAT has correct permissions

### Analysis fails

- Check pipeline logs for specific error
- Verify `COPILOT_GITHUB_TOKEN` is set and valid
- Ensure the env variable is named exactly `COPILOT_GITHUB_TOKEN` (not `GITHUB_TOKEN`)
- Ensure work item has description/acceptance criteria

### Cannot create PR

- Verify `GHE_TOKEN` has `repo` scope
- Check that `GH_HOST` is correct
- Ensure branch protection allows pushes

### Teams notifications not working

- Verify webhook URL is correct
- Check that the webhook is still active in Teams
- Look for errors in pipeline logs

## Security & Compliance

### AI Model Provider

This solution uses OpenCode with configurable AI providers. Choose a provider that meets your organization's compliance requirements:

| Provider | Data Handling |
|----------|--------------|
| OpenRouter | Routes to various models, check their data policy |
| OpenAI | Data processed by OpenAI API |
| Anthropic | Data processed by Anthropic API |
| Azure OpenAI | Data stays within your Azure tenant |

**Audit trail:** All AI interactions are logged in pipeline output.

### Token Security

- Never commit tokens to the repository
- Use pipeline secret variables for all sensitive data
- Rotate API keys and `GHE_TOKEN` regularly
- The AI agent can only create PRs, never merge them
- Pipeline uses `$(System.AccessToken)` which is automatically scoped and rotated

### Webhook Security - Accepted Risk

> **Decision Date:** 2026-01-27

The incoming webhook endpoint (`/webhooks/ai-agent-trigger`) is publicly accessible without cryptographic authentication.

**Why no HMAC verification:**
- Azure DevOps Service Hooks cannot compute HMAC-SHA1 signatures
- Adding an Azure Function proxy would increase complexity
- The incoming webhook secret feature requires the caller to compute the signature

**Mitigating factors:**
- Webhook URL is not publicly documented (obscurity)
- Payload must match expected Azure DevOps format
- Work item must exist in the organization
- Pipeline only performs read operations and creates PRs (no destructive actions)
- All actions are logged in pipeline output
- PRs require human review before merge

**Residual risk:**
- An attacker who discovers the webhook URL could trigger the pipeline on arbitrary work item IDs
- This would consume pipeline minutes and potentially spam work items with AI comments

**Alternative approaches (not implemented):**
1. Azure Function proxy with HMAC validation
2. Polling-based trigger instead of webhook
3. IP allowlisting (complex with Azure DevOps Service Hooks)

**Accepted by:** Project team, 2026-01-27
