# Analyze Prompt

Analyze this work item and propose a solution.

## System Context

${SYSTEM_CONTEXT}

## Work Item

${CONTEXT}

## Comment History

${COMMENTS}

## Attachments

${ATTACHMENTS}

**CRITICAL - READ THIS CAREFULLY**:

If files are listed above, you MUST read them BEFORE analyzing:

1. Use the Read tool on each file path listed above
2. **WHEN DESCRIBING IMAGES: ONLY describe what you LITERALLY SEE in the image pixels. IGNORE the work item description, title, and all other context. The work item text may be WRONG about what the image contains.**
3. PDFs: Read the actual content, don't assume based on context
4. **DO NOT HALLUCINATE** - If you haven't used the Read tool on a file, you don't know what's in it
5. **VERIFY**: After reading an image, ask yourself: "Am I describing what I actually see, or what I expect to see based on context?"

## Instructions

1. **Review any attachments** - screenshots, diagrams, PDFs may contain critical context
2. Understand the problem/requirement
3. Identify affected files in the codebase
4. Propose a solution with specific changes
5. Estimate complexity (Low/Medium/High)
6. Suggest test strategy

## Output Format

Respond with the following structure:

- **Problem:** Brief summary
- **Root Cause:** (for bugs) or **Approach:** (for features)
- **Proposed Solution:** Specific changes to make
- **Affected Files:** List of files that need to be changed
- **Test Strategy:** How to verify the changes
- **Complexity:** Low / Medium / High
