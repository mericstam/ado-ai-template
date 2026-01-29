# Azure DevOps AI Agent Automation

## Problem Statement

**What:** Developers in enterprise organizations spend too much time on routine tasks like simple bug fixes and small features, limiting capacity for more complex and value-creating work.

**Who:**
- Developers who need to handle a large number of work items
- Teams that want to scale development capacity without increasing headcount
- Organizations that require full traceability from requirements to code

**Why now:**
- Need to scale development capacity
- AI coding agents have reached sufficient maturity for production use
- Enterprise policies now allow controlled AI usage through approved channels

## Current Situation

Today, work items are handled manually:
1. Developer picks work item from backlog
2. Reads description and acceptance criteria
3. Implements manually
4. Creates PR and waits for review
5. Updates work item status manually

**Problems with current process:**
- Time-consuming for routine tasks
- Inconsistent documentation
- Manual status updates are often forgotten
- Difficult to scale without more developers

## Proposed Solution

An **AI agent triggered by Azure DevOps work items** that automatically:
1. Analyzes work item and proposes solution
2. Waits for approval
3. Implements the solution
4. Creates Pull Request
5. Updates work item with status and link to PR

### Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Azure DevOps   │────▶│  Azure Pipeline  │────▶│  GitHub Enterprise│
│  Work Item      │     │  + OpenCode Agent│     │  (PR)           │
│  (tag trigger)  │◀────│                  │◀────│                 │
└─────────────────┘     └──────────────────┘     └─────────────────┘
        │                        │
        │                        ▼
        │               ┌──────────────────┐
        │               │  Teams Webhook   │
        │               │  (on error)      │
        └───────────────└──────────────────┘
