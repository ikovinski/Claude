#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

DIRS=(commands agents rules scenarios skills contexts templates)

echo "AI Agents System — Uninstall"
echo "Source: $REPO_DIR"
echo "Target: $CLAUDE_DIR"
echo ""

removed=0
skipped=0

for dir in "${DIRS[@]}"; do
  source="$REPO_DIR/$dir"

  [ -d "$source" ] || continue
  [ -d "$CLAUDE_DIR/$dir" ] || continue

  for item in "$source"/*; do
    [ -e "$item" ] || continue

    name="$(basename "$item")"
    target="$CLAUDE_DIR/$dir/$name"

    if [ ! -L "$target" ]; then
      echo "  SKIP  $dir/$name (not a symlink)"
      ((skipped++))
      continue
    fi

    current=$(readlink "$target")
    if [ "$current" != "$item" ]; then
      echo "  SKIP  $dir/$name (points to $current, not this repo)"
      ((skipped++))
      continue
    fi

    rm "$target"
    echo "  DEL   $dir/$name"
    ((removed++))
  done

  # Remove directory if empty (our mkdir -p cleanup)
  rmdir "$CLAUDE_DIR/$dir" 2>/dev/null && echo "  CLEAN $dir/ (empty, removed)" || true
done

echo ""
echo "Done: $removed removed, $skipped skipped."
