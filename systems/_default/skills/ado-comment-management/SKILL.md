---
name: ado-comment-management
description: Use when user requests managing Azure DevOps work item comments - listing, deleting, updating, or cleaning up AI-generated comments.
---

# Azure DevOps Comment Management

Manage work item comments using `scripts/update-workitem.sh`.

## Commands

| Action | Command |
|--------|---------|
| List comments | `bash scripts/update-workitem.sh --work-item-id $WORK_ITEM_ID --list-comments` |
| Delete one | `bash scripts/update-workitem.sh --work-item-id $WORK_ITEM_ID --delete-comment <COMMENT_ID>` |
| Delete AI comments | `bash scripts/update-workitem.sh --work-item-id $WORK_ITEM_ID --delete-ai-comments` |
| Update comment | `bash scripts/update-workitem.sh --work-item-id $WORK_ITEM_ID --update-comment <COMMENT_ID> --add-comment "New text"` |
| Add reaction | `bash scripts/update-workitem.sh --work-item-id $WORK_ITEM_ID --add-reaction like --reaction-comment-pattern "@ai"` |

## Environment Variables (pre-set in pipeline)

All required variables are already set:
- `AZURE_DEVOPS_ORG` - Organization name
- `AZURE_DEVOPS_PROJECT` - Project name
- `AZURE_DEVOPS_PAT` - Auth token
- `WORK_ITEM_ID` - Current work item ID

**Use `$WORK_ITEM_ID` directly** - no need to specify it manually.

## Common Tasks

### "Remove your comments" / "Delete AI comments"
```bash
bash scripts/update-workitem.sh --work-item-id $WORK_ITEM_ID --delete-ai-comments
```

### "List comments" / "Show comments"
```bash
bash scripts/update-workitem.sh --work-item-id $WORK_ITEM_ID --list-comments
```

### Update status comment (live todo)
```bash
# First time: create comment, note the ID from output
bash scripts/update-workitem.sh --work-item-id $WORK_ITEM_ID --add-comment "## Status\n- [ ] Task 1\n- [ ] Task 2"

# Later: update same comment with progress
bash scripts/update-workitem.sh --work-item-id $WORK_ITEM_ID --update-comment <COMMENT_ID> --add-comment "## Status\n- [x] Task 1\n- [ ] Task 2"
```

## Reactions

Available: `like`, `dislike`, `heart`, `hooray`, `smile`, `confused`

## Notes

- `--delete-ai-comments` only deletes comments from Build Service or containing "AI Agent"
- `--update-comment` requires `--add-comment` with the new text
- Text is automatically converted from Markdown to HTML

## Limitations

**Delete/Update requires creator identity**: Azure DevOps only allows the comment creator to modify or delete their comments. This means:
- In pipeline: Works with `System.AccessToken` (Build Service identity)
- Locally: Only works for comments you created with your PAT
