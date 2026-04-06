"""After /model switch, update the Discord bot nickname to include the model name."""

import asyncio
import os
import yaml
from pathlib import Path


def _get_current_model() -> str:
    """Read current model from config.yaml."""
    config_path = Path.home() / ".hermes" / "config.yaml"
    try:
        with open(config_path, encoding="utf-8") as f:
            cfg = yaml.safe_load(f) or {}
        model_cfg = cfg.get("model", {})
        return model_cfg.get("name") or model_cfg.get("default") or "unknown"
    except Exception:
        return "unknown"


def _short_model_name(model: str) -> str:
    """Strip provider prefix for cleaner display. e.g. openai/gpt-4o-mini -> gpt-4o-mini"""
    if "/" in model:
        model = model.split("/", 1)[1]
    # Remove :free suffix
    if model.endswith(":free"):
        model = model[:-5]
    return model


async def _update_nickname():
    """Connect briefly to Discord to update nickname."""
    import discord

    token = os.environ.get("DISCORD_BOT_TOKEN")
    if not token:
        return

    model = _short_model_name(_get_current_model())
    new_nick = f"hermes | {model}"

    intents = discord.Intents.default()
    client = discord.Client(intents=intents)

    @client.event
    async def on_ready():
        for guild in client.guilds:
            try:
                await guild.me.edit(nick=new_nick)
                print(f"[update-nickname] Set nickname to '{new_nick}' in {guild.name}")
            except Exception as e:
                print(f"[update-nickname] Failed in {guild.name}: {e}")
        await client.close()

    try:
        await asyncio.wait_for(client.start(token), timeout=15)
    except (asyncio.TimeoutError, asyncio.CancelledError):
        pass


def handler(event_type: str, context: dict):
    """Hook entry point — called by HookRegistry.emit()."""
    # Small delay to let the model switch persist to config.yaml
    async def _delayed():
        await asyncio.sleep(2)
        await _update_nickname()

    return _delayed()
