# Detailed Installation Guide for Tender API Plugin for Claude Code

## Introduction

The Tender API Plugin for Claude Code helps you interact with the Tender App system to manage construction tenders, including:
- Search for projects, tender packages, bidding documents
- Evaluate documents with AI
- Look up historical material prices
- Compare Excel BOQ files
- Manage projects and tender packages

## System Requirements

- **Claude Code**: Latest version
- **Operating System**: macOS, Linux, or Windows with WSL
- **Git**: To clone repository
- **Tender App Account**: To obtain authentication token

## Installation Methods

### Method 1: Install from GitHub Marketplace (Recommended)

This is the simplest and fastest way:

```bash
# Step 1: Add marketplace
/plugin marketplace add vulh1209/claude-tender-skill

# Step 2: Install plugin
/plugin install tender-api@tender-api-marketplace
```

**Advantages:**
- Auto-updates
- Easy management through Claude Code
- No need to clone repository

### Method 2: Clone directly to plugins directory

```bash
# Step 1: Create plugins directory if it doesn't exist
mkdir -p ~/.claude/plugins

# Step 2: Clone repository
git clone https://github.com/vulh1209/claude-tender-skill.git ~/.claude/plugins/tender-api

# Step 3: Set permissions for script
chmod +x ~/.claude/plugins/tender-api/scripts/api.sh
```

**Advantages:**
- Complete version control
- Can modify plugin code

### Method 3: Use Symlink for development

If you've cloned the repository elsewhere and want to develop:

```bash
# Step 1: Clone repository (if not already done)
cd ~/projects
git clone https://github.com/vulh1209/claude-tender-skill.git

# Step 2: Create symlink
ln -s ~/projects/claude-tender-skill ~/.claude/plugins/tender-api

# Step 3: Set permissions
chmod +x ~/projects/claude-tender-skill/scripts/api.sh
```

**Advantages:**
- Convenient for development
- Easy to update with git pull

### Method 4: Configure for specific project

Add to `.claude/settings.json` file in your project:

```json
{
  "plugins": [
    "/absolute/path/to/claude-tender-skill"
  ]
}
```

**Specific example:**
```json
{
  "plugins": [
    "/Users/username/projects/claude-tender-skill"
  ]
}
```

**Advantages:**
- Plugin only works in specific project
- Doesn't affect global Claude Code

### Method 5: Test plugin during development

```bash
# Run Claude Code with plugin directory
claude --plugin-dir ./claude-tender-skill

# Or with multiple plugins
claude --plugin-dir ./claude-tender-skill --plugin-dir ./another-plugin
```

**Advantages:**
- Quick testing without installation
- Suitable for development

## Authentication Configuration

### Step 1: Get CLI Token

1. **Open browser** and navigate to: https://tender.sipher.gg/cli-tokens

2. **Sign in** with Microsoft account (if prompted)

3. **Create new token:**
   - Click "Generate Token" button
   - Name your token (e.g., "Claude Code Plugin")
   - Copy the generated token (format: `tnd_xxxxxxxxxxxxx`)

4. **Important notes:**
   - Token is only shown once
   - Save token in a secure location
   - Don't share token with others

### Step 2: Configure environment variable

#### On macOS/Linux:

```bash
# Step 1: Open shell configuration file
nano ~/.zshrc  # For macOS with zsh
# or
nano ~/.bashrc # For Linux with bash

# Step 2: Add the following line at the end of file
export TENDER_CLI_TOKEN="tnd_your_token_here"

# Step 3: Save and exit
# Press Ctrl+X, then Y, then Enter

# Step 4: Reload configuration
source ~/.zshrc  # or source ~/.bashrc
```

#### On Windows (WSL):

```bash
# Similar to Linux
nano ~/.bashrc
export TENDER_CLI_TOKEN="tnd_your_token_here"
source ~/.bashrc
```

#### Optional configuration:

```bash
# Custom API URL (if needed)
export TENDER_API_URL="https://custom-api.example.com/api"

# Default is: https://tender-api.sipher.gg/api
```

### Step 3: Verify configuration

```bash
# Check token is set
echo $TENDER_CLI_TOKEN
# Output: tnd_xxxxxxxxxxxxx

# Check in Claude Code
/tender-api:tender-setup
```

## Installation Verification

### 1. Check plugin is recognized

In Claude Code, run:
```
/plugin list
```

You should see `tender-api` in the list.

### 2. Test basic command

```
/tender-api:tender-search "test"
```

### 3. Test API connection

Ask Claude:
```
"Check connection to Tender API"
```

## Using the Plugin

### Slash Commands

| Command | Description | Example |
|---------|-------------|---------|
| `/tender-api:tender-search` | Quick search | `/tender-api:tender-search "package 09/12"` |
| `/tender-api:tender-setup` | Check configuration | `/tender-api:tender-setup` |

### Natural Language

Plugin automatically activates when you ask about:

**Vietnamese examples:**
```
"Tìm tất cả dự án trong Tender App"
"Liệt kê các gói thầu của dự án ABC"
"Giá xi măng mới nhất là bao nhiêu?"
"So sánh 2 file Excel BOQ này"
"Đánh giá hồ sơ dự thầu của nhà thầu XYZ"
```

