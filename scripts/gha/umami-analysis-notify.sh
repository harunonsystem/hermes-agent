#!/usr/bin/env bash
# GitHub Actions entrypoint for Umami analysis notification.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT_DIR}"

bash scripts/send-umami-analysis-notify.sh
