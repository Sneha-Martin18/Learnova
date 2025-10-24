#!/bin/bash

# CI/CD Verification Test Script
# This script tests your CI/CD setup locally before pushing to GitHub

set -e  # Exit on error

echo "=========================================="
echo "CI/CD Verification Test Script"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to print test result
test_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ PASSED${NC}: $2"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ FAILED${NC}: $2"
        ((TESTS_FAILED++))
    fi
    echo ""
}

# Test 1: Check if Git is initialized
echo "Test 1: Checking Git repository..."
if git rev-parse --git-dir > /dev/null 2>&1; then
    test_result 0 "Git repository is initialized"
else
    test_result 1 "Git repository not found"
fi

# Test 2: Check if remote is configured
echo "Test 2: Checking Git remote..."
if git remote -v | grep -q "origin"; then
    REMOTE_URL=$(git remote get-url origin)
    echo -e "${GREEN}✓ PASSED${NC}: Git remote configured: $REMOTE_URL"
    ((TESTS_PASSED++))
else
    echo -e "${YELLOW}⚠ WARNING${NC}: No Git remote configured"
    echo "  To fix: git remote add origin https://github.com/Sneha-Martin18/Learnova.git"
    ((TESTS_FAILED++))
fi
echo ""

# Test 3: Check workflow files exist
echo "Test 3: Checking workflow files..."
WORKFLOW_FILES=("ci-cd.yml" "deploy.yml" "pr-checks.yml" "docker-publish.yml")
WORKFLOWS_OK=true
for file in "${WORKFLOW_FILES[@]}"; do
    if [ -f ".github/workflows/$file" ]; then
        echo "  ✓ Found: $file"
    else
        echo "  ✗ Missing: $file"
        WORKFLOWS_OK=false
    fi
done
if [ "$WORKFLOWS_OK" = true ]; then
    test_result 0 "All workflow files present"
else
    test_result 1 "Some workflow files missing"
fi

