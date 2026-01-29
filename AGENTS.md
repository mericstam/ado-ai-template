# AI Agent Instructions

This file provides context and guidelines for AI agents (Claude, Copilot, etc.) working on this repository.

## Rules

1. **All content must be in English** - Documentation, code comments, commit messages, PR descriptions, and all other written content must be in English.

## Project Overview

This repository contains an **Azure DevOps AI Agent Automation** system that:
- Triggers from Azure DevOps work items (via tags)
- Uses OpenCode agent to analyze and implement solutions
- Creates Pull Requests in GitHub Enterprise
- Updates work item status throughout the process

## Architecture

```
Azure DevOps Work Item (tag: "ai-ready")
        │
        ▼
Azure DevOps Pipeline
        │
        ▼
OpenCode Agent ──► GitHub Enterprise (PR)
        │
        ▼
Work Item (status update) ──► Teams (on error)
```

## Key Components

| Component | Technology | Purpose |
|-----------|------------|---------|
| Orchestration | Azure DevOps Pipelines | Triggers and coordinates the workflow |
| AI Agent | OpenCode | Analyzes work items and implements solutions |
| Version Control | GitHub Enterprise | Hosts code and PRs |
| Authentication | Personal Access Token (PAT) | Secure access to APIs |
| Notifications | Teams Webhook | Error escalation |
| Configuration | YAML files | Definition of Done per component |

## Directory Structure

```
/
├── AGENTS.md                        # AI agent instructions (this file)
├── README.md                        # Project overview and quick start
├── PRD.md                           # Product requirements document
├── opencode.json                    # OpenCode configuration
├── pipelines/
│   ├── ai-agent.yml                 # Main pipeline definition
│   └── templates/
│       ├── analyze.yml              # Analysis stage template
│       └── implement.yml            # Implementation stage template
├── scripts/
│   ├── get-workitem-context.sh      # Fetch work item details
│   ├── update-workitem.sh           # Update work item comments/tags
│   └── send-teams-notification.sh   # Send Teams notifications
├── config/
│   └── dod/
│       └── default.yml              # Default Definition of Done
└── docs/
    ├── SETUP.md                     # Installation guide
    ├── DOD-GUIDE.md                 # Definition of Done guide
    └── azure-pipelines-ghe.md       # Technical setup guide
```

## Coding Guidelines

### Scripts (Bash)

- Use `#!/bin/bash` shebang
- Include `set -e` for error handling
- Parse arguments with `while [[ $# -gt 0 ]]` pattern
- Validate required environment variables
- Use meaningful variable names in UPPER_CASE for env vars

### Pipeline YAML

- Use templates for reusable stages
- Store all secrets in pipeline variables (never in code)
- Include proper conditions for stage execution
- Add descriptive `displayName` to all steps

### Definition of Done Structure

```yaml
component: "component-name"
quality_gates:
  build:
    command: "build command"
    required: true
  test:
    command: "test command"
    required: true
    min_coverage: 80
  lint:
    command: "lint command"
    required: true

context:
  system_prompt: |
    Context for the AI agent working on this component.

templates:
  analysis: |
    Template for analysis output.
```

## Work Item Integration

The system uses work item comments (not custom fields) for status updates.

Tags used:
- `ai-ready`: Triggers analysis
- `ai-working`: Added during processing
- `ai-approved`: Triggers implementation
- `ai-failed`: Added on error

## Security Considerations

- Never commit PATs or secrets to the repository
- Agent can only create PRs, never merge
- All actions are logged in pipeline and work item
- Agent access is limited to specific repos

## Related Documentation

- [README.md](README.md) - Quick start guide
- [PRD.md](PRD.md) - Full product requirements with user stories
- [docs/SETUP.md](docs/SETUP.md) - Installation and configuration
- [docs/DOD-GUIDE.md](docs/DOD-GUIDE.md) - Definition of Done guide
- [docs/azure-pipelines-ghe.md](docs/azure-pipelines-ghe.md) - Technical setup guide

## Status

MVP implemented. See [PRD.md](PRD.md) for detailed roadmap.
