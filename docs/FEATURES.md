# Feature List

Overview of all features - implemented and planned.

## Legend

- [x] Implemented
- [ ] Planned

---

## Core Pipeline

### Trigger & Detection

- [x] Webhook trigger from Azure DevOps service hooks
- [x] Tag-based action detection (`ai-ready`, `ai-approved`)
- [x] Skip logic when `ai-working` tag present (prevent re-trigger)
- [ ] Custom field-based system detection
- [ ] Area path-based system detection

### Analysis Stage

- [x] Fetch work item context (title, description, acceptance criteria)
- [x] Run OpenCode in analyze mode
- [x] Post analysis as work item comment
- [x] Add/remove tags on work item
- [ ] System-specific analysis prompts
- [ ] Include related work items in context

### Implementation Stage

- [x] Create feature branch (`ai/{workItemId}`)
- [x] Run OpenCode in implement mode
- [x] Run Definition of Done quality gates
- [x] Commit and push changes
- [x] Create Pull Request via GitHub CLI
- [x] Update work item with PR link
- [ ] System-specific implementation prompts
- [ ] System-specific quality gate commands

---

## User Experience

### Notifications

- [x] Immediate "AI Agent Started" comment when pipeline triggers
- [x] Status comment with pipeline link
- [x] Completion comment with PR link
- [x] Error comment with pipeline logs link
- [ ] Teams notification on error
- [ ] Teams notification on success

### Comment Formatting

- [x] Markdown to HTML conversion for ADO comments
- [x] Headers (`## Header` → `<h2>`)
- [x] Bold text (`**text**` → `<b>`)
- [x] Links (`[text](url)` → `<a href>`)
- [x] Lists (`- item` → `<ul><li>`)
- [x] Bare URL auto-linking

### Tags

- [x] `ai-ready` - Triggers analysis
- [x] `ai-working` - Processing in progress
- [x] `ai-approved` - Triggers implementation
- [x] `ai-failed` - Error occurred

### Comment Commands

- [x] `@ai` mention detection in comments
- [x] Custom command execution via comments
- [x] Response posted as work item comment

---

## Configuration

### Definition of Done

- [x] YAML-based DoD configuration
- [x] Configurable quality gates (build, test, lint)
- [x] Fallback to default config
- [ ] Per-system DoD configurations
- [ ] Min coverage threshold enforcement

### System Configuration (Planned)

- [ ] Global configuration (`config/global.yml`)
- [ ] System-specific configs (`config/systems/*.yml`)
- [ ] Tech stack definitions (Java, .NET, etc.)
- [ ] Cloud provider context (Azure, GCP, AWS)
- [ ] Repository mappings
- [ ] Config inheritance and merging

### Skills Framework (Planned)

- [ ] Reusable prompt templates
- [ ] Skill definitions (`config/skills/*.yml`)
- [ ] Per-system skill selection

### Subagents (Planned)

- [ ] Agent configurations (`config/agents/*.yml`)
- [ ] Model selection per agent
- [ ] Token limit configuration

### OpenCode Agents (Planned)

- [ ] Use `opencode agent` to create specialized agents
- [ ] Vision-agent: For image/attachment analysis (gpt-4.1)
- [ ] Code-agent: For implementation (gpt-5.1-codex-max)
- [ ] Analyze-agent: For work item analysis
- [ ] Agent-per-task routing in pipeline

---

## Security & Compliance

- [x] GitHub Enterprise Copilot for AI (no external AI services)
- [x] `COPILOT_GITHUB_TOKEN` authentication
- [x] `$(System.AccessToken)` for Azure DevOps API
- [x] Agent can only create PRs, never merge
- [x] Full audit trail in pipeline logs
- [ ] Token rotation reminders
- [ ] Sensitive data detection in prompts

---

## Observability

### Pipeline Logging

- [x] Log OpenCode input (prompt + config)
- [x] Log resolved DoD configuration
- [ ] Log resolved system configuration
- [ ] Log AI response time
- [ ] Log token usage

### Work Item Tracking

- [x] Pipeline link in comments
- [x] Build ID reference
- [ ] AI cost/token tracking field
- [ ] Processing time field

---

## Documentation

- [x] README.md - Overview and quick start
- [x] SETUP.md - Installation guide
- [x] DOD-GUIDE.md - Definition of Done guide
- [x] USAGE.md - User guide for AI agent
- [x] TIMELINE.md - Project development history
- [x] CLAUDE.md - AI coding instructions
- [x] PRD.md - Product requirements
- [x] SYSTEM-CONFIG-PLAN.md - System config roadmap
- [ ] SYSTEM-CONFIG-GUIDE.md - How to add systems
- [ ] TROUBLESHOOTING.md - Common issues

---

## Summary

| Category | Implemented | Planned | Total |
|----------|-------------|---------|-------|
| Core Pipeline | 12 | 4 | 16 |
| User Experience | 13 | 2 | 15 |
| Configuration | 3 | 10 | 13 |
| Security | 5 | 2 | 7 |
| Observability | 3 | 4 | 7 |
| Documentation | 8 | 2 | 10 |
| **Total** | **44** | **24** | **68** |

**Progress: 65% complete**
