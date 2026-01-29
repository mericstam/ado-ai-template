# Claude Code Instructions

## Global Rules

- **Always use English** in all communication, documentation, code comments, and commit messages

## Pipeline Development Workflow

When working with Azure DevOps pipelines in this repo:

1. Make changes to pipeline files
2. **Commit and push changes** - WAIT for push to complete before next step!
3. Verify push completed: `git log --oneline origin/main -1`
4. **Trigger test:** `pwsh scripts/toggle-ai-ready.ps1 -WorkItemId 123456`
5. Ask user to manually verify pipeline behavior

**Test Work Item:** 123456
**Test Script:** `scripts/toggle-ai-ready.ps1` - Always use this script to trigger test runs

**IMPORTANT:** Never trigger pipeline before push is confirmed complete!

## Azure DevOps Variable References

Cross-stage variable references use DIFFERENT syntax depending on context:

### Stage Conditions (compile-time)
Use `dependencies` with format: `dependencies.StageName.outputs['JobName.StepName.VariableName']`
```yaml
condition: eq(dependencies.Process.outputs['DetermineAction.webhook.ACTION'], 'analyze')
```

### Stage Variables (runtime)
Use `stageDependencies` with format: `stageDependencies.StageName.JobName.outputs['StepName.VariableName']`
```yaml
variables:
  MY_VAR: $[ stageDependencies.Process.DetermineAction.outputs['webhook.WORK_ITEM_ID'] ]
```

**Key difference:**
- `dependencies` = compile-time, used in conditions
- `stageDependencies` = runtime, used in variable expressions with `$[ ]`

## OpenCode CLI Usage

### Non-interactive mode (CI/CD)
Use `opencode run "prompt"` for non-interactive execution:
```bash
docker run --rm \
  -e ANTHROPIC_API_KEY \
  -v "$(pwd):/workspace" \
  -w /workspace \
  ghcr.io/anomalyco/opencode run "Your prompt here"
```

**WRONG:** `opencode --print "prompt"` (--print flag does not exist)
**CORRECT:** `opencode run "prompt"`

### Environment Variables
- `ANTHROPIC_API_KEY` - Required for AI model access
- `GH_HOST` / `GH_TOKEN` - For GitHub Enterprise access

## Azure DevOps Authentication

### System.AccessToken vs PAT
- `System.AccessToken` is a JWT/OAuth token - use **Bearer** auth
- Personal Access Tokens (PAT) - use **Basic** auth

Detection pattern in bash:
```bash
if [[ "$AZURE_DEVOPS_PAT" == ey* ]]; then
    # JWT token - use Bearer
    AUTH_HEADER="Authorization: Bearer $AZURE_DEVOPS_PAT"
else
    # PAT - use Basic
    AUTH=$(echo -n ":$AZURE_DEVOPS_PAT" | base64)
    AUTH_HEADER="Authorization: Basic $AUTH"
fi
```

### Pipeline Variables
- Use `$(System.AccessToken)` instead of custom PAT variables when possible
- Use `$(System.TeamProject)` for project name
- Hardcode org name if `$(AZURE_DEVOPS_ORG)` is not defined

## YAML Multiline Strings in Pipelines

When using multiline strings inside `script: |` blocks, **all lines must maintain consistent indentation** relative to the YAML structure:

**WRONG** - Lines inside string start at column 1:
```yaml
- script: |
    MESSAGE="## Header

This line has no indentation - YAML parser fails!"
```

**CORRECT** - All lines indented consistently:
```yaml
- script: |
    MESSAGE="## Header

    This line is properly indented within the YAML block."
```

The YAML parser will fail with "could not find expected ':'" if a line inside the block looks like a YAML key (contains `:` followed by space).

## Azure DevOps Work Item Comments

### HTML, Not Markdown
Work item comments use **HTML formatting**, not Markdown. The `scripts/update-workitem.sh` script automatically converts Markdown to HTML.

| Markdown | HTML |
|----------|------|
| `## Header` | `<h2>Header</h2>` |
| `**bold**` | `<b>bold</b>` |
| `*italic*` | `<i>italic</i>` |
| `[text](url)` | `<a href="url">text</a>` |
| `- item` | `<ul><li>item</li></ul>` |
| Bare URL | `<a href="url">url</a>` |

### Adding Comments via API
```bash
curl -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"text": "<h2>Header</h2><b>Bold</b> text"}' \
  "$BASE_URL/wit/workitems/$ID/comments?api-version=7.0-preview.3"
```
