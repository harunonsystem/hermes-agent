#!/usr/bin/env bash
# Install dependencies required by repository validation scripts.

set -euo pipefail

uv sync --locked
