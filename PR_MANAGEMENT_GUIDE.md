# Pull Request Management Guide

## Problem: Too Many Open Pull Requests (60+)

When you have too many open PRs, it becomes difficult to:
- View CI/CD workflow status
- Track which PRs are active
- Maintain repository hygiene
- Review and merge important changes

## Solution: PR Cleanup Tools

This repository now includes several tools to help manage pull requests effectively.

---

## 🛠️ Available Tools

### 1. **List and Analyze PRs** (`list_prs.sh`)

Lists all open PRs with details and categorizes them by age.

**Usage:**
```bash
chmod +x list_prs.sh
./list_prs.sh
```

**What it shows:**
- Total number of open PRs
- PR details (number, title, author, branch, dates)
- PRs older than 30 days
- PRs older than 7 days
- Recent PRs (< 7 days)

---

### 2. **Bulk Close PRs** (`bulk_close_prs.sh`)

Interactive tool to close multiple PRs at once.

**Usage:**
```bash
chmod +x bulk_close_prs.sh
./bulk_close_prs.sh
```

**Options:**
1. Close PRs older than 30 days
2. Close PRs older than 7 days
3. Close PRs older than custom days
4. Close specific PRs by number
5. Close all PRs except most recent N
6. Exit

**Safety Features:**
- Shows which PRs will be closed before taking action
- Requires confirmation before closing
- Adds closure reason as a comment
- Attempts to delete branch (if permitted)

---

### 3. **View CI/CD Workflows** (`view_cicd_workflows.sh`)

View workflow runs directly without going through PRs.

**Usage:**
```bash
chmod +x view_cicd_workflows.sh
./view_cicd_workflows.sh
```

**Options:**
1. List recent workflow runs
2. View specific workflow run
3. Watch latest workflow (real-time)
4. View workflow logs
5. List workflows by branch
6. List failed workflows
7. List successful workflows
8. Rerun a workflow

---

### 4. **Automated Stale PR Cleanup** (`.github/workflows/stale-pr-cleanup.yml`)

GitHub Action that automatically manages stale PRs.

**How it works:**
- Runs daily at midnight UTC
- Marks PRs as stale after 30 days of inactivity
- Closes stale PRs after 7 additional days
- Can be triggered manually

**Protected PRs:**
PRs with these labels won't be auto-closed:
- `keep-open`
- `in-progress`
- `blocked`
- `waiting-for-review`

**Manual Trigger:**
```bash
gh workflow run stale-pr-cleanup.yml
```

---

## 📋 Step-by-Step Cleanup Process

### Step 1: Analyze Current PRs
```bash
./list_prs.sh
```

Review the output and identify:
- Which PRs are important
- Which PRs are outdated
- Which PRs can be closed

### Step 2: Close Old PRs
```bash
./bulk_close_prs.sh
```

Choose an option:
- **Option 1**: Close PRs older than 30 days (safest)
- **Option 5**: Keep only the 5 most recent PRs (aggressive)

### Step 3: View CI/CD Status
```bash
./view_cicd_workflows.sh
```

Now you can see workflow runs clearly without PR clutter.

### Step 4: Enable Auto-Cleanup
The stale PR workflow is already set up. It will:
- Automatically mark inactive PRs
- Close them after warning period
- Keep your repository clean going forward

---

## 🔧 Prerequisites

### Install GitHub CLI
```bash
# Ubuntu/Debian
sudo apt install gh

# Or download from
# https://cli.github.com/
```

### Authenticate
```bash
gh auth login
```

Follow the prompts to authenticate with your GitHub account.

---

## 💡 Best Practices

### 1. **Regular Cleanup**
- Run `list_prs.sh` weekly
- Close stale PRs monthly
- Keep only active PRs open

### 2. **Use Labels**
Add labels to important PRs:
```bash
gh pr edit <number> --add-label "keep-open"
gh pr edit <number> --add-label "in-progress"
```

### 3. **Convert to Draft**
For PRs that aren't ready:
```bash
gh pr ready <number> --undo
```

### 4. **Close with Context**
Always add a reason when closing:
```bash
gh pr close <number> --comment "Closing because XYZ"
```

### 5. **View Actions Tab**
Instead of looking at PRs, go directly to:
```
https://github.com/YOUR_USERNAME/YOUR_REPO/actions
```

---

## 🚀 Quick Commands Reference

### List PRs
```bash
# All open PRs
gh pr list

# Limited to 50
gh pr list --limit 50

# By author
gh pr list --author @me

# By label
gh pr list --label "bug"
```

### Close PRs
```bash
# Single PR
gh pr close 123

# With comment
gh pr close 123 --comment "Reason for closing"

# With branch deletion
gh pr close 123 --delete-branch
```

### View Workflows
```bash
# List recent runs
gh run list --limit 20

# View specific run
gh run view <run-id>

# Watch in real-time
gh run watch

# View logs
gh run view <run-id> --log
```

### Workflow Filters
```bash
# By workflow name
gh run list --workflow=ci-cd.yml

# By branch
gh run list --branch main

# By status
gh run list --status failure
gh run list --status success
```

---

## 🔍 Troubleshooting

### Can't see workflows?
- Go to Actions tab directly: `https://github.com/YOUR_USERNAME/YOUR_REPO/actions`
- Use `view_cicd_workflows.sh` script
- Filter by branch: `gh run list --branch main`

### Too many PRs to close manually?
- Use `bulk_close_prs.sh` with option 5
- Keep only the N most recent PRs
- Enable stale PR workflow for future

### GitHub CLI not working?
```bash
# Check installation
gh --version

# Check authentication
gh auth status

# Re-authenticate
gh auth login
```

---

## 📊 Monitoring

### Check Cleanup Progress
```bash
# Before cleanup
./list_prs.sh > before.txt

# After cleanup
./list_prs.sh > after.txt

# Compare
diff before.txt after.txt
```

### View Stale Workflow Status
```bash
gh run list --workflow=stale-pr-cleanup.yml
```

---

## 🎯 Recommended Workflow

1. **Daily**: Check CI/CD status via Actions tab
2. **Weekly**: Run `list_prs.sh` to review open PRs
3. **Monthly**: Run `bulk_close_prs.sh` to clean up
4. **Automated**: Let stale workflow handle the rest

---

## 📝 Notes

- All scripts are safe and require confirmation before closing PRs
- Closed PRs can be reopened if needed
- Branch deletion only works if you have permissions
- Stale workflow respects protected labels
- You can always view closed PRs in GitHub

---

## 🆘 Need Help?

If you encounter issues:
1. Check GitHub CLI is installed: `gh --version`
2. Verify authentication: `gh auth status`
3. Review script permissions: `chmod +x *.sh`
4. Check GitHub Actions tab for workflow status

---

**Created:** 2025-10-24
**Purpose:** Manage 60+ open pull requests and improve CI/CD visibility
