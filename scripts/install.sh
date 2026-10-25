#!/usr/bin/env bash
# Copy rick-skills into a project's .claude/skills (or any agent's skills dir).
# Usage: scripts/install.sh [target-dir]   (default: ./.claude/skills)
# Re-run to update; existing skills with the same name are replaced.
set -euo pipefail
SRC="$(cd "$(dirname "$0")/.." && pwd)/skills"
DEST="${1:-./.claude/skills}"
mkdir -p "$DEST"
for d in "$SRC"/*/; do
  name="$(basename "$d")"
  rm -rf "$DEST/$name"
  cp -r "$d" "$DEST/$name"
  echo "installed $name"
done
echo "done → $DEST"
