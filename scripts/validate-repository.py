#!/usr/bin/env python3
"""Validate repository metadata files used by Hermes Agent."""

from __future__ import annotations

import json
from pathlib import Path

import yaml


ROOT = Path(__file__).resolve().parents[1]


def _load_json(path: Path) -> None:
    with path.open(encoding="utf-8") as f:
        json.load(f)


def _load_yaml(path: Path) -> None:
    with path.open(encoding="utf-8") as f:
        yaml.safe_load(f)


def _validate_skill_frontmatter(path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---\n"):
        raise ValueError(f"{path}: missing YAML frontmatter")

    end = text.find("\n---\n", 4)
    if end == -1:
        raise ValueError(f"{path}: unterminated YAML frontmatter")

    metadata = yaml.safe_load(text[4:end])
    if not isinstance(metadata, dict):
        raise ValueError(f"{path}: frontmatter is not a mapping")

    for key in ("name", "description"):
        if key not in metadata:
            raise ValueError(f"{path}: missing frontmatter key: {key}")


def main() -> None:
    for path in [ROOT / "channel_directory.example.json"]:
        _load_json(path)

    yaml_files = [ROOT / "config.yaml"]
    yaml_files.extend((ROOT / "hooks").glob("**/*.yaml"))
    yaml_files.extend((ROOT / ".github" / "workflows").glob("*.yml"))
    yaml_files.extend((ROOT / ".github" / "workflows").glob("*.yaml"))
    for path in yaml_files:
        _load_yaml(path)

    for path in (ROOT / "skills").glob("**/SKILL.md"):
        _validate_skill_frontmatter(path)

    print("Validation passed")


if __name__ == "__main__":
    main()
