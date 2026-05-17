#!/usr/bin/env bash
# Sync hermes config between this repo and ~/.hermes
# Usage: ./sync.sh [pull|deploy]

set -euo pipefail

HERMES_DIR="${HERMES_DIR:-$HOME/.hermes}"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

copy_file() {
  src="$1"
  dest="$2"

  if [ ! -f "$src" ]; then
    echo "[sync] skip missing file: $src"
    return 0
  fi

  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
}

sync_dir() {
  src="$1"
  dest="$2"
  delete_flag="${3:-}"

  if [ ! -d "$src" ]; then
    echo "[sync] skip missing directory: $src"
    return 0
  fi

  mkdir -p "$dest"
  if [ "$delete_flag" = "--delete" ]; then
    rsync -a --delete --exclude '__pycache__/' --exclude '*.pyc' "$src/" "$dest/"
  else
    rsync -a --exclude '__pycache__/' --exclude '*.pyc' "$src/" "$dest/"
  fi
}

case "${1:-pull}" in
  pull)
    echo "[sync] Pulling from $HERMES_DIR -> $REPO_DIR"
    copy_file "$HERMES_DIR/config.yaml" "$REPO_DIR/config.yaml"
    copy_file "$HERMES_DIR/SOUL.md" "$REPO_DIR/SOUL.md"
    sync_dir "$HERMES_DIR/skills" "$REPO_DIR/skills" --delete
    sync_dir "$HERMES_DIR/hooks" "$REPO_DIR/hooks" --delete
    echo "[sync] Done."
    ;;
  deploy)
    echo "[sync] Deploying from $REPO_DIR -> $HERMES_DIR"
    mkdir -p "$HERMES_DIR"
    copy_file "$REPO_DIR/config.yaml" "$HERMES_DIR/config.yaml"
    copy_file "$REPO_DIR/SOUL.md" "$HERMES_DIR/SOUL.md"
    sync_dir "$REPO_DIR/skills" "$HERMES_DIR/skills"
    sync_dir "$REPO_DIR/hooks" "$HERMES_DIR/hooks"
    echo "[sync] Done. Run 'hermes gateway restart' to apply."
    ;;
  *)
    echo "Usage: $0 [pull|deploy]"
    exit 1
    ;;
esac
