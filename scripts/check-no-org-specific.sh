#!/bin/bash
# check-no-org-specific.sh
# Prevents organization-specific values from being committed to the template
#
# Usage:
#   ./scripts/check-no-org-specific.sh           # Check all files
#   ./scripts/check-no-org-specific.sh --staged  # Check only staged files (for pre-commit)
#
# Add patterns to FORBIDDEN_PATTERNS array to block additional values

set -e

# Forbidden patterns - add organization-specific values here
FORBIDDEN_PATTERNS=(
    "jspannareif"
    "mobility-CTP"
    "if-it"
)

# Allowed patterns - exceptions that look like org-specific but are OK
ALLOWED_FILES=(
    "check-no-org-specific.sh"  # This file itself
)

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Parse arguments
STAGED_ONLY=false
if [[ "$1" == "--staged" ]]; then
    STAGED_ONLY=true
fi

cd "$TEMPLATE_ROOT"

# Get files to check
if [ "$STAGED_ONLY" = true ]; then
    FILES=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null || echo "")
else
    FILES=$(git ls-files 2>/dev/null || find . -type f -not -path './.git/*')
fi

if [ -z "$FILES" ]; then
    echo -e "${GREEN}No files to check${NC}"
    exit 0
fi

FOUND_ISSUES=false

for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
    # Search for pattern in files
    MATCHES=$(echo "$FILES" | xargs grep -l "$pattern" 2>/dev/null || true)

    for file in $MATCHES; do
        # Check if file is in allowed list
        SKIP=false
        for allowed in "${ALLOWED_FILES[@]}"; do
            if [[ "$file" == *"$allowed"* ]]; then
                SKIP=true
                break
            fi
        done

        if [ "$SKIP" = true ]; then
            continue
        fi

        echo -e "${RED}ERROR:${NC} Found '$pattern' in $file"
        grep -n "$pattern" "$file" | head -3
        echo ""
        FOUND_ISSUES=true
    done
done

if [ "$FOUND_ISSUES" = true ]; then
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}Organization-specific values found!${NC}"
    echo -e "${RED}========================================${NC}"
    echo ""
    echo "The template should only contain generic placeholders like:"
    echo "  - your-org"
    echo "  - your-project"
    echo "  - ghcr.io/opencode-ai/opencode:latest"
    echo ""
    echo "Organization-specific values belong in the parent repo, not the template."
    exit 1
fi

echo -e "${GREEN}No organization-specific values found${NC}"
exit 0
