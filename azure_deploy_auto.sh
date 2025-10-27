#!/bin/bash

# Automated Azure Deployment Script (Non-Interactive)
# This script creates all Azure resources without prompts

set -e

# Configuration - EDIT THESE VALUES
DB_ADMIN_PASSWORD="LearnovaDB@2024!"  # Change this to your preferred password
DJANGO_SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_urlsafe(50))" 2>/dev/null || echo "django-insecure-$(date +%s)-change-this-in-production")

# Resource names
RESOURCE_GROUP="Learnova-rg"
LOCATION="eastus"
ACR_NAME="Learnovaacr$(date +%s | tail -c 4)"
DB_SERVER_NAME="Learnova-db-$(date +%s | tail -c 4)"
DB_NAME="Learnova_production"
DB_ADMIN_USER="Learnovaadmin"
APP_SERVICE_PLAN="Learnova-plan"
WEB_APP_NAME="Learnova-app-$(date +%s | tail -c 4)"

echo "=========================================="
echo "Azure Automated Deployment"
echo "=========================================="
echo ""

# Check Azure CLI
if ! command -v az &> /dev/null; then
    echo "Installing Azure CLI..."
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
fi

# Login check
if ! az account show &> /dev/null; then
    echo "Please login to Azure..."
    az login
fi

SUBSCRIPTION_ID=$(az account show --query id --output tsv)
echo "Subscription ID: $SUBSCRIPTION_ID"
echo ""

echo "Creating resources..."
echo ""

# 1. Resource Group
echo "1/7 Creating Resource Group..."
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION \
  --output none
echo "✅ Resource Group created"

# 2. Container Registry
echo "2/7 Creating Container Registry..."
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Basic \
  --admin-enabled true \
  --output none
echo "✅ Container Registry created"

# Get ACR credentials
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer --output tsv)
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username --output tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query "passwords[0].value" --output tsv)

# 3. PostgreSQL Database
echo "3/7 Creating PostgreSQL Database..."
az postgres flexible-server create \
  --resource-group $RESOURCE_GROUP \
  --name $DB_SERVER_NAME \
  --location $LOCATION \
  --admin-user $DB_ADMIN_USER \
  --admin-password "$DB_ADMIN_PASSWORD" \
  --sku-name Standard_B1ms \
  --tier Burstable \
  --storage-size 32 \
  --version 13 \
  --public-access 0.0.0.0 \
  --yes \
  --output none
echo "✅ PostgreSQL server created"

# Create database
az postgres flexible-server db create \
  --resource-group $RESOURCE_GROUP \
  --server-name $DB_SERVER_NAME \
  --database-name $DB_NAME \
  --output none
echo "✅ Database created"

# Firewall rule
az postgres flexible-server firewall-rule create \
  --resource-group $RESOURCE_GROUP \
  --name $DB_SERVER_NAME \
  --rule-name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0 \
  --output none
echo "✅ Firewall configured"

DATABASE_URL="postgresql://${DB_ADMIN_USER}:${DB_ADMIN_PASSWORD}@${DB_SERVER_NAME}.postgres.database.azure.com:5432/${DB_NAME}?sslmode=require"

# 4. App Service Plan
echo "4/7 Creating App Service Plan..."
az appservice plan create \
  --name $APP_SERVICE_PLAN \
  --resource-group $RESOURCE_GROUP \
  --is-linux \
  --sku F1 \
  --output none
echo "✅ App Service Plan created (Free tier)"

# 5. Web App
echo "5/7 Creating Web App..."
az webapp create \
  --resource-group $RESOURCE_GROUP \
  --plan $APP_SERVICE_PLAN \
  --name $WEB_APP_NAME \
  --deployment-container-image-name $ACR_LOGIN_SERVER/Learnova:latest \
  --output none
echo "✅ Web App created"

# Configure container
az webapp config container set \
  --name $WEB_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --docker-custom-image-name $ACR_LOGIN_SERVER/Learnova:latest \
  --docker-registry-server-url https://$ACR_LOGIN_SERVER \
  --docker-registry-server-user $ACR_USERNAME \
  --docker-registry-server-password $ACR_PASSWORD \
  --output none
