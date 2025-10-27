# Azure Deployment Guide - Student Free Tier

## 🎓 Overview

This guide will help you deploy the Learnova Student Management System to Azure Web App for Containers using the **Azure Student Free Tier**.

**What you'll deploy:**
- Django monolith application
- PostgreSQL database (Azure Database for PostgreSQL)
- Docker container on Azure Web App

**Estimated cost:** $0-10/month (within free tier limits)

---

## 📋 Prerequisites

### 1. Azure Student Account
- Sign up at: https://azure.microsoft.com/en-us/free/students/
- Verify with your student email
- Get $100 credit (valid for 12 months)

### 2. Install Azure CLI
```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Verify installation
az --version

# Login to Azure
az login
```

### 3. GitHub Account
- Your repository: https://github.com/Sneha-Martin18/Learnova

---

## 🚀 Step-by-Step Deployment

### Step 1: Create Azure Resources

#### 1.1 Create Resource Group
```bash
az group create \
  --name Learnova-rg \
  --location eastus
```

#### 1.2 Create Azure Container Registry (ACR)
```bash
# Create ACR (must be globally unique)
az acr create \
  --resource-group Learnova-rg \
  --name Learnovaacr \
  --sku Basic \
  --admin-enabled true

# Get ACR credentials
az acr credential show --name Learnovaacr --resource-group Learnova-rg
```

**Save these values:**
- Login Server: `Learnovaacr.azurecr.io`
- Username: (from output)
- Password: (from output)

#### 1.3 Create PostgreSQL Database
```bash
# Create PostgreSQL Flexible Server
az postgres flexible-server create \
  --resource-group Learnova-rg \
  --name Learnova-db \
  --location eastus \
  --admin-user Learnovaadmin \
  --admin-password 'YourSecurePassword123!' \
  --sku-name Standard_B1ms \
  --tier Burstable \
  --storage-size 32 \
  --version 13 \
  --public-access 0.0.0.0

# Create database
az postgres flexible-server db create \
  --resource-group Learnova-rg \
  --server-name Learnova-db \
  --database-name Learnova_production

# Get connection string
az postgres flexible-server show-connection-string \
  --server-name Learnova-db \
  --database-name Learnova_production \
  --admin-user Learnovaadmin \
  --admin-password 'YourSecurePassword123!'
```

#### 1.4 Create App Service Plan
```bash
# Create Linux App Service Plan (Free tier)
az appservice plan create \
  --name Learnova-plan \
  --resource-group Learnova-rg \
  --is-linux \
  --sku F1
```

#### 1.5 Create Web App
```bash
# Create Web App for Containers
az webapp create \
  --resource-group Learnova-rg \
  --plan Learnova-plan \
  --name Learnova-app \
  --deployment-container-image-name Learnovaacr.azurecr.io/Learnova:latest

# Configure ACR credentials
az webapp config container set \
  --name Learnova-app \
  --resource-group Learnova-rg \
  --docker-custom-image-name Learnovaacr.azurecr.io/Learnova:latest \
  --docker-registry-server-url https://Learnovaacr.azurecr.io \
  --docker-registry-server-user <ACR_USERNAME> \
  --docker-registry-server-password <ACR_PASSWORD>
```

---

### Step 2: Configure Environment Variables

```bash
# Set application settings
az webapp config appsettings set \
  --resource-group Learnova-rg \
  --name Learnova-app \
  --settings \
    DJANGO_SETTINGS_MODULE=student_management_system.settings \
    SECRET_KEY='your-generated-secret-key-here' \
    DEBUG=False \
    ALLOWED_HOSTS='Learnova-app.azurewebsites.net' \
    DATABASE_URL='postgresql://Learnovaadmin:YourSecurePassword123!@Learnova-db.postgres.database.azure.com:5432/Learnova_production' \
    WEBSITES_PORT=8000
```

---

### Step 3: Create Service Principal for GitHub Actions

```bash
# Get subscription ID
az account show --query id --output tsv

# Create service principal (replace {subscription-id} with your ID)
az ad sp create-for-rbac \
  --name "Learnova-github-actions" \
  --role contributor \
  --scopes /subscriptions/{subscription-id}/resourceGroups/Learnova-rg \
  --sdk-auth
```

**Save the entire JSON output** - you'll need it for GitHub Secrets.

---

### Step 4: Configure GitHub Secrets

Go to: https://github.com/Sneha-Martin18/Learnova/settings/secrets/actions

Add these secrets:

