#!/bin/bash

# Unified CI/CD Workflow Status Viewer
# Shows all jobs from the latest workflow run in a single consolidated view

echo "=========================================="
echo "CI/CD Unified Workflow Dashboard"
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

# Get the latest workflow run
echo "🔍 Fetching latest CI/CD workflow run..."
LATEST_RUN=$(gh run list --workflow=ci-cd.yml --limit 1 --json databaseId,status,conclusion,headBranch,event,createdAt,updatedAt --jq '.[0]')

if [ -z "$LATEST_RUN" ]; then
    echo "❌ No workflow runs found"
    exit 1
fi

RUN_ID=$(echo "$LATEST_RUN" | jq -r '.databaseId')
STATUS=$(echo "$LATEST_RUN" | jq -r '.status')
CONCLUSION=$(echo "$LATEST_RUN" | jq -r '.conclusion')
BRANCH=$(echo "$LATEST_RUN" | jq -r '.headBranch')
EVENT=$(echo "$LATEST_RUN" | jq -r '.event')
CREATED=$(echo "$LATEST_RUN" | jq -r '.createdAt')
UPDATED=$(echo "$LATEST_RUN" | jq -r '.updatedAt')

echo ""
echo "=========================================="
echo "📊 Workflow Run #$RUN_ID"
echo "=========================================="
echo "Branch:    $BRANCH"
echo "Event:     $EVENT"
echo "Status:    $STATUS"
echo "Result:    $CONCLUSION"
echo "Created:   $CREATED"
echo "Updated:   $UPDATED"
echo ""

# Get all jobs for this run
echo "=========================================="
echo "🔧 All Jobs Status"
echo "=========================================="

gh run view $RUN_ID --json jobs --jq '.jobs[] | "[\(.conclusion // .status | ascii_upcase)] \(.name) (\(.startedAt // "not started"))"' | while read line; do
    if [[ $line == *"SUCCESS"* ]]; then
        echo "✅ $line"
    elif [[ $line == *"FAILURE"* ]]; then
        echo "❌ $line"
    elif [[ $line == *"CANCELLED"* ]]; then
        echo "🚫 $line"
    elif [[ $line == *"SKIPPED"* ]]; then
        echo "⏭️  $line"
    elif [[ $line == *"IN_PROGRESS"* ]] || [[ $line == *"QUEUED"* ]]; then
        echo "🔄 $line"
    else
        echo "⏳ $line"
    fi
done

echo ""
echo "=========================================="
echo "📋 Detailed Job Breakdown"
echo "=========================================="

# Get detailed job information
gh run view $RUN_ID --json jobs --jq '.jobs[] | {name: .name, status: .status, conclusion: .conclusion, steps: [.steps[] | {name: .name, conclusion: .conclusion}]}' | jq -r '
"
Job: \(.name)
Status: \(.status)
Conclusion: \(.conclusion // "N/A")
Steps:
\(.steps[] | "  - [\(.conclusion // "pending")] \(.name)")
"'

echo ""
echo "=========================================="
echo "📈 Summary Statistics"
echo "=========================================="

TOTAL_JOBS=$(gh run view $RUN_ID --json jobs --jq '.jobs | length')
SUCCESS_JOBS=$(gh run view $RUN_ID --json jobs --jq '[.jobs[] | select(.conclusion == "success")] | length')
FAILED_JOBS=$(gh run view $RUN_ID --json jobs --jq '[.jobs[] | select(.conclusion == "failure")] | length')
SKIPPED_JOBS=$(gh run view $RUN_ID --json jobs --jq '[.jobs[] | select(.conclusion == "skipped")] | length')
IN_PROGRESS=$(gh run view $RUN_ID --json jobs --jq '[.jobs[] | select(.status == "in_progress")] | length')

echo "Total Jobs:      $TOTAL_JOBS"
echo "✅ Success:      $SUCCESS_JOBS"
echo "❌ Failed:       $FAILED_JOBS"
echo "⏭️  Skipped:      $SKIPPED_JOBS"
echo "🔄 In Progress:  $IN_PROGRESS"

# Calculate success rate
if [ "$TOTAL_JOBS" -gt 0 ]; then
    SUCCESS_RATE=$((SUCCESS_JOBS * 100 / TOTAL_JOBS))
    echo "Success Rate:    ${SUCCESS_RATE}%"
fi

echo ""
echo "=========================================="
echo "🔗 Quick Actions"
echo "=========================================="
echo "View in browser:  gh run view $RUN_ID --web"
echo "View logs:        gh run view $RUN_ID --log"
echo "Rerun workflow:   gh run rerun $RUN_ID"
echo "Watch live:       gh run watch $RUN_ID"
echo ""

# Show failed job logs if any
if [ "$FAILED_JOBS" -gt 0 ]; then
    echo "=========================================="
    echo "❌ Failed Jobs Details"
    echo "=========================================="

    FAILED_JOB_NAMES=$(gh run view $RUN_ID --json jobs --jq '.jobs[] | select(.conclusion == "failure") | .name')

    echo "$FAILED_JOB_NAMES" | while read job_name; do
        echo ""
        echo "Failed Job: $job_name"
        echo "---"
    done

    echo ""
    echo "💡 To view detailed logs of failed jobs:"
    echo "   gh run view $RUN_ID --log-failed"
fi

echo ""
echo "=========================================="
echo "✨ Workflow Dashboard Complete"
echo "=========================================="
