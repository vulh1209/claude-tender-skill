---
name: tender-search
description: Quick search across Tender App entities
allowed-tools: Bash, Read
arguments:
  - name: query
    description: Search keyword (e.g., "highway", "09/12/2025", "ABC Corp")
    required: true
---

# Tender Search Command

Search across all Tender App entities (projects, packages, submissions, contractors).

## Instructions

1. First, check if TENDER_CLI_TOKEN is set:
   ```bash
   echo "Token: ${TENDER_CLI_TOKEN:0:12}..."
   ```

2. If token is not set, instruct user to run:
   ```bash
   export TENDER_CLI_TOKEN="tnd_your_token_here"
   ```

3. Source the API helper and perform global search:
   ```bash
   source ${CLAUDE_PLUGIN_ROOT}/scripts/api.sh

   # URL encode the query (replace / with %2F, space with %20)
   api_get "/global-search?search=<encoded_query>&skip=0&take=20" | jq '.'
   ```

4. Format results in a readable table showing:
   - Type (project/package/submission/contractor)
   - Name
   - ID

## Example

User: `/tender-search "09/12/2025"`

Response:
```
Found 7 results for "09/12/2025":

| Type       | Name                                    | ID          |
|------------|----------------------------------------|-------------|
| package    | 09/12/2025                             | 221ca40e... |
| submission | REV1-SUB_EDENID_01_09/12/2025_...      | 01c5af1d... |
...
```
