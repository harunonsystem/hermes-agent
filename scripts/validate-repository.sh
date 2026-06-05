#!/usr/bin/env bash
# Run repository validation checks used by GitHub Actions and local development.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

for shell_script in sync.sh auto-sync.sh; do
  bash -n "${shell_script}"
done

find scripts -type f -name '*.sh' -print | sort | while IFS= read -r script; do
  bash -n "${script}"
done

uv run ruff format --check scripts hooks
uv run ruff check scripts hooks
uv run python -m py_compile hooks/update-nickname/handler.py scripts/validate-repository.py
uv run python scripts/validate-repository.py
