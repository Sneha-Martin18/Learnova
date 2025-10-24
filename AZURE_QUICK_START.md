# Azure Deployment Quick Start - Student Free Tier

## 🚀 5-Minute Setup

### Prerequisites
- Azure Student account activated
- Azure CLI installed
- GitHub repository access

---

## Step 1: Install Azure CLI (if not installed)

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az login
```

---

## Step 2: Run Automated Setup Script

I've created a script to automate the entire setup. Run this:

```bash
# Navigate to project directory
cd /home/jayasurya/Downloads/project-backup/django-student-management-system-master

# Make script executable
chmod +x azure_setup.sh

# Run setup (will prompt for values)
./azure_setup.sh
```

---

## Step 3: Configure GitHub Secrets

After the script completes, add these secrets to GitHub:

**Go to:** https://github.com/Sneha-Martin18/Learnova/settings/secrets/actions

**Click:** "New repository secret" for each:

1. **AZURE_CREDENTIALS** - Copy from script output
2. **ACR_LOGIN_SERVER** - Copy from script output
3. **ACR_USERNAME** - Copy from script output
4. **ACR_PASSWORD** - Copy from script output

---

## Step 4: Deploy

```bash
git add .
git commit -m "feat: Add Azure deployment"
git push origin main
```

Watch deployment at: https://github.com/Sneha-Martin18/Learnova/actions

---

## Step 5: Access Your App

**URL:** https://learnova-app.azurewebsites.net

---

## 💰 Cost: ~$17/month (covered by $100 student credit)

---

## 🆘 Need Help?

See full guide: `AZURE_DEPLOYMENT_GUIDE.md`

**Common Issues:**
- **Container won't start:** Check logs with `az webapp log tail`
- **Database connection fails:** Check firewall rules
- **Deployment fails:** Check GitHub Actions logs

---

## 📋 What Gets Created

- ✅ Resource Group: `learnova-rg`
- ✅ Container Registry: `learnovaacr`
- ✅ PostgreSQL Database: `learnova-db`
- ✅ App Service Plan: `learnova-plan` (Free tier)
- ✅ Web App: `learnova-app`

---

**Ready to deploy? Run the setup script!**
