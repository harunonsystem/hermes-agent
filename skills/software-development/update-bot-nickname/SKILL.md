---
name: Update Discord Bot Nickname
category: software-development
description: モデル切り替え時にDiscord Botのニックネームをモデル名入りに更新する
---

# SKILL: Update Discord Bot Nickname

## ルール
- `/model` でモデルを切り替えた後、必ず自分のDiscordニックネームを更新すること
- フォーマット: `hermes | モデル名`
- 例: `hermes | gpt-4o-mini`, `hermes | claude-sonnet-4.6`, `hermes | qwen3.6-plus`

## 実行方法
モデル切り替え後、以下のPythonコードをターミナルで実行してニックネームを変更する:

```python
import os, discord

TOKEN = os.environ.get("DISCORD_BOT_TOKEN")
client = discord.Client(intents=discord.Intents.default())

@client.event
async def on_ready():
    for guild in client.guilds:
        try:
            await guild.me.edit(nick="hermes | MODEL_NAME")
            print(f"Updated nickname in {guild.name}")
        except Exception as e:
            print(f"Failed: {e}")
    await client.close()

client.run(TOKEN)
```

MODEL_NAME を現在のモデル名に置き換えること。
