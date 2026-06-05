#!/usr/bin/env bash
# Best-effort repository auto-fixes for local lefthook.
# This script intentionally exits 0 so validation can run afterward.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

status=0

if [ "$#" -gt 0 ]; then
  targets=("$@")
else
  targets=(scripts hooks)
fi

uv run ruff format --force-exclude "${targets[@]}" || status=1
uv run ruff check --fix --force-exclude "${targets[@]}" || status=1

if [ "${status}" -ne 0 ]; then
  echo "[fix] Some auto-fixes failed, continuing to validation..." >&2
fi

exit 0
