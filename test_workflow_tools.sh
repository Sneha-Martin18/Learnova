#!/bin/bash

# Test script to verify workflow viewing tools are working

echo "=========================================="
echo "Testing Workflow Viewing Tools"
echo "=========================================="
echo ""

# Test 1: Check if scripts exist
echo "✓ Test 1: Checking if scripts exist..."
if [ -f "view_workflow_summary.sh" ]; then
    echo "  ✅ view_workflow_summary.sh exists"
else
    echo "  ❌ view_workflow_summary.sh NOT found"
fi

if [ -f "workflow_status_dashboard.py" ]; then
    echo "  ✅ workflow_status_dashboard.py exists"
else
    echo "  ❌ workflow_status_dashboard.py NOT found"
fi

if [ -f "view_cicd_workflows.sh" ]; then
    echo "  ✅ view_cicd_workflows.sh exists"
else
    echo "  ❌ view_cicd_workflows.sh NOT found"
fi

echo ""

# Test 2: Check if scripts are executable
echo "✓ Test 2: Checking if scripts are executable..."
if [ -x "view_workflow_summary.sh" ]; then
    echo "  ✅ view_workflow_summary.sh is executable"
else
    echo "  ⚠️  view_workflow_summary.sh is NOT executable"
    echo "     Run: chmod +x view_workflow_summary.sh"
fi

if [ -x "workflow_status_dashboard.py" ]; then
    echo "  ✅ workflow_status_dashboard.py is executable"
else
    echo "  ⚠️  workflow_status_dashboard.py is NOT executable"
    echo "     Run: chmod +x workflow_status_dashboard.py"
fi

echo ""

# Test 3: Check if gh CLI is installed
echo "✓ Test 3: Checking GitHub CLI installation..."
if command -v gh &> /dev/null; then
    GH_VERSION=$(gh --version | head -1)
    echo "  ✅ GitHub CLI installed: $GH_VERSION"
else
    echo "  ❌ GitHub CLI NOT installed"
    echo "     Install with: sudo apt install gh"
    exit 1
fi

echo ""

# Test 4: Check gh authentication
echo "✓ Test 4: Checking GitHub CLI authentication..."
if gh auth status &> /dev/null; then
    echo "  ✅ GitHub CLI is authenticated"
    gh auth status 2>&1 | grep "Logged in"
else
    echo "  ❌ GitHub CLI is NOT authenticated"
    echo "     Run: gh auth login"
    echo ""
    echo "  📝 Authentication Steps:"
    echo "     1. Run: gh auth login"
    echo "     2. Select: GitHub.com"
    echo "     3. Select: HTTPS"
    echo "     4. Select: Login with a web browser"
    echo "     5. Copy the one-time code"
    echo "     6. Press Enter to open browser"
    echo "     7. Paste code and authorize"
    exit 1
fi

echo ""

# Test 5: Check if repository is connected to GitHub
echo "✓ Test 5: Checking GitHub repository connection..."
if git remote -v | grep -q "github.com"; then
    REPO_URL=$(git remote get-url origin 2>/dev/null || echo "Not set")
    echo "  ✅ Repository connected to GitHub"
    echo "     Remote: $REPO_URL"
else
    echo "  ⚠️  Repository NOT connected to GitHub"
    echo "     This is a local repository only"
    echo ""
    echo "  📝 To connect to GitHub:"
    echo "     1. Create a repository on GitHub"
    echo "     2. Run: git remote add origin https://github.com/USERNAME/REPO.git"
    echo "     3. Run: git push -u origin main"
fi

echo ""

# Test 6: Check for workflow runs
echo "✓ Test 6: Checking for workflow runs..."
WORKFLOW_COUNT=$(gh run list --limit 1 2>/dev/null | wc -l)
if [ "$WORKFLOW_COUNT" -gt 1 ]; then
    echo "  ✅ Workflow runs found"
    echo ""
    echo "  Latest workflow run:"
    gh run list --limit 1
else
    echo "  ⚠️  No workflow runs found"
    echo "     Workflows will appear after:"
    echo "     1. Push code to GitHub"
    echo "     2. Create a pull request"
    echo "     3. Workflow is triggered automatically"
fi

echo ""

# Test 7: Check Python installation
echo "✓ Test 7: Checking Python installation..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo "  ✅ Python installed: $PYTHON_VERSION"
else
    echo "  ❌ Python3 NOT installed"
    echo "     Install with: sudo apt install python3"
fi

echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo ""

# Determine overall status
if command -v gh &> /dev/null && gh auth status &> /dev/null; then
    echo "✅ All prerequisites met!"
    echo ""
    echo "🚀 You can now use:"
    echo "   ./view_workflow_summary.sh"
    echo "   python3 workflow_status_dashboard.py"
    echo "   ./view_cicd_workflows.sh"
    echo ""
    echo "📖 Read the guide:"
    echo "   cat UNIFIED_WORKFLOW_VIEW_GUIDE.md"
else
    echo "⚠️  Setup required"
    echo ""
    echo "📝 Next steps:"
    if ! command -v gh &> /dev/null; then
        echo "   1. Install GitHub CLI: sudo apt install gh"
    fi
    if ! gh auth status &> /dev/null; then
        echo "   2. Authenticate: gh auth login"
    fi
    if ! git remote -v | grep -q "github.com"; then
        echo "   3. Connect to GitHub repository"
    fi
fi

echo ""