| Secret Name | Value | How to Get |
|-------------|-------|------------|
| `AZURE_CREDENTIALS` | Service principal JSON | From Step 3 |
| `ACR_LOGIN_SERVER` | `Learnovaacr.azurecr.io` | From Step 1.2 |
| `ACR_USERNAME` | ACR username | From Step 1.2 |
| `ACR_PASSWORD` | ACR password | From Step 1.2 |
| `AZURE_WEBAPP_NAME` | `Learnova-app` | From Step 1.5 |

---

### Step 5: Deploy

```bash
# Push to main branch to trigger deployment
git add .
git commit -m "feat: Add Azure deployment configuration"
git push origin main
```

The GitHub Actions workflow will:
1. Build Docker image
2. Push to Azure Container Registry
3. Deploy to Azure Web App
4. Application goes live!

---

## 🌐 Access Your Application

**URL:** https://Learnova-app.azurewebsites.net

**Admin Panel:** https://Learnova-app.azurewebsites.net/admin

---

## 💰 Cost Breakdown (Student Free Tier)

| Service | Tier | Monthly Cost |
|---------|------|--------------|
| App Service Plan | F1 (Free) | $0 |
| Container Registry | Basic | $5 |
| PostgreSQL | Burstable B1ms | $12 |
| **Total** | | **~$17/month** |

**With $100 credit:** ~5-6 months free

---

## 🔧 Useful Commands

### View logs
```bash
az webapp log tail --name Learnova-app --resource-group Learnova-rg
```

### Restart app
```bash
az webapp restart --name Learnova-app --resource-group Learnova-rg
```

### SSH into container
```bash
az webapp ssh --name Learnova-app --resource-group Learnova-rg
```

### Update environment variables
```bash
az webapp config appsettings set \
  --resource-group Learnova-rg \
  --name Learnova-app \
  --settings KEY=VALUE
```

### Scale up (if needed)
```bash
# Upgrade to Basic tier (more resources)
az appservice plan update \
  --name Learnova-plan \
  --resource-group Learnova-rg \
  --sku B1
```

---

## 🐛 Troubleshooting

### Issue: Container won't start
```bash
# Check logs
az webapp log tail --name Learnova-app --resource-group Learnova-rg

# Check container settings
az webapp config show --name Learnova-app --resource-group Learnova-rg
```

### Issue: Database connection fails
```bash
# Check firewall rules
az postgres flexible-server firewall-rule list \
  --resource-group Learnova-rg \
  --name Learnova-db

# Allow Azure services
az postgres flexible-server firewall-rule create \
  --resource-group Learnova-rg \
  --name Learnova-db \
  --rule-name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0
```

### Issue: Application errors
```bash
# View application logs
az webapp log download --name Learnova-app --resource-group Learnova-rg

# Enable detailed logging
az webapp log config \
  --name Learnova-app \
  --resource-group Learnova-rg \
  --docker-container-logging filesystem
```

---

## 📊 Monitoring

### View metrics in Azure Portal
1. Go to: https://portal.azure.com
2. Navigate to your Web App
3. Click "Metrics" in the left menu
4. Monitor: CPU, Memory, HTTP requests, Response time

### Set up alerts
```bash
# Create alert for high CPU usage
az monitor metrics alert create \
  --name high-cpu-alert \
  --resource-group Learnova-rg \
  --scopes /subscriptions/{subscription-id}/resourceGroups/Learnova-rg/providers/Microsoft.Web/sites/Learnova-app \
  --condition "avg Percentage CPU > 80" \
  --description "Alert when CPU usage is above 80%"
```

---

## 🔒 Security Best Practices

1. **Never commit secrets** to GitHub
2. **Use Key Vault** for sensitive data (optional, costs extra)
3. **Enable HTTPS only**
   ```bash
   az webapp update \
     --resource-group Learnova-rg \
     --name Learnova-app \
     --https-only true
   ```
4. **Restrict database access** to Azure services only
5. **Regular backups** of database
   ```bash
   az postgres flexible-server backup list \
     --resource-group Learnova-rg \
     --name Learnova-db
   ```

---

## 🎯 Next Steps

1. ✅ Complete all steps above
2. ✅ Test your deployment
3. ✅ Set up custom domain (optional)
4. ✅ Configure SSL certificate (optional, free with App Service)
5. ✅ Set up monitoring and alerts
6. ✅ Create database backups

---

## 📚 Additional Resources

- [Azure Web Apps Documentation](https://docs.microsoft.com/azure/app-service/)
- [Azure Container Registry](https://docs.microsoft.com/azure/container-registry/)
- [Azure Database for PostgreSQL](https://docs.microsoft.com/azure/postgresql/)
- [GitHub Actions for Azure](https://github.com/Azure/actions)

---

**Need help?** Check the troubleshooting section or Azure documentation.

**Last Updated:** 2025-10-24
