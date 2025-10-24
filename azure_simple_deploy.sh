#!/bin/bash

# Simplified Azure Deployment - Uses GitHub Container Registry (No ACR needed)

set -e

# Configuration
DB_PASSWORD="LearnovaDB@2024!"
DJANGO_SECRET=$(python3 -c "import secrets; print(secrets.token_urlsafe(50))")

RESOURCE_GROUP="learnova-rg"
LOCATION="eastus"
DB_SERVER="learnova-db-$(date +%s | tail -c 4)"
DB_NAME="learnova_db"
DB_USER="learnovaadmin"
APP_PLAN="learnova-plan"
WEB_APP="learnova-app-$(date +%s | tail -c 4)"

echo "🚀 Starting Azure Deployment..."
echo ""

# Get subscription
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
echo "Subscription: $SUBSCRIPTION_ID"
echo ""

# 1. Resource Group (use existing)
echo "[1/5] Using existing Resource Group..."
echo "✅ Done"

# 2. PostgreSQL
echo "[2/5] Creating PostgreSQL Database (this takes 3-5 minutes)..."
az postgres flexible-server create \
  --resource-group $RESOURCE_GROUP \
  --name $DB_SERVER \
  --location $LOCATION \
  --admin-user $DB_USER \
  --admin-password "$DB_PASSWORD" \
  --sku-name Standard_B1ms \
  --tier Burstable \
  --storage-size 32 \
  --version 13 \
  --public-access 0.0.0.0 \
  --yes \
  --output none

az postgres flexible-server db create \
  --resource-group $RESOURCE_GROUP \
  --server-name $DB_SERVER \
  --database-name $DB_NAME \
  --output none

az postgres flexible-server firewall-rule create \
  --resource-group $RESOURCE_GROUP \
  --name $DB_SERVER \
  --rule-name AllowAzure \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0 \
  --output none

echo "✅ Done"

DATABASE_URL="postgresql://${DB_USER}:${DB_PASSWORD}@${DB_SERVER}.postgres.database.azure.com:5432/${DB_NAME}?sslmode=require"

# 3. App Service Plan
echo "[3/5] Creating App Service Plan (Free tier)..."
az appservice plan create \
  --name $APP_PLAN \
  --resource-group $RESOURCE_GROUP \
  --is-linux \
  --sku F1 \
  --output none
echo "✅ Done"

# 4. Web App
echo "[4/5] Creating Web App..."
az webapp create \
  --resource-group $RESOURCE_GROUP \
  --plan $APP_PLAN \
  --name $WEB_APP \
  --deployment-container-image-name nginx \
  --output none

# Configure for GitHub Container Registry
az webapp config container set \
  --name $WEB_APP \
  --resource-group $RESOURCE_GROUP \
  --docker-custom-image-name ghcr.io/sneha-martin18/learnova:latest \
  --docker-registry-server-url https://ghcr.io \
  --output none

# Set environment variables
az webapp config appsettings set \
  --resource-group $RESOURCE_GROUP \
  --name $WEB_APP \
  --settings \
    DJANGO_SETTINGS_MODULE=student_management_system.settings \
    SECRET_KEY="$DJANGO_SECRET" \
    DEBUG=False \
    ALLOWED_HOSTS="${WEB_APP}.azurewebsites.net" \
    DATABASE_URL="$DATABASE_URL" \
    WEBSITES_PORT=8000 \
  --output none

echo "✅ Done"

# 5. Service Principal
echo "[5/5] Creating Service Principal for GitHub..."
SP_JSON=$(az ad sp create-for-rbac \
  --name "learnova-gh-$(date +%s)" \
  --role contributor \
  --scopes /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP \
  --sdk-auth 2>/dev/null)
echo "✅ Done"

echo ""
echo "=========================================="
echo "✅ DEPLOYMENT COMPLETE!"
echo "=========================================="
echo ""
echo "🌐 Your App URL:"
echo "   https://${WEB_APP}.azurewebsites.net"
echo ""
echo "💾 Saving credentials..."

# Save to file
cat > azure_credentials.txt << EOF
========================================
Azure Deployment Credentials
========================================

App URL: https://${WEB_APP}.azurewebsites.net
Resource Group: $RESOURCE_GROUP

Database:
  Server: ${DB_SERVER}.postgres.database.azure.com
  Database: $DB_NAME
  User: $DB_USER
  Password: $DB_PASSWORD
  Connection: $DATABASE_URL

Django Secret: $DJANGO_SECRET

========================================
GitHub Secrets (Add these to GitHub)
========================================

Go to: https://github.com/Sneha-Martin18/Learnova/settings/secrets/actions

1. AZURE_CREDENTIALS
$SP_JSON

2. AZURE_WEBAPP_NAME
$WEB_APP

========================================
EOF

echo "✅ Credentials saved to: azure_credentials.txt"
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. Add GitHub Secrets (see azure_credentials.txt)"
echo "2. Push code:"
echo "   git add ."
echo "   git commit -m 'feat: Deploy to Azure'"
echo "   git push origin main"
echo ""
echo "3. GitHub Actions will build and deploy automatically!"
echo ""
echo "🎉 Setup Complete!"
