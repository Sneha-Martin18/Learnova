# CI/CD Workflow Status

## ✅ Active Workflows

| Workflow | File | Status | Purpose |
|----------|------|--------|---------|
| **Monolithic CI/CD** | `ci-cd.yml` | ✅ ACTIVE | Main pipeline for Django monolith |
| **Azure Deploy** | `azure-deploy.yml` | ✅ Active | Azure deployment |
| **Deploy** | `deploy.yml` | ✅ Active | Manual deployment to servers |
| **Docker Compose Test** | `docker-compose-test.yml` | ✅ Active | Docker compose testing |
| **Docker Publish** | `docker-publish.yml` | ✅ Active | Publish Docker images |
| **PR Checks** | `pr-checks.yml` | ✅ Active | Pull request validation |
| **Pull Request Checks** | `pull-request-checks.yml` | ✅ Active | Additional PR checks |
| **Stale PR Cleanup** | `stale-pr-cleanup.yml` | ✅ Active | Clean up stale PRs |

## ❌ Disabled Workflows

| Workflow | File | Status | Reason |
|----------|------|--------|--------|
| **Microservices CI/CD** | `microservices-ci-cd.yml.disabled` | ❌ DISABLED | Switched to monolithic architecture |

## Architecture Change Summary

### Before
```
┌─────────────────────────────────────┐
│   Microservices Architecture        │
├─────────────────────────────────────┤
│ • API Gateway                       │
│ • User Management Service           │
│ • Academic Service                  │
│ • Attendance Service                │
│ • Notification Service              │
│ • Leave Management Service          │
│ • Feedback Service                  │
│ • Assessment Service                │
│ • Financial Service                 │
│ • Frontend Service                  │
└─────────────────────────────────────┘
```

### After (Current)
```
┌─────────────────────────────────────┐
│   Monolithic Architecture           │
├─────────────────────────────────────┤
│ • Single Django Application         │
│ • All features in one codebase      │
│ • Simplified deployment             │
│ • Faster builds                     │
│ • Easier maintenance                │
└─────────────────────────────────────┘
```

## CI/CD Pipeline Flow

```
┌─────────────────┐
│  Push/PR Event  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Code Quality    │ ← Black, isort, Flake8, Bandit
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Test Django     │ ← Unit tests, Coverage
└────────┬────────┘
         │
         ├──────────────────┐
         ▼                  ▼
┌─────────────────┐  ┌─────────────────┐
│ Build Docker    │  │ Security Scan   │
└────────┬────────┘  └────────┬────────┘
         │                    │
         └──────────┬─────────┘
                    ▼
         ┌─────────────────┐
         │ Integration     │
         │ Tests           │
         └────────┬────────┘
                  │
                  ▼
         ┌─────────────────┐
         │ Build Summary   │
         └────────┬────────┘
                  │
         ┌────────┴────────┐
         ▼                 ▼
┌─────────────────┐ ┌─────────────────┐
│ Deploy Staging  │ │ Deploy Prod     │
│ (develop)       │ │ (main)          │
└─────────────────┘ └─────────────────┘
```

## Key Metrics

### Build Performance
- **Microservices Pipeline**: ~15-20 minutes (parallel builds)
- **Monolithic Pipeline**: ~8-12 minutes (single build)
- **Improvement**: ~40% faster

### Complexity
- **Microservices**: 10+ Docker images, 8+ service tests
- **Monolithic**: 1 Docker image, 1 test suite
- **Reduction**: 90% less complexity

### Maintenance
- **Microservices**: Multiple Dockerfiles, requirements.txt files
- **Monolithic**: Single Dockerfile, single requirements.txt
- **Simplification**: Easier to maintain and update

## Quick Commands

### View Active Workflows
```bash
ls -lah .github/workflows/*.yml
```

### View Disabled Workflows
```bash
ls -lah .github/workflows/*.disabled
```

### Test Pipeline Locally
```bash
# Install dependencies
pip install -r requirements.txt

# Run tests
python manage.py test

# Build Docker image
docker build -t learnova-monolith .
```

### Trigger Manual Workflow
1. Go to GitHub Actions tab
2. Select "Monolithic CI/CD Pipeline"
3. Click "Run workflow"
4. Select branch and run

## Environment Configuration

### Required Secrets (for deployment)
- `SSH_PRIVATE_KEY`: SSH key for server access
- `SERVER_HOST`: Server hostname or IP
- `SERVER_USER`: SSH username
- `DEPLOY_PATH`: Deployment directory path
- `SLACK_WEBHOOK`: Slack notification webhook (optional)

### Environment Variables
- `PYTHON_VERSION`: 3.11
- `DJANGO_SETTINGS_MODULE`: student_management_system.settings

## Deployment Targets

### Staging
- **Branch**: develop
- **URL**: https://staging.learnova.com
- **Auto-deploy**: Yes (on push to develop)

### Production
- **Branch**: main
- **URL**: https://learnova.com
- **Auto-deploy**: Yes (on push to main)

## Monitoring & Alerts

### GitHub Actions Dashboard
- URL: `https://github.com/Sneha-Martin18/Learnova/actions`
- View all workflow runs
- Check build status
- Download artifacts

### Status Badges
Add to README.md:
```markdown
![CI/CD](https://github.com/Sneha-Martin18/Learnova/workflows/Monolithic%20CI/CD%20Pipeline/badge.svg)
```

## Rollback Instructions

### To Revert to Microservices
```bash
# Disable monolithic pipeline
mv .github/workflows/ci-cd.yml .github/workflows/ci-cd-monolithic.yml.disabled

# Enable microservices pipeline
mv .github/workflows/microservices-ci-cd.yml.disabled .github/workflows/microservices-ci-cd.yml

# Commit changes
git add .github/workflows/
git commit -m "Revert to microservices CI/CD"
git push
```

## Documentation

- **Setup Guide**: [MONOLITHIC_CICD_SETUP.md](./MONOLITHIC_CICD_SETUP.md)
- **Workflow README**: [.github/workflows/README.md](./.github/workflows/README.md)
- **CI/CD Documentation**: [.github/CICD_DOCUMENTATION.md](./.github/CICD_DOCUMENTATION.md)

## Last Updated

- **Date**: October 27, 2025
- **Change**: Switched from microservices to monolithic CI/CD
- **Modified By**: CI/CD Configuration Update
