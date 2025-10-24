# Unified CI/CD Workflow View Guide

## Problem: Can't See All Workflow Jobs in One Place

When you have 60+ pull requests, GitHub's interface makes it difficult to see all CI/CD workflow jobs in a unified view. Jobs are scattered across different PRs, making it hard to get an overview of your pipeline status.

## Solution: Unified Workflow Dashboard

This repository now includes tools to view **all workflow jobs in a single consolidated view**, regardless of how many PRs you have.

---

## 🎯 Quick Start

### Option 1: Shell Script (Fast & Simple)
```bash
./view_workflow_summary.sh
```

### Option 2: Python Dashboard (Rich & Detailed)
```bash
python3 workflow_status_dashboard.py
```

---

## 🛠️ Tool 1: Shell Script Dashboard

**File:** `view_workflow_summary.sh`

### Features
- ✅ Shows latest workflow run summary
- ✅ Lists all jobs with status icons
- ✅ Displays detailed step-by-step breakdown
- ✅ Provides statistics (success rate, counts)
- ✅ Shows failed job details
- ✅ Provides quick action commands

### Usage
```bash
chmod +x view_workflow_summary.sh
./view_workflow_summary.sh
```

### Output Example
```
==========================================
📊 Workflow Run #12345
==========================================
Branch:    main
Event:     push
Status:    completed
Result:    success
Created:   2025-10-24T09:00:00Z
Updated:   2025-10-24T09:15:00Z

==========================================
🔧 All Jobs Status
==========================================
✅ [SUCCESS] Code Quality Checks (2025-10-24T09:00:00Z)
✅ [SUCCESS] Test Microservices (user-management-service)
✅ [SUCCESS] Test Microservices (academic-service)
❌ [FAILURE] Build Docker Images (api-gateway)
⏭️  [SKIPPED] Security Vulnerability Scan
🔄 [IN_PROGRESS] Integration Tests

==========================================
📈 Summary Statistics
==========================================
Total Jobs:      15
✅ Success:      12
❌ Failed:       1
⏭️  Skipped:      1
🔄 In Progress:  1
Success Rate:    80%
```

---

## 🛠️ Tool 2: Python Dashboard

**File:** `workflow_status_dashboard.py`

### Features
- 🎨 Colorized output for better readability
- 📊 Visual progress bars
- ⏱️ Duration tracking for each job
- 📋 Detailed step-by-step breakdown
- 📈 Advanced statistics
- 🔗 Quick action commands

### Usage
```bash
python3 workflow_status_dashboard.py
```

### Output Features
- **Color-coded status**: Green (success), Red (failure), Yellow (skipped)
- **Duration tracking**: Shows how long each job took
- **Progress bars**: Visual representation of success rate
- **Step details**: See which specific steps passed/failed

---

## 📊 What You'll See

### 1. Workflow Summary
- Run ID and basic info
- Branch and event type
- Overall status and conclusion
- Timestamps

### 2. Jobs Overview
All jobs listed with:
- ✅ Success icon
- ❌ Failure icon
- 🔄 In-progress icon
- ⏭️ Skipped icon
- ⏳ Duration

### 3. Detailed Breakdown
For each job:
- Job name and status
- All steps with their status
- Step-by-step execution details

### 4. Statistics
- Total job count
- Success/failure/skipped counts
- Success rate percentage
- Visual progress bar

### 5. Quick Actions
Ready-to-use commands for:
- View in browser
- View logs
- Rerun workflow
- Watch live

---

## 🔍 Viewing Specific Workflow Runs

### View by Branch
```bash
gh run list --workflow=ci-cd.yml --branch main --limit 10
```

### View by Status
```bash
# Failed runs only
gh run list --workflow=ci-cd.yml --status failure

# Successful runs only
gh run list --workflow=ci-cd.yml --status success
```

### View Specific Run
```bash
# Get run ID from the dashboard output
gh run view <run-id>

# View in browser
gh run view <run-id> --web

# View logs
gh run view <run-id> --log

# View only failed logs
gh run view <run-id> --log-failed
```

---

## 🌐 Alternative: GitHub Actions Tab

You can also view workflows directly in GitHub:

1. Go to your repository on GitHub
2. Click the **"Actions"** tab
3. Select **"CI/CD Pipeline"** from the left sidebar
4. Click on any workflow run to see all jobs

**Direct URL format:**
```
https://github.com/YOUR_USERNAME/YOUR_REPO/actions
```

This bypasses the PR view entirely and shows all workflow runs.

---

## 💡 Best Practices

### 1. Regular Monitoring
```bash
# Check latest status daily
./view_workflow_summary.sh

# Or set up an alias
alias cicd-status='cd /path/to/repo && ./view_workflow_summary.sh'
```

