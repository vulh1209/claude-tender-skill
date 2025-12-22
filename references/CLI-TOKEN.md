# CLI Token API Reference

Manage CLI tokens for authentication with Tender API.

> **Note:** These endpoints require Microsoft authentication. You cannot create new tokens using an existing CLI token - this prevents privilege escalation.

## Authentication Flow

1. Go to **https://tender.sipher.gg/cli-tokens**
2. Authenticate via Microsoft if prompted
3. Generate a new CLI token
4. Copy and store the token securely
5. Use token for CLI/automation access

## Endpoints

### List My Tokens
Get all tokens for the current user.

```bash
# Requires Microsoft auth or existing CLI token
api_get "cli-token"
```

**Response:**
```json
[
  {
    "id": "uuid",
    "name": "Claude Code CLI",
    "tokenPrefix": "tnd_abc12345",
    "expiresAt": "2025-12-31T00:00:00.000Z",
    "lastUsedAt": "2025-12-22T10:30:00.000Z",
    "createdAt": "2025-12-01T00:00:00.000Z"
  }
]
```

### Generate New Token
Create a new CLI token. **Requires Microsoft authentication.**

```bash
# This endpoint ONLY works with Microsoft auth, not CLI token
curl -X POST "$API_URL/cli-token/generate" \
  -H "Authorization: Bearer <microsoft-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "My CLI Token",
    "expiresInDays": 90
  }'
```

**Request Body:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Descriptive name for the token |
| `expiresInDays` | number | No | Days until expiration (1-365). Omit for no expiration |

**Response:**
```json
{
  "id": "uuid",
  "name": "My CLI Token",
  "token": "tnd_abc123...full_token_here",
  "tokenPrefix": "tnd_abc12345",
  "expiresAt": "2026-03-22T00:00:00.000Z",
  "message": "Token generated successfully. Save this token now - you won't see it again!"
}
```

> **Important:** The full `token` value is only shown once. Copy and store it securely.

### Revoke Token
Revoke (delete) a CLI token. **Requires Microsoft authentication.**

```bash
# This endpoint ONLY works with Microsoft auth, not CLI token
curl -X DELETE "$API_URL/cli-token/<tokenId>" \
  -H "Authorization: Bearer <microsoft-token>"
```

**Response:** `204 No Content`

### Verify Token (Who Am I)
Check current token validity and user info.

```bash
api_whoami
# or
api_get "auth/me"
```

## Token Format

- Prefix: `tnd_` (identifies as Tender CLI token)
- Full format: `tnd_<64-hex-characters>`
- Example: `tnd_a1b2c3d4e5f6789...`

## Security Notes

1. **One-time reveal**: Full token is only shown once upon creation
2. **Hashed storage**: Only SHA-256 hash is stored in database
3. **Prefix identification**: `tokenPrefix` helps identify tokens without revealing them
4. **No privilege escalation**: Cannot create new tokens using CLI token auth
5. **User-scoped**: Each user manages their own tokens

## Usage in Scripts

```bash
# Set environment variable
export TENDER_CLI_TOKEN="tnd_your_token_here"

# Source the API helper
source .claude/skills/tender-api/scripts/api.sh

# Verify connection
api_whoami

# Make API calls
api_get "project"
api_get "packages?projectId=<uuid>"
```

## Best Practices

1. **Use descriptive names**: "Claude Code - Dev Machine", "CI/CD Pipeline"
2. **Set expiration for temporary access**: Use `expiresInDays` for contractors
3. **Rotate regularly**: Create new tokens and revoke old ones periodically
4. **Don't share tokens**: Each user/service should have its own token
5. **Revoke immediately if compromised**: Use web UI to revoke leaked tokens
