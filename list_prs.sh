#!/bin/bash

# Script to list and analyze all open pull requests
# This helps identify which PRs to keep or close

echo "=========================================="
echo "Pull Request Analysis Tool"
echo "=========================================="
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed."
    echo "Install it with: sudo apt install gh"
    echo "Or visit: https://cli.github.com/"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub CLI"
    echo "Run: gh auth login"
    exit 1
fi

echo "📊 Fetching all open pull requests..."
echo ""

# Get total count
TOTAL_PRS=$(gh pr list --state open --json number --jq 'length')
echo "Total Open PRs: $TOTAL_PRS"
echo ""

if [ "$TOTAL_PRS" -eq 0 ]; then
    echo "✅ No open pull requests found!"
    exit 0
fi

# List all PRs with details
echo "=========================================="
echo "All Open Pull Requests:"
echo "=========================================="
gh pr list --state open --limit 100 --json number,title,author,createdAt,headRefName,updatedAt \
    --template '{{range .}}PR #{{.number}} | {{.title}}
  Author: {{.author.login}}
  Branch: {{.headRefName}}
  Created: {{.createdAt}}
  Updated: {{.updatedAt}}
  ---
{{end}}'

echo ""
echo "=========================================="
echo "PRs by Age:"
echo "=========================================="

# List old PRs (older than 30 days)
echo "🕐 PRs older than 30 days:"
gh pr list --state open --limit 100 --json number,title,createdAt \
    --jq '.[] | select(.createdAt | fromdateiso8601 < (now - 2592000)) | "PR #\(.number): \(.title)"'

echo ""
echo "🕑 PRs older than 7 days:"
gh pr list --state open --limit 100 --json number,title,createdAt \
    --jq '.[] | select(.createdAt | fromdateiso8601 < (now - 604800)) | "PR #\(.number): \(.title)"'

echo ""
echo "=========================================="
echo "Summary:"
echo "=========================================="
echo "Total Open PRs: $TOTAL_PRS"

OLD_30=$(gh pr list --state open --limit 100 --json createdAt --jq '[.[] | select(.createdAt | fromdateiso8601 < (now - 2592000))] | length')
OLD_7=$(gh pr list --state open --limit 100 --json createdAt --jq '[.[] | select(.createdAt | fromdateiso8601 < (now - 604800))] | length')
RECENT=$(gh pr list --state open --limit 100 --json createdAt --jq '[.[] | select(.createdAt | fromdateiso8601 >= (now - 604800))] | length')

echo "  - Older than 30 days: $OLD_30"
echo "  - Older than 7 days: $OLD_7"
echo "  - Recent (< 7 days): $RECENT"
echo ""

echo "💡 Next Steps:"
echo "  1. Review the list above"
echo "  2. Run './bulk_close_prs.sh' to close old PRs"
echo "  3. Or manually close PRs: gh pr close <number>"
echo ""
