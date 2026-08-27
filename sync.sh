#!/usr/bin/env bash
# Deploy hermes-config -> ~/.hermes
# Usage: ./sync.sh deploy

set -euo pipefail

HERMES_DIR="$HOME/.hermes"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

case "${1:-}" in
  pull)
    echo "Pull is disabled: hermes-config is the settings SSOT."
    echo "Review and import live changes manually before editing the SSOT."
    exit 2
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
    echo "Usage: $0 deploy"
    exit 1
    ;;
esac
