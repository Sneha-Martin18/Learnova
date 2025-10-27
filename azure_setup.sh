#!/bin/bash

# Azure Deployment Setup Script for Student Free Tier
# This script automates the creation of Azure resources for Learnova

set -e

echo "=========================================="
echo "Azure Deployment Setup - Learnova"
echo "Student Free Tier"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}❌ Azure CLI is not installed${NC}"
    echo "Install it with: curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
    exit 1
fi

echo -e "${GREEN}✅ Azure CLI found${NC}"
echo ""

# Check if logged in
echo "Checking Azure login status..."
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}⚠️  Not logged in to Azure${NC}"
    echo "Logging in..."
    az login
fi

echo -e "${GREEN}✅ Logged in to Azure${NC}"
echo ""

# Get subscription info
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
SUBSCRIPTION_NAME=$(az account show --query name --output tsv)
echo -e "${BLUE}📊 Subscription: $SUBSCRIPTION_NAME${NC}"
echo -e "${BLUE}📊 Subscription ID: $SUBSCRIPTION_ID${NC}"
echo ""

# Configuration
RESOURCE_GROUP="Learnova-rg"
LOCATION="eastus"
ACR_NAME="Learnovaacr$(date +%s | tail -c 4)"  # Add random suffix for uniqueness
DB_SERVER_NAME="Learnova-db-$(date +%s | tail -c 4)"
DB_NAME="Learnova_production"
DB_ADMIN_USER="Learnovaadmin"
APP_SERVICE_PLAN="Learnova-plan"
WEB_APP_NAME="Learnova-app-$(date +%s | tail -c 4)"

# Prompt for database password
echo -e "${YELLOW}🔐 Enter a secure password for PostgreSQL database:${NC}"
read -s DB_ADMIN_PASSWORD
echo ""
echo -e "${YELLOW}🔐 Confirm password:${NC}"
read -s DB_ADMIN_PASSWORD_CONFIRM
echo ""

if [ "$DB_ADMIN_PASSWORD" != "$DB_ADMIN_PASSWORD_CONFIRM" ]; then
    echo -e "${RED}❌ Passwords do not match${NC}"
    exit 1
fi

# Prompt for Django secret key
echo -e "${YELLOW}🔑 Enter Django SECRET_KEY (or press Enter to generate):${NC}"
read DJANGO_SECRET_KEY
if [ -z "$DJANGO_SECRET_KEY" ]; then
    DJANGO_SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_urlsafe(50))")
    echo -e "${GREEN}✅ Generated SECRET_KEY${NC}"
fi
echo ""

echo "=========================================="
echo "Configuration Summary"
echo "=========================================="
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $LOCATION"
echo "ACR Name: $ACR_NAME"
echo "Database Server: $DB_SERVER_NAME"
echo "Web App: $WEB_APP_NAME"
echo ""
echo -e "${YELLOW}⚠️  Estimated cost: ~\$17/month (covered by student credit)${NC}"
echo ""
read -p "Continue with deployment? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled"
    exit 1
fi

echo ""
echo "=========================================="
echo "Step 1: Creating Resource Group"
echo "=========================================="
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION \
  --output table

echo -e "${GREEN}✅ Resource group created${NC}"
echo ""

echo "=========================================="
echo "Step 2: Creating Container Registry"
echo "=========================================="
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Basic \
  --admin-enabled true \
  --output table

echo -e "${GREEN}✅ Container registry created${NC}"
echo ""

# Get ACR credentials
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer --output tsv)
ACR_CREDENTIALS=$(az acr credential show --name $ACR_NAME --resource-group $RESOURCE_GROUP)
ACR_USERNAME=$(echo $ACR_CREDENTIALS | jq -r '.username')
ACR_PASSWORD=$(echo $ACR_CREDENTIALS | jq -r '.passwords[0].value')

echo "=========================================="
echo "Step 3: Creating PostgreSQL Database"
echo "=========================================="
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
  --output table

echo -e "${GREEN}✅ PostgreSQL server created${NC}"
echo ""

# Create database
az postgres flexible-server db create \
  --resource-group $RESOURCE_GROUP \
  --server-name $DB_SERVER_NAME \
  --database-name $DB_NAME \
  --output table

echo -e "${GREEN}✅ Database created${NC}"
echo ""

