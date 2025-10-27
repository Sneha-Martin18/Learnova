# Azure Deployment Troubleshooting

## Current Issue: Application Error

The app is showing "Application Error" after deployment.

## Root Cause Identified

1. **Quota Exceeded** - Free F1 tier exceeded 60 min/day CPU quota
2. **Upgraded to B1 tier** - Now has unlimited CPU time
3. **App still not starting** - Configuration or code issue

## Actions Taken

1. ✅ Upgraded from F1 (Free) to B1 (Basic) tier
2. ✅ Database uploaded to Azure Storage (332KB)
3. ✅ Startup command simplified
4. ✅ Environment variables configured
5. ✅ Multiple restarts attempted

## Current Configuration

**Pricing Tier:** B1 Basic (~$13/month, but covered by student credits)
**Startup Command:** `python manage.py migrate --noinput && gunicorn --bind=0.0.0.0:8000 --timeout 600 student_management_system.wsgi:application`
**Database:** SQLite in Azure Blob Storage
**Static Files:** Azure Blob Storage configured

## Quick Fix Options

### Option 1: Enable Always On (Recommended)

```bash
az webapp config set --resource-group Learnova-rg --name Learnova-05594 --always-on true
az webapp restart --resource-group Learnova-rg --name Learnova-05594
```

### Option 2: Check Application Logs

```bash
# Enable detailed logging
az webapp log config --resource-group Learnova-rg --name Learnova-05594 --application-logging filesystem --level verbose

# View logs
az webapp log tail --resource-group Learnova-rg --name Learnova-05594
```

### Option 3: Simplify Startup

Remove database download complexity temporarily:

```bash
az webapp config set --resource-group Learnova-rg --name Learnova-05594 --startup-file "gunicorn --bind=0.0.0.0:8000 student_management_system.wsgi:application"
az webapp restart --resource-group Learnova-rg --name Learnova-05594
```

## Cost Information

**Previous:** F1 Free tier - $0/month (but quota exceeded)
**Current:** B1 Basic tier - ~$13/month

**Good News:** You have $100 Azure student credits, so this is covered for ~7 months

## Next Steps

1. Enable "Always On" feature
2. Check detailed logs for specific errors
3. Consider simplifying the startup process
4. May need to debug Python/Django configuration

## Resources Created

- Web App: Learnova-05594
- Storage Account: Learnovastatic18774
- App Service Plan: Learnova-plan (B1 tier)
- Database: Uploaded to Azure Storage

## URL

http://Learnova-05594.azurewebsites.net (currently showing error)
