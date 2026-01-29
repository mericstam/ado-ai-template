# Installing OpenCode in Azure Pipelines with GitHub Enterprise

This guide shows a simple setup for installing OpenCode in an Azure Pipeline and connecting to GitHub Enterprise (GHE).

## Prerequisites

- GHE host (e.g., github.mycompany.com)
- Personal access token for GHE stored as a secret in the pipeline
- Build agent with Node.js (if installing via npm)

## Recommended Pipeline Variables

- GH_HOST: your GHE host
- GH_TOKEN: token as secret variable (e.g., GHE_TOKEN)

## Example: Azure Pipelines YAML

```yaml
steps:
  - task: NodeTool@0
    inputs:
      versionSpec: '20.x'

  - script: |
      npm i -g opencode-cli
    displayName: Install OpenCode

  - script: |
      set GH_HOST=github.mycompany.com
      set GH_TOKEN=$(GHE_TOKEN)
      opencode --help
    displayName: Run OpenCode
```

## Notes

- Permissions: GH_TOKEN typically needs at least `repo` and sometimes `read:org`.
- If you already have a CI base image with OpenCode, the installation step can be skipped.
- For Linux-based agents, use `export` instead of `set`.

## Example: opencode.json

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "azure-devops": {
      "type": "local",
      "command": ["npx", "-y", "@azure-devops/mcp", "your-org"],
      "enabled": true
    }
  },
  "keybinds": {
    "app_exit": "<leader>q",
    "input_clear": "escape"
  }
}
```
