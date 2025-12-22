# CLI Token Authentication

This guide explains how to set up CLI token authentication for the Tender App API.

## Overview

CLI tokens allow you to authenticate with the Tender App API from command-line tools like Claude Code, scripts, and automation workflows without requiring interactive Microsoft login.

**Key features:**
- Long-lived tokens (optional expiry)
- Same permissions as your user account
- Revocable at any time
- Secure: tokens are hashed before storage

---

## Generating a Token

### Option 1: Via UI (Recommended)

1. Login to Tender App at `http://localhost:3001`
2. Navigate to **Settings > CLI Tokens**
3. Click **Generate New Token**
4. Enter a descriptive name (e.g., "Claude Code CLI")
5. Optionally set an expiration (1-365 days)
6. Click **Generate**
7. **Copy the token immediately** - it will only be shown once!

### Option 2: Via API

If you have a Microsoft token (from browser dev tools):

```bash
# Get Microsoft token from browser:
# 1. Open Tender App in browser
# 2. Open DevTools > Application > Local Storage
# 3. Find the msal token

MICROSOFT_TOKEN="eyJ0eXAiOiJKV1QiLCJub25jZSI..."

curl -X POST "http://localhost:3000/api/cli-token/generate" \
  -H "Authorization: Bearer ${MICROSOFT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"name": "Claude Code CLI"}'
```

Response:
```json
{
  "token": "tnd_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2",
  "tokenPrefix": "tnd_a1b2c3d4",
  "id": "uuid",
  "name": "Claude Code CLI",
  "message": "Save this token now. You will not be able to see it again."
}
```

---

## Setting Up the Token

### For Current Session

```bash
export TENDER_CLI_TOKEN="tnd_your_token_here"
```

### For Persistent Use

Add to your shell profile (`~/.bashrc`, `~/.zshrc`, or `~/.profile`):

```bash
# Tender App CLI Token
export TENDER_CLI_TOKEN="tnd_your_token_here"

# Optional: Override API URL
export TENDER_API_URL="http://localhost:3000/api"
```

Then reload:
```bash
source ~/.zshrc  # or ~/.bashrc
```

### For Claude Code Specifically

Create or edit `~/.claude/.env`:
```
TENDER_CLI_TOKEN=tnd_your_token_here
TENDER_API_URL=http://localhost:3000/api
```

---

## Verifying Authentication

```bash
# Source the helper script
source .claude/skills/tender-api/scripts/api.sh

# Check who you're authenticated as
api_whoami
```

Expected output:
```
Authenticated as:
{
  "id": "your-user-id",
  "email": "your@email.com",
  "displayName": "Your Name",
  "role": "ADMIN"
}
```

---

## Managing Tokens

### List Your Tokens

```bash
curl -X GET "http://localhost:3000/api/cli-token" \
  -H "Authorization: Bearer ${MICROSOFT_TOKEN}"
```

### Revoke a Token

```bash
curl -X DELETE "http://localhost:3000/api/cli-token/{token-id}" \
  -H "Authorization: Bearer ${MICROSOFT_TOKEN}"
```

---

## Token Format

CLI tokens follow this format:
```
tnd_<64-hex-characters>
```

Example:
```
tnd_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2
```

- Prefix `tnd_` identifies it as a Tender CLI token
- 64 hex characters (32 random bytes)
- Total length: 68 characters

---

## Security Best Practices

1. **Never commit tokens to git**
   - Add to `.gitignore`: `*.env.local`, `.env`

2. **Use environment variables**
   - Don't hardcode tokens in scripts

3. **Set expiration for shared machines**
   - Use 30-90 day expiry for tokens on shared systems

4. **Revoke compromised tokens immediately**
   - Use the UI or API to revoke

5. **Use descriptive names**
   - Name tokens by machine/purpose for easy management

---

## Troubleshooting

### "TENDER_CLI_TOKEN not set"

The environment variable is not configured:
```bash
export TENDER_CLI_TOKEN="tnd_your_token"
```

### "Invalid or expired CLI token"

- Token may have been revoked
- Token may have expired
- Generate a new token from the UI

### "User account is not active"

Your user account has been deactivated. Contact an administrator.

### "Connection refused"

The backend server is not running:
```bash
# Start the backend
cd packages/backend && pnpm dev
```

---

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/cli-token/generate` | Generate new token (requires Microsoft auth) |
| GET | `/cli-token` | List your tokens (requires Microsoft auth) |
| DELETE | `/cli-token/:id` | Revoke a token (requires Microsoft auth) |

Note: Token management endpoints require Microsoft authentication, not CLI token auth. This prevents privilege escalation.