```

## Goals & Success Criteria

### MVP (Minimum Viable Product)
- [ ] A pipeline triggered by specific tag on work item
- [ ] Agent analyzes and creates proposal in work item
- [ ] After approval: implementation + PR
- [ ] Status updated in work item field
- [ ] Error handling with escalation to Teams

### Full Vision
- [ ] Phased rollout to all teams
- [ ] Support for multiple work item types
- [ ] Centralized Definition of Done per component
- [ ] Automatic triage of which work items are suitable for automation

### Success Metrics
| Metric | Goal |
|--------|------|
| Time from work item to PR | < 30 min for simple tasks |
| Percentage of PRs passing review first time | > 80% |
| Developer time saved per week | > 5h per developer |
| Work items handled automatically | > 20% of simple tasks |

## User Stories

### Story 1: Automatic analysis of work item
**As a** developer
**I want** the agent to automatically analyze my work item when I set a specific tag
**So that** I quickly get a qualified assessment and solution proposal

**Acceptance Criteria:**
- Given a work item with the tag "ai-ready"
- When the tag is set
- Then pipeline starts and the agent analyzes
- And work item is updated with analysis within 5 minutes
- And analysis contains: Problem, Cause, Proposed solution, Affected files

**Priority:** Must Have

---

### Story 2: Implementation after approval
**As a** developer
**I want** the agent to implement the solution after I approve the analysis
**So that** I don't have to do the routine work myself

**Acceptance Criteria:**
- Given an approved analysis (tag "ai-approved" or comment)
- When approval is registered
- Then the agent creates a feature branch
- And implements the solution according to Definition of Done
- And creates Pull Request linked to work item
- And updates work item status to "In Review"

**Priority:** Must Have

---

### Story 3: Live status in work item
**As a** project manager
**I want** to see the agent's progress directly in the work item
**So that** I have full traceability and can follow the work

**Acceptance Criteria:**
- Given that the agent is working on a work item
- When each phase is complete (analysis, implementation, PR)
- Then work item field is updated with current status
- And any errors are reported clearly

**Priority:** Must Have

---

### Story 4: Escalation on error
**As a** developer
**I want** to be notified in Teams if the agent encounters problems
**So that** I can quickly take over or help

**Acceptance Criteria:**
- Given that the agent fails with a task
- When the error occurs
- Then notification is sent to Teams channel via webhook
- And work item is updated with error status and description
- And the agent aborts without damaging the repo

**Priority:** Must Have

---

### Story 5: Centralized configuration
**As a** tech lead
**I want** to be able to define Definition of Done per component centrally
**So that** the agent follows our standards and I can update quickly when needed

**Acceptance Criteria:**
- Given a central configuration file per component/repo
- When the agent starts work
- Then it reads in current Definition of Done
- And follows all quality requirements (build, test, lint, etc.)

**Priority:** Should Have

## Use Cases

### Use Case 1: Simple Bug Fix

**Primary Actor:** Developer

**Preconditions:**
- Work item exists with clear bug description
- Repo is connected to Azure DevOps
- Agent has access via PAT

**Main Success Scenario:**
1. Developer sets tag "ai-ready" on work item
2. Azure DevOps triggers pipeline
3. Pipeline starts OpenCode agent with work item context
4. Agent analyzes bug and identifies affected code
5. Agent writes analysis to work item field
6. Developer reviews and sets "ai-approved"
7. Agent creates feature branch
8. Agent implements fix + regression tests
9. Agent runs Definition of Done checks
10. Agent creates PR with link to work item
11. Agent updates work item status to "In Review"

**Alternative Flows:**
- 4a. Agent cannot identify the problem → Reports in work item, exits
- 9a. Definition of Done fails → Attempts to correct, max 3 attempts
- 9b. Continued failure → Escalates to Teams, exits

**Postconditions:**
- PR exists linked to work item
- Work item has updated status
- All DoD checks have passed

---

### Use Case 2: Small Feature

**Primary Actor:** Developer

**Preconditions:**
- User story with clear acceptance criteria
- Definition of Done defined for the component

**Main Success Scenario:**
1. Developer sets tag "ai-ready" on user story
2. Agent analyzes requirements and identifies implementation plan
3. Agent presents proposal with affected files and test plan
4. Developer approves or adjusts the proposal
5. Agent implements feature according to plan
6. Agent writes tests according to test plan
7. Agent runs all DoD checks
8. Agent creates PR with description
9. Work item is updated with PR link

**Alternative Flows:**
- 3a. Agent assesses the task as too complex → Flags in work item, exits
- 5a. Implementation deviates from plan → Reports difference, continues if minor

**Postconditions:**
- Feature implemented with tests
- PR ready for review
- Full traceability in work item

## Technical Requirements

### Stack

| Component | Technology | Rationale |
|-----------|------------|-----------|
| Orchestration | Azure DevOps Pipelines | Integration with work items, enterprise-approved |
| AI Agent | OpenCode | Claude Code-like capability for coding |
| Version Control | GitHub Enterprise | Existing infrastructure |
| Authentication | Personal Access Token (PAT) | Simple setup, sufficient for MVP |
| Notifications | Teams Webhook (Workflows) | Enterprise standard for communication |
| Configuration | YAML files in repo | Version controlled, auditable |

### Pipeline Architecture

```yaml
# Conceptual pipeline structure
trigger: none  # Triggered by work item webhook/service hook

stages:
  - stage: Analyze
    jobs:
      - job: AnalyzeWorkItem
        steps:
          - checkout: self
          - task: LoadDefinitionOfDone
          - task: RunOpenCodeAgent
            inputs:
              mode: analyze
              workItemId: $(workItemId)
          - task: UpdateWorkItem
            inputs:
              status: "Awaiting Approval"

  - stage: Implement
    condition: eq(variables['approved'], 'true')
    jobs:
      - job: ImplementSolution
        steps:
          - task: RunOpenCodeAgent
            inputs:
              mode: implement
          - task: RunDefinitionOfDone
          - task: CreatePullRequest
          - task: UpdateWorkItem
            inputs:
              status: "In Review"
```

### Definition of Done - Structure

```yaml
# config/dod/{component}.yaml
component: "backend-api"
quality_gates:
  build:
    command: "dotnet build -warnaserror"
    required: true
  test:
    command: "dotnet test"
    required: true
    min_coverage: 80
  lint:
    command: "dotnet format --verify-no-changes"
    required: true

context:
  system_prompt: |
    You are working with a .NET backend API.
    - Follow Clean Architecture principles
    - All public methods should have XML documentation
    - Use repository pattern for data access

templates:
  analysis: |
    **Problem:** {summary}
    **Cause:** {technical_cause}
    **Proposed solution:** {solution}
    **Affected files:** {files}
    **Test strategy:** {test_strategy}

    Reply "ai-approved" for me to implement.
