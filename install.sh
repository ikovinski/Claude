#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

DIRS=(commands agents rules scenarios skills)

echo "AI Agents System — Install"
echo "Source: $REPO_DIR"
echo "Target: $CLAUDE_DIR"
echo ""

if [ ! -d "$CLAUDE_DIR" ]; then
  echo "Error: $CLAUDE_DIR does not exist. Is Claude Code installed?"
  exit 1
fi

installed=0
skipped=0

for dir in "${DIRS[@]}"; do
  target="$CLAUDE_DIR/$dir"
  source="$REPO_DIR/$dir"

  if [ ! -d "$source" ]; then
    echo "  SKIP  $dir/ (not found in repo)"
    ((skipped++))
    continue
  fi

  if [ -L "$target" ]; then
    current=$(readlink "$target")
    if [ "$current" = "$source" ]; then
      echo "  OK    $dir/ (already linked)"
      ((installed++))
      continue
    else
      echo "  SKIP  $dir/ (symlink exists -> $current)"
      ((skipped++))
      continue
    fi
  fi

  if [ -e "$target" ]; then
    echo "  SKIP  $dir/ (already exists as regular file/directory)"
    ((skipped++))
    continue
  fi

  ln -s "$source" "$target"
  echo "  LINK  $dir/ -> $source"
  ((installed++))
done

echo ""
echo "Done: $installed linked, $skipped skipped."
