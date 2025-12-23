---
name: tender-api
description: "Interact with Tender App backend APIs for construction tender management. Actions: global search (projects/packages/submissions/contractors), evaluate documents with AI, query price history with RAG, compare Excel files. Use when user asks to find/search/list projects, packages, submissions, contractors, or needs tender evaluation, price intelligence, document comparison."
allowed-tools: Bash, Read, Grep, Glob
---

# Tender API Skill

Enables Claude Code to interact with the Tender App backend APIs for construction tender management.

## Prerequisites

### Environment Variables

```bash
# Required: Your CLI token from https://tender.sipher.gg/cli-tokens
export TENDER_CLI_TOKEN="tnd_your_token_here"

# Optional: Override API URL (default: https://tender-api.sipher.gg/api)
export TENDER_API_URL="https://tender-api.sipher.gg/api"
```

### Load API Helper

Before making API calls, source the helper script:

```bash
source ${CLAUDE_PLUGIN_ROOT}/scripts/api.sh
```

---

## Key Concepts

### PERFECT IDEAL Contractor
"PERFECT IDEAL" is a **system-generated virtual contractor**, NOT a real contractor. Key points:
- Created automatically by the system for each package
- Represents the ideal/baseline submission based on the original BOQ (Bill of Quantities)
- Used as a reference point for comparing actual contractor submissions
- When you see `perfectIdeal` in API responses, it refers to this system-generated baseline
- Do NOT treat it as an actual contractor when analyzing or reporting data

---

## Quick Reference

| Category | Use Case | Reference |
|----------|----------|-----------|
| **Authentication** | CLI token setup, verification | [AUTH.md](${CLAUDE_PLUGIN_ROOT}/references/AUTH.md) |
| **CLI Tokens** | Token management API | [CLI-TOKEN.md](${CLAUDE_PLUGIN_ROOT}/references/CLI-TOKEN.md) |
| **AI Evaluation** | Document analysis, sign-off generation | [EVALUATION.md](${CLAUDE_PLUGIN_ROOT}/references/EVALUATION.md) |
| **Price Intelligence** | RAG-based price queries, data sources | [PRICE-INTELLIGENCE.md](${CLAUDE_PLUGIN_ROOT}/references/PRICE-INTELLIGENCE.md) |
| **Document Comparison** | Excel diff, BOQ comparison | [DOCUMENT-COMPARISON.md](${CLAUDE_PLUGIN_ROOT}/references/DOCUMENT-COMPARISON.md) |
| **Project Management** | Projects, packages, BOQ items | [PROJECT.md](${CLAUDE_PLUGIN_ROOT}/references/PROJECT.md) |
| **Submissions** | Tender submissions, evaluations | [SUBMISSION.md](${CLAUDE_PLUGIN_ROOT}/references/SUBMISSION.md) |
| **Workflows** | End-to-end task examples | [WORKFLOWS.md](${CLAUDE_PLUGIN_ROOT}/references/WORKFLOWS.md) |

---

## API Helper Functions

### Basic HTTP Methods

```bash
# GET request
api_get "/endpoint"

# POST request with JSON body
api_post "/endpoint" '{"key": "value"}'

# PUT request
api_put "/endpoint" '{"key": "value"}'

# PATCH request
api_patch "/endpoint" '{"key": "value"}'

# DELETE request
api_delete "/endpoint"
```

### File Operations

```bash
# Upload file
api_upload "/endpoint" "fieldname" "/path/to/file"

# Download file
api_download "/endpoint" "/path/to/save"
```

### Utility Functions

```bash
# Check API health
api_health

# Check authentication
api_whoami
```

---

## Global Search

### Search Across All Entities

```bash
# Using the global-search API endpoint (recommended)
api_get "/global-search?search=keyword&skip=0&take=20"

# URL encode special characters: / -> %2F, space -> %20
api_get "/global-search?search=09%2F12%2F2025&skip=0&take=20"
```

### Search Helper Functions

```bash
# Search everything
global_search "highway"

# Search by entity type
search_projects "construction"
search_packages "electrical" [projectId]
search_submissions "ABC Corp" [packageId]
search_contractors "company name"
```

### Quick Lookup by ID

```bash
get_project_details "project-uuid"
get_package_details "package-uuid"
get_submission_details "submission-uuid"
get_contractor_details "contractor-uuid"
```

### List All

```bash
list_projects [take]      # Default: 25
list_contractors [take]   # Default: 50
```

---

## Common API Endpoints

### Projects

```bash
# List projects
api_get "/project?skip=0&take=25"

# Get single project
api_get "/project/<id>"

# Create project
api_post "/project" '{"name": "Project Name", "description": "..."}'

# Update project
api_patch "/project/<id>" '{"name": "Updated Name"}'

# Delete project
api_delete "/project/<id>"
```

### Packages

```bash
# List packages for a project
api_get "/packages?projectId=<uuid>"

# Get single package
api_get "/packages/<id>"

# Create package
api_post "/packages" '{"projectId": "<uuid>", "name": "Package Name"}'
```

### Submissions

```bash
# List submissions for a package
api_get "/submission?packageId=<uuid>"

# Get submission details
api_get "/submission/<id>"
```

### AI Evaluation

```bash
# Generate evaluation
api_post "/agent/generate-evaluate" '{"prompt": "Analyze this document"}'
```

### Price Intelligence

```bash
# Query price history
api_post "/price-history/query" '{"query": "cement price in Hanoi"}'
```

### Document Comparison

```bash
# Compare Excel files
api_post "/excel-diff/v3/compare" '{"fileId1": "...", "fileId2": "..."}'
```

---

## Response Format

### Paginated Lists

```json
{
  "success": true,
  "data": [...],
  "total": 100
}
```

### Single Resource

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "Resource Name"
  }
}
```

### Global Search Results

```json
{
  "success": true,
  "data": [
    {"id": "uuid", "name": "Package Name", "type": "package"},
    {"id": "uuid", "name": "Project Name", "type": "project"}
  ],
  "total": 7
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
- **"Invalid or expired CLI token"**: Generate a new token from https://tender.sipher.gg/cli-tokens
- **"User account is not active"**: Contact administrator

### Connection Issues

- **"Connection refused"**: Check API URL and network
- **"CORS error"**: Use backend URL directly

---

## Security Notes

- Never commit tokens to version control
- Token is tied to your user account with same permissions
- Revoke tokens immediately if compromised
- Use environment variables, not hardcoded values