```

### Security

- **Authentication:** PAT stored as pipeline secret variable
- **Access Control:** Agent only gets access to specific repos
- **Audit:** All actions logged in pipeline and work item
- **Limitations:** Agent cannot merge PR, only create

### Infrastructure

- **Runners:** Support for both Azure-hosted and self-hosted agents
- **Scaling:** Pipeline runs on-demand, no always-on cost
- **Network Access:** Agent needs to reach GitHub Enterprise and Azure DevOps API

## User Experience

### Work Item Flow

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   New       │───▶│  AI Ready   │───▶│  AI Working │───▶│  In Review  │
│             │    │  (tag set)  │    │  (analysis) │    │  (PR exists)│
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                          │                   │
                          ▼                   ▼
                   ┌─────────────┐    ┌─────────────┐
                   │  AI Failed  │    │  AI Approved│
                   │  (escalated)│    │  (impl.)    │
                   └─────────────┘    └─────────────┘
```

### Status Fields in Work Item

| Field | Purpose |
|-------|---------|
| AI Status | Current phase (Analyzing, Awaiting Approval, Implementing, etc.) |
| AI Analysis | Agent's analysis and proposal |
| AI PR Link | Link to created PR |
| AI Error | Any error message |

## Testing Strategy

### Approach

Centralized technical frameworks and ways of working are defined per component via Definition of Done configuration. This enables:
- Quick update of quality requirements centrally
- Consistent standard across teams
- Easy onboarding of new repos

### Quality Gates

Defined per component in `config/dod/{component}.yaml`:
- Build without errors/warnings
- All tests pass
- Code coverage according to requirements
- Linting/formatting
- Specific domain rules (e.g., medical device requirements)

### System Test

- **Sandbox Environment:** Test pipeline against test repo before production
- **Mock work items:** Verify analysis quality
- **Rollback test:** Ensure failed implementations can be restored

## Risks & Mitigation

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Agent makes wrong changes in code | High | Medium | Two-phase approach, PR review required, DoD checks |
| User acceptance - team doesn't trust agent | Medium | Medium | Phased rollout, transparency, opt-in per work item |
| PAT is compromised | High | Low | Rotate regularly, minimal scope, audit logging |
| Agent gets stuck in loop | Medium | Medium | Timeout, max attempts, automatic escalation |
| Definition of Done is too strict/loose | Medium | Medium | Iterate based on feedback, per-component config |

## Trade-offs

| Decision | Chosen Alternative | Alternative | Rationale |
|----------|-------------------|-------------|-----------|
| Authentication | PAT | GitHub App | Simpler setup for MVP, can be upgraded later |
| Trigger | Tag on work item | Automatic on status | Explicit opt-in gives better control initially |
| Approval | Two-phase with manual approval | Direct implementation | Builds trust, reduces risk of errors |
| Error handling | Escalate to Teams | Retry automatically | Human oversight more important than automation on errors |

## Out of Scope

- **PR merge:** Agent creates PR but never merges
- **Production deploy:** Code only, no deploy
- **Complex architecture changes:** Only bounded tasks
- **Automatic triage:** MVP requires manual tag, no AI assessment of what fits
- **Multi-repo changes:** One PR per work item, one repo

## Documentation

| Document | Audience | Content |
|----------|----------|---------|
| README.md | Everyone | Overview and quick start |
| SETUP.md | DevOps/Platform | Installation and configuration |
| DOD-GUIDE.md | Tech leads | How to create Definition of Done |
| TROUBLESHOOTING.md | Developers | Common problems and solutions |

## Success Metrics

| Metric | Measurement Method | Goal (3 months) |
|--------|-------------------|-----------------|
| Number of work items handled | Pipeline telemetry | 50+ per month |
| PR approval rate first review | GitHub metrics | > 80% |
| Average time to PR | Pipeline duration | < 30 min |
| Developer satisfaction | Survey | > 4/5 |
| Escalation frequency | Teams webhook count | < 20% |

## Next Steps

1. **Set up basic pipeline**
   - Azure DevOps service hook for work item events
   - Pipeline template with OpenCode agent
   - Basic work item update

2. **Create Definition of Done structure**
   - YAML schema for DoD configuration
   - First component as pilot

3. **Implement two-phase flow**
   - Analysis phase with work item update
   - Approval trigger
   - Implementation phase with PR

4. **Pilot with one team**
   - Select team and repo for pilot test
   - Iterate based on feedback

5. **Teams integration**
   - Webhook for escalation
   - Notifications on success

---

*Generated with PRD Interview Skill*
