# DevOps Quick Start Guide

## 🚀 Quick Commands

### Local Development

```bash
# Start all microservices
cd microservices
docker compose up -d

# View running services
docker compose ps

# View logs
docker compose logs -f

# Stop all services
docker compose down

# Rebuild and restart
docker compose up -d --build
```

### Testing

```bash
# Run monolith tests
python manage.py test

# Run specific microservice tests
cd microservices/user-management-service
python manage.py test

# Run with coverage
coverage run --source='.' manage.py test
coverage report
```

### CI/CD

```bash
# View workflow runs
gh run list --limit 10

# Watch latest workflow
gh run watch

# View workflow in browser
gh run view --web

# Trigger workflow manually
gh workflow run microservices-ci-cd.yml
```

---

## 📊 CI/CD Workflows

### 1. Main Pipeline: `microservices-ci-cd.yml`

**Triggers:** Push to main/develop, Pull requests

**Jobs:**
- ✅ Code Quality (Black, isort, Flake8, Bandit)
- ✅ Test Monolith (Django tests + coverage)
- ✅ Test Microservices (8 services in parallel)
- ✅ Build Docker Images (11 images)
- ✅ Integration Tests (Docker Compose)
- ✅ Security Scan (Trivy)
- ✅ Performance Tests (k6)
- ✅ Deploy Staging (develop branch)
- ✅ Deploy Production (main branch)

### 2. Docker Compose Tests: `docker-compose-test.yml`

**Triggers:** Push, Pull requests

**What it does:**
- Builds all services
- Starts infrastructure (Postgres, Redis)
- Tests service health checks
- Validates service communication
- Collects logs

### 3. PR Checks: `pull-request-checks.yml`

**Triggers:** Pull requests

**What it does:**
- Validates PR title (conventional commits)
- Checks for large files
- Detects merge conflicts
- Quick lint checks
- Auto-labels PRs

---

## 🏗️ Architecture Overview

```
┌─────────────────┐
│   API Gateway   │ :8080 (Flask)
└────────┬────────┘
         │
    ┌────┴────────────────────────────────────┐
    │                                         │
┌───▼────────┐  ┌──────────┐  ┌────────────┐
│ User Mgmt  │  │ Academic │  │ Attendance │
│   :8000    │  │  :8001   │  │   :8002    │
└────────────┘  └──────────┘  └────────────┘

┌──────────────┐  ┌──────────┐  ┌──────────┐
│ Notification │  │  Leave   │  │ Feedback │
│    :8003     │  │  :8004   │  │  :8005   │
└──────────────┘  └──────────┘  └──────────┘

┌──────────────┐  ┌──────────┐  ┌──────────┐
│ Assessment   │  │Financial │  │ Frontend │
│    :8006     │  │  :8007   │  │  :9000   │
└──────────────┘  └──────────┘  └──────────┘

Infrastructure:
- PostgreSQL :5433
- Redis :6379
- Celery Workers & Beat Schedulers
```

---

## 🔧 Service Ports

| Service | Port | Type | Celery |
|---------|------|------|--------|
| API Gateway | 8080 | Flask | No |
| User Management | 8000 | Django | Yes |
| Academic | 8001 | Django | No |
| Attendance | 8002 | Django | No |
| Notification | 8003 | Django | Yes |
| Leave Management | 8004 | Django | Yes |
| Feedback | 8005 | Django | Yes |
| Assessment | 8006 | Django | Yes |
| Financial | 8007 | Django | Yes |
| Frontend | 9000 | Django | No |
| PostgreSQL | 5433 | Database | - |
| Redis | 6379 | Cache/Queue | - |

---

## 📝 Workflow Status

### View in GitHub

```
https://github.com/Sneha-Martin18/Learnova/actions
```

### Check Status via CLI

```bash
# List recent runs
gh run list --workflow=microservices-ci-cd.yml --limit 5

# View specific run
gh run view <run-id>

# View logs
gh run view <run-id> --log

# Download artifacts
gh run download <run-id>
```

