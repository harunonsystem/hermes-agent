---
name: umami-analytics
description: Umami(セルフホスト型アナリティクス)のサイトデータを分析し、改善提案を生成する。アクセス解析・サイト分析・トラフィック分析の依頼で発火。 Analyze Umami website data and generate improvement suggestions.
version: 1.1.0
author: Hermes Agent
---

# Umami Analytics Skill

This skill analyzes data from Umami (self-hosted) and provides a summary and improvement suggestions.

## Trigger

Use this skill when the user asks about ANY of the following (English or Japanese):

**English:**
- "Umami analytics"
- "umami analysis"
- "/analyze umami"
- "analyze website traffic"
- "improvement suggestions from analytics data"

**日本語 (これらのキーワードでも必ず発火):**
- 「umami」「Umami」「うまみ」(単独でも反応する)
- 「アナリティクス」「analytics」
- 「アクセス解析」「アクセス分析」
- 「サイト分析」「サイトの解析」
- 「トラフィック分析」「PV分析」
- 「サイトのアクセス見て」「うちのサイトどう?」
- 「ブログの数字」「ウェブサイトの数字」
- 「改善提案」+「サイト/ブログ」の組み合わせ
- 「/analyze」「/umami」「/traffic」

判定迷ったら発火させる。空振りしてもユーザーに確認すれば済む。

## Requirements

Environment variables MUST be loaded from `~/.hermes/.env`:

```bash
# These should already be in ~/.hermes/.env
source ~/.hermes/.env
echo $UMAMI_API_ENDPOINT
echo $UMAMI_USERNAME
echo $UMAMI_PASSWORD
```

If missing, ask the user to add them to `~/.hermes/.env`.

**Important**: Use username/password (not USER_ID/SECRET) for authentication!

## Usage

When triggered, immediately:
1. Load the environment variables from ~/.hermes/.env
2. Make API calls using bash curl

**Important**: Do NOT ask for confirmation. Just do it.

### Environment check:
```bash
echo "UMAMI_API_ENDPOINT: ${UMAMI_API_ENDPOINT}"
echo "UMAMI_API_CLIENT_USER_ID: ${UMAMI_API_CLIENT_USER_ID}"
echo "UMAMI_API_CLIENT_SECRET: ${UMAMI_API_CLIENT_SECRET}"
```

## Steps

**DO THIS IMMEDIATELY when triggered:**

### Step 1: Load environment variables
```bash
source ~/.hermes/.env
```
Check that UMAMI_USERNAME and UMAMI_PASSWORD are available.

### Step 2: Login to get token
```bash
login_payload="$(jq -n \
  --arg username "${UMAMI_USERNAME}" \
  --arg password "${UMAMI_PASSWORD}" \
  '{username: $username, password: $password}')"

TOKEN="$(curl --fail-with-body -sSL -X POST "${UMAMI_API_ENDPOINT}/auth/login" \
  -H "Content-Type: application/json" \
  --data "${login_payload}" | jq -r '.token')"

if [ -z "${TOKEN}" ] || [ "${TOKEN}" = "null" ]; then
  echo "Failed to obtain Umami token" >&2
  exit 1
fi

echo "Token obtained"
```

### Step 3: Get all websites
```bash
curl -sL "${UMAMI_API_ENDPOINT}/websites" \
  -H "Authorization: Bearer ${TOKEN}"
```

### Step 4: For each website, get stats
```bash
# Get stats (last 30 days)
nowMs=$(($(date +%s) * 1000))
thirtyDaysAgo=$((nowMs - 30 * 24 * 60 * 60 * 1000))

curl -sL "${UMAMI_API_ENDPOINT}/websites/${websiteId}/stats?startAt=${thirtyDaysAgo}&endAt=${nowMs}" \
  -H "Authorization: Bearer ${TOKEN}"
```

### Step 5: Analyze and output
- Summarize total pageviews, unique visitors
- Identify trends
- Generate 3-5 actionable improvement suggestions

## Implementation Notes

- Use bash `curl` to make API calls
- Process JSON responses with your reasoning
- Do NOT ask for confirmation - just execute
- First login to get token, then use Bearer auth

## Detailed Procedure

### Step 1: Validate Environment

Check that the following environment variables are set:
- UMAMI_API_ENDPOINT
- UMAMI_API_CLIENT_USER_ID
- UMAMI_API_CLIENT_SECRET

If any are missing, ask the user to add them to ~/.hermes/.env

### Step 2: Get Token via Login

```bash
TOKEN=$(curl -s -X POST "${UMAMI_API_ENDPOINT}/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"username\": \"${UMAMI_USERNAME}\", \"password\": \"${UMAMI_PASSWORD}\"}" | jq -r '.token')
```

Save the token for subsequent requests.

### Step 3: Get List of Websites

```bash
curl -s "${UMAMI_API_ENDPOINT}/websites" \
  -H "Authorization: Bearer ${TOKEN}"
```

Save the output to a file for analysis.

### Step 4: Fetch Statistics for Each Website

For stats (last 30 days):
```bash
curl -s "${UMAMI_API_ENDPOINT}/websites/${websiteId}/stats?startAt=${30daysAgo}&endAt=${now}" \
  -H "Authorization: Bearer ${TOKEN}"
```

For events:
```bash
curl -s "${UMAMI_API_ENDPOINT}/websites/${websiteId}/events?startAt=${30daysAgo}&endAt=${now}" \
  -H "Authorization: Bearer ${TOKEN}"
```

For metrics:
```bash
curl -s "${UMAMI_API_ENDPOINT}/websites/${websiteId}/metrics?startAt=${30daysAgo}&endAt=${now}" \
  -H "Authorization: Bearer ${TOKEN}"
```

### Step 4: Analyze Data

Look for:
- Traffic trends (increasing/decreasing)
- High bounce rate pages
- Low engagement metrics
- Referral sources
- Top performing content
- Technical issues (e.g., 404 errors from events)
- Conversion funnel drop-offs

Calculate timestamps for last 30 days using bash:
```bash
nowMs=$(($(date +%s) * 1000))
thirtyDaysAgo=$((nowMs - 30 * 24 * 60 * 60 * 1000))
```

### Step 5: Generate Output

Produce a markdown-formatted report with:

## Umami Analytics Report

### Summary
- Overall traffic stats
- Key highlights

### Improvement Suggestions
1. [Specific actionable suggestion]
2. [Another suggestion]
...

Each suggestion should be clear, concise, and tied to the data.

## Example Output

```
## Umami Analytics Report

### Summary
Total pageviews: 12,345 (up 5% from last period)
Unique visitors: 8,910
Top referral source: google.com

### Improvement Suggestions
1. Optimize landing page for mobile users - bounce rate is 65% on mobile vs 45% on desktop.
2. Create more content around "topic X" - it has the highest engagement time.
3. Fix broken links on product pages - 404 events increased 20% last week.
```

## Notes

- The agent should use its reasoning to interpret the data and generate suggestions.
- For complex analysis, the agent may break down the task into substeps (e.g., first analyze traffic, then analyze user behavior).
- The output should be ready to copy-paste into a Discord message.