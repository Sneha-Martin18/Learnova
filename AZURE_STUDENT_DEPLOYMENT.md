# Azure Student Tier Deployment - Complete Guide

## 🎯 Deployment Summary

**What we're deploying:** Django monolith application to Azure Web App for Containers

**Cost:** $0/month (Free tier F1)

**What you need:**
- Azure Student account
- GitHub account
- 10 minutes

---

## ✅ Step-by-Step Deployment

### Step 1: Create Azure Web App (Azure Portal - Easiest)

1. **Go to Azure Portal:** https://portal.azure.com

2. **Create Web App:**
   - Click "Create a resource"
   - Search for "Web App"
   - Click "Create"

3. **Configure:**
   - **Resource Group:** `LEARNOVA-rg` (create new)
   - **Name:** `LEARNOVA-app` (must be unique)
   - **Publish:** Container
   - **Operating System:** Linux
   - **Region:** East US
   - **Pricing Plan:** Free F1

4. **Container Settings:**
   - **Image Source:** Other Container Registries
   - **Image:** `ghcr.io/sneha-martin18/LEARNOVA:latest`
   - **Registry:** `https://ghcr.io`

5. **Click:** Review + Create → Create

6. **Wait 2-3 minutes** for deployment

---

### Step 2: Configure Environment Variables

1. Go to your Web App in Azure Portal
2. Click **Configuration** (left menu)
3. Click **New application setting** for each:

```
DJANGO_SETTINGS_MODULE = student_management_system.settings
SECRET_KEY = your-secret-key-here
DEBUG = False
ALLOWED_HOSTS = LEARNOVA-app.azurewebsites.net
WEBSITES_PORT = 8000
```

4. Click **Save**

---

### Step 3: Set Up GitHub Actions Deployment

#### 3.1 Get Publish Profile

1. In Azure Portal, go to your Web App
2. Click **Get publish profile** (top menu)
3. Save the downloaded file
4. Open it and copy the entire XML content

#### 3.2 Add GitHub Secret

1. Go to: https://github.com/Sneha-Martin18/LEARNOVA/settings/secrets/actions
2. Click **New repository secret**
3. Name: `AZURE_WEBAPP_PUBLISH_PROFILE`
4. Value: Paste the XML content
5. Click **Add secret**

#### 3.3 Update Workflow

The workflow is already created at `.github/workflows/azure-deploy.yml`

Just update line 9:
```yaml
AZURE_WEBAPP_NAME: LEARNOVA-app  # Change to your actual app name
```

---

### Step 4: Deploy

```bash
git add .
git commit -m "feat: Deploy to Azure Web App"
git push origin main
```

Watch deployment at: https://github.com/Sneha-Martin18/LEARNOVA/actions

---

### Step 5: Access Your App

**URL:** https://LEARNOVA-app.azurewebsites.net

---

## 🔧 Alternative: Using Azure CLI

If you prefer command line:

```bash
# Login
az login

# Create resource group
az group create --name LEARNOVA-rg --location eastus

# Create app service plan (Free tier)
az appservice plan create \
  --name LEARNOVA-plan \
  --resource-group LEARNOVA-rg \
  --is-linux \
  --sku F1

# Create web app
az webapp create \
  --resource-group LEARNOVA-rg \
  --plan LEARNOVA-plan \
  --name LEARNOVA-app \
  --deployment-container-image-name ghcr.io/sneha-martin18/LEARNOVA:latest

# Configure environment
az webapp config appsettings set \
  --resource-group LEARNOVA-rg \
  --name LEARNOVA-app \
  --settings \
    DJANGO_SETTINGS_MODULE=student_management_system.settings \
    SECRET_KEY="your-secret-key" \
    DEBUG=False \
    ALLOWED_HOSTS="LEARNOVA-app.azurewebsites.net" \
    WEBSITES_PORT=8000
```

---

## 📊 What's Included

✅ **Free Tier (F1):**
- 1 GB RAM
- 1 GB Storage
- 60 CPU minutes/day
- Custom domain support
- SSL certificate (free)

---

## 🔄 CI/CD Workflow

The workflow (`.github/workflows/azure-deploy.yml`) will:
1. Build Docker image
2. Push to GitHub Container Registry (free)
3. Deploy to Azure Web App
4. Application goes live automatically

---

## 🆙 Upgrading (Optional)

### Add PostgreSQL Database

**Cost:** ~$12/month (covered by student credit)

```bash
# Create PostgreSQL
az postgres flexible-server create \
  --resource-group LEARNOVA-rg \
  --name LEARNOVA-db \
  --location eastus \
  --admin-user LEARNOVAadmin \
  --admin-password "YourPassword123!" \
  --sku-name Standard_B1ms \
  --tier Burstable \
  --storage-size 32 \
  --version 13 \
  --public-access 0.0.0.0

# Create database
az postgres flexible-server db create \
  --resource-group LEARNOVA-rg \
  --server-name LEARNOVA-db \
  --database-name LEARNOVA_db

# Update app settings
az webapp config appsettings set \
  --resource-group LEARNOVA-rg \
  --name LEARNOVA-app \
  --settings \
    DATABASE_URL="postgresql://LEARNOVAadmin:YourPassword123!@LEARNOVA-db.postgres.database.azure.com:5432/LEARNOVA_db"
```

---

## 🐛 Troubleshooting

### App won't start
```bash
# View logs
az webapp log tail --name LEARNOVA-app --resource-group LEARNOVA-rg

# Enable logging
az webapp log config \
  --name LEARNOVA-app \
  --resource-group LEARNOVA-rg \
  --docker-container-logging filesystem
```

### Container image not found
- Make sure GitHub Actions ran successfully
- Check image exists: https://github.com/Sneha-Martin18/LEARNOVA/pkgs/container/LEARNOVA
- Verify container registry URL in Azure

### Port issues
- Ensure `WEBSITES_PORT=8000` is set
- Check Dockerfile exposes port 8000

---

## 💰 Cost Monitoring

**Free tier limits:**
- 60 CPU minutes/day
- 1 GB storage
- 165 MB/day outbound data

**Monitor usage:**
1. Go to Azure Portal
2. Navigate to your Web App
3. Click "Metrics" to see usage

**Set up budget alert:**
```bash
az consumption budget create \
  --budget-name LEARNOVA-budget \
  --amount 20 \
  --time-grain Monthly \
  --start-date 2025-01-01 \
  --end-date 2025-12-31
```

---

## 📚 Resources

- [Azure Web Apps Docs](https://docs.microsoft.com/azure/app-service/)
- [GitHub Actions for Azure](https://github.com/Azure/actions)
- [Azure Student Portal](https://portal.azure.com/#blade/Microsoft_Azure_Education/EducationMenuBlade/overview)

---

## ✅ Quick Checklist

- [ ] Azure Student account activated
- [ ] Web App created in Azure Portal
- [ ] Environment variables configured
- [ ] Publish profile downloaded
- [ ] GitHub secret added
- [ ] Workflow file updated
- [ ] Code pushed to GitHub
- [ ] Deployment successful
- [ ] App accessible at URL

---

**Need help?** Check Azure Portal logs or GitHub Actions logs for errors.

**Last Updated:** 2025-10-24