echo "✅ Container configured"

# 6. Environment Variables
echo "6/7 Configuring Environment Variables..."
az webapp config appsettings set \
  --resource-group $RESOURCE_GROUP \
  --name $WEB_APP_NAME \
  --settings \
    DJANGO_SETTINGS_MODULE=student_management_system.settings \
    SECRET_KEY="$DJANGO_SECRET_KEY" \
    DEBUG=False \
    ALLOWED_HOSTS="${WEB_APP_NAME}.azurewebsites.net" \
    DATABASE_URL="$DATABASE_URL" \
    WEBSITES_PORT=8000 \
  --output none
echo "✅ Environment variables configured"

# 7. Service Principal
echo "7/7 Creating Service Principal..."
SP_OUTPUT=$(az ad sp create-for-rbac \
  --name "Learnova-github-$(date +%s)" \
  --role contributor \
  --scopes /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP \
  --sdk-auth 2>/dev/null)
echo "✅ Service Principal created"

echo ""
echo "=========================================="
echo "✅ DEPLOYMENT COMPLETE!"
echo "=========================================="
echo ""
echo "📊 Resources Created:"
echo "  • Resource Group: $RESOURCE_GROUP"
echo "  • Container Registry: $ACR_NAME"
echo "  • Database: $DB_SERVER_NAME"
echo "  • Web App: $WEB_APP_NAME"
echo ""
echo "🌐 Application URL:"
echo "  https://${WEB_APP_NAME}.azurewebsites.net"
echo ""
echo "=========================================="
echo "GitHub Secrets - Add to Repository"
echo "=========================================="
echo ""
echo "Go to: https://github.com/Sneha-Martin18/Learnova/settings/secrets/actions"
echo ""
echo "Add these secrets:"
echo ""
echo "1. AZURE_CREDENTIALS"
echo "$SP_OUTPUT"
echo ""
echo "2. ACR_LOGIN_SERVER"
echo "$ACR_LOGIN_SERVER"
echo ""
echo "3. ACR_USERNAME"
echo "$ACR_USERNAME"
echo ""
echo "4. ACR_PASSWORD"
echo "$ACR_PASSWORD"
echo ""
echo "5. AZURE_WEBAPP_NAME"
echo "$WEB_APP_NAME"
echo ""
echo "=========================================="
echo "Next Steps"
echo "=========================================="
echo ""
echo "1. Add the secrets above to GitHub"
echo "2. Update .github/workflows/azure-deploy.yml:"
echo "   Change AZURE_WEBAPP_NAME to: $WEB_APP_NAME"
echo ""
echo "3. Deploy:"
echo "   git add ."
echo "   git commit -m 'feat: Deploy to Azure'"
echo "   git push origin main"
echo ""
echo "🎉 Setup complete!"
echo ""

# Save credentials to file
cat > azure_credentials.txt << EOF
========================================
Azure Deployment Credentials
========================================

Resource Group: $RESOURCE_GROUP
Web App Name: $WEB_APP_NAME
Web App URL: https://${WEB_APP_NAME}.azurewebsites.net

Container Registry: $ACR_LOGIN_SERVER
ACR Username: $ACR_USERNAME
ACR Password: $ACR_PASSWORD

Database Server: ${DB_SERVER_NAME}.postgres.database.azure.com
Database Name: $DB_NAME
Database User: $DB_ADMIN_USER
Database Password: $DB_ADMIN_PASSWORD

Connection String:
$DATABASE_URL

Django Secret Key:
$DJANGO_SECRET_KEY

Service Principal (for GitHub):
$SP_OUTPUT

========================================
GitHub Secrets Configuration
========================================

AZURE_CREDENTIALS: (See Service Principal above)
ACR_LOGIN_SERVER: $ACR_LOGIN_SERVER
ACR_USERNAME: $ACR_USERNAME
ACR_PASSWORD: $ACR_PASSWORD
AZURE_WEBAPP_NAME: $WEB_APP_NAME

========================================
EOF

echo "💾 Credentials saved to: azure_credentials.txt"
echo ""
