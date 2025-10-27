# Quick Start: Workflow Viewing Tools

## ✅ Test Results

Your system is ready! All tools are installed and configured:

- ✅ GitHub CLI installed (v2.45.0)
- ✅ Python installed (v3.12.3)
- ✅ All scripts exist and are executable
- ✅ Repository connected to GitHub (Sneha-Martin18/LEARNOVA)

## ⚠️ Authentication Required

Your GitHub CLI token needs to be refreshed. Run:

```bash
gh auth login
```

**Follow these steps:**

1. Select: **GitHub.com**
2. Select: **HTTPS**
3. Select: **Login with a web browser**
4. Copy the one-time code shown
5. Press Enter to open browser
6. Paste the code and authorize

## 🚀 After Authentication

Once authenticated, you can use these tools:

### 1. View Unified Workflow Dashboard
```bash
./view_workflow_summary.sh
```
Shows all CI/CD jobs from the latest workflow run in one view.

### 2. Python Dashboard (Rich View)
```bash
python3 workflow_status_dashboard.py
```
Color-coded output with progress bars and detailed statistics.

### 3. Interactive Workflow Viewer
```bash
./view_cicd_workflows.sh
```
Menu-driven interface to explore workflows.

### 4. List All Workflow Runs
```bash
gh run list --workflow=ci-cd.yml --limit 20
```

### 5. View Specific Run
```bash
gh run view <run-id>
```

### 6. View in Browser
```bash
gh run view --web
```

### 7. Watch Live
```bash
gh run watch
```

## 📊 Check Pull Requests

You have 60+ pull requests. To manage them:

### List PRs
```bash
./list_prs.sh
```

### Close Old PRs
```bash
./bulk_close_prs.sh
```

## 🔍 Direct GitHub Access

You can also view workflows directly on GitHub:

**Actions Tab:**
```
https://github.com/Sneha-Martin18/LEARNOVA/actions
```

**Workflow Runs:**
```
https://github.com/Sneha-Martin18/LEARNOVA/actions/workflows/ci-cd.yml
```

## 📝 Current Status

- **Repository:** Sneha-Martin18/LEARNOVA
- **Tools Status:** All working ✅
- **Authentication:** Needs refresh ⚠️
- **Workflow Runs:** Will be visible after authentication

## 🎯 Next Steps

1. **Authenticate GitHub CLI:**
   ```bash
   gh auth login
   ```

2. **View workflows:**
   ```bash
   ./view_workflow_summary.sh
   ```

3. **Manage PRs:**
   ```bash
   ./list_prs.sh
   ./bulk_close_prs.sh
   ```

4. **Enable auto-cleanup:**
   The stale PR workflow is already configured in `.github/workflows/stale-pr-cleanup.yml`

## 📖 Documentation

- `UNIFIED_WORKFLOW_VIEW_GUIDE.md` - Complete workflow viewing guide
- `PR_MANAGEMENT_GUIDE.md` - PR management guide
- `CI_CD_VERIFICATION_GUIDE.md` - CI/CD setup guide

## 🆘 Troubleshooting

### Issue: "Bad credentials"
**Solution:** Run `gh auth login` to refresh token

### Issue: "No workflow runs found"
**Solution:**
- Check GitHub Actions tab in browser
- Ensure workflows have been triggered
- Push code or create PR to trigger workflow

### Issue: Can't see all jobs
**Solution:** Use the unified dashboard tools instead of PR view

---

**Created:** 2025-10-24
**Status:** Ready to use after authentication
