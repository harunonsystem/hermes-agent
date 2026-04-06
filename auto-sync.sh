#!/bin/bash
# Auto-sync ~/.hermes config to git repo (daily cron)
REPO_DIR="$HOME/hermes-config"
cd "$REPO_DIR" || exit 1

# Pull latest from ~/.hermes
bash sync.sh pull

# Check if there are changes
if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
  exit 0
fi

# Commit and push
git add -A
git commit -m "auto-sync: $(date +%Y-%m-%d)"
git push
