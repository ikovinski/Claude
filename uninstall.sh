#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

DIRS=(commands agents rules scenarios skills)

echo "AI Agents System — Uninstall"
echo "Source: $REPO_DIR"
echo "Target: $CLAUDE_DIR"
echo ""

removed=0
skipped=0

for dir in "${DIRS[@]}"; do
  target="$CLAUDE_DIR/$dir"
  source="$REPO_DIR/$dir"

  if [ ! -L "$target" ]; then
    echo "  SKIP  $dir/ (not a symlink)"
    ((skipped++))
    continue
  fi

  current=$(readlink "$target")
  if [ "$current" != "$source" ]; then
    echo "  SKIP  $dir/ (points to $current, not this repo)"
    ((skipped++))
    continue
  fi

  rm "$target"
  echo "  DEL   $dir/"
  ((removed++))
done

echo ""
echo "Done: $removed removed, $skipped skipped."