# Test 4: Validate YAML syntax
echo "Test 4: Validating YAML syntax..."
if command -v yamllint &> /dev/null; then
    if yamllint .github/workflows/*.yml 2>&1 | grep -q "error"; then
        test_result 1 "YAML syntax errors found"
    else
        test_result 0 "YAML syntax is valid"
    fi
else
    echo -e "${YELLOW}⚠ SKIPPED${NC}: yamllint not installed"
    echo "  Install: pip install yamllint"
    echo ""
fi

# Test 5: Check Python dependencies
echo "Test 5: Checking Python linting tools..."
PYTHON_TOOLS=("black" "isort" "flake8")
TOOLS_OK=true
for tool in "${PYTHON_TOOLS[@]}"; do
    if command -v $tool &> /dev/null; then
        echo "  ✓ Found: $tool"
    else
        echo "  ✗ Missing: $tool"
        TOOLS_OK=false
    fi
done
if [ "$TOOLS_OK" = true ]; then
    test_result 0 "All Python linting tools installed"
else
    echo -e "${YELLOW}⚠ WARNING${NC}: Some tools missing"
    echo "  Install: pip install black isort flake8"
    ((TESTS_FAILED++))
    echo ""
fi

# Test 6: Run code formatting check
echo "Test 6: Running Black (code formatting)..."
if command -v black &> /dev/null; then
    if black --check microservices/ student_management_app/ 2>&1 | grep -q "would be reformatted"; then
        echo -e "${YELLOW}⚠ WARNING${NC}: Code formatting issues found"
        echo "  Fix: black microservices/ student_management_app/"
        ((TESTS_FAILED++))
    else
        test_result 0 "Code formatting is correct"
    fi
else
    echo -e "${YELLOW}⚠ SKIPPED${NC}: black not installed"
    echo ""
fi

# Test 7: Run import sorting check
echo "Test 7: Running isort (import sorting)..."
if command -v isort &> /dev/null; then
    if isort --check-only microservices/ student_management_app/ 2>&1 | grep -q "ERROR"; then
        echo -e "${YELLOW}⚠ WARNING${NC}: Import sorting issues found"
        echo "  Fix: isort microservices/ student_management_app/"
        ((TESTS_FAILED++))
    else
        test_result 0 "Import sorting is correct"
    fi
else
    echo -e "${YELLOW}⚠ SKIPPED${NC}: isort not installed"
    echo ""
fi

# Test 8: Run linting
echo "Test 8: Running Flake8 (linting)..."
if command -v flake8 &> /dev/null; then
    if [ -f ".flake8" ]; then
        ERROR_COUNT=$(flake8 microservices/ student_management_app/ --config=.flake8 --count 2>&1 | tail -1)
        if [ "$ERROR_COUNT" -gt 0 ]; then
            echo -e "${YELLOW}⚠ WARNING${NC}: Found $ERROR_COUNT linting issues"
            echo "  Review: flake8 microservices/ student_management_app/ --config=.flake8"
            ((TESTS_FAILED++))
        else
            test_result 0 "No linting issues found"
        fi
    else
        echo -e "${YELLOW}⚠ SKIPPED${NC}: .flake8 config not found"
    fi
else
    echo -e "${YELLOW}⚠ SKIPPED${NC}: flake8 not installed"
    echo ""
fi

# Test 9: Check Docker installation
echo "Test 9: Checking Docker..."
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    test_result 0 "Docker installed: $DOCKER_VERSION"
else
    test_result 1 "Docker not installed"
fi

# Test 10: Check Docker Compose
echo "Test 10: Checking Docker Compose..."
if command -v docker compose &> /dev/null; then
    COMPOSE_VERSION=$(docker compose version)
    test_result 0 "Docker Compose installed: $COMPOSE_VERSION"
else
    test_result 1 "Docker Compose not installed"
fi

# Test 11: Check Dockerfile existence
echo "Test 11: Checking Dockerfiles..."
DOCKERFILES_OK=true
SERVICES=("user-management-service" "academic-service" "attendance-service" "notification-service"
          "leave-management-service" "feedback-service" "assessment-service" "financial-service"
          "api-gateway" "frontend-service")
for service in "${SERVICES[@]}"; do
    if [ -f "microservices/$service/Dockerfile" ]; then
        echo "  ✓ Found: $service/Dockerfile"
    else
        echo "  ✗ Missing: $service/Dockerfile"
        DOCKERFILES_OK=false
    fi
done
if [ "$DOCKERFILES_OK" = true ]; then
    test_result 0 "All Dockerfiles present"
else
    test_result 1 "Some Dockerfiles missing"
fi

# Test 12: Check docker-compose.yml
echo "Test 12: Checking docker-compose.yml..."
if [ -f "microservices/docker-compose.yml" ]; then
    test_result 0 "docker-compose.yml exists"
else
    test_result 1 "docker-compose.yml not found"
fi

# Test 13: Validate docker-compose syntax
echo "Test 13: Validating docker-compose syntax..."
if command -v docker compose &> /dev/null && [ -f "microservices/docker-compose.yml" ]; then
    cd microservices
    if docker compose config > /dev/null 2>&1; then
        test_result 0 "docker-compose.yml syntax is valid"
    else
        test_result 1 "docker-compose.yml has syntax errors"
    fi
    cd ..
else
    echo -e "${YELLOW}⚠ SKIPPED${NC}: Docker Compose not available"
    echo ""
fi

# Test 14: Check requirements files
echo "Test 14: Checking requirements.txt files..."
REQ_FILES_OK=true
for service in "${SERVICES[@]}"; do
    if [ -f "microservices/$service/requirements.txt" ]; then
        echo "  ✓ Found: $service/requirements.txt"
    else
        echo "  ⚠ Missing: $service/requirements.txt"
    fi
done
test_result 0 "Requirements files check complete"

# Summary
echo "=========================================="
echo "TEST SUMMARY"
echo "=========================================="
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed! Your CI/CD setup looks good.${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Push to GitHub: git push origin main"
    echo "2. Check Actions tab on GitHub"
    echo "3. Configure GitHub secrets for deployment"
    exit 0
else
    echo -e "${YELLOW}⚠ Some tests failed or warnings found.${NC}"
    echo ""
    echo "Review the failures above and fix them before pushing to GitHub."
    echo "See CI_CD_VERIFICATION_GUIDE.md for detailed solutions."
    exit 1
fi
