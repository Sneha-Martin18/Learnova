#!/bin/bash

echo "=========================================="
echo "GitHub Actions Workflow Checker"
echo "=========================================="
echo ""

# Check if workflows exist
echo "📁 Checking workflow files..."
WORKFLOW_COUNT=$(find .github/workflows -name "*.yml" -o -name "*.yaml" | wc -l)
echo "Found $WORKFLOW_COUNT workflow files:"
find .github/workflows -name "*.yml" -o -name "*.yaml" | while read file; do
    echo "  ✅ $file"
done
echo ""

# Check if pushed to GitHub
echo "🔍 Checking Git status..."
if git diff --quiet HEAD origin/main 2>/dev/null; then
    echo "✅ Local branch is in sync with origin/main"
else
    echo "⚠️  Local changes not pushed or branches diverged"
fi
echo ""

# Repository info
echo "📊 Repository Information:"
REPO_URL=$(git remote get-url origin 2>/dev/null)
echo "  Remote: $REPO_URL"
echo "  Branch: $(git branch --show-current)"
echo "  Latest commit: $(git log -1 --oneline)"
echo ""

# Extract GitHub repo details
if [[ $REPO_URL =~ github.com[:/]([^/]+)/([^/.]+) ]]; then
    OWNER="${BASH_REMATCH[1]}"
    REPO="${BASH_REMATCH[2]}"

    echo "🔗 Direct Links:"
    echo "  Actions: https://github.com/$OWNER/$REPO/actions"
    echo "  Workflows: https://github.com/$OWNER/$REPO/actions/workflows"
    echo "  Main Pipeline: https://github.com/$OWNER/$REPO/actions/workflows/microservices-ci-cd.yml"
    echo ""

    # Try to open in browser
    echo "🌐 Opening GitHub Actions in browser..."
    xdg-open "https://github.com/$OWNER/$REPO/actions" 2>/dev/null || \
    open "https://github.com/$OWNER/$REPO/actions" 2>/dev/null || \
    echo "  Please open: https://github.com/$OWNER/$REPO/actions"
else
    echo "⚠️  Could not parse GitHub repository URL"
fi

echo ""
echo "=========================================="
echo "💡 Troubleshooting Tips:"
echo "=========================================="
echo ""
echo "If you don't see workflows in GitHub Actions:"
echo ""
echo "1. Wait a few seconds - workflows may take time to appear"
echo "2. Refresh the GitHub Actions page"
echo "3. Check if workflows are enabled in repository settings:"
echo "   Settings → Actions → General → Allow all actions"
echo ""
echo "4. Verify workflow syntax:"
for workflow in .github/workflows/*.yml; do
    echo "   Checking $workflow..."
    if command -v yamllint &> /dev/null; then
        yamllint "$workflow" 2>&1 | head -3
    else
        echo "   (Install yamllint for syntax checking: pip install yamllint)"
    fi
done
echo ""
echo "5. Check workflow runs with GitHub CLI:"
echo "   gh run list --limit 5"
echo "   gh workflow list"
echo ""
echo "=========================================="
