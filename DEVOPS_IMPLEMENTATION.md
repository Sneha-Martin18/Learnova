# DevOps Implementation Guide - Learnova Student Management System

## 🎯 Overview

This document describes the complete DevOps CI/CD implementation for the Learnova Student Management System, a microservices-based application built with Django and Flask.

---

## 🏗️ Architecture

### Microservices Stack

1. **API Gateway** (Flask) - Port 8080
   - Routes requests to appropriate services
   - Handles authentication and authorization
   - Load balancing

2. **User Management Service** (Django) - Port 8000
   - User authentication and authorization
   - Profile management
   - JWT token generation
   - Celery workers for async tasks

3. **Academic Service** (Django) - Port 8001
   - Course management
   - Class scheduling
   - Academic records

4. **Attendance Service** (Django) - Port 8002
   - Attendance tracking
   - Reports generation

5. **Notification Service** (Django + Celery) - Port 8003
   - Email notifications (SendGrid)
   - SMS notifications (Twilio)
   - Push notifications
   - Celery workers and beat scheduler

6. **Leave Management Service** (Django + Celery) - Port 8004
   - Leave applications
   - Approval workflows
   - Celery workers and beat scheduler

7. **Feedback Service** (Django + Celery) - Port 8005
   - Student feedback
   - Course evaluations
   - Celery workers and beat scheduler

8. **Assessment Service** (Django + Celery) - Port 8006
   - Exam management
   - Grade calculation
   - Result publishing
   - Celery workers and beat scheduler

9. **Financial Service** (Django + Celery) - Port 8007
   - Fee management
   - Payment processing
   - Invoice generation
   - Celery workers and beat scheduler

10. **Frontend Service** (Django) - Port 9000
    - Web interface
    - Template rendering
    - Static file serving

### Infrastructure

- **Database**: PostgreSQL 15
- **Cache/Message Broker**: Redis 7
- **Task Queue**: Celery
- **Web Server**: Gunicorn
- **Containerization**: Docker & Docker Compose

---

## 🚀 CI/CD Pipeline

### Workflow Files

1. **`microservices-ci-cd.yml`** - Main CI/CD pipeline
2. **`docker-compose-test.yml`** - Full stack integration tests
3. **`pull-request-checks.yml`** - PR validation
4. **`stale-pr-cleanup.yml`** - Automated PR cleanup

### Pipeline Stages

#### Stage 1: Code Quality (Parallel)
- **Black** - Code formatting check
- **isort** - Import sorting check
- **Flake8** - Linting
- **Bandit** - Security linting
- **Safety** - Dependency vulnerability check

#### Stage 2: Testing (Parallel)

**Monolith Tests:**
- Django test suite
- Coverage reporting
- PostgreSQL integration

**Microservices Tests:**
- Individual service testing
- Matrix strategy for 8 services
- PostgreSQL + Redis integration
- Pytest + pytest-django

#### Stage 3: Docker Build (Parallel)
- Build all 11 Docker images
- Multi-stage builds
- Layer caching with GitHub Actions cache
- Image tagging with commit SHA

#### Stage 4: Integration Tests
- Docker Compose orchestration
- Service health checks
- End-to-end testing
- Log collection and artifact upload

#### Stage 5: Security Scanning
- **Trivy** - Filesystem and config scanning
- **SARIF** report upload to GitHub Security
- Dependency vulnerability checks

#### Stage 6: Performance Tests (Main branch only)
- Load testing with k6
- Performance benchmarking
- Response time validation

#### Stage 7: Deployment

**Staging** (develop branch):
- Automated deployment to staging environment
- Smoke tests
- Environment validation

**Production** (main branch):
- Manual approval required
- Blue-green deployment
- Rollback capability
- Deployment notifications

---

## 📋 Workflow Triggers

### Automatic Triggers

```yaml
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]
  workflow_dispatch:  # Manual trigger
```

### Branch Strategy

- **`main`** - Production branch
  - Triggers full pipeline + production deployment
  - Requires all tests to pass
  - Protected branch with required reviews

- **`develop`** - Development branch
  - Triggers full pipeline + staging deployment
  - Integration testing environment

- **Feature branches** - Pull requests
  - Code quality checks
  - Unit tests
  - Docker build validation

---

## 🐳 Docker Configuration

### Dockerfile Best Practices

All services follow these patterns:

1. **Multi-stage builds** (where applicable)
2. **Non-root user** for security
3. **Health checks** for monitoring
4. **Layer caching** optimization
5. **Minimal base images** (slim variants)

### Example Dockerfile Structure

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc postgresql-client curl \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create non-root user
RUN adduser --disabled-password --gecos '' appuser
RUN chown -R appuser:appuser /app
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:8000/health/ || exit 1

# Run application
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "wsgi:application"]
```

### Docker Compose Orchestration

**Development:**
```bash
cd microservices
docker compose up -d
```

**Production:**
```bash
docker compose -f docker-compose.prod.yml up -d
```

**Testing:**
```bash
docker compose -f docker-compose.test.yml up --abort-on-container-exit
```

---

## 🔒 Security Measures

### Code Security

1. **Bandit** - Python security linter
2. **Safety** - Dependency vulnerability scanner
3. **Trivy** - Container and filesystem scanner
4. **SARIF** reports uploaded to GitHub Security

### Container Security

1. Non-root users in containers
2. Minimal base images
3. No secrets in images
4. Regular security scans

### Secrets Management

- Use GitHub Secrets for sensitive data
- Environment-specific configurations
- Never commit secrets to repository

```yaml
env:
  DB_PASSWORD: ${{ secrets.DB_PASSWORD }}
  SECRET_KEY: ${{ secrets.DJANGO_SECRET_KEY }}
  SENDGRID_API_KEY: ${{ secrets.SENDGRID_API_KEY }}
