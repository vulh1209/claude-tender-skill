---
description: Set up Tender API authentication and verify connection
allowed-tools: Bash, Read
---

# Tender Setup Command

Set up authentication for Tender API.

## Instructions

1. Check current authentication status:
   ```bash
   if [ -n "$TENDER_CLI_TOKEN" ]; then
     echo "Token is set: ${TENDER_CLI_TOKEN:0:12}..."
     source ${CLAUDE_PLUGIN_ROOT}/scripts/api.sh
     api_whoami
   else
     echo "Token is NOT set"
   fi
   ```

2. If token is not set or invalid, guide user:

   **Step 1:** Go to https://tender.sipher.gg/cli-tokens

   **Step 2:** Login with Microsoft account if prompted

   **Step 3:** Click "Generate Token" to create a new CLI token

   **Step 4:** Copy the token and run:
   ```bash
   export TENDER_CLI_TOKEN="tnd_your_token_here"
   ```

   **Step 5:** Add to shell profile for persistence:
   ```bash
   echo 'export TENDER_CLI_TOKEN="tnd_your_token_here"' >> ~/.zshrc
   ```

3. Verify authentication:
   ```bash
   source ${CLAUDE_PLUGIN_ROOT}/scripts/api.sh
   api_whoami
   ```

## Token Format

Valid tokens start with `tnd_` prefix, e.g.:
```
tnd_d6cce96905a917b2554fda97843c23376e0a46754e91c7cd162ef52ad56e21c8
```

## Troubleshooting

- **"Invalid or expired CLI token"**: Generate a new token from the UI
- **"User account is not active"**: Contact administrator
- **Token not persisting**: Make sure to add export to shell profile
