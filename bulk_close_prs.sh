#!/bin/bash

# Script to bulk close old/stale pull requests
# Use with caution - this will close PRs permanently

echo "=========================================="
echo "Bulk PR Closure Tool"
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

# Function to close PRs older than specified days
close_old_prs() {
    local days=$1
    local reason=$2

    echo "🔍 Finding PRs older than $days days..."

    # Get PR numbers older than specified days
    local pr_numbers=$(gh pr list --state open --limit 100 --json number,createdAt \
        --jq ".[] | select(.createdAt | fromdateiso8601 < (now - ($days * 86400))) | .number")

    if [ -z "$pr_numbers" ]; then
        echo "✅ No PRs found older than $days days"
        return
    fi

    local count=$(echo "$pr_numbers" | wc -l)
    echo "Found $count PRs to close"
    echo ""

    # Show which PRs will be closed
    echo "PRs that will be closed:"
    for pr in $pr_numbers; do
        gh pr view $pr --json number,title --template 'PR #{{.number}}: {{.title}}'
        echo ""
    done

    echo ""
    read -p "⚠️  Do you want to close these $count PRs? (yes/no): " confirm

    if [ "$confirm" != "yes" ]; then
        echo "❌ Cancelled"
        return
    fi

    # Close each PR
    for pr in $pr_numbers; do
        echo "Closing PR #$pr..."
        gh pr close $pr --comment "$reason" --delete-branch 2>/dev/null || gh pr close $pr --comment "$reason"
        echo "✅ Closed PR #$pr"
    done

    echo ""
    echo "✅ Closed $count PRs"
}

# Function to close specific PRs by number
close_specific_prs() {
    echo "Enter PR numbers to close (space-separated):"
    read -p "PR numbers: " pr_numbers

    if [ -z "$pr_numbers" ]; then
        echo "❌ No PR numbers provided"
        return
    fi

    read -p "Enter closure reason: " reason

    for pr in $pr_numbers; do
        echo "Closing PR #$pr..."
        gh pr close $pr --comment "$reason" --delete-branch 2>/dev/null || gh pr close $pr --comment "$reason"
        echo "✅ Closed PR #$pr"
    done
}

# Function to close all PRs except the most recent N
close_all_except_recent() {
    local keep_count=$1

    echo "🔍 Finding PRs to close (keeping $keep_count most recent)..."

    local pr_numbers=$(gh pr list --state open --limit 100 --json number \
        --jq ".[$keep_count:] | .[].number")

    if [ -z "$pr_numbers" ]; then
        echo "✅ No PRs to close"
        return
    fi

    local count=$(echo "$pr_numbers" | wc -l)
    echo "Found $count PRs to close (keeping $keep_count most recent)"
    echo ""

    read -p "⚠️  Do you want to close these $count PRs? (yes/no): " confirm

    if [ "$confirm" != "yes" ]; then
        echo "❌ Cancelled"
        return
    fi

    for pr in $pr_numbers; do
        echo "Closing PR #$pr..."
        gh pr close $pr --comment "Cleaning up old PRs to maintain repository hygiene" --delete-branch 2>/dev/null || gh pr close $pr --comment "Cleaning up old PRs"
        echo "✅ Closed PR #$pr"
    done

    echo ""
    echo "✅ Closed $count PRs"
}

# Main menu
echo "Select an option:"
echo "1. Close PRs older than 30 days"
echo "2. Close PRs older than 7 days"
echo "3. Close PRs older than custom days"
echo "4. Close specific PRs by number"
echo "5. Close all PRs except most recent N"
echo "6. Exit"
echo ""
read -p "Enter option (1-6): " option

case $option in
    1)
        close_old_prs 30 "Closing stale PR (older than 30 days) to clean up repository"
        ;;
    2)
        close_old_prs 7 "Closing old PR (older than 7 days) to clean up repository"
        ;;
    3)
        read -p "Enter number of days: " days
        close_old_prs $days "Closing old PR (older than $days days) to clean up repository"
        ;;
    4)
        close_specific_prs
        ;;
    5)
        read -p "How many recent PRs to keep? " keep_count
        close_all_except_recent $keep_count
        ;;
    6)
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
echo "Done!"
echo "=========================================="
