# Plan: Hierarchical System Configuration Support

## Research Findings - OpenCode Capabilities

### Configuration Loading Order (highest priority last)
1. Remote config (`.well-known/opencode`)
2. Global config (`~/.config/opencode/opencode.json`)
3. Custom config (`OPENCODE_CONFIG` env var)
4. **Project config** (`opencode.json` in workspace root) ← We use this

### Skills Support
- Location: `.opencode/skills/<name>/SKILL.md`
- Format: YAML frontmatter + Markdown body
- Required fields: `name`, `description`
- Optional: `license`, `compatibility`, `metadata`, `allowed-tools`
- Skills can have subdirectories: `scripts/`, `references/`, `assets/`
- Invoked via `skill` tool or automatically discovered

### Agents Support
- Location: `.opencode/agents/<name>.md` or in `opencode.json`
- Types: `primary` (user-facing), `subagent` (invoked by primary)
- Options: `model`, `temperature`, `maxSteps`, `tools`, `permission`, `prompt`
- Can restrict tool access per agent
- Can have custom system prompts

### Docker Configuration
```bash
docker run --rm \
  -e COPILOT_GITHUB_TOKEN \
  -v "$(pwd):/workspace" \
  -w /workspace \
  ghcr.io/anomalyco/opencode run "prompt"
```

Project-local config (`.opencode/` and `opencode.json`) is automatically loaded from workspace.

---

## Architecture

Based on OpenCode's actual capabilities:

```
config/
├── global.yml                    # Global settings (merged into prompts)
└── systems/
    ├── _template.yml             # Template for new systems
    ├── order-management.yml      # Java/GCP system
    └── customer-portal.yml       # .NET/Azure system

.opencode/                        # OpenCode native config (in this repo)
├── opencode.json                 # MCP servers, permissions
├── skills/
│   ├── analyze-workitem/
│   │   └── SKILL.md              # Work item analysis skill
│   ├── implement-solution/
│   │   └── SKILL.md              # Implementation skill
│   └── code-review/
│       └── SKILL.md              # Code review skill
└── agents/
    ├── analyzer.md               # Analysis subagent
    └── implementer.md            # Implementation subagent
```

### Key Insight

| Type | Purpose | Location | Example |
|------|---------|----------|---------|
| **Skills** | Capability (what can the agent do) | `.opencode/skills/` | analyze-workitem, code-review |
| **Agents** | Specialized assistants | `.opencode/agents/` | analyzer (read-only), implementer |
| **System Config** | Context (what stack/architecture) | `config/systems/` | Java/GCP, .NET/Azure |

System-specific context (Java vs .NET, Azure vs GCP) is:
1. Resolved by our scripts (detect system from work item)
2. Injected into the prompt passed to `opencode run`
3. NOT stored as separate OpenCode skills/agents per system

---

## TODO List

### Phase 1: OpenCode Native Config

- [ ] **1.1** Create `.opencode/opencode.json` with MCP servers
- [ ] **1.2** Create `.opencode/skills/analyze-workitem/SKILL.md`
- [ ] **1.3** Create `.opencode/skills/implement-solution/SKILL.md`
- [ ] **1.4** Create `.opencode/agents/analyzer.md` (read-only subagent)
- [ ] **1.5** Create `.opencode/agents/implementer.md` (full-access subagent)

### Phase 2: System Configuration (YAML)

- [ ] **2.1** Create `config/global.yml` with base settings
- [ ] **2.2** Create `config/systems/_template.yml`
- [ ] **2.3** Create `config/systems/order-management.yml` (Java/GCP)
- [ ] **2.4** Create `config/systems/customer-portal.yml` (.NET/Azure)

### Phase 3: Detection & Merging Scripts

- [ ] **3.1** Update `scripts/get-workitem-context.sh` (add area_path)
- [ ] **3.2** Create `scripts/resolve-system-config.sh`
- [ ] **3.3** Create `scripts/build-opencode-prompt.sh` (merge system context into prompt)

### Phase 4: Pipeline Integration

- [ ] **4.1** Update `pipelines/templates/analyze.yml`
- [ ] **4.2** Update `pipelines/templates/implement.yml`
- [ ] **4.3** Install `yq` in pipeline for YAML processing

---

## File Specifications

### `.opencode/opencode.json`
```json
{
  "$schema": "https://opencode.ai/config.json",
  "model": "anthropic/claude-sonnet-4-20250514",
  "mcp": {
    "azure-devops": {
      "type": "local",
      "command": ["npx", "-y", "@anthropic/mcp-azure-devops"],
      "enabled": true,
      "environment": {
        "AZURE_DEVOPS_ORG": "{env:AZURE_DEVOPS_ORG}",
        "AZURE_DEVOPS_PROJECT": "{env:AZURE_DEVOPS_PROJECT}",
        "AZURE_DEVOPS_PAT": "{env:AZURE_DEVOPS_PAT}"
      }
    }
  },
  "permission": {
    "bash": "allow",
    "edit": "allow",
    "write": "allow"
  }
}
```

