#!/bin/bash
# build-prompt.sh
# Builds a complete prompt by combining:
# - Default context + system context
# - Default prompt + system prompt additions
# - Work item context
# - Command text (for command mode)

set -e

# Default values
MODE=""
SYSTEM=""
CONTEXT_FILE=""
COMMAND_TEXT=""
SYSTEMS_DIR=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --mode)
            MODE="$2"
            shift 2
            ;;
        --system)
            SYSTEM="$2"
            shift 2
            ;;
        --context)
            CONTEXT_FILE="$2"
            shift 2
            ;;
        --command)
            COMMAND_TEXT="$2"
            shift 2
            ;;
        --systems-dir)
            SYSTEMS_DIR="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
done

# Validate required arguments
if [ -z "$MODE" ]; then
    echo "Error: --mode is required (analyze|implement|command)" >&2
    exit 1
fi

if [ -z "$SYSTEM" ]; then
    echo "Error: --system is required" >&2
    exit 1
fi

if [ -z "$CONTEXT_FILE" ]; then
    echo "Error: --context is required" >&2
    exit 1
fi

# Validate mode
case $MODE in
    analyze|implement|command)
        ;;
    *)
        echo "Error: Invalid mode '$MODE'. Must be analyze, implement, or command" >&2
        exit 1
        ;;
esac

# Command mode requires --command
if [ "$MODE" = "command" ] && [ -z "$COMMAND_TEXT" ]; then
    echo "Error: --command is required for command mode" >&2
    exit 1
fi

# Determine paths
if [ -z "$SYSTEMS_DIR" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    SYSTEMS_DIR="$SCRIPT_DIR/../systems"
fi

DEFAULT_DIR="$SYSTEMS_DIR/_default"
SYSTEM_DIR="$SYSTEMS_DIR/$SYSTEM"

# Validate default directory exists
if [ ! -d "$DEFAULT_DIR" ]; then
    echo "Error: Default system directory not found: $DEFAULT_DIR" >&2
    exit 1
fi

# Validate context file exists
if [ ! -f "$CONTEXT_FILE" ]; then
    echo "Error: Context file not found: $CONTEXT_FILE" >&2
    exit 1
fi

# =============================================================================
# 1. Build combined SYSTEM_CONTEXT (default + system)
# =============================================================================

SYSTEM_CONTEXT=""

# Always include default context
if [ -f "$DEFAULT_DIR/context.md" ]; then
    SYSTEM_CONTEXT=$(cat "$DEFAULT_DIR/context.md")
fi

# Add system-specific context if exists and not _default
if [ "$SYSTEM" != "_default" ] && [ -f "$SYSTEM_DIR/context.md" ]; then
    if [ -n "$SYSTEM_CONTEXT" ]; then
        SYSTEM_CONTEXT="$SYSTEM_CONTEXT

---

"
    fi
    SYSTEM_CONTEXT="$SYSTEM_CONTEXT$(cat "$SYSTEM_DIR/context.md")"
fi

# Fallback if no context found
if [ -z "$SYSTEM_CONTEXT" ]; then
    SYSTEM_CONTEXT="No system context available."
fi

# =============================================================================
# 2. Build combined PROMPT (default + system additions)
# =============================================================================

PROMPT_CONTENT=""

# Always include default prompt
DEFAULT_PROMPT="$DEFAULT_DIR/prompts/$MODE.md"
if [ -f "$DEFAULT_PROMPT" ]; then
    PROMPT_CONTENT=$(cat "$DEFAULT_PROMPT")
else
    echo "Error: Default prompt not found: $DEFAULT_PROMPT" >&2
    exit 1
fi

# Add system-specific prompt additions if exists
SYSTEM_PROMPT="$SYSTEM_DIR/prompts/$MODE.md"
if [ "$SYSTEM" != "_default" ] && [ -f "$SYSTEM_PROMPT" ]; then
    PROMPT_CONTENT="$PROMPT_CONTENT

---

$(cat "$SYSTEM_PROMPT")"
fi

# =============================================================================
# 3. Read work item context
# =============================================================================

WORK_ITEM_CONTEXT=$(cat "$CONTEXT_FILE")

# =============================================================================
# 4. Extract attachment list for explicit prompt inclusion
# =============================================================================

# Generate a clear list of attachments with Read commands
ATTACHMENTS_LIST=$(echo "$WORK_ITEM_CONTEXT" | jq -r '
    if .attachments and (.attachments | length) > 0 then
        "The following files are available. Use the Read tool to view them:\n" +
        (.attachments | map("- " + .path + " (" + .type + ")") | join("\n"))
    else
        "No attachments available."
    end
' 2>/dev/null || echo "No attachments available.")

# =============================================================================
# 4b. Extract comments for conversation context
# =============================================================================

# Generate formatted comment history (newest first, limited to 20)
COMMENTS_LIST=$(echo "$WORK_ITEM_CONTEXT" | jq -r '
    if .comments and (.comments | length) > 0 then
        (.comments | map(
            "**" + .author + "** (" + (.date | split("T")[0]) + "):\n" +
            (.text | gsub("<[^>]*>"; "") | .[0:500])
        ) | join("\n\n---\n\n"))
    else
        "No previous comments."
    end
' 2>/dev/null || echo "No previous comments.")

# =============================================================================
# 5. Perform variable substitution
# =============================================================================

# Use awk for reliable multi-line substitution
echo "$PROMPT_CONTENT" | awk \
    -v system_ctx="$SYSTEM_CONTEXT" \
    -v context="$WORK_ITEM_CONTEXT" \
    -v command="$COMMAND_TEXT" \
    -v attachments="$ATTACHMENTS_LIST" \
    -v comments="$COMMENTS_LIST" '
{
    line = $0

    # Replace ${SYSTEM_CONTEXT}
    gsub(/\$\{SYSTEM_CONTEXT\}/, system_ctx, line)

    # Replace ${CONTEXT}
    gsub(/\$\{CONTEXT\}/, context, line)

    # Replace ${COMMAND}
    gsub(/\$\{COMMAND\}/, command, line)

    # Replace ${ATTACHMENTS}
    gsub(/\$\{ATTACHMENTS\}/, attachments, line)

    # Replace ${COMMENTS}
    gsub(/\$\{COMMENTS\}/, comments, line)

    print line
}
'
