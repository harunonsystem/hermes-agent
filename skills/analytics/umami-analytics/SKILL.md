---
name: umami-analytics
description: Analyze Umami website data and generate improvement suggestions.
version: 1.0.0
author: Hermes Agent
---

# Umami Analytics Skill

This skill analyzes data from Umami (self-hosted) and provides a summary and improvement suggestions.

## Requirements

Environment variables must be set (via `op run` or as arguments):

| Variable | Description | Example |
|----------|------------|---------|
| UMAMI_API_ENDPOINT | Base URL of the Umami API | `https://umami.example.com/api/` |
| UMAMI_API_CLIENT_USER_ID | User ID for API authentication | (UUID) |
| UMAMI_API_CLIENT_SECRET | Secret matching APP_SECRET | (random string) |

## Usage

### Via op run (recommended):
```bash
op run -- umami-analytics
```

### Inline (with env vars):
```
Use the umami-analytics skill. Environment variables:
- UMAMI_API_ENDPOINT: <endpoint>
- UMAMI_API_CLIENT_USER_ID: <user_id>
- UMAMI_API_CLIENT_SECRET: <secret>
```

## Steps

1. Validate that the required environment variables are set.
2. Fetch the list of websites from the Umami API.
3. For each website, fetch statistics (pageviews, visitors, etc.) and optionally events and metrics.
4. Analyze the collected data to identify trends, issues, and opportunities for improvement.
5. Generate a summary of the current state and a list of actionable improvement suggestions.
6. Output the summary and suggestions in a format suitable for posting to Discord.

## Implementation Notes

- The agent should use the `bash` tool to make HTTP requests (e.g., using `curl`) to the Umami API.
- The agent should handle pagination if necessary (though the Umami API might not paginate for these endpoints).
- The analysis should be done by the agent's reasoning capabilities, guided by the prompts in this skill.

## Detailed Procedure

### Step 1: Validate Environment

Check that the following environment variables are set:
- UMAMI_API_ENDPOINT
- UMAMI_API_CLIENT_USER_ID
- UMAMI_API_CLIENT_SECRET

If any are missing, ask the user to add them to ~/.hermes/.env

### Step 2: Get List of Websites

```bash
curl -s "${UMAMI_API_ENDPOINT}/websites" \
  -H "X-UMAMI-USERID: ${UMAMI_API_CLIENT_USER_ID}" \
  -H "X-UMAMI-SECRET: ${UMAMI_API_CLIENT_SECRET}"
```

Save the output to a file for analysis.

### Step 3: Fetch Statistics for Each Website

For stats (last 30 days):
```bash
curl -s "${UMAMI_API_ENDPOINT}/websites/${websiteId}/stats?startAt=${30daysAgo}&endAt=${now}" \
  -H "X-UMAMI-USERID: ${UMAMI_API_CLIENT_USER_ID}" \
  -H "X-UMAMI-SECRET: ${UMAMI_API_CLIENT_SECRET}"
```

For events:
```bash
curl -s "${UMAMI_API_ENDPOINT}/websites/${websiteId}/events?startAt=${30daysAgo}&endAt=${now}" \
  -H "X-UMAMI-USERID: ${UMAMI_API_CLIENT_USER_ID}" \
  -H "X-UMAMI-SECRET: ${UMAMI_API_CLIENT_SECRET}"
```

For metrics:
```bash
curl -s "${UMAMI_API_ENDPOINT}/websites/${websiteId}/metrics?startAt=${30daysAgo}&endAt=${now}" \
  -H "X-UMAMI-USERID: ${UMAMI_API_CLIENT_USER_ID}" \
  -H "X-UMAMI-SECRET: ${UMAMI_API_CLIENT_SECRET}"
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
now=$(date +%s)
thirtyDaysAgo=$((now - 30 * 24 * 60 * 60 * 1000))
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