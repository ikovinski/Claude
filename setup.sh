#!/bin/bash

# AI Agents System - Setup Script
# Creates symlinks in ~/.claude/ for:
#   - commands (slash commands)
#   - skills (project patterns)
#   - agents (AI personas)
#   - rules (coding standards)
#   - scenarios (multi-step workflows)
#   - contexts (mode-specific focus)
# and configures global CLAUDE.md

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🤖 AI Agents System - Setup"
echo "==========================="
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
CLAUDE_MD_PATH="$CLAUDE_DIR/CLAUDE.md"
TEMPLATE_PATH="$SCRIPT_DIR/templates/global-claude-md.template"

# Directories to symlink
DIRS=("commands" "skills" "agents" "rules" "scenarios" "contexts")

# Step 1: Create ~/.claude if it doesn't exist
if [ ! -d "$CLAUDE_DIR" ]; then
    echo -e "${YELLOW}Creating $CLAUDE_DIR...${NC}"
    mkdir -p "$CLAUDE_DIR"
fi

# Step 2: Create/update symlinks for each directory
for dir in "${DIRS[@]}"; do
    SYMLINK_PATH="$CLAUDE_DIR/$dir"
    TARGET_PATH="$SCRIPT_DIR/$dir"

    if [ ! -d "$TARGET_PATH" ]; then
        echo -e "${YELLOW}Skipping $dir (directory not found in source)${NC}"
        continue
    fi

    if [ -L "$SYMLINK_PATH" ]; then
        echo -e "${YELLOW}Symlink $dir already exists. Updating...${NC}"
        rm "$SYMLINK_PATH"
    elif [ -d "$SYMLINK_PATH" ]; then
        echo -e "${RED}Error: $SYMLINK_PATH is a directory, not a symlink.${NC}"
        echo "Please remove it manually and run setup again."
        exit 1
    fi

    ln -s "$TARGET_PATH" "$SYMLINK_PATH"
    echo -e "${GREEN}✓ Created symlink: ~/.claude/$dir → $TARGET_PATH${NC}"
done

# Step 3: Backup existing CLAUDE.md if it exists
if [ -f "$CLAUDE_MD_PATH" ]; then
    BACKUP_PATH="$CLAUDE_MD_PATH.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$CLAUDE_MD_PATH" "$BACKUP_PATH"
    echo -e "${YELLOW}✓ Backed up existing CLAUDE.md to: $BACKUP_PATH${NC}"
fi

# Step 4: Create/update CLAUDE.md from template
if [ -f "$TEMPLATE_PATH" ]; then
    cp "$TEMPLATE_PATH" "$CLAUDE_MD_PATH"
    echo -e "${GREEN}✓ Created $CLAUDE_MD_PATH from template${NC}"
else
    echo -e "${RED}Error: Template not found at $TEMPLATE_PATH${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo "The AI Agents System is now available globally."
echo ""
echo "Symlinks created:"
for dir in "${DIRS[@]}"; do
    if [ -L "$CLAUDE_DIR/$dir" ]; then
        echo "  ~/.claude/$dir"
    fi
done
echo ""
echo "To test, restart Claude Code and try:"
echo "  /plan \"Add new feature\""
echo "  /review src/MyService.php"
echo "  /debug"
echo ""
echo "To uninstall, run: ./uninstall.sh"
