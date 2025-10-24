#!/bin/bash

# Script to view CI/CD workflow runs directly
# This bypasses the PR view and shows workflow status

echo "=========================================="
echo "CI/CD Workflow Viewer"
echo "=========================================="
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed."
    echo "Install it with: sudo apt install gh"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub CLI"
    echo "Run: gh auth login"
    exit 1
fi

# Function to list workflow runs
list_workflows() {
    echo "📊 Recent CI/CD Workflow Runs:"
    echo "=========================================="
    gh run list --workflow=ci-cd.yml --limit 20
    echo ""
}

# Function to view specific workflow
view_workflow() {
    read -p "Enter workflow run ID: " run_id
    echo ""
    gh run view $run_id
}

# Function to watch workflow in real-time
watch_workflow() {
    echo "🔄 Watching latest workflow run..."
    gh run watch
}

# Function to view workflow logs
view_logs() {
    read -p "Enter workflow run ID: " run_id
    echo ""
    gh run view $run_id --log
}

# Function to list by branch
list_by_branch() {
    read -p "Enter branch name (e.g., main, develop): " branch
    echo ""
    echo "📊 Workflow runs for branch: $branch"
    gh run list --workflow=ci-cd.yml --branch $branch --limit 20
}

# Function to list failed runs
list_failed() {
    echo "❌ Failed Workflow Runs:"
    echo "=========================================="
    gh run list --workflow=ci-cd.yml --status failure --limit 20
    echo ""
}

# Function to list successful runs
list_successful() {
    echo "✅ Successful Workflow Runs:"
    echo "=========================================="
    gh run list --workflow=ci-cd.yml --status success --limit 20
    echo ""
}

# Function to rerun a workflow
rerun_workflow() {
    read -p "Enter workflow run ID to rerun: " run_id
    echo ""
    echo "🔄 Rerunning workflow $run_id..."
    gh run rerun $run_id
    echo "✅ Workflow rerun triggered"
}

# Main menu
echo "Select an option:"
echo "1. List recent workflow runs"
echo "2. View specific workflow run"
echo "3. Watch latest workflow (real-time)"
echo "4. View workflow logs"
echo "5. List workflows by branch"
echo "6. List failed workflows"
echo "7. List successful workflows"
echo "8. Rerun a workflow"
echo "9. Exit"
echo ""
read -p "Enter option (1-9): " option

case $option in
    1)
        list_workflows
        ;;
    2)
        view_workflow
        ;;
    3)
        watch_workflow
        ;;
    4)
        view_logs
        ;;
    5)
        list_by_branch
        ;;
    6)
        list_failed
        ;;
    7)
        list_successful
        ;;
    8)
        rerun_workflow
        ;;
    9)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "❌ Invalid option"
        exit 1
        ;;
esac

echo ""
echo "=========================================="
echo "💡 Tip: You can also view workflows at:"
echo "   https://github.com/YOUR_USERNAME/YOUR_REPO/actions"
echo "=========================================="
