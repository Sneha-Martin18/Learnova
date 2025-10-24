#!/bin/bash

# Minimal Azure Deployment - Free Tier Only (No Database)
# Uses SQLite for now, can upgrade to PostgreSQL later

set -e

# Configuration
DJANGO_SECRET=$(python3 -c "import secrets; print(secrets.token_urlsafe(50))")
RESOURCE_GROUP="learnova-rg"
LOCATION="eastus"
APP_PLAN="learnova-plan"
WEB_APP="learnova-app-$(date +%s | tail -c 4)"

echo "🚀 Azure Minimal Deployment (Free Tier)"
echo ""

SUBSCRIPTION_ID=$(az account show --query id --output tsv)
echo "Subscription: $SUBSCRIPTION_ID"
echo ""

# 1. App Service Plan
echo "[1/3] Creating App Service Plan (Free tier)..."
az appservice plan create \
  --name $APP_PLAN \
  --resource-group $RESOURCE_GROUP \
  --is-linux \
  --sku F1 \
  --output none
echo "✅ Done"

# 2. Web App
echo "[2/3] Creating Web App..."
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

# Set environment variables (using SQLite)
az webapp config appsettings set \
  --resource-group $RESOURCE_GROUP \
  --name $WEB_APP \
  --settings \
    DJANGO_SETTINGS_MODULE=student_management_system.settings \
    SECRET_KEY="$DJANGO_SECRET" \
    DEBUG=False \
    ALLOWED_HOSTS="${WEB_APP}.azurewebsites.net" \
    WEBSITES_PORT=8000 \
  --output none

echo "✅ Done"

# 3. Service Principal
echo "[3/3] Creating Service Principal..."
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
echo "🌐 App URL: https://${WEB_APP}.azurewebsites.net"
echo ""

# Save credentials
cat > azure_credentials.txt << EOF
========================================
Azure Deployment Info
========================================

App URL: https://${WEB_APP}.azurewebsites.net
Resource Group: $RESOURCE_GROUP
Web App Name: $WEB_APP

Django Secret: $DJANGO_SECRET

========================================
GitHub Secrets
========================================

Add to: https://github.com/Sneha-Martin18/Learnova/settings/secrets/actions

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
echo "2. Commit and push:"
echo "   git add ."
echo "   git commit -m 'feat: Deploy to Azure'"
echo "   git push origin main"
echo ""
echo "🎉 Done! GitHub Actions will deploy automatically."
