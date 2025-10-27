# Monolithic CI/CD Setup

## Overview

The CI/CD pipeline has been configured to run the project in **monolithic architecture** instead of microservices.

## Changes Made

### 1. Active CI/CD Pipeline
- **File**: `.github/workflows/ci-cd.yml`
- **Status**: ✅ Active
- **Architecture**: Monolithic Django Application

### 2. Disabled Workflows
- **File**: `.github/workflows/microservices-ci-cd.yml.disabled`
- **Status**: ❌ Disabled (renamed to prevent execution)
- **Architecture**: Microservices (not in use)

## Pipeline Structure

The monolithic CI/CD pipeline includes the following jobs:

### 1. Code Quality & Linting
- Black (code formatting)
- isort (import sorting)
- Flake8 (linting)
- Bandit (security linting)

### 2. Test Django Monolith
- Runs Django unit tests
- Uses PostgreSQL for testing
- Generates coverage reports
- Uploads test artifacts

### 3. Build Docker Image
- Builds single monolithic Docker image
- Uses root `Dockerfile`
- Caches layers for faster builds
- Tags with commit SHA and 'latest'

### 4. Security Scanning
- Trivy vulnerability scanner
- Dependency checks with Safety
- SARIF report upload to GitHub Security

### 5. Integration Tests
- Database migrations
- Static file collection
- Deployment readiness checks
- Server startup validation

### 6. Build Summary
- Generates comprehensive build report
- Shows job statuses
- Documents architecture type

### 7. Deploy to Staging
- Triggers on `develop` branch
- Manual deployment control
- Environment: staging

### 8. Deploy to Production
- Triggers on `main` branch
- Manual deployment control
- Environment: production

## Triggers

The pipeline runs on:
- **Push** to `main`, `master`, or `develop` branches
- **Pull requests** to `main`, `master`, or `develop` branches
- **Manual trigger** via workflow_dispatch

## Key Differences from Microservices Pipeline

| Aspect | Microservices | Monolithic |
|--------|--------------|------------|
| **Services Tested** | 8+ individual services | Single Django app |
| **Docker Images** | 10+ images | 1 image |
| **Complexity** | High (matrix builds) | Low (single build) |
| **Build Time** | Longer (parallel builds) | Faster (single build) |
| **Dependencies** | Multiple requirements.txt | Single requirements.txt |
| **Database** | PostgreSQL + Redis | SQLite (dev) / PostgreSQL (prod) |

## Running Locally

To run the monolithic application locally:

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run migrations
python manage.py migrate

# Collect static files
python manage.py collectstatic --noinput

# Run development server
python manage.py runserver
```

## Docker Build

To build the monolithic Docker image:

```bash
# Build image
docker build -t learnova-monolith:latest .

# Run container
docker run -p 8000:8000 learnova-monolith:latest
```

## Environment Variables

The pipeline uses these environment variables:

- `PYTHON_VERSION`: '3.11'
- `DJANGO_SETTINGS_MODULE`: 'student_management_system.settings'
- `SECRET_KEY`: (set in CI environment)
- `DEBUG`: 'False' (in CI/CD)
- `DATABASE_URL`: (PostgreSQL connection string)

## Deployment

### Staging Deployment
- Automatically triggers on push to `develop` branch
- Environment URL: https://staging.learnova.com
- Requires manual approval

### Production Deployment
- Automatically triggers on push to `main` branch
- Environment URL: https://learnova.com
- Requires manual approval

## Monitoring

View pipeline status:
1. Go to GitHub repository
2. Click on "Actions" tab
3. Select "Monolithic CI/CD Pipeline"
4. View run history and logs

## Status Badge

Add this to your README.md:

```markdown
![Monolithic CI/CD](https://github.com/Sneha-Martin18/Learnova/workflows/Monolithic%20CI/CD%20Pipeline/badge.svg)
```

## Troubleshooting

### Pipeline Fails on Tests
- Check test logs in GitHub Actions
- Run tests locally: `python manage.py test`
- Ensure all dependencies are installed

### Docker Build Fails
- Verify Dockerfile exists in root directory
- Check Docker build logs
- Test locally: `docker build -t test .`

### Deployment Fails
- Verify GitHub Secrets are configured
- Check server connectivity
- Review deployment logs

## Next Steps

1. ✅ Monolithic CI/CD pipeline is active
2. ⏭️ Configure deployment secrets (if deploying)
3. ⏭️ Set up staging/production environments
4. ⏭️ Add custom deployment scripts (if needed)

## Reverting to Microservices

If you need to switch back to microservices:

```bash
# Rename files
mv .github/workflows/microservices-ci-cd.yml.disabled .github/workflows/microservices-ci-cd.yml
mv .github/workflows/ci-cd.yml .github/workflows/ci-cd-monolithic.yml.disabled
```

## Support

For issues or questions:
- Check workflow logs in GitHub Actions
- Review [CICD_DOCUMENTATION.md](.github/CICD_DOCUMENTATION.md)
- Open an issue in the repository