```

---

## 📊 Monitoring and Logging

### Health Checks

All services implement health check endpoints:

- `/health/` - Service health status
- `/api/v1/{service}/health/` - Detailed health info

### Logging

- Centralized logging with Docker Compose
- Log aggregation in CI/CD
- Artifact upload for debugging

### Metrics

- Service response times
- Error rates
- Resource utilization
- Test coverage reports

---

## 🧪 Testing Strategy

### Unit Tests
- Individual service testing
- Mock external dependencies
- Fast execution

### Integration Tests
- Service-to-service communication
- Database interactions
- Redis caching

### End-to-End Tests
- Full stack with Docker Compose
- Real database and Redis
- API endpoint testing

### Performance Tests
- Load testing with k6
- Stress testing
- Scalability validation

---

## 📦 Artifacts and Reports

### Generated Artifacts

1. **Coverage Reports** - HTML coverage reports
2. **Security Reports** - Bandit JSON reports
3. **Test Logs** - Integration test logs
4. **Docker Logs** - Service logs from Docker Compose

### Accessing Artifacts

```bash
# Download from GitHub Actions UI
# Or use GitHub CLI
gh run download <run-id> -n coverage-report
gh run download <run-id> -n bandit-security-report
gh run download <run-id> -n docker-compose-logs
```

---

## 🚀 Deployment

### Staging Deployment

Triggered on push to `develop` branch:

```yaml
deploy-staging:
  if: github.ref == 'refs/heads/develop'
  environment:
    name: staging
    url: https://staging.Learnova.com
```

### Production Deployment

Triggered on push to `main` branch:

```yaml
deploy-production:
  if: github.ref == 'refs/heads/main'
  environment:
    name: production
    url: https://Learnova.com
```

### Deployment Steps

1. Build Docker images
2. Push to container registry
3. Update environment configuration
4. Deploy with Docker Compose/Kubernetes
5. Run smoke tests
6. Monitor deployment

---

## 🛠️ Local Development

### Prerequisites

- Docker Desktop or Docker Engine
- Docker Compose v2+
- Python 3.11+
- Git

### Setup

```bash
# Clone repository
git clone https://github.com/Sneha-Martin18/Learnova.git
cd Learnova

# Start microservices
cd microservices
docker compose up -d

# Check service status
docker compose ps

# View logs
docker compose logs -f

# Stop services
docker compose down
```

### Running Tests Locally

```bash
# Run all tests
python -m pytest

# Run specific service tests
cd microservices/user-management-service
python manage.py test

# Run with coverage
coverage run --source='.' manage.py test
coverage report
coverage html
```

---

## 📈 Performance Optimization

### Docker Build Optimization

1. **Layer caching** - Order Dockerfile commands efficiently
2. **Multi-stage builds** - Reduce final image size
3. **Parallel builds** - Use `docker compose build --parallel`
4. **BuildKit** - Enable for better caching

### CI/CD Optimization

1. **Parallel jobs** - Run independent jobs concurrently
2. **Matrix strategy** - Test multiple services in parallel
3. **Caching** - Cache pip dependencies and Docker layers
4. **Conditional execution** - Skip unnecessary jobs

---

## 🐛 Troubleshooting

### Common Issues

**Issue: Docker build fails**
```bash
# Clear Docker cache
docker builder prune -a

# Rebuild without cache
docker compose build --no-cache
```

**Issue: Service won't start**
```bash
# Check logs
docker compose logs <service-name>

# Check health
docker compose ps
```

**Issue: Tests fail locally but pass in CI**
```bash
# Ensure same Python version
python --version

# Clear pytest cache
rm -rf .pytest_cache __pycache__

# Reinstall dependencies
pip install -r requirements.txt --force-reinstall
```

### Debugging CI/CD

1. Check workflow logs in GitHub Actions
2. Download artifacts for detailed reports
3. Run workflows manually with `workflow_dispatch`
4. Test Docker builds locally first

---

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Django Testing](https://docs.djangoproject.com/en/stable/topics/testing/)
- [Celery Documentation](https://docs.celeryq.dev/)

---

## 🎓 DevOps Best Practices Implemented

✅ **Continuous Integration** - Automated testing on every commit
✅ **Continuous Deployment** - Automated deployment to staging/production
✅ **Infrastructure as Code** - Docker Compose configurations
✅ **Security Scanning** - Automated vulnerability detection
✅ **Code Quality** - Automated linting and formatting checks
✅ **Testing Strategy** - Unit, integration, and E2E tests
✅ **Monitoring** - Health checks and logging
✅ **Documentation** - Comprehensive guides and comments
✅ **Version Control** - Git workflow with protected branches
✅ **Artifact Management** - Test reports and logs

---

**Last Updated:** 2025-10-24
**Version:** 1.0.0
**Maintained by:** DevOps Team