### 2. Watch Live Workflows
```bash
# Watch the latest workflow in real-time
gh run watch

# Watch specific workflow
gh run watch <run-id>
```

### 3. Quick Failure Investigation
```bash
# View only failed job logs
gh run view <run-id> --log-failed

# Rerun failed jobs
gh run rerun <run-id> --failed
```

### 4. Filter by Time
```bash
# Runs from last 24 hours
gh run list --workflow=ci-cd.yml --created ">=2025-10-23"

# Runs from specific date range
gh run list --workflow=ci-cd.yml --created "2025-10-20..2025-10-24"
```

---

## 🔧 Troubleshooting

### Issue: "No workflow runs found"

**Solution:**
1. Check if workflows have been triggered:
   ```bash
   gh run list --limit 50
   ```
2. Verify workflow file exists:
   ```bash
   ls -la .github/workflows/ci-cd.yml
   ```
3. Check if workflow is enabled in GitHub Settings

### Issue: "GitHub CLI not authenticated"

**Solution:**
```bash
gh auth login
# Follow the prompts to authenticate
```

### Issue: Can't see recent runs

**Solution:**
```bash
# Increase limit
gh run list --workflow=ci-cd.yml --limit 50

# Or view all runs
gh run list --workflow=ci-cd.yml --limit 100
```

---

## 📋 Workflow Jobs Breakdown

Your CI/CD pipeline includes these jobs:

### 1. **Code Quality Checks** (lint)
- Black code formatting
- isort import sorting
- Flake8 linting

### 2. **Test Microservices** (test-services)
Matrix job testing 8 services:
- user-management-service
- academic-service
- attendance-service
- notification-service
- leave-management-service
- feedback-service
- assessment-service
- financial-service

### 3. **Build Docker Images** (build-images)
Matrix job building 10 images:
- All 8 microservices
- API Gateway
- Frontend

### 4. **Security Scan** (security-scan)
- Trivy vulnerability scanning
- SARIF report upload

### 5. **Integration Tests** (integration-tests)
- Docker Compose deployment
- Service health checks

### 6. **Deploy to Staging** (deploy-staging)
- Runs on `develop` branch
- Deploys to staging environment

### 7. **Deploy to Production** (deploy-production)
- Runs on `main` branch
- Deploys to production environment

---

## 🚀 Advanced Usage

### Compare Multiple Runs
```bash
# List last 5 runs
gh run list --workflow=ci-cd.yml --limit 5

# Compare success rates
for run_id in $(gh run list --workflow=ci-cd.yml --limit 5 --json databaseId --jq '.[].databaseId'); do
    echo "Run #$run_id:"
    gh run view $run_id --json jobs --jq '[.jobs[] | select(.conclusion == "success")] | length'
done
```

### Export Workflow Data
```bash
# Export to JSON
gh run view <run-id> --json jobs > workflow_data.json

# Export to CSV (requires jq)
gh run view <run-id> --json jobs | jq -r '.jobs[] | [.name, .conclusion, .startedAt, .completedAt] | @csv' > workflow_data.csv
```

### Monitor Specific Job
```bash
# Find job ID
gh run view <run-id> --json jobs --jq '.jobs[] | select(.name == "Build Docker Images") | .id'

# View job logs
gh run view --job <job-id> --log
```

---

## 📊 Integration with Other Tools

### Use with PR Management
```bash
# 1. Clean up old PRs
./bulk_close_prs.sh

# 2. View unified workflow status
./view_workflow_summary.sh

# 3. Check specific workflow for a branch
gh run list --branch feature/new-feature
```

### Combine with CI/CD Status Checker
```bash
# Check overall CI/CD health
python check_cicd_status.py

# Then view detailed workflow
python3 workflow_status_dashboard.py
```

---

## 🎯 Summary

**Problem:** 60+ PRs make it impossible to see CI/CD status clearly

**Solution:** Use unified workflow dashboards

**Tools:**
1. `view_workflow_summary.sh` - Quick shell-based view
2. `workflow_status_dashboard.py` - Rich Python dashboard
3. GitHub Actions tab - Web-based view
4. `gh run` commands - CLI-based queries

**Result:** See all workflow jobs in one consolidated view, regardless of PR count

---

## 📝 Quick Reference

```bash
# View unified dashboard
./view_workflow_summary.sh

# Or Python version
python3 workflow_status_dashboard.py

# View in browser
gh run view --web

# Watch live
gh run watch

# View failed logs only
gh run view <run-id> --log-failed

# List recent runs
gh run list --workflow=ci-cd.yml --limit 20

# Rerun workflow
gh run rerun <run-id>
```

---

**Created:** 2025-10-24
**Purpose:** Provide unified view of all CI/CD workflow jobs in one place