# Allow Azure services
az postgres flexible-server firewall-rule create \
  --resource-group $RESOURCE_GROUP \
  --name $DB_SERVER_NAME \
  --rule-name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0 \
  --output table

echo -e "${GREEN}✅ Firewall rules configured${NC}"
echo ""

# Build connection string
DATABASE_URL="postgresql://${DB_ADMIN_USER}:${DB_ADMIN_PASSWORD}@${DB_SERVER_NAME}.postgres.database.azure.com:5432/${DB_NAME}?sslmode=require"

echo "=========================================="
echo "Step 4: Creating App Service Plan"
echo "=========================================="
az appservice plan create \
  --name $APP_SERVICE_PLAN \
  --resource-group $RESOURCE_GROUP \
  --is-linux \
  --sku F1 \
  --output table

echo -e "${GREEN}✅ App Service Plan created (Free tier)${NC}"
echo ""

echo "=========================================="
echo "Step 5: Creating Web App"
echo "=========================================="
az webapp create \
  --resource-group $RESOURCE_GROUP \
  --plan $APP_SERVICE_PLAN \
  --name $WEB_APP_NAME \
  --deployment-container-image-name $ACR_LOGIN_SERVER/Learnova:latest \
  --output table

echo -e "${GREEN}✅ Web App created${NC}"
echo ""

# Configure container settings
az webapp config container set \
  --name $WEB_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --docker-custom-image-name $ACR_LOGIN_SERVER/Learnova:latest \
  --docker-registry-server-url https://$ACR_LOGIN_SERVER \
  --docker-registry-server-user $ACR_USERNAME \
  --docker-registry-server-password $ACR_PASSWORD \
  --output table

echo -e "${GREEN}✅ Container configured${NC}"
echo ""

echo "=========================================="
echo "Step 6: Configuring Environment Variables"
echo "=========================================="
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
  --output table

echo -e "${GREEN}✅ Environment variables configured${NC}"
echo ""

echo "=========================================="
echo "Step 7: Creating Service Principal"
echo "=========================================="
SP_OUTPUT=$(az ad sp create-for-rbac \
  --name "Learnova-github-actions-$(date +%s)" \
  --role contributor \
  --scopes /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP \
  --sdk-auth)

echo -e "${GREEN}✅ Service Principal created${NC}"
echo ""

echo "=========================================="
echo "✅ DEPLOYMENT SETUP COMPLETE!"
echo "=========================================="
echo ""
echo -e "${BLUE}📊 Resources Created:${NC}"
echo "  • Resource Group: $RESOURCE_GROUP"
echo "  • Container Registry: $ACR_NAME"
echo "  • Database Server: $DB_SERVER_NAME"
echo "  • Web App: $WEB_APP_NAME"
echo ""
echo -e "${BLUE}🌐 Your Application URL:${NC}"
echo "  https://${WEB_APP_NAME}.azurewebsites.net"
echo ""
echo "=========================================="
echo "GitHub Secrets Configuration"
echo "=========================================="
echo ""
echo -e "${YELLOW}Add these secrets to GitHub:${NC}"
echo "https://github.com/Sneha-Martin18/Learnova/settings/secrets/actions"
echo ""
echo -e "${GREEN}AZURE_CREDENTIALS:${NC}"
echo "$SP_OUTPUT"
echo ""
echo -e "${GREEN}ACR_LOGIN_SERVER:${NC}"
echo "$ACR_LOGIN_SERVER"
echo ""
echo -e "${GREEN}ACR_USERNAME:${NC}"
echo "$ACR_USERNAME"
echo ""
echo -e "${GREEN}ACR_PASSWORD:${NC}"
echo "$ACR_PASSWORD"
echo ""
echo "=========================================="
echo "Next Steps"
echo "=========================================="
echo ""
echo "1. Add the secrets above to GitHub"
echo "2. Update AZURE_WEBAPP_NAME in .github/workflows/azure-deploy.yml to: $WEB_APP_NAME"
echo "3. Push code to trigger deployment:"
echo "   git add ."
echo "   git commit -m 'feat: Add Azure deployment'"
echo "   git push origin main"
echo ""
echo "4. Monitor deployment:"
echo "   https://github.com/Sneha-Martin18/Learnova/actions"
echo ""
echo "5. Access your app:"
echo "   https://${WEB_APP_NAME}.azurewebsites.net"
echo ""
echo -e "${GREEN}🎉 Setup complete! Ready to deploy!${NC}"
echo ""
