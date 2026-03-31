#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

DIRS=(commands agents rules scenarios skills contexts templates)

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
  source="$REPO_DIR/$dir"

  if [ ! -d "$source" ]; then
    echo "  SKIP  $dir/ (not found in repo)"
    continue
  fi

  # Ensure target directory exists
  mkdir -p "$CLAUDE_DIR/$dir"

  # Link each item (file or subdirectory) inside the directory
  for item in "$source"/*; do
    [ -e "$item" ] || continue

    name="$(basename "$item")"
    target="$CLAUDE_DIR/$dir/$name"

    if [ -L "$target" ]; then
      current=$(readlink "$target")
      if [ "$current" = "$item" ]; then
        echo "  OK    $dir/$name (already linked)"
        ((installed++))
        continue
      else
        echo "  SKIP  $dir/$name (symlink exists -> $current)"
        ((skipped++))
        continue
      fi
    fi

    if [ -e "$target" ]; then
      echo "  SKIP  $dir/$name (already exists)"
      ((skipped++))
      continue
    fi

    ln -s "$item" "$target"
    echo "  LINK  $dir/$name -> $item"
    ((installed++))
  done
done

echo ""
echo "Done: $installed linked, $skipped skipped."
