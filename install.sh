#!/usr/bin/env bash
# install.sh — Install Claude Code custom commands globally
# Usage: bash install.sh
# Copies all commands from .claude/commands/ to ~/.claude/commands/
# so they are available as slash commands in any project.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$SCRIPT_DIR/.claude/commands"
DESTINATION="$HOME/.claude/commands"

if [ ! -d "$SOURCE" ]; then
  echo "Error: source directory not found: $SOURCE" >&2
  exit 1
fi

mkdir -p "$DESTINATION"

count=0
for file in "$SOURCE"/*.md; do
  [ -f "$file" ] || continue
  cp "$file" "$DESTINATION/$(basename "$file")"
  echo "Installed: $(basename "$file")"
  count=$((count + 1))
done

if [ "$count" -eq 0 ]; then
  echo "Warning: no .md files found in $SOURCE"
  exit 0
fi

echo ""
echo "Done. $count command(s) installed to $DESTINATION"
echo "Restart Claude Code or open a new terminal to use the commands."
