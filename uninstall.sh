#!/bin/bash

# AI Agents System - Uninstall Script
# Removes all symlinks and optionally restores backup CLAUDE.md

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🗑️  AI Agents System - Uninstall"
echo "================================"
echo ""

CLAUDE_DIR="$HOME/.claude"
CLAUDE_MD_PATH="$CLAUDE_DIR/CLAUDE.md"

# Directories to remove
DIRS=("commands" "skills" "agents" "rules" "scenarios" "contexts")

# Step 1: Remove all symlinks
for dir in "${DIRS[@]}"; do
    SYMLINK_PATH="$CLAUDE_DIR/$dir"
    if [ -L "$SYMLINK_PATH" ]; then
        rm "$SYMLINK_PATH"
        echo -e "${GREEN}✓ Removed symlink: $SYMLINK_PATH${NC}"
    else
        echo -e "${YELLOW}Symlink not found: $SYMLINK_PATH${NC}"
    fi
done

# Step 2: Check for backups
BACKUPS=$(ls -t "$CLAUDE_DIR"/CLAUDE.md.backup.* 2>/dev/null | head -1)

if [ -n "$BACKUPS" ]; then
    echo ""
    echo "Found backup: $BACKUPS"
    read -p "Restore this backup? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cp "$BACKUPS" "$CLAUDE_MD_PATH"
        echo -e "${GREEN}✓ Restored CLAUDE.md from backup${NC}"
    fi
else
    echo ""
    read -p "Remove CLAUDE.md? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -f "$CLAUDE_MD_PATH"
        echo -e "${GREEN}✓ Removed CLAUDE.md${NC}"
    fi
fi

echo ""
echo -e "${GREEN}✅ Uninstall complete!${NC}"
echo ""
echo "The ai-agents-system directory was NOT deleted."
echo "To completely remove, delete this directory manually."
