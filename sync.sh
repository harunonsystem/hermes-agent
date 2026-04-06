#!/bin/bash
# Sync hermes-config -> ~/.hermes
# Usage: ./sync.sh [deploy|pull]

HERMES_DIR="$HOME/.hermes"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

case "${1:-pull}" in
  pull)
    echo "Pulling from ~/.hermes -> repo..."
    cp "$HERMES_DIR/config.yaml" "$REPO_DIR/"
    cp "$HERMES_DIR/SOUL.md" "$REPO_DIR/"
    cp "$HERMES_DIR/channel_directory.json" "$REPO_DIR/"
    rsync -a --delete "$HERMES_DIR/skills/" "$REPO_DIR/skills/"
    [ -d "$HERMES_DIR/hooks" ] && rsync -a --delete "$HERMES_DIR/hooks/" "$REPO_DIR/hooks/"
    echo "Done."
    ;;
  deploy)
    echo "Deploying repo -> ~/.hermes..."
    cp "$REPO_DIR/config.yaml" "$HERMES_DIR/"
    cp "$REPO_DIR/SOUL.md" "$HERMES_DIR/"
    cp "$REPO_DIR/channel_directory.json" "$HERMES_DIR/"
    rsync -a "$REPO_DIR/skills/" "$HERMES_DIR/skills/"
    [ -d "$REPO_DIR/hooks" ] && rsync -a "$REPO_DIR/hooks/" "$HERMES_DIR/hooks/"
    echo "Done. Run 'hermes gateway restart' to apply."
    ;;
  *)
    echo "Usage: $0 [pull|deploy]"
    exit 1
    ;;
esac
