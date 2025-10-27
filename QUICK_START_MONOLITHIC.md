# Quick Start Guide - Monolithic Architecture

## ✅ What Changed

Your CI/CD pipeline now runs the **monolithic Django application** instead of microservices.

## 🚀 Running Locally

The project is already running! Access it at: **http://127.0.0.1:8000/**

### Commands Used
```bash
# Created virtual environment
python3 -m venv venv

# Installed dependencies
./venv/bin/pip install -r requirements.txt

# Ran migrations
./venv/bin/python manage.py migrate

# Started server
./venv/bin/python manage.py runserver
```

### To Stop the Server
Press `CTRL+C` in the terminal

### To Restart the Server
```bash
./venv/bin/python manage.py runserver
```

## 📋 CI/CD Changes

### Active Pipeline
- **File**: `.github/workflows/ci-cd.yml`
- **Name**: Monolithic CI/CD Pipeline
- **Architecture**: Single Django Application

### What It Does
1. ✅ Code quality checks (Black, isort, Flake8)
2. ✅ Runs Django tests
3. ✅ Builds single Docker image
4. ✅ Security scanning
5. ✅ Integration tests
6. ✅ Auto-deploys to staging/production

### Disabled Pipeline
- **File**: `.github/workflows/microservices-ci-cd.yml.disabled`
- **Status**: Disabled (won't run)

## 🔄 How CI/CD Triggers

The monolithic pipeline runs when you:
- Push to `main`, `master`, or `develop` branches
- Create a pull request
- Manually trigger from GitHub Actions

## 📊 Pipeline Jobs

```
1. Code Quality      → Linting and formatting checks
2. Test Django       → Unit tests with coverage
3. Build Docker      → Single monolithic image
4. Security Scan     → Vulnerability checks
5. Integration Tests → Full app testing
6. Build Summary     → Results report
7. Deploy Staging    → Auto-deploy on develop branch
8. Deploy Production → Auto-deploy on main branch
```

## 🐳 Docker Build

To build the monolithic Docker image:

```bash
docker build -t learnova-monolith:latest .
docker run -p 8000:8000 learnova-monolith:latest
```

## 📁 Project Structure

```
Learnova/
├── student_management_app/     # Main Django app
├── student_management_system/  # Django settings
├── gateway/                    # Gateway middleware
├── static/                     # Static files
├── media/                      # Media files
├── manage.py                   # Django management
├── requirements.txt            # Python dependencies
├── Dockerfile                  # Docker configuration
└── .github/
    └── workflows/
        ├── ci-cd.yml          # ✅ ACTIVE (Monolithic)
        └── microservices-ci-cd.yml.disabled  # ❌ Disabled
```

## 📚 Documentation

- **CI/CD Setup**: [MONOLITHIC_CICD_SETUP.md](./MONOLITHIC_CICD_SETUP.md)
- **Workflow Status**: [CICD_WORKFLOW_STATUS.md](./CICD_WORKFLOW_STATUS.md)
- **Workflows README**: [.github/workflows/README.md](./.github/workflows/README.md)

## 🎯 Next Steps

1. ✅ **Local server is running** at http://127.0.0.1:8000/
2. ✅ **CI/CD configured** for monolithic architecture
3. ⏭️ **Push changes** to trigger the new pipeline
4. ⏭️ **Configure deployment secrets** (if deploying to servers)

## 🔧 Common Tasks

### Run Tests
```bash
./venv/bin/python manage.py test
```

### Create Superuser
```bash
./venv/bin/python manage.py createsuperuser
```

### Collect Static Files
```bash
./venv/bin/python manage.py collectstatic
```

### Make Migrations
```bash
./venv/bin/python manage.py makemigrations
./venv/bin/python manage.py migrate
```

## 🌐 Access Points

- **Local Server**: http://127.0.0.1:8000/
- **Admin Panel**: http://127.0.0.1:8000/admin/
- **GitHub Actions**: https://github.com/Sneha-Martin18/Learnova/actions

## ✨ Benefits of Monolithic Architecture

- ✅ **Simpler deployment** - Single application to deploy
- ✅ **Faster builds** - No need to build multiple services
- ✅ **Easier debugging** - All code in one place
- ✅ **Lower complexity** - Single codebase to maintain
- ✅ **Better for small teams** - Less overhead

## 🆘 Troubleshooting

### Server Won't Start?
```bash
# Check if port 8000 is in use
lsof -i :8000

# Kill existing process
kill -9 <PID>

# Restart server
./venv/bin/python manage.py runserver
```

### CI/CD Not Running?
- Check `.github/workflows/ci-cd.yml` exists
- Verify you pushed to main/develop branch
- Check GitHub Actions tab for errors

### Dependencies Missing?
```bash
./venv/bin/pip install -r requirements.txt
```

## 📞 Support

- Check workflow logs in GitHub Actions
- Review documentation files
- Open an issue in the repository

---

**Status**: ✅ Ready to use
**Architecture**: Monolithic Django Application
**Server**: Running on http://127.0.0.1:8000/