**English examples:**
```
"Search for package 09/12/2025"
"List all projects in Tender App"
"What are the latest cement prices?"
"Compare these two Excel files"
"Evaluate submission abc123"
```

## Common Error Troubleshooting

### Error: Plugin not recognized

**Causes and solutions:**

1. **Check path:**
   ```bash
   ls -la ~/.claude/plugins/tender-api/.claude-plugin/plugin.json
   ```
   
2. **Check JSON syntax:**
   ```bash
   cat ~/.claude/plugins/tender-api/.claude-plugin/plugin.json | jq .
   ```

3. **Restart Claude Code:**
   ```bash
   # Exit and reopen Claude Code
   ```

### Error: Token not found

**Solution:**

1. **Check environment variable:**
   ```bash
   echo $TENDER_CLI_TOKEN
   ```

2. **Check if config file was sourced:**
   ```bash
   source ~/.zshrc  # or ~/.bashrc
   ```

3. **Check for typos in token:**
   - Token must start with `tnd_`
   - No whitespace

### Error: Permission denied

**Solution:**
```bash
chmod +x ~/.claude/plugins/tender-api/scripts/api.sh
```

### Error: API connection failed

**Check:**

1. **Token is still valid:**
   - Go to https://tender.sipher.gg/cli-tokens
   - Check token is still active

2. **Internet connection:**
   ```bash
   ping tender-api.sipher.gg
   ```

3. **Firewall/Proxy:**
   - Check firewall allows HTTPS connections
   - Configure proxy if needed

## Plugin Directory Structure

```
claude-tender-skill/
├── .claude-plugin/
│   ├── plugin.json       # Plugin metadata (required)
│   └── marketplace.json  # Marketplace configuration
├── commands/             # Slash commands
│   ├── tender-search.md  # Search command
│   └── tender-setup.md   # Setup command
├── skills/               # Agent skills
│   └── tender-api/
│       └── SKILL.md      # Main skill definition
├── scripts/              # Support scripts
│   └── api.sh            # API call functions
├── references/           # API documentation
│   ├── AUTH.md           # Authentication guide
│   ├── CLI-TOKEN.md      # Token management
│   ├── EVALUATION.md     # AI evaluation
│   ├── PRICE-INTELLIGENCE.md  # Price lookup
│   ├── PROJECT.md        # Project management
│   ├── SUBMISSION.md     # Submission management
│   ├── DOCUMENT-COMPARISON.md # Document comparison
│   └── WORKFLOWS.md      # Workflow examples
├── LICENSE               # MIT License
├── CHANGELOG.md          # Version history
└── README.md             # Main documentation
```

## Security

### Best Practices:

1. **Don't commit tokens:**
   ```gitignore
   # .gitignore
   .env
   *token*
   ```

2. **Use environment variables:**
   - Always use `$TENDER_CLI_TOKEN`
   - Don't hardcode tokens in code

3. **Token management:**
   - Revoke token immediately if compromised
   - Create separate tokens for each environment
   - Set expiry date for tokens

4. **Permissions:**
   - Token inherits user permissions
   - Only grant necessary permissions

## Tips and Tricks

### 1. Create aliases for frequently used commands

```bash
# Add to ~/.zshrc or ~/.bashrc
alias tender-search="/tender-api:tender-search"
alias tender-setup="/tender-api:tender-setup"
```

### 2. Debug API calls

```bash
# Enable debug mode
export TENDER_DEBUG=true

# View detailed logs
tail -f ~/.claude/logs/tender-api.log
```

### 3. Update plugin

**If installed via marketplace:**
```
/plugin update tender-api@tender-api-marketplace
```

**If cloned repository:**
```bash
cd ~/.claude/plugins/tender-api
git pull origin main
```

### 4. Backup token

```bash
# Save to password manager
# or encrypted file
echo $TENDER_CLI_TOKEN | gpg -c > tender-token.gpg
```

## Support

### Report Issues
- GitHub Issues: https://github.com/vulh1209/claude-tender-skill/issues

### Documentation
- Main README: [README.md](README.md)
- API Reference: [references/](references/)
- Changelog: [CHANGELOG.md](CHANGELOG.md)

### Contact
- Author: vulh1209
- GitHub: https://github.com/vulh1209

## FAQ (Frequently Asked Questions)

**Q: Does the plugin work offline?**
A: No, the plugin needs internet connection to call Tender API.

**Q: Can I use multiple tokens at once?**
A: No, only supports 1 token at a time.

**Q: When does the token expire?**
A: Depends on admin configuration, usually 90 days.

**Q: Can I customize the API endpoint?**
A: Yes, use the `TENDER_API_URL` variable.

**Q: Does the plugin log requests?**
A: Yes, when `TENDER_DEBUG=true` is enabled.

## Conclusion

The Tender API Plugin provides powerful integration between Claude Code and the Tender App system. With this detailed guide, you can:
- Install the plugin in various ways
- Configure authentication securely
- Use all features fully
- Troubleshoot common errors

We hope you use the plugin effectively!