# AGENTS.md

This repository manages local Hermes Agent configuration, personas, skills, hooks, and validation tooling.

## Scope

These instructions apply to the entire repository.

## Repository purpose

- Manage Hermes local configuration in Git.
- Keep reusable Hermes assets such as `skills/`, `hooks/`, `SOUL.md`, and `config.yaml`.
- Keep validation and GitHub Actions scripts reproducible.
- Avoid committing runtime state, logs, caches, secrets, and personal channel metadata.

## Language and communication

- Prefer Japanese for user-facing explanations in this repository.
- Keep answers concise and evidence-based.
- Do not add unrelated features or broad refactors.
- Do not perform destructive or irreversible operations without explicit confirmation.

## Privacy and security

Never commit:

- `channel_directory.json`
- `.env`
- secrets or tokens
- runtime state files
- logs
- memory/session data
- cache files
- `__pycache__/`
- `*.pyc`

`channel_directory.json` is intentionally ignored because Discord channel/thread names can contain private conversation content or personal information.

If sensitive data was already committed, deleting the file in a later commit is not enough. Treat it as disclosed and consider history rewrite/remediation separately.

## Tooling

Use the project-managed toolchain:

- `mise` for executable versions
- `uv` for Python dependency and lockfile management
- `ruff` for Python formatting/linting
- `lefthook` for local Git hooks

Recommended setup:

- `mise trust`
- `mise install`
- `uv sync --locked`
- `lefthook install`

## Validation

Before committing, run:

- `bash scripts/validate-repository.sh`

GitHub Actions runs:

- `bash scripts/gha/validate.sh`

The validation should check at minimum:

- shell syntax
- Python formatting/linting
- Python compile checks
- JSON parsing
- YAML parsing
- skill frontmatter parsing

## Formatting and auto-fix

For local auto-fixes, use:

- `bash scripts/fix-repository.sh`

Auto-fix scripts should be best-effort and may continue after formatter errors, but final validation must remain strict.

Do not make CI auto-fix files. CI should fail and report the issue.

## Python conventions

- Target Python 3.11.
- Prefer `pathlib.Path` for paths.
- Prefer explicit UTF-8 when reading/writing text files.
- Keep validation scripts deterministic and offline where possible.
- Use `ruff format` and `ruff check`.
- Avoid adding dependencies unless they are needed by validation or repository tooling.

## Shell conventions

- Use `#!/usr/bin/env bash`.
- Use `set -euo pipefail` for strict scripts.
- Quote variables.
- Resolve repo root before operating on files.
- Keep GitHub Actions entrypoints thin and delegate logic to scripts under `scripts/`.

## Git conventions

- Stage only intentional changes.
- Do not commit generated caches or runtime state.
- For auto-sync behavior, only stage repository-managed files.
- Do not reintroduce `channel_directory.json`.

## Review priorities

When reviewing changes, pay special attention to:

- privacy leaks
- secret exposure
- unsafe shell interpolation
- broken CI validation
- workflows that depend on unavailable tools
- scripts that silently ignore failures
- mismatch between README instructions and actual tooling
