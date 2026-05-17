#!/usr/bin/env bash
# Auto-sync ~/.hermes config to this git repo.

set -euo pipefail

REPO_DIR="${REPO_DIR:-$(cd "$(dirname "$0")" && pwd)}"
cd "$REPO_DIR"

# Pull latest from ~/.hermes.
bash "$REPO_DIR/sync.sh" pull

# Check if there are changes.
if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
  echo "[auto-sync] No changes."
  exit 0
fi

# Refuse to auto-commit channel metadata because thread names can contain PII.
if git ls-files --error-unmatch channel_directory.json >/dev/null 2>&1; then
  echo "[auto-sync] channel_directory.json is still tracked. Run: git rm --cached channel_directory.json"
  exit 1
fi

# Commit and push only the repository-managed files.
git add -A -- \
  .gitignore \
  README.md \
  SOUL.md \
  config.yaml \
  mise.toml \
  pyproject.toml \
  uv.lock \
  sync.sh \
  auto-sync.sh \
  channel_directory.example.json \
  .github/workflows \
  hooks \
  scripts \
  skills

if git diff --cached --quiet; then
  echo "[auto-sync] No repository-managed changes."
  exit 0
fi

git commit -m "auto-sync: $(date +%Y-%m-%d)"
git push
