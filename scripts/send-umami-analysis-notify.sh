#!/usr/bin/env bash
# Send a Discord notification that asks whether to run Umami analysis.

set -euo pipefail

: "${DISCORD_WEBHOOK_URL:?DISCORD_WEBHOOK_URL is required}"

extra_message="${EXTRA_MESSAGE:-}"
base_content=$'Umami 分析を実行しますか？\n\n`/analyze umami` で全Webサイトのアクセス解析を実行します。'
content="${base_content}"
if [ -n "${extra_message}" ]; then
  content+=$'\n\n'
  content+="${extra_message}"
fi

payload="$(jq -nc --arg content "${content}" '{content: $content, allowed_mentions: {parse: []}}')"
curl --fail-with-body -X POST "${DISCORD_WEBHOOK_URL}" \
  -H "Content-Type: application/json" \
  --data "${payload}"