### `.opencode/skills/analyze-workitem/SKILL.md`
```yaml
---
name: analyze-workitem
description: Analyze Azure DevOps work items and propose solutions. Use when analyzing bugs or user stories.
license: MIT
compatibility: Requires Azure DevOps MCP server
---

## What I Do
- Analyze work item title, description, and acceptance criteria
- Identify affected files in the codebase
- Propose a minimal, focused solution
- Estimate complexity (Low/Medium/High)
- Suggest test strategy

## Output Format
Use the analysis template with sections for:
- Problem summary
- Root cause (for bugs)
- Proposed solution
- Affected files
- Test strategy
- Complexity estimate
```

### `.opencode/agents/analyzer.md`
```yaml
---
description: Analyzes work items and proposes solutions (read-only)
mode: subagent
model: anthropic/claude-sonnet-4-20250514
temperature: 0.2
tools:
  write: false
  edit: false
  bash: false
---
You are an AI agent specialized in analyzing work items.

Your task is to:
1. Understand the problem/requirement
2. Explore the codebase to identify affected areas
3. Propose a solution with specific changes
4. Estimate complexity and suggest tests

You have READ-ONLY access. Do not attempt to modify files.
```

### `config/systems/order-management.yml` (Example: Java/GCP)
```yaml
name: order-management
description: Backend order processing system

detection:
  area_path:
    - "MyProject\\OrderManagement\\*"
  tags:
    - "order-management"

tech_stack:
  language: Java
  version: "21"
  framework: Spring Boot 3.x
  cloud: Google Cloud
  services:
    - Cloud Run
    - Cloud SQL
    - Pub/Sub

architecture:
  patterns:
    - Clean Architecture
    - Domain-Driven Design
  layers:
    - domain (business logic)
    - application (use cases)
    - infrastructure (adapters)
    - presentation (API)

quality_gates:
  build: "./gradlew build -x test"
  test: "./gradlew test"
  lint: "./gradlew spotlessCheck"
  coverage_min: 85

context: |
  You are working on the Order Management system.

  Architecture: Clean Architecture with DDD patterns.
  - All business logic in domain layer
  - Use cases in application layer
  - Spring Boot conventions (constructor injection)

  Google Cloud: Cloud Run, Cloud SQL, Pub/Sub

  Testing: JUnit 5, Testcontainers, JaCoCo (85% min)
```

### `config/systems/customer-portal.yml` (Example: .NET/Azure)
```yaml
name: customer-portal
description: Customer-facing web portal

detection:
  area_path:
    - "MyProject\\CustomerPortal\\*"
  tags:
    - "customer-portal"

tech_stack:
  language: C#
  version: "12"
  framework: .NET 8
  cloud: Azure
  services:
    - Azure App Service
    - Azure SQL
    - Azure Service Bus
    - Azure Key Vault

architecture:
  patterns:
    - Clean Architecture
    - CQRS
    - Mediator Pattern
  layers:
    - Domain
    - Application
    - Infrastructure
    - WebApi

quality_gates:
  build: "dotnet build --configuration Release --warnaserror"
  test: "dotnet test --collect:'XPlat Code Coverage'"
  lint: "dotnet format --verify-no-changes"
  coverage_min: 80

context: |
  You are working on the Customer Portal system.

  Architecture: Clean Architecture with CQRS.
  - Use MediatR for command/query separation
  - FluentValidation for input validation
  - Record types for DTOs and Value Objects

  Azure: App Service, Azure SQL, Service Bus, Key Vault

  .NET Conventions:
  - Async all the way (no .Result or .Wait())
  - Constructor injection
  - IOptions<T> for configuration
```

---

## Prompt Building Flow

```
1. Work Item Created → Pipeline Triggered
                ↓
2. get-workitem-context.sh → workitem-context.json
   (includes area_path, tags, custom fields)
                ↓
3. resolve-system-config.sh → system-name.txt
   (detects: order-management)
                ↓
4. build-opencode-prompt.sh → prompt.txt
   (merges: global + system context + work item + instructions)
                ↓
5. docker run opencode run "$(cat prompt.txt)"
   (uses .opencode/ skills and agents)
```

---

## Sources

- [OpenCode Skills](https://opencode.ai/docs/skills)
- [OpenCode Agents](https://opencode.ai/docs/agents/)
- [OpenCode Config](https://opencode.ai/docs/config/)
- [OpenCode MCP Servers](https://opencode.ai/docs/mcp-servers/)
- [OpenCode Docker Guide](https://agileweboperations.com/2025/11/23/how-to-run-opencode-ai-in-a-docker-container/)
- [Agent Skills Specification](https://agentskills.io/specification)
