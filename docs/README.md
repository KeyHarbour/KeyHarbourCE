# Confluence Documentation Sync

This directory contains configuration for automatically syncing documentation to Confluence.

## Setup

### 1. Create Atlassian API Token

1. Go to [Atlassian Account Settings](https://id.atlassian.com/manage-profile/security/api-tokens)
2. Click "Create API token"
3. Name it "GitHub Actions - KeyHarbour Docs"
4. Copy the token

### 2. Add GitHub Secrets

Add these secrets to your repository (Settings > Secrets and variables > Actions):

| Secret | Description |
|--------|-------------|
| `CONFLUENCE_EMAIL` | Your Atlassian account email |
| `CONFLUENCE_API_TOKEN` | The API token from step 1 |

### 3. Configure Documents

Edit `confluence-sync.yml` to add or modify documents to sync:

```yaml
documents:
  - source: "MYFILE.md"           # Path relative to repo root
    title: "My Page Title"         # Title in Confluence
    parent: "Parent Page Name"     # Parent page (will be created if missing)
    labels:                        # Optional labels
      - "documentation"
```

## How It Works

1. On push to `main` branch (when `.md` files change), the workflow runs
2. The script reads `confluence-sync.yml` for document configuration
3. Markdown is converted to Confluence storage format
4. Pages are created or updated in the `docs` space

## Manual Sync

To manually sync all documents:

1. Go to Actions > "Sync Documentation to Confluence"
2. Click "Run workflow"
3. Check "Force sync all documents"
4. Click "Run workflow"

## Confluence Space Structure

```
docs (Space)
|-- Getting Started
|   |-- On-Premise Installation Guide
|   |-- Docker Quick Start
|-- Deployment
|   |-- Deployment Options
```

## Supported Markdown Features

- Headers (H1-H6)
- Code blocks with syntax highlighting
- Tables
- Lists (ordered and unordered)
- Links (relative links converted to GitHub URLs)
- Bold, italic, strikethrough
- Mermaid diagrams (requires Confluence app)

## Troubleshooting

### Authentication Errors

Verify your API token is correct and your email matches your Atlassian account.

### Permission Errors

Ensure your Atlassian account has edit permissions in the `docs` space.

### Page Not Updating

Check if the page title matches exactly. Confluence uses title as unique identifier.
