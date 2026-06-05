"""After /model switch, update the Discord bot nickname to include the model name."""

from __future__ import annotations

import asyncio
import os
import sys
from pathlib import Path

import yaml

DISCORD_NICKNAME_LIMIT = 32
NICKNAME_PREFIX = "hermes | "


def _log(message: str) -> None:
    print(f"[update-nickname] {message}", file=sys.stderr)


def _get_current_model() -> str:
    """Read current model from config.yaml."""
    config_path = Path.home() / ".hermes" / "config.yaml"
    try:
        with config_path.open(encoding="utf-8") as f:
            cfg = yaml.safe_load(f) or {}
    except Exception as exc:
        _log(f"Failed to read {config_path}: {exc}")
        return "unknown"

    model_cfg = cfg.get("model", {})
    if not isinstance(model_cfg, dict):
        _log(f"Invalid model config in {config_path}")
        return "unknown"

    return model_cfg.get("name") or model_cfg.get("default") or "unknown"


def _short_model_name(model: str) -> str:
    """Strip provider prefix for cleaner display. e.g. openai/gpt-4o-mini -> gpt-4o-mini."""
    if "/" in model:
        model = model.split("/", 1)[1]
    if model.endswith(":free"):
        model = model[:-5]
    return model


def _nickname_for_model(model: str) -> str:
    """Build a Discord-safe nickname for the current model."""
    short_model = _short_model_name(model)
    max_model_length = DISCORD_NICKNAME_LIMIT - len(NICKNAME_PREFIX)
    if len(short_model) > max_model_length:
        short_model = short_model[:max_model_length]
    return f"{NICKNAME_PREFIX}{short_model}"


async def _update_nickname() -> None:
    """Connect briefly to Discord to update nickname."""
    try:
        import discord
    except ModuleNotFoundError as exc:
        _log(f"Discord package is not available: {exc}")
        return

    token = os.environ.get("DISCORD_BOT_TOKEN")
    if not token:
        _log("DISCORD_BOT_TOKEN is not set; skipping nickname update")
        return

    new_nick = _nickname_for_model(_get_current_model())

    intents = discord.Intents.default()
    client = discord.Client(intents=intents)

    @client.event
    async def on_ready() -> None:
        for guild in client.guilds:
            try:
                await guild.me.edit(nick=new_nick)
                _log(f"Set nickname to '{new_nick}' in {guild.name}")
            except Exception as exc:
                _log(f"Failed to update nickname in {guild.name}: {exc}")
        await client.close()

    try:
        await asyncio.wait_for(client.start(token), timeout=15)
    except TimeoutError:
        _log("Timed out while updating Discord nickname")
    except asyncio.CancelledError:
        _log("Nickname update was cancelled")
        raise
    except Exception as exc:
        _log(f"Failed to update Discord nickname: {exc}")
    finally:
        if not client.is_closed():
            await client.close()


def handler(event_type: str, context: dict):
    """Hook entry point — called by HookRegistry.emit()."""

    async def _delayed() -> None:
        # Small delay to let the model switch persist to config.yaml.
        await asyncio.sleep(2)
        await _update_nickname()

    return _delayed()
