# Tender API Skill for Claude Code

A Claude Code skill that enables interaction with Tender App backend APIs for construction tender management.

## Features

- **AI Evaluation**: Analyze documents, generate sign-offs
- **Price Intelligence**: RAG-based price queries, historical data
- **Document Comparison**: Excel diff, BOQ comparison
- **Project Management**: Projects, packages, BOQ items
- **Submissions**: Tender submissions, evaluations

## Quick Install

```bash
git clone https://github.com/vulh1209/claude-tender-skill.git ~/.claude/skills/tender-api
```

## Setup

### 1. Get a CLI Token

1. Go to **https://tender.sipher.gg/cli-tokens**
2. Login with Microsoft if prompted
3. Click **Generate Token**
4. Copy the token

### 2. Configure Environment

Add to your shell profile (`~/.zshrc` or `~/.bashrc`):

```bash
export TENDER_CLI_TOKEN="tnd_your_token_here"
```

Then reload:

```bash
source ~/.zshrc
```

### 3. Verify Installation

Open Claude Code and ask:

```
"Check if Tender API is configured correctly"
```

## Usage Examples

### List Projects

```
"List all projects in Tender App"
```

### Query Price History

```
"What are the latest cement prices from price history?"
```

### Evaluate Submission

```
"Evaluate submission abc123 for package xyz"
```

### Compare Documents

```
"Compare these two Excel files for BOQ differences"
```

## Directory Structure

```
claude-tender-skill/
├── SKILL.md              # Main skill definition (required)
├── README.md             # This file
├── scripts/
│   └── api.sh            # Helper functions for API calls
└── references/
    ├── AUTH.md           # Authentication guide
    ├── CLI-TOKEN.md      # Token management API
    ├── EVALUATION.md     # AI evaluation endpoints
    ├── PRICE-INTELLIGENCE.md  # RAG price queries
    ├── PROJECT.md        # Project management
    ├── SUBMISSION.md     # Submission handling
    ├── DOCUMENT-COMPARISON.md # Excel diff
    └── WORKFLOWS.md      # End-to-end examples
```

## API Reference

| Category | Description | Reference |
|----------|-------------|-----------|
| Authentication | CLI token setup | [AUTH.md](references/AUTH.md) |
| CLI Tokens | Token management | [CLI-TOKEN.md](references/CLI-TOKEN.md) |
| AI Evaluation | Document analysis | [EVALUATION.md](references/EVALUATION.md) |
| Price Intelligence | RAG queries | [PRICE-INTELLIGENCE.md](references/PRICE-INTELLIGENCE.md) |
| Projects | Project management | [PROJECT.md](references/PROJECT.md) |
| Submissions | Tender submissions | [SUBMISSION.md](references/SUBMISSION.md) |
| Document Comparison | Excel diff | [DOCUMENT-COMPARISON.md](references/DOCUMENT-COMPARISON.md) |

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `TENDER_CLI_TOKEN` | Yes | Your CLI authentication token |
| `TENDER_API_URL` | No | API base URL (default: `https://tender-api.sipher.gg/api`) |

## Troubleshooting

### Token Not Found

```bash
# Verify token is set
echo $TENDER_CLI_TOKEN
# Should output: tnd_xxxxx...
```

### Permission Denied on Script

```bash
chmod +x ~/.claude/skills/tender-api/scripts/api.sh
```

### Skill Not Detected

1. Verify skill location: `ls ~/.claude/skills/tender-api/SKILL.md`
2. Restart Claude Code session

## Security

- Never commit tokens to version control
- Token inherits your user permissions
- Revoke tokens immediately if compromised
- Use environment variables, not hardcoded values

## License

MIT License
