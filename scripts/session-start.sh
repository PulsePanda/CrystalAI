#!/usr/bin/env bash

echo "## Session Context"
echo ""
echo "**Date:** $(date '+%Y-%m-%d (%A)')"
echo ""

# Show today's daily note if it exists
# Check CLAUDE_PROJECT_DIR first (if running in vault), then common vault locations
VAULT_PATHS=(
    "${CLAUDE_PROJECT_DIR:-}"
    "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/VaultyBoi"
    "$HOME/Documents/Obsidian"
    "$HOME/Obsidian"
)

DAILY_NOTE=""
TODAY=$(date +%Y-%m-%d)
for vpath in "${VAULT_PATHS[@]}"; do
    if [ -n "$vpath" ] && [ -f "$vpath/Daily Notes/$TODAY.md" ]; then
        DAILY_NOTE="$vpath/Daily Notes/$TODAY.md"
        break
    fi
done

if [ -n "$DAILY_NOTE" ]; then
    echo "### Today's Daily Note"
    head -30 "$DAILY_NOTE"
    echo ""
    echo "---"
    echo ""
fi

# Show pending heart-queue items
if [ -s "$HOME/.claude/state/operational/heart-queue" ]; then
    echo "### Pending Heart Queue"
    cat "$HOME/.claude/state/operational/heart-queue"
    echo ""
    echo "---"
    echo ""
fi

# List active projects from ~/Documents/Projects
PROJECTS_DIR="$HOME/Documents/Projects"
if [ -d "$PROJECTS_DIR" ]; then
    ACTIVE=$(find "$PROJECTS_DIR" -maxdepth 3 \( -name "*.md" -o -name "_project.md" \) -not -path "*/archive/*" -not -path "*/_archive/*" -not -path "*/_template/*" -exec grep -l "status:.*active" {} \; 2>/dev/null | head -10)
    if [ -n "$ACTIVE" ]; then
        echo "### Active Projects"
        echo "$ACTIVE" | while read -r f; do
            name=$(basename "$f" .md)
            if [ "$name" = "_project" ]; then
                basename "$(dirname "$f")"
            else
                echo "$name"
            fi
        done
        echo ""
        echo "---"
        echo ""
    fi
fi

echo "Run /resume to load full session context (Todoist tasks, behavioral state, integrations)."
