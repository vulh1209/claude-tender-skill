# Tender API Plugin for Claude Code

A Claude Code plugin that enables interaction with Tender App backend APIs for construction tender management.

## Features

- **Global Search**: Search across projects, packages, submissions, contractors
- **AI Evaluation**: Analyze documents, generate sign-offs
- **Price Intelligence**: RAG-based price queries, historical data
- **Document Comparison**: Excel diff, BOQ comparison
- **Project Management**: Projects, packages, BOQ items
- **Submissions**: Tender submissions, evaluations

## Installation

### Option 1: Clone to plugins directory (Recommended)

```bash
# Clone directly to Claude Code plugins
git clone https://github.com/vulh1209/claude-tender-skill.git ~/.claude/plugins/tender-api
```

### Option 2: Symlink from development location

```bash
# If you have the repo elsewhere, create a symlink
ln -s /path/to/claude-tender-skill ~/.claude/plugins/tender-api
```

### Option 3: Add to project-specific plugins

Add to your project's `.claude/settings.json`:

```json
{
  "plugins": [
    "/path/to/claude-tender-skill"
  ]
}
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

Open Claude Code and run:

```
/tender-setup
```

Or ask:

```
"Check if Tender API is configured correctly"
```

## Usage

### Slash Commands

| Command | Description |
|---------|-------------|
| `/tender-search "keyword"` | Quick search across all entities |
| `/tender-setup` | Set up authentication |

### Natural Language

The `tender-api` skill is automatically triggered when you ask about:

- Finding/searching projects, packages, submissions
- Tender evaluation or document analysis
- Price intelligence queries
- Document comparison

**Examples:**

```
"Search for package 09/12/2025"
"List all projects in Tender App"
"What are the latest cement prices from price history?"
"Evaluate submission abc123 for package xyz"
"Compare these two Excel files for BOQ differences"
```

## Directory Structure

```
tender-api/
├── plugin.json           # Plugin manifest
├── README.md             # This file
├── SKILL.md              # Legacy skill definition
├── skills/
│   └── tender-api.md     # Main skill
├── commands/
│   ├── tender-search.md  # /tender-search command
│   └── tender-setup.md   # /tender-setup command
├── scripts/
│   └── api.sh            # API helper functions
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

### Plugin Not Detected

1. Verify plugin location: `ls ~/.claude/plugins/tender-api/plugin.json`
2. Restart Claude Code session
3. Check plugin.json syntax is valid JSON

### Token Not Found

```bash
# Verify token is set
echo $TENDER_CLI_TOKEN
# Should output: tnd_xxxxx...
```

### Skill Not Triggering

Make sure you have sourced the API helper:
```bash
source ~/.claude/plugins/tender-api/scripts/api.sh
```

### Permission Denied on Script

```bash
chmod +x ~/.claude/plugins/tender-api/scripts/api.sh
```

## Security

- Never commit tokens to version control
- Token inherits your user permissions
- Revoke tokens immediately if compromised
- Use environment variables, not hardcoded values

## License

MIT License
