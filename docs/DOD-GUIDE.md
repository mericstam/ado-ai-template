# Definition of Done Guide

This guide explains how to create and customize Definition of Done (DoD) configurations for the AI Agent.

## Overview

Definition of Done configs tell the AI Agent:
- What quality gates must pass before creating a PR
- What coding standards and patterns to follow
- How to format analysis and implementation reports

## File Location

DoD configs are stored in `config/dod/` with the naming convention:

```
config/dod/{component-name}.yml
```

The `default.yml` is used when no specific config is specified.

## Configuration Structure

```yaml
# Component identifier
component: "my-component"

# Quality gates that must pass
quality_gates:
  build:
    command: "npm run build"
    required: true
    description: "Build must complete without errors"

  test:
    command: "npm test"
    required: true
    min_coverage: 80
    description: "All tests must pass"

  lint:
    command: "npm run lint"
    required: true
    description: "Code must pass linting"

# Context for the AI agent
context:
  system_prompt: |
    Guidelines for the AI when working on this component.

# Templates for output formatting
templates:
  analysis: |
    Template for analysis output.
  implementation_complete: |
    Template for completion message.
  error: |
    Template for error messages.
```

## Quality Gates

### Available Options

| Field | Type | Description |
|-------|------|-------------|
| `command` | string | Shell command to execute |
| `required` | boolean | If true, failure stops the pipeline |
| `min_coverage` | number | Minimum code coverage percentage (for test gates) |
| `description` | string | Human-readable description |

### Common Quality Gates

#### Node.js / TypeScript
```yaml
quality_gates:
  build:
    command: "npm run build"
    required: true
  test:
    command: "npm test -- --coverage"
    required: true
    min_coverage: 80
  lint:
    command: "npm run lint"
    required: true
  typecheck:
    command: "npx tsc --noEmit"
    required: true
```

#### .NET
```yaml
quality_gates:
  build:
    command: "dotnet build -warnaserror"
    required: true
  test:
    command: "dotnet test --collect:\"XPlat Code Coverage\""
    required: true
    min_coverage: 80
  lint:
    command: "dotnet format --verify-no-changes"
    required: true
```

#### Python
```yaml
quality_gates:
  test:
    command: "pytest --cov=src --cov-fail-under=80"
    required: true
    min_coverage: 80
  lint:
    command: "ruff check ."
    required: true
  typecheck:
    command: "mypy src"
    required: true
```

## Context / System Prompt

The `context.system_prompt` provides instructions to the AI agent about how to work with this component.

### Best Practices

1. **Be specific about patterns**
   ```yaml
   context:
     system_prompt: |
       This is a React application using:
       - TypeScript with strict mode
       - React Query for data fetching
       - Zustand for state management
       - Tailwind CSS for styling

       Follow these patterns:
       - Use functional components with hooks
       - Place API calls in src/api/
       - Place shared components in src/components/shared/
   ```

2. **Include file structure guidance**
   ```yaml
   context:
     system_prompt: |
       Project structure:
       - src/features/{feature}/ - Feature modules
       - src/shared/ - Shared utilities
       - src/types/ - TypeScript types

       When adding a new feature:
       1. Create folder in src/features/
       2. Add index.ts for exports
       3. Add tests in __tests__/
   ```

3. **Specify testing requirements**
   ```yaml
   context:
     system_prompt: |
       Testing requirements:
       - Unit tests for all business logic
       - Integration tests for API endpoints
       - Use Jest and React Testing Library
       - Mock external dependencies
   ```

## Templates

Templates use placeholder syntax: `{placeholder_name}`

### Analysis Template

```yaml
templates:
  analysis: |
    ## AI Analysis

    **Problem:** {summary}

    **Root Cause:** {technical_cause}

    **Proposed Solution:** {solution}

    **Affected Files:**
    {files}

    **Test Strategy:** {test_strategy}

    **Estimated Complexity:** {complexity}

    ---
    Add tag `ai-approved` to start implementation.
```

### Implementation Complete Template

```yaml
templates:
  implementation_complete: |
    ## Implementation Complete

    **Changes Made:**
    {changes}

    **Tests Added:**
    {tests}

    **Pull Request:** {pr_link}

    Please review the PR and merge when ready.
```

### Error Template

```yaml
templates:
  error: |
    ## AI Agent Error

    **Stage:** {stage}
    **Error:** {error_message}

    ```
    {error_details}
    ```

    Please review and retry or handle manually.
```

## Examples

### Backend API Component

```yaml
component: "backend-api"

quality_gates:
  build:
    command: "dotnet build -c Release -warnaserror"
    required: true
  test:
    command: "dotnet test --logger trx"
    required: true
    min_coverage: 85
  lint:
    command: "dotnet format --verify-no-changes"
    required: true

context:
  system_prompt: |
    You are working on a .NET 8 Web API.

    Architecture:
    - Clean Architecture with layers: API, Application, Domain, Infrastructure
    - CQRS pattern with MediatR
    - Entity Framework Core for data access

    Guidelines:
    - All endpoints need authorization attributes
    - Use FluentValidation for request validation
    - Return ProblemDetails for errors
    - Add XML documentation to public APIs

templates:
  analysis: |
    ## Backend API Analysis

    **Issue:** {summary}
    **Affected Layer:** {layer}
    **Root Cause:** {technical_cause}

    **Solution:**
    {solution}

    **Files to Modify:**
    {files}

    **Database Changes:** {db_changes}
    **API Changes:** {api_changes}

    ---
    Reply with `ai-approved` to proceed.
```

### React Frontend Component

```yaml
component: "frontend-web"

quality_gates:
  build:
    command: "npm run build"
    required: true
  test:
    command: "npm test -- --coverage --watchAll=false"
    required: true
    min_coverage: 75
  lint:
    command: "npm run lint"
    required: true
  typecheck:
    command: "npx tsc --noEmit"
    required: true

context:
  system_prompt: |
    You are working on a React 18 application with TypeScript.

    Stack:
    - React 18 with hooks
    - TypeScript strict mode
    - React Router v6
    - TanStack Query for server state
    - Tailwind CSS

    Guidelines:
    - Prefer functional components
    - Use custom hooks for reusable logic
    - Keep components small and focused
    - Write tests with React Testing Library
    - Use semantic HTML elements

templates:
  analysis: |
    ## Frontend Analysis

    **Issue:** {summary}
    **Component(s) Affected:** {components}

    **Solution:**
    {solution}

    **UI/UX Impact:** {ui_impact}
    **Accessibility Considerations:** {a11y}

    ---
    Add `ai-approved` to implement.
```

## Using Custom Configs

When triggering the pipeline, specify the config name:

```yaml
parameters:
  - name: dodConfig
    value: 'backend-api'  # Uses config/dod/backend-api.yml
```

Or via the pipeline UI when running manually.

## Tips

1. **Start simple** - Begin with the default config and customize as needed
2. **Iterate** - Adjust based on AI output quality
3. **Be explicit** - The more context you provide, the better the results
4. **Test locally** - Run quality gate commands locally before adding to config
5. **Version control** - DoD configs are in git, so changes are tracked
