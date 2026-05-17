#!/usr/bin/env bash
# GitHub Actions entrypoint for repository validation.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT_DIR}"

bash scripts/install-validation-dependencies.sh
bash scripts/validate-repository.sh
