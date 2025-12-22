---
name: tender-api
description: "Interact with Tender App backend APIs for construction tender management. Actions: evaluate documents with AI, query price history with RAG, compare Excel files, manage projects/packages/BOQs/submissions. Use when user asks about tender evaluation, price intelligence, document comparison, project management, or needs to call Tender App APIs. Requires TENDER_CLI_TOKEN environment variable."
allowed-tools: Bash, Read, Grep, Glob
---

# Tender API Skill

Enables Claude Code to interact with the Tender App backend APIs for construction tender management.

## Prerequisites

### 1. CLI Token Setup

Before using this skill, you need a CLI token:

1. Go to **https://tender.sipher.gg/cli-tokens**
2. Generate a new token and copy it
3. Set the environment variable:

```bash
export TENDER_CLI_TOKEN="tnd_your_token_here"
```

See [references/AUTH.md](references/AUTH.md) for detailed setup instructions.

### 2. API Server

The skill connects to the production API by default:
```bash
# Default: https://tender-api.sipher.gg/api
# Override with TENDER_API_URL environment variable if needed
```

---

## Quick Reference

| Category | Use Case | Reference |
|----------|----------|-----------|
| **Authentication** | CLI token setup, verification | [AUTH.md](references/AUTH.md) |
| **CLI Tokens** | Token management API | [CLI-TOKEN.md](references/CLI-TOKEN.md) |
| **AI Evaluation** | Document analysis, sign-off generation | [EVALUATION.md](references/EVALUATION.md) |
| **Price Intelligence** | RAG-based price queries, data sources | [PRICE-INTELLIGENCE.md](references/PRICE-INTELLIGENCE.md) |
| **Document Comparison** | Excel diff, BOQ comparison | [DOCUMENT-COMPARISON.md](references/DOCUMENT-COMPARISON.md) |
| **Project Management** | Projects, packages, BOQ items | [PROJECT.md](references/PROJECT.md) |
| **Submissions** | Tender submissions, evaluations | [SUBMISSION.md](references/SUBMISSION.md) |
| **Workflows** | End-to-end task examples | [WORKFLOWS.md](references/WORKFLOWS.md) |

---

## How to Use

### Step 1: Load the Helper Script

Source the API helper script for convenient functions:

```bash
source .claude/skills/tender-api/scripts/api.sh
```

### Step 2: Make API Calls

Use the helper functions:

```bash
# GET request
api_get "/project"

# POST request with JSON body
api_post "/agent/generate-evaluate" '{"prompt": "Analyze this document"}'

# PATCH request
api_patch "/project/123" '{"name": "Updated Name"}'

# DELETE request
api_delete "/cli-token/abc123"
```

### Step 3: Process Results

API responses are JSON. Use `jq` for parsing:

```bash
api_get "/project" | jq '.data[].name'
```

---

## Common Tasks

### Check Authentication
```bash
api_get "/auth/profile" | jq '.user'
```

### List Projects
```bash
api_get "/project?skip=0&take=25" | jq '.data'
```

### Query Price History
```bash
api_post "/price-history/query" '{"query": "cement price in Hanoi"}'
```

### Compare Excel Files
```bash
# Upload files first, then compare using file IDs
api_post "/excel-diff/v3/compare" '{"fileId1": "...", "fileId2": "..."}'
```

---

## API Response Format

### Paginated Lists
```json
{
  "data": [...],
  "total": 100
}
```

### Single Resource
```json
{
  "id": "uuid",
  "name": "Resource Name",
  ...
}
```

### Errors
```json
{
  "statusCode": 401,
  "message": "Unauthorized",
  "error": "Unauthorized"
}
```

---

## Troubleshooting

### Token Issues
- **"TENDER_CLI_TOKEN not set"**: Export your token: `export TENDER_CLI_TOKEN="tnd_..."`
- **"Invalid or expired CLI token"**: Generate a new token from the UI
- **"User account is not active"**: Contact administrator

### Connection Issues
- **"Connection refused"**: Ensure backend is running on correct port
- **"CORS error"**: Use backend URL directly, not through proxy

---

## Security Notes

- Never commit tokens to version control
- Token is tied to your user account with same permissions
- Revoke tokens immediately if compromised
- Use environment variables, not hardcoded values
