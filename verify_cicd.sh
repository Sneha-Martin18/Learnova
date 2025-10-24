#!/bin/bash

echo "=========================================="
echo "CI/CD Pipeline Verification"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "📊 Checking CI/CD Status..."
echo ""

# 1. Check if workflows exist
echo "1️⃣  Checking workflow files..."
WORKFLOW_FILES=$(find .github/workflows -name "*.yml" 2>/dev/null | wc -l)
if [ "$WORKFLOW_FILES" -gt 0 ]; then
    echo -e "${GREEN}✅ Found $WORKFLOW_FILES workflow files${NC}"
    find .github/workflows -name "*.yml" | while read file; do
        echo "   - $(basename $file)"
    done
else
    echo -e "${RED}❌ No workflow files found${NC}"
    exit 1
fi
echo ""

# 2. Check if code is pushed
echo "2️⃣  Checking Git status..."
LATEST_COMMIT=$(git log -1 --oneline)
echo "   Latest commit: $LATEST_COMMIT"

if git diff --quiet HEAD origin/main 2>/dev/null; then
    echo -e "${GREEN}✅ Code is pushed to GitHub${NC}"
else
    echo -e "${YELLOW}⚠️  Local changes detected or not pushed${NC}"
fi
echo ""

# 3. Repository information
echo "3️⃣  Repository Information..."
REPO_URL=$(git remote get-url origin 2>/dev/null)
echo "   Remote: $REPO_URL"

if [[ $REPO_URL =~ github.com[:/]([^/]+)/([^/.]+) ]]; then
    OWNER="${BASH_REMATCH[1]}"
    REPO="${BASH_REMATCH[2]}"
    echo -e "${GREEN}✅ GitHub repository detected${NC}"
    echo "   Owner: $OWNER"
    echo "   Repo: $REPO"
else
    echo -e "${RED}❌ Not a GitHub repository${NC}"
    exit 1
fi
echo ""

# 4. Check workflow syntax
echo "4️⃣  Validating workflow syntax..."
SYNTAX_OK=true
for workflow in .github/workflows/*.yml; do
    if [ -f "$workflow" ]; then
        # Basic YAML syntax check
        if python3 -c "import yaml; yaml.safe_load(open('$workflow'))" 2>/dev/null; then
            echo -e "${GREEN}✅ $(basename $workflow) - Valid YAML${NC}"
        else
            echo -e "${RED}❌ $(basename $workflow) - Invalid YAML${NC}"
            SYNTAX_OK=false
        fi
    fi
done
echo ""

# 5. Check GitHub Actions status
echo "5️⃣  Checking GitHub Actions status..."
echo ""
echo "🔗 Direct Links:"
echo "   Actions: https://github.com/$OWNER/$REPO/actions"
echo "   Main Pipeline: https://github.com/$OWNER/$REPO/actions/workflows/microservices-ci-cd.yml"
echo ""

# 6. Try to get workflow status via GitHub CLI
echo "6️⃣  Fetching workflow runs (if gh CLI is authenticated)..."
if command -v gh &> /dev/null; then
    if gh auth status &> /dev/null; then
        echo ""
        echo "Recent workflow runs:"
        gh run list --limit 5 2>/dev/null || echo "   Unable to fetch runs (authentication may be needed)"
        echo ""

        echo "Available workflows:"
        gh workflow list 2>/dev/null || echo "   Unable to fetch workflows"
    else
        echo -e "${YELLOW}⚠️  GitHub CLI not authenticated${NC}"
        echo "   Run: gh auth login"
    fi
else
    echo -e "${YELLOW}⚠️  GitHub CLI not installed${NC}"
    echo "   Install: sudo apt install gh"
fi
echo ""

# 7. Summary
echo "=========================================="
echo "📋 Summary"
echo "=========================================="
echo ""

if [ "$WORKFLOW_FILES" -gt 0 ] && [ "$SYNTAX_OK" = true ]; then
    echo -e "${GREEN}✅ CI/CD is properly configured!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Open GitHub Actions: https://github.com/$OWNER/$REPO/actions"
    echo "2. You should see workflow runs from your latest push"
    echo "3. Click on a workflow run to see detailed logs"
    echo ""
    echo "If you don't see any runs:"
    echo "- Wait 10-30 seconds for GitHub to process the push"
    echo "- Refresh the page"
    echo "- Check Settings → Actions → General (ensure Actions are enabled)"
else
    echo -e "${RED}❌ CI/CD configuration has issues${NC}"
    echo "Please fix the errors above"
fi

echo ""
echo "🌐 Opening GitHub Actions in browser..."
xdg-open "https://github.com/$OWNER/$REPO/actions" 2>/dev/null || \
open "https://github.com/$OWNER/$REPO/actions" 2>/dev/null || \
echo "Please open: https://github.com/$OWNER/$REPO/actions"

echo ""
echo "=========================================="