---

## 🐛 Common Issues & Solutions

### Issue: Service won't start

```bash
# Check logs
docker compose logs <service-name>

# Restart service
docker compose restart <service-name>

# Rebuild service
docker compose up -d --build <service-name>
```

### Issue: Database connection error

```bash
# Check if Postgres is running
docker compose ps postgres

# Check Postgres logs
docker compose logs postgres

# Restart Postgres
docker compose restart postgres
```

### Issue: Celery worker not processing tasks

```bash
# Check Celery worker logs
docker compose logs <service>-celery

# Restart Celery worker
docker compose restart <service>-celery

# Check Redis connection
docker compose exec redis redis-cli ping
```

### Issue: CI/CD workflow failing

```bash
# View workflow logs in GitHub Actions
# Download artifacts for detailed reports
gh run download <run-id> -n coverage-report
gh run download <run-id> -n bandit-security-report

# Run tests locally first
python manage.py test
docker compose -f microservices/docker-compose.yml up --build
```

---

## 🎯 Best Practices

### Before Pushing Code

1. ✅ Run tests locally
2. ✅ Check code formatting: `black .`
3. ✅ Sort imports: `isort .`
4. ✅ Run linter: `flake8 .`
5. ✅ Build Docker images locally
6. ✅ Test with Docker Compose

### Pull Request Guidelines

1. ✅ Use conventional commit format
   - `feat: add new feature`
   - `fix: resolve bug`
   - `docs: update documentation`
   - `refactor: improve code structure`

2. ✅ Keep PRs small and focused
3. ✅ Add tests for new features
4. ✅ Update documentation
5. ✅ Ensure CI/CD passes

### Deployment Checklist

**Staging:**
- ✅ All tests pass
- ✅ Code review approved
- ✅ Merge to `develop` branch
- ✅ Auto-deploy to staging
- ✅ Verify staging environment

**Production:**
- ✅ Tested in staging
- ✅ All tests pass
- ✅ Security scan passed
- ✅ Performance tests passed
- ✅ Merge to `main` branch
- ✅ Manual approval
- ✅ Deploy to production
- ✅ Monitor deployment

---

## 📊 Monitoring

### Health Checks

```bash
# Check all services
curl http://localhost:8080/health  # API Gateway
curl http://localhost:8000/api/v1/users/health/  # User Management
curl http://localhost:8001/api/v1/academics/health/  # Academic
curl http://localhost:8002/api/v1/attendance/health/  # Attendance
```

### View Metrics

```bash
# Service status
docker compose ps

# Resource usage
docker stats

# Logs
docker compose logs -f --tail=100
```

---

## 🔐 Security

### Secrets Management

Never commit:
- Database passwords
- API keys (SendGrid, Twilio)
- Secret keys
- Tokens

Use GitHub Secrets:
```yaml
env:
  SECRET_KEY: ${{ secrets.DJANGO_SECRET_KEY }}
  DB_PASSWORD: ${{ secrets.DB_PASSWORD }}
```

### Security Scans

Automated in CI/CD:
- Bandit (Python security)
- Safety (Dependencies)
- Trivy (Containers)

---

## 📚 Documentation

- **Full Guide:** `DEVOPS_IMPLEMENTATION.md`
- **Architecture:** `PROJECT_REPORT.md`
- **Microservices:** `MICROSERVICES_MIGRATION_GUIDE.md`
- **Workflow Tools:** `UNIFIED_WORKFLOW_VIEW_GUIDE.md`
- **PR Management:** `PR_MANAGEMENT_GUIDE.md`

---

**Quick Links:**
- [GitHub Actions](https://github.com/Sneha-Martin18/Learnova/actions)
- [Repository](https://github.com/Sneha-Martin18/Learnova)
- [Issues](https://github.com/Sneha-Martin18/Learnova/issues)
- [Pull Requests](https://github.com/Sneha-Martin18/Learnova/pulls)
